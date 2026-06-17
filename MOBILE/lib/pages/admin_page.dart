import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application_loginkoavy/api_service.dart';
import 'package:flutter_application_loginkoavy/widgets/responsive_helper.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final ApiService _apiService = ApiService();
  int selectedMenu = 0;

  static const Color neon1 = Color(0xff00F2FF);
  static const Color neon2 = Color(0xff00D4AA);

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveHelper.isMobile(context);

    Widget sidebarContent() {
      return Container(
        width: 290,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: .4),
          border: const Border(right: BorderSide(color: Colors.white10)),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                _buildLogo(),
                const SizedBox(height: 50),
                _buildMenuButton("Dashboard", 0),
                _buildMenuButton("Gestão de Usuários", 1),
                _buildMenuButton("Telemetria Real", 2),
                const Spacer(),
                _buildLogoutButton(),
              ],
            ),
          ),
        ),
      );
    }

    Widget mainContent() {
      return Padding(
        padding: EdgeInsets.all(isMobile ? 20 : 40),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isMobile),
              const SizedBox(height: 40),
              _buildStatCards(isMobile),
              const SizedBox(height: 30),
              _buildMonitoringSection(isMobile),
            ],
          ),
        ),
      );
    }

    return Theme(
      data: ThemeData(
        scaffoldBackgroundColor: const Color(0xff050505),
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
        colorScheme: const ColorScheme.dark(primary: neon1, secondary: neon2),
      ),
      child: Scaffold(
        appBar: isMobile ? AppBar(title: const Text("KOAVY ADMIN"), backgroundColor: Colors.black87) : null,
        drawer: isMobile ? Drawer(backgroundColor: const Color(0xff050505), child: sidebarContent()) : null,
        body: isMobile ? mainContent() : Row(children: [sidebarContent(), Expanded(child: mainContent())]),
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(14)), gradient: LinearGradient(colors: [neon1, neon2])),
          child: const Center(child: Text("K", style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.w900))),
        ),
        const SizedBox(width: 12),
        const Text("KOAVY", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          await _apiService.logout();
          if (!mounted) return;
          Navigator.pushReplacementNamed(context, '/');
        },
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red.withValues(alpha: .1), foregroundColor: Colors.red, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
        child: const Text("Encerrar Sessão", style: TextStyle(fontWeight: FontWeight.w800)),
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    if (isMobile) {
      return Column(children: [_buildSearchBar(), const SizedBox(height: 16), _buildApiStatus()]);
    }
    return Row(children: [Expanded(child: _buildSearchBar()), const SizedBox(width: 20), _buildApiStatus()]);
  }

  Widget _buildStatCards(bool isMobile) {
    final cards = [
      _buildStatCard("Total Usuários", "--", Colors.grey),
      _buildStatCard("Pacientes", "--", Colors.green),
      _buildStatCard("Tutores", "--", neon1),
    ];
    if (isMobile) return Column(children: cards.map((c) => Padding(padding: const EdgeInsets.only(bottom: 16), child: c)).toList());
    return Row(children: cards.map((c) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: c))).toList());
  }

  Widget _buildMonitoringSection(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 40),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: .05), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Atividade de Monitoramento", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24)),
          const SizedBox(height: 25),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(32)),
            child: isMobile
                ? Column(children: [_buildUserRow(), const SizedBox(height: 20), ElevatedButton(onPressed: () {}, child: const Text("INSPECIONAR"))])
                : Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_buildUserRow(), ElevatedButton(onPressed: () {}, child: const Text("INSPECIONAR"))]),
          )
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 64,
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: .05), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white10)),
      child: const TextField(style: TextStyle(color: Colors.white), decoration: InputDecoration(prefixIcon: Icon(Icons.search, color: Colors.grey), border: InputBorder.none, hintText: "Buscar...", hintStyle: TextStyle(color: Colors.grey))),
    );
  }

  Widget _buildApiStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: .05), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)), const SizedBox(width: 10), const Text("STATUS API", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w900))]),
    );
  }

  Widget _buildMenuButton(String title, int index) {
    bool active = selectedMenu == index;
    return GestureDetector(
      onTap: () => setState(() => selectedMenu = index),
      child: Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: active ? neon1.withValues(alpha: .1) : Colors.transparent, borderRadius: BorderRadius.circular(18)), child: Row(children: [Container(width: 8, height: 8, decoration: BoxDecoration(color: active ? neon1 : Colors.transparent, shape: BoxShape.circle)), const SizedBox(width: 16), Text(title, style: TextStyle(color: active ? neon1 : Colors.grey, fontWeight: FontWeight.w700))])),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: .05), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white10)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title.toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 2)), const SizedBox(height: 20), Text(value, style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w900))]),
    );
  }

  Widget _buildUserRow() {
    return Row(children: [Container(width: 50, height: 50, decoration: BoxDecoration(color: neon1.withValues(alpha: .1), shape: BoxShape.circle), child: const Center(child: Text("JS", style: TextStyle(color: neon1, fontWeight: FontWeight.w900)))), const SizedBox(width: 20), Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text("João Silva", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)), Text("BPM 72", style: TextStyle(color: Colors.grey))])]);
  }
}
