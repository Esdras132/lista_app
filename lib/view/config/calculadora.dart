import 'package:flutter/material.dart';
import 'package:lista_de_compras/controller/shared.preferences.controller.dart';
import 'package:math_expressions/math_expressions.dart';

class CalculatorView extends StatefulWidget {
  const CalculatorView({super.key});

  @override
  _CalculatorViewState createState() => _CalculatorViewState();
}

class _CalculatorViewState extends State<CalculatorView> {
  String _output = "0";
  String _input = "";
  SharedPreferencesController sharedPreferencesController =
      SharedPreferencesController();

  @override
  void initState() {
    super.initState();
    sharedPreferencesController.get(context, 'calculadora_input').then((value) {
      setState(() {
        _input = value ?? "";
      });
    });

    sharedPreferencesController.get(context, 'calculadora_output').then((
      value,
    ) {
      setState(() {
        _output = value ?? "";
      });
    });
  }

  void _onPressed(String value) {
    setState(() {
      if (value == "C") {
        _input = "";
        _output = "0";
        sharedPreferencesController.set(context, 'calculadora_input', _input);
        sharedPreferencesController.set(context, 'calculadora_output', _output);
      } else if (value == "=") {
        try {
          sharedPreferencesController.set(context, 'calculadora_input', _input);
          _output = _calculate(_input);
          sharedPreferencesController.set(
            context,
            'calculadora_output',
            _output,
          );
        } catch (e) {
          _output = "Erro";
        }
      } else {
        _input += value;
      }
    });
  }

  String _calculate(String expression) {
    try {
      // ignore: deprecated_member_use
      Parser p = Parser();
      Expression exp = p.parse(expression);
      ContextModel cm = ContextModel();
      double result = exp.evaluate(EvaluationType.REAL, cm);
      return result.toStringAsFixed(2);
    } catch (e) {
      return "Erro";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[700],
      appBar: AppBar(
        title: const Text("Calculadora", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.bottomRight,
              child: Text(
                _input,
                style: const TextStyle(fontSize: 32, color: Colors.white),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.bottomRight,
              child: Text(
                _output,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Expanded(flex: 2, child: _buildButtons()),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    const buttons = [
      "7","8","9","/",
      "4","5","6","*",
      "1","2","3","-",
      "C","0",".","+",
    ];

    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1.5,
            ),
            itemCount: buttons.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () => _onPressed(buttons[index]),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(10),
                  ),
                  child: Text(
                    buttons[index],
                    style: const TextStyle(fontSize: 24, color: Colors.white),
                  ),
                ),
              );
            },
          ),
        ),

        SizedBox(
          width: double.infinity,
          height: 60,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: ElevatedButton(
              onPressed: () => _onPressed("="),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "=",
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
          ),
        ),
        SizedBox(height: 35),
      ],
    );
  }
}
