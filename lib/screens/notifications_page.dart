import 'package:flutter/material.dart';
import '../constants.dart';

/// Tela de notificações com lista de atividades recentes
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  // Dados mock de notificações
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'type': 'follow',
      'title': 'Novo seguidor',
      'message': 'João Silva começou a seguir você',
      'time': '2 min atrás',
      'read': false,
      'avatar': null,
    },
    {
      'id': '2',
      'type': 'like',
      'title': 'Curtida no post',
      'message': 'Maria Santos curtiu seu post "Análise do filme..."',
      'time': '15 min atrás',
      'read': false,
      'avatar': null,
    },
    {
      'id': '3',
      'type': 'comment',
      'title': 'Novo comentário',
      'message': 'Carlos Oliveira comentou no seu vídeo',
      'time': '1h atrás',
      'read': true,
      'avatar': null,
    },
    {
      'id': '4',
      'type': 'subscription',
      'title': 'Nova assinatura',
      'message': 'Ana Santos se inscreveu no seu nível Bronze',
      'time': '3h atrás',
      'read': true,
      'avatar': null,
    },
    {
      'id': '5',
      'type': 'mention',
      'title': 'Menção',
      'message': 'Você foi mencionado por Pedro Costa',
      'time': '1 dia atrás',
      'read': true,
      'avatar': null,
    },
  ];

  /// Marca notificação como lida
  void _markAsRead(String id) {
    setState(() {
      final notification = _notifications.firstWhere((n) => n['id'] == id);
      notification['read'] = true;
    });
  }

  /// Obtém ícone baseado no tipo de notificação
  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'follow':
        return Icons.person_add;
      case 'like':
        return Icons.favorite;
      case 'comment':
        return Icons.comment;
      case 'subscription':
        return Icons.star;
      case 'mention':
        return Icons.alternate_email;
      default:
        return Icons.notifications;
    }
  }

  /// Obtém cor baseada no tipo de notificação
  Color _getNotificationColor(String type) {
    switch (type) {
      case 'follow':
        return Colors.blue;
      case 'like':
        return Colors.red;
      case 'comment':
        return Colors.green;
      case 'subscription':
        return Colors.orange;
      case 'mention':
        return Colors.purple;
      default:
        return AppColors.btnSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !(n['read'] as bool)).length;

    return Column(
      children: [
        // Header
        Container(
          padding: EdgeInsets.all(AppDimensions.spacingLarge),
          color: Colors.white,
          child: Row(
            children: [
              Text(
                'Notificações',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              SizedBox(width: AppDimensions.spacingMedium),
              if (unreadCount > 0)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.btnSecondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$unreadCount não lidas',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              Spacer(),
              TextButton(
                onPressed: () {
                  setState(() {
                    for (var notification in _notifications) {
                      notification['read'] = true;
                    }
                  });
                },
                child: Text(
                  'Marcar todas como lidas',
                  style: TextStyle(color: AppColors.btnSecondary),
                ),
              ),
            ],
          ),
        ),

        // Lista de notificações
        Expanded(
          child: _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 64,
                        color: AppColors.textGrey,
                      ),
                      SizedBox(height: AppDimensions.spacingMedium),
                      Text(
                        'Nenhuma notificação',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    return _buildNotificationItem(notification);
                  },
                ),
        ),
      ],
    );
  }

  /// Constrói item de notificação
  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    final isRead = notification['read'] as bool;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppDimensions.spacingLarge, vertical: 2),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : AppColors.btnSecondary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        border: Border.all(
          color: isRead ? Colors.grey.shade200 : AppColors.btnSecondary.withOpacity(0.2),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getNotificationColor(notification['type']),
          child: Icon(
            _getNotificationIcon(notification['type']),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          notification['title'],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification['message'],
              style: TextStyle(
                color: AppColors.textGrey,
              ),
            ),
            SizedBox(height: 4),
            Text(
              notification['time'],
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textGrey,
              ),
            ),
          ],
        ),
        trailing: !isRead
            ? Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.btnSecondary,
                  shape: BoxShape.circle,
                ),
              )
            : null,
        onTap: () {
          if (!isRead) {
            _markAsRead(notification['id']);
          }
          // Aqui poderia navegar para o conteúdo relacionado
        },
      ),
    );
  }
}
