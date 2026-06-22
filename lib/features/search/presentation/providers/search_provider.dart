import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/supabase_providers.dart';
import '../../data/search_repository.dart';

final searchRepositoryProvider = Provider((ref) => SearchRepository(ref.watch(supabaseClientProvider)));

final searchResultsProvider = FutureProvider.family<SearchResults, String>((ref, query) async {
  final result = await ref.watch(searchRepositoryProvider).search(query);
  return result.fold((failure) => const SearchResults(), (r) => r);
});
