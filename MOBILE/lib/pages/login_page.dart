import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_loginkoavy/api_service.dart';
import 'package:flutter_application_loginkoavy/widgets/custom_text_field.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Página de Login do sistema Koavy.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  final ApiService _apiService = ApiService();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    verificarLogin();
  }

  /// Verifica se já existe uma sessão ativa salva localmente e realiza o auto-login.
  void verificarLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('koavy_token');
    final userJson = prefs.getString('koavy_user');
    
    if (token != null && userJson != null) {
      try {
        final Map<String, dynamic> user = jsonDecode(userJson);
        final int perfilId = user['perfil_id'] ?? user['perfilId'] ?? 1;

        if (!mounted) return;
        if (perfilId == 3) {
          Navigator.pushReplacementNamed(context, '/admin');
        } else if (perfilId == 2) {
          Navigator.pushReplacementNamed(
            context, 
            '/dashboard-tutor',
            arguments: {'userName': user['nome'], 'email': user['email']},
          );
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } catch (e) {
        // Ignora erro e aguarda login manual se o JSON estiver corrompido
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  /// Realiza o fluxo de autenticação tradicional via API PHP.
  void fazerLogin() async {
    if (_formKey.currentState!.validate()) {
      String emailDigitado = emailController.text.trim();
      String senhaDigitada = senhaController.text;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xff00f2ff))),
      );

      try {
        final response = await _apiService.login(emailDigitado, senhaDigitada);
        if (!mounted) return;
        Navigator.pop(context); // Fecha o loading

        if (response.statusCode == 200) {
          final user = response.data['user'];
          final int perfilId = user['perfil_id'] ?? 1;

          if (!mounted) return;
          
          // NAVEGAÇÃO PROFISSIONAL: Usando rotas nomeadas com argumentos
          if (perfilId == 3) {
            Navigator.pushReplacementNamed(context, '/admin');
          } else if (perfilId == 2) {
            Navigator.pushReplacementNamed(
              context, 
              '/dashboard-tutor',
              arguments: {'userName': user['nome'], 'email': user['email']},
            );
          } else {
            Navigator.pushReplacementNamed(context, '/home');
          }
        }
      } on DioException catch (e) {
        if (!mounted) return;
        Navigator.pop(context); // Fecha o loading
        String msg = "E-mail ou senha incorretos.";
        if (e.type == DioExceptionType.connectionTimeout) msg = "Erro de conexão com o servidor.";
        mostrarMensagem("Erro de Acesso", msg);
      }
    }
  }

  /// Realiza a autenticação via Google no Servidor PHP.
  void loginWithGoogle() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xff00f2ff))),
    );

    try {
      // Usamos um token fictício prefixado com mock_ em desenvolvimento local.
      // Em produção, isso integrará com o plugin nativo google_sign_in para obter o token real.
      final response = await _apiService.googleLogin(
        'mock_google_token_12345',
        email: 'google@teste.com',
        name: 'Usuário Google Teste',
      );

      if (!mounted) return;
      Navigator.pop(context); // Fecha o loading

      if (response.statusCode == 200) {
        final user = response.data['user'];
        final int perfilId = user['perfil_id'] ?? 1;

        if (perfilId == 3) {
          Navigator.pushReplacementNamed(context, '/admin');
        } else if (perfilId == 2) {
          Navigator.pushReplacementNamed(
            context, 
            '/dashboard-tutor',
            arguments: {'userName': user['nome'], 'email': user['email']},
          );
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } on DioException catch (_) {
      if (!mounted) return;
      Navigator.pop(context); // Fecha o loading
      mostrarMensagem("Erro no Google Login", "Falha ao sincronizar a sessão com o servidor.");
    }
  }

  /// Abre o modal para redefinição de senha.
  void openForgotModal() {
    final TextEditingController forgotEmailController = TextEditingController();
    final forgotFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xff1a1c1e),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
            side: const BorderSide(color: Colors.white10),
          ),
          content: Form(
            key: forgotFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Recuperar Acesso",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Outfit',
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Enviaremos um link de redefinição para o seu e-mail cadastrado.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 24),
                
                // Input E-mail
                const Text(
                  "SEU E-MAIL",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: forgotEmailController,
                  style: const TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Digite seu e-mail";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "seu@email.com",
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.black.withValues(alpha: 0.4),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Colors.white10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Colors.white10),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Botão Enviar
                ElevatedButton(
                  onPressed: () {
                    if (forgotFormKey.currentState!.validate()) {
                      Navigator.pop(context);
                      mostrarMensagem(
                        "Link Enviado",
                        "Sucesso! Um link de recuperação foi enviado para ${forgotEmailController.text}.\nVerifique sua caixa de entrada.",
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff00f2ff),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text("Enviar Link", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 12),
                
                // Botão Voltar
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Voltar ao Login",
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Exibe um diálogo modal com informações ao usuário.
  void mostrarMensagem(String titulo, String mensagem, {VoidCallback? onConfirm}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xff101010),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: const Color(0xff00f2ff).withValues(alpha: 0.2)),
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
                style: TextStyle(color: Color(0xff00f2ff), fontWeight: FontWeight.bold),
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

    return Scaffold(
      backgroundColor: const Color(0xff0f1011),
      body: Stack(
        children: [
          // Efeitos de gradiente/blur no fundo
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xff00f2ff).withValues(alpha: 0.04),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xff00d4aa).withValues(alpha: 0.04),
              ),
            ),
          ),

          // NAVBAR FIXA NO TOPO
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
              ),
              child: SafeArea(
                bottom: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/welcome');
                      },
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xff00f2ff), Color(0xff00d4aa)],
                              ),
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                            ),
                            child: const Center(
                              child: Text(
                                "K",
                                style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w900),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "Koavy",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              fontFamily: 'Outfit',
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/cadastro-paciente');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text(
                        "Criar Conta",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // FORMULÁRIO DE LOGIN
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 120, bottom: 40),
              child: Container(
                width: screenWidth < 540 ? double.infinity : 500,
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "Bem-vindo",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Outfit',
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Acesse sua conta para continuar.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 40),

                      // Campo de E-mail
                      const Text(
                        "E-MAIL DE ACESSO",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: emailController,
                        hintText: "seu@email.com",
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Por favor, digite seu e-mail";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Campo de Senha
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "SENHA",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          TextButton(
                            onPressed: openForgotModal,
                            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                            child: const Text(
                              "Esqueci a senha",
                              style: TextStyle(color: Color(0xff00f2ff), fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: senhaController,
                        hintText: "••••••••",
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Por favor, digite a senha";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 35),

                      // Botão Entrar
                      SizedBox(
                        height: 60,
                        child: ElevatedButton(
                          onPressed: fazerLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: Ink(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              gradient: const LinearGradient(
                                colors: [Color(0xff00f2ff), Color(0xff00d4aa)],
                              ),
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              child: const Text(
                                "Entrar no Sistema",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Separador
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.05))),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              "OU ENTRE COM",
                              style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.05))),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Google Login Button
                      OutlinedButton(
                        onPressed: loginWithGoogle,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset("assets/images/google.png", width: 20, height: 20),
                            const SizedBox(width: 12),
                            const Text(
                              "Google",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
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
}
