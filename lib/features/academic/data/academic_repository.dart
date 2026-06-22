import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/failure.dart';
import 'models/resource_model.dart';

class AcademicRepository {
  final SupabaseClient _client;
  AcademicRepository(this._client);

  Future<Either<Failure, List<ResourceModel>>> getResources({String? courseCode, ResourceType? type, String? search}) async {
    try {
      var query = _client.from(Tables.resources).select('*, uploader:uploader_id ( username )');
      if (courseCode != null) query = query.eq('course_code', courseCode);
      if (type != null) query = query.eq('type', type.value);
      if (search != null && search.isNotEmpty) query = query.ilike('title', '%$search%');
      final data = await query.order('created_at', ascending: false);
      return Right((data as List).map((e) => ResourceModel.fromJson(e as Map<String, dynamic>)).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<String>>> getCourses() async {
    try {
      final data = await _client.from(Tables.courses).select('code').order('code');
      return Right((data as List).map((e) => e['code'] as String).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, ResourceModel>> uploadResource(ResourceModel resource) async {
    try {
      final data = await _client
          .from(Tables.resources)
          .insert(resource.toInsertJson())
          .select('*, uploader:uploader_id ( username )')
          .single();
      return Right(ResourceModel.fromJson(data));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> incrementDownload(String id) async {
    try {
      await _client.rpc('increment_resource_downloads', params: {'resource_id': id});
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
