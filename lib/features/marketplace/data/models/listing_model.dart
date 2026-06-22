import 'package:equatable/equatable.dart';
import '../../../../core/constants/app_constants.dart';

class ListingModel extends Equatable {
  final String id;
  final String sellerId;
  final String title;
  final String description;
  final double price;
  final ListingCategory category;
  final List<String> imageUrls;
  final String? location;
  final bool isSold;
  final bool isSaved;
  final DateTime createdAt;
  final String? sellerUsername;
  final String? sellerAvatarUrl;
  final String? sellerPhone;

  const ListingModel({
    required this.id,
    required this.sellerId,
    required this.title,
    required this.description,
    required this.price,
    this.category = ListingCategory.services,
    this.imageUrls = const [],
    this.location,
    this.isSold = false,
    this.isSaved = false,
    required this.createdAt,
    this.sellerUsername,
    this.sellerAvatarUrl,
    this.sellerPhone,
  });

  factory ListingModel.fromJson(Map<String, dynamic> json) {
    final seller = json['seller'] as Map<String, dynamic>?;
    return ListingModel(
      id: json['id'] as String,
      sellerId: json['seller_id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      category: ListingCategoryX.fromString(json['category'] as String? ?? 'services'),
      imageUrls: (json['image_urls'] as List?)?.map((e) => e.toString()).toList() ?? [],
      location: json['location'] as String?,
      isSold: json['is_sold'] as bool? ?? false,
      isSaved: json['is_saved'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      sellerUsername: seller?['username'] as String?,
      sellerAvatarUrl: seller?['avatar_url'] as String?,
      sellerPhone: seller?['phone'] as String?,
    );
  }

  Map<String, dynamic> toInsertJson() => {
        'seller_id': sellerId,
        'title': title,
        'description': description,
        'price': price,
        'category': category.value,
        'image_urls': imageUrls,
        'location': location,
      };

  @override
  List<Object?> get props => [id, isSold, isSaved];
}
