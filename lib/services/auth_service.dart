import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

/// Classe de serviço para autenticação usando API backend
class AuthService {
  static const String baseUrl = 'http://localhost:3000/api';

  /// Realiza login do usuário via API
  /// @param email Email do usuário
  /// @param password Senha do usuário
  /// @returns Instância de User
  Future<User> login(String email, String password) async {
    final response = await http.post(
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
  }

  /// Registra um novo usuário via API
  /// @param email Email do usuário
  /// @param password Senha do usuário
  /// @param name Nome opcional do usuário
  /// @returns Instância de User criado
  Future<User> register(String email, String password, {String? name}) async {
    final response = await http.post(
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
  }
}
