--TRIGGERS

--bloqueia a venda para clientes bloqueados
CREATE TRIGGER trg_BloquearVendaClienteInativoOuRestrito
ON Vendas
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (
        SELECT 1
        FROM INSERTED I
        INNER JOIN Clientes C ON I.idCliente = C.idCliente
        INNER JOIN SituacaoCliente SC ON C.Situacao = SC.id
        LEFT JOIN ClientesRestritos CR ON C.idCliente = CR.idCliente
        WHERE SC.Situacao = 'Inativo' OR CR.idCliente IS NOT NULL
    )
    BEGIN
        RAISERROR('Venda não permitida: cliente está inativo ou restrito.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
    INSERT INTO Vendas (DataVenda, idCliente)
    SELECT DataVenda, idCliente
    FROM INSERTED;
END;
GO

--bloqueia a compra para fornecedores bloqueados
CREATE TRIGGER trg_BloquearCompraFornecedorInativoOuBloqueado
ON Compras
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (
        SELECT 1
        FROM INSERTED I
        INNER JOIN Fornecedores F ON I.idFornecedor = F.idFornecedor
        INNER JOIN SituacaoFornecedor SF ON F.Situacao = SF.id
        LEFT JOIN FornecedoresBloqueados FB ON F.idFornecedor = FB.idFornecedor
        WHERE SF.Situacao = 'Inativo' OR FB.idFornecedor IS NOT NULL
    )
    BEGIN
        RAISERROR('Compra não permitida: fornecedor está inativo ou bloqueado.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
    INSERT INTO Compras (DataCompra, idFornecedor)
    SELECT DataCompra, idFornecedor
    FROM INSERTED;
END;
GO

--triggers bloqueando o delete
CREATE TRIGGER trg_BlockDelete_Clientes
ON Clientes
AFTER DELETE
AS
BEGIN
    ROLLBACK TRANSACTION;
    RAISERROR('DELETE não permitido na tabela Clientes.', 16, 1);
END;
GO

CREATE TRIGGER trg_BlockDelete_TelefonesClientes
ON TelefonesClientes
AFTER DELETE
AS
BEGIN
    ROLLBACK TRANSACTION;
    RAISERROR('DELETE não permitido na tabela TelefonesClientes.', 16, 1);
END;
GO

CREATE TRIGGER trg_BlockDelete_Vendas
ON Vendas
AFTER DELETE
AS
BEGIN
    ROLLBACK TRANSACTION;
    RAISERROR('DELETE não permitido na tabela Vendas.', 16, 1);
END;
GO

CREATE TRIGGER trg_BlockDelete_ItensVendas
ON ItensVendas
AFTER DELETE
AS
BEGIN
    ROLLBACK TRANSACTION;
    RAISERROR('DELETE não permitido na tabela ItensVendas.', 16, 1);
END;
GO

CREATE TRIGGER trg_BlockDelete_Medicamentos
ON Medicamentos
AFTER DELETE
AS
BEGIN
    ROLLBACK TRANSACTION;
    RAISERROR('DELETE não permitido na tabela Medicamentos.', 16, 1);
END;
GO

CREATE TRIGGER trg_BlockDelete_Producoes
ON Producoes
AFTER DELETE
AS
BEGIN
    ROLLBACK TRANSACTION;
    RAISERROR('DELETE não permitido na tabela Producoes.', 16, 1);
END;
GO

CREATE TRIGGER trg_BlockDelete_Ingredientes
ON Ingredientes
AFTER DELETE
AS
BEGIN
    ROLLBACK TRANSACTION;
    RAISERROR('DELETE não permitido na tabela Ingredientes.', 16, 1);
END;
GO

CREATE TRIGGER trg_BlockDelete_PrincipiosAtivos
ON PrincipiosAtivos
AFTER DELETE
AS
BEGIN
    ROLLBACK TRANSACTION;
    RAISERROR('DELETE não permitido na tabela PrincipiosAtivos.', 16, 1);
END;
GO

CREATE TRIGGER trg_BlockDelete_ItensCompras
ON ItensCompras
AFTER DELETE
AS
BEGIN
    ROLLBACK TRANSACTION;
    RAISERROR('DELETE não permitido na tabela ItensCompras.', 16, 1);
END;
GO

CREATE TRIGGER trg_BlockDelete_Compras
ON Compras
AFTER DELETE
AS
BEGIN
    ROLLBACK TRANSACTION;
    RAISERROR('DELETE não permitido na tabela Compras.', 16, 1);
END;
GO

CREATE TRIGGER trg_BlockDelete_Fornecedores
ON Fornecedores
AFTER DELETE
AS
BEGIN
    ROLLBACK TRANSACTION;
    RAISERROR('DELETE não permitido na tabela Fornecedores.', 16, 1);
END;
GO

CREATE TRIGGER trg_BlockDelete_Categorias
ON Categorias
AFTER DELETE
AS
BEGIN
    ROLLBACK TRANSACTION;
    RAISERROR('DELETE não permitido na tabela Categorias.', 16, 1);
END;
GO

CREATE TRIGGER trg_BlockDelete_SituacaoCliente
ON SituacaoCliente
AFTER DELETE
AS
BEGIN
    ROLLBACK TRANSACTION;
    RAISERROR('DELETE não permitido na tabela SituacaoCliente.', 16, 1);
END;
GO

CREATE TRIGGER trg_BlockDelete_SituacaoPrincipioAtivo
ON SituacaoPrincipioAtivo
AFTER DELETE
AS
BEGIN
    ROLLBACK TRANSACTION;
    RAISERROR('DELETE não permitido na tabela SituacaoPrincipioAtivo.', 16, 1);
END;
GO

CREATE TRIGGER trg_BlockDelete_SituacaoMedicamento
ON SituacaoMedicamento
AFTER DELETE
AS
BEGIN
    ROLLBACK TRANSACTION;
    RAISERROR('DELETE não permitido na tabela SituacaoMedicamento.', 16, 1);
END;
GO

CREATE TRIGGER trg_BlockDelete_SituacaoFornecedor
ON SituacaoFornecedor
AFTER DELETE
AS
BEGIN
    ROLLBACK TRANSACTION;
    RAISERROR('DELETE não permitido na tabela SituacaoFornecedor.', 16, 1);
END;
GO
--proibindo venda e compra de +3 itens

CREATE TRIGGER trg_BloqueioItemVenda_Medicamentos
ON ItensVendas
AFTER INSERT
AS
BEGIN
 IF EXISTS (
        SELECT i.idVenda
        FROM ItensVendas i
        GROUP BY i.idVenda
        HAVING COUNT(i.idMedicamento) > 3
    )
    BEGIN
        RAISERROR('Uma venda não pode ter mais que 3 itens.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

CREATE TRIGGER trg_BloqueioLimiteItensCompra_Principio
ON ItensCompras
AFTER INSERT
AS
BEGIN
    IF EXISTS (
        SELECT idCompra
        FROM ItensCompras
        GROUP BY idCompra
        HAVING COUNT(idPrincipio) > 3
    )
    BEGIN
        RAISERROR('Uma compra não pode ter mais de 3 itens.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

--procedure para compra
CREATE PROCEDURE sp_fazerCompra
    @DataCompra DATE,
    @idFornecedor INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @NovoIdCompra INT;

    INSERT INTO Compras (DataCompra, idFornecedor)
    VALUES (@DataCompra, @idFornecedor);

    SET @NovoIdCompra = SCOPE_IDENTITY();

    INSERT INTO ItensCompras (idCompra, idPrincipio, Quantidade, ValorUnitario)
    SELECT @NovoIdCompra, idPrincipio, Quantidade, ValorUnitario
    FROM #ItensCompra;

    SELECT @NovoIdCompra AS CompraCriada;
END;
GO

--procedure para venda 

CREATE PROCEDURE sp_RealizarVenda
    @DataVenda DATE,
    @idCliente INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @NovoIdVenda INT;

    INSERT INTO Vendas (DataVenda, idCliente)
    VALUES (@DataVenda, @idCliente);

    SET @NovoIdVenda = SCOPE_IDENTITY();

    INSERT INTO ItensVendas (idVenda, idMedicamento, Quantidade)
    SELECT @NovoIdVenda, idMedicamento, Quantidade
    FROM #ItensVenda;

    SELECT @NovoIdVenda AS VendaCriada;
END;
GO

