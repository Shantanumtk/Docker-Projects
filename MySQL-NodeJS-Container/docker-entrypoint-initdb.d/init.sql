-- /docker-entrypoint-initdb.d/init.sql
CREATE DATABASE IF NOT EXISTS crud_db;
USE crud_db;

-- Create Users table
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    role ENUM('admin', 'user') DEFAULT 'user',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Insert sample data
INSERT INTO users (name, email, role) VALUES
    ('John Doe', 'john@example.com', 'admin'),
    ('Jane Smith', 'jane@example.com', 'user'),
    ('Bob Wilson', 'bob@example.com', 'user')
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    role = VALUES(role);

-- Create Products table
CREATE TABLE IF NOT EXISTS products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample products
INSERT INTO products (name, price) VALUES
    ('Product 1', 99.99),
    ('Product 2', 149.99),
    ('Product 3', 199.99)
ON DUPLICATE KEY UPDATE
    price = VALUES(price);

