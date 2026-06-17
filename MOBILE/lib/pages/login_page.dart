import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_loginkoavy/api_service.dart';
import 'package:flutter_application_loginkoavy/widgets/custom_text_field.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
          Navigator.pushReplacementNamed(context, '/dashboard-paciente', arguments: {'userName': user['nome'], 'email': user['email']});
        }
      } catch (_) {
        // Ignora erro
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  void fazerLogin() async {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xff00f2ff))),
      );

      try {
        final response = await _apiService.login(emailController.text.trim(), senhaController.text);
        if (!mounted) return;
        Navigator.pop(context);

        if (response.statusCode == 200) {
          final user = response.data['user'];
          final int perfilId = user['perfil_id'] ?? 1;

          if (perfilId == 3) {
            Navigator.pushReplacementNamed(context, '/admin');
          } else if (perfilId == 2) {
            Navigator.pushReplacementNamed(context, '/dashboard-tutor', arguments: {'userName': user['nome'], 'email': user['email']});
          } else {
            Navigator.pushReplacementNamed(context, '/dashboard-paciente', arguments: {'userName': user['nome'], 'email': user['email']});
          }
        }
      } on DioException catch (_) {
        if (!mounted) return;
        Navigator.pop(context);
        mostrarMensagem("Erro de Acesso", "E-mail ou senha incorretos.");
      }
    }
  }

  void loginWithGoogle() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xff00f2ff))),
    );

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        if (!mounted) return;
        Navigator.pop(context);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        final response = await _apiService.googleLogin(
          googleAuth.idToken ?? '',
          email: firebaseUser.email,
          name: firebaseUser.displayName,
        );

        if (!mounted) return;
        Navigator.pop(context);

        if (response.statusCode == 200) {
          final user = response.data['user'];
          final int perfilId = user['perfil_id'] ?? 1;

          if (perfilId == 3) {
            Navigator.pushReplacementNamed(context, '/admin');
          } else if (perfilId == 2) {
            Navigator.pushReplacementNamed(context, '/dashboard-tutor', arguments: {'userName': user['nome'], 'email': user['email']});
          } else {
            Navigator.pushReplacementNamed(context, '/dashboard-paciente', arguments: {'userName': user['nome'], 'email': user['email']});
          }
        }
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      mostrarMensagem("Erro Google", "Falha na autenticação: $e");
    }
  }

  void mostrarMensagem(String titulo, String mensagem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xff16181b),
        title: Text(titulo, style: const TextStyle(color: Colors.white)),
        content: Text(mensagem, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK", style: TextStyle(color: Color(0xff00f2ff)))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0f1011),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("KOAVY", style: TextStyle(color: Color(0xff00f2ff), fontSize: 40, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomTextField(controller: emailController, hintText: "Email"),
                    const SizedBox(height: 16),
                    CustomTextField(controller: senhaController, hintText: "Senha", obscureText: true),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(onPressed: fazerLogin, child: const Text("ENTRAR")),
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton(
                      onPressed: loginWithGoogle,
                      child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.login), SizedBox(width: 8), Text("Entrar com Google")]),
                    ),
                    const SizedBox(height: 20),
                    TextButton(onPressed: () => Navigator.pushNamed(context, '/cadastro-paciente'), child: const Text("Não tem conta? Cadastre-se")),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
