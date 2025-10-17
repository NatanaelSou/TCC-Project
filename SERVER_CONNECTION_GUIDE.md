# Guia de Conexão com o Servidor - Projeto Premiora

Este documento fornece instruções detalhadas para configurar e acessar o servidor do projeto Premiora em diferentes ambientes de desenvolvimento e acesso.

## Visão Geral da Arquitetura

- **Frontend**: Aplicativo Flutter
- **Backend**: Servidor Node.js (porta 3000)
- **Banco de Dados**: MySQL (porta 3306)
- **Comunicação**: HTTP/REST API

## Pré-requisitos

### Software Necessário

- Node.js (versão 16 ou superior)
- MySQL Server
- Flutter SDK
- Git

### Configurações de Rede

- O servidor Node.js deve estar acessível na rede local
- Firewall deve permitir conexões na porta 3000
- MySQL deve aceitar conexões remotas (se necessário)

## Métodos de Acesso

### 1. Desenvolvimento Local (Host Machine)

**Cenário**: Desenvolvedor trabalhando na mesma máquina onde o servidor roda.

**Configuração no Flutter**:

```dart
// lib/core/constants/constants.dart
const String baseUrl = 'http://localhost:3000';
```

**Configuração no Backend**:

```javascript
// backend/index.js
app.listen(3000, "localhost", () => {
  console.log("Servidor: http://localhost:3000");
});
```

**Passos**:

1. Inicie o MySQL Server localmente
2. Execute `cd backend && npm install && node index.js`
3. Execute `flutter run` no projeto Flutter

### 2. Acesso via Emulador Android

**Cenário**: Testando o app em emulador Android no mesmo computador.

**Configuração no Flutter**:

```dart
// lib/core/constants/constants.dart
const String baseUrl = 'http://10.0.2.2:3000';
```

**Configuração no Backend**:

```javascript
// backend/index.js
app.listen(3000, "0.0.0.0", () => {
  console.log("Servidor: http://[IP-DA-MAQUINA]:3000");
});
```

**Passos**:

1. Descubra o IP da máquina host: `ipconfig` (Windows) ou `ifconfig` (Linux/Mac)
2. Configure o backend para ouvir em `0.0.0.0`
3. Use `10.0.2.2` no Flutter (este é o alias do emulador para o host)

### 3. Acesso via Rede Local (Compartilhado)

**Cenário**: Múltiplos desenvolvedores acessando o mesmo servidor na rede local.

**Configuração no Flutter**:

```dart
// lib/core/constants/constants.dart
const String baseUrl = 'http://[IP-DO-SERVIDOR]:3000';
```

**Configuração no Backend**:

```javascript
// backend/index.js
app.listen(3000, "0.0.0.0", () => {
  console.log("Servidor: http://[IP-DA-MAQUINA]:3000");
});
```

**Passos para o Servidor (Máquina A)**:

1. Descubra o IP da máquina: `ipconfig` (Windows) ou `ifconfig` (Linux/Mac)
2. Configure o MySQL para aceitar conexões remotas:
   ```sql
   -- No MySQL Workbench ou terminal MySQL:
   CREATE USER 'tcc_user'@'%' IDENTIFIED BY '512200Balatro@';
   GRANT ALL PRIVILEGES ON tcc_project.* TO 'tcc_user'@'%';
   FLUSH PRIVILEGES;
   ```
3. Atualize `backend/config/db.js` se necessário:
   ```javascript
   const connection = mysql.createConnection({
     host: "[IP-DA-MAQUINA-A]", // ou 'localhost' se MySQL local
     user: "tcc_user",
     password: "512200Balatro@",
     database: "tcc_project",
   });
   ```
4. Inicie o servidor: `node index.js`

**Passos para o Cliente (Máquina B)**:

1. Atualize `lib/core/constants/constants.dart`:
   ```dart
   const String baseUrl = 'http://[IP-DA-MAQUINA-A]:3000';
   ```
2. Execute o app Flutter normalmente

### 4. Acesso via Rede Wi-Fi (Dispositivos Móveis)

**Cenário**: Testando em dispositivo físico Android/iOS conectado à mesma rede Wi-Fi.

**Configuração no Flutter**:

```dart
// lib/core/constants/constants.dart
const String baseUrl = 'http://[IP-DO-SERVIDOR]:3000';
```

**Configuração no Backend**:

```javascript
// backend/index.js
app.listen(3000, "0.0.0.0", () => {
  console.log("Servidor: http://[IP-DA-MAQUINA]:3000");
});
```

**Passos Adicionais**:

1. Certifique-se de que ambos dispositivos estão na mesma rede Wi-Fi
2. Desative firewall temporariamente ou configure regras para porta 3000
3. Para iOS: Pode ser necessário certificado HTTPS em produção

## Configuração Dinâmica de Ambiente

Para facilitar mudanças entre ambientes, implemente configuração dinâmica:

```dart
// lib/core/constants/constants.dart
import 'package:flutter/foundation.dart';

class Config {
  static const String localUrl = 'http://localhost:3000';
  static const String emulatorUrl = 'http://10.0.2.2:3000';
  static const String networkUrl = 'http://192.168.3.8:3000'; // Altere conforme necessário

  static String get baseUrl {
    // Lógica para detectar ambiente
    if (kIsWeb) return localUrl;
    // Adicione lógica para detectar se está no emulador
    return networkUrl; // Default para rede
  }
}

const String baseUrl = Config.baseUrl;
```

## Script de Configuração Automática

Crie um script para facilitar a configuração:

```bash
#!/bin/bash
# setup_server.sh

echo "Descobrindo IP da máquina..."
IP=$(hostname -I | awk '{print $1}')
echo "IP detectado: $IP"

echo "Atualizando configuração do Flutter..."
sed -i "s|http://.*:3000|http://$IP:3000|g" lib/core/constants/constants.dart

echo "Atualizando configuração do backend..."
sed -i "s|http://.*:3000|http://$IP:3000|g" backend/index.js

echo "Configuração concluída!"
echo "Servidor acessível em: http://$IP:3000"
```

## Verificação de Conectividade

### Teste Básico do Servidor

```bash
curl http://[IP-DO-SERVIDOR]:3000/ping
# Deve retornar: {"message": "pong"}
```

### Teste de Login

```bash
curl -X POST http://[IP-DO-SERVIDOR]:3000/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"teste@teste.com","password":"123456"}'
```

### Teste de Registro

```bash
curl -X POST http://[IP-DO-SERVIDOR]:3000/api/users/register \
  -H "Content-Type: application/json" \
  -d '{"email":"novo@teste.com","password":"123456","name":"Novo Usuário"}'
```

## Troubleshooting

### Problema: "Connection refused"

**Possíveis causas**:

- Servidor não está rodando
- Porta bloqueada pelo firewall
- IP incorreto

**Soluções**:

1. Verifique se o servidor está executando: `netstat -tlnp | grep 3000`
2. Teste conectividade local: `curl http://localhost:3000/ping`
3. Verifique firewall: `sudo ufw allow 3000` (Linux) ou Firewall do Windows

### Problema: "Database connection failed"

**Possíveis causas**:

- MySQL não está rodando
- Credenciais incorretas
- MySQL não aceita conexões remotas

**Soluções**:

1. Verifique status do MySQL: `sudo systemctl status mysql`
2. Teste conexão local: `mysql -u tcc_user -p tcc_project`
3. Para conexões remotas, execute os comandos SQL de concessão acima

### Problema: App não conecta no emulador

**Solução**: Use `10.0.2.2` ao invés do IP real da máquina host

### Problema: Conexão lenta ou instável

**Possíveis causas**:

- Rede Wi-Fi congestionada
- Firewall interferindo
- Servidor sobrecarregado

**Soluções**:

1. Teste em rede cabeada se possível
2. Adicione timeout nas requisições HTTP
3. Implemente retry logic

## Notas de Segurança

### Desenvolvimento

- Nunca commite credenciais reais no código
- Use variáveis de ambiente para senhas
- Limite acesso ao banco apenas ao necessário

### Produção

- Use HTTPS ao invés de HTTP
- Implemente autenticação adequada
- Configure firewall restritivo
- Use VPN para acesso remoto seguro

## Checklist de Configuração

- [ ] IP do servidor identificado
- [ ] Flutter configurado com URL correta
- [ ] Backend ouvindo na interface correta (0.0.0.0)
- [ ] MySQL aceitando conexões remotas
- [ ] Firewall configurado para porta 3000
- [ ] Testes de conectividade passando
- [ ] App Flutter conectando com sucesso

## Suporte

Para problemas específicos:

1. Verifique os logs do servidor Node.js
2. Teste conectividade com curl
3. Verifique configuração de rede
4. Consulte a documentação de conectividade existente

---

**Última atualização**: $(date)
**Versão do documento**: 1.0
