import 'package:flutter/material.dart';

class HistoricoPage extends StatefulWidget {
  const HistoricoPage({super.key});

  @override
  State<HistoricoPage> createState() => _HistoricoPageState();
}

class _HistoricoPageState extends State<HistoricoPage> {
  String selectedFilter = '7D'; // '1D', '7D', '30D'

  final List<Map<String, dynamic>> logs = [
    {'time': 'Hoje, 14:32', 'bpm': 74, 'status': 'Normal', 'color': const Color(0xff00d4aa)},
    {'time': 'Hoje, 10:15', 'bpm': 98, 'status': 'Elevado (Exercício)', 'color': const Color(0xfff59e0b)},
    {'time': 'Ontem, 22:00', 'bpm': 62, 'status': 'Normal (Repouso)', 'color': const Color(0xff00d4aa)},
    {'time': 'Ontem, 16:45', 'bpm': 118, 'status': 'Taquicardia Leve', 'color': const Color(0xffef4444)},
    {'time': '12 Jun, 09:12', 'bpm': 70, 'status': 'Normal', 'color': const Color(0xff00d4aa)},
    {'time': '11 Jun, 19:30', 'bpm': 85, 'status': 'Normal', 'color': const Color(0xff00d4aa)},
    {'time': '10 Jun, 08:00', 'bpm': 58, 'status': 'Bradicardia Leve (Sono)', 'color': const Color(0xff3b82f6)},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff050505),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'HISTÓRICO CARDÍACO',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Filter
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFilterChip('1D'),
                const SizedBox(width: 12),
                _buildFilterChip('7D'),
                const SizedBox(width: 12),
                _buildFilterChip('30D'),
              ],
            ),
            const SizedBox(height: 24),

            // Average Indicator Box
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xff111418), const Color(0xff111418).withValues(alpha: 0.8)],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MÉDIA DO PERÍODO',
                        style: TextStyle(color: Color(0xff00f2ff), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                      ),
                      SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text('74', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                          SizedBox(width: 4),
                          Text('BPM', style: TextStyle(color: Colors.white60, fontSize: 14)),
                        ],
                      )
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('ESTADO GERAL', style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text(
                        'Excelente',
                        style: TextStyle(color: Color(0xff00d4aa), fontSize: 18, fontWeight: FontWeight.bold),
                      )
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Registros de Atividade',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Timeline List of logs
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final log = logs[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xff111418),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: log['color'].withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: log['color'].withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.favorite, color: log['color'], size: 20),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                log['status'],
                                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                log['time'],
                                style: const TextStyle(color: Colors.white38, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '${log['bpm']}',
                              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 2),
                            const Text(
                              'BPM',
                              style: TextStyle(color: Colors.white60, fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final bool isSelected = selectedFilter == label;
    return InkWell(
      onTap: () {
        setState(() {
          selectedFilter = label;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(colors: [Color(0xff00f2ff), Color(0xff00d4aa)])
              : null,
          color: isSelected ? null : const Color(0xff111418),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.white.withValues(alpha: 0.05),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white70,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
