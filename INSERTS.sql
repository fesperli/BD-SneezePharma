/*
Fluxo feliz: 
-> Criacao das tabelas auxiliares
-> Tabela Clientes, Telefone Clientes e Clientes Bloqueados
-> Tabela Fornecedor e Fornecedores Bloqueados
-> Principios ativos
-> Medicamentos
-> Producao e Itens Producao
-> Compra e Itens Compra
-> Venda e Itens Venda
*/
INSERT INTO SituacaoCliente (Situacao) 
VALUES ('Ativo'), ('Inativo');

INSERT INTO SituacaoFornecedor (Situacao)
VALUES ('Ativo'), ('Inativo');

INSERT INTO SituacaoMedicamento (Situacao)
VALUES ('Ativo'), ('Inativo');

INSERT INTO SituacaoPrincipioAtivo (Situacao)
VALUES ('Ativo'), ('Inativo');

INSERT INTO Categorias (Nome) 
VALUES ('Analgesico'), ('Antibiotico'), ('Anti-inflamatorio'), ('Vitamina');

INSERT INTO Clientes (CPF, Nome, Sobrenome, DataNascimento, DataCadastro, Situacao)
VALUES ('52689648873', 'Felipe', 'Sperli', '2005/07/07', GETDATE(), 1),
('54312390811', 'Pedro', 'Belarmino', '2003/10/20', GETDATE(), 1),
('34332167881', 'Juninho', 'Gemaplays', '2000/03/13', GETDATE(), 2);

INSERT INTO TelefonesClientes (idCliente, CodPais, CodArea, Numero)
VALUES (1, '55+', '16', '996384551'),
(2, '55+', '19', '997890231'),
(3, '55+', '21', '967756312');

INSERT INTO ClientesRestritos (idCliente)
VALUES (2);

INSERT INTO Fornecedores (CNPJ, RazaoSocial, Pais, DataAbertura, DataCadastro, Situacao)
VALUES ('21557896011', '5by5', 'Brasil', '2000/11/23', GETDATE(), 1),
('32445167765', 'Nestle', 'Brasil', '1987/08/19', GETDATE(), 2),
('25122645509', 'Cimed', 'Brasil', '1997/01/11', GETDATE(), 1); 

INSERT INTO FornecedoresBloqueados (idFornecedor)
VALUES (3);

INSERT INTO PrincipiosAtivos (Nome, DataCadastro, Situacao)
VALUES ('Loratadina', GETDATE(), 1),
('Omeprazol', GETDATE(), 1),
('Ibuprofeno', GETDATE(), 2);

INSERT INTO Medicamentos (CDB, Nome, Categoria, ValorVenda, DataCadastro, Situacao)
VALUES ('134567890112', 'Advil', 3, 16.50, GETDATE(), 1),
('9876789543122', 'Claritin', 2, 25, GETDATE(), 1),
('1221435678998', 'Victrix', 1, 9.99, GETDATE(), 2);

INSERT INTO Producoes (DataProducao, idMedicamento, Quantidade)
VALUES (GETDATE(), 1, 25);

INSERT INTO Ingredientes (idProducao, idPrincipio, Quantidade)
VALUES (1, 1, 10);

INSERT INTO Compras (DataCompra, idFornecedor)
VALUES (GETDATE(), 1);

INSERT INTO ItensCompras (idCompra, idPrincipio, Quantidade, ValorUnitario)
VALUES (1, 1, 100, 5.00);


INSERT INTO Vendas (DataVenda, idCliente) 
VALUES(GETDATE(), 1);

INSERT INTO ItensVendas (idVenda, idMedicamento, Quantidade)
VALUES(1, 1, 2);

--ativar cliente/fornecedor novamente
/*
UPDATE Clientes
SET Situacao = 1
WHERE idCliente = X; 

UPDATE Fornecedores
SET Situacao = 1
WHERE idFornecedor = X;
*/

--remover cliente/fornecedor do bloqueio 
/*
DELETE FROM ClientesRestritos
WHERE idCliente = X;

DELETE FROM FornecedoresBloqueados
WHERE idFornecedor = X;
*/
