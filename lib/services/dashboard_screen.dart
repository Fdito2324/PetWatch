import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pie_chart/pie_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<DashboardStats> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _loadStats();
  }

  Future<DashboardStats> _loadStats() async {
    final snapshot = await FirebaseFirestore.instance.collection('lost_dogs').get();
    final total = snapshot.docs.length;
    final found = snapshot.docs.where((d) => (d.data()['found'] ?? false) as bool).length;
    final lost = total - found;

    double totalMinutes = 0;
    int resolvedCount = 0;
    for (var doc in snapshot.docs.where((d) => (d.data()['found'] ?? false) as bool)) {
      final data = doc.data();
      if (data.containsKey('timestamp') && data.containsKey('foundTimestamp')) {
        final reportedAt = (data['timestamp'] as Timestamp).toDate();
        final foundAt = (data['foundTimestamp'] as Timestamp).toDate();
        totalMinutes += foundAt.difference(reportedAt).inMinutes;
        resolvedCount++;
      }
    }
    final avgResolution = resolvedCount > 0 ? totalMinutes / resolvedCount : 0.0;

    return DashboardStats(
      total: total,
      found: found,
      lost: lost,
      avgResolutionMinutes: avgResolution,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard de Reportes'),
        centerTitle: true,
        elevation: 2,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.primaryColor.withOpacity(0.1), theme.primaryColor.withOpacity(0.05)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<DashboardStats>(
          future: _statsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: \${snapshot.error}'));
            }
            final stats = snapshot.data!;
            final dataMap = <String, double>{
              'Encontrados': stats.found.toDouble(),
              'Perdidos': stats.lost.toDouble(),
            };
            final gradientList = [
              [Colors.teal, Colors.tealAccent],
              [Colors.deepOrangeAccent, Colors.orangeAccent],
            ];

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Text(
                            'Reporte de perros en Antofagasta',
                            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              PieChart(
                                dataMap: dataMap,
                                chartType: ChartType.disc,
                                chartRadius: width / 2.2,
                                gradientList: gradientList,
                                legendOptions: const LegendOptions(showLegends: false),
                                chartValuesOptions: ChartValuesOptions(
                                  showChartValues: true,
                                  showChartValuesInPercentage: true,
                                  showChartValuesOutside: true,
                                  decimalPlaces: 0,
                                  chartValueStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                                animationDuration: const Duration(milliseconds: 1000),
                              ),
                              Transform.translate(
                                offset: const Offset(0, -15),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Reportes',
                                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${stats.total}',
                                      style: theme.textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendItem(gradientList[0][0], 'Encontrados'),
                      const SizedBox(width: 24),
                      _buildLegendItem(gradientList[1][0], 'Perdidos'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _buildStatCard(
                        icon: Icons.pets,
                        label: 'Total',
                        value: stats.total.toString(),
                        iconColor: theme.primaryColor,
                      ),
                      _buildStatCard(
                        icon: Icons.check_circle,
                        label: 'Encontrados',
                        value: stats.found.toString(),
                        iconColor: gradientList[0][0],
                      ),
                      _buildStatCard(
                        icon: Icons.error,
                        label: 'Perdidos',
                        value: stats.lost.toString(),
                        iconColor: gradientList[1][0],
                      ),
                      _buildStatCard(
                        icon: Icons.timer,
                        label: 'Tiempo Promedio',
                        value: '${stats.avgResolutionMinutes.toStringAsFixed(1)} min',
                        iconColor: theme.primaryColorDark,
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 64) / 2,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Column(
            children: [
              Icon(icon, color: iconColor, size: 32),
              const SizedBox(height: 8),
              Text(label, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardStats {
  final int total;
  final int found;
  final int lost;
  final double avgResolutionMinutes;

  DashboardStats({
    required this.total,
    required this.found,
    required this.lost,
    required this.avgResolutionMinutes,
  });
}
