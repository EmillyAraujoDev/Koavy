import 'package:flutter/material.dart';
import 'package:flutter_application_loginkoavy/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class RecuperarSenhaPage extends StatefulWidget {
  const RecuperarSenhaPage({super.key});

  @override
  State<RecuperarSenhaPage> createState() => _RecuperarSenhaPageState();
}

class _RecuperarSenhaPageState extends State<RecuperarSenhaPage> {
  final TextEditingController emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  bool isLoading = false;

  void enviarEmailRecuperacao() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        final response = await _apiService.recuperarSenha(
          emailController.text.trim(),
        );

        if (!mounted) return;
        setState(() {
          isLoading = false;
        });

        if (response.statusCode == 200) {
          final String message = response.data['message'] ?? 'Solicitação de recuperação processada!';
          final String? link = response.data['link'];

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: const Color(0xff16181b),
              title: const Text("Recuperação de Senha", style: TextStyle(color: Colors.white)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    message,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  if (link != null) ...[
                    const SizedBox(height: 16),
                    const Text(
                      "Modo de Compatibilidade / Teste TCC:",
                      style: TextStyle(color: Color(0xff00f2ff), fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff00f2ff),
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () async {
                        final Uri url = Uri.parse(link);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        }
                      },
                      child: const Text("Redefinir no Navegador"),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // fecha dialog
                    Navigator.pop(context); // volta para login
                  },
                  child: const Text("OK", style: TextStyle(color: Color(0xff00f2ff))),
                ),
              ],
            ),
          );
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: const Color(0xff16181b),
              title: const Text("Erro", style: TextStyle(color: Colors.redAccent)),
              content: Text(response.data['message'] ?? "Erro ao processar solicitação", style: const TextStyle(color: Colors.white70)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK", style: TextStyle(color: Color(0xff00f2ff))),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        setState(() {
          isLoading = false;
        });
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xff16181b),
            title: const Text("Erro de Conexão", style: TextStyle(color: Colors.redAccent)),
            content: Text("Ocorreu um erro ao conectar: $e", style: const TextStyle(color: Colors.white70)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK", style: TextStyle(color: Color(0xff00f2ff))),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0f1011),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.lock_reset,
                size: 80,
                color: Color(0xff00f2ff),
              ),
              const SizedBox(height: 24),
              const Text(
                "Recuperar Acesso",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Enviaremos um link de redefinição para o seu e-mail cadastrado.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: emailController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: "seu@email.com",
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.email, color: Color(0xff00f2ff)),
                    filled: true,
                    fillColor: Colors.black.withValues(alpha: 0.4),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Colors.white10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xff00f2ff)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, informe seu e-mail';
                    }
                    if (!value.contains('@')) {
                      return 'Por favor, informe um e-mail válido';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading ? null : enviarEmailRecuperacao,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text(
                          "ENVIAR LINK",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
