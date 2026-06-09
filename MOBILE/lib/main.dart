import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application_loginkoavy/pages/interface_page.dart';
import 'package:flutter_application_loginkoavy/pages/login_page.dart';
import 'package:flutter_application_loginkoavy/pages/cadastro_paciente_page.dart';
import 'package:flutter_application_loginkoavy/pages/dashboard_paciente_page.dart';
import 'package:flutter_application_loginkoavy/pages/dashboard_tutor_page.dart';
import 'package:flutter_application_loginkoavy/pages/admin_page.dart';
import 'package:flutter_application_loginkoavy/cadastrotutor.dart';
import 'package:flutter_application_loginkoavy/contato.dart';

void main() {
  runApp(const KoavyApp());
}

/// Aplicação principal do Koavy Mobile.
class KoavyApp extends StatelessWidget {
  const KoavyApp({super.key});

  // Paleta de cores Koavy
  static const Color neon1 = Color(0xff00f2ff); // --neon1
  static const Color neon2 = Color(0xff00d4aa); // --neon2
  static const Color bgDark = Color(0xff050505); // fundo global

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Koavy',

      // ================= TEMA GLOBAL =================
      theme: ThemeData(
        // Cores principais baseadas na identidade visual Koavy
        colorScheme: const ColorScheme.dark(
          primary: neon1,
          secondary: neon2,
          surface: Color(0xff111418),
          onPrimary: Colors.black,
          onSecondary: Colors.black,
          onSurface: Colors.white,
        ),
        scaffoldBackgroundColor: bgDark,

        // Tipografia: Google Fonts Inter (mesma fonte do projeto WEB)
        textTheme: GoogleFonts.interTextTheme(
          ThemeData.dark().textTheme,
        ),

        // ElevatedButton padrão com gradiente neon
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: neon1,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // TextButton padrão neon
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: neon1,
          ),
        ),

        // Componentes de Material 3
        useMaterial3: true,
      ),

      // ================= ROTA INICIAL =================
      home: const InterfacePage(),

      // ================= ROTAS NOMEADAS =================
      // Permite Navigator.pushNamed(context, '/login') em qualquer lugar
      routes: {
        '/':                    (context) => const InterfacePage(),
        '/login':               (context) => const LoginPage(),
        '/cadastro-paciente':   (context) => const CadastroPacientePage(),
        '/cadastro-tutor':      (context) => const CadastroTutorPage(),
        '/contato':             (context) => const ContatoPage(),
        '/admin':               (context) => const AdminPage(),
        '/dashboard-paciente':  (context) => const DashboardPacientePage(),
        '/dashboard-tutor':     (context) => const DashboardTutorPage(),
      },
    );
  }
}
