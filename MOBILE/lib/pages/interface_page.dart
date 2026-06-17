import 'package:flutter/material.dart';
import 'package:flutter_application_loginkoavy/widgets/custom_navbar.dart';
import 'package:flutter_application_loginkoavy/widgets/responsive_helper.dart';

/// Página Inicial (Landing Page) da aplicação Koavy.
class InterfacePage extends StatefulWidget {
  const InterfacePage({super.key});

  @override
  State<InterfacePage> createState() => _InterfacePageState();
}

class _InterfacePageState extends State<InterfacePage> {
  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveHelper.isMobile(context);

    return Scaffold(
      backgroundColor: const Color(0xff07090b),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ================= NAVBAR =================
            CustomNavBar(
              activeTab: 'Início',
              onEntrarTap: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),

            // ================= HERO =================
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                vertical: isMobile ? 40 : 100,
                horizontal: isMobile ? 24 : 60,
              ),
              child: isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildHeroText(isMobile),
                        const SizedBox(height: 50),
                        _buildHeroImage(),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: _buildHeroText(isMobile)),
                        Expanded(child: _buildHeroImage()),
                      ],
                    ),
            ),

            // ================= BENEFÍCIOS =================
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 24 : 50,
                vertical: isMobile ? 50 : 80,
              ),
              child: Column(
                children: [
                  Text(
                    "Por que escolher Koavy?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 32 : 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: isMobile ? 40 : 60),
                  Wrap(
                    spacing: 30,
                    runSpacing: 30,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildBeneficioCard(
                        "assets/images/heartKoavy.png",
                        "Monitoramento 24h",
                        "Acompanhamento contínuo com precisão.",
                      ),
                      _buildBeneficioCard(
                        "assets/images/alertKoavy.png",
                        "Alertas Reais",
                        "Notificações automáticas em tempo real.",
                      ),
                      _buildBeneficioCard(
                        "assets/images/celular.png",
                        "App Intuitivo",
                        "Relatórios simples e acessíveis.",
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ================= HISTÓRIA =================
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 24 : 60,
                vertical: isMobile ? 50 : 80,
              ),
              child: Column(
                children: [
                  Text(
                    "Como Tudo Começou",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 34 : 42,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: isMobile ? 30 : 50),
                  isMobile
                      ? Column(
                          children: [
                            _buildHistoriaText(),
                            const SizedBox(height: 30),
                            _buildHeroImage(), // Usando imagem hero como placeholder
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildHistoriaText()),
                            const SizedBox(width: 40),
                            Expanded(child: _buildHeroImage()),
                          ],
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= AUXILIAR WIDGETS =================

  Widget _buildHeroText(bool isMobile) {
    return Column(
      crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          "Monitore seu coração em tempo real",
          textAlign: isMobile ? TextAlign.center : TextAlign.start,
          style: TextStyle(
            color: Colors.white,
            fontSize: isMobile ? 36 : 54,
            fontWeight: FontWeight.w800,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 25),
        Text(
          "Monitoramento inteligente com alertas e acompanhamento contínuo.",
          textAlign: isMobile ? TextAlign.center : TextAlign.start,
          style: TextStyle(
            color: Colors.white70,
            fontSize: isMobile ? 18 : 20,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 35),
        InkWell(
          onTap: () {
            Navigator.pushReplacementNamed(context, '/cadastro-paciente');
          },
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 35,
              vertical: 18,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: const LinearGradient(
                colors: [Color(0xff22d3ee), Color(0xff34d399)],
              ),
            ),
            child: const Text(
              "Começar agora",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroImage() {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 350,
            height: 350,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.cyan.withValues(alpha: 0.4),
                  blurRadius: 120,
                  spreadRadius: 30,
                ),
              ],
            ),
          ),
          Image.asset("assets/images/koala1.png", width: 320),
        ],
      ),
    );
  }

  Widget _buildBeneficioCard(String imagem, String titulo, String descricao) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: const Color(0xff111418),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Image.asset(imagem, width: 60),
          const SizedBox(height: 25),
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            descricao,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoriaText() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: const Color(0xff111418),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white10),
      ),
      child: const Text(
        "Tudo começou com o irmão mais velho de uma dos integrantes que tem 23 anos e, desde que nasceu, sofre com uma desregulação cardíaca. Ele sempre foi uma pessoa muito ativa e é professor de beach tennis, um esporte bastante intenso. Recentemente, após perceber que ele vinha apresentando alterações cardíacas mais frequentes, a médica recomendou que ele evitasse esforços físicos intensos, devido à sua condição. Pensando nisso, surgiu a ideia de desenvolver uma pulseira inteligente que possa auxiliá-lo no monitoramento da saúde cardíaca.",
        style: TextStyle(
          color: Colors.white70,
          fontSize: 17,
          height: 1.8,
        ),
      ),
    );
  }
}
