import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../agregates/dao/DatabaseHelper.dart';

class InventoriesPage extends StatefulWidget {
  @override
  _InventoriesPageState createState() => _InventoriesPageState();
}

class _InventoriesPageState extends State<InventoriesPage> {
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _entryDateController = TextEditingController();
  final TextEditingController _expirationDateController =
  TextEditingController();
  final TextEditingController _detailsController = TextEditingController();

  List<XFile>? _imageFiles; // Para almacenar las imágenes seleccionadas
  final _formKey = GlobalKey<FormState>(); // Clave para el formulario
  bool _isLoading = false; // Estado de carga

  Future<void> _requestPermissions() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  Future<void> _pickImages() async {
    await _requestPermissions(); // Solicitar permisos antes de abrir la galería

    final ImagePicker picker = ImagePicker();
    final List<XFile>? selectedImages = await picker.pickMultiImage();

    if (selectedImages != null) {
      setState(() {
        _imageFiles = selectedImages;
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imageFiles?.removeAt(index);
    });
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey.shade900,
      textColor: Colors.white, //
      fontSize: 12.0,
      webBgColor: "linear-gradient(to right, #00b09b, #96c93d)",
    );
  }


  Future<void> _addProduct() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true; // Activar estado de carga
      });

      // Crear un producto a insertar
      final product = {
        'name': _productNameController.text,
        'category': _categoryController.text,
        'brand': _brandController.text,
        'quantity': int.parse(_quantityController.text),
        'entryDate': _entryDateController.text,
        'expirationDate': _expirationDateController.text,
        'details': _detailsController.text,
        'imagePath': _imageFiles?.isNotEmpty == true
            ? _imageFiles![0].path
            : null, // Usa la primera imagen seleccionada
      };

      // Guardar el producto en la base de datos
      await DatabaseHelper().insertProduct(product);

      // Mostrar mensaje de éxito
      _showToast('Producto registrado exitosamente.');

      // Limpiar los campos después de agregar el producto
      _productNameController.clear();
      _categoryController.clear();
      _brandController.clear();
      _quantityController.clear();
      _entryDateController.clear();
      _expirationDateController.clear();
      _detailsController.clear();
      setState(() {
        _imageFiles = null;
        _isLoading = false; // Desactivar estado de carga
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.store,
              color: Colors.white,
              size: 28,
            ),
            SizedBox(width: 8),
            Text(
              'Agregar Producto',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(22.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField('Nombre de producto', _productNameController),
                _buildTextField('Categoría', _categoryController),
                _buildTextField('Marca', _brandController),
                _buildTextField('Cantidad', _quantityController,
                    isNumeric: true),
                _buildDateField('Fecha de ingreso', _entryDateController),
                _buildDateField('Fecha de expiración', _expirationDateController),
                _buildDetailsField(),
                SizedBox(height: 16),
                Text('Fotos del Producto',
                    style:
                    TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                _buildImageCarousel(),
                SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickImages,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 7, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.4),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.upload_file, size: 18, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'Cargar fotos',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Center(
                  child: _isLoading // Mostrar indicador de carga
                      ? CircularProgressIndicator()
                      : _buildRoundedButton(
                    label: 'Registrar Producto',
                    onPressed: (_areFieldsValid() && _imageFiles != null)
                        ? _addProduct
                        : null,
                    color: Colors.blueAccent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[700]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.0),
            borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.0),
            borderSide: BorderSide(color: Colors.red, width: 2.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.0),
            borderSide: BorderSide(color: Colors.grey, width: 1.0),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Este campo no puede estar vacío';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        onTap: () {
          DatePicker.showDatePicker(context,
              showTitleActions: true,
              onConfirm: (date) {
                controller.text = date.toLocal().toString().split(' ')[0]; // Formato de fecha
              },
              currentTime: DateTime.now(),
              locale: LocaleType.es);
        },
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[700]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.0),
            borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.0),
            borderSide: BorderSide(color: Colors.red, width: 2.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.0),
            borderSide: BorderSide(color: Colors.grey, width: 1.0),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Este campo no puede estar vacío';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDetailsField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: _detailsController,
        maxLines: 3,
        decoration: InputDecoration(
          labelText: 'Detalles del producto',
          labelStyle: TextStyle(color: Colors.grey[700]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.0),
            borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.0),
            borderSide: BorderSide(color: Colors.red, width: 2.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.0),
            borderSide: BorderSide(color: Colors.grey, width: 1.0),
          ),
        ),
      ),
    );
  }

  Widget _buildImageCarousel() {
    return _imageFiles == null || _imageFiles!.isEmpty
        ? Text('No hay imágenes seleccionadas.')
        : Container(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _imageFiles!.length,
        itemBuilder: (context, index) {
          return Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                width: 100,
                margin: EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: FileImage(File(_imageFiles![index].path)),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              IconButton(
                icon: Icon(Icons.remove_circle, color: Colors.red),
                onPressed: () => _removeImage(index),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRoundedButton(
      {required String label, required VoidCallback? onPressed, Color? color}) {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Colors.blueAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Text(
            label,
            style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  bool _areFieldsValid() {
    return _productNameController.text.isNotEmpty &&
        _categoryController.text.isNotEmpty &&
        _brandController.text.isNotEmpty &&
        _quantityController.text.isNotEmpty &&
        _entryDateController.text.isNotEmpty &&
        _expirationDateController.text.isNotEmpty;
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _categoryController.dispose();
    _brandController.dispose();
    _quantityController.dispose();
    _entryDateController.dispose();
    _expirationDateController.dispose();
    _detailsController.dispose();
    super.dispose();
  }
}
