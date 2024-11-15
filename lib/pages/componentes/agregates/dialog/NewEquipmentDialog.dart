import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import '../api/Refrigeration.dart';
import '../api/RefrigerationService.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';

class NewEquipmentDialog extends StatefulWidget {
  final ValueChanged<Refrigeration> onSave;

  NewEquipmentDialog({
    required this.onSave,
  });

  @override
  _NewEquipmentDialogState createState() => _NewEquipmentDialogState();
}

String formatDate(String date) {
  try {
    DateTime parsedDate = DateTime.parse(date);
    return DateFormat('yyyy-MM-dd').format(parsedDate);
  } catch (e) {
    return date;
  }
}
class _NewEquipmentDialogState extends State<NewEquipmentDialog> {
  Future<String> _imageToBase64(File imageFile) async {
    List<int> imageBytes = await imageFile.readAsBytes();
    String base64Image = base64Encode(imageBytes);
    return 'data:image/jpeg;base64,$base64Image';
  }


  final _formKey = GlobalKey<FormState>();
  final _newEquipment = Refrigeration(
    id: null,
    title: '',
    description: 'Activo',
    capacity: 'Capacidad: 100%',
    image: '',
    temperature: '',
    humidity: '',
    lastMaintenance: '',
    nextMaintenance: '',
    model: '',
    serialNumber: '',
    installedDate: '',
  );

  File? _selectedImage;
  final TextEditingController _nextMaintenanceController = TextEditingController();
  final TextEditingController _installedDateController = TextEditingController();

  // Método para seleccionar la imagen
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85, // Comprimir la imagen
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });

      // Convertir la imagen a base64 y guardarla
      final base64Image = await _imageToBase64(_selectedImage!);
      _newEquipment.image = base64Image;
    }
  }

  void _saveEquipment() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      _newEquipment.lastMaintenance = formatDate(_newEquipment.lastMaintenance);
      _newEquipment.nextMaintenance = formatDate(_newEquipment.nextMaintenance);
      _newEquipment.installedDate = formatDate(_newEquipment.installedDate);

      if (_selectedImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor seleccione una imagen')),
        );
        return;
      }

      try {

        final createdEquipment = await RefrigerationService.createRefrigeration(_newEquipment);

        // Cerrar el diálogo
        if (mounted) {
          Navigator.of(context).pop();
        }

        widget.onSave(createdEquipment);

      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al guardar equipo: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Agregar Nuevo Equipo'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField('Título', (value) => _newEquipment.title = value!),
              _buildDatePickerField(
                'Próximo Mantenimiento',
                _nextMaintenanceController,
                    (value) => _newEquipment.nextMaintenance = value,
              ),
              _buildDatePickerField(
                'Fecha de Instalación',
                _installedDateController,
                    (value) => _newEquipment.installedDate = value,
              ),
              _buildTextField('Modelo', (value) => _newEquipment.model = value),
              _buildTextField('Número de Serie', (value) => _newEquipment.serialNumber = value),
              _buildImagePicker(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),  // Cierra el diálogo
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _saveEquipment,  // Guarda el equipo
          child: Text('Guardar'),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, void Function(String value) onSaved) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        decoration: InputDecoration(labelText: label),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Este campo no puede estar vacío';
          }
          return null;
        },
        onSaved: (value) => onSaved(value ?? ''),
      ),
    );
  }

  Widget _buildDatePickerField(String label, TextEditingController controller, void Function(String value) onSaved) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(labelText: label),
        onTap: () async {
          DatePicker.showDatePicker(context,
              showTitleActions: true,
              onConfirm: (date) {
                // Formato de fecha con dos dígitos para día y mes
                final formattedDate = DateFormat("yyyy-MM-dd").format(date);
                controller.text = formattedDate;  // Muestra la fecha seleccionada
                onSaved(formattedDate);  // Guarda la fecha seleccionada
              },
              currentTime: DateTime.now(),
              locale: LocaleType.es);
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Seleccione una fecha';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      children: [
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: _selectedImage == null
              ? Center(
            child: Icon(Icons.image_outlined, size: 50, color: Colors.grey),
          )
              : ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              _selectedImage!,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: _pickImage,
          icon: Icon(Icons.image),
          label: Text(_selectedImage == null ? 'Seleccionar Imagen' : 'Cambiar Imagen'),
        ),
      ],
    );
  }
}