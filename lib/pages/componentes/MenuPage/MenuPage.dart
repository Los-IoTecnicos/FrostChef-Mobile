import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../agregates/dao/DatabaseHelper.dart';
import '../agregates/dao/NotificationDatabaseHelper.dart';

class MenuPage extends StatefulWidget {
  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  List<Map<String, dynamic>> _products = []; // Para almacenar los productos
  bool _isLoading = true; // Estado para manejar la carga
  final dbHelper = NotificationDatabaseHelper();
  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true; // Indica que se están cargando los datos
    });
    final products = await DatabaseHelper().getProducts();
    setState(() {
      _products = products;
      _isLoading = false; // Finaliza la carga
    });
  }


  // Método para refrescar productos
  Future<void> _refreshProducts() async {
    await _loadProducts();  
  }

  void _showProductDetailsDialog(Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.all(10),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Imagen del producto
                      product['imagePath'] != null && product['imagePath'].isNotEmpty
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          height: 200,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: FileImage(File(product['imagePath'])),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      )
                          : Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: Center(child: Text('Sin imagen')),
                      ),
                      SizedBox(height: 16),
                      // Información del producto
                      Row(
                        children: [
                          Text(
                            'Producto: ',
                            style: TextStyle(fontSize: 12),
                          ),
                          Expanded(
                            child: Text(
                              '${product['name'] ?? ''}',
                              style: TextStyle(fontSize: 22, color: Colors.blueAccent, fontWeight: FontWeight.bold),
                              maxLines: 1, // Limitar a una línea
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cantidad: ',
                                style: TextStyle(fontSize: 12),
                              ),
                              Text(
                                '${product['quantity'] ?? 0}',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Categoría: ',
                                style: TextStyle(fontSize: 12),
                              ),
                              Text(
                                '${product['category'] ?? 'N/A'}',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Marca: ',
                                style: TextStyle(fontSize: 12),
                              ),
                              Text(
                                '${product['brand'] ?? 'N/A'}',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                              ),
                              SizedBox(height: 8),
                              // Agregar Detalles aquí
                              Text(
                                'Detalles: ',
                                style: TextStyle(fontSize: 12),
                              ),
                              Text(
                                '${product['details'] ?? 'N/A'}',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                                maxLines: 3, // Limitar el número de líneas
                                overflow: TextOverflow.ellipsis, // Manejar el desbordamiento
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Fecha de Entrada: ',
                                style: TextStyle(fontSize: 12),
                              ),
                              Text(
                                '${product['entryDate'] ?? 'N/A'}',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Fecha de Expiración: ',
                                style: TextStyle(fontSize: 12),
                              ),
                              Text(
                                '${product['expirationDate'] ?? 'N/A'}',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      // Botones de acción
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                _confirmDeleteProduct(product);
                              },
                              child: Text(
                                'Eliminar',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent, // Color del botón
                                padding: EdgeInsets.symmetric(vertical: 6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  // Eliminamos el borde
                                  side: BorderSide(color: Colors.transparent),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10), // Espaciado entre botones
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                _markProductAsExpiring(product);
                              },
                              child: Text(
                                'Próximo a Vencer',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade300, // Color del botón
                                padding: EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  // Eliminamos el borde
                                  side: BorderSide(color: Colors.transparent),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.grey[700]?.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Icon(Icons.close, color: Colors.white, size: 18),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDeleteProduct(Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Center(
            child: Text(
              'Confirmar Eliminación',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          content: RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 16, color: Colors.black),
              children: <TextSpan>[
                TextSpan(text: '¿Está seguro que desea eliminar el producto "', style: TextStyle(fontWeight: FontWeight.normal)),
                TextSpan(text: product['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: '"?', style: TextStyle(fontWeight: FontWeight.normal)),
              ],
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                backgroundColor: Colors.grey[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo de confirmación
              },
              child: Text(
                'Cancelar',
                style: TextStyle(color: Colors.black),
              ),
            ),
            SizedBox(width: 8),
            TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                await DatabaseHelper().deleteProduct(product['id']);
                Fluttertoast.showToast(
                  msg: "Producto eliminado",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: Colors.green,
                  textColor: Colors.white,
                );
                // Llama al método para recargar los productos
                await _loadProducts();
                Navigator.of(context).pop(); // Cierra el diálogo de confirmación
                Navigator.of(context).pop(); // Cierra el diálogo de detalles del producto
              },
              child: Text(
                'Aceptar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }


  void _markProductAsExpiring(Map<String, dynamic> product) async {
    try {
      // Crear una copia mutable del mapa
      final mutableProduct = Map<String, dynamic>.from(product);

      setState(() {
        mutableProduct['isExpiring'] = true;
      });

      // Crear el mapa de datos para la notificación
      final notificationData = {
        'name': mutableProduct['name'],
        'quantity': mutableProduct['quantity'],
        'expirationDate': mutableProduct['expirationDate'],
      };

      // Insertar la notificación
      final result = await dbHelper.insertNotification({
        'type': 'product',
        'title': 'Producto próximo a vencer',
        'message': 'El producto ${mutableProduct['name']} está próximo a vencer',
        'timestamp': DateTime.now().toIso8601String(),
        'data': notificationData.toString(),
      });

      if (result > 0) {
        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Notificación creada correctamente'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        throw Exception('No se pudo crear la notificación');
      }

      // Recargar los productos
      await _loadProducts();

    } catch (e) {
      print('Error al marcar producto como vencido: $e');
      // Mostrar mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text('Error al crear la notificación: ${e.toString()}'),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Menú de Productos',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshProducts,  
        color: Colors.blueAccent,  
        child: _isLoading
            ? Center(child: CircularProgressIndicator()) 
            : _products.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, size: 60, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No hay productos disponibles.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        )
            : Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Total de productos: ${_products.length}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.end,
              ),
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                ),
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  final product = _products[index];
                  return _buildProductCard(product, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildProductCard(Map<String, dynamic> product, int index) {
    return Card(
      margin: EdgeInsets.all(8.0),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mostrar la imagen del producto
          product['imagePath'] != null && product['imagePath'].isNotEmpty
              ? ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: FileImage(File(product['imagePath'])),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          )
              : ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            child: Container(
              height: 100,
              color: Colors.grey[300],
              child: Center(child: Text('Sin imagen')),
            ),
          ),

          // Si el producto está próximo a vencer, mostrar un mensaje
          if (product['isExpiring'] == true)
            Container(
              color: Colors.red,
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Próximo a vencer',
                style: TextStyle(fontSize: 12, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Producto: ',
                      style: TextStyle(fontSize: 12, color: Colors.black),
                    ),
                    Expanded(
                      child: Text(
                        product['name'] ?? '',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'Marca: ',
                      style: TextStyle(fontSize: 12, color: Colors.black),
                    ),
                    Text(
                      '${product['brand'] ?? 0}',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'Cantidad: ',
                      style: TextStyle(fontSize: 12, color: Colors.black),
                    ),
                    Text(
                      '${product['quantity'] ?? 0}',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                    ),
                  ],
                ),
                Center(
                  child: ElevatedButton(
                    onPressed: () => _showProductDetailsDialog(product),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      minimumSize: Size(0, 30),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: Text(
                      'Ver detalle',
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

}
