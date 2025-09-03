-- Esquema do banco de dados para o Serviço de Conteúdo Premium

CREATE DATABASE IF NOT EXISTS tcc_project;

USE tcc_project;

-- Tabela de usuários
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de assinaturas
CREATE TABLE subscriptions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    creator_id INT,
    tier_id INT,
    status ENUM('active', 'cancelled', 'paused') DEFAULT 'active',
    start_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    end_date TIMESTAMP NULL,
    auto_renew BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (creator_id) REFERENCES users(id),
    FOREIGN KEY (tier_id) REFERENCES tiers(id)
);

-- Tabela de tiers de assinatura
CREATE TABLE tiers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    creator_id INT,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    benefits JSON,
    max_subscribers INT DEFAULT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (creator_id) REFERENCES users(id)
);

-- Tabela de pagamentos
CREATE TABLE payments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    subscription_id INT,
    amount DECIMAL(10,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'BRL',
    gateway ENUM('mercadopago', 'paypal') NOT NULL,
    transaction_id VARCHAR(255) UNIQUE,
    status ENUM('pending', 'completed', 'failed', 'refunded') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (subscription_id) REFERENCES subscriptions(id)
);

-- Tabela de conteúdo expandida
CREATE TABLE content (
    id INT AUTO_INCREMENT PRIMARY KEY,
    creator_id INT,
    tier_id INT DEFAULT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    type ENUM('text', 'image', 'video', 'audio', 'live') DEFAULT 'text',
    file_url VARCHAR(500),
    is_premium BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (creator_id) REFERENCES users(id),
    FOREIGN KEY (tier_id) REFERENCES tiers(id)
);

-- Tabela de posts (para conteúdo textual)
CREATE TABLE posts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    content_id INT,
    text_content TEXT,
    media_urls JSON,
    tags JSON,
    visibility ENUM('public', 'subscribers', 'tier') DEFAULT 'subscribers',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (content_id) REFERENCES content(id)
);

-- Tabela de comentários
CREATE TABLE comments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT,
    user_id INT,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES posts(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Tabela de notificações
CREATE TABLE notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    type ENUM('new_content', 'subscription', 'payment', 'comment') NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Tabela de perfil do criador
CREATE TABLE creator_profiles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNIQUE,
    banner_image VARCHAR(500),
    description TEXT,
    website VARCHAR(255),
    social_links JSON,
    total_earnings DECIMAL(15,2) DEFAULT 0,
    subscriber_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Tabela de transmissões ao vivo
CREATE TABLE live_streams (
    id INT AUTO_INCREMENT PRIMARY KEY,
    creator_id INT,
    title VARCHAR(255) NOT NULL,
    stream_url VARCHAR(500),
    is_live BOOLEAN DEFAULT FALSE,
    viewer_count INT DEFAULT 0,
    started_at TIMESTAMP NULL,
    ended_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (creator_id) REFERENCES users(id)
);
