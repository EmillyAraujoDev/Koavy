import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_application_loginkoavy/api_service.dart';
import 'package:flutter_application_loginkoavy/widgets/responsive_helper.dart';

class DashboardPacientePage extends StatefulWidget {
  final String userName;
  final String email;

  const DashboardPacientePage({
    super.key,
    this.userName = 'Paciente Demo',
    this.email = 'paciente@koavy.com',
  });

  @override
  State<DashboardPacientePage> createState() => _DashboardPacientePageState();
}

class _DashboardPacientePageState extends State<DashboardPacientePage> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  int activeTab = 0; // 0: Resumo, 1: Histórico, 2: Perfil

  // Dados do paciente (editáveis)
  late String currentName;
  late String currentEmail;
  String currentWeight = '75';
  String currentHeight = '180';
  String currentBloodType = 'O+';

  // Controladores do Formulário de Edição
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController weightController;
  late TextEditingController heightController;
  late TextEditingController bloodController;

  // Estado do BPM Realtime
  int currentBPM = 72;
  late Timer bpmTimer;
  late AnimationController pulseController;

  // Lista de Exames (dinâmica)
  final List<Map<String, String>> exames = [
    {
      'titulo': 'Eletrocardiograma',
      'tamanho': '1.2 MB',
      'data': '12 Mai 2026',
    }
  ];

  @override
  void initState() {
    super.initState();
    currentName = widget.userName;
    currentEmail = widget.email;

    nameController = TextEditingController(text: currentName);
    emailController = TextEditingController(text: currentEmail);
    weightController = TextEditingController(text: currentWeight);
    heightController = TextEditingController(text: currentHeight);
    bloodController = TextEditingController(text: currentBloodType);

    // Simulação de BPM flutuante a cada 3 segundos
    bpmTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          currentBPM = 65 + Random().nextInt(15); // oscila entre 65 e 80
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
    bpmTimer.cancel();
    pulseController.dispose();
    nameController.dispose();
    emailController.dispose();
    weightController.dispose();
    heightController.dispose();
    bloodController.dispose();
    super.dispose();
  }

  void simularAnexoExame() {
    setState(() {
      exames.insert(0, {
        'titulo': 'Hemograma_Koavy_${Random().nextInt(900) + 100}.pdf',
        'tamanho': '850 KB',
        'data': 'Hoje',
      });
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exame enviado com sucesso!'),
        backgroundColor: Color(0xff34d399),
      ),
    );
  }

  void salvarPerfil() {
    setState(() {
      currentName = nameController.text;
      currentEmail = emailController.text;
      currentWeight = weightController.text;
      currentHeight = heightController.text;
      currentBloodType = bloodController.text;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Perfil atualizado com sucesso!'),
        backgroundColor: Colors.cyan,
      ),
    );
    setState(() {
      activeTab = 0; // Retorna para a aba resumo
    });
  }

  void logout() async {
    await _apiService.logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveHelper.isMobile(context);

    return Scaffold(
      backgroundColor: const Color(0xff050505),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.4),
            border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xff00f2ff),
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    child: const Center(
                      child: Text(
                        "K",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Koavy",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  if (!isMobile)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          currentName,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const Text(
                          "Paciente Ativo",
                          style: TextStyle(color: Color(0xff34d399), fontWeight: FontWeight.bold, fontSize: 10),
                        ),
                      ],
                    ),
                  const SizedBox(width: 20),
                  IconButton(
                    onPressed: logout,
                    icon: const Icon(Icons.logout, color: Colors.redAccent),
                  ),
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
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildTabButton("Resumo Realtime", 0),
                      const SizedBox(width: 12),
                      _buildTabButton("Histórico Médico", 1),
                      const SizedBox(width: 12),
                      _buildTabButton("Dados do Perfil", 2),
                    ],
                  ),
                ),
                const SizedBox(height: 35),
                IndexedStack(
                  index: activeTab,
                  children: [
                    _buildResumoTab(isMobile),
                    _buildHistoricoTab(isMobile),
                    _buildPerfilTab(isMobile),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final bool isActive = activeTab == index;
    return InkWell(
      onTap: () => setState(() => activeTab = index),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xff00f2ff) : Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? Colors.transparent : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            color: isActive ? Colors.black : Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 12,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildResumoTab(bool isMobile) {
    return isMobile
        ? Column(
            children: [
              _buildMonitorCard(isMobile),
              const SizedBox(height: 24),
              _buildProfileSidebarCard(),
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildMonitorCard(isMobile)),
              const SizedBox(width: 30),
              Expanded(flex: 1, child: _buildProfileSidebarCard()),
            ],
          );
  }

  Widget _buildMonitorCard(bool isMobile) {
    double percentage = (currentBPM - 40) / (160 - 40);
    percentage = percentage.clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Monitoramento Cardíaco",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              AnimatedBuilder(
                animation: pulseController,
                builder: (context, child) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xff00f2ff).withValues(alpha: 0.1 + (pulseController.value * 0.1)),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xff00f2ff).withValues(alpha: 0.2 + (pulseController.value * 0.3)),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(color: Color(0xff00f2ff), shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 8),
                        const Text("LIVE", style: TextStyle(color: Color(0xff00f2ff), fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 40),
          _buildBpmDisplay(percentage, isMobile),
        ],
      ),
    );
  }

  Widget _buildBpmDisplay(double percentage, bool isMobile) {
    final Widget indicator = Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 180,
          height: 180,
          child: CircularProgressIndicator(
            value: percentage,
            strokeWidth: 12,
            backgroundColor: Colors.white.withValues(alpha: 0.05),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xff00f2ff)),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: Tween(begin: 0.95, end: 1.05).animate(pulseController),
              child: const Icon(Icons.favorite, color: Color(0xff00f2ff), size: 32),
            ),
            Text("$currentBPM", style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900)),
            const Text("BPM", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );

    final Widget info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("STATUS DO SISTEMA", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text("Ritmo saudável. Continue assim!", style: TextStyle(color: Color(0xff34d399), fontWeight: FontWeight.w600, fontSize: 14)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            _buildMinMaxCard("MÍNIMA", "65"),
            const SizedBox(width: 16),
            _buildMinMaxCard("MÁXIMA", "110"),
          ],
        ),
      ],
    );

    return isMobile
        ? Column(children: [Center(child: indicator), const SizedBox(height: 32), info])
        : Row(children: [indicator, const SizedBox(width: 40), Expanded(child: info)]);
  }

  Widget _buildMinMaxCard(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSidebarCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xff00f2ff), width: 2), color: const Color(0xff16181b)),
            child: const Icon(Icons.person, color: Color(0xff00f2ff), size: 48),
          ),
          const SizedBox(height: 20),
          Text(currentName, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const Text("ID: #100", style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 30),
          _buildSidebarInfoRow("Sanguíneo", currentBloodType, highlight: true),
        ],
      ),
    );
  }

  Widget _buildSidebarInfoRow(String label, String value, {bool highlight = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
          Text(value, style: TextStyle(color: highlight ? const Color(0xff00f2ff) : Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildHistoricoTab(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(child: Text("Histórico de Exames", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold))),
            IconButton(onPressed: simularAnexoExame, icon: const Icon(Icons.add_circle, color: Color(0xff00d4aa), size: 32)),
          ],
        ),
        const SizedBox(height: 30),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 350, mainAxisSpacing: 20, crossAxisSpacing: 20, mainAxisExtent: 180),
          itemCount: exames.length,
          itemBuilder: (context, index) => _buildExamCard(exames[index]),
        ),
      ],
    );
  }

  Widget _buildExamCard(Map<String, String> exam) {
    final bool isNew = exam['data'] == 'Hoje';
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: isNew ? const Color(0xff00f2ff) : Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
              const SizedBox(width: 16),
              Expanded(child: Text(exam['titulo']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
            ],
          ),
          const Spacer(),
          Text(exam['data']!, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildPerfilTab(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.03), borderRadius: BorderRadius.circular(40), border: Border.all(color: Colors.white10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Dados do Perfil", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 35),
          _buildProfileField("Nome", nameController),
          const SizedBox(height: 20),
          _buildProfileField("E-mail", emailController),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: salvarPerfil,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff00f2ff), foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            child: const Text("Salvar Alterações"),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.black45,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}
