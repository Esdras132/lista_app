import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

class Config extends StatefulWidget {
  const Config({Key? key}) : super(key: key);

  @override
  State<Config> createState() => _ConfigState();
}

class _ConfigState extends State<Config> {
  List<String> listitema = ["Claro", "Escuro"];
  String selectval = "Claro";
  String ver = '2.0.0';
  List<String> listliguagens = ["PT-BR", "EN"];
  String selectvall = "PT-BR";
  final Uri _url =
      Uri.parse('https://www.instagram.com/esdrasleviti/');
  late PackageInfo _packageInfo;

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  Widget _infoTile(String title, String subtitle) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle.isEmpty ? 'Not set' : subtitle),
    );
  }

  void copiar() {
    Clipboard.setData(ClipboardData(text: _url.toString()));
    const snackBar =
       SnackBar(content: Text('Link copiado para a área de transferência'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              height: 50,
              width: 10000,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 10,
                    blurRadius: 5,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  children: [
                    TextButton(
                      child: const Text(
                        'Instagram',
                        style: TextStyle(fontSize: 20, color: Colors.black),
                      ),
                      onLongPress: () {
                        copiar();
                      },
                      onPressed: () async {
                        // ignore: deprecated_member_use
                        if (!await launch(_url.toString())) {
                          throw Exception('Could not launch $_url');
                        }
                      },
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Container(
              // height: 50,
              width: 10000,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 10,
                    blurRadius: 5,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DropdownButton(
                      value: selectval,
                      onChanged: (value) {
                        setState(() {
                          selectval = value.toString();
                        });
                      },
                      items: listitema.map((itemone) {
                        return DropdownMenuItem(
                            value: itemone, child: Text(itemone));
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Container(
              height: 50,
              width: 10000,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 10,
                    blurRadius: 5,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DropdownButton(
                      value: selectvall,
                      onChanged: (value) {
                        setState(() {
                          selectvall = value.toString();
                        });
                      },
                      items: listliguagens.map((ligua) {
                        return DropdownMenuItem(
                            value: ligua, child: Text(ligua));
                      }).toList(),
                    ),
                    // Text('Linguagem PT-BR',style: TextStyle(fontSize: 20, color: Colors.black),)
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Container(
              height: 80,
              width: 10000,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 10,
                    blurRadius: 5,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _infoTile('Versão', _packageInfo.version),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
