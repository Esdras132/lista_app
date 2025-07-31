import 'dart:developer';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:lista_de_compras/controller/alert.controller.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:lista_de_compras/services/db.service.dart';
import 'package:share_plus/share_plus.dart';

class ExcelController {
  final AlertController alert = AlertController();

  Future<void> exportarExcel(BuildContext context) async {
    try {
      // Solicita permissão de armazenamento no Android
      if (Platform.isAndroid) {
        final status = await Permission.manageExternalStorage.request();
        if (!status.isGranted) {
           alert.erroMessage(
            // ignore: use_build_context_synchronously
            context,
            'Permissão de armazenamento negada.',
          );
          
        }
      }

      // Cria o arquivo Excel e a aba
      final excel = Excel.createExcel();
      final preco = excel['Com Preço'];
      final semPreco = excel['Sem Preço'];

      // Cabeçalhos
      preco.appendRow([
        TextCellValue('Lista'),
        TextCellValue('Item'),
        TextCellValue('quantidade'),
        TextCellValue('preço'),
      ]);
      semPreco.appendRow([TextCellValue('Item'), TextCellValue('quantidade')]);

      // Lista com preço
      final listaCom = await DBserviceCom.fetchAll();
      final listaComSnapshot = await listaCom.first;
      for (var item in listaComSnapshot) {
        preco.appendRow([
          TextCellValue(item.descricao ?? ''),
          for (var i = 0; i < item.items!.length; i++)
            TextCellValue(item.items![i].descricao ?? ''),
          for (var i = 0; i < item.items!.length; i++)
            TextCellValue(item.items![i].quantidade.toString()),
          for (var i = 0; i < item.items!.length; i++)
            TextCellValue(item.items![i].valor.toString()),
        ]);
      }

      // Lista sem preço
      final listaSem = await DBserviceSem.fetchAll();
      final listaSemSnapshot = await listaSem.first;
      for (var item in listaSemSnapshot) {
        semPreco.appendRow([
          TextCellValue(item.descricao ?? ''),
          TextCellValue('1'),
        ]);
      }

      // Define o diretório para salvar
      Directory? dir;
      if (Platform.isAndroid) {
        dir = Directory('/storage/emulated/0/Download');
      } else {
        dir = await getApplicationDocumentsDirectory();
      }

      // Caminho do arquivo
      final path = '${dir.path}/lista_compras.xlsx';
      final fileBytes = excel.save();

      if (fileBytes == null) {
        alert.erroMessage(context, 'Erro ao salvar o Excel.');
      }

      final file =
          File(path)
            ..createSync(recursive: true)
            ..writeAsBytesSync(fileBytes!);

      // Mostra a tela para enviar
      // ignore: deprecated_member_use
      await Share.shareXFiles([XFile(path)], text: 'Lista de Compras');
    } catch (e) {
      log('Erro: ${e.toString()}');
      alert.erroMessage(context, 'Erro: ${e.toString()}');
    }
  }
}

