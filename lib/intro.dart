import 'package:Lista_de_compras/login/login.dart';
import 'package:flutter/material.dart';

// ignore: camel_case_types
class intro extends StatefulWidget {
  const intro({super.key});

  @override
  State<intro> createState() => _introState();
}

// ignore: camel_case_types
class _introState extends State<intro> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Title(
            color: Colors.black, child: const Text('Conheça a sua nova lista')),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const loginpage()),
                    );
                  },
                  child: const Text('Entre agora'),),
              
            ],
          ),
        ),
      ),
    );
  }
}
