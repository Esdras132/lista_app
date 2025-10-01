import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lista_de_compras/controller/alert.controller.dart';
import 'package:lista_de_compras/controller/lista.name.controller.dart';
import 'package:lista_de_compras/controller/shared.preferences.controller.dart';
import 'package:lista_de_compras/model/name.item.model.dart';
import 'package:lista_de_compras/model/name.model.dart';
import 'package:lista_de_compras/view/list/shopping/shopping.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class ItemsListaPage extends StatefulWidget {
  final ListaModel model;
  const ItemsListaPage({super.key, required this.model});

  @override
  State<ItemsListaPage> createState() => _ItemsListaPageState();
}

class _ItemsListaPageState extends State<ItemsListaPage> {
  List<ItensListaModel> itens = [];
  AlertController alert = AlertController();
  ListaNameController controller = ListaNameController();

  final GlobalKey _addKey = GlobalKey();
  final GlobalKey _selectAllKey = GlobalKey();
  final GlobalKey _shoppingKey = GlobalKey();
  final GlobalKey _titleKey = GlobalKey();

  List<TargetFocus> targets = [];
  SharedPreferencesController sharedPreferencesController =
      SharedPreferencesController();

  @override
  void initState() {
    super.initState();
    sharedPreferencesController.get(context, 'lista_user_id').then((value) {
      value == null
          ? {

            sharedPreferencesController.set(
              context,
              'lista_user_id',
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
                  'lista_user_id',
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
        keyTarget: _addKey,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: Text(
              "Aqui você adiciona um novo item à sua lista",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ],
      ),
    );
    targets.add(
      TargetFocus(
        identify: "SELECTALL",
        keyTarget: _selectAllKey,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: Text(
              "Aqui você seleciona todos os itens da lista",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "SHOPPING",
        keyTarget: _shoppingKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Text(
              "Aqui você inicia as compras, marcando os itens que já foram adquiridos",
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
              "Aqui está o título da sua lista e a quantidade de itens nela",
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
      alignSkip: Alignment.bottomRight,
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
              key: _titleKey,
              '${widget.model.descricao!.length > 20 ? '${widget.model.descricao!.substring(0, 20)}...' : widget.model.descricao!} ',
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              " Qtd: ${widget.model.itensName!.length.toString()}",
              style: const TextStyle(fontSize: 17, color: Colors.white),
            ),
          ],
        ),
        actions: <Widget>[
          (widget.model.itensName!.where((a) => a.checked == true).isNotEmpty)
              ? IconButton(
                onPressed: () {
                  controller.deleteItem(
                    context,
                    widget.model,
                    () => setState(() {}),
                  );
                },
                icon: const Icon(Icons.delete),
              )
              : IconButton(
                key: _shoppingKey,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (context) => ShoppingPage(
                            model: widget.model,
                            refresh: () => setState(() {}),
                          ),
                    ),
                  );
                },
                icon: const Icon(Icons.shopping_cart_outlined),
              ),
        ],
      ),
      body:
          widget.model.itensName!.isEmpty
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
                itemCount: widget.model.itensName!.length,
                itemBuilder: (context, index) {
                  itens = widget.model.itensName!;
                  final item = widget.model.itensName![index];
                  return ListTile(
                    onTap: () {
                      setState(() {
                        item.checked = !item.checked;
                      });
                    },
                    onLongPress: () {
                      controller.editItem(
                        context,
                        widget.model,
                        item,
                        () => setState(() {}),
                      );
                    },
                    leading: Theme(
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
                    ),

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
                      ],
                    ),
                  );
                },
              ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            key: _selectAllKey,
            onPressed: () {
              setState(() {
                for (var item in itens) {
                  item.checked = !item.checked;
                }
              });
            },
            backgroundColor: Colors.green,
            child: Icon(Icons.select_all, color: Colors.white),
          ),
          const SizedBox(height: 20),
          FloatingActionButton(
            key: _addKey,
            backgroundColor: Colors.green,
            child: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              controller.addItem(context, widget.model, () {
                setState(() {});
              });
            },
          ),
        ],
      ),
    );
  }
}
