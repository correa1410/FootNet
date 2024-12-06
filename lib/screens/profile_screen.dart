import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:footnet/screens/profile_picture_screen.dart';

class ProfileScreen extends StatefulWidget {
  final Function(String)? onPictureSelected;

  ProfileScreen({this.onPictureSelected});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _initial = 'N';
  String? _photoUrl;
  User? _user;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    _user = _auth.currentUser;
    if (_user != null) {
      String? userName = _user?.displayName;
      _initial = (userName != null && userName.isNotEmpty)
          ? userName.substring(0, 1).toUpperCase()
          : 'N';
      _emailController.text = _user?.email ?? '';
      _nameController.text = userName ?? '';
      _photoUrl = _user?.photoURL;
    }
  }

  Future<void> _updateName() async {
    try {
      await _user?.updateDisplayName(_nameController.text);
      await _user?.reload();
      _loadUserData();
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nombre actualizado exitosamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar nombre: $e')),
      );
    }
  }

  Future<void> _updateEmail() async {
    try {
      await _user?.updateEmail(_emailController.text);
      await _user?.reload();
      _loadUserData();
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Correo actualizado exitosamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar correo: $e')),
      );
    }
  }

  Future<void> _updatePassword() async {
    try {
      await _user?.updatePassword(_passwordController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Contraseña actualizada exitosamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar contraseña: $e')),
      );
    }
  }

  Future<void> _deleteAccount() async {
    try {
      await _user?.delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Usuario eliminado exitosamente')),
      );
      Navigator.of(context).pop(); // Cierra el ProfileScreen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar usuario: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil de usuario'),
        backgroundColor: Colors.amber,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          Center(
            child: GestureDetector(
              onTap: () async {
                final selectedPhotoUrl = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePictureScreen(
                      onPictureSelected: (String photoUrl) async {
                        await _updatePhotoUrl(photoUrl);
                      },
                    ),
                  ),
                );

                if (selectedPhotoUrl != null) {
                  await _updatePhotoUrl(selectedPhotoUrl);
                }
              },
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.red,
                backgroundImage: _photoUrl != null ? NetworkImage(_photoUrl!) : null,
                child: _photoUrl == null
                    ? Text(
                        _initial,
                        style: TextStyle(fontSize: 40, color: Colors.white),
                      )
                    : null,
              ),
            ),
          ),
          SizedBox(height: 20),
          ListTile(
            leading: Icon(Icons.email),
            title: TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'メールアドレス'),
            ),
            trailing: IconButton(
              icon: Icon(Icons.save),
              onPressed: _updateEmail,
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.person),
            title: TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'ユーザー名'),
            ),
            trailing: IconButton(
              icon: Icon(Icons.save),
              onPressed: _updateName,
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.lock),
            title: TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: '新しいパスワード'),
              obscureText: true,
            ),
            trailing: IconButton(
              icon: Icon(Icons.save),
              onPressed: _updatePassword,
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.delete, color: Colors.red),
            title: Text(
              'アカウント削除',
              style: TextStyle(color: Colors.red),
            ),
            onTap: _deleteAccount,
          ),
        ],
      ),
    );
  }

  Future<void> _updatePhotoUrl(String photoUrl) async {
    setState(() {
      _photoUrl = photoUrl;
    });

    try {
      await _user?.updatePhotoURL(photoUrl);
      await _user?.reload();
      _user = _auth.currentUser;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar la foto: $e')),
      );
    }
  }
}