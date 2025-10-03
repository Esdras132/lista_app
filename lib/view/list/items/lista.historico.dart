import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:brasil_fields/brasil_fields.dart';
import 'package:lista_de_compras/controller/alert.controller.dart';
import 'package:lista_de_compras/controller/lista.preco.controller.dart';
import 'package:lista_de_compras/controller/shared.preferences.controller.dart';
import 'package:lista_de_compras/model/item.model.dart';
import 'package:lista_de_compras/model/lista.model.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class HistoricoPage extends StatefulWidget {
  const HistoricoPage({super.key, required this.model});

  final HistoricoModel model;

  @override
  State<HistoricoPage> createState() => _HistoricoPageState();
}

class _HistoricoPageState extends State<HistoricoPage> {
  List<ItemModel> items = [];
  AlertController alert = AlertController();
  ListaHistoricoController controller = ListaHistoricoController();

  final GlobalKey _totalKey = GlobalKey();
  final GlobalKey _titleKey = GlobalKey();

  List<TargetFocus> targets = [];

  SharedPreferencesController sharedPreferencesController =
      SharedPreferencesController();

  @override
  void initState() {
    super.initState();
     sharedPreferencesController.get(context, 'historico_user_id').then((value) {
      value == null
          ? {
            sharedPreferencesController.set(
              context,
              'historico_user_id',
              FirebaseAuth.instance.currentUser!.uid,
            ),
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showTutorial();
            }),
          }
          : {
            if (value != FirebaseAuth.instance.currentUser!.uid)
              {
                sharedPreferencesController.set(
                  context,
                  'historico_user_id',
                  FirebaseAuth.instance.currentUser!.uid,
                ),
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _showTutorial();
                }),
              },
          };
    }); 
  }

  void _showTutorial() {
    targets.clear();

    targets.add(
      TargetFocus(
        identify: "ADDITEM",
        keyTarget: _totalKey,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: Text(
              "Aqui está o total gasto e a quantidade de itens na lista",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ],
      ),
    );



    targets.add(
      TargetFocus(
        identify: "TITLE",
        keyTarget: _titleKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Text(
              "Aqui está o título da sua lista e a data",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ],
      ),
    );

    TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.green.shade900,
      textSkip: "PULAR",
      paddingFocus: 10,
      opacityShadow: 0.8,
      alignSkip: Alignment.bottomLeft,
    ).show(context: context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[700],
      appBar: AppBar(
        elevation: 8,
        shadowColor: Colors.black87,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '${widget.model.descricao!.length > 20 ? '${widget.model.descricao!.substring(0, 20)}...' : widget.model.descricao!} ',
              key: _titleKey,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              "Data: ${formatarData(widget.model.data!)}",
              style: const TextStyle(fontSize: 17, color: Colors.white),
            ),
          ],
        ),
      ),
      body:
          widget.model.items!.isEmpty
              ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Image.asset("assets/naotemnada.png"),
                  ),
                  const Text(
                    "Não tem Produtos",
                    style: TextStyle(fontSize: 27, color: Colors.white),
                  ),
                ],
              )
              : ListView.builder(
                itemCount: widget.model.items!.length,
                itemBuilder: (context, index) {
                  items = widget.model.items!;
                  final item = widget.model.items![index];

                  return ListTile(
                    onTap: () {
                      setState(() {
                        item.checked = !item.checked;
                      });
                    },
                    /*                     onLongPress: () {
                      controller.editItem(
                        context,
                        widget.model,
                        item,
                        () => setState(() {}),
                      );
                    }, */
                    /*                     leading: Theme(
                      data: Theme.of(context).copyWith(
                        checkboxTheme: CheckboxThemeData(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          side: const BorderSide(color: Colors.white, width: 2),
                        ),
                      ),
                      child: Checkbox(
                        value: item.checked,
                        checkColor: Colors.white,
                        activeColor: Colors.green,
                        onChanged: (bool? value) {
                          setState(() {
                            item.checked = value!;
                          });
                        },
                      ),
                    ), */
                    title: Text(
                      item.descricao!,
                      style: const TextStyle(fontSize: 25, color: Colors.white),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quantidade ${item.quantidade} ${item.quantidade?.truncateToDouble() == item.quantidade ? 'UN' : 'KG'}',
                          style: const TextStyle(color: Colors.white),
                        ),
                        Text(
                          'Valor ${UtilBrasilFields.obterReal(item.valor!.toDouble())}',
                          style: const TextStyle(color: Colors.white),
                        ),
                        Text(
                          'Valor Total ${UtilBrasilFields.obterReal(item.getTotal())}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  );
                },
              ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          key: _totalKey,
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Qtd: ${widget.model.items!.length.toString()}/Total: ${UtilBrasilFields.obterReal(widget.model.getTotal())}',
          ),
        ),
      ),
    );
  }

  String formatarData(DateTime data) {
    String dia = data.day.toString().padLeft(2, '0');
    String mes = data.month.toString().padLeft(2, '0');
    String ano = data.year.toString();
    return "$dia/$mes/$ano";
  }
}
