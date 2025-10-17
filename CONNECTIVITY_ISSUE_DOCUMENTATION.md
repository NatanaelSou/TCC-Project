# Documentação do Erro de Conectividade - Flutter + Node.js + MySQL

## Descrição do Problema

O aplicativo Flutter estava falhando ao tentar se conectar à API do backend Node.js para operações de login e cadastro. O erro observado era: `uri=http://192.168.3.8:3000/api/login`, indicando falha de conexão.

## Análise do Erro

### Problemas Identificados

1. **Porta Incorreta no baseUrl do Flutter**
   - **Arquivo**: `lib/core/constants/constants.dart`
   - **Problema**: A constante `baseUrl` estava definida como `http://192.168.3.8:3306` (porta do MySQL) ao invés de `http://192.168.3.8:3000` (porta do servidor Node.js)
   - **Impacto**: O app tentava conectar na porta errada, causando falha de conexão

2. **Servidor Node.js Configurado na Porta Errada**
   - **Arquivo**: `backend/index.js`
   - **Problema**: O servidor estava configurado para ouvir na porta 3306 ao invés de 3000
   - **Impacto**: Conflito de portas e servidor não disponível na porta esperada

3. **Log de Inicialização Incorreto**
   - **Arquivo**: `backend/index.js`
   - **Problema**: O log de inicialização mostrava `http://192.168.1.7:3000` (IP incorreto)
   - **Impacto**: Confusão sobre qual IP/porta o servidor estava rodando

4. **Tratamento de Erros Insuficiente**
   - **Arquivo**: `lib/data/services/auth_service.dart`
   - **Problema**: Métodos `login()` e `register()` não tratavam adequadamente erros de rede
   - **Impacto**: Exceções não tratadas causavam crashes no app

## Correções Implementadas

### 1. Correção da Porta no baseUrl

```dart
// lib/core/constants/constants.dart
// ANTES:
const String baseUrl = 'http://192.168.3.8:3306';

// DEPOIS:
// Para desenvolvimento local (host machine)
const String baseUrl = 'http://192.168.3.8:3000';

// Para emulador Android, descomente a linha abaixo e comente a acima
// const String baseUrl = 'http://10.0.2.2:3000';
```

### 2. Correção da Porta do Servidor Node.js

```javascript
// backend/index.js
// ANTES:
app.listen(3306, "0.0.0.0", () =>
  console.log(
    "Servidor: http://192.168.3.8:3306 - /api/users - /api/login - /api/profiles - /api/content - /api/community",
  ),
);

// DEPOIS:
app.listen(3000, "0.0.0.0", () =>
  console.log(
    "Servidor: http://192.168.3.8:3000 - /api/users - /api/login - /api/profiles - /api/content - /api/community",
  ),
);
```

### 3. Correção do Log de Inicialização

```javascript
// backend/index.js
// ANTES:
console.log(
  "Servidor: http://192.168.1.7:3000 - /api/users - /api/login - /api/profiles - /api/content - /api/community",
);

// DEPOIS:
console.log(
  "Servidor: http://192.168.3.8:3000 - /api/users - /api/login - /api/profiles - /api/content - /api/community",
);
```

### 4. Melhoria no Tratamento de Erros

```dart
// lib/data/services/auth_service.dart
Future<User> login(String email, String password) async {
  try {
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
  } catch (e) {
    if (e is http.ClientException) {
      throw Exception('Erro de conexão: Verifique se o servidor está rodando e acessível');
    }
    rethrow;
  }
}
```

## Testes de Validação

### Testes Realizados

1. **Teste de Login via API**:

   ```bash
   curl -X POST http://192.168.3.8:3000/api/login \
        -H "Content-Type: application/json" \
        -d '{"email":"test2@example.com","password":"password123"}'
   ```

   **Resultado**: Sucesso - usuário logado

2. **Teste de Registro via API**:

   ```bash
   curl -X POST http://192.168.3.8:3000/api/users/register \
        -H "Content-Type: application/json" \
        -d '{"email":"newuser@example.com","password":"password123","name":"New User"}'
   ```

   **Resultado**: Sucesso - usuário registrado

3. **Verificação de Conectividade do Servidor**:
   - Servidor Node.js iniciando corretamente na porta 3000
   - Conexão MySQL estabelecida
   - Logs indicando funcionamento normal

## Alternativas de Melhoria

### 1. Configuração de Ambiente

**Problema**: IPs e portas hardcoded dificultam deploy em diferentes ambientes.

**Solução Recomendada**:

```dart
// lib/core/constants/constants.dart
import 'package:flutter/foundation.dart';

const String baseUrl = kDebugMode
    ? 'http://192.168.3.8:3000'  // Desenvolvimento
    : 'https://api.premiora.com'; // Produção
```

### 2. Timeout nas Requisições HTTP

**Problema**: Requisições podem travar indefinidamente em conexões lentas.

**Solução Recomendada**:

```dart
// lib/data/services/auth_service.dart
class AuthService {
  final Duration timeout = const Duration(seconds: 10);

  Future<User> login(String email, String password) async {
    final client = http.Client();
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(timeout);

      // ... resto do código
    } finally {
      client.close();
    }
  }
}
```

### 3. Retry Logic para Falhas Temporárias

**Problema**: Falhas de rede temporárias causam erros desnecessários.

**Solução Recomendada**:

```dart
// lib/data/services/auth_service.dart
Future<T> _retryRequest<T>(Future<T> Function() request, {int maxRetries = 3}) async {
  for (int i = 0; i < maxRetries; i++) {
    try {
      return await request();
    } catch (e) {
      if (i == maxRetries - 1) rethrow;
      await Future.delayed(Duration(seconds: 1 << i)); // Exponential backoff
    }
  }
  throw Exception('Max retries exceeded');
}
```

### 4. Variáveis de Ambiente para Configuração

**Problema**: Credenciais e configurações hardcoded.

**Solução Recomendada**:

```javascript
// backend/.env
DB_HOST=192.168.3.8
DB_USER=tcc_user
DB_PASSWORD=512200Balatro@
DB_NAME=tcc_project
SERVER_PORT=3000

// backend/config/db.js
require('dotenv').config();
const connection = mysql.createConnection({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME
});
```

### 5. Health Check Endpoint

**Problema**: Dificuldade em diagnosticar se o servidor está funcionando.

**Solução Recomendada**:

```javascript
// backend/index.js
app.get("/health", (req, res) => {
  db.query("SELECT 1", (err) => {
    if (err) {
      res
        .status(500)
        .json({ status: "error", message: "Database connection failed" });
    } else {
      res.json({ status: "ok", timestamp: new Date().toISOString() });
    }
  });
});
```

### 6. Logging Melhorado

**Problema**: Dificuldade em debugar problemas de conectividade.

**Solução Recomendada**:

```javascript
// backend/index.js
const winston = require("winston");

const logger = winston.createLogger({
  level: "info",
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json(),
  ),
  transports: [
    new winston.transports.File({ filename: "logs/error.log", level: "error" }),
    new winston.transports.File({ filename: "logs/combined.log" }),
  ],
});

app.use((req, res, next) => {
  logger.info(`${req.method} ${req.url}`, {
    ip: req.ip,
    userAgent: req.get("User-Agent"),
  });
  next();
});
```

### 7. Monitoramento de Conectividade no Flutter

**Problema**: App não detecta quando perde conectividade.

**Solução Recomendada**:

```dart
// lib/core/utils/connectivity_utils.dart
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityUtils {
  static Future<bool> hasInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  static Stream<ConnectivityResult> get connectivityStream =>
      Connectivity().onConnectivityChanged;
}
```

## Conclusão

O erro de conectividade foi causado principalmente por configuração incorreta de portas entre o Flutter (apontando para MySQL) e o Node.js (ouvindo na porta errada). As correções implementadas resolveram o problema imediato.

As alternativas de melhoria sugeridas visam tornar o sistema mais robusto, configurável e fácil de manter em diferentes ambientes de desenvolvimento e produção.

## Lições Aprendidas

1. Sempre verificar se portas e IPs estão corretos em todas as camadas da aplicação
2. Implementar tratamento adequado de erros para melhorar experiência do usuário
3. Usar variáveis de ambiente para configurações sensíveis
4. Adicionar timeouts e retry logic para operações de rede
5. Manter logs claros e precisos para facilitar debugging
