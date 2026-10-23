USE TiendaOnlineDB;
GO


SELECT 'Categorias' AS Tabla, COUNT(*) AS Registros FROM dbo.Categorias UNION ALL
SELECT 'Proveedores',   COUNT(*) FROM dbo.Proveedores   UNION ALL
SELECT 'Productos',     COUNT(*) FROM dbo.Productos     UNION ALL
SELECT 'Clientes',      COUNT(*) FROM dbo.Clientes      UNION ALL
SELECT 'Direcciones',   COUNT(*) FROM dbo.Direcciones   UNION ALL
SELECT 'Pedidos',       COUNT(*) FROM dbo.Pedidos       UNION ALL
SELECT 'DetallePedido', COUNT(*) FROM dbo.DetallePedido UNION ALL
SELECT 'Pagos',         COUNT(*) FROM dbo.Pagos         UNION ALL
SELECT 'Envios',        COUNT(*) FROM dbo.Envios        UNION ALL
SELECT 'Resenas',       COUNT(*) FROM dbo.Resenas;

SELECT (SELECT COUNT(*) FROM dbo.Categorias) + (SELECT COUNT(*) FROM dbo.Proveedores)
     + (SELECT COUNT(*) FROM dbo.Productos)  + (SELECT COUNT(*) FROM dbo.Clientes)
     + (SELECT COUNT(*) FROM dbo.Direcciones) + (SELECT COUNT(*) FROM dbo.Pedidos)
     + (SELECT COUNT(*) FROM dbo.DetallePedido) + (SELECT COUNT(*) FROM dbo.Pagos)
     + (SELECT COUNT(*) FROM dbo.Envios) + (SELECT COUNT(*) FROM dbo.Resenas) AS TotalRegistros;

SELECT p.PedidoID, p.Total,
       SUM(CAST(d.Cantidad * d.PrecioUnitario * (1 - d.Descuento / 100.0) AS DECIMAL(14,2))) AS SumaDetalle
FROM dbo.Pedidos p
JOIN dbo.DetallePedido d ON d.PedidoID = p.PedidoID
GROUP BY p.PedidoID, p.Total
HAVING ABS(p.Total - SUM(CAST(d.Cantidad * d.PrecioUnitario * (1 - d.Descuento / 100.0) AS DECIMAL(14,2)))) > 0.01;


SELECT TOP 5 p.PedidoID, c.Nombres + ' ' + c.Apellidos AS Cliente, p.FechaPedido, p.Estado, p.Total,
       COUNT(d.DetalleID) AS Items, e.Transportadora
FROM dbo.Pedidos p
JOIN dbo.Clientes c       ON c.ClienteID = p.ClienteID
JOIN dbo.DetallePedido d  ON d.PedidoID  = p.PedidoID
LEFT JOIN dbo.Envios e    ON e.PedidoID  = p.PedidoID
GROUP BY p.PedidoID, c.Nombres, c.Apellidos, p.FechaPedido, p.Estado, p.Total, e.Transportadora
ORDER BY p.PedidoID;
GO
