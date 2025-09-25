import 'dart:convert';
import 'package:http/http.dart' as http;

/// Serviço base para operações HTTP
/// Fornece configuração comum e tratamento de respostas para serviços derivados
abstract class HttpService {
  // Configurações compartilhadas
  static const String _baseUrl = 'http://localhost:3000/api';
  static const Duration _timeout = Duration(seconds: 10);

  // Headers padrão para requisições
  static const Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
  };

  /// Realiza uma requisição GET
  /// @param endpoint Endpoint da API
  /// @param headers Headers adicionais (opcional)
  /// @returns Resposta HTTP
  Future<http.Response> get(String endpoint, {Map<String, String>? headers}) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final requestHeaders = {..._defaultHeaders, ...?headers};

    return await http.get(url, headers: requestHeaders).timeout(_timeout);
  }

  /// Realiza uma requisição POST
  /// @param endpoint Endpoint da API
  /// @param body Corpo da requisição (JSON)
  /// @param headers Headers adicionais (opcional)
  /// @returns Resposta HTTP
  Future<http.Response> post(String endpoint, dynamic body, {Map<String, String>? headers}) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final requestHeaders = {..._defaultHeaders, ...?headers};

    return await http.post(url, headers: requestHeaders, body: jsonEncode(body)).timeout(_timeout);
  }

  /// Realiza uma requisição PUT
  /// @param endpoint Endpoint da API
  /// @param body Corpo da requisição (JSON)
  /// @param headers Headers adicionais (opcional)
  /// @returns Resposta HTTP
  Future<http.Response> put(String endpoint, dynamic body, {Map<String, String>? headers}) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final requestHeaders = {..._defaultHeaders, ...?headers};

    return await http.put(url, headers: requestHeaders, body: jsonEncode(body)).timeout(_timeout);
  }

  /// Realiza uma requisição DELETE
  /// @param endpoint Endpoint da API
  /// @param headers Headers adicionais (opcional)
  /// @returns Resposta HTTP
  Future<http.Response> delete(String endpoint, {Map<String, String>? headers}) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final requestHeaders = {..._defaultHeaders, ...?headers};

    return await http.delete(url, headers: requestHeaders).timeout(_timeout);
  }

  /// Processa a resposta HTTP e trata erros comuns
  /// @param response Resposta HTTP
  /// @param operation Nome da operação para mensagens de erro
  /// @returns Dados decodificados da resposta ou null
  /// @throws HttpException em caso de erro
  dynamic handleResponse(http.Response response, String operation) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isNotEmpty) {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          throw HttpException('Erro ao processar resposta do servidor para $operation');
        }
      }
      return null;
    } else {
      String errorMessage = 'Falha ao $operation';

      try {
        final errorData = jsonDecode(response.body);
        if (errorData['message'] != null) {
          errorMessage = errorData['message'];
        }
      } catch (e) {
        switch (response.statusCode) {
          case 400:
            errorMessage = 'Dados inválidos fornecidos';
            break;
          case 401:
            errorMessage = 'Não autorizado';
            break;
          case 403:
            errorMessage = 'Acesso negado';
            break;
          case 404:
            errorMessage = 'Recurso não encontrado';
            break;
          case 409:
            errorMessage = 'Conflito de dados';
            break;
          case 500:
            errorMessage = 'Erro interno do servidor';
            break;
          default:
            errorMessage = 'Erro ${response.statusCode} do servidor';
        }
      }

      throw HttpException(errorMessage);
    }
  }
}

/// Exceção customizada para erros HTTP
class HttpException implements Exception {
  final String message;

  HttpException(this.message);

  @override
  String toString() => message;
}
