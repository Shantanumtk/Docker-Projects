CREATE TABLE IF NOT EXISTS employees (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    position VARCHAR(50),
    salary DECIMAL(10, 2)
);

INSERT INTO employees (name, position, salary)
VALUES ('John Doe', 'Manager', 75000.00),
       ('Jane Smith', 'Developer', 60000.00);
