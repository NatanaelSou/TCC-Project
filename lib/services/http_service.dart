/// Serviço HTTP mock - não usado mais, mantido para compatibilidade
/// Todas as operações HTTP foram substituídas por dados mock estáticos

/// Exceção customizada para erros (mantida para compatibilidade)
class HttpException implements Exception {
  final String message;

  HttpException(this.message);

  @override
  String toString() => message;
}
