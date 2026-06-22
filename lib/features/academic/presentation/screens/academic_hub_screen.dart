import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../data/models/resource_model.dart';
import '../providers/academic_provider.dart';

class AcademicHubScreen extends ConsumerStatefulWidget {
  const AcademicHubScreen({super.key});
  @override
  ConsumerState<AcademicHubScreen> createState() => _AcademicHubScreenState();
}

class _AcademicHubScreenState extends ConsumerState<AcademicHubScreen> {
  ResourceType? _type;

  @override
  Widget build(BuildContext context) {
    final params = ResourcesParams(type: _type);
    final resourcesAsync = ref.watch(resourcesProvider(params));

    return Scaffold(
      appBar: AppBar(title: const Text('Academic Hub')),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(label: const Text('All'), selected: _type == null, onSelected: (_) => setState(() => _type = null)),
                ),
                for (final t in ResourceType.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(label: Text(t.label), selected: _type == t, onSelected: (_) => setState(() => _type = t)),
                  ),
              ],
            ),
          ),
          Expanded(
            child: resourcesAsync.when(
              loading: () => const LoadingIndicator(),
              error: (e, _) => Center(child: Text('$e')),
              data: (resources) {
                if (resources.isEmpty) {
                  return const EmptyState(icon: Icons.menu_book_outlined, title: 'No resources yet');
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: resources.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final r = resources[i];
                    return Card(
                      child: ListTile(
                        onTap: () => context.push('/academic/${r.id}'),
                        leading: CircleAvatar(child: Text(r.courseCode.isNotEmpty ? r.courseCode[0] : '?')),
                        title: Text(r.title, style: AppTextStyles.labelLarge),
                        subtitle: Text('${r.courseCode} • ${r.type.label}'),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.download_outlined, size: 16),
                            Text('${r.downloadCount}', style: AppTextStyles.caption),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/academic/upload'),
        child: const Icon(Icons.upload_file_outlined),
      ),
    );
  }
}
