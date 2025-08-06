import 'dart:developer';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lista_de_compras/controller/alert.controller.dart';
import 'package:lista_de_compras/view/login/Redefinir_senha.dart';
import 'package:lista_de_compras/view/login/sign-up_page.dart';
import 'package:lista_de_compras/view/login/verifyEmail.dart';


class Loginpage extends StatefulWidget {
  const Loginpage({super.key});

  @override
  State<Loginpage> createState() => _LoginState();
}

class _LoginState extends State<Loginpage> {
  final TextEditingController _login = TextEditingController();
  final TextEditingController _senha = TextEditingController();
  final AlertController alertController = AlertController();
  final _formKey = GlobalKey<FormState>();
  bool passenable = true;
  bool _indicador = false;

  // Armazenamento seguro
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _carregarCredenciais();
  }

  // Carrega login e senha armazenados
  Future<void> _carregarCredenciais() async {
    String? savedEmail = await _secureStorage.read(key: 'saved_email');
    String? savedPassword = await _secureStorage.read(key: 'saved_password');

    if (savedEmail != null && savedPassword != null) {
      setState(() {
        _login.text = savedEmail;
        _senha.text = savedPassword;
      });
    }
  }

  // Salvar credenciais no Google Smart Lock
  Future<void> _salvarCredenciais(String email, String senha) async {
    await _secureStorage.write(key: 'saved_email', value: email);
    await _secureStorage.write(key: 'saved_password', value: senha);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child:
                _indicador
                    ? const CircularProgressIndicator(
                      color: Colors.white,
                      backgroundColor: Colors.black12,
                    )
                    : _buildLoginForm(),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return AutofillGroup(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 80,
              backgroundImage: AssetImage("assets/logo2.png"),
              backgroundColor: Colors.green.shade700,
            ),
            const SizedBox(height: 24),
            AnimatedTextKit(
              animatedTexts: [
                TypewriterAnimatedText(
                  'Bem-Vindo!',
                  textStyle: const TextStyle(
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  speed: const Duration(milliseconds: 150),
                ),
              ],
              isRepeatingAnimation: false,
            ),
            const SizedBox(height: 24),
            _buildTextField(
              controller: _login,
              label: "E-mail",
              icon: Icons.email,
              isPassword: false,
              validator: (value) {
                if (value == null || !EmailValidator.validate(value)) {
                  return 'Coloque um E-mail válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _senha,
              label: "Senha",
              icon: Icons.lock,
              isPassword: true,
              validator: (value) {
                if (value == null || value.length < 6) {
                  return 'A senha precisa ter pelo menos 6 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            _buildLoginButton(),
            const SizedBox(height: 16),
            _buildOptions(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isPassword,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType:
          isPassword
              ? TextInputType.visiblePassword
              : TextInputType.emailAddress,
      obscureText: isPassword ? passenable : false,
      cursorColor: Colors.green,
      autofillHints:
          isPassword ? [AutofillHints.password] : [AutofillHints.email],
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        labelStyle: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        prefixIcon: Icon(icon, color: Colors.green),
        suffixIcon:
            isPassword
                ? IconButton(
                  icon: Icon(
                    passenable
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: Colors.green,
                  ),
                  onPressed: () => setState(() => passenable = !passenable),
                )
                : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            setState(() => _indicador = true);
 try {
              await FirebaseAuth.instance.signInWithEmailAndPassword(
                email: _login.text,
                password: _senha.text,
              );

              // Salvar credenciais
              await _salvarCredenciais(_login.text, _senha.text);

              // Integrar com Google Smart Lock (Opcional)
              GoogleSignIn googleSignIn = GoogleSignIn();
              await googleSignIn.signInSilently();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => VerifyEmail()),
              );
              _login.clear();
              _senha.clear();
            } catch (e) {
              // ignore: use_build_context_synchronously
              alertController.showSnackBarError(context, 'Login ou Senha incorretos');
              log(e.toString());
            } finally {
              setState(() => _indicador = false);
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Entrar',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildOptions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () {
            _login.clear();
            _senha.clear();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SignUpPage()),
            );
          },
          child: const Text(
            'Criar conta',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
        const Text('|', style: TextStyle(color: Colors.white, fontSize: 16)),
        TextButton(
          onPressed: () {
            _login.clear();
            _senha.clear();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RedefinirSenha()),
            );
          },
          child: const Text(
            'Esqueci a senha',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ],
    );
  }

}


