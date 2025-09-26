// lib/screens/landing_page.dart
//
// Landing page principal da plataforma Premiora
// Página inicial com design responsivo para mobile e desktop
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../services/auth_service.dart';
import '../user_state.dart';
import 'home_page.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  // Controladores para os formulários de login/registro
  final TextEditingController _registerNameController = TextEditingController();
  final TextEditingController _registerEmailController = TextEditingController();
  final TextEditingController _registerPasswordController = TextEditingController();
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController = TextEditingController();

  // Serviço de autenticação
  final AuthService _authService = AuthService();

  // Estados dos modais
  bool _showLoginModal = false;
  bool _showRegisterModal = false;

  // Estados de loading e erro
  bool _registerLoading = false;
  String? _registerError;
  bool _loginLoading = false;
  String? _loginError;

  @override
  void dispose() {
    _registerNameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    super.dispose();
  }

  // Função para mostrar modal de registro
  void _showRegisterDialog() {
    setState(() {
      _showRegisterModal = true;
      _registerError = null;
    });
  }

  // Função para mostrar modal de login
  void _showLoginDialog() {
    setState(() {
      _showLoginModal = true;
      _loginError = null;
    });
  }

  // Função para fechar modais
  void _closeModals() {
    setState(() {
      _showLoginModal = false;
      _showRegisterModal = false;
    });
  }

  // Função para login de debug (apenas para teste)
  Future<void> _handleDebugLogin() async {
    setState(() {
      _showLoginModal = false; // Fechar modal antes de navegar
    });

    try {
      final user = await AuthService().debugLogin();
      if (mounted) {
        final userState = Provider.of<UserState>(context, listen: false);
        userState.loginWithUser(user);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }
    } catch (e) {
      // Em caso de erro, mostrar modal de login novamente
      if (mounted) {
        setState(() {
          _showLoginModal = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro no acesso debug: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Conteúdo principal
          SingleChildScrollView(
            child: Column(
              children: [
                // Header
                _buildHeader(),
                // Hero Section
                _buildHeroSection(),
                // Features Section
                _buildFeaturesSection(),
                // Testimonials Section
                _buildTestimonialsSection(),
                // Footer
                _buildFooter(),
              ],
            ),
          ),
          // Modal de Login
          if (_showLoginModal) _buildLoginModal(),
          // Modal de Registro
          if (_showRegisterModal) _buildRegisterModal(),
        ],
      ),
    );
  }

  // Header com navegação
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        children: [
          // Logo
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Premiora',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Navegação desktop
          MediaQuery.of(context).size.width > 768
              ? Row(
                  children: [
                    _buildNavItem('Recursos'),
                    _buildNavItem('Depoimentos'),
                    _buildNavItem('Contato'),
                    const SizedBox(width: 20),
                    _buildOutlinedButton('Entrar', _showLoginDialog),
                    const SizedBox(width: 10),
                    _buildFilledButton('Registrar-se', _showRegisterDialog),
                  ],
                )
              : IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {},
                ),
        ],
      ),
    );
  }

  // Item de navegação
  Widget _buildNavItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
    );
  }

  // Botão outlined
  Widget _buildOutlinedButton(String text, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.black),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.black),
      ),
    );
  }

  // Botão filled
  Widget _buildFilledButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.btnSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  // Seção Hero
  Widget _buildHeroSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
      child: MediaQuery.of(context).size.width > 768
          ? Row(
              children: [
                // Conteúdo da esquerda
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Conteúdo Premium\npara Criadores e Fãs',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Descubra e apoie seus criadores favoritos com assinaturas exclusivas. Acesse conteúdo único, interaja na comunidade e seja parte de algo especial.',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black87,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Row(
                        children: [
                          _buildFilledButton('Comece Agora', () {}),
                          const SizedBox(width: 15),
                          _buildOutlinedButton('Já tenho conta', _showLoginDialog),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 60),
                // Imagem Hero
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 400,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        'Imagem Hero',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Column(
              children: [
                // Imagem Hero para mobile
                Container(
                  height: 250,
                  margin: const EdgeInsets.only(bottom: 40),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      'Imagem Hero',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                // Conteúdo para mobile
                const Text(
                  'Conteúdo Premium\npara Criadores e Fãs',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Descubra e apoie seus criadores favoritos com assinaturas exclusivas. Acesse conteúdo único, interaja na comunidade e seja parte de algo especial.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Column(
                  children: [
                    _buildFilledButton('Comece Agora', () {}),
                    const SizedBox(height: 15),
                    _buildOutlinedButton('Já tenho conta', _showLoginDialog),
                  ],
                ),
              ],
            ),
    );
  }

  // Seção de Features
  Widget _buildFeaturesSection() {
    final features = [
      {
        'icon': Icons.star,
        'title': 'Conteúdo\nExclusivo',
        'description': 'Acesse posts, vídeos e lives exclusivos dos seus criadores favoritos.',
      },
      {
        'icon': Icons.people,
        'title': 'Comunidade\nAtiva',
        'description': 'Interaja com outros fãs e criadores em chats e fóruns dedicados.',
      },
      {
        'icon': Icons.lock,
        'title': 'Pagamentos\nSeguros',
        'description': 'Assinaturas fáceis e seguras com múltiplas opções de pagamento.',
      },
      {
        'icon': Icons.devices,
        'title': 'Acesso em\nQualquer Lugar',
        'description': 'Desfrute do conteúdo no desktop, mobile ou qualquer dispositivo.',
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
      color: Colors.grey[50],
      child: Column(
        children: [
          const Text(
            'Por que escolher nossa plataforma?',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 60),
          MediaQuery.of(context).size.width > 768
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: features.map((feature) => _buildFeatureCard(feature)).toList(),
                )
              : Column(
                  children: features.map((feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: _buildFeatureCard(feature),
                  )).toList(),
                ),
        ],
      ),
    );
  }

  // Card de feature
  Widget _buildFeatureCard(Map<String, dynamic> feature) {
    return Container(
      width: MediaQuery.of(context).size.width > 768 ? 250 : double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            feature['icon'] as IconData,
            size: 50,
            color: AppColors.btnSecondary,
          ),
          const SizedBox(height: 20),
          Text(
            feature['title'] as String,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          Text(
            feature['description'] as String,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Seção de Depoimentos
  Widget _buildTestimonialsSection() {
    final testimonials = [
      {
        'text': 'Incrível plataforma! Encontrei criadores incríveis e o conteúdo é de alta qualidade.',
        'author': 'João Silva, Assinante',
      },
      {
        'text': 'Como criador, adorei a facilidade de monetizar meu trabalho e interagir com fãs.',
        'author': 'Maria Santos, Criadora',
      },
      {
        'text': 'A comunidade é engajada e os pagamentos são super rápidos. Recomendo!',
        'author': 'Carlos Oliveira, Assinante',
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
      child: Column(
        children: [
          const Text(
            'O que nossos usuários dizem',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 60),
          MediaQuery.of(context).size.width > 768
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: testimonials.map((testimonial) => _buildTestimonialCard(testimonial)).toList(),
                )
              : Column(
                  children: testimonials.map((testimonial) => Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: _buildTestimonialCard(testimonial),
                  )).toList(),
                ),
        ],
      ),
    );
  }

  // Card de depoimento
  Widget _buildTestimonialCard(Map<String, dynamic> testimonial) {
    return Container(
      width: MediaQuery.of(context).size.width > 768 ? 300 : double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Text(
            '"${testimonial['text']}"',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              height: 1.6,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            testimonial['author'] as String,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Footer
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      color: Colors.black,
      child: Column(
        children: [
          const Text(
            '© 2025 Premiora. Todos os direitos reservados.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFooterLink('Privacidade'),
              const SizedBox(width: 20),
              _buildFooterLink('Termos'),
              const SizedBox(width: 20),
              _buildFooterLink('Suporte'),
            ],
          ),
        ],
      ),
    );
  }

  // Link do footer
  Widget _buildFooterLink(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        decoration: TextDecoration.underline,
      ),
    );
  }

  // Função para lidar com registro
  Future<void> _handleRegister() async {
    setState(() {
      _registerLoading = true;
      _registerError = null;
    });
    try {
      final user = await _authService.register(
        _registerEmailController.text,
        _registerPasswordController.text,
        name: _registerNameController.text,
      );
      if (mounted) {
        final userState = Provider.of<UserState>(context, listen: false);
        userState.loginWithUser(user);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }
    } on HttpException catch (e) {
      if (mounted) {
        setState(() {
          _registerError = e.message;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _registerError = 'Erro inesperado';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _registerLoading = false;
        });
      }
    }
  }

  // Função para lidar com login
  Future<void> _handleLogin() async {
    setState(() {
      _loginLoading = true;
      _loginError = null;
    });
    try {
      final user = await _authService.login(
        _loginEmailController.text,
        _loginPasswordController.text,
      );
      if (mounted) {
        final userState = Provider.of<UserState>(context, listen: false);
        userState.loginWithUser(user);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }
    } on HttpException catch (e) {
      if (mounted) {
        setState(() {
          _loginError = e.message;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loginError = 'Erro inesperado';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _loginLoading = false;
        });
      }
    }
  }

  // Modal de Login
  Widget _buildLoginModal() {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width > 768 ? 400 : MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Premiora',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Text(
                'Entrar',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 30),
              // Exibir erro se houver
              if (_loginError != null)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Text(
                    _loginError!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (_loginError != null) const SizedBox(height: 20),
              // Campo Email
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Email',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _loginEmailController,
                decoration: InputDecoration(
                  hintText: 'seu@email.com',
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                ),
              ),
              const SizedBox(height: 20),
              // Campo Senha
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Senha',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _loginPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: '.............',
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                ),
              ),
              const SizedBox(height: 30),
              // Botão Entrar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loginLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.btnSecondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: _loginLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Entrar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              // Botão Debug (apenas para teste)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _handleDebugLogin,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Acesso Debug (Teste)',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Links
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Não tem conta? ',
                    style: TextStyle(color: Colors.black87),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showLoginModal = false;
                        _showRegisterModal = true;
                      });
                    },
                    child: const Text(
                      'Registrar-se',
                      style: TextStyle(
                        color: AppColors.btnSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _closeModals,
                child: const Text(
                  'Voltar ao início',
                  style: TextStyle(
                    color: AppColors.btnSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Modal de Registro
  Widget _buildRegisterModal() {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width > 768 ? 400 : MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Premiora',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Text(
                'Registrar-se',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 30),
              // Exibir erro se houver
              if (_registerError != null)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Text(
                    _registerError!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (_registerError != null) const SizedBox(height: 20),
              // Campo Nome
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Nome',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _registerNameController,
                decoration: InputDecoration(
                  hintText: 'Seu nome completo',
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                ),
              ),
              const SizedBox(height: 20),
              // Campo Email
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Email',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _registerEmailController,
                decoration: InputDecoration(
                  hintText: 'seu@email.com',
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                ),
              ),
              const SizedBox(height: 20),
              // Campo Senha
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Senha',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _registerPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Crie uma senha',
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                ),
              ),
              const SizedBox(height: 30),
              // Botão Registrar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _registerLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.btnSecondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: _registerLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Registrar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              // Links
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Já tem conta? ',
                    style: TextStyle(color: Colors.black87),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showRegisterModal = false;
                        _showLoginModal = true;
                      });
                    },
                    child: const Text(
                      'Entrar',
                      style: TextStyle(
                        color: AppColors.btnSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _closeModals,
                child: const Text(
                  'Voltar ao início',
                  style: TextStyle(
                    color: AppColors.btnSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
