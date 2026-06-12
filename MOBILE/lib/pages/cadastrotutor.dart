// Flutter page for tutor registration (cadastrotutor.dart)
// Implements real API calls to the backend via ApiService.
// Design follows the premium UI style used in the existing patient registration page.

import 'package:flutter/material.dart';
import 'package:flutter_application_loginkoavy/api_service.dart';
import 'package:flutter_application_loginkoavy/pages/interface_page.dart';
import 'package:flutter_application_loginkoavy/pages/login_page.dart';
import 'package:flutter_application_loginkoavy/widgets/custom_navbar.dart';
import 'package:flutter_application_loginkoavy/widgets/custom_text_field.dart';
import 'package:dio/dio.dart';

class CadastroTutorPage extends StatefulWidget {
  const CadastroTutorPage({super.key});

  @override
  State<CadastroTutorPage> createState() => _CadastroTutorPageState();
}

class _CadastroTutorPageState extends State<CadastroTutorPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for input fields
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  final TextEditingController telefoneController = TextEditingController();
  final TextEditingController pacienteIdController = TextEditingController();

  @override
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    senhaController.dispose();
    telefoneController.dispose();
    pacienteIdController.dispose();
    super.dispose();
  }

  /// Submete o cadastro de tutor e vínculo ao paciente via API.
  void _realizarCadastro() async {
    if (_formKey.currentState!.validate()) {
      // Show loading spinner
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: CircularProgressIndicator(color: Colors.cyanAccent),
        ),
      );

      final Map<String, dynamic> vinculo = {
        'nome': nomeController.text.trim(),
        'email': emailController.text.trim(),
        'senha': senhaController.text,
        'telefone': telefoneController.text.trim(),
        'pacienteId': int.tryParse(pacienteIdController.text.trim()),
      };

      try {
        final response = await ApiService().vincularTutor(vinculo);
        if (!mounted) return;
        Navigator.pop(context); // close loading
        if (response.statusCode == 201) {
          mostrarMensagem(
            "Sucesso",
            "Tutor cadastrado e vinculado ao paciente ${vinculo['pacienteId']}!",
            onConfirm: () {
              if (!mounted) return;
              _formKey.currentState!.reset();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          );
        } else {
          mostrarMensagem(
            "Erro",
            response.data['message'] ?? "Falha ao cadastrar tutor.",
          );
        }
      } on DioException catch (e) {
        if (!mounted) return;
        Navigator.pop(context);
        String msg = "Falha no cadastro.";
        if (e.response != null && e.response!.data is Map) {
          msg = e.response!.data['message'] ?? msg;
        } else if (e.type == DioExceptionType.connectionTimeout) {
          msg = "Erro de conexão com o servidor.";
        }
        mostrarMensagem("Erro", msg);
      }
    } else {
      mostrarMensagem("Dados Inválidos", "Corrija os campos destacados antes de continuar.");
    }
  }

  /// Exibe diálogo estilizado para mensagens.
  void mostrarMensagem(String titulo, String mensagem, {VoidCallback? onConfirm}) {
    showDialog(
      context: context,
      builder: (_) {
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
                if (onConfirm != null) onConfirm();
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
    final bool isMobile = screenWidth < 900;

    return Scaffold(
      backgroundColor: const Color(0xff0f1011),
      body: Column(
        children: [
          // Navbar
          CustomNavBar(
            showBackButton: true,
            activeTab: 'Cadastro Tutor',
            onBackTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const InterfacePage()),
              );
            },
            onEntrarTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          ),
          // Form
          Expanded(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isMobile ? 16 : 40),
                child: Center(
                  child: Container(
                    width: 1200,
                    padding: EdgeInsets.all(isMobile ? 20 : 32),
                    decoration: BoxDecoration(
                      color: const Color(0xff16181b),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.cyan.withValues(alpha: 0.2)),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Text(
                            'Cadastro de Tutor',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isMobile ? 24 : 34,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Crie sua conta de tutor e vincule a um paciente',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                          const SizedBox(height: 40),
                          // Form fields section
                          _buildFormSection(
                            isMobile: isMobile,
                            children: [
                              _buildField(
                                controller: nomeController,
                                hint: 'Nome completo',
                                isMobile: isMobile,
                                validator: (v) => v == null || v.trim().isEmpty ? 'Informe o nome' : null,
                              ),
                              _buildField(
                                controller: emailController,
                                hint: 'Email',
                                isMobile: isMobile,
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return 'Informe o email';
                                  final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                                  if (!regex.hasMatch(v.trim())) return 'Email inválido';
                                  return null;
                                },
                              ),
                              _buildField(
                                controller: senhaController,
                                hint: 'Senha',
                                isMobile: isMobile,
                                obscure: true,
                                validator: (v) => v == null || v.length < 6 ? 'Mínimo 6 caracteres' : null,
                              ),
                              _buildField(
                                controller: telefoneController,
                                hint: 'Telefone',
                                isMobile: isMobile,
                                keyboardType: TextInputType.phone,
                                validator: (v) => v == null || v.trim().isEmpty ? 'Informe o telefone' : null,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Paciente ID field
                          _buildFormSection(
                            isMobile: isMobile,
                            children: [
                              _buildField(
                                controller: pacienteIdController,
                                hint: 'ID do Paciente',
                                isMobile: isMobile,
                                keyboardType: TextInputType.number,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return 'Informe o ID do paciente';
                                  if (int.tryParse(v.trim()) == null) return 'ID deve ser numérico';
                                  return null;
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 35),
                          // Submit button
                          SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                padding: EdgeInsets.zero,
                              ),
                              onPressed: _realizarCadastro,
                              child: Ink(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  gradient: const LinearGradient(colors: [Color(0xff22d3ee), Color(0xff34d399)]),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Cadastrar Tutor',
                                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 25),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Já possui conta?', style: TextStyle(color: Colors.grey, fontSize: 14)),
                              TextButton(
                                onPressed: () => Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(builder: (_) => const LoginPage()),
                                ),
                                child: const Text('Entrar', style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper to build responsive sections
  Widget _buildFormSection({required bool isMobile, required List<Widget> children}) {
    if (isMobile) return Column(children: children);
    // Desktop: row with spacing
    final List<Widget> rowChildren = [];
    for (int i = 0; i < children.length; i++) {
      rowChildren.add(Expanded(child: children[i]));
      if (i < children.length - 1) rowChildren.add(const SizedBox(width: 16));
    }
    return Row(children: rowChildren);
  }

  // Helper to build a custom text field
  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required bool isMobile,
    bool obscure = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final field = Padding(
      padding: EdgeInsets.only(bottom: isMobile ? 16 : 0),
      child: CustomTextField(
        controller: controller,
        hintText: hint,
        obscureText: obscure,
        keyboardType: keyboardType,
        useContainerDecoration: true,
        borderRadius: 16,
        validator: validator,
      ),
    );
    return isMobile ? field : Expanded(child: field);
  }
}
