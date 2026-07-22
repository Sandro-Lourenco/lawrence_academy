import 'package:flutter/material.dart';
import '../../design_system/tokens/liquid_theme.dart';

class AdminAnalyticsPage extends StatefulWidget {
  const AdminAnalyticsPage({super.key});

  @override
  State<AdminAnalyticsPage> createState() => _AdminAnalyticsPageState();
}

class _AdminAnalyticsPageState extends State<AdminAnalyticsPage> {
  int _currentPage = 1;
  final int _pageSize = 5;

  // Pagamentos Auditados (Simulação da tabela com paginação remota)
  final List<Map<String, dynamic>> _paymentLogs = [
    {
      "date": "07/07/2026",
      "email": "sandrocalebe8@gmail.com",
      "mrr": "R\$ 89,90",
      "status": "Confirmado",
    },
    {
      "date": "06/07/2026",
      "email": "aluno.costura@gmail.com",
      "mrr": "R\$ 89,90",
      "status": "Confirmado",
    },
    {
      "date": "05/07/2026",
      "email": "elena.alfaiate@hotmail.com",
      "mrr": "R\$ 89,90",
      "status": "Atrasado",
    },
    {
      "date": "04/07/2026",
      "email": "juliana.vestido@gmail.com",
      "mrr": "R\$ 89,90",
      "status": "Confirmado",
    },
    {
      "date": "03/07/2026",
      "email": "patricia.moulage@gmail.com",
      "mrr": "R\$ 89,90",
      "status": "Cancelado",
    },
    {
      "date": "02/07/2026",
      "email": "beatriz.fina@gmail.com",
      "mrr": "R\$ 89,90",
      "status": "Confirmado",
    },
    {
      "date": "01/07/2026",
      "email": "renata.viagem@gmail.com",
      "mrr": "R\$ 89,90",
      "status": "Confirmado",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 800;

    // Métricas calculadas para exibição baseada na paginação
    final startIdx = (_currentPage - 1) * _pageSize;
    final endIdx = startIdx + _pageSize;
    final pageLogs = _paymentLogs.sublist(
      startIdx,
      endIdx > _paymentLogs.length ? _paymentLogs.length : endIdx,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Painel Administrativo & Métricas",
          style: TextStyle(fontFamily: 'Outfit', fontSize: 16),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: LiquidTheme.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Grid de Métricas Principais
            isMobile
                ? Column(
                    children: [
                      _buildMetricCard(
                        "MRR TOTAL",
                        "R\$ 12.450,00",
                        "+8.2% este mês",
                        Icons.monetization_on,
                      ),
                      const SizedBox(height: 16),
                      _buildMetricCard(
                        "ALUNOS ATIVOS",
                        "138 alunos",
                        "+12 novos",
                        Icons.people,
                      ),
                      const SizedBox(height: 16),
                      _buildMetricCard(
                        "TAXA DE CONCLUSÃO",
                        "72%",
                        "Média de 4.2 aulas/semana",
                        Icons.golf_course,
                      ),
                      const SizedBox(height: 16),
                      _buildMetricCard(
                        "CHURN RATE",
                        "2.1%",
                        "-0.4% em relação a Junho",
                        Icons.trending_down,
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          "MRR TOTAL",
                          "R\$ 12.450,00",
                          "+8.2% este mês",
                          Icons.monetization_on,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildMetricCard(
                          "ALUNOS ATIVOS",
                          "138 alunos",
                          "+12 novos",
                          Icons.people,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildMetricCard(
                          "TAXA DE CONCLUSÃO",
                          "72%",
                          "Média de 4.2 aulas",
                          Icons.golf_course,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildMetricCard(
                          "CHURN RATE",
                          "2.1%",
                          "-0.4% em relação a Junho",
                          Icons.trending_down,
                        ),
                      ),
                    ],
                  ),
            const SizedBox(height: 40),

            // 2. Tabela de Auditoria de Pagamentos
            const Text(
              "Auditoria de Faturamento & Pagamentos",
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: LiquidTheme.glassDecoration(radius: 16),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  Table(
                    columnWidths: const {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(4),
                      2: FlexColumnWidth(2),
                      3: FlexColumnWidth(2),
                    },
                    children: [
                      // Cabeçalho da Tabela
                      TableRow(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.04),
                        ),
                        children: const [
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              "Data",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              "E-mail",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              "Fatura",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              "Status",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Linhas com os registros paginados
                      ...pageLogs.map((log) {
                        return TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                log["date"],
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white60,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                log["email"],
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white60,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                log["mrr"],
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white60,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                log["status"],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: log["status"] == "Confirmado"
                                      ? LiquidTheme.secondary
                                      : log["status"] == "Atrasado"
                                      ? LiquidTheme.warningPastel
                                      : Colors.redAccent,
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),

                  // Paginação
                  Container(
                    color: Colors.white.withValues(alpha: 0.01),
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: _currentPage > 1
                              ? () => setState(() => _currentPage -= 1)
                              : null,
                          child: const Text(
                            "Anterior",
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                        Text(
                          "Página $_currentPage de ${(_paymentLogs.length / _pageSize).ceil()}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white60,
                          ),
                        ),
                        TextButton(
                          onPressed: endIdx < _paymentLogs.length
                              ? () => setState(() => _currentPage += 1)
                              : null,
                          child: const Text(
                            "Próximo",
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    String subText,
    IconData icon,
  ) {
    return Container(
      decoration: LiquidTheme.glassDecoration(radius: 16),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: Colors.white60,
                ),
              ),
              Icon(icon, color: LiquidTheme.primary, size: 18),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Outfit',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subText,
            style: const TextStyle(fontSize: 11, color: LiquidTheme.secondary),
          ),
        ],
      ),
    );
  }
}
