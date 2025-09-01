-- Esquema do Banco de Dados para Plataforma de Serviço de Conteúdo
-- Versão MySQL - Migrado do PostgreSQL
-- Similar ao YouTube: usuários, criadores, conteúdo, inscrições, etc.

-- Configurações iniciais para MySQL
SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";

-- Criar banco de dados se não existir
CREATE DATABASE IF NOT EXISTS content_service CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE content_service;

-- Tabela de usuários (todos os usuários da plataforma)
CREATE TABLE IF NOT EXISTS users (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100),
    avatar_url TEXT,
    bio TEXT,
    is_verified BOOLEAN DEFAULT FALSE,
    is_creator BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de criadores (perfis específicos para criadores de conteúdo)
CREATE TABLE IF NOT EXISTS creators (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    user_id CHAR(36) NOT NULL,
    channel_name VARCHAR(100) NOT NULL,
    channel_description TEXT,
    channel_banner_url TEXT,
    subscriber_count INT DEFAULT 0,
    total_views BIGINT DEFAULT 0,
    custom_url VARCHAR(50) UNIQUE,
    is_monetized BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_creators_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de categorias de conteúdo
CREATE TABLE IF NOT EXISTS categories (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    icon_url TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de vídeos/conteúdo
CREATE TABLE IF NOT EXISTS content (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    creator_id CHAR(36) NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    video_url TEXT NOT NULL,
    thumbnail_url TEXT,
    duration INT, -- em segundos
    category_id CHAR(36),
    view_count BIGINT DEFAULT 0,
    like_count INT DEFAULT 0,
    dislike_count INT DEFAULT 0,
    is_published BOOLEAN DEFAULT TRUE,
    is_featured BOOLEAN DEFAULT FALSE,
    tags JSON, -- MySQL 5.7.8+ suporta JSON
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (creator_id) REFERENCES creators(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(id),
    INDEX idx_content_creator_id (creator_id),
    INDEX idx_content_category_id (category_id),
    INDEX idx_content_created_at (created_at DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de inscrições (subscribers)
CREATE TABLE IF NOT EXISTS subscriptions (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    subscriber_id CHAR(36) NOT NULL,
    creator_id CHAR(36) NOT NULL,
    subscribed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (subscriber_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (creator_id) REFERENCES creators(id) ON DELETE CASCADE,
    UNIQUE KEY unique_subscription (subscriber_id, creator_id),
    INDEX idx_subscriptions_subscriber_id (subscriber_id),
    INDEX idx_subscriptions_creator_id (creator_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de likes/dislikes nos vídeos
CREATE TABLE IF NOT EXISTS content_reactions (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    user_id CHAR(36) NOT NULL,
    content_id CHAR(36) NOT NULL,
    reaction_type ENUM('like', 'dislike') NOT NULL,
    reacted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (content_id) REFERENCES content(id) ON DELETE CASCADE,
    UNIQUE KEY unique_reaction (user_id, content_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de comentários
CREATE TABLE IF NOT EXISTS comments (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    user_id CHAR(36) NOT NULL,
    content_id CHAR(36) NOT NULL,
    parent_comment_id CHAR(36),
    comment_text TEXT NOT NULL,
    like_count INT DEFAULT 0,
    is_pinned BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (content_id) REFERENCES content(id) ON DELETE CASCADE,
    FOREIGN KEY (parent_comment_id) REFERENCES comments(id) ON DELETE CASCADE,
    INDEX idx_comments_content_id (content_id),
    INDEX idx_comments_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de playlists
CREATE TABLE IF NOT EXISTS playlists (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    creator_id CHAR(36) NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    is_public BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (creator_id) REFERENCES creators(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de itens da playlist
CREATE TABLE IF NOT EXISTS playlist_items (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    playlist_id CHAR(36) NOT NULL,
    content_id CHAR(36) NOT NULL,
    position INT NOT NULL,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (playlist_id) REFERENCES playlists(id) ON DELETE CASCADE,
    FOREIGN KEY (content_id) REFERENCES content(id) ON DELETE CASCADE,
    UNIQUE KEY unique_playlist_item (playlist_id, content_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de pagamentos (para monetização)
CREATE TABLE IF NOT EXISTS payments (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    user_id CHAR(36) NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'BRL',
    payment_type ENUM('subscription', 'donation', 'purchase') NOT NULL,
    status VARCHAR(20) DEFAULT 'pending',
    stripe_payment_id VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMP NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de notificações
CREATE TABLE IF NOT EXISTS notifications (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    user_id CHAR(36) NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT,
    notification_type VARCHAR(50),
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Índices adicionais para otimização de performance
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);

COMMIT;
