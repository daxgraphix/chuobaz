import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/supabase_providers.dart';
import '../../data/comment_repository.dart';
import '../../data/models/comment_model.dart';

final commentRepositoryProvider = Provider((ref) => CommentRepository(ref.watch(supabaseClientProvider)));

final commentsProvider =
    FutureProvider.family<List<CommentModel>, String>((ref, postId) async {
  final result = await ref.watch(commentRepositoryProvider).getComments(postId);
  return result.fold((failure) => throw failure.message, (comments) => comments);
});
