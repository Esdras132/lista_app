import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:lista_de_compras/auth_gate.dart';

class SplashScreenVideo extends StatefulWidget {
  const SplashScreenVideo({super.key});

  @override
  State<SplashScreenVideo> createState() => _SplashScreenVideoState();
}

class _SplashScreenVideoState extends State<SplashScreenVideo> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    // Aponta o controller para o vídeo na pasta assets
    _controller = VideoPlayerController.asset('assets/splash_final.mp4')
      ..initialize().then((_) {
        // Garante que a UI seja reconstruída com o primeiro frame do vídeo
        setState(() {});
        // Inicia a reprodução do vídeo
        _controller.play();
      });

    // Adiciona um "ouvinte" para saber quando o vídeo termina
    _controller.addListener(() {
      // Se a posição atual do vídeo for igual à sua duração total
      if (_controller.value.position == _controller.value.duration) {
        _navigateToHome();
      }
    });
  }

  void _navigateToHome() {
    // Navega para a próxima tela substituindo a tela de splash.
    // Isso impede que o usuário volte para o vídeo ao apertar o botão "voltar".
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => AuthGate()),
    );
  }

  @override
  void dispose() {
    // Libera os recursos do controller quando a tela é destruída
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Cor de fundo enquanto o vídeo carrega
      body: Center(
        // Verifica se o vídeo já foi inicializado
        child: _controller.value.isInitialized
            ? AspectRatio(
                // Mantém a proporção original do vídeo
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const CircularProgressIndicator(), // Mostra um loading enquanto o vídeo carrega
      ),
    );
  }
}