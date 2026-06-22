import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../providers/marketplace_provider.dart';
import '../widgets/listing_card.dart';

class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});
  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen> {
  ListingCategory? _category;

  @override
  Widget build(BuildContext context) {
    final params = ListingsParams(category: _category);
    final listingsAsync = ref.watch(listingsProvider(params));

    return Scaffold(
      appBar: AppBar(title: const Text('Marketplace')),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: const Text('All'),
                    selected: _category == null,
                    onSelected: (_) => setState(() => _category = null),
                  ),
                ),
                for (final c in ListingCategory.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(c.label),
                      selected: _category == c,
                      onSelected: (_) => setState(() => _category = c),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: listingsAsync.when(
              loading: () => const LoadingIndicator(),
              error: (e, _) => Center(child: Text('$e')),
              data: (listings) {
                if (listings.isEmpty) {
                  return const EmptyState(icon: Icons.storefront_outlined, title: 'No listings yet');
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: listings.length,
                  itemBuilder: (_, i) => ListingCard(
                    listing: listings[i],
                    onTap: () => context.push('/marketplace/${listings[i].id}'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/marketplace/create'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
