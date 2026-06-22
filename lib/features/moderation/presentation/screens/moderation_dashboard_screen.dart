import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../providers/moderation_provider.dart';

class ModerationDashboardScreen extends ConsumerStatefulWidget {
  const ModerationDashboardScreen({super.key});
  @override
  ConsumerState<ModerationDashboardScreen> createState() => _ModerationDashboardScreenState();
}

class _ModerationDashboardScreenState extends ConsumerState<ModerationDashboardScreen> {
  ReportStatus? _filter = ReportStatus.pending;

  @override
  Widget build(BuildContext context) {
    final reportsAsync = ref.watch(reportsProvider(_filter));
    return Scaffold(
      appBar: AppBar(title: const Text('Moderation')),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              children: [
                Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(label: const Text('All'), selected: _filter == null, onSelected: (_) => setState(() => _filter = null))),
                for (final s in ReportStatus.values)
                  Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(label: Text(s.name), selected: _filter == s, onSelected: (_) => setState(() => _filter = s))),
              ],
            ),
          ),
          Expanded(
            child: reportsAsync.when(
              loading: () => const LoadingIndicator(),
              error: (e, _) => Center(child: Text('$e')),
              data: (reports) {
                if (reports.isEmpty) return const EmptyState(icon: Icons.shield_outlined, title: 'No reports here');
                return ListView.separated(
                  itemCount: reports.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final r = reports[i];
                    return ListTile(
                      title: Text(r.reason, style: AppTextStyles.labelLarge),
                      subtitle: Text('${r.targetType} • reported by @${r.reporterUsername ?? 'unknown'} • ${DateFormatter.relative(r.createdAt)}'),
                      trailing: PopupMenuButton<String>(
                        onSelected: (v) async {
                          final repo = ref.read(moderationRepositoryProvider);
                          if (v == 'hide') await repo.hideContent(r.targetId, r.targetType);
                          if (v == 'dismiss') await repo.resolveReport(r.id, ReportStatus.dismissed);
                          if (v == 'actioned') await repo.resolveReport(r.id, ReportStatus.actioned);
                          ref.invalidate(reportsProvider(_filter));
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'hide', child: Text('Hide content')),
                          PopupMenuItem(value: 'actioned', child: Text('Mark actioned')),
                          PopupMenuItem(value: 'dismiss', child: Text('Dismiss')),
                        ],
                      ),
                      onTap: () {
                        if (r.targetType == 'post') context.push('/posts/${r.targetId}');
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
