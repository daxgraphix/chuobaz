import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/supabase_providers.dart';
import '../../data/academic_repository.dart';
import '../../data/models/resource_model.dart';

final academicRepositoryProvider = Provider((ref) => AcademicRepository(ref.watch(supabaseClientProvider)));

class ResourcesParams {
  final String? courseCode;
  final ResourceType? type;
  final String? search;
  const ResourcesParams({this.courseCode, this.type, this.search});
}

final resourcesProvider = FutureProvider.family<List<ResourceModel>, ResourcesParams>((ref, params) async {
  final result = await ref
      .watch(academicRepositoryProvider)
      .getResources(courseCode: params.courseCode, type: params.type, search: params.search);
  return result.fold((failure) => throw failure.message, (list) => list);
});

final coursesProvider = FutureProvider<List<String>>((ref) async {
  final result = await ref.watch(academicRepositoryProvider).getCourses();
  return result.fold((failure) => [], (list) => list);
});
