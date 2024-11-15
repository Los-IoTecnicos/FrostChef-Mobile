import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:frostchef/pages/models/login/providers/AuthProvider.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _image;
  final picker = ImagePicker();
  bool isEditing = false;


  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Datos simulados del usuario (reemplazar con datos reales)
  Map<String, dynamic> userData = {
    'name': 'John Doe',
    'email': 'john.doe@example.com',
    'phone': '+1234567890',
    'role': 'Chef Principal',
  };

  @override
  void initState() {
    super.initState();

    _nameController.text = userData['name'];
    _emailController.text = userData['email'];
    _phoneController.text = userData['phone'];
  }

  Future<void> _getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mi Perfil',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.save : Icons.edit, color: Colors.white),
            onPressed: () {
              setState(() {
                isEditing = !isEditing;
                if (!isEditing) {
                  // Aquí iría la lógica para guardar los cambios
                  userData['name'] = _nameController.text;
                  userData['email'] = _emailController.text;
                  userData['phone'] = _phoneController.text;
                }
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [

            Container(
              color: Colors.blueAccent,
              padding: EdgeInsets.only(bottom: 20.0),
              child: Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: _image != null
                              ? FileImage(_image!) as ImageProvider
                              : AssetImage('assets/images/default_profile.png'),
                        ),
                        if (isEditing)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 20,
                              child: IconButton(
                                icon: Icon(Icons.camera_alt, color: Colors.blueAccent),
                                onPressed: _getImage,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      userData['role'],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Información del usuario
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    'Información Personal',
                    [
                      _buildEditableField(
                        'Nombre',
                        _nameController,
                        Icons.person,
                        enabled: isEditing,
                      ),
                      _buildEditableField(
                        'Email',
                        _emailController,
                        Icons.email,
                        enabled: isEditing,
                      ),
                      _buildEditableField(
                        'Teléfono',
                        _phoneController,
                        Icons.phone,
                        enabled: isEditing,
                      ),
                    ],
                  ),


                  SizedBox(height: 20),

                  // Botones de acción
                  Column(
                    children: [
                      ElevatedButton.icon(
                        icon: Icon(Icons.exit_to_app),
                        label: Text('Cerrar Sesión'),
                        onPressed: () async {
                          await Provider.of<AuthProvider>(context, listen: false).logout();
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          minimumSize: Size(double.infinity, 45),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
        SizedBox(height: 10),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: children,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditableField(
      String label,
      TextEditingController controller,
      IconData icon, {
        bool enabled = false,
      }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabled: enabled,
        ),
      ),
    );
  }

  Widget _buildInfoTile(String title, String value, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(title),
      subtitle: Text(value),
      dense: true,
    );
  }


}