CREATE TABLE IF NOT EXISTS users (
	id INT AUTO_INCREMENT PRIMARY KEY,
	email VARCHAR(255) NOT NULL UNIQUE,
	password VARCHAR(255) NOT NULL,
	name VARCHAR(100)
);

INSERT INTO users (email, password, name) VALUES ('teste@teste.com', '123456', 'Usuário Teste')
	ON DUPLICATE KEY UPDATE email=email;
