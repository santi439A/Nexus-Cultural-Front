class ArtisanModel {
  final String id;
  final String name;
  final String community;
  final String department;
  final String municipality;
  final String avatarUrl;
  final String bio;
  final bool verified;
  final int yearsOfExperience;
  final List<String> techniques;
  final String phone;
  final double rating;
  final int reviewsCount;
  final String? voiceStoryAudioUrl;

  const ArtisanModel({
    required this.id,
    required this.name,
    required this.community,
    required this.department,
    required this.municipality,
    required this.avatarUrl,
    required this.bio,
    this.verified = true,
    required this.yearsOfExperience,
    required this.techniques,
    required this.phone,
    this.rating = 4.9,
    this.reviewsCount = 48,
    this.voiceStoryAudioUrl,
  });

  factory ArtisanModel.fromJson(Map<String, dynamic> json) {
    return ArtisanModel(
      id: json['id'] as String,
      name: json['name'] as String,
      community: json['community'] as String,
      department: json['department'] as String,
      municipality: json['municipality'] as String,
      avatarUrl: json['avatarUrl'] as String,
      bio: json['bio'] as String,
      verified: json['verified'] as bool? ?? true,
      yearsOfExperience: json['yearsOfExperience'] as int? ?? 30,
      techniques: List<String>.from(json['techniques'] as List),
      phone: json['phone'] as String,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.9,
      reviewsCount: json['reviewsCount'] as int? ?? 48,
      voiceStoryAudioUrl: json['voiceStoryAudioUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'community': community,
    'department': department,
    'municipality': municipality,
    'avatarUrl': avatarUrl,
    'bio': bio,
    'verified': verified,
    'yearsOfExperience': yearsOfExperience,
    'techniques': techniques,
    'phone': phone,
    'rating': rating,
    'reviewsCount': reviewsCount,
    'voiceStoryAudioUrl': voiceStoryAudioUrl,
  };
}

class ProductModel {
  final String id;
  final String name;
  final String tagline;
  final String category;
  final String region;
  final String department;
  final double price;
  final ArtisanModel artisan;
  final List<String> images;
  final double rating;
  final int reviewsCount;
  final String storyQuote;
  final String technique;
  final String craftingTime;
  final String symbolism;
  final String dimensions;
  final int stock;
  final bool isFamilyWorkshop;

  const ProductModel({
    required this.id,
    required this.name,
    required this.tagline,
    required this.category,
    required this.region,
    required this.department,
    required this.price,
    required this.artisan,
    required this.images,
    this.rating = 4.9,
    this.reviewsCount = 38,
    required this.storyQuote,
    required this.technique,
    required this.craftingTime,
    required this.symbolism,
    required this.dimensions,
    required this.stock,
    this.isFamilyWorkshop = true,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      tagline: json['tagline'] as String,
      category: json['category'] as String,
      region: json['region'] as String,
      department: json['department'] as String,
      price: (json['price'] as num).toDouble(),
      artisan: ArtisanModel.fromJson(json['artisan'] as Map<String, dynamic>),
      images: List<String>.from(json['images'] as List),
      rating: (json['rating'] as num?)?.toDouble() ?? 4.9,
      reviewsCount: json['reviewsCount'] as int? ?? 38,
      storyQuote: json['storyQuote'] as String,
      technique: json['technique'] as String,
      craftingTime: json['craftingTime'] as String,
      symbolism: json['symbolism'] as String,
      dimensions: json['dimensions'] as String,
      stock: json['stock'] as int,
      isFamilyWorkshop: json['isFamilyWorkshop'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'tagline': tagline,
    'category': category,
    'region': region,
    'department': department,
    'price': price,
    'artisan': artisan.toJson(),
    'images': images,
    'rating': rating,
    'reviewsCount': reviewsCount,
    'storyQuote': storyQuote,
    'technique': technique,
    'craftingTime': craftingTime,
    'symbolism': symbolism,
    'dimensions': dimensions,
    'stock': stock,
    'isFamilyWorkshop': isFamilyWorkshop,
  };
}
