CREATE TABLE IF NOT EXISTS calcoli (
    id INT AUTO_INCREMENT PRIMARY KEY,
    capitale_iniziale DECIMAL(12,2) NOT NULL,
    tasso DECIMAL(5,2) NOT NULL,
    anni INT NOT NULL,
    deposito_mensile DECIMAL(12,2) NOT NULL,
    risultato_finale DECIMAL(12,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);