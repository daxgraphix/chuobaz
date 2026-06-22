import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/supabase_providers.dart';
import '../../data/marketplace_repository.dart';
import '../../data/models/listing_model.dart';

final marketplaceRepositoryProvider =
    Provider((ref) => MarketplaceRepository(ref.watch(supabaseClientProvider)));

class ListingsParams {
  final ListingCategory? category;
  final String? search;
  const ListingsParams({this.category, this.search});
}

final listingsProvider =
    FutureProvider.family<List<ListingModel>, ListingsParams>((ref, params) async {
  final result =
      await ref.watch(marketplaceRepositoryProvider).getListings(category: params.category, search: params.search);
  return result.fold((failure) => throw failure.message, (list) => list);
});

final listingDetailProvider = FutureProvider.family<ListingModel?, String>((ref, id) async {
  final result = await ref.watch(marketplaceRepositoryProvider).getListingById(id);
  return result.fold((failure) => null, (l) => l);
});
