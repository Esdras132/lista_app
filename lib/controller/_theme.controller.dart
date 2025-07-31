import 'package:flutter/material.dart';
import 'package:lista_de_compras/controller/shared.preferences.controller.dart';

class ThemeController with ChangeNotifier {
  SharedPreferencesController sharedPreferencesController = SharedPreferencesController();
  
  
 toggleTheme(BuildContext context, bool isModoEscuro,) {
    sharedPreferencesController.set(context, 'isModoEscuro', isModoEscuro.toString());

  }

  Future<bool> get(BuildContext context) async {
    String? isModoEscuro = await sharedPreferencesController.get(context, 'isModoEscuro');
    if (isModoEscuro == null) {
      return false; 
    }
    if (isModoEscuro == 'true') {
      return true;
    } else {
      return false;
    }
    
  }
}

