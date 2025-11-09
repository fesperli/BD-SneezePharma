--lista de cliente com situacao
SELECT
    C.idCliente,
    C.CPF,
    C.Nome,
    C.Sobrenome,
    C.DataNascimento,
    C.DataCadastro,
    SC.Situacao AS SituacaoCliente
FROM Clientes C
INNER JOIN SituacaoCliente SC ON C.Situacao = SC.id;

--cliente inativo
SELECT
    C.idCliente,
    C.CPF,
    C.Nome,
    C.Sobrenome,
    C.DataNascimento,
    C.DataCadastro,
    SC.Situacao AS SituacaoCliente
FROM Clientes C
INNER JOIN SituacaoCliente SC ON C.Situacao = SC.id
WHERE SC.Situacao = 'Inativo';

--clientes restritos
SELECT
    CR.id,
    C.Nome + ' ' + C.Sobrenome AS Cliente,
    SC.Situacao
FROM ClientesRestritos CR
INNER JOIN Clientes C ON CR.idCliente = C.idCliente
INNER JOIN SituacaoCliente SC ON C.Situacao = SC.id;

-- fornecedores
SELECT
    F.idFornecedor,
    F.CNPJ,
    F.RazaoSocial,
    F.Pais,
    F.DataAbertura,
    F.DataCadastro,
    SF.Situacao AS SituacaoFornecedor
FROM Fornecedores F
INNER JOIN SituacaoFornecedor SF ON F.Situacao = SF.id;

--fornecedores inatuvos
SELECT
    F.idFornecedor,
    F.CNPJ,
    F.RazaoSocial,
    F.Pais,
    F.DataAbertura,
    F.DataCadastro,
    SF.Situacao AS SituacaoFornecedor
FROM Fornecedores F
INNER JOIN SituacaoFornecedor SF ON F.Situacao = SF.id
WHERE SF.Situacao = 'Inativo'; 

--fornecedores bloqueados
SELECT
    FB.id,
    F.RazaoSocial AS Fornecedor,
    SF.Situacao
FROM FornecedoresBloqueados FB
INNER JOIN Fornecedores F ON FB.idFornecedor = F.idFornecedor
INNER JOIN SituacaoFornecedor SF ON F.Situacao = SF.id;

--compras realizadas
SELECT
    C.idCompra,
    C.DataCompra,
    F.RazaoSocial AS Fornecedor
FROM Compras C
INNER JOIN Fornecedores F ON C.idFornecedor = F.idFornecedor;

--medicamentos com categoria e situacao
SELECT
    m.IdMedicamento,
    m.Nome AS Medicamento,
    c.Nome AS Categoria,
    s.Situacao
FROM Medicamentos m
JOIN Categorias c ON m.Categoria = c.id
JOIN SituacaoMedicamento s ON m.Situacao = s.id;

--produção
SELECT
    PR.idProducao,
    PR.DataProducao,
    M.Nome AS Medicamento,
    PR.Quantidade
FROM Producoes PR
INNER JOIN Medicamentos M ON PR.idMedicamento = M.idMedicamento;

--ingredientes da produção
SELECT
    I.idProducao,
    M.Nome AS Medicamento,
    PA.Nome AS PrincipioAtivo,
    I.Quantidade
FROM Ingredientes I
INNER JOIN Producoes P ON I.idProducao = P.idProducao
INNER JOIN Medicamentos M ON P.idMedicamento = M.idMedicamento
INNER JOIN PrincipiosAtivos PA ON I.idPrincipio = PA.idPrincipio;

--producao e ingredientes juntos
SELECT
    P.idProducao,
    P.DataProducao,
    M.idMedicamento,
    M.Nome AS Medicamento,
    P.Quantidade AS QuantidadeProduzida,
    PA.idPrincipio,
    PA.Nome AS PrincipioAtivo,
    I.Quantidade AS QuantidadeUsada
FROM Producoes P
INNER JOIN Medicamentos M
    ON P.idMedicamento = M.idMedicamento
INNER JOIN Ingredientes I
    ON P.idProducao = I.idProducao
INNER JOIN PrincipiosAtivos PA
    ON I.idPrincipio = PA.idPrincipio
ORDER BY
    P.idProducao,
    PA.Nome;

--venda com fornecedor, principio ativo, quantidade e valores
SELECT
    c.idCompra AS Compra,
    c.DataCompra,     
    f.RazaoSocial AS Fornecedor,
    pa.Nome AS PrincipioAtivo,
    ic.Quantidade,
    ic.ValorUnitario,
    (ic.Quantidade * ic.ValorUnitario) AS TotalItem
FROM Compras c
JOIN Fornecedores f ON f.idFornecedor = c.idFornecedor
JOIN ItensCompras ic ON ic.idCompra = c.idCompra
JOIN PrincipiosAtivos pa ON pa.idPrincipio = ic.idPrincipio
ORDER BY c.idCompra, pa.Nome;

--venda com cliente, medicamento, quantidade e valores
SELECT
    v.idVenda,
    c.Nome + ' ' + c.Sobrenome AS Cliente,
    m.Nome AS Medicamento,
    m.ValorVenda AS ValorUnitario,
    iv.Quantidade,
    (IV.Quantidade * m.ValorVenda) AS TotalItem,
(SELECT SUM(iv.Quantidade * m.ValorVenda)
FROM ItensVendas iv
JOIN Medicamentos m ON m.idMedicamento = iv.idMedicamento
WHERE iv.idVenda = v.idVenda) AS ValorTotalVenda
FROM Vendas v
JOIN Clientes c ON c.idCliente = v.idCliente
JOIN ItensVendas iv ON iv.idVenda = v.idVenda
JOIN Medicamentos m ON m.idMedicamento = iv.idMedicamento
ORDER BY v.idVenda, m.Nome;

--relatório medicamentos mais vendidos
SELECT
    M.Nome AS Medicamento,
    SUM(IV.Quantidade) AS TotalVendido
FROM ItensVendas IV
INNER JOIN Medicamentos M ON IV.idMedicamento = M.idMedicamento
GROUP BY M.Nome
ORDER BY TotalVendido DESC;

--relatorio de compras fornecedor
SELECT
    C.idCompra,
    C.DataCompra,
    F.RazaoSocial AS Fornecedor,
    SUM(IC.Quantidade * IC.ValorUnitario) AS ValorTotalCompra
FROM Compras C
JOIN Fornecedores F ON F.idFornecedor = C.idFornecedor
JOIN ItensCompras IC ON IC.idCompra = C.idCompra
GROUP BY C.idCompra, C.DataCompra, F.RazaoSocial
ORDER BY C.DataCompra, C.idCompra;
