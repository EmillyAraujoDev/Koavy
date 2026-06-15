import 'package:flutter/material.dart';
import 'package:flutter_application_loginkoavy/widgets/custom_navbar.dart';
import 'package:flutter_application_loginkoavy/widgets/custom_text_field.dart';

/// Página de Cadastro de Paciente Cardíaco.
class CadastroPacientePage extends StatefulWidget {
  const CadastroPacientePage({super.key});

  @override
  State<CadastroPacientePage> createState() => _CadastroPacientePageState();
}

class _CadastroPacientePageState extends State<CadastroPacientePage> {
  final _formKey = GlobalKey<FormState>();

  // Controladores dos campos
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  final TextEditingController telefoneController = TextEditingController();
  final TextEditingController idadeController = TextEditingController();
  final TextEditingController pesoController = TextEditingController();
  final TextEditingController alturaController = TextEditingController();
  final TextEditingController sexoController = TextEditingController();
  final TextEditingController tipoSanguineoController = TextEditingController();
  final TextEditingController marcapassoController = TextEditingController();
  final TextEditingController cepController = TextEditingController();
  final TextEditingController obsMedController = TextEditingController();

  DateTime? dataNascimento;

  @override
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    senhaController.dispose();
    telefoneController.dispose();
    idadeController.dispose();
    pesoController.dispose();
    alturaController.dispose();
    sexoController.dispose();
    tipoSanguineoController.dispose();
    marcapassoController.dispose();
    cepController.dispose();
    obsMedController.dispose();
    super.dispose();
  }

  /// Realiza as validações e submete o cadastro do paciente.
  void realizarCadastro() {
    if (_formKey.currentState!.validate()) {
      if (dataNascimento == null) {
        mostrarMensagem("Aviso", "Por favor, selecione sua data de nascimento.");
        return;
      }

      // Simula o sucesso do cadastro
      mostrarMensagem(
        "Sucesso",
        "Paciente cadastrado com sucesso!\n\nDados salvos para ${nomeController.text}.",
        onConfirm: () {
          // Limpa o formulário e navega de volta para a tela inicial
          _formKey.currentState!.reset();
          setState(() {
            dataNascimento = null;
          });
          Navigator.pushReplacementNamed(context, '/welcome');
        },
      );
    } else {
      mostrarMensagem("Dados Inválidos", "Por favor, corrija os erros no formulário antes de continuar.");
    }
  }

  /// Exibe uma janela de alerta estilizada.
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
    final bool isMobile = screenWidth < 900;

    return Scaffold(
      backgroundColor: const Color(0xff0f1011),
      body: Column(
        children: [
          // ================= NAVBAR =================
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

          // ================= FORMULÁRIO =================
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
                      border: Border.all(
                        color: Colors.cyan.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Cabeçalho do formulário
                          Text(
                            'Cadastro do Paciente Cardíaco',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isMobile ? 24 : 34,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Monitoramento inteligente e seguro Koavy',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 40),

                          // LINHA 1 (Nome, Email, Senha, Telefone)
                          _buildFormSection(
                            isMobile: isMobile,
                            children: [
                              _buildField(
                                controller: nomeController,
                                hint: 'Nome completo',
                                isMobile: isMobile,
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) return 'Digite seu nome';
                                  if (val.trim().split(' ').length < 2) return 'Digite o nome completo';
                                  return null;
                                },
                              ),
                              _buildField(
                                controller: emailController,
                                hint: 'Email',
                                isMobile: isMobile,
                                keyboardType: TextInputType.emailAddress,
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) return 'Digite seu email';
                                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                                  if (!emailRegex.hasMatch(val.trim())) return 'Email inválido';
                                  return null;
                                },
                              ),
                              _buildField(
                                controller: senhaController,
                                hint: 'Senha',
                                isMobile: isMobile,
                                obscure: true,
                                validator: (val) {
                                  if (val == null || val.isEmpty) return 'Digite uma senha';
                                  if (val.length < 6) return 'Mínimo de 6 caracteres';
                                  return null;
                                },
                              ),
                              _buildField(
                                controller: telefoneController,
                                hint: 'Telefone',
                                isMobile: isMobile,
                                keyboardType: TextInputType.phone,
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) return 'Digite seu telefone';
                                  return null;
                                },
                              ),
                            ],
                          ),

                          SizedBox(height: isMobile ? 0 : 20),

                          // LINHA 2 (Idade, Peso, Altura, Sexo)
                          _buildFormSection(
                            isMobile: isMobile,
                            children: [
                              _buildField(
                                controller: idadeController,
                                hint: 'Idade',
                                isMobile: isMobile,
                                keyboardType: TextInputType.number,
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) return 'Obrigatório';
                                  final numVal = int.tryParse(val.trim());
                                  if (numVal == null || numVal <= 0) return 'Inválido';
                                  return null;
                                },
                              ),
                              _buildField(
                                controller: pesoController,
                                hint: 'Peso (kg)',
                                isMobile: isMobile,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) return 'Obrigatório';
                                  final numVal = double.tryParse(val.trim().replaceAll(',', '.'));
                                  if (numVal == null || numVal <= 0) return 'Inválido';
                                  return null;
                                },
                              ),
                              _buildField(
                                controller: alturaController,
                                hint: 'Altura (cm)',
                                isMobile: isMobile,
                                keyboardType: TextInputType.number,
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) return 'Obrigatório';
                                  final numVal = int.tryParse(val.trim());
                                  if (numVal == null || numVal <= 0) return 'Inválido';
                                  return null;
                                },
                              ),
                              _buildField(
                                controller: sexoController,
                                hint: 'Sexo',
                                isMobile: isMobile,
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) return 'Obrigatório';
                                  return null;
                                },
                              ),
                            ],
                          ),

                          SizedBox(height: isMobile ? 0 : 20),

                          // LINHA 3 (Tipo Sanguíneo, Marcapasso, CEP, Observações médicas)
                          _buildFormSection(
                            isMobile: isMobile,
                            children: [
                              _buildField(
                                controller: tipoSanguineoController,
                                hint: 'Tipo Sanguíneo',
                                isMobile: isMobile,
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) return 'Obrigatório';
                                  return null;
                                },
                              ),
                              _buildField(
                                controller: marcapassoController,
                                hint: 'Marcapasso (sim/não)',
                                isMobile: isMobile,
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) return 'Obrigatório';
                                  final low = val.trim().toLowerCase();
                                  if (low != 'sim' && low != 'não' && low != 'nao') return 'Digite sim/não';
                                  return null;
                                },
                              ),
                              _buildField(
                                controller: cepController,
                                hint: 'CEP',
                                isMobile: isMobile,
                                keyboardType: TextInputType.number,
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) return 'Obrigatório';
                                  return null;
                                },
                              ),
                              _buildField(
                                controller: obsMedController,
                                hint: 'Observações médicas',
                                isMobile: isMobile,
                                validator: (val) {
                                  // Campo opcional
                                  return null;
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // DATA DE NASCIMENTO
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Data de nascimento',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              InkWell(
                                onTap: () async {
                                  DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime(2000),
                                    firstDate: DateTime(1900),
                                    lastDate: DateTime.now(),
                                    builder: (context, child) {
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          colorScheme: const ColorScheme.dark(
                                            primary: Colors.cyanAccent,
                                            onPrimary: Colors.black,
                                            surface: Color(0xff16181b),
                                            onSurface: Colors.white,
                                          ), dialogTheme: DialogThemeData(backgroundColor: const Color(0xff0f1011)),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );

                                  if (picked != null) {
                                    setState(() {
                                      dataNascimento = picked;
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
                                    dataNascimento == null
                                        ? 'Selecionar data'
                                        : '${dataNascimento!.day.toString().padLeft(2, '0')}/${dataNascimento!.month.toString().padLeft(2, '0')}/${dataNascimento!.year}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 35),

                          // BOTÃO CADASTRAR
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
                                      Color(0xff22d3ee),
                                      Color(0xff34d399),
                                    ],
                                  ),
                                ),
                                child: Container(
                                  alignment: Alignment.center,
                                  child: const Text(
                                    'Cadastrar Paciente',
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
                          const SizedBox(height: 25),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Não é um paciente?',
                                style: TextStyle(color: Colors.grey, fontSize: 14),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushReplacementNamed(context, '/cadastro-tutor');
                                },
                                child: const Text(
                                  'Cadastrar como Tutor',
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
    );
  }

  /// Construtor auxiliar de seções do formulário (comporta-se como Row no Desktop e Column no Mobile).
  Widget _buildFormSection({required bool isMobile, required List<Widget> children}) {
    if (isMobile) {
      return Column(
        children: children,
      );
    } else {
      List<Widget> rowChildren = [];
      for (int i = 0; i < children.length; i++) {
        rowChildren.add(children[i]);
        if (i < children.length - 1) {
          rowChildren.add(const SizedBox(width: 16));
        }
      }
      return Row(
        children: rowChildren,
      );
    }
  }

  /// Cria um campo de texto CustomTextField configurado para o formulário.
  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required bool isMobile,
    bool obscure = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final Widget textFieldWidget = Padding(
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

    if (isMobile) {
      return textFieldWidget;
    } else {
      return Expanded(child: textFieldWidget);
    }
  }
}
