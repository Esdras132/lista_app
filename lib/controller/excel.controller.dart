import 'dart:developer';
import 'dart:io';
import 'package:brasil_fields/brasil_fields.dart';
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
    var rowIndex = 0;
    var total = double.parse('0');
    try {
      if (Platform.isAndroid) {
        final status = await Permission.manageExternalStorage.request();
        if (!status.isGranted) {
          alert.erroMessage(context, 'Permissão de armazenamento negada.');
          return;
        }
      }

      final excel = Excel.createExcel();
      final listaGeral = excel['Listas'];
      final preco = excel['Com Preço'];
      final semPreco = excel['Sem Preço'];

      CellStyle boldStyle = CellStyle(
        bold: true,
        fontFamily: getFontFamily(FontFamily.Calibri),
        horizontalAlign: HorizontalAlign.Center,
        backgroundColorHex: ExcelColor.green,
      );

      // Cabeçalhos
      listaGeral.appendRow([
        TextCellValue('Tipo'),
        TextCellValue('Listas'),
        TextCellValue('Quantidade'),
        TextCellValue('Total'),
      ]);
      listaGeral.row(0).forEach((cell) => cell?.cellStyle = boldStyle);

      preco.appendRow([
        TextCellValue('Lista'),
        TextCellValue('Item'),
        TextCellValue('Quantidade'),
        TextCellValue('Preço'),
      ]);
      preco.row(0).forEach((cell) => cell?.cellStyle = boldStyle);

      semPreco.appendRow([
        TextCellValue('Lista'),
        TextCellValue('Item'),
        TextCellValue('Quantidade'),
      ]);
      semPreco.row(0).forEach((cell) => cell?.cellStyle = boldStyle);

      final listaGeralCom = DBserviceCom.fetchAll();
      final listaGeralSem = DBserviceSem.fetchAll();
      final listaGeralComSnapshot = await listaGeralCom.first;
      final listaGeralSemSnapshot = await listaGeralSem.first;

      for (var item in listaGeralComSnapshot) {
        rowIndex ++;
        total = total + item.getTotal();
        listaGeral.appendRow([
          TextCellValue('Com Preço'),
          TextCellValue(item.descricao ?? ''),
          TextCellValue(item.items?.length.toString() ?? '0'),
          TextCellValue(UtilBrasilFields.obterReal(item.getTotal() ?? '0')),
        ]);
      }

      for (var item in listaGeralSemSnapshot) {
        rowIndex ++;
        listaGeral.appendRow([
          TextCellValue('Sem Preço'),
          TextCellValue(item.descricao ?? ''),
          TextCellValue(item.itensName?.length.toString() ?? '0'),
          TextCellValue(''),
        ]);
      }

      listaGeral.merge(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex  + 1),
        CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex  + 1),
      );

      listaGeral
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex  + 1))
          .value = TextCellValue('Quantidade e Total');

      listaGeral
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex  + 1))
          .value = TextCellValue(UtilBrasilFields.obterReal(total).toString());

      final listaCom = await DBserviceCom.fetchAll();
      final listaComSnapshot = await listaCom.first;
      for (var item in listaComSnapshot) {
        final items = item.items!;
        for (var i = 0; i < items.length; i++) {
          preco.appendRow([
            TextCellValue(item.descricao ?? ''),
            TextCellValue(items[i].descricao ?? ''),
            TextCellValue(items[i].quantidade.toString()),
            TextCellValue(
              UtilBrasilFields.obterReal(
                double.parse(items[i].valor.toString()),
              ),
            ),
          ]);
        }
      }

      // Aba sem preço
      final listaSem = await DBserviceSem.fetchAll();
      final listaSemSnapshot = await listaSem.first;
      for (var item in listaSemSnapshot) {
        final itensName = item.itensName!;
        for (var i = 0; i < itensName.length; i++) {
          semPreco.appendRow([
            TextCellValue(item.descricao ?? ''),
            TextCellValue(itensName[i].descricao ?? ''),
            TextCellValue(itensName[i].quantidade.toString()),
          ]);
        }
      }

      excel.delete('Sheet1');

      Directory? dir;
      if (Platform.isAndroid) {
        dir = Directory('/storage/emulated/0/Download');
      } else {
        dir = await getApplicationDocumentsDirectory();
      }

      final path = '${dir.path}/Lista de Compras.xlsx';
      final fileBytes = excel.save();

      if (fileBytes == null) {
        alert.erroMessage(context, 'Erro ao salvar o Excel.');
        return;
      }

      final file =
          File(path)
            ..createSync(recursive: true)
            ..writeAsBytesSync(fileBytes);

      // ignore: deprecated_member_use
      await Share.shareXFiles([XFile(path)], text: 'Lista de Compras');
    } catch (e) {
      log('Erro: ${e.toString()}');
      alert.erroMessage(context, 'Erro: ${e.toString()}');
    }
  }
}
