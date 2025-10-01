import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lista_de_compras/controller/alert.controller.dart';
import 'package:lista_de_compras/services/db.service.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

class Config extends StatefulWidget {
  const Config({Key? key}) : super(key: key);

  @override
  State<Config> createState() => _ConfigState();
}

class _ConfigState extends State<Config> {
  PackageInfo? _packageInfo;
  List<String> listitema = ["Claro", "Escuro"];
  String selectval = "Claro";
  String ver = '2.0.0';
  List<String> listliguagens = ["PT-BR", "EN"];
  String selectvall = "PT-BR";
  final Uri _url = Uri.parse('https://www.instagram.com/esdrasleviti/');

  AlertController alertController = AlertController();
  final GlobalKey _redesKey = GlobalKey();
  final GlobalKey _apagarHistoricoKey = GlobalKey();
  final GlobalKey _versaoKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showTutorial();
    });
  }

  void _showTutorial() {
    List<TargetFocus> targets = [
      TargetFocus(
        identify: "Title",
        keyTarget: _redesKey,
        contents: [
          TargetContent(
            // ✅ ADICIONADO AQUI para mover o texto para baixo
            align: ContentAlign.bottom,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: const Text(
              "Aqui você pode acessar as redes sociais do desenvolvedor.",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            )
          ),
        ],
      ),
      TargetFocus(
        identify: "Description",
        keyTarget: _apagarHistoricoKey,
        contents: [
          TargetContent(
            // ✅ ADICIONADO AQUI para mover o texto para baixo
            align: ContentAlign.bottom,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
              "Aqui você pode apagar o histórico de compras.",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),)
          ),
        ],
      ),
      TargetFocus(
        identify: "Description",
        keyTarget: _versaoKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: const Text(
              "Aqui você pode ver a versão do aplicativo. Sempre que tiver uma atualização, você verá a nova versão aqui.",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ];

    TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.green.shade900,
      textSkip: "PULAR",
      paddingFocus: 10,
      opacityShadow: 0.8,
      alignSkip: Alignment.bottomRight,
    ).show(context: context);
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  void copiar() {
    Clipboard.setData(ClipboardData(text: _url.toString()));
    const snackBar = SnackBar(
      content: Text('Link copiado para a área de transferência'),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[700],
      appBar: AppBar(
        title: const Text(
          'Configurações',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _buildSettingItem(
              key: _redesKey,
              title: 'Redes Sociais, Desenvolvedor',
              onLongPress: copiar,
              onPressed: () async {
                if (!await launchUrl(_url)) {
                  throw Exception('Não foi possível abrir o link $_url');
                }
              },
            ),
            const SizedBox(height: 20),
            _buildSettingItem(
              key: _apagarHistoricoKey,
              title: 'Apagar Histórico',
              onPressed: () {
                alertController
                    .confirmDialog(
                      context,
                      bodyMessage: "Deseja apagar todos os itens do Histórico?",
                      btnOk: () {
                        try {
                          DBServiceHistorico().deleteForever();
                          alertController.showSnackBarSucesso(
                            context,
                            "Histórico apagado com sucesso!",
                          );
                        } catch (e) {
                          alertController.showSnackBarError(
                            context,
                            "Erro ao apagar Histórico, tente novamente mais tarde!",
                          );
                          print("Erro ao apagar Histórico: $e");
                        }
                      },
                      btnCancel: () {},
                    )
                    .show();
              },
            ),
            const SizedBox(height: 20),
            _buildSettingItem(
              key: _versaoKey,
              title: 'Versão',
              subtitle: _packageInfo?.version ?? 'error',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required String title,
    String subtitle = '',
    Key? key,
    VoidCallback? onLongPress,
    VoidCallback? onPressed,
  }) {
    // Note que a key do item da lista está no ListTile, não no Text.
    // Para o tutorial funcionar, a key precisa estar no widget que você quer destacar.
    // Vamos mover a key para o Container, que engloba todo o item.
    return InkWell(
      key: key, // Key aplicada aqui
      onTap: onPressed,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.green,
          boxShadow: [
            BoxShadow(
              color: Colors.green.shade900.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (subtitle.isNotEmpty)
              Text(
                subtitle,
                style: const TextStyle(fontSize: 16, color: Colors.white70),
              ),
          ],
        ),
      ),
    );
  }
}