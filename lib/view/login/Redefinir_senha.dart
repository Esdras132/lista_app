import 'dart:developer';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lista_de_compras/controller/alert.controller.dart';

class RedefinirSenha extends StatefulWidget {
  const RedefinirSenha({super.key});

  @override
  State<RedefinirSenha> createState() => _RedefinirSenhaState();
}

class _RedefinirSenhaState extends State<RedefinirSenha> {
  final TextEditingController _recuperarSenha = TextEditingController();
  final AlertController alertController = AlertController();
  final _formKey = GlobalKey<FormState>();
  bool _indicador = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Redefinir Senha',
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
    return Padding(
      padding: const EdgeInsets.all(20),
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
            const Text(
              'Recuperar Senha',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 20),
            _buildEmailField(),
            const SizedBox(height: 20),
            _buildSendButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      autofocus: true,
      autofillHints: const [AutofillHints.email],
      controller: _recuperarSenha,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Digite um e-mail válido';
        } else if (!EmailValidator.validate(value)) {
          return 'E-mail inválido';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: 'E-mail',
        labelStyle: const TextStyle(color: Colors.green),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.green),
        ),
        prefixIcon: const Icon(Icons.email, color: Colors.green),
      ),
    );
  }

  Widget _buildSendButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _enviarEmail,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: const Text(
          'Enviar E-mail',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }

  Future<void> _enviarEmail() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _indicador = true);
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: _recuperarSenha.text);
        if (!mounted) return;
        alertController.showSnackBarError(context, 'Caso seu e-mail esteja cadastrado, será enviado um link para redefinir a senha.');
      } catch (e) {
        log(e.toString());
      } finally {
        setState(() => _indicador = false);
      }
    }
  }
}
