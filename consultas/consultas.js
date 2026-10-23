
// CONSULTA 1: Historial de compras de un cliente

db.pedidos.aggregate([
  { $match: { clienteId: 286 } },
  { $lookup: { from: "clientes", localField: "clienteId", foreignField: "_id", as: "cliente" } },
  { $unwind: "$cliente" },
  { $project: { fechaPedido: 1, estado: 1, total: 1, nombre: "$cliente.nombres", apellidos: "$cliente.apellidos" } },
  { $sort: { fechaPedido: -1 } }
])


// CONSULTA 2: Productos por agotarse y el proveedor a llamar

db.productos.aggregate([
  { $match: { stock: { $lt: 5 } } },
  { $lookup: { from: "proveedores", localField: "proveedorId", foreignField: "_id", as: "proveedor" } },
  { $unwind: "$proveedor" },
  { $project: { _id: 0, nombre: 1, stock: 1, proveedor: "$proveedor.nombre", telefono: "$proveedor.contacto.telefono" } },
  { $sort: { stock: 1 } }
])



// CONSULTA 3: Reseñas de 1 estrella con datos del cliente y del producto (2 $lookup)

db.resenas.aggregate([
  { $match: { calificacion: 1 } },
  { $lookup: { from: "clientes", localField: "clienteId", foreignField: "_id", as: "cliente" } },
  { $unwind: "$cliente" },
  { $lookup: { from: "productos", localField: "productoId", foreignField: "_id", as: "producto" } },
  { $unwind: "$producto" },
  { $project: { _id: 0, comentario: 1, cliente: "$cliente.nombres", telefono: "$cliente.telefono", producto: "$producto.nombre" } }
])



// CONSULTA 4: Pedidos cancelados más grandes

db.pedidos.aggregate([
  { $match: { estado: "Cancelado" } },
  { $lookup: { from: "clientes", localField: "clienteId", foreignField: "_id", as: "cliente" } },
  { $unwind: "$cliente" },
  { $project: { total: 1, cliente: "$cliente.nombres", email: "$cliente.email" } },
  { $sort: { total: -1 } },
  { $limit: 10 }
])



// CONSULTA 5: Pedidos en camino con su guía y transportadora

db.pedidos.aggregate([
  { $match: { estado: "Enviado" } },
  { $lookup: { from: "clientes", localField: "clienteId", foreignField: "_id", as: "cliente" } },
  { $unwind: "$cliente" },
  { $project: { cliente: "$cliente.nombres", telefono: "$cliente.telefono", ciudad: "$direccionEntrega.ciudad", transportadora: "$envio.transportadora", guia: "$envio.numeroGuia" } }
])



// CONSULTA 6: Catálogo de celulares con su proveedor

db.productos.aggregate([
  { $match: { "categoria.nombre": "Celulares" } },
  { $lookup: { from: "proveedores", localField: "proveedorId", foreignField: "_id", as: "proveedor" } },
  { $unwind: "$proveedor" },
  { $project: { _id: 0, nombre: 1, precioUnitario: 1, stock: 1, proveedor: "$proveedor.nombre" } },
  { $sort: { precioUnitario: -1 } }
])



// CONSULTA 7: Últimos 10 pagos rechazados

db.pedidos.aggregate([
  { $unwind: "$pagos" },
  { $match: { "pagos.estado": "Rechazado" } },
  { $lookup: { from: "clientes", localField: "clienteId", foreignField: "_id", as: "cliente" } },
  { $unwind: "$cliente" },
  { $project: { metodo: "$pagos.metodo", monto: "$pagos.monto", fecha: "$pagos.fecha", cliente: "$cliente.nombres", telefono: "$cliente.telefono" } },
  { $sort: { fecha: -1 } },
  { $limit: 10 }
])



// CONSULTA 8: Detalle de un pedido con producto y proveedor (2 $lookup)

db.pedidos.aggregate([
  { $match: { _id: 9 } },
  { $unwind: "$items" },
  { $lookup: { from: "productos", localField: "items.productoId", foreignField: "_id", as: "producto" } },
  { $unwind: "$producto" },
  { $lookup: { from: "proveedores", localField: "producto.proveedorId", foreignField: "_id", as: "proveedor" } },
  { $unwind: "$proveedor" },
  { $project: { _id: 0, producto: "$producto.nombre", cantidad: "$items.cantidad", subtotal: "$items.subtotal", proveedor: "$proveedor.nombre" } }
])
