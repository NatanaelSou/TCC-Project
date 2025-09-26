const LoginService = require('../services/loginService');

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

// Controller de debug login (apenas para teste)
exports.debugLogin = async (req, res) => {
  try {
    console.log('[LoginController] Requisição de debug login recebida');
    // Retorna um usuário mock para teste
    const mockUser = {
      id: 999,
      email: 'debug@teste.com',
      name: 'Usuário Debug'
    };

    console.log('[LoginController] Debug login efetuado com sucesso:', mockUser);
    res.json({ message: 'Debug login efetuado com sucesso', user: mockUser });
  } catch (err) {
    console.error('[LoginController] Erro no debug login:', err);
    res.status(500).json({ error: err.message });
  }
};
