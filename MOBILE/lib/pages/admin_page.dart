import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_application_loginkoavy/pages/login_page.dart';
import 'package:google_fonts/google_fonts.dart';

/// Página de Administração (Dashboard) do sistema Koavy.
class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int selectedMenu = 0;

  static const Color neon1 = Color(0xff00F2FF);
  static const Color neon2 = Color(0xff00D4AA);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 950;

    // Constrói o conteúdo da barra lateral (Sidebar)
    Widget sidebarContent() {
      return Container(
        width: 290,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: .4),
          border: Border(
            right: BorderSide(
              color: Colors.white.withValues(alpha: .05),
            ),
          ),
        ),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 20,
              sigmaY: 20,
            ),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  // Logo
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(14)),
                          gradient: LinearGradient(
                            colors: [neon1, neon2],
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            "K",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ShaderMask(
                        shaderCallback: (bounds) {
                          return const LinearGradient(
                            colors: [neon1, neon2],
                          ).createShader(bounds);
                        },
                        child: const Text(
                          "KOAVY",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),

                  // Itens de Menu
                  _buildMenuButton("Dashboard", 0),
                  _buildMenuButton("Gestão de Usuários", 1),
                  _buildMenuButton("Telemetria Real", 2),

                  const Spacer(),

                  // Botão de Encerrar Sessão (Retorna ao Login)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.withValues(alpha: .1),
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                          vertical: 18,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        "Encerrar Sessão",
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Constrói a área de conteúdo principal (Dashboard)
    Widget mainContent() {
      return Padding(
        padding: EdgeInsets.all(isMobile ? 20 : 40),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER (Pesquisa + Status da API)
              screenWidth < 600
                  ? Column(
                      children: [
                        _buildSearchBar(),
                        const SizedBox(height: 16),
                        _buildApiStatus(),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(child: _buildSearchBar()),
                        const SizedBox(width: 20),
                        _buildApiStatus(),
                      ],
                    ),

              const SizedBox(height: 40),

              // CARDS DE ESTATÍSTICA (Responsivos)
              isMobile
                  ? Column(
                      children: [
                        _buildStatCard("Total Usuários", "--", Colors.grey),
                        const SizedBox(height: 16),
                        _buildStatCard("Pacientes", "--", Colors.green),
                        const SizedBox(height: 16),
                        _buildStatCard("Tutores", "--", neon1),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            "Total Usuários",
                            "--",
                            Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: _buildStatCard(
                            "Pacientes",
                            "--",
                            Colors.green,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: _buildStatCard(
                            "Tutores",
                            "--",
                            neon1,
                          ),
                        ),
                      ],
                    ),

              const SizedBox(height: 30),

              // MONITORAMENTO DE ATIVIDADE
              Container(
                padding: EdgeInsets.all(isMobile ? 20 : 40),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .05),
                  borderRadius: BorderRadius.circular(isMobile ? 24 : 48),
                  border: Border.all(
                    color: Colors.white10,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Atividade de Monitoramento",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: isMobile ? 20 : 28,
                      ),
                    ),
                    const SizedBox(height: 25),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: isMobile
                          ? Column(
                              children: [
                                _buildActivityUserRow(),
                                const SizedBox(height: 20),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => const InspectModal(),
                                      );
                                    },
                                    child: const Text("INSPECIONAR"),
                                  ),
                                )
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildActivityUserRow(),
                                ElevatedButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => const InspectModal(),
                                    );
                                  },
                                  child: const Text(
                                    "INSPECIONAR",
                                  ),
                                )
                              ],
                            ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      );
    }

    // Aplica o tema específico de administração (Google Fonts Inter) localmente nesta tela.
    return Theme(
      data: ThemeData(
        scaffoldBackgroundColor: const Color(0xff050505),
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
        colorScheme: const ColorScheme.dark(
          primary: neon1,
          secondary: neon2,
        ),
      ),
      child: Scaffold(
        appBar: isMobile
            ? AppBar(
                title: const Text(
                  "KOAVY ADMIN",
                  style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5),
                ),
                backgroundColor: Colors.black.withValues(alpha: .8),
                elevation: 0,
                iconTheme: const IconThemeData(color: neon1),
              )
            : null,
        drawer: isMobile ? Drawer(backgroundColor: const Color(0xff050505), child: sidebarContent()) : null,
        body: isMobile
            ? mainContent()
            : Row(
                children: [
                  sidebarContent(),
                  Expanded(child: mainContent()),
                ],
              ),
      ),
    );
  }

  // ================= AUXILIAR WIDGETS =================

  Widget _buildSearchBar() {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white10,
        ),
      ),
      child: const TextField(
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey,
          ),
          border: InputBorder.none,
          hintText: "Buscar pacientes, tutores ou IDs...",
          hintStyle: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildApiStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white10,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            "STATUS API",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 10,
              letterSpacing: 2,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(String title, int index) {
    bool active = selectedMenu == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMenu = index;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: active ? neon1.withValues(alpha: .1) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: active ? neon1 : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                color: active ? neon1 : Colors.grey,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color titleColor) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .05),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: titleColor,
              fontWeight: FontWeight.w900,
              fontSize: 11,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityUserRow() {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: neon1.withValues(alpha: .1),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text(
              "JS",
              style: TextStyle(
                color: neon1,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "João Silva (#100)",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 5),
            Text(
              "BPM Normal (72)",
              style: TextStyle(
                color: Colors.grey,
              ),
            )
          ],
        ),
      ],
    );
  }
}

/// Modal de Inspeção de Usuário
class InspectModal extends StatelessWidget {
  const InspectModal({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      backgroundColor: const Color(0xff1A1C1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(40),
        side: const BorderSide(color: Colors.white10),
      ),
      child: Container(
        width: screenWidth < 650 ? screenWidth * 0.9 : 600,
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Nome do Usuário",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Nome",
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.black38,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Fechar"),
            ),
          ],
        ),
      ),
    );
  }
}
