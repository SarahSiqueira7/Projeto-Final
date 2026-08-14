-- Criar banco de dados
CREATE DATABASE IF NOT EXISTS sistema_controle_pedidos;

-- Conectar ao banco de dados
USE sistema_controle_pedidos;

-- Tabela de Categorias
CREATE TABLE categorias (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL UNIQUE,
    descricao TEXT,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de Produtos
CREATE TABLE produtos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    descricao TEXT,
    preco DECIMAL(10, 2) NOT NULL,
    quantidade_estoque INTEGER NOT NULL DEFAULT 0,
    categoria_id INTEGER NOT NULL,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (categoria_id) REFERENCES categorias(id)
);

-- Tabela de Clientes
CREATE TABLE clientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    telefone VARCHAR(20),
    endereco TEXT,
    cidade VARCHAR(100),
    estado VARCHAR(2),
    cep VARCHAR(10),
    cpf_cnpj VARCHAR(20) UNIQUE,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ativo BOOLEAN DEFAULT TRUE
);

-- Tabela de Pedidos (CORRIGIDO)
CREATE TABLE pedidos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INTEGER NOT NULL,
    data_pedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_entrega TIMESTAMP NULL,
    status VARCHAR(50) DEFAULT 'Pendente',
    valor_total DECIMAL(10, 2) DEFAULT 0,
    observacoes TEXT,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

-- Trigger para calcular data_entrega automaticamente
DELIMITER $$

CREATE TRIGGER trg_set_data_entrega
BEFORE INSERT ON pedidos
FOR EACH ROW
BEGIN
  IF NEW.data_entrega IS NULL THEN
    SET NEW.data_entrega = DATE_ADD(NEW.data_pedido, INTERVAL 5 DAY);
  END IF;
END$$

DELIMITER ;

-- Tabela de Itens do Pedido
CREATE TABLE itens_pedido (
    id INT AUTO_INCREMENT PRIMARY KEY,
    pedido_id INTEGER NOT NULL,
    produto_id INTEGER NOT NULL,
    quantidade INTEGER NOT NULL,
    preco_unitario DECIMAL(10, 2) NOT NULL,
    subtotal DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (pedido_id) REFERENCES pedidos(id) ON DELETE CASCADE,
    FOREIGN KEY (produto_id) REFERENCES produtos(id)
);

-- Tabela de Controle de Estoque
CREATE TABLE controle_estoque (
    id INT AUTO_INCREMENT PRIMARY KEY,
    produto_id INTEGER NOT NULL,
    quantidade_anterior INTEGER,
    quantidade_nova INTEGER,
    tipo_movimento VARCHAR(50),
    data_movimento TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    observacoes TEXT,
    FOREIGN KEY (produto_id) REFERENCES produtos(id)
);

-- Criar índices para melhor performance
CREATE INDEX idx_produtos_categoria ON produtos(categoria_id);
CREATE INDEX idx_pedidos_cliente ON pedidos(cliente_id);
CREATE INDEX idx_itens_pedido_pedido ON itens_pedido(pedido_id);
CREATE INDEX idx_itens_pedido_produto ON itens_pedido(produto_id);
CREATE INDEX idx_estoque_produto ON controle_estoque(produto_id);

-- Inserir dados de exemplo
INSERT INTO categorias (nome, descricao) VALUES
('Eletrônicos', 'Produtos eletrônicos diversos'),
('Roupas', 'Vestuário em geral'),
('Alimentos', 'Produtos alimentícios');

INSERT INTO produtos (nome, descricao, preco, quantidade_estoque, categoria_id) VALUES
('Notebook Dell', 'Notebook Intel Core i5', 2500.00, 10, 1),
('Smartphone Samsung', 'Smartphone Android 128GB', 1200.00, 15, 1),
('Camiseta Básica', 'Camiseta 100% algodão', 49.90, 50, 2),
('Calça Jeans', 'Calça jeans azul', 89.90, 30, 2),
('Arroz 5kg', 'Arroz integral 5kg', 25.00, 100, 3);

INSERT INTO clientes (nome, email, telefone, endereco, cidade, estado, cep) VALUES
('João Silva', 'joao@email.com', '11999999999', 'Rua A, 123', 'São Paulo', 'SP', '01234-567'),
('Maria Santos', 'maria@email.com', '21988888888', 'Avenida B, 456', 'Rio de Janeiro', 'RJ', '20000-000'),
('Pedro Costa', 'pedro@email.com', '31977777777', 'Rua C, 789', 'Belo Horizonte', 'MG', '30100-000');

-- ========================================
-- INSERIR PEDIDOS (DA FORMA CORRETA)
-- ========================================

-- Pedido 1: João Silva - Notebook + Camiseta
INSERT INTO pedidos (cliente_id, status, valor_total, observacoes) VALUES
(1, 'Pendente', 2549.90, 'Pedido urgente - cliente premium');

-- Pedido 2: Maria Santos - Smartphone + Calça
INSERT INTO pedidos (cliente_id, data_pedido, status, valor_total, observacoes) VALUES
(2, DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 2 DAY), 'Processando', 1249.80, 'Aguardando confirmação de pagamento');

-- Pedido 3: Pedro Costa - Camisetas + Calça
INSERT INTO pedidos (cliente_id, data_pedido, status, valor_total, observacoes) VALUES
(3, DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 5 DAY), 'Entregue', 139.80, 'Entregue com sucesso');

-- Pedido 4: João Silva - Arroz
INSERT INTO pedidos (cliente_id, data_pedido, status, valor_total, observacoes) VALUES
(1, DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 1 DAY), 'Enviado', 25.00, 'Pedido em trânsito');

-- ========================================
-- INSERIR ITENS DOS PEDIDOS (DETALHES)
-- ========================================

-- Itens do Pedido 1 (João Silva)
INSERT INTO itens_pedido (pedido_id, produto_id, quantidade, preco_unitario, subtotal) VALUES
(1, 1, 1, 2500.00, 2500.00),
(1, 3, 1, 49.90, 49.90);

-- Itens do Pedido 2 (Maria Santos)
INSERT INTO itens_pedido (pedido_id, produto_id, quantidade, preco_unitario, subtotal) VALUES
(2, 2, 1, 1200.00, 1200.00),
(2, 4, 1, 49.80, 49.80);

-- Itens do Pedido 3 (Pedro Costa)
INSERT INTO itens_pedido (pedido_id, produto_id, quantidade, preco_unitario, subtotal) VALUES
(3, 3, 2, 49.90, 99.80),
(3, 4, 1, 40.00, 40.00);

-- Itens do Pedido 4 (João Silva)
INSERT INTO itens_pedido (pedido_id, produto_id, quantidade, preco_unitario, subtotal) VALUES
(4, 5, 1, 25.00, 25.00);
