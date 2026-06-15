import 'package:flutter/material.dart';
import 'package:flutter_application_loginkoavy/widgets/custom_navbar.dart';
import 'package:flutter_application_loginkoavy/widgets/custom_text_field.dart';

/// Página de Cadastro de Tutor (Vínculo com Paciente) do sistema Koavy.
class CadastroTutorPage extends StatefulWidget {
  const CadastroTutorPage({super.key});

  @override
  State<CadastroTutorPage> createState() => _CadastroTutorPageState();
}

class _CadastroTutorPageState extends State<CadastroTutorPage> {
  final _formKey = GlobalKey<FormState>();

  // Controladores dos campos
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController pacienteIdController = TextEditingController();

  DateTime? dataVinculo;

  @override
  void dispose() {
    nomeController.dispose();
    pacienteIdController.dispose();
    super.dispose();
  }

  /// Realiza as validações e submete o vínculo de tutor.
  void realizarCadastro() {
    if (_formKey.currentState!.validate()) {
      if (dataVinculo == null) {
        mostrarMensagem("Aviso", "Por favor, selecione a data do vínculo.");
        return;
      }

      // Exibe diálogo de sucesso simulando a API
      mostrarMensagem(
        "Sucesso",
        "Vínculo como Tutor realizado com sucesso!\n\nVocê está vinculado ao Paciente ID #${pacienteIdController.text}.",
        onConfirm: () {
          // Limpa o formulário e redireciona para a página principal
          _formKey.currentState!.reset();
          setState(() {
            dataVinculo = null;
          });
          Navigator.pushReplacementNamed(context, '/welcome');
        },
      );
    } else {
      mostrarMensagem("Dados Inválidos", "Por favor, preencha todos os campos corretamente.");
    }
  }

  /// Exibe uma caixa de diálogo estilizada
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
    final bool isMobile = screenWidth < 800;

    return Scaffold(
      backgroundColor: const Color(0xff050505),
      body: Stack(
        children: [
          // Efeitos de gradiente/blur de fundo
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xff00f2ff).withValues(alpha: 0.05),
              ),
            ),
          ),
          
          Column(
            children: [
              // NAVBAR
              CustomNavBar(
                showBackButton: true,
                activeTab: 'Cadastro',
                onBackTap: () {
                  Navigator.pushReplacementNamed(context, '/welcome');
                },
                onEntrarTap: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),

              // CONTEÚDO DO FORMULÁRIO
              Expanded(
                child: SafeArea(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(isMobile ? 16 : 40),
                    child: Center(
                      child: Container(
                        width: 700,
                        padding: EdgeInsets.all(isMobile ? 24 : 48),
                        decoration: BoxDecoration(
                          color: const Color(0xff111418).withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(40),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Cabeçalho
                              const Text(
                                'Cadastro de Tutor',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 34,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Outfit',
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Vincule-se a um paciente para monitorar sua saúde em tempo real.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 40),

                              // Campo: Nome do Tutor
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Seu Nome Completo'.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              CustomTextField(
                                controller: nomeController,
                                hintText: 'Como devemos te chamar?',
                                useContainerDecoration: true,
                                borderRadius: 16,
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Por favor, digite seu nome completo';
                                  }
                                  if (val.trim().split(' ').length < 2) {
                                    return 'Digite pelo menos nome e sobrenome';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),

                              // Seção Responsiva: ID do Paciente e Data do Vínculo
                              _buildResponsiveRow(
                                isMobile: isMobile,
                                children: [
                                  // Campo: ID do Paciente
                                  Expanded(
                                    flex: isMobile ? 0 : 1,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'ID do Paciente'.toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 2,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        CustomTextField(
                                          controller: pacienteIdController,
                                          hintText: 'Ex: 123',
                                          keyboardType: TextInputType.number,
                                          useContainerDecoration: true,
                                          borderRadius: 16,
                                          validator: (val) {
                                            if (val == null || val.trim().isEmpty) {
                                              return 'Digite o ID do paciente';
                                            }
                                            if (int.tryParse(val.trim()) == null) {
                                              return 'Apenas números';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 4),
                                        const Text(
                                          'Peça o ID ao paciente cadastrado.',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  if (!isMobile) const SizedBox(width: 20),
                                  if (isMobile) const SizedBox(height: 24),

                                  // Campo: Data do Vínculo
                                  Expanded(
                                    flex: isMobile ? 0 : 1,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Data do Vínculo'.toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 2,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        InkWell(
                                          onTap: () async {
                                            DateTime? picked = await showDatePicker(
                                              context: context,
                                              initialDate: DateTime.now(),
                                              firstDate: DateTime(2000),
                                              lastDate: DateTime.now(),
                                              builder: (context, child) {
                                                return Theme(
                                                  data: Theme.of(context).copyWith(
                                                    colorScheme: const ColorScheme.dark(
                                                      primary: Colors.cyanAccent,
                                                      onPrimary: Colors.black,
                                                      surface: Color(0xff16181b),
                                                      onSurface: Colors.white,
                                                    ), dialogTheme: const DialogThemeData(backgroundColor: Color(0xff0f1011)),
                                                  ),
                                                  child: child!,
                                                );
                                              },
                                            );

                                            if (picked != null) {
                                              setState(() {
                                                dataVinculo = picked;
                                              });
                                            }
                                          },
                                          child: Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 18,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xff1d1f23),
                                              borderRadius: BorderRadius.circular(16),
                                              border: Border.all(
                                                color: Colors.white10,
                                              ),
                                            ),
                                            child: Text(
                                              dataVinculo == null
                                                  ? 'Selecionar data'
                                                  : '${dataVinculo!.day.toString().padLeft(2, '0')}/${dataVinculo!.month.toString().padLeft(2, '0')}/${dataVinculo!.year}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 15),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 40),

                              // Botão principal: Vincular como Tutor
                              SizedBox(
                                width: double.infinity,
                                height: 60,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                  onPressed: realizarCadastro,
                                  child: Ink(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(18),
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xff00f2ff),
                                          Color(0xff00d4aa),
                                        ],
                                      ),
                                    ),
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: const Text(
                                        'Vincular como Tutor',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 30),

                              // Link alternativo de cadastro de paciente
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Você é o paciente?',
                                    style: TextStyle(color: Colors.grey, fontSize: 14),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushReplacementNamed(context, '/cadastro-paciente');
                                    },
                                    child: const Text(
                                      'Cadastrar como Paciente',
                                      style: TextStyle(
                                        color: Colors.cyanAccent,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
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
        ],
      ),
    );
  }

  Widget _buildResponsiveRow({required bool isMobile, required List<Widget> children}) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children.map((w) {
          if (w is Expanded) return w.child;
          return w;
        }).toList(),
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      );
    }
  }
}
