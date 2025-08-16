import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lista_de_compras/controller/alert.controller.dart';
import 'package:lista_de_compras/model/name.item.model.dart';
import 'package:lista_de_compras/model/name.model.dart';
import 'package:lista_de_compras/services/db.service.dart';

class ListaPersonalizada extends StatefulWidget {
  const ListaPersonalizada({super.key});

  @override
  State<ListaPersonalizada> createState() => _ListaPersonalizadaState();
}

class ListaItem {
  String id;
  String title;
  String table;
  String subtitle;
  bool personalizada;

  ListaItem({
    required this.id,
    required this.table,
    required this.title,
    required this.subtitle,
    this.personalizada = false,
  });
}

class _ListaPersonalizadaState extends State<ListaPersonalizada> {
  AlertController alertController = AlertController();
  bool _loading = false;
  final List<ListaItem> _itens = [
    ListaItem(
      id: 'cafe',
      table: 'Café',
      title: 'Lista do Café',
      subtitle: 'Você come em casa?',
    ),
    ListaItem(
      id: 'almoco',
      table: 'Almoço',
      title: 'Lista do Almoço',
      subtitle: 'Você come em casa?',
    ),
    ListaItem(
      id: 'janta',
      table: 'Jantar',
      title: 'Lista do Jantar',
      subtitle: 'Vocês come em casa?',
    ),
    ListaItem(
      id: 'higiene',
      table: 'Higiene',
      title: 'Lista de Higiene',
      subtitle: 'Produtos de limpeza e higiene',
    ),
    ListaItem(
      id: 'lanche',
      table: 'Lanche',
      title: 'Lista do Lanche',
      subtitle: 'Ingredientes para o lanche',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[700],
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Lista Personalizada',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body:
          _loading
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Carregando Sua \n Lista Personalizada...',
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: _itens.length,
                          itemBuilder: (context, index) {
                            final item = _itens[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildSettingItem(item),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSaveButton(),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          _loading = true;
          DBServiceLista.deleteMyList();

          setState(() {});

          final lista = await DBserviceListaPersonalizada.fetchAll().first;
          log('Lista personalizada: ${lista.length}');

          if (lista.isNotEmpty) {
            await DBserviceListaPersonalizada.deleteMyList();
          }

          try {
            final Map<String, dynamic> dados = {};

            for (var item in _itens) {
              if (item.personalizada) {
                final String resposta = await rootBundle.loadString(
                  'assets/definicoes/${item.id}.json',
                );
                dados[item.table] = json.decode(resposta);
              } else {
                final String resposta = await rootBundle.loadString(
                  'assets/definicoes/nao_${item.id}.json',
                );
                dados[item.table] = json.decode(resposta);
              }
            }

            for (var item in dados.entries) {
              List<ItensListaModel> modelItems = [];
              for (var item in item.value) {
                modelItems.add(
                  ItensListaModel(
                    descricao: item['descricao']?.toString() ?? '',
                    quantidade: (item['quantidade'] as num?)?.toDouble(),
                  ),
                );
              }
              ListaModel model = ListaModel(
                descricao: item.key.toString(),
                personalizada: true,
                itensName: modelItems,
              );

              DBserviceListaPersonalizada.createMyList(model);
            }
            await Future.delayed(Duration(seconds: 2));
          // ignore: use_build_context_synchronously
          alertController.successMessage(context, 'Lista personalizada\nCriada com sucesso!').show();
          } catch (e) {
            throw Exception('Erro ao salvar lista personalizada: $e');
          } finally {
            _loading = false;
            setState(() {});
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Text(
          'Salvar',
          style: TextStyle(
            color: Colors.green,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem(ListaItem item) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.green,
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade900,
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        title: Text(
          item.title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.subtitle.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8, top: 4),
                child: Text(
                  item.subtitle,
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ),
            const SizedBox(height: 8),
            _buildToggleRow(
              label: 'Personalizada:',
              value: item.personalizada,
              onChanged: (value) {
                setState(() {
                  item.personalizada = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleRow({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: Colors.white70),
        ),
        Row(
          children: [
            _buildToggleButton(
              label: 'Sim',
              selected: value,
              onTap: () => onChanged(true),
            ),
            const SizedBox(width: 8),
            _buildToggleButton(
              label: 'Não',
              selected: !value,
              onTap: () => onChanged(false),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildToggleButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? Colors.green[700]! : Colors.white,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.green[700] : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
