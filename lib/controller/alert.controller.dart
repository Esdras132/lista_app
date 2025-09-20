import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';

class AlertController {
  AwesomeDialog confirmDialog(
    BuildContext context, {
    String? bodyMessage,
    VoidCallback? btnOk,
    VoidCallback? btnCancel,
  }) {
    return AwesomeDialog(
      context: context,
      dialogType: DialogType.infoReverse,
      buttonsBorderRadius: const BorderRadius.all(Radius.circular(2)),
      headerAnimationLoop: false,
      btnOkColor: Colors.green,
      btnCancelColor: Colors.red,
      title: 'INFO',
      desc: bodyMessage,
      showCloseIcon: true,
      btnCancelText: 'Cancelar',
      btnCancelOnPress: btnCancel,
      btnOkOnPress: btnOk,
    );
  }

  Future<AwesomeDialog> questionDialog(
    BuildContext context, {
    String? bodyMessage,
    VoidCallback? btnOk,
  }) async {
    return AwesomeDialog(
      context: context,
      dialogType: DialogType.question,
      buttonsBorderRadius: const BorderRadius.all(Radius.circular(2)),
      headerAnimationLoop: false,
      btnOkColor: Colors.green,
      btnCancelColor: Colors.red,
      title: 'PERGUNTA',
      desc: bodyMessage,
      showCloseIcon: true,
      btnCancelText: 'Cancelar',
      btnCancelOnPress: () {},
      btnOkOnPress: btnOk,
    );
  }

  AwesomeDialog successMessage(BuildContext context, String message) {
    return AwesomeDialog(
      context: context,
      headerAnimationLoop: false,
      dialogType: DialogType.success,
      showCloseIcon: true,
      btnOkColor: Colors.green,
      title: 'ATENÇÃO',
      desc: message,
      btnCancelText: 'Cancelar',
      btnOkOnPress: () {},
      btnOkIcon: Icons.check_circle,
    );
  }

  AwesomeDialog bodyMessage(
    BuildContext context,
    Widget? body,
    VoidCallback? btnOk,
    VoidCallback? btnCancel, {
    String? btnTitle,
  }) {
    return AwesomeDialog(
      context: context,
      dialogType: DialogType.infoReverse,
      buttonsBorderRadius: const BorderRadius.all(Radius.circular(2)),
      headerAnimationLoop: false,
      btnOkColor: Colors.green,
      btnCancelColor: Colors.red,
      title: 'INFO',
      body: body,
      showCloseIcon: true,

      btnCancelOnPress: btnCancel,
      btnCancelText: 'Cancelar',
      btnOkText: btnTitle,
      btnOkOnPress: btnOk,
    );
  }

  AwesomeDialog erroMessage(BuildContext context, String message) {
    return AwesomeDialog(
      context: context,
      headerAnimationLoop: false,
      dialogType: DialogType.error,
      showCloseIcon: true,
      btnOkColor: Colors.green,
      title: 'ERRO',
      desc: message,
      btnOkOnPress: () {},
      btnOkIcon: Icons.check_circle,
    );
  }

  void showSnackBarSucesso(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),

        backgroundColor: Colors.greenAccent,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 4),
      ),
    );
  }

  void showSnackBarError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 4),
      ),
    );
  }
}
