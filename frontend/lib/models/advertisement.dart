/// YEstateHub Advertisement Model

class Advertisement {
  final String id;
  final String imageUrl;
  final String externalLink;
  final bool isActive;
  final DateTime createdAt;

  // Text overlay fields
  final String title;
  final String subtitle;
  final String buttonText;
  final String fontFamily; // e.g. 'Poppins', 'Roboto', 'Playfair Display'
  final double titleSize;
  final double subtitleSize;
  final int titleColorValue; // stored as int (0xFFFFFFFF)
  final int subtitleColorValue;
  final int buttonColorValue;
  final int buttonTextColorValue;
  final int overlayColorValue; // semi-transparent overlay on image
  final double overlayOpacity;
  final String textAlign; // 'left', 'center', 'right'

  const Advertisement({
    required this.id,
    this.imageUrl = '',
    this.externalLink = '',
    this.isActive = true,
    required this.createdAt,
    this.title = '',
    this.subtitle = '',
    this.buttonText = '',
    this.fontFamily = 'Poppins',
    this.titleSize = 28,
    this.subtitleSize = 14,
    this.titleColorValue = 0xFFFFFFFF,
    this.subtitleColorValue = 0xFFFFFFFF,
    this.buttonColorValue = 0xFF10B981,
    this.buttonTextColorValue = 0xFFFFFFFF,
    this.overlayColorValue = 0xFF000000,
    this.overlayOpacity = 0.3,
    this.textAlign = 'left',
  });

  Advertisement copyWith({
    String? imageUrl,
    String? externalLink,
    bool? isActive,
    String? title,
    String? subtitle,
    String? buttonText,
    String? fontFamily,
    double? titleSize,
    double? subtitleSize,
    int? titleColorValue,
    int? subtitleColorValue,
    int? buttonColorValue,
    int? buttonTextColorValue,
    int? overlayColorValue,
    double? overlayOpacity,
    String? textAlign,
  }) {
    return Advertisement(
      id: id,
      imageUrl: imageUrl ?? this.imageUrl,
      externalLink: externalLink ?? this.externalLink,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      buttonText: buttonText ?? this.buttonText,
      fontFamily: fontFamily ?? this.fontFamily,
      titleSize: titleSize ?? this.titleSize,
      subtitleSize: subtitleSize ?? this.subtitleSize,
      titleColorValue: titleColorValue ?? this.titleColorValue,
      subtitleColorValue: subtitleColorValue ?? this.subtitleColorValue,
      buttonColorValue: buttonColorValue ?? this.buttonColorValue,
      buttonTextColorValue: buttonTextColorValue ?? this.buttonTextColorValue,
      overlayColorValue: overlayColorValue ?? this.overlayColorValue,
      overlayOpacity: overlayOpacity ?? this.overlayOpacity,
      textAlign: textAlign ?? this.textAlign,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'imageUrl': imageUrl,
        'externalLink': externalLink,
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
        'title': title,
        'subtitle': subtitle,
        'buttonText': buttonText,
        'fontFamily': fontFamily,
        'titleSize': titleSize,
        'subtitleSize': subtitleSize,
        'titleColorValue': titleColorValue,
        'subtitleColorValue': subtitleColorValue,
        'buttonColorValue': buttonColorValue,
        'buttonTextColorValue': buttonTextColorValue,
        'overlayColorValue': overlayColorValue,
        'overlayOpacity': overlayOpacity,
        'textAlign': textAlign,
      };

  factory Advertisement.fromJson(Map<String, dynamic> json) {
    // Handle both snake_case (API) and camelCase (local cache) field names
    // Backend uses: image_url, cta_text, cta_link, status, created_at
    // Frontend uses: imageUrl, buttonText, externalLink, isActive, createdAt

    // Determine isActive from either boolean field or status string
    bool active = true;
    if (json.containsKey('isActive')) {
      active = json['isActive'] as bool? ?? true;
    } else if (json.containsKey('status')) {
      active = (json['status']?.toString().toLowerCase() == 'active');
    }

    return Advertisement(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      imageUrl: (json['imageUrl'] ?? json['image_url'] ?? '') as String,
      externalLink: (json['externalLink'] ?? json['external_link'] ?? json['cta_link'] ?? '') as String,
      isActive: active,
      createdAt: DateTime.tryParse(
              (json['createdAt'] ?? json['created_at'] ?? '').toString()) ??
          DateTime.now(),
      title: (json['title'] ?? '') as String,
      subtitle: (json['subtitle'] ?? '') as String,
      buttonText: (json['buttonText'] ?? json['button_text'] ?? json['cta_text'] ?? '') as String,
      fontFamily: (json['fontFamily'] ?? json['font_family'] ?? 'Poppins') as String,
      titleSize: (json['titleSize'] ?? json['title_size'] as num?)?.toDouble() ?? 28,
      subtitleSize: (json['subtitleSize'] ?? json['subtitle_size'] as num?)?.toDouble() ?? 14,
      titleColorValue: (json['titleColorValue'] ?? json['title_color_value']) as int? ?? 0xFFFFFFFF,
      subtitleColorValue: (json['subtitleColorValue'] ?? json['subtitle_color_value']) as int? ?? 0xFFFFFFFF,
      buttonColorValue: (json['buttonColorValue'] ?? json['button_color_value']) as int? ?? 0xFF10B981,
      buttonTextColorValue: (json['buttonTextColorValue'] ?? json['button_text_color_value']) as int? ?? 0xFFFFFFFF,
      overlayColorValue: (json['overlayColorValue'] ?? json['overlay_color_value']) as int? ?? 0xFF000000,
      overlayOpacity: (json['overlayOpacity'] ?? json['overlay_opacity'] as num?)?.toDouble() ?? 0.3,
      textAlign: (json['textAlign'] ?? json['text_align'] ?? 'left') as String,
    );
  }
}
