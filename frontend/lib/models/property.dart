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
  final String ownerUid;
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
    this.ownerUid = '',
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

  /// JSON serialization for local persistence (camelCase for local, snake_case for API)
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'address': address,
    'locality': locality,
    'city': city,
    'price': price,
    'price_per_sqft': pricePerSqft,
    'bedrooms': bedrooms,
    'bathrooms': bathrooms,
    'area_sqft': areaSqft,
    'floor': floor,
    'total_floors': totalFloors,
    'property_type': propertyType.name,
    'transaction_type': transactionType.name,
    'furnishing': furnishing.name,
    'listed_by': listedBy.name,
    'owner_name': ownerName,
    'owner_uid': ownerUid,
    'images': images,
    'amenities': amenities,
    'is_verified': isVerified,
    'is_rera_approved': isReraApproved,
    'no_brokerage': noBrokerage,
    'rera_id': reraId,
    'facing': facingDirection,
    'age_of_building': ageOfBuilding,
    'possession_status': possessionStatus,
    'created_at': listedDate.toIso8601String(),
    'views': views,
    'enquiries': enquiries,
    'is_saved': isSaved,
  };

  /// Parse property type from string name or int index
  static PropertyType _parsePropertyType(dynamic val) {
    if (val is int && val >= 0 && val < PropertyType.values.length) {
      return PropertyType.values[val];
    }
    if (val is String) {
      const map = {
        'apartment': PropertyType.apartment,
        'villa': PropertyType.villa,
        'independent_house': PropertyType.independentHouse,
        'independentHouse': PropertyType.independentHouse,
        'plot': PropertyType.plot,
        'builder_floor': PropertyType.builderFloor,
        'builderFloor': PropertyType.builderFloor,
        'pg': PropertyType.pg,
      };
      return map[val] ?? PropertyType.apartment;
    }
    return PropertyType.apartment;
  }

  /// Parse transaction type from string name or int index
  static TransactionType _parseTransactionType(dynamic val) {
    if (val is int && val >= 0 && val < TransactionType.values.length) {
      return TransactionType.values[val];
    }
    if (val is String) {
      const map = {
        'buy': TransactionType.buy,
        'rent': TransactionType.rent,
        'pg': TransactionType.pg,
        'commercial': TransactionType.commercial,
      };
      return map[val] ?? TransactionType.buy;
    }
    return TransactionType.buy;
  }

  /// Parse furnishing status from string name or int index
  static FurnishingStatus _parseFurnishing(dynamic val) {
    if (val is int && val >= 0 && val < FurnishingStatus.values.length) {
      return FurnishingStatus.values[val];
    }
    if (val is String) {
      const map = {
        'furnished': FurnishingStatus.furnished,
        'semi_furnished': FurnishingStatus.semiFurnished,
        'semiFurnished': FurnishingStatus.semiFurnished,
        'unfurnished': FurnishingStatus.unfurnished,
      };
      return map[val] ?? FurnishingStatus.unfurnished;
    }
    return FurnishingStatus.unfurnished;
  }

  /// Parse listed by from string name or int index
  static ListedBy _parseListedBy(dynamic val) {
    if (val is int && val >= 0 && val < ListedBy.values.length) {
      return ListedBy.values[val];
    }
    if (val is String) {
      const map = {
        'owner': ListedBy.owner,
        'builder': ListedBy.builder,
        'dealer': ListedBy.dealer,
      };
      return map[val] ?? ListedBy.owner;
    }
    return ListedBy.owner;
  }

  /// Handles both snake_case (API) and camelCase (legacy local cache) keys
  factory Property.fromJson(Map<String, dynamic> json) {
    // Helper to read snake_case or camelCase key
    T? _get<T>(String snakeKey, String camelKey, [T? fallback]) {
      final val = json[snakeKey] ?? json[camelKey];
      if (val == null) return fallback;
      if (val is T) return val;
      return fallback;
    }

    num? _getNum(String snakeKey, String camelKey) {
      final val = json[snakeKey] ?? json[camelKey];
      if (val is num) return val;
      return null;
    }

    return Property(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      title: (json['title'] as String?) ?? '',
      address: (json['address'] as String?) ?? '',
      locality: (json['locality'] as String?) ?? '',
      city: (json['city'] ?? json['district'] ?? '') as String? ?? '',
      price: (_getNum('price', 'price') ?? 0).toDouble(),
      pricePerSqft: _getNum('price_per_sqft', 'pricePerSqft')?.toDouble(),
      bedrooms: (_getNum('bedrooms', 'bedrooms') ?? 0).toInt(),
      bathrooms: (_getNum('bathrooms', 'bathrooms') ?? 0).toInt(),
      areaSqft: (_getNum('area_sqft', 'areaSqft') ?? 0).toDouble(),
      floor: (_getNum('floor', 'floor') ?? 0).toInt(),
      totalFloors: (_getNum('total_floors', 'totalFloors') ?? 0).toInt(),
      propertyType: _parsePropertyType(json['property_type'] ?? json['propertyType']),
      transactionType: _parseTransactionType(json['transaction_type'] ?? json['transactionType']),
      furnishing: _parseFurnishing(json['furnishing']),
      listedBy: _parseListedBy(json['listed_by'] ?? json['listedBy']),
      ownerName: (json['owner_name'] ?? json['ownerName'] ?? json['contact_name'] ?? '') as String? ?? '',
      ownerUid: (json['owner_uid'] ?? json['ownerUid'] ?? '') as String? ?? '',
      images: List<String>.from(json['images'] ?? []),
      amenities: List<String>.from(json['amenities'] ?? []),
      isVerified: (json['is_verified'] ?? json['isVerified'] ?? false) as bool? ?? false,
      isReraApproved: (json['is_rera_approved'] ?? json['isReraApproved'] ?? false) as bool? ?? false,
      noBrokerage: (json['no_brokerage'] ?? json['noBrokerage'] ?? false) as bool? ?? false,
      reraId: (json['rera_id'] ?? json['reraId']) as String?,
      facingDirection: (json['facing'] ?? json['facingDirection'] ?? '') as String? ?? '',
      ageOfBuilding: (_getNum('age_of_building', 'ageOfBuilding') ?? 0).toInt(),
      possessionStatus: (json['possession_status'] ?? json['possessionStatus'] ?? '') as String? ?? '',
      listedDate: DateTime.tryParse(
          (json['created_at'] ?? json['listedDate'] ?? '').toString()) ?? DateTime.now(),
      views: (_getNum('views', 'views') ?? 0).toInt(),
      enquiries: (_getNum('enquiries', 'enquiries') ?? 0).toInt(),
      isSaved: (json['is_saved'] ?? json['isSaved'] ?? false) as bool? ?? false,
    );
  }
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
