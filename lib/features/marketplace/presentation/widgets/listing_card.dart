import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/listing_model.dart';

class ListingCard extends StatelessWidget {
  final ListingModel listing;
  final VoidCallback onTap;
  const ListingCard({super.key, required this.listing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.1,
              child: listing.imageUrls.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: listing.imageUrls.first,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: AppColors.lightBorder),
                      errorWidget: (_, __, ___) => Container(
                          color: AppColors.lightBorder,
                          child: const Icon(Icons.image_not_supported_outlined)),
                    )
                  : Container(
                      color: AppColors.lightBorder,
                      child: const Icon(Icons.shopping_bag_outlined, size: 32)),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(listing.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.labelLarge),
                  const SizedBox(height: 4),
                  Text('TZS ${listing.price.toStringAsFixed(0)}',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
                  if (listing.location != null) ...[
                    const SizedBox(height: 2),
                    Text(listing.location!, style: AppTextStyles.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
