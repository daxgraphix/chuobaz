import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/marketplace_provider.dart';

class ListingDetailScreen extends ConsumerWidget {
  final String listingId;
  const ListingDetailScreen({super.key, required this.listingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingAsync = ref.watch(listingDetailProvider(listingId));
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      body: listingAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(child: Text('$e')),
        data: (listing) {
          if (listing == null) return const Center(child: Text('Listing not found'));
          final isOwner = user?.id == listing.sellerId;
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 280,
                flexibleSpace: FlexibleSpaceBar(
                  background: listing.imageUrls.isNotEmpty
                      ? PageView(
                          children: listing.imageUrls
                              .map((url) => CachedNetworkImage(imageUrl: url, fit: BoxFit.cover))
                              .toList(),
                        )
                      : Container(color: AppColors.lightBorder, child: const Icon(Icons.shopping_bag_outlined, size: 56)),
                ),
                actions: [
                  if (isOwner)
                    PopupMenuButton<String>(
                      onSelected: (v) async {
                        final repo = ref.read(marketplaceRepositoryProvider);
                        if (v == 'sold') await repo.markSold(listing.id);
                        if (v == 'delete') await repo.deleteListing(listing.id);
                        ref.invalidate(listingDetailProvider(listingId));
                        if (v == 'delete' && context.mounted) Navigator.pop(context);
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'sold', child: Text('Mark as sold')),
                        PopupMenuItem(value: 'delete', child: Text('Delete listing')),
                      ],
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.flag_outlined),
                      onPressed: () {},
                    ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (listing.isSold)
                        Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                          child: const Text('SOLD', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
                        ),
                      Text(listing.title, style: AppTextStyles.h2),
                      const SizedBox(height: 6),
                      Text('TZS ${listing.price.toStringAsFixed(0)}',
                          style: AppTextStyles.h3.copyWith(color: AppColors.primary)),
                      if (listing.location != null) ...[
                        const SizedBox(height: 4),
                        Row(children: [
                          const Icon(Icons.location_on_outlined, size: 16, color: AppColors.lightTextSecondary),
                          const SizedBox(width: 4),
                          Text(listing.location!, style: AppTextStyles.bodySmall),
                        ]),
                      ],
                      const Divider(height: 32),
                      Text('Description', style: AppTextStyles.h3),
                      const SizedBox(height: 6),
                      Text(listing.description, style: AppTextStyles.bodyMedium),
                      const Divider(height: 32),
                      Row(children: [
                        UserAvatar(avatarUrl: listing.sellerAvatarUrl, displayName: listing.sellerUsername ?? 'Seller', radius: 20),
                        const SizedBox(width: 10),
                        Text(listing.sellerUsername ?? 'Seller', style: AppTextStyles.labelLarge),
                      ]),
                      const SizedBox(height: 20),
                      if (!isOwner)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: listing.sellerPhone == null
                                ? null
                                : () => launchUrl(Uri.parse('https://wa.me/${listing.sellerPhone}')),
                            icon: const Icon(Icons.chat_outlined),
                            label: const Text('Contact Seller'),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
