const LoginService = require('../services/loginService');

exports.loginUser = async (req, res) => {
  try {
    const { email, password } = req.body;
    const user = await LoginService.checkLogin(email, password);
    
    if (!user) {
      return res.status(401).json({ message: 'Usuário ou senha inválidos' });
    }

    res.json({ message: 'Login efetuado com sucesso', user });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
// Controller de login
exports.loginUser = async (req, res) => {
  try {
    console.log('[LoginController] Requisição de login recebida:', req.body);
    const { email, password } = req.body;
    const user = await LoginService.checkLogin(email, password);

    if (!user) {
      console.log('[LoginController] Usuário ou senha inválidos');
      return res.status(401).json({ message: 'Usuário ou senha inválidos' });
    }

    console.log('[LoginController] Login efetuado com sucesso:', user);
    res.json({ message: 'Login efetuado com sucesso', user });
  } catch (err) {
    console.error('[LoginController] Erro no login:', err);
    res.status(500).json({ error: err.message });
  }
};
