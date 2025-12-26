import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:monitoringng1/models/head_departement_model.dart';
import 'package:monitoringng1/models/pic_model.dart';
import 'package:monitoringng1/restapi.dart';
import 'package:monitoringng1/config.dart' as ApiConfig;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _picIdController = TextEditingController();
  final DataService _dataService = DataService();
  
  bool _isHeadDepartment = true;
  bool _isLoading = false;

  void _login() async {
    setState(() => _isLoading = true);

    try {
      if (_isHeadDepartment) {
        final username = _usernameController.text.trim();
        final password = _passwordController.text;

        if (username.isEmpty || password.isEmpty) {
          if (mounted) setState(() => _isLoading = false);
          _showErrorDialog('Username dan password wajib diisi');
          return;
        }

        final raw = await _dataService.selectWhere(
          ApiConfig.token,
          ApiConfig.project,
          ApiConfig.CollectionName.headCollection,
          ApiConfig.appid,
          'username',
          username,
        );

        print('DEBUG: Raw response = $raw');
        
        final Map<String, dynamic> response = jsonDecode(raw is String ? raw : raw.toString());
        print('DEBUG: Decoded response = $response');
        
        final List<dynamic> list = response['data'] ?? [];
        print('DEBUG: Data list = $list');
        
        if (list.isEmpty) {
          _showErrorDialog('Username tidak ditemukan');
          if (mounted) setState(() => _isLoading = false);
          return;
        }

        final user = KepalaDepartemenModel.fromJson(list.first);
        print('DEBUG: User data = ${user.username}, stored password = ${user.password}, input password = $password');
        
        if (user.password != password) {
          _showErrorDialog('Password salah');
          if (mounted) setState(() => _isLoading = false);
          return;
        }

        if (!mounted) return;
        try {
          Navigator.pushReplacementNamed(context, '/head-dashboard', arguments: user);
        } catch (e) {
          print('DEBUG: Navigation error = $e');
          _showErrorDialog('Error navigasi: ${e.toString()}');
        }
      } else {
        final picId = _picIdController.text.trim();
        if (picId.isEmpty) {
          _showErrorDialog('ID PIC tidak boleh kosong');
          return;
        }

        final raw = await _dataService.selectWhere(
          ApiConfig.token,
          ApiConfig.project,
          ApiConfig.CollectionName.picCollection,
          ApiConfig.appid,
          'id_pic',
          picId,
        );

        final Map<String, dynamic> response = jsonDecode(raw is String ? raw : raw.toString());
        final List<dynamic> picList = response['data'] ?? [];
        if (picList.isEmpty) {
          _showErrorDialog('ID PIC tidak ditemukan');
          if (mounted) setState(() => _isLoading = false);
          return;
        }

        final pic = PicLineModel.fromJson(picList.first);
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/pic-dashboard', arguments: pic);
      }
    } catch (e) {
      print('DEBUG: Login exception = $e');
      _showErrorDialog('Gagal login. Error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Gagal'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 95, 142, 95),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      'assets/logo-futaba.jpg',
                      fit: BoxFit.contain,
                    )
                  ),
                  
                  const SizedBox(height: 24),
                  const Text(
                    'QUALITY CHECK SYSTEM',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 68, 120, 68),
                    ),
                  ),
                  const Text(
                    'PT Futaba Industrial Indonesia',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => setState(() => _isHeadDepartment = true),
                            style: TextButton.styleFrom(
                              backgroundColor: _isHeadDepartment ? const Color.fromARGB(255, 68, 120, 68) : Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Kepala Departemen',
                              style: TextStyle(
                                color: _isHeadDepartment ? Colors.white : Colors.grey[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextButton(
                            onPressed: () => setState(() => _isHeadDepartment = false),
                            style: TextButton.styleFrom(
                              backgroundColor: !_isHeadDepartment ? const Color.fromARGB(255, 68, 120, 68) : Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'PIC Line',
                              style: TextStyle(
                                color: !_isHeadDepartment ? Colors.white : Colors.grey[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  if (_isHeadDepartment) ...[
                    TextField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ] else ...[
                    TextField(
                      controller: _picIdController,
                      decoration: const InputDecoration(
                        labelText: 'ID PIC Line',
                        prefixIcon: Icon(Icons.badge),
                        border: OutlineInputBorder(),
                        hintText: 'Contoh: PIC-BODY-001',
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Masukkan ID yang diberikan oleh Kepala Departemen',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  
                  const SizedBox(height: 32),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 68, 120, 68),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'LOGIN',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}