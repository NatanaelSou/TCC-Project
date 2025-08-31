-- Arquivo de Migrações para Evolução do Banco de Dados
-- Este arquivo contém exemplos de alterações futuras no esquema

-- =====================================================
-- MIGRAÇÃO 001: Adicionar campo de localização aos usuários
-- =====================================================
-- Data: Futura implementação
-- Motivo: Permitir localização geográfica dos usuários

-- ALTER TABLE users ADD COLUMN country VARCHAR(100);
-- ALTER TABLE users ADD COLUMN state VARCHAR(100);
-- ALTER TABLE users ADD COLUMN city VARCHAR(100);
-- ALTER TABLE users ADD COLUMN timezone VARCHAR(50);

-- =====================================================
-- MIGRAÇÃO 002: Sistema de notificações push
-- =====================================================
-- Data: Futura implementação
-- Motivo: Melhorar engajamento com notificações push

-- ALTER TABLE users ADD COLUMN push_token TEXT;
-- ALTER TABLE users ADD COLUMN notification_preferences JSONB DEFAULT '{"email": true, "push": true, "sms": false}';

-- =====================================================
-- MIGRAÇÃO 003: Sistema de comentários aninhados
-- =====================================================
-- Data: Futura implementação
-- Motivo: Melhorar interatividade dos comentários

-- ALTER TABLE comments ADD COLUMN reply_count INTEGER DEFAULT 0;
-- ALTER TABLE comments ADD COLUMN depth INTEGER DEFAULT 0;
-- CREATE INDEX idx_comments_parent_id ON comments(parent_comment_id) WHERE parent_comment_id IS NOT NULL;

-- =====================================================
-- MIGRAÇÃO 004: Analytics e métricas de conteúdo
-- =====================================================
-- Data: Futura implementação
-- Motivo: Melhorar análise de performance do conteúdo

-- ALTER TABLE content ADD COLUMN avg_watch_time INTEGER; -- em segundos
-- ALTER TABLE content ADD COLUMN completion_rate DECIMAL(5,2); -- percentual
-- ALTER TABLE content ADD COLUMN unique_viewers INTEGER DEFAULT 0;

-- =====================================================
-- MIGRAÇÃO 005: Sistema de moderação de conteúdo
-- =====================================================
-- Data: Futura implementação
-- Motivo: Implementar moderação de conteúdo

-- CREATE TABLE content_reports (
--     id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
--     content_id UUID REFERENCES content(id) ON DELETE CASCADE,
--     reporter_id UUID REFERENCES users(id) ON DELETE CASCADE,
--     report_type VARCHAR(50) NOT NULL, -- spam, harassment, copyright, etc.
--     description TEXT,
--     status VARCHAR(20) DEFAULT 'pending', -- pending, reviewed, resolved
--     reviewed_by UUID REFERENCES users(id),
--     reviewed_at TIMESTAMP WITH TIME ZONE,
--     created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
-- );

-- ALTER TABLE content ADD COLUMN moderation_status VARCHAR(20) DEFAULT 'approved';
-- ALTER TABLE comments ADD COLUMN moderation_status VARCHAR(20) DEFAULT 'approved';

-- =====================================================
-- MIGRAÇÃO 006: Sistema de lives/streaming
-- =====================================================
-- Data: Futura implementação
-- Motivo: Adicionar funcionalidade de streaming ao vivo

-- CREATE TABLE live_streams (
--     id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
--     creator_id UUID REFERENCES creators(id) ON DELETE CASCADE,
--     title VARCHAR(255) NOT NULL,
--     description TEXT,
--     stream_key VARCHAR(255) UNIQUE NOT NULL,
--     is_live BOOLEAN DEFAULT FALSE,
--     started_at TIMESTAMP WITH TIME ZONE,
--     ended_at TIMESTAMP WITH TIME ZONE,
--     viewer_count INTEGER DEFAULT 0,
--     peak_viewers INTEGER DEFAULT 0,
--     category_id UUID REFERENCES categories(id),
--     created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
-- );

-- ALTER TABLE creators ADD COLUMN is_streaming BOOLEAN DEFAULT FALSE;

-- =====================================================
-- MIGRAÇÃO 007: Sistema de doações/tips
-- =====================================================
-- Data: Futura implementação
-- Motivo: Permitir doações aos criadores

-- CREATE TABLE donations (
--     id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
--     donor_id UUID REFERENCES users(id) ON DELETE CASCADE,
--     creator_id UUID REFERENCES creators(id) ON DELETE CASCADE,
--     amount DECIMAL(10,2) NOT NULL,
--     currency VARCHAR(3) DEFAULT 'BRL',
--     message TEXT,
--     is_anonymous BOOLEAN DEFAULT FALSE,
--     payment_id VARCHAR(255),
--     created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
-- );

-- ALTER TABLE creators ADD COLUMN total_donations DECIMAL(15,2) DEFAULT 0;

-- =====================================================
-- MIGRAÇÃO 008: Sistema de badges/conquistas
-- =====================================================
-- Data: Futura implementação
-- Motivo: Gamificação da plataforma

-- CREATE TABLE badges (
--     id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
--     name VARCHAR(100) NOT NULL,
--     description TEXT,
--     icon_url TEXT,
--     badge_type VARCHAR(50), -- achievement, milestone, special
--     criteria JSONB, -- condições para ganhar o badge
--     created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
-- );

-- CREATE TABLE user_badges (
--     id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
--     user_id UUID REFERENCES users(id) ON DELETE CASCADE,
--     badge_id UUID REFERENCES badges(id) ON DELETE CASCADE,
--     earned_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
--     UNIQUE(user_id, badge_id)
-- );

-- =====================================================
-- MIGRAÇÃO 009: Otimização de performance
-- =====================================================
-- Data: Futura implementação
-- Motivo: Melhorar performance com índices adicionais

-- CREATE INDEX CONCURRENTLY idx_content_view_count ON content(view_count DESC);
-- CREATE INDEX CONCURRENTLY idx_content_created_at_month ON content(EXTRACT(MONTH FROM created_at), EXTRACT(YEAR FROM created_at));
-- CREATE INDEX CONCURRENTLY idx_users_created_at_year ON users(EXTRACT(YEAR FROM created_at));
-- CREATE INDEX CONCURRENTLY idx_comments_created_at_content ON comments(content_id, created_at DESC);

-- =====================================================
-- MIGRAÇÃO 010: Backup e auditoria
-- =====================================================
-- Data: Futura implementação
-- Motivo: Sistema de auditoria para compliance

-- CREATE TABLE audit_log (
--     id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
--     table_name VARCHAR(50) NOT NULL,
--     record_id UUID NOT NULL,
--     action VARCHAR(10) NOT NULL, -- INSERT, UPDATE, DELETE
--     old_values JSONB,
--     new_values JSONB,
--     user_id UUID REFERENCES users(id),
--     ip_address INET,
--     user_agent TEXT,
--     created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
-- );

-- =====================================================
-- INSTRUÇÕES PARA APLICAR MIGRAÇÕES
-- =====================================================
--
-- 1. Sempre faça backup do banco antes de aplicar migrações
-- 2. Teste as migrações em ambiente de desenvolvimento primeiro
-- 3. Aplique as migrações em ordem sequencial
-- 4. Documente cada migração com data e motivo
-- 5. Considere o impacto em dados existentes
--
-- Comando para aplicar uma migração:
-- psql -U username -d database_name -f migrations.sql
--
-- Ou executar individualmente cada seção comentada acima
