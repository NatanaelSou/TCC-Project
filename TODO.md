# Migração para MySQL Workbench - TODO List

## ✅ Etapa 1: Converter Schema PostgreSQL para MySQL
- [x] Criar novo arquivo database/schema-mysql.sql com sintaxe MySQL
- [x] Substituir UUID por VARCHAR(36) ou BINARY(16)
- [x] Remover extensões PostgreSQL (uuid-ossp, pgcrypto)
- [x] Converter tipos de dados PostgreSQL para MySQL
- [x] Ajustar triggers e funções para sintaxe MySQL
- [x] Atualizar índices para sintaxe MySQL

## ✅ Etapa 2: Atualizar Configuração do Banco de Dados
- [x] Modificar backend/config/database.js para usar MySQL
- [x] Substituir 'pg' por 'mysql2' como driver
- [x] Atualizar parâmetros de conexão para MySQL
- [x] Ajustar funções utilitárias para sintaxe MySQL

## ✅ Etapa 3: Atualizar Dependências
- [x] Modificar backend/package.json
- [x] Remover 'pg' das dependências
- [x] Adicionar 'mysql2' como dependência
- [x] Atualizar scripts npm se necessário

## ✅ Etapa 4: Converter Scripts de Setup
- [x] Atualizar backend/scripts/setupDatabase.js
- [x] Converter queries PostgreSQL para MySQL
- [x] Ajustar tratamento de erros para MySQL
- [x] Atualizar backend/scripts/completeDatabaseTests.js

## ✅ Etapa 5: Converter Dados Iniciais
- [x] Criar database/seed-mysql.sql
- [x] Converter funções uuid_generate_v4() para UUID()
- [x] Ajustar sintaxe de arrays PostgreSQL para MySQL
- [x] Atualizar queries de limpeza e inserção

## ✅ Etapa 6: Testar Migração
- [x] Executar setup do banco MySQL
- [x] Testar conexão com o banco
- [x] Verificar se todas as tabelas foram criadas
- [x] Executar testes de API
- [x] Validar funcionamento completo

## ✅ Etapa 7: Documentação e Limpeza
- [x] Atualizar README-SETUP.md com instruções MySQL
- [x] Remover arquivos PostgreSQL obsoletos
- [x] Criar backup dos arquivos originais
- [x] Documentar mudanças realizadas
