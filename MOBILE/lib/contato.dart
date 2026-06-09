import 'package:flutter/material.dart';
import 'package:flutter_application_loginkoavy/pages/interface_page.dart';
import 'package:flutter_application_loginkoavy/pages/login_page.dart';
import 'package:flutter_application_loginkoavy/widgets/custom_navbar.dart';
import 'package:flutter_application_loginkoavy/widgets/custom_text_field.dart';

/// Página de Contato (Fale Conosco) do sistema Koavy.
class ContatoPage extends StatefulWidget {
  const ContatoPage({super.key});

  @override
  State<ContatoPage> createState() => _ContatoPageState();
}

class _ContatoPageState extends State<ContatoPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nomeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mensagemController = TextEditingController();

  String assuntoSelecionado = 'Dúvidas Gerais';
  final List<String> assuntos = ['Dúvidas Gerais', 'Suporte Técnico', 'Comercial'];

  @override
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    mensagemController.dispose();
    super.dispose();
  }

  /// Processa e valida o formulário de contato.
  void enviarMensagem() {
    if (_formKey.currentState!.validate()) {
      mostrarMensagem(
        "Mensagem Enviada",
        "Obrigado pelo seu contato, ${nomeController.text}!\n\nNossa equipe responderá sua mensagem sobre '$assuntoSelecionado' no e-mail fornecido.",
        onConfirm: () {
          // Limpa campos
          nomeController.clear();
          emailController.clear();
          mensagemController.clear();
          setState(() {
            assuntoSelecionado = 'Dúvidas Gerais';
          });
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const InterfacePage(),
            ),
          );
        },
      );
    } else {
      mostrarMensagem("Aviso", "Por favor, preencha os campos obrigatórios corretamente.");
    }
  }

  void mostrarMensagem(String titulo, String mensagem, {VoidCallback? onConfirm}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xff16181b),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.cyan.withValues(alpha: 0.2)),
          ),
          title: Text(
            titulo,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(
            mensagem,
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (onConfirm != null) {
                  onConfirm();
                }
              },
              child: const Text(
                "OK",
                style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 950;

    return Scaffold(
      backgroundColor: const Color(0xff050505),
      body: Column(
        children: [
          // NAVBAR
          CustomNavBar(
            showBackButton: true,
            activeTab: 'Contato',
            onBackTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const InterfacePage(),
                ),
              );
            },
            onEntrarTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const LoginPage(),
                ),
              );
            },
          ),

          // CONTEÚDO PRINCIPAL
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 60,
                vertical: isMobile ? 30 : 60,
              ),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: isMobile
                      ? Column(
                          children: [
                            _buildInfoSection(isMobile),
                            const SizedBox(height: 40),
                            _buildFormCard(isMobile),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildInfoSection(isMobile)),
                            const SizedBox(width: 60),
                            Expanded(child: _buildFormCard(isMobile)),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(bool isMobile) {
    return Column(
      crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: isMobile ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            const Text(
              "Fale ",
              style: TextStyle(
                color: Colors.white,
                fontSize: 42,
                fontWeight: FontWeight.w900,
                fontFamily: 'Outfit',
              ),
            ),
            ShaderMask(
              shaderCallback: (bounds) {
                return const LinearGradient(
                  colors: [Color(0xff00f2ff), Color(0xff00d4aa)],
                ).createShader(bounds);
              },
              child: const Text(
                "Conosco",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Outfit',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          "Estamos aqui para ajudar. Se você tem dúvidas sobre a plataforma, planos para empresas ou suporte técnico, preencha o formulário.",
          textAlign: isMobile ? TextAlign.center : TextAlign.start,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 18,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 40),
        
        // Card de E-mail
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.cyan.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.email,
                  color: Colors.cyanAccent,
                ),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'E-mail',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'contato@koavy.com',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 24 : 40),
      decoration: BoxDecoration(
        color: const Color(0xff111418).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Linha Responsiva: Nome e E-mail
            isMobile
                ? Column(
                    children: [
                      _buildFieldLabel('Nome'),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: nomeController,
                        hintText: 'Seu nome',
                        useContainerDecoration: true,
                        borderRadius: 16,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Digite seu nome';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildFieldLabel('E-mail'),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: emailController,
                        hintText: 'seu@email.com',
                        keyboardType: TextInputType.emailAddress,
                        useContainerDecoration: true,
                        borderRadius: 16,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Digite seu e-mail';
                          final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                          if (!emailRegex.hasMatch(val.trim())) return 'E-mail inválido';
                          return null;
                        },
                      ),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel('Nome'),
                            const SizedBox(height: 8),
                            CustomTextField(
                              controller: nomeController,
                              hintText: 'Seu nome',
                              useContainerDecoration: true,
                              borderRadius: 16,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) return 'Digite seu nome';
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel('E-mail'),
                            const SizedBox(height: 8),
                            CustomTextField(
                              controller: emailController,
                              hintText: 'seu@email.com',
                              keyboardType: TextInputType.emailAddress,
                              useContainerDecoration: true,
                              borderRadius: 16,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) return 'Digite seu e-mail';
                                final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                                if (!emailRegex.hasMatch(val.trim())) return 'E-mail inválido';
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
            const SizedBox(height: 20),

            // Dropdown: Assunto
            _buildFieldLabel('Assunto'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xff1d1f23),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButtonFormField<String>(
                  value: assuntoSelecionado,
                  dropdownColor: const Color(0xff16181b),
                  decoration: const InputDecoration(border: InputBorder.none),
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                  items: assuntos.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      assuntoSelecionado = newValue!;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Textarea: Mensagem
            _buildFieldLabel('Mensagem'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xff1d1f23),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: TextFormField(
                controller: mensagemController,
                maxLines: 5,
                style: const TextStyle(color: Colors.white),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Digite sua mensagem';
                  return null;
                },
                decoration: const InputDecoration(
                  hintText: 'Como podemos ajudar?',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(20),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Botão Enviar Mensagem
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: enviarMensagem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  shadowColor: Colors.cyanAccent.withValues(alpha: 0.3),
                  elevation: 10,
                ),
                child: const Text(
                  'Enviar Mensagem',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String labelText) {
    return Text(
      labelText.toUpperCase(),
      style: const TextStyle(
        color: Colors.grey,
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
      ),
    );
  }
}
