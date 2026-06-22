import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/failure.dart';

class PlatformMetrics {
  final int dau;
  final int mau;
  final int activeCommunities;
  final int totalUsers;
  final int totalPosts;
  final double retentionRate;
  final List<Map<String, dynamic>> growthSeries;
  final List<Map<String, dynamic>> topPosts;

  const PlatformMetrics({
    this.dau = 0,
    this.mau = 0,
    this.activeCommunities = 0,
    this.totalUsers = 0,
    this.totalPosts = 0,
    this.retentionRate = 0,
    this.growthSeries = const [],
    this.topPosts = const [],
  });
}

class AnalyticsRepository {
  final SupabaseClient _client;
  AnalyticsRepository(this._client);

  Future<Either<Failure, PlatformMetrics>> getMetrics() async {
    try {
      final usersRes = await _client
          .from(Tables.users)
          .select('id', const FetchOptions(count: CountOption.exact, head: true));
      final postsRes = await _client
          .from(Tables.posts)
          .select('id', const FetchOptions(count: CountOption.exact, head: true));
      final commRes = await _client
          .from(Tables.communities)
          .select('id', const FetchOptions(count: CountOption.exact, head: true));

      Map<String, dynamic>? rpcResult;
      try {
        final res = await _client.rpc('get_platform_metrics');
        rpcResult = res as Map<String, dynamic>?;
      } catch (_) {
        // Function not deployed yet; fall back to basic counts
      }

      final topPostsData = await _client
          .from(Tables.posts)
          .select('id, title, comment_count')
          .order('comment_count', ascending: false)
          .limit(5);

      return Right(PlatformMetrics(
        dau: rpcResult?['dau'] as int? ?? 0,
        mau: rpcResult?['mau'] as int? ?? 0,
        activeCommunities: commRes.count ?? 0,
        totalUsers: usersRes.count ?? 0,
        totalPosts: postsRes.count ?? 0,
        retentionRate: (rpcResult?['retention_rate'] as num?)?.toDouble() ?? 0,
        growthSeries: List<Map<String, dynamic>>.from(
            rpcResult?['growth_series'] as List? ?? []),
        topPosts: List<Map<String, dynamic>>.from(topPostsData as List),
      ));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
