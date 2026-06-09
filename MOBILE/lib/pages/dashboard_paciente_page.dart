import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_application_loginkoavy/pages/login_page.dart';

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
  int activeTab = 0; // 0: Resumo, 1: Histórico, 2: Perfil

  // Dados do paciente (editáveis)
  late String currentName;
  late String currentEmail;
  String currentWeight = '75';
  String currentHeight = '180';
  String currentBloodType = 'O+';
  String currentAge = '30';

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

    // Controle de pulsação do indicador "LIVE" e ícone de coração
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
        backgroundColor: const Color(0xff34d399),
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

  void logout() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 900;

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
                  // Logo
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
                      fontFamily: 'Outfit',
                    ),
                  ),
                  const Spacer(),
                  // Paciente Ativo tag e Nome
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
                          style: TextStyle(color: const Color(0xff34d399), fontWeight: FontWeight.bold, fontSize: 10),
                        ),
                      ],
                    ),
                  const SizedBox(width: 20),
                  // Botão de Logout
                  IconButton(
                    onPressed: logout,
                    icon: const Icon(Icons.logout, color: Colors.redAccent),
                    tooltip: 'Sair do Sistema',
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
                // TABS NAVEGAÇÃO
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

                // CONTEÚDO DAS ABAS
                IndexedStack(
                  index: activeTab,
                  children: [
                    _buildResumoTab(isMobile),
                    _buildHistoricoTab(),
                    _buildPerfilTab(),
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
      onTap: () {
        setState(() {
          activeTab = index;
        });
      },
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

  // ================= ABA 1: RESUMO REALTIME =================
  Widget _buildResumoTab(bool isMobile) {
    return isMobile
        ? Column(
            children: [
              _buildMonitorCard(),
              const SizedBox(height: 24),
              _buildProfileSidebarCard(),
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildMonitorCard()),
              const SizedBox(width: 30),
              Expanded(flex: 1, child: _buildProfileSidebarCard()),
            ],
          );
  }

  Widget _buildMonitorCard() {
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
                  fontFamily: 'Outfit',
                ),
              ),
              // Pulse LIVE Badge
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
                          decoration: const BoxDecoration(
                            color: Color(0xff00f2ff),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "LIVE",
                          style: TextStyle(
                            color: Color(0xff00f2ff),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              // Radial BPM Ring
              Stack(
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
                        scale: Tween(begin: 0.95, end: 1.05).animate(
                          CurvedAnimation(parent: pulseController, curve: Curves.easeInOut),
                        ),
                        child: const Icon(
                          Icons.favorite,
                          color: Color(0xff00f2ff),
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "$currentBPM",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Text(
                        "BPM",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 40),
              // Status & Stats
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "STATUS DO SISTEMA",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Seu coração está batendo em um ritmo saudável. Continue assim!",
                            style: TextStyle(
                              color: const Color(0xff34d399),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.03),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: const [
                                Text("MÍNIMA", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                                SizedBox(height: 4),
                                Text("65", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.03),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: const [
                                Text("MÁXIMA", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                                SizedBox(height: 4),
                                Text("110", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSidebarCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xff00f2ff).withValues(alpha: 0.08),
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xff00f2ff), width: 2),
              color: const Color(0xff16181b),
            ),
            child: const Center(
              child: Icon(
                Icons.person,
                color: Color(0xff00f2ff),
                size: 48,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            currentName,
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            "ID: #100",
            style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          // Info List
          _buildSidebarInfoRow("Idade", "$currentAge anos"),
          const SizedBox(height: 12),
          _buildSidebarInfoRow("Sanguíneo", currentBloodType, highlightValue: true),
        ],
      ),
    );
  }

  Widget _buildSidebarInfoRow(String label, String value, {bool highlightValue = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
          Text(
            value,
            style: TextStyle(
              color: highlightValue ? const Color(0xff00f2ff) : Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ================= ABA 2: HISTÓRICO MÉDICO =================
  Widget _buildHistoricoTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Histórico de Exames",
                  style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                ),
                SizedBox(height: 4),
                Text(
                  "Mantenha seus documentos organizados para consultas futuras.",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: simularAnexoExame,
              icon: const Icon(Icons.attach_file, color: Colors.black),
              label: const Text("Anexar Novo Exame"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff00d4aa),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 350,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            mainAxisExtent: 180,
          ),
          itemCount: exames.length,
          itemBuilder: (context, index) {
            final exam = exames[index];
            final bool isNew = exam['data'] == 'Hoje';
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: isNew ? const Color(0xff00f2ff).withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.08),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              exam['titulo']!,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            Text(
                              "PDF • ${exam['tamanho']!}",
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Divider(color: Colors.white10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(exam['data']!, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                      if (isNew)
                        const Text(
                          "ENVIADO ✔",
                          style: TextStyle(color: const Color(0xff34d399), fontSize: 11, fontWeight: FontWeight.bold),
                        )
                      else
                        const Text(
                          "VER DOCUMENTO",
                          style: TextStyle(color: Color(0xff00f2ff), fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // ================= ABA 3: DADOS DO PERFIL (FORMULÁRIO) =================
  Widget _buildPerfilTab() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Editar Minhas Informações",
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
          ),
          const SizedBox(height: 35),
          LayoutBuilder(
            builder: (context, constraints) {
              final bool localIsMobile = constraints.maxWidth < 650;
              return Column(
                children: [
                  _buildFormRow(
                    isMobile: localIsMobile,
                    leftLabel: 'Nome Completo',
                    leftController: nameController,
                    rightLabel: 'E-mail de Acesso',
                    rightController: emailController,
                  ),
                  const SizedBox(height: 20),
                  _buildFormRow(
                    isMobile: localIsMobile,
                    leftLabel: 'Peso (kg)',
                    leftController: weightController,
                    rightLabel: 'Altura (cm)',
                    rightController: heightController,
                  ),
                  const SizedBox(height: 20),
                  _buildFormRow(
                    isMobile: localIsMobile,
                    leftLabel: 'Tipo Sanguíneo',
                    leftController: bloodController,
                    rightLabel: 'Idade',
                    rightController: TextEditingController(text: currentAge), // apenas leitura na idade
                    rightReadOnly: true,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 40),
          const Divider(color: Colors.white10),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    activeTab = 0; // Cancela e volta
                  });
                },
                child: const Text("Cancelar", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: salvarPerfil,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff00f2ff),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text("Salvar Alterações", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormRow({
    required bool isMobile,
    required String leftLabel,
    required TextEditingController leftController,
    required String rightLabel,
    required TextEditingController rightController,
    bool rightReadOnly = false,
  }) {
    final Widget leftField = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(leftLabel.toUpperCase(), style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 8),
        TextFormField(
          controller: leftController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.black.withValues(alpha: 0.4),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.white10)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.white10)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xff00f2ff))),
          ),
        ),
      ],
    );

    final Widget rightField = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(rightLabel.toUpperCase(), style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 8),
        TextFormField(
          controller: rightController,
          readOnly: rightReadOnly,
          style: TextStyle(color: rightReadOnly ? Colors.grey : Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.black.withValues(alpha: 0.4),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.white10)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.white10)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xff00f2ff))),
          ),
        ),
      ],
    );

    if (isMobile) {
      return Column(
        children: [
          leftField,
          const SizedBox(height: 20),
          rightField,
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(child: leftField),
          const SizedBox(width: 20),
          Expanded(child: rightField),
        ],
      );
    }
  }
}
