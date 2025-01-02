CREATE DATABASE node_crud_db;
\c node_crud;

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100)
);

INSERT INTO users (name, email) VALUES
('Ethan Hunt', 'ethan.hunt@example.com'),
('Tom Cruise', 'tom.cruise@example.com');

