import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/supabase_providers.dart';
import '../../../auth/data/models/app_user_model.dart';
import '../../data/admin_repository.dart';

final adminRepositoryProvider = Provider((ref) => AdminRepository(ref.watch(supabaseClientProvider)));

final allUsersProvider = FutureProvider.family<List<AppUserModel>, String?>((ref, search) async {
  final result = await ref.watch(adminRepositoryProvider).getUsers(search: search);
  return result.fold((failure) => throw failure.message, (list) => list);
});
