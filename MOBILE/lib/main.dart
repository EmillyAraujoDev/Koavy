import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Importações de páginas existentes
import 'package:flutter_application_loginkoavy/pages/interface_page.dart';
import 'package:flutter_application_loginkoavy/pages/login_page.dart';
import 'package:flutter_application_loginkoavy/pages/cadastro_paciente_page.dart';
import 'package:flutter_application_loginkoavy/pages/dashboard_paciente_page.dart';
import 'package:flutter_application_loginkoavy/pages/dashboard_tutor_page.dart';
import 'package:flutter_application_loginkoavy/pages/admin_page.dart';
import 'package:flutter_application_loginkoavy/pages/cadastro_tutor_page.dart';
import 'package:flutter_application_loginkoavy/pages/contato_page.dart';
import 'package:flutter_application_loginkoavy/pages/recuperar_senha_page.dart';

// Novas importações de páginas para arquitetura profissional
import 'package:flutter_application_loginkoavy/pages/home_page.dart';
import 'package:flutter_application_loginkoavy/pages/dashboard_page.dart';
import 'package:flutter_application_loginkoavy/pages/perfil_page.dart';
import 'package:flutter_application_loginkoavy/pages/historico_page.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_loginkoavy/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase initialization error: $e");
    // Em alguns casos (como web ou sem google-services.json) pode falhar.
    // Continuamos para não travar o app se o usuário não for usar Google Login.
  }
  runApp(const KoavyApp());
}

/// Aplicação principal do Koavy Mobile.
class KoavyApp extends StatelessWidget {
  const KoavyApp({super.key});

  // Paleta de cores Koavy (neon e dark)
  static const Color neonCyan = Color(0xff00f2ff);
  static const Color neonGreen = Color(0xff00d4aa);
  static const Color backgroundDark = Color(0xff050505);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Koavy',

      // ================= TEMA GLOBAL =================
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(
          primary: neonCyan,
          secondary: neonGreen,
          surface: Color(0xff111418),
          onPrimary: Colors.black,
          onSecondary: Colors.black,
          onSurface: Colors.white,
        ),
        scaffoldBackgroundColor: backgroundDark,

        // Tipografia: Inter (Google Fonts)
        textTheme: GoogleFonts.interTextTheme(
          ThemeData.dark().textTheme,
        ),

        // Estilização de botões globais
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: neonCyan,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        
        useMaterial3: true,
      ),


      // ================= NAVEGAÇÃO =================
      // SOLUÇÃO: Usamos initialRoute '/' mapeado diretamente para InterfacePage (Welcome)
      initialRoute: '/',
      
      // Rotas estáticas
      routes: {
        '/': (context) => const InterfacePage(),
        '/login': (context) => const LoginPage(),
        '/welcome': (context) => const InterfacePage(),
        '/home': (context) => const HomePage(),
        '/dashboard': (context) => const DashboardPage(),
        '/perfil': (context) => const PerfilPage(),
        '/historico': (context) => const HistoricoPage(),
        '/cadastro-paciente': (context) => const CadastroPacientePage(),
        '/cadastro-tutor': (context) => const CadastroTutorPage(),
        '/contato': (context) => const ContatoPage(),
        '/admin': (context) => const AdminPage(),
        '/recuperar-senha': (context) => const RecuperarSenhaPage(),
      },

      // Gerenciador de rotas dinâmicas (com argumentos complexos)
      onGenerateRoute: (settings) {
        if (settings.name == '/dashboard-paciente') {
          final args = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (context) => DashboardPacientePage(
              userName: args?['userName'] ?? 'Paciente Demo',
              email: args?['email'] ?? 'paciente@koavy.com',
            ),
          );
        }
        if (settings.name == '/dashboard-tutor') {
          final args = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (context) => DashboardTutorPage(
              userName: args?['userName'] ?? 'Tutor Demo',
              email: args?['email'] ?? 'tutor@koavy.com',
            ),
          );
        }
        return null;
      },
    );
  }
}
