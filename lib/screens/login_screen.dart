// lib/screens/login_screen.dart
//
// Tela de login com validação e tratamento de erro robusto
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';

// Serviços e Estado
import '../services/auth_service.dart';
import '../services/http_service.dart';
import '../user_state.dart';
import '../utils/validators.dart';
import '../constants.dart';

/// Tela de login com validação e tratamento de erro robusto
class LoginScreen extends StatefulWidget {
  final VoidCallback? onLoginSuccess;

  const LoginScreen({this.onLoginSuccess, super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controladores de texto
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Estado
  final AuthService _authService = AuthService();
  String? _emailError;
  String? _passwordError;
  bool _isLoading = false;

  /// Constrói os links de navegação (esqueceu senha, cadastre-se)
  List<Widget> _buildLinks() {
    return [
      GestureDetector(
        onTap: () {},
        child: Text(
          'Esqueceu a senha?',
          style: TextStyle(
            color: AppColors.primary,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
      SizedBox(width: AppDimensions.spacingMedium, height: AppDimensions.spacingSmall),
      Expanded(
        child: RichText(
          text: TextSpan(
            style: TextStyle(color: AppColors.textDark),
            children: [
              TextSpan(text: 'Não tem uma conta? '),
              TextSpan(
                text: 'Cadastre-se',
                style: TextStyle(
                  color: AppColors.primary,
                  decoration: TextDecoration.underline,
                ),
                recognizer: TapGestureRecognizer()..onTap = () {},
              ),
            ],
          ),
        ),
      ),
    ];
  }

  // Construção do Widget
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: 500, // largura máxima do login
      ),
      child: Center(
        child: Container(
          padding: EdgeInsets.all(40),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Título
                Text(
                  'Bem-vindo de volta!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppDimensions.spacingLarge),
                Text(
                  'Faça login para continuar',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textGrey,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppDimensions.spacingExtraLarge),

                // Campo de email
                TextFormField(
                  controller: _emailController,
                  validator: Validators.validateEmail,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email, color: AppColors.primary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
                    ),
                    errorText: _emailError,
                    filled: true,
                    fillColor: AppColors.inputFill,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: AppDimensions.spacingLarge),

                // Campo de senha
                TextFormField(
                  controller: _passwordController,
                  validator: Validators.validatePassword,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: Icon(Icons.lock, color: AppColors.primary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
                    ),
                    errorText: _passwordError,
                    filled: true,
                    fillColor: AppColors.inputFill,
                  ),
                  textInputAction: TextInputAction.done,
                ),
                SizedBox(height: AppDimensions.spacingExtraLarge),

                // Botão de login
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _handleLogin,
                  icon: Icon(Icons.login, color: AppColors.textLight),
                  label: Text(
                    _isLoading ? 'Entrando...' : 'Entrar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacingExtraLarge,
                      vertical: AppDimensions.spacingLarge,
                    ),
                    shape: StadiumBorder(),
                  ),
                ),

                // --- Additional Links ---
                LayoutBuilder(
                  builder: (context, constraints) {
                    bool useColumn = constraints.maxWidth < 360;

                    return useColumn
                        ? Column(children: [..._buildLinks()])
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [..._buildLinks()],
                          );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Manipula o processo de login
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _emailError = null;
      _passwordError = null;
    });

    try {
      final user = await _authService.login(
        _emailController.text,
        _passwordController.text,
      );

      if (mounted) {
        final userState = Provider.of<UserState>(context, listen: false);
        userState.loginWithUser(user);

        if (widget.onLoginSuccess != null) {
          widget.onLoginSuccess!();
        }

        Navigator.of(context).pop();
      }
    } on HttpException catch (e) {
      if (mounted) {
        setState(() {
          _emailError = e.message;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _emailError = AppStrings.invalidCredentialsError;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
