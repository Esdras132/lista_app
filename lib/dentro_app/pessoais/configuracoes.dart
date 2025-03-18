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
  final Uri _url = Uri.parse('https://www.instagram.com/esdrasleviti/');
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

  void copiar() {
    Clipboard.setData(ClipboardData(text: _url.toString()));
    const snackBar = SnackBar(content: Text('Link copiado para a área de transferência'));
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
        child: ListView(
          children: [
            _buildSettingItem(
              title: 'Instagram',
              onLongPress: copiar,
              onPressed: () async {
                // ignore: deprecated_member_use
                if (!await launch(_url.toString())) {
                  throw Exception('Não foi possível abrir o link');
                }
              },
            ),
            const SizedBox(height: 30),
            _buildDropdown(
              title: 'Modo de Tema',
              value: selectval,
              items: listitema,
              onChanged: (value) {
                setState(() {
                  selectval = value.toString();
                });
              },
            ),
/*            const SizedBox(height: 30),
             _buildDropdown(
              title: 'Idioma',
              value: selectvall,
              items: listliguagens,
              onChanged: (value) {
                setState(() {
                  selectvall = value.toString();
                });
              },
            ), */
            const SizedBox(height: 30),
            _buildSettingItem(
              title: 'Versão',
              subtitle: _packageInfo.version,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({required String title, String subtitle = '', VoidCallback? onLongPress, VoidCallback? onPressed}) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 4,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        title: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        subtitle: subtitle.isNotEmpty ? Text(subtitle, style: TextStyle(fontSize: 16, color: Colors.grey.shade600)) : null,
        onLongPress: onLongPress,
        onTap: onPressed,
      ),
    );
  }

  Widget _buildDropdown({required String title, required String value, required List<String> items, required ValueChanged<String?> onChanged}) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 4,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        title: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        trailing: DropdownButton<String>(
          value: value,
          onChanged: onChanged,
          items: items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }
}
