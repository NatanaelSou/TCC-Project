// lib/screens/landing_page.dart
//
// Landing page principal da plataforma Premiora
// Página inicial com design responsivo para mobile e desktop
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../user_state.dart';
import '../widgets/header_widget.dart';
import '../widgets/hero_section_widget.dart';
import '../widgets/features_section_widget.dart';
import '../widgets/testimonials_section_widget.dart';
import '../widgets/footer_widget.dart';
import '../widgets/login_modal_widget.dart';
import '../widgets/register_modal_widget.dart';
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
  final AuthService _authService = AuthService(baseUrl: 'http://192.168.1.7:3000/api');

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
                HeaderWidget(
                  onLoginPressed: _showLoginDialog,
                  onRegisterPressed: _showRegisterDialog,
                ),
                // Hero Section
                HeroSectionWidget(
                  onStartPressed: () {}, // Placeholder para ação de "Comece Agora"
                  onLoginPressed: _showLoginDialog,
                ),
                // Features Section
                const FeaturesSectionWidget(),
                // Testimonials Section
                const TestimonialsSectionWidget(),
                // Footer
                const FooterWidget(),
              ],
            ),
          ),
          // Modal de Login
          if (_showLoginModal)
            LoginModalWidget(
              emailController: _loginEmailController,
              passwordController: _loginPasswordController,
              isLoading: _loginLoading,
              error: _loginError,
              onLogin: _handleLogin,
              onClose: _closeModals,
              onSwitchToRegister: () {
                setState(() {
                  _showLoginModal = false;
                  _showRegisterModal = true;
                });
              },
            ),
          // Modal de Registro
          if (_showRegisterModal)
            RegisterModalWidget(
              nameController: _registerNameController,
              emailController: _registerEmailController,
              passwordController: _registerPasswordController,
              isLoading: _registerLoading,
              error: _registerError,
              onRegister: _handleRegister,
              onClose: _closeModals,
              onSwitchToLogin: () {
                setState(() {
                  _showRegisterModal = false;
                  _showLoginModal = true;
                });
              },
            ),
        ],
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
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _registerError = 'Erro de conexão: ${e.toString()}';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _registerError = 'Ocorreu um erro inesperado. Tente novamente.';
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
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _loginError = 'Erro de conexão: ${e.toString()}';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loginError = 'Ocorreu um erro inesperado. Tente novamente.';
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




}
