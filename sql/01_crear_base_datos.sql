USE master;
GO

IF DB_ID('TiendaOnlineDB') IS NOT NULL
BEGIN
    ALTER DATABASE TiendaOnlineDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE TiendaOnlineDB;
END
GO

CREATE DATABASE TiendaOnlineDB;
GO

USE TiendaOnlineDB;
GO

CREATE TABLE dbo.Categorias (
    CategoriaID   INT IDENTITY(1,1) NOT NULL,
    Nombre        NVARCHAR(60)  NOT NULL,
    Descripcion   NVARCHAR(200) NULL,
    CONSTRAINT PK_Categorias PRIMARY KEY (CategoriaID),
    CONSTRAINT UQ_Categorias_Nombre UNIQUE (Nombre)
);
GO

CREATE TABLE dbo.Proveedores (
    ProveedorID   INT IDENTITY(1,1) NOT NULL,
    Nombre        NVARCHAR(100) NOT NULL,
    NIT           NVARCHAR(20)  NOT NULL,
    Ciudad        NVARCHAR(60)  NOT NULL,
    Telefono      NVARCHAR(20)  NULL,
    Email         NVARCHAR(100) NULL,
    CONSTRAINT PK_Proveedores PRIMARY KEY (ProveedorID),
    CONSTRAINT UQ_Proveedores_NIT UNIQUE (NIT)
);
GO

CREATE TABLE dbo.Productos (
    ProductoID      INT IDENTITY(1,1) NOT NULL,
    SKU             NVARCHAR(20)  NOT NULL,
    Nombre          NVARCHAR(120) NOT NULL,
    CategoriaID     INT           NOT NULL,
    ProveedorID     INT           NOT NULL,
    PrecioUnitario  DECIMAL(12,2) NOT NULL,
    Costo           DECIMAL(12,2) NOT NULL,
    Stock           INT           NOT NULL DEFAULT 0,
    Activo          BIT           NOT NULL DEFAULT 1,
    FechaCreacion   DATE          NOT NULL,
    CONSTRAINT PK_Productos PRIMARY KEY (ProductoID),
    CONSTRAINT UQ_Productos_SKU UNIQUE (SKU),
    CONSTRAINT FK_Productos_Categorias  FOREIGN KEY (CategoriaID) REFERENCES dbo.Categorias(CategoriaID),
    CONSTRAINT FK_Productos_Proveedores FOREIGN KEY (ProveedorID) REFERENCES dbo.Proveedores(ProveedorID),
    CONSTRAINT CK_Productos_Precio CHECK (PrecioUnitario > 0 AND Costo > 0),
    CONSTRAINT CK_Productos_Stock  CHECK (Stock >= 0)
);
GO

CREATE TABLE dbo.Clientes (
    ClienteID      INT IDENTITY(1,1) NOT NULL,
    Nombres        NVARCHAR(60)  NOT NULL,
    Apellidos      NVARCHAR(80)  NOT NULL,
    Documento      NVARCHAR(15)  NOT NULL,
    Email          NVARCHAR(120) NOT NULL,
    Telefono       NVARCHAR(20)  NULL,
    FechaRegistro  DATETIME2(0)  NOT NULL,
    Segmento       NVARCHAR(15)  NOT NULL,
    CONSTRAINT PK_Clientes PRIMARY KEY (ClienteID),
    CONSTRAINT UQ_Clientes_Documento UNIQUE (Documento),
    CONSTRAINT UQ_Clientes_Email UNIQUE (Email),
    CONSTRAINT CK_Clientes_Segmento CHECK (Segmento IN (N'Regular', N'Frecuente', N'Premium'))
);
GO

CREATE TABLE dbo.Direcciones (
    DireccionID   INT IDENTITY(1,1) NOT NULL,
    ClienteID     INT           NOT NULL,
    Tipo          NVARCHAR(15)  NOT NULL,
    Direccion     NVARCHAR(150) NOT NULL,
    Ciudad        NVARCHAR(60)  NOT NULL,
    Departamento  NVARCHAR(60)  NOT NULL,
    EsPrincipal   BIT           NOT NULL DEFAULT 0,
    CONSTRAINT PK_Direcciones PRIMARY KEY (DireccionID),
    CONSTRAINT FK_Direcciones_Clientes FOREIGN KEY (ClienteID) REFERENCES dbo.Clientes(ClienteID),
    CONSTRAINT CK_Direcciones_Tipo CHECK (Tipo IN (N'Casa', N'Oficina', N'Otro'))
);
GO

CREATE TABLE dbo.Pedidos (
    PedidoID     INT IDENTITY(1,1) NOT NULL,
    ClienteID    INT           NOT NULL,
    DireccionID  INT           NOT NULL,
    FechaPedido  DATETIME2(0)  NOT NULL,
    Estado       NVARCHAR(15)  NOT NULL,
    Canal        NVARCHAR(15)  NOT NULL,
    Total        DECIMAL(14,2) NOT NULL,
    CONSTRAINT PK_Pedidos PRIMARY KEY (PedidoID),
    CONSTRAINT FK_Pedidos_Clientes    FOREIGN KEY (ClienteID)   REFERENCES dbo.Clientes(ClienteID),
    CONSTRAINT FK_Pedidos_Direcciones FOREIGN KEY (DireccionID) REFERENCES dbo.Direcciones(DireccionID),
    CONSTRAINT CK_Pedidos_Estado CHECK (Estado IN (N'Pendiente', N'Pagado', N'Enviado', N'Entregado', N'Cancelado')),
    CONSTRAINT CK_Pedidos_Canal  CHECK (Canal IN (N'Web', N'App', N'Teléfono'))
);
GO

CREATE TABLE dbo.DetallePedido (
    DetalleID       INT IDENTITY(1,1) NOT NULL,
    PedidoID        INT           NOT NULL,
    ProductoID      INT           NOT NULL,
    Cantidad        INT           NOT NULL,
    PrecioUnitario  DECIMAL(12,2) NOT NULL,   -- precio al momento de la compra
    Descuento       DECIMAL(5,2)  NOT NULL DEFAULT 0, -- porcentaje
    CONSTRAINT PK_DetallePedido PRIMARY KEY (DetalleID),
    CONSTRAINT FK_Detalle_Pedidos   FOREIGN KEY (PedidoID)   REFERENCES dbo.Pedidos(PedidoID),
    CONSTRAINT FK_Detalle_Productos FOREIGN KEY (ProductoID) REFERENCES dbo.Productos(ProductoID),
    CONSTRAINT UQ_Detalle_Pedido_Producto UNIQUE (PedidoID, ProductoID),
    CONSTRAINT CK_Detalle_Cantidad CHECK (Cantidad > 0),
    CONSTRAINT CK_Detalle_Descuento CHECK (Descuento BETWEEN 0 AND 100)
);
GO

CREATE TABLE dbo.Pagos (
    PagoID     INT IDENTITY(1,1) NOT NULL,
    PedidoID   INT           NOT NULL,
    Metodo     NVARCHAR(30)  NOT NULL,
    Monto      DECIMAL(14,2) NOT NULL,
    FechaPago  DATETIME2(0)  NOT NULL,
    Estado     NVARCHAR(15)  NOT NULL,
    CONSTRAINT PK_Pagos PRIMARY KEY (PagoID),
    CONSTRAINT FK_Pagos_Pedidos FOREIGN KEY (PedidoID) REFERENCES dbo.Pedidos(PedidoID),
    CONSTRAINT CK_Pagos_Estado CHECK (Estado IN (N'Aprobado', N'Rechazado', N'Reembolsado'))
);
GO

CREATE TABLE dbo.Envios (
    EnvioID         INT IDENTITY(1,1) NOT NULL,
    PedidoID        INT           NOT NULL,
    Transportadora  NVARCHAR(40)  NOT NULL,
    NumeroGuia      NVARCHAR(30)  NOT NULL,
    FechaEnvio      DATETIME2(0)  NOT NULL,
    FechaEntrega    DATETIME2(0)  NULL,
    CostoEnvio      DECIMAL(10,2) NOT NULL,
    Estado          NVARCHAR(15)  NOT NULL,
    CONSTRAINT PK_Envios PRIMARY KEY (EnvioID),
    CONSTRAINT UQ_Envios_Pedido UNIQUE (PedidoID),
    CONSTRAINT FK_Envios_Pedidos FOREIGN KEY (PedidoID) REFERENCES dbo.Pedidos(PedidoID)
);
GO

CREATE TABLE dbo.Resenas (
    ResenaID      INT IDENTITY(1,1) NOT NULL,
    ProductoID    INT           NOT NULL,
    ClienteID     INT           NOT NULL,
    Calificacion  TINYINT       NOT NULL,
    Comentario    NVARCHAR(300) NULL,
    Fecha         DATETIME2(0)  NOT NULL,
    CONSTRAINT PK_Resenas PRIMARY KEY (ResenaID),
    CONSTRAINT FK_Resenas_Productos FOREIGN KEY (ProductoID) REFERENCES dbo.Productos(ProductoID),
    CONSTRAINT FK_Resenas_Clientes  FOREIGN KEY (ClienteID)  REFERENCES dbo.Clientes(ClienteID),
    CONSTRAINT UQ_Resenas_Producto_Cliente UNIQUE (ProductoID, ClienteID),
    CONSTRAINT CK_Resenas_Calificacion CHECK (Calificacion BETWEEN 1 AND 5)
);
GO

CREATE INDEX IX_Productos_Categoria ON dbo.Productos(CategoriaID);
CREATE INDEX IX_Productos_Proveedor ON dbo.Productos(ProveedorID);
CREATE INDEX IX_Direcciones_Cliente ON dbo.Direcciones(ClienteID);
CREATE INDEX IX_Pedidos_Cliente     ON dbo.Pedidos(ClienteID);
CREATE INDEX IX_Pedidos_Fecha       ON dbo.Pedidos(FechaPedido);
CREATE INDEX IX_Detalle_Producto    ON dbo.DetallePedido(ProductoID);
CREATE INDEX IX_Pagos_Pedido        ON dbo.Pagos(PedidoID);
CREATE INDEX IX_Resenas_Cliente     ON dbo.Resenas(ClienteID);
GO

PRINT 'Base de datos TiendaOnlineDB creada con 10 tablas';
GO
