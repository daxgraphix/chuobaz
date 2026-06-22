import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/failure.dart';
import 'models/listing_model.dart';

const _listingSelect = '*, seller:seller_id ( username, avatar_url, phone )';

class MarketplaceRepository {
  final SupabaseClient _client;
  MarketplaceRepository(this._client);

  Future<Either<Failure, List<ListingModel>>> getListings({ListingCategory? category, String? search}) async {
    try {
      var query = _client.from(Tables.marketplaceListings).select(_listingSelect).eq('is_sold', false);
      if (category != null) query = query.eq('category', category.value);
      if (search != null && search.isNotEmpty) query = query.ilike('title', '%$search%');
      final data = await query.order('created_at', ascending: false);
      return Right((data as List).map((e) => ListingModel.fromJson(e as Map<String, dynamic>)).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, ListingModel>> getListingById(String id) async {
    try {
      final data = await _client.from(Tables.marketplaceListings).select(_listingSelect).eq('id', id).single();
      return Right(ListingModel.fromJson(data));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, ListingModel>> createListing(ListingModel listing) async {
    try {
      final data = await _client
          .from(Tables.marketplaceListings)
          .insert(listing.toInsertJson())
          .select(_listingSelect)
          .single();
      return Right(ListingModel.fromJson(data));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> updateListing(String id, Map<String, dynamic> updates) async {
    try {
      await _client.from(Tables.marketplaceListings).update(updates).eq('id', id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> deleteListing(String id) async {
    try {
      await _client.from(Tables.marketplaceListings).delete().eq('id', id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> markSold(String id) =>
      updateListing(id, {'is_sold': true});
}
