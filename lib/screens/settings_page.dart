import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../user_state.dart';
import '../providers/theme_provider.dart';

/// Tela de configurações com opções de conta e preferências
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _notificationsEnabled = true;
  bool _emailUpdates = true;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    final userState = Provider.of<UserState>(context, listen: false);
    _nameController.text = userState.name ?? '';
    _emailController.text = userState.email ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Altera senha
  Future<void> _changePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'As senhas não coincidem';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      // Simulação de mudança de senha
      await Future.delayed(Duration(seconds: 1));

      setState(() {
        _successMessage = 'Senha alterada com sucesso!';
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao alterar senha: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool _cacheCleared = false;

    void _clearCache() {
      setState(() {
        _cacheCleared = true;
      });
      // Aqui você pode adicionar a lógica para limpar o cache real
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          _cacheCleared = false;
        });
      });
    }

    final userState = Provider.of<UserState>(context);

    return Consumer<ThemeNotifier>(
      builder: (context, theme, child) {
        return SingleChildScrollView(
      padding: EdgeInsets.all(AppDimensions.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          Text(
            'Configurações',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: AppDimensions.spacingExtraLarge),

          // Mensagens de erro/sucesso
          if (_errorMessage != null)
            Container(
              padding: EdgeInsets.all(AppDimensions.spacingMedium),
              margin: EdgeInsets.only(bottom: AppDimensions.spacingLarge),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.error, color: Colors.red),
                  SizedBox(width: AppDimensions.spacingMedium),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),

          if (_successMessage != null)
            Container(
              padding: EdgeInsets.all(AppDimensions.spacingMedium),
              margin: EdgeInsets.only(bottom: AppDimensions.spacingLarge),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: AppDimensions.spacingMedium),
                  Expanded(
                    child: Text(
                      _successMessage!,
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                ],
              ),
            ),

          // Seção Conta
          _buildSectionTitle('Conta'),
          _buildActionTile(
            'Logout',
            'Sair da conta',
            Icons.logout,
            Colors.red,
            () {
              userState.logout();
              Navigator.of(context).pushReplacementNamed('/'); // Volta para landing
            },
          ),
          SizedBox(height: AppDimensions.spacingMedium),
          _buildActionTile(
            'Excluir Conta',
            'Remover permanentemente sua conta',
            Icons.delete_forever,
            Colors.red,
            () {
              // Mostrar diálogo de confirmação
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Excluir Conta'),
                  content: Text('Esta ação não pode ser desfeita. Todos os seus dados serão removidos permanentemente.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () {
                        // Implementar exclusão
                        Navigator.of(context).pop();
                      },
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: Text('Excluir'),
                    ),
                  ],
                ),
              );
            },
          ),
          SizedBox(height: AppDimensions.spacingMedium),
          _buildActionTile(
            'Alterar Email',
            'Mudar endereço de email',
            Icons.email,
            AppColors.textDark,
            () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Alterar Email'),
                  content: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: 'Novo Email'),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () {
                        userState.setEmail(_emailController.text);
                        Navigator.of(context).pop();
                        setState(() {
                          _successMessage = 'Email alterado com sucesso!';
                        });
                      },
                      child: Text('Alterar'),
                    ),
                  ],
                ),
              );
            },
          ),
          SizedBox(height: AppDimensions.spacingMedium),
          _buildActionTile(
            'Alterar Senha',
            'Mudar senha da conta',
            Icons.lock,
            AppColors.textDark,
            () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Alterar Senha'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _currentPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(labelText: 'Senha Atual'),
                      ),
                      TextField(
                        controller: _newPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(labelText: 'Nova Senha'),
                      ),
                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(labelText: 'Confirmar Nova Senha'),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () async {
                        if (_newPasswordController.text != _confirmPasswordController.text) {
                          setState(() {
                            _errorMessage = 'As senhas não coincidem';
                          });
                          Navigator.of(context).pop();
                          return;
                        }
                        setState(() {
                          _isLoading = true;
                        });
                        // Simulação de mudança de senha
                        await Future.delayed(Duration(seconds: 1));
                        setState(() {
                          _isLoading = false;
                          _successMessage = 'Senha alterada com sucesso!';
                          _currentPasswordController.clear();
                          _newPasswordController.clear();
                          _confirmPasswordController.clear();
                        });
                        Navigator.of(context).pop();
                      },
                      child: Text('Alterar'),
                    ),
                  ],
                ),
              );
            },
          ),
          SizedBox(height: AppDimensions.spacingMedium),

          // Seção Preferências
          _buildSectionTitle('Preferências'),
          _buildSwitchTile(
            'Modo Escuro',
            'Alternar entre modo claro e escuro',
            theme.isDark,
            (value) => theme.toggleTheme(),
          ),
          SizedBox(height: AppDimensions.spacingMedium),
          _buildActionTile(
            'Limpar Cache',
            _cacheCleared ? 'Cache limpo com sucesso' : 'Remover arquivos temporários',
            Icons.delete_sweep,
            _cacheCleared ? Colors.green : AppColors.textDark,
            () {
              if (!_cacheCleared) {
                _clearCache();
              }
            },
          ),

          // Seção Notificações
          _buildSectionTitle('Notificações'),
          _buildSwitchTile(
            'Notificações push',
            'Receber notificações no dispositivo',
            _notificationsEnabled,
            (value) => setState(() => _notificationsEnabled = value),
          ),
          _buildSwitchTile(
            'Atualizações por email',
            'Receber newsletters e atualizações',
            _emailUpdates,
            (value) => setState(() => _emailUpdates = value),
          ),
        ],
      ),
    );
      },
    );
  }

  /// Constrói título de seção
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppDimensions.spacingMedium),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
        ),
      ),
    );
  }

  /// Constrói campo de texto
  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.iconDark),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        ),
        filled: true,
        fillColor: AppColors.inputFill,
      ),
    );
  }

  /// Constrói tile com switch
  Widget _buildSwitchTile(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: EdgeInsets.only(bottom: AppDimensions.spacingMedium),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        border: Border.all(color: AppColors.textGrey),
      ),
      child: ListTile(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w500, color: AppColors.textDark)),
        subtitle: Text(subtitle, style: TextStyle(color: AppColors.textGrey)),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.btnSecondary,
        ),
      ),
    );
  }

  /// Constrói tile de ação
  Widget _buildActionTile(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        border: Border.all(color: AppColors.textGrey),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w500, color: color)),
        subtitle: Text(subtitle, style: TextStyle(color: AppColors.textGrey)),
        onTap: onTap,
      ),
    );
  }
}
