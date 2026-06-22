import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../providers/analytics_provider.dart';

class AnalyticsDashboardScreen extends ConsumerWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(platformMetricsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: metricsAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(child: Text('$e')),
        data: (m) {
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(platformMetricsProvider),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    _MetricCard(label: 'Total Users', value: '${m.totalUsers}'),
                    _MetricCard(label: 'Total Posts', value: '${m.totalPosts}'),
                    _MetricCard(label: 'Active Communities', value: '${m.activeCommunities}'),
                    _MetricCard(label: 'Retention', value: '${(m.retentionRate * 100).toStringAsFixed(0)}%'),
                    _MetricCard(label: 'DAU', value: '${m.dau}'),
                    _MetricCard(label: 'MAU', value: '${m.mau}'),
                  ],
                ),
                const SizedBox(height: 24),
                Text('Growth (Daily Active Users)', style: AppTextStyles.h3),
                const SizedBox(height: 12),
                SizedBox(
                  height: 200,
                  child: m.growthSeries.isEmpty
                      ? const Center(child: Text('No growth data yet — deploy get_platform_metrics() RPC'))
                      : LineChart(
                          LineChartData(
                            gridData: const FlGridData(show: false),
                            titlesData: const FlTitlesData(show: false),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: List.generate(
                                  m.growthSeries.length,
                                  (i) => FlSpot(i.toDouble(), (m.growthSeries[i]['count'] as num).toDouble()),
                                ),
                                isCurved: true,
                                color: AppColors.primary,
                                barWidth: 3,
                                dotData: const FlDotData(show: false),
                              ),
                            ],
                          ),
                        ),
                ),
                const SizedBox(height: 24),
                Text('Top Posts', style: AppTextStyles.h3),
                const SizedBox(height: 8),
                ...m.topPosts.map((p) => ListTile(
                      title: Text(p['title'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: Text('${p['comment_count']} comments'),
                    )),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  const _MetricCard({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value, style: AppTextStyles.h2),
            Text(label, style: AppTextStyles.bodySmall),
          ],
        ),
      ),
    );
  }
}
