import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

/// Classe de serviço para autenticação usando API backend
class AuthService {
  final String baseUrl;

  AuthService({required this.baseUrl});

  /// Realiza login do usuário via API
  /// @param email Email do usuário
  /// @param password Senha do usuário
  /// @returns Instância de User
  Future<User> login(String email, String password) async {
    try {
      final response = await http.post(
    // AVISO: Verifique se o uso de BuildContext após await é seguro
    // AVISO: Verifique se o uso de BuildContext após await é seguro
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data['user']);
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Erro no login');
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception('Erro de conexão: Verifique se o servidor está rodando e acessível');
      }
      rethrow;
    }
  }

  /// Registra um novo usuário via API
  /// @param email Email do usuário
  /// @param password Senha do usuário
  /// @param name Nome opcional do usuário
  /// @returns Instância de User criado
  Future<User> register(String email, String password, {String? name}) async {
    try {
      final response = await http.post(
    // AVISO: Verifique se o uso de BuildContext após await é seguro
    // AVISO: Verifique se o uso de BuildContext após await é seguro
        Uri.parse('$baseUrl/users/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password, 'name': name}),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return User.fromJson(data['user']);
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Erro no registro');
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception('Erro de conexão: Verifique se o servidor está rodando e acessível');
      }
      rethrow;
    }
  }
}
