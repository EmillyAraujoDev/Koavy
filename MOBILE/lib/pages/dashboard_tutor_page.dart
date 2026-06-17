import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_application_loginkoavy/api_service.dart';
import 'package:flutter_application_loginkoavy/widgets/responsive_helper.dart';

class DashboardTutorPage extends StatefulWidget {
  final String userName;
  final String email;

  const DashboardTutorPage({
    super.key,
    this.userName = 'Tutor Demo',
    this.email = 'tutor@koavy.com',
  });

  @override
  State<DashboardTutorPage> createState() => _DashboardTutorPageState();
}

class _DashboardTutorPageState extends State<DashboardTutorPage> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  int currentBPM = 74;
  int currentO2 = 98;
  late Timer telemetryTimer;
  late AnimationController pulseController;

  @override
  void initState() {
    super.initState();
    telemetryTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          currentBPM = 70 + Random().nextInt(10);
          currentO2 = 96 + Random().nextInt(4);
        });
      }
    });

    pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    telemetryTimer.cancel();
    pulseController.dispose();
    super.dispose();
  }

  void logout() async {
    await _apiService.logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/');
  }

  void abrirHistoricoModal() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xff1a1c1e),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30), side: const BorderSide(color: Colors.white10)),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Histórico de João Silva", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 25),
                _buildHistoricoSection("ÚLTIMOS EXAMES ANEXADOS", [
                  _buildHistoricoItem("Eletrocardiograma_Mar.pdf", "12 MAR 2026", Icons.picture_as_pdf, Colors.redAccent),
                ]),
                const SizedBox(height: 20),
                _buildHistoricoSection("RELATÓRIO DE ALERTAS", [
                  _buildAlertItem("Arritmia Detectada", "14 MAI 2026 - 22:15", "CRÍTICO"),
                ]),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistoricoSection(String title, List<Widget> items) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.03), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Color(0xff00f2ff), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 16),
          ...items,
        ],
      ),
    );
  }

  Widget _buildHistoricoItem(String title, String subtitle, IconData icon, Color iconColor) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAlertItem(String title, String subtitle, String status) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(20)),
            child: Text(status, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveHelper.isMobile(context);

    return Scaffold(
      backgroundColor: const Color(0xff050505),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.4), border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)))),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  const Text("Koavy Tutor", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
                  const Spacer(),
                  IconButton(onPressed: logout, icon: const Icon(Icons.logout, color: Colors.redAccent)),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 40),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Central de Monitoramento", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
                const SizedBox(height: 40),
                GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 400, mainAxisSpacing: 30, crossAxisSpacing: 30, mainAxisExtent: 340),
                  children: [
                    _buildPatientCard(),
                    _buildAddPatientCard(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPatientCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.03), borderRadius: BorderRadius.circular(40), border: Border.all(color: Colors.white10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 50, height: 50, decoration: const BoxDecoration(color: Color(0xff00f2ff), shape: BoxShape.circle), child: const Center(child: Text("JS", style: TextStyle(fontWeight: FontWeight.bold)))),
              const SizedBox(width: 16),
              const Text("João Silva", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              _buildTelemetriaBox("BPM", "$currentBPM", const Color(0xff00f2ff)),
              const SizedBox(width: 12),
              _buildTelemetriaBox("O2", "$currentO2%", const Color(0xff34d399)),
            ],
          ),
          const Spacer(),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: abrirHistoricoModal, child: const Text("Ver Histórico"))),
        ],
      ),
    );
  }

  Widget _buildTelemetriaBox(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
            Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildAddPatientCard() {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.white10, style: BorderStyle.solid), borderRadius: BorderRadius.circular(40)),
      child: const Center(child: Icon(Icons.add, color: Colors.grey, size: 48)),
    );
  }
}
