# 🧪 Guia de Testes - Plataforma de Conteúdo

Este documento descreve a suíte completa de testes implementada para validar o funcionamento da plataforma de serviço de conteúdo.

## 📋 Visão Geral dos Testes

A suíte de testes é composta por três categorias principais:

1. **🗄️ Testes de Banco de Dados** - Validação da estrutura, dados e integridade
2. **🌐 Testes da API** - Validação dos endpoints e funcionalidades
3. **⚡ Testes de Carga** - Validação de performance e escalabilidade

## 🚀 Como Executar os Testes

### Pré-requisitos

1. **PostgreSQL** rodando e configurado
2. **Node.js** >= 16.0.0 instalado
3. **Dependências** instaladas: `npm install`
4. **Banco de dados** configurado e populado
5. **Servidor backend** rodando (porta 3001)

### Comandos Disponíveis

```bash
# Executar todos os testes
npm run test-all

# Executar apenas testes de banco de dados
npm run test-db-only

# Executar apenas testes da API
npm run test-api-only

# Executar apenas testes de carga
npm run test-load-only

# Executar testes individuais
npm run test-complete    # Testes completos de BD
npm run test-load        # Testes de carga
npm run test-api         # Testes básicos da API
```

## 📊 Detalhes dos Testes

### 1. Testes de Banco de Dados (`completeDatabaseTests.js`)

Valida a integridade completa do banco de dados PostgreSQL:

#### ✅ Testes Executados:
- **Conexão com BD** - Verifica se consegue conectar ao PostgreSQL
- **Estrutura das Tabelas** - Confirma que todas as tabelas necessárias existem
- **Dados Iniciais** - Valida se os dados de seed foram inseridos corretamente
- **Integridade Referencial** - Verifica foreign keys e relacionamentos
- **Constraints e Índices** - Valida primary keys, unique constraints
- **Saúde da API** - Testa endpoint básico de health check
- **Endpoints de Usuários** - CRUD operations para usuários
- **Endpoints de Conteúdo** - Operações de conteúdo e busca
- **Endpoints de Criadores** - Funcionalidades de canais
- **Performance de Queries** - Tempo de resposta de queries complexas
- **Casos de Erro** - Tratamento adequado de erros 404, 400, etc.

#### 📈 Métricas Coletadas:
- Tempo de resposta médio
- Taxa de sucesso das operações
- Número de registros por tabela
- Status de constraints

### 2. Testes da API (`testAPI.js`)

Testes funcionais dos endpoints REST:

#### ✅ Funcionalidades Testadas:
- Registro de usuário
- Login e autenticação JWT
- Perfil do usuário
- Criação de canal de criador
- Upload e gerenciamento de conteúdo
- Sistema de inscrições
- Busca e filtros de conteúdo
- Listagem de criadores populares

### 3. Testes de Carga (`loadTests.js`)

Avalia a performance sob carga:

#### ✅ Cenários de Teste:
- **Carga de Leitura** - Múltiplas requisições GET simultâneas
- **Carga Mista** - Combinação de diferentes tipos de operação
- **Carga Contínua** - Teste prolongado de stress
- **Dados Grandes** - Manipulação de grandes volumes de dados

#### 📊 Métricas de Performance:
- Tempo de resposta médio, mínimo e máximo
- Percentis P95 e P99
- Taxa de erro aceitável
- Throughput (requisições por segundo)

## 📄 Relatórios de Teste

### Arquivo de Relatório

Após execução, um relatório detalhado é gerado em `test-report.json`:

```json
{
  "timestamp": "2024-01-15T10:30:00.000Z",
  "summary": {
    "totalTests": 3,
    "passedTests": 3,
    "failedTests": 0,
    "successRate": 100.0
  },
  "database": {
    "success": true,
    "timestamp": "2024-01-15T10:30:05.000Z"
  },
  "api": {
    "success": true,
    "timestamp": "2024-01-15T10:30:10.000Z"
  },
  "load": {
    "success": true,
    "timestamp": "2024-01-15T10:30:15.000Z"
  },
  "recommendations": [...]
}
```

### Saída no Console

Exemplo de saída bem-sucedida:

```
🚀 INICIANDO SUITE COMPLETA DE TESTES
================================================================================
Testando: Banco de Dados, API e Performance
================================================================================

🗄️  EXECUTANDO TESTES DE BANCO DE DADOS
==================================================

🔗 Testando conexão com banco de dados...
✅ PASSOU Conexão com Banco de Dados: Conexão estabelecida com sucesso

📋 Testando estrutura das tabelas...
✅ PASSOU Estrutura da Tabela: categories
✅ PASSOU Estrutura da Tabela: users
...

📊 Testando dados iniciais...
✅ PASSOU Dados Iniciais: Categorias
✅ PASSOU Dados Iniciais: Usuários
...

================================================================================
📊 RELATÓRIO CONSOLIDADO DE TESTES
================================================================================

🕒 Timestamp: 2024-01-15T10:30:00.000Z
📈 Total de Testes: 3
✅ Aprovados: 3
❌ Reprovados: 0
📊 Taxa de Sucesso: 100.00%

📋 Status dos Módulos:
   🗄️  Banco de Dados: ✅ OK
   🌐 API: ✅ OK
   ⚡ Carga/Performance: ✅ OK

🎉 TODOS OS TESTES PASSARAM!
✅ Sistema pronto para produção.
================================================================================
```

## 🔧 Configuração dos Testes

### Arquivo `test-config.json`

Personalize o comportamento dos testes através do arquivo `backend/test-config.json`:

```json
{
  "database": {
    "host": "localhost",
    "port": 5432,
    "database": "content_service",
    "user": "postgres",
    "password": ""
  },
  "api": {
    "baseUrl": "http://localhost:3001/api",
    "timeout": 10000
  },
  "tests": {
    "enableDatabaseTests": true,
    "enableAPITests": true,
    "enableLoadTests": true,
    "concurrentRequests": 50,
    "testDuration": 30000
  },
  "performance": {
    "maxResponseTime": 1000,
    "minRequestsPerSecond": 10,
    "acceptableErrorRate": 0.05
  }
}
```

## 🚨 Resolução de Problemas

### Problemas Comuns e Soluções

#### ❌ "Conexão com Banco de Dados" falha
- Verifique se PostgreSQL está rodando
- Confirme credenciais no arquivo de configuração
- Teste conexão manual: `psql -h localhost -U postgres -d content_service`

#### ❌ "Estrutura das Tabelas" falha
- Execute setup do banco: `npm run setup-db`
- Verifique se migrations foram aplicadas
- Confirme schema no arquivo `database/schema.sql`

#### ❌ "Dados Iniciais" falha
- Execute seed do banco: `npm run seed-db`
- Verifique se arquivo `database/seed.sql` existe
- Confirme que tabelas foram criadas antes do seed

#### ❌ Testes de API falham
- Verifique se servidor está rodando: `npm run dev`
- Confirme porta 3001 não está ocupada
- Teste endpoint manual: `curl http://localhost:3001/api/health`

#### ❌ Performance ruim nos testes de carga
- Aumente recursos do PostgreSQL (memória, conexões)
- Otimize queries com índices
- Considere cache (Redis) para produção
- Configure pool de conexões adequadamente

## 📈 Interpretação dos Resultados

### Níveis de Performance

- **🟢 Excelente**: < 500ms tempo médio de resposta
- **🟡 Bom**: 500-1000ms tempo médio de resposta
- **🟠 Aceitável**: 1000-2000ms tempo médio de resposta
- **🔴 Ruim**: > 2000ms tempo médio de resposta

### Taxas de Sucesso Recomendadas

- **Produção**: > 99.9% disponibilidade
- **Testes**: > 95% sucesso nas operações
- **Carga**: > 90% sucesso sob stress

## 🔄 Integração com CI/CD

Para integração com pipelines de CI/CD:

```yaml
# Exemplo GitHub Actions
- name: Run Tests
  run: |
    cd backend
    npm install
    npm run test-all
```

## 📞 Suporte

Para dúvidas sobre os testes ou problemas encontrados:

1. Verifique os logs detalhados no console
2. Consulte o relatório em `test-report.json`
3. Revise as configurações em `test-config.json`
4. Verifique pré-requisitos no `README-SETUP.md`

---

**Nota**: Os testes foram projetados para serem executados em ambiente de desenvolvimento/testes. Para produção, considere ajustes nos parâmetros de carga e configuração de timeouts.
