import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/failure.dart';

/// Aggregated search results across posts, users, communities, resources,
/// marketplace listings.
class SearchResults {
  final List<Map<String, dynamic>> posts;
  final List<Map<String, dynamic>> users;
  final List<Map<String, dynamic>> communities;
  final List<Map<String, dynamic>> resources;
  final List<Map<String, dynamic>> listings;

  const SearchResults({
    this.posts = const [],
    this.users = const [],
    this.communities = const [],
    this.resources = const [],
    this.listings = const [],
  });

  bool get isEmpty =>
      posts.isEmpty && users.isEmpty && communities.isEmpty && resources.isEmpty && listings.isEmpty;
}

class SearchRepository {
  final SupabaseClient _client;
  SearchRepository(this._client);

  Future<Either<Failure, SearchResults>> search(String query) async {
    if (query.trim().isEmpty) return const Right(SearchResults());
    try {
      final like = '%$query%';
      final results = await Future.wait([
        _client.from(Tables.posts).select('id, title, body').ilike('title', like).limit(10),
        _client.from(Tables.users).select('id, username, display_name, avatar_url').ilike('username', like).limit(10),
        _client.from(Tables.communities).select('id, name, avatar_url').ilike('name', like).limit(10),
        _client.from(Tables.resources).select('id, title, course_code').ilike('title', like).limit(10),
        _client.from(Tables.marketplaceListings).select('id, title, price').ilike('title', like).limit(10),
      ]);
      return Right(SearchResults(
        posts: List<Map<String, dynamic>>.from(results[0] as List),
        users: List<Map<String, dynamic>>.from(results[1] as List),
        communities: List<Map<String, dynamic>>.from(results[2] as List),
        resources: List<Map<String, dynamic>>.from(results[3] as List),
        listings: List<Map<String, dynamic>>.from(results[4] as List),
      ));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
