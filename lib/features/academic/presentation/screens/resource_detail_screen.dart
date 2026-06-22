import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../providers/academic_provider.dart';

class ResourceDetailScreen extends ConsumerWidget {
  final String resourceId;
  const ResourceDetailScreen({super.key, required this.resourceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resourcesAsync = ref.watch(resourcesProvider(const ResourcesParams()));
    return Scaffold(
      appBar: AppBar(title: const Text('Resource')),
      body: resourcesAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(child: Text('$e')),
        data: (resources) {
          final resource = resources.where((r) => r.id == resourceId).firstOrNull;
          if (resource == null) return const Center(child: Text('Resource not found'));
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(resource.title, style: AppTextStyles.h2),
                const SizedBox(height: 6),
                Text('${resource.courseCode} • ${resource.type.label}', style: AppTextStyles.bodySmall),
                if (resource.description != null) ...[
                  const SizedBox(height: 16),
                  Text(resource.description!, style: AppTextStyles.bodyMedium),
                ],
                const SizedBox(height: 16),
                Text('Uploaded by ${resource.uploaderUsername ?? 'a student'}', style: AppTextStyles.caption),
                const SizedBox(height: 28),
                AppButton(
                  label: 'Download (${resource.downloadCount})',
                  icon: Icons.download_outlined,
                  onPressed: () async {
                    await ref.read(academicRepositoryProvider).incrementDownload(resource.id);
                    await launchUrl(Uri.parse(resource.fileUrl));
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
