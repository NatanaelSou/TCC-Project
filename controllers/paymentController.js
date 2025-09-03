// Controlador para processamento de pagamentos
const mercadopago = require('mercadopago');
const paypal = require('paypal-rest-sdk');
const db = require('../config/database');

// Configurar Mercado Pago
mercadopago.configure({
  access_token: process.env.MERCADO_PAGO_ACCESS_TOKEN
});

// Configurar PayPal
paypal.configure({
  mode: process.env.PAYPAL_MODE || 'sandbox',
  client_id: process.env.PAYPAL_CLIENT_ID,
  client_secret: process.env.PAYPAL_CLIENT_SECRET
});

// Criar preferência de pagamento Mercado Pago
exports.createMercadoPagoPreference = async (req, res) => {
  try {
    const { subscription_id, amount, description } = req.body;

    // Buscar informações da assinatura
    const subscriptionQuery = `
      SELECT s.*, u.name as user_name, u.email,
             c.name as creator_name, t.name as tier_name, t.price
      FROM subscriptions s
      JOIN users u ON s.user_id = u.id
      JOIN users c ON s.creator_id = c.id
      JOIN tiers t ON s.tier_id = t.id
      WHERE s.id = ?
    `;

    db.query(subscriptionQuery, [subscription_id], (err, results) => {
      if (err || results.length === 0) {
        return res.status(404).json({ error: 'Assinatura não encontrada' });
      }

      const subscription = results[0];

      // Criar preferência no Mercado Pago
      const preference = {
        items: [{
          title: `Assinatura ${subscription.tier_name} - ${subscription.creator_name}`,
          description: description || `Assinatura mensal do criador ${subscription.creator_name}`,
          quantity: 1,
          currency_id: 'BRL',
          unit_price: parseFloat(amount || subscription.price)
        }],
        payer: {
          name: subscription.user_name,
          email: subscription.email
        },
        back_urls: {
          success: `${process.env.FRONTEND_URL}/payment/success`,
          failure: `${process.env.FRONTEND_URL}/payment/failure`,
          pending: `${process.env.FRONTEND_URL}/payment/pending`
        },
        auto_return: 'approved',
        external_reference: `sub_${subscription_id}`,
        notification_url: `${process.env.BACKEND_URL}/api/payments/webhook/mercadopago`
      };

      mercadopago.preferences.create(preference)
        .then(response => {
          res.json({
            preference_id: response.body.id,
            init_point: response.body.init_point,
            sandbox_init_point: response.body.sandbox_init_point
          });
        })
        .catch(error => {
          console.error('Erro ao criar preferência Mercado Pago:', error);
          res.status(500).json({ error: 'Erro ao processar pagamento' });
        });
    });
  } catch (error) {
    console.error('Erro no controlador de pagamento:', error);
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
};

// Criar pagamento PayPal
exports.createPayPalPayment = async (req, res) => {
  try {
    const { subscription_id, amount, description } = req.body;

    // Buscar informações da assinatura
    const subscriptionQuery = `
      SELECT s.*, u.name as user_name, u.email,
             c.name as creator_name, t.name as tier_name, t.price
      FROM subscriptions s
      JOIN users u ON s.user_id = u.id
      JOIN users c ON s.creator_id = c.id
      JOIN tiers t ON s.tier_id = t.id
      WHERE s.id = ?
    `;

    db.query(subscriptionQuery, [subscription_id], (err, results) => {
      if (err || results.length === 0) {
        return res.status(404).json({ error: 'Assinatura não encontrada' });
      }

      const subscription = results[0];

      const create_payment_json = {
        intent: 'sale',
        payer: {
          payment_method: 'paypal'
        },
        redirect_urls: {
          return_url: `${process.env.FRONTEND_URL}/payment/success`,
          cancel_url: `${process.env.FRONTEND_URL}/payment/cancel`
        },
        transactions: [{
          item_list: {
            items: [{
              name: `Assinatura ${subscription.tier_name}`,
              sku: `sub_${subscription_id}`,
              price: (amount || subscription.price).toFixed(2),
              currency: 'BRL',
              quantity: 1
            }]
          },
          amount: {
            currency: 'BRL',
            total: (amount || subscription.price).toFixed(2)
          },
          description: description || `Assinatura mensal do criador ${subscription.creator_name}`
        }]
      };

      paypal.payment.create(create_payment_json, (error, payment) => {
        if (error) {
          console.error('Erro ao criar pagamento PayPal:', error);
          res.status(500).json({ error: 'Erro ao processar pagamento' });
        } else {
          // Salvar informações do pagamento
          const paymentData = {
            subscription_id: subscription_id,
            amount: amount || subscription.price,
            currency: 'BRL',
            gateway: 'paypal',
            transaction_id: payment.id,
            status: 'pending'
          };

          db.query('INSERT INTO payments SET ?', paymentData, (err, result) => {
            if (err) {
              console.error('Erro ao salvar pagamento:', err);
            }
          });

          // Encontrar link de aprovação
          const approval_url = payment.links.find(link => link.rel === 'approval_url');

          res.json({
            payment_id: payment.id,
            approval_url: approval_url ? approval_url.href : null,
            payment: payment
          });
        }
      });
    });
  } catch (error) {
    console.error('Erro no controlador PayPal:', error);
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
};

// Executar pagamento PayPal
exports.executePayPalPayment = async (req, res) => {
  try {
    const { paymentId, payerId } = req.body;

    paypal.payment.execute(paymentId, { payer_id: payerId }, (error, payment) => {
      if (error) {
        console.error('Erro ao executar pagamento PayPal:', error);
        res.status(500).json({ error: 'Erro ao executar pagamento' });
      } else {
        // Atualizar status do pagamento
        db.query(
          'UPDATE payments SET status = ?, updated_at = NOW() WHERE transaction_id = ?',
          ['completed', paymentId],
          (err, result) => {
            if (err) {
              console.error('Erro ao atualizar pagamento:', err);
            }
          }
        );

        res.json({
          success: true,
          payment: payment
        });
      }
    });
  } catch (error) {
    console.error('Erro ao executar pagamento:', error);
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
};

// Webhook Mercado Pago
exports.handleMercadoPagoWebhook = async (req, res) => {
  try {
    const { id, topic } = req.query;

    if (topic === 'payment') {
      // Buscar informações do pagamento
      mercadopago.payment.get(id)
        .then(payment => {
          const paymentInfo = payment.body;

          // Atualizar status do pagamento no banco
          const status = paymentInfo.status === 'approved' ? 'completed' :
                        paymentInfo.status === 'pending' ? 'pending' :
                        paymentInfo.status === 'rejected' ? 'failed' : 'pending';

          const externalReference = paymentInfo.external_reference;

          if (externalReference && externalReference.startsWith('sub_')) {
            const subscriptionId = externalReference.replace('sub_', '');

            // Salvar ou atualizar pagamento
            const paymentData = {
              subscription_id: subscriptionId,
              amount: paymentInfo.transaction_amount,
              currency: paymentInfo.currency_id,
              gateway: 'mercadopago',
              transaction_id: paymentInfo.id.toString(),
              status: status
            };

            // Verificar se já existe
            db.query('SELECT id FROM payments WHERE transaction_id = ?', [paymentInfo.id], (err, results) => {
              if (err) {
                console.error('Erro ao verificar pagamento existente:', err);
                return res.status(500).send('Erro');
              }

              if (results.length === 0) {
                // Inserir novo pagamento
                db.query('INSERT INTO payments SET ?', paymentData, (err, result) => {
                  if (err) {
                    console.error('Erro ao salvar pagamento:', err);
                  }
                });
              } else {
                // Atualizar pagamento existente
                db.query(
                  'UPDATE payments SET status = ?, updated_at = NOW() WHERE transaction_id = ?',
                  [status, paymentInfo.id],
                  (err, result) => {
                    if (err) {
                      console.error('Erro ao atualizar pagamento:', err);
                    }
                  }
                );
              }
            });
          }

          res.status(200).send('OK');
        })
        .catch(error => {
          console.error('Erro ao buscar pagamento Mercado Pago:', error);
          res.status(500).send('Erro');
        });
    } else {
      res.status(200).send('OK');
    }
  } catch (error) {
    console.error('Erro no webhook Mercado Pago:', error);
    res.status(500).send('Erro');
  }
};

// Listar pagamentos do usuário
exports.getUserPayments = async (req, res) => {
  try {
    const userId = req.user.id;

    const query = `
      SELECT p.*, s.creator_id, u.name as creator_name, t.name as tier_name
      FROM payments p
      JOIN subscriptions s ON p.subscription_id = s.id
      JOIN users u ON s.creator_id = u.id
      JOIN tiers t ON s.tier_id = t.id
      WHERE s.user_id = ?
      ORDER BY p.created_at DESC
    `;

    db.query(query, [userId], (err, results) => {
      if (err) {
        return res.status(500).json({ error: 'Erro ao buscar pagamentos' });
      }

      res.json(results);
    });
  } catch (error) {
    console.error('Erro ao buscar pagamentos:', error);
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
};

// Listar pagamentos do criador
exports.getCreatorPayments = async (req, res) => {
  try {
    const creatorId = req.user.id;

    const query = `
      SELECT p.*, s.user_id, u.name as user_name, t.name as tier_name
      FROM payments p
      JOIN subscriptions s ON p.subscription_id = s.id
      JOIN users u ON s.user_id = u.id
      JOIN tiers t ON s.tier_id = t.id
      WHERE s.creator_id = ?
      ORDER BY p.created_at DESC
    `;

    db.query(query, [creatorId], (err, results) => {
      if (err) {
        return res.status(500).json({ error: 'Erro ao buscar pagamentos' });
      }

      res.json(results);
    });
  } catch (error) {
    console.error('Erro ao buscar pagamentos:', error);
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
};
