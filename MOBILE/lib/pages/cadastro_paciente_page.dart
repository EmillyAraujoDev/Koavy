import 'package:flutter/material.dart';
import 'package:flutter_application_loginkoavy/widgets/custom_navbar.dart';
import 'package:flutter_application_loginkoavy/widgets/custom_text_field.dart';
import 'package:flutter_application_loginkoavy/api_service.dart';
import 'package:dio/dio.dart';

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

  /// Realiza as validações e submete o cadastro do paciente via API.
  Future<void> realizarCadastro() async {
    if (!_formKey.currentState!.validate()) {
      mostrarMensagem(
<<<<<<< HEAD
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
=======
        'Dados Inválidos',
        'Por favor, corrija os erros no formulário antes de continuar.',
>>>>>>> c3ddca26d8b70f1dc0598fe5875b7f961c21046f
      );
      return;
    }

    if (dataNascimento == null) {
      mostrarMensagem('Aviso', 'Por favor, selecione sua data de nascimento.');
      return;
    }

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Colors.cyanAccent),
      ),
    );

    final String dataNascStr =
        '${dataNascimento!.year}-'
        '${dataNascimento!.month.toString().padLeft(2, '0')}-'
        '${dataNascimento!.day.toString().padLeft(2, '0')}';

    String sexo = 'O';
    final sexoLower = sexoController.text.trim().toLowerCase();
    if (sexoLower.startsWith('m')) sexo = 'M';
    if (sexoLower.startsWith('f')) sexo = 'F';

    final Map<String, dynamic> usuario = {
      'perfilId': 1,
      'nome': nomeController.text.trim(),
      'email': emailController.text.trim(),
      'senha': senhaController.text,
      'telefone': telefoneController.text.trim(),
      'idade': int.tryParse(idadeController.text.trim()),
      'dataNascimento': dataNascStr,
      'sexo': sexo,
      'peso': double.tryParse(pesoController.text.trim().replaceAll(',', '.')),
      'altura': () {
        final v = double.tryParse(alturaController.text.trim());
        return v != null ? v / 100.0 : null;
      }(),
      'tipoSanguineo': tipoSanguineoController.text.trim().toUpperCase(),
      'marcapasso': marcapassoController.text.trim().toLowerCase() == 'sim',
      'cep': cepController.text.trim(),
      'obsMed': obsMedController.text.trim(),
    };

    try {
      final response = await ApiService().cadastrarPaciente(usuario);

      if (!mounted) return;
      Navigator.pop(context); // Fechar loading

      if (response.statusCode == 201) {
        final newId = response.data['id'];
        mostrarMensagem(
          'Sucesso',
          'Paciente cadastrado com sucesso!\n\nSeu ID de paciente é: $newId\n'
              'Guarde este ID para vincular seu tutor.',
          onConfirm: () {
            if (!mounted) return;
            _formKey.currentState!.reset();
            setState(() => dataNascimento = null);
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const LoginPage()),
            );
          },
        );
      } else {
        mostrarMensagem(
          'Erro',
          response.data['message'] ?? 'Erro ao realizar cadastro.',
        );
      }
    } on DioException catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Fechar loading

      String msg = 'Falha no cadastro.';
      if (e.response?.data is Map) {
        msg = e.response!.data['message'] ?? msg;
      } else {
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.sendTimeout:
          case DioExceptionType.receiveTimeout:
            msg = 'Tempo de conexão esgotado. Tente novamente.';
            break;
          case DioExceptionType.connectionError:
            msg = 'Sem conexão com o servidor. Verifique sua internet.';
            break;
          case DioExceptionType.badResponse:
            msg = 'Resposta inválida do servidor (${e.response?.statusCode}).';
            break;
          default:
            msg = 'Erro inesperado. Tente novamente.';
        }
      }
      mostrarMensagem('Erro', msg);
    }
  }

  /// Exibe uma janela de alerta estilizada.
  void mostrarMensagem(
    String titulo,
    String mensagem, {
    VoidCallback? onConfirm,
  }) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xff16181b),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.cyan.withOpacity(0.2)),
        ),
        title: Text(
          titulo,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          mensagem,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm?.call();
            },
            child: const Text(
              'OK',
              style: TextStyle(
                color: Colors.cyanAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
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
<<<<<<< HEAD
              Navigator.pushReplacementNamed(context, '/welcome');
            },
            onEntrarTap: () {
              Navigator.pushReplacementNamed(context, '/login');
=======
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const InterfacePage()),
              );
            },
            onEntrarTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
>>>>>>> c3ddca26d8b70f1dc0598fe5875b7f961c21046f
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
                        color: Colors.cyan.withOpacity(0.2),
                      ),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Cabeçalho
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
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                          const SizedBox(height: 40),

                          // LINHA 1 — Nome, Email, Senha, Telefone
                          _buildFormSection(
                            isMobile: isMobile,
                            children: [
                              _buildField(
                                controller: nomeController,
                                hint: 'Nome completo',
                                isMobile: isMobile,
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Digite seu nome';
                                  }
                                  if (val.trim().split(' ').length < 2) {
                                    return 'Digite o nome completo';
                                  }
                                  return null;
                                },
                              ),
                              _buildField(
                                controller: emailController,
                                hint: 'Email',
                                isMobile: isMobile,
                                keyboardType: TextInputType.emailAddress,
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Digite seu email';
                                  }
                                  final emailRegex =
                                      RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                                  if (!emailRegex.hasMatch(val.trim())) {
                                    return 'Email inválido';
                                  }
                                  return null;
                                },
                              ),
                              _buildField(
                                controller: senhaController,
                                hint: 'Senha',
                                isMobile: isMobile,
                                obscure: true,
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return 'Digite uma senha';
                                  }
                                  if (val.length < 6) {
                                    return 'Mínimo de 6 caracteres';
                                  }
                                  return null;
                                },
                              ),
                              _buildField(
                                controller: telefoneController,
                                hint: 'Telefone',
                                isMobile: isMobile,
                                keyboardType: TextInputType.phone,
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Digite seu telefone';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),

                          SizedBox(height: isMobile ? 0 : 20),

                          // LINHA 2 — Idade, Peso, Altura, Sexo
                          _buildFormSection(
                            isMobile: isMobile,
                            children: [
                              _buildField(
                                controller: idadeController,
                                hint: 'Idade',
                                isMobile: isMobile,
                                keyboardType: TextInputType.number,
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Obrigatório';
                                  }
                                  final n = int.tryParse(val.trim());
                                  if (n == null || n <= 0) return 'Inválido';
                                  return null;
                                },
                              ),
                              _buildField(
                                controller: pesoController,
                                hint: 'Peso (kg)',
                                isMobile: isMobile,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Obrigatório';
                                  }
                                  final n = double.tryParse(
                                    val.trim().replaceAll(',', '.'),
                                  );
                                  if (n == null || n <= 0) return 'Inválido';
                                  return null;
                                },
                              ),
                              _buildField(
                                controller: alturaController,
                                hint: 'Altura (cm)',
                                isMobile: isMobile,
                                keyboardType: TextInputType.number,
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Obrigatório';
                                  }
                                  final n = int.tryParse(val.trim());
                                  if (n == null || n <= 0) return 'Inválido';
                                  return null;
                                },
                              ),
                              _buildField(
                                controller: sexoController,
                                hint: 'Sexo (M/F)',
                                isMobile: isMobile,
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Obrigatório';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),

                          SizedBox(height: isMobile ? 0 : 20),

                          // LINHA 3 — Tipo Sanguíneo, Marcapasso, CEP, Obs.
                          _buildFormSection(
                            isMobile: isMobile,
                            children: [
                              _buildField(
                                controller: tipoSanguineoController,
                                hint: 'Tipo Sanguíneo',
                                isMobile: isMobile,
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Obrigatório';
                                  }
                                  return null;
                                },
                              ),
                              _buildField(
                                controller: marcapassoController,
                                hint: 'Marcapasso (sim/não)',
                                isMobile: isMobile,
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Obrigatório';
                                  }
                                  final low = val.trim().toLowerCase();
                                  if (low != 'sim' &&
                                      low != 'não' &&
                                      low != 'nao') {
                                    return 'Digite sim ou não';
                                  }
                                  return null;
                                },
                              ),
                              _buildField(
                                controller: cepController,
                                hint: 'CEP',
                                isMobile: isMobile,
                                keyboardType: TextInputType.number,
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Obrigatório';
                                  }
                                  return null;
                                },
                              ),
                              _buildField(
                                controller: obsMedController,
                                hint: 'Observações médicas',
                                isMobile: isMobile,
                                // Campo opcional
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
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime(2000),
                                    firstDate: DateTime(1900),
                                    lastDate: DateTime.now(),
                                    builder: (context, child) {
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          colorScheme:
                                              const ColorScheme.dark(
                                            primary: Colors.cyanAccent,
                                            onPrimary: Colors.black,
                                            surface: Color(0xff16181b),
                                            onSurface: Colors.white,
<<<<<<< HEAD
                                          ), dialogTheme: DialogThemeData(backgroundColor: const Color(0xff0f1011)),
=======
                                          ),
                                          dialogTheme: const DialogThemeData(
                                            backgroundColor: Color(0xff0f1011),
                                          ),
>>>>>>> c3ddca26d8b70f1dc0598fe5875b7f961c21046f
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (picked != null) {
                                    setState(() => dataNascimento = picked);
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
                                    border: Border.all(color: Colors.white10),
                                  ),
                                  child: Text(
                                    dataNascimento == null
                                        ? 'Selecionar data'
                                        : '${dataNascimento!.day.toString().padLeft(2, '0')}/'
                                            '${dataNascimento!.month.toString().padLeft(2, '0')}/'
                                            '${dataNascimento!.year}',
                                    style: const TextStyle(color: Colors.white),
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
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 14),
                              ),
                              TextButton(
                                onPressed: () {
<<<<<<< HEAD
                                  Navigator.pushReplacementNamed(context, '/cadastro-tutor');
=======
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (_) => const CadastroTutorPage(),
                                    ),
                                  );
>>>>>>> c3ddca26d8b70f1dc0598fe5875b7f961c21046f
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

  /// Seção do formulário: Row no desktop, Column no mobile.
  Widget _buildFormSection({
    required bool isMobile,
    required List<Widget> children,
  }) {
    if (isMobile) {
      return Column(children: children);
    }
    return Row(
      children: [
        for (int i = 0; i < children.length; i++) ...[
          children[i],
          if (i < children.length - 1) const SizedBox(width: 16),
        ],
      ],
    );
  }

  /// Campo de texto configurado para o formulário.
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
<<<<<<< HEAD

    if (isMobile) {
      return textFieldWidget;
    } else {
      return Expanded(child: textFieldWidget);
    }
=======
    return isMobile ? field : Expanded(child: field);
>>>>>>> c3ddca26d8b70f1dc0598fe5875b7f961c21046f
  }
}