-- MariaDB initialization script for NixVM development

-- Create a sample database and table
CREATE DATABASE IF NOT EXISTS nixvm_sample;
USE nixvm_sample;

-- Create a sample table
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Insert some sample data
INSERT INTO users (username, email, password_hash) VALUES
('admin', 'admin@nixvm.local', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'), -- password
('user', 'user@nixvm.local', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi');  -- password

-- Create a simple posts table
CREATE TABLE IF NOT EXISTS posts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    content TEXT,
    published BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Insert sample posts
INSERT INTO posts (user_id, title, content, published) VALUES
(1, 'Welcome to NixVM', 'This is your first post in the NixVM PHP development environment!', TRUE),
(1, 'Development Setup', 'You now have PHP 8.3, MariaDB, and Caddy running in containers.', TRUE);

-- Grant permissions to the nixvm_user
GRANT ALL PRIVILEGES ON nixvm_dev.* TO 'nixvm_user'@'%';
GRANT ALL PRIVILEGES ON nixvm_sample.* TO 'nixvm_user'@'%';
FLUSH PRIVILEGES;