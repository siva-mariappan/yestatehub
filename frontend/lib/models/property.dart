/// YEstateHub Property Data Models

enum PropertyType { apartment, villa, independentHouse, plot, builderFloor, pg }

enum TransactionType { buy, rent, pg, commercial }

enum FurnishingStatus { furnished, semiFurnished, unfurnished }

enum ListedBy { owner, builder, dealer }

class Property {
  final String id;
  final String title;
  final String address;
  final String locality;
  final String city;
  final double price;
  final double? pricePerSqft;
  final int bedrooms;
  final int bathrooms;
  final double areaSqft;
  final int floor;
  final int totalFloors;
  final PropertyType propertyType;
  final TransactionType transactionType;
  final FurnishingStatus furnishing;
  final ListedBy listedBy;
  final String ownerName;
  final List<String> images;
  final List<String> amenities;
  final bool isVerified;
  final bool isReraApproved;
  final bool noBrokerage;
  final String? reraId;
  final String facingDirection;
  final int ageOfBuilding;
  final String possessionStatus;
  final DateTime listedDate;
  final int views;
  final int enquiries;
  final bool isSaved;

  const Property({
    required this.id,
    required this.title,
    required this.address,
    required this.locality,
    required this.city,
    required this.price,
    this.pricePerSqft,
    required this.bedrooms,
    required this.bathrooms,
    required this.areaSqft,
    required this.floor,
    required this.totalFloors,
    required this.propertyType,
    required this.transactionType,
    required this.furnishing,
    required this.listedBy,
    required this.ownerName,
    required this.images,
    required this.amenities,
    this.isVerified = false,
    this.isReraApproved = false,
    this.noBrokerage = false,
    this.reraId,
    required this.facingDirection,
    required this.ageOfBuilding,
    required this.possessionStatus,
    required this.listedDate,
    this.views = 0,
    this.enquiries = 0,
    this.isSaved = false,
  });

  String get formattedPrice {
    if (price >= 10000000) {
      return '${(price / 10000000).toStringAsFixed(2)} Cr';
    } else if (price >= 100000) {
      return '${(price / 100000).toStringAsFixed(1)} L';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)}K';
    }
    return price.toStringAsFixed(0);
  }

  String get bhkLabel {
    if (propertyType == PropertyType.plot) return 'Plot';
    return '$bedrooms BHK';
  }

  String get areaLabel => '${areaSqft.toStringAsFixed(0)} sq.ft';
  String get floorLabel => '$floor of $totalFloors floors';
}

class PropertyFilter {
  final TransactionType? transactionType;
  final double? minPrice;
  final double? maxPrice;
  final List<int> bedrooms;
  final List<PropertyType> propertyTypes;
  final FurnishingStatus? furnishing;
  final ListedBy? listedBy;
  final bool? noBrokerage;
  final bool? readyToMove;
  final bool? verified;
  final String? sortBy;

  const PropertyFilter({
    this.transactionType,
    this.minPrice,
    this.maxPrice,
    this.bedrooms = const [],
    this.propertyTypes = const [],
    this.furnishing,
    this.listedBy,
    this.noBrokerage,
    this.readyToMove,
    this.verified,
    this.sortBy,
  });

  PropertyFilter copyWith({
    TransactionType? transactionType,
    double? minPrice,
    double? maxPrice,
    List<int>? bedrooms,
    List<PropertyType>? propertyTypes,
    FurnishingStatus? furnishing,
    ListedBy? listedBy,
    bool? noBrokerage,
    bool? readyToMove,
    bool? verified,
    String? sortBy,
  }) {
    return PropertyFilter(
      transactionType: transactionType ?? this.transactionType,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      bedrooms: bedrooms ?? this.bedrooms,
      propertyTypes: propertyTypes ?? this.propertyTypes,
      furnishing: furnishing ?? this.furnishing,
      listedBy: listedBy ?? this.listedBy,
      noBrokerage: noBrokerage ?? this.noBrokerage,
      readyToMove: readyToMove ?? this.readyToMove,
      verified: verified ?? this.verified,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

class LocalityScore {
  final String name;
  final double connectivity;
  final double safety;
  final double lifestyle;
  final double environment;
  final double valueForMoney;

  const LocalityScore({
    required this.name,
    required this.connectivity,
    required this.safety,
    required this.lifestyle,
    required this.environment,
    required this.valueForMoney,
  });

  double get overall =>
      (connectivity + safety + lifestyle + environment + valueForMoney) / 5;
}

class PriceTrend {
  final String quarter;
  final double pricePerSqft;

  const PriceTrend({required this.quarter, required this.pricePerSqft});
}

class ServiceCategory {
  final String id;
  final String name;
  final String icon;
  final String description;
  final String imageUrl;
  final String? offerText;
  final bool isFeatured;

  const ServiceCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    this.imageUrl = '',
    this.offerText,
    this.isFeatured = false,
  });
}
