import "package:flutter/material.dart";

class loginpage extends StatefulWidget {
  const loginpage({super.key});

  @override
  State<loginpage> createState() => _loginState();
}

class _loginState extends State<loginpage> {
  TextEditingController _login = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      alignment: Alignment.center,
      child: widgetTextField(),
    ));
  }

  widgetTextField() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Image.asset(
            "assets/logo_lista.png",
          ),
        ),
        TextField(
          cursorColor: Colors.green,
          controller: _login,
          decoration: const InputDecoration(labelText: 'login'),
          textInputAction: TextInputAction.next,
        ),
      ],
    );
  }
}
