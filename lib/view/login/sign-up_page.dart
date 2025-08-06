import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import "dart:developer";
import 'package:email_validator/email_validator.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lista_de_compras/controller/alert.controller.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _senha = TextEditingController();
  final TextEditingController _confirmacaoSenha = TextEditingController();
  final AlertController alertController = AlertController();
  final _formKey = GlobalKey<FormState>();
  bool passenable = true;
  bool passenableCon = true;
  bool _indicador = false;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();


    Future<void> _salvarCredenciais(String email, String senha) async {
    await _secureStorage.write(key: 'saved_email', value: email);
    await _secureStorage.write(key: 'saved_password', value: senha);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Cadastro',
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: _indicador
            ? const CircularProgressIndicator(
                color: Colors.green,
                backgroundColor: Colors.grey,
              )
            : _buildForm(),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/logo_lista.png",
              width: 100,
              alignment: Alignment.center,
            ),
            const SizedBox(height: 20),

            _buildTextField(
              controller: _email,
              label: 'Email',
              obscureText: false,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Digite um E-mail válido';
                } else if (!EmailValidator.validate(value)) {
                  return 'E-mail inválido';
                }
                return null;
              },
              keyboardType: TextInputType.emailAddress,
              icon: Icons.email,
            ),

            _buildTextField(
              controller: _senha,
              label: 'Senha',
              obscureText: passenable,
              validator: (value) {
                if (value == null || value.length < 6) {
                  return 'Senha precisa ter pelo menos 6 caracteres';
                }
                return null;
              },
              keyboardType: TextInputType.visiblePassword,
              icon: passenable ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              onIconPress: () {
                setState(() {
                  passenable = !passenable;
                });
              },
            ),

            _buildTextField(
              controller: _confirmacaoSenha,
              label: 'Confirme a Senha',
              obscureText: passenableCon,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'A confirmação da senha precisa ser preenchida';
                } else if (value != _senha.text) {
                  return 'As senhas não coincidem';
                }
                return null;
              },
              keyboardType: TextInputType.visiblePassword,
              icon: passenableCon ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              onIconPress: () {
                setState(() {
                  passenableCon = !passenableCon;
                });
              },
            ),

            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: LinearGradient(
                  colors: [Colors.green.shade400, Colors.green.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              margin: const EdgeInsets.all(16.0),
              child: TextButton(
                onPressed: _signUp,
                child: const Text(
                  'Cadastrar',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Já tem uma conta? ', style: TextStyle(fontSize: 16)),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Entrar',
                    style: TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _indicador = true;
      });
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _email.text,
          password: _senha.text,
        );
        
        
        await _salvarCredenciais(_email.text, _senha.text);
        Navigator.pop(context);
      } catch (e) {
        log(e.toString());
        alertController.showSnackBarError(context,'Esse e-mail já está registrado em outra conta');
      } finally {
        setState(() {
          _indicador = false;
        });
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required String? Function(String?) validator,
    required TextInputType keyboardType,
    required IconData icon,
    void Function()? onIconPress,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        cursorColor: Colors.green,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.green),
          contentPadding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 15.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.green, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.green, width: 2),
          ),
          suffixIcon: IconButton(
            onPressed: onIconPress,
            icon: Icon(icon, color: Colors.green),
          ),
        ),
      ),
    );
  }
}
