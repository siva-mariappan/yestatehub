import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/advertisement.dart';
import 'api_service.dart';

/// Singleton store for advertisements — syncs with MongoDB API, falls back to SharedPreferences.
class AdvertisementStore extends ChangeNotifier {
  AdvertisementStore._();
  static final AdvertisementStore _instance = AdvertisementStore._();
  static AdvertisementStore get instance => _instance;

  static const String _storageKey = 'yestatehub_advertisements';
  final _api = ApiService();

  final List<Advertisement> _ads = [];
  bool _isLoaded = false;

  List<Advertisement> get ads => List.unmodifiable(_ads);
  List<Advertisement> get activeAds => _ads.where((a) => a.isActive).toList();

  Future<void> init() async {
    if (_isLoaded) return;

    // Try loading from API first
    try {
      final dynamic rawAds = await _api.get('/api/advertisements/active', requireAuth: false);
      final List<dynamic> apiAds = rawAds is List ? rawAds : [];
      _ads.clear();
      _ads.addAll(apiAds.map((j) => Advertisement.fromJson(j as Map<String, dynamic>)));
      _isLoaded = true;
      _persistLocal(); // Cache locally
      notifyListeners();
      return;
    } catch (e) {
      debugPrint('AdvertisementStore API load failed, using local: $e');
    }

    // Fallback to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        _ads.clear();
        _ads.addAll(
            jsonList.map((j) => Advertisement.fromJson(j as Map<String, dynamic>)));
      } catch (e) {
        debugPrint('AdvertisementStore load error: $e');
      }
    }
    _isLoaded = true;
    notifyListeners();
  }

  /// Refresh from API
  Future<void> refresh() async {
    try {
      final dynamic rawAds = await _api.get('/api/advertisements/active', requireAuth: false);
      final List<dynamic> apiAds = rawAds is List ? rawAds : [];
      _ads.clear();
      _ads.addAll(apiAds.map((j) => Advertisement.fromJson(j as Map<String, dynamic>)));
      _persistLocal();
      notifyListeners();
    } catch (e) {
      debugPrint('AdvertisementStore refresh error: $e');
    }
  }

  Future<void> _persistLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(_ads.map((a) => a.toJson()).toList());
      await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      debugPrint('AdvertisementStore persist error: $e');
    }
  }

  Future<void> addAd(Advertisement ad) async {
    _ads.add(ad);
    notifyListeners();
    // Sync to API — send snake_case fields matching backend AdvertisementCreate model
    try {
      final body = {
        'title': ad.title,
        'subtitle': ad.subtitle,
        'image_url': ad.imageUrl,
        'cta_text': ad.buttonText,
        'cta_link': ad.externalLink,
        'status': ad.isActive ? 'active' : 'draft',
        'placement': 'home_carousel',
        'bg_color': '#${ad.overlayColorValue.toRadixString(16).padLeft(8, '0').substring(2)}',
        'text_color': '#${ad.titleColorValue.toRadixString(16).padLeft(8, '0').substring(2)}',
        'start_date': DateTime.now().toIso8601String(),
        'end_date': DateTime.now().add(const Duration(days: 365)).toIso8601String(),
      };
      await _api.post('/api/advertisements/', body: body);
    } catch (e) {
      debugPrint('AdvertisementStore API add error: $e');
    }
    _persistLocal();
  }

  Future<void> updateAd(
    String id, {
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
  }) async {
    final index = _ads.indexWhere((a) => a.id == id);
    if (index == -1) return;
    _ads[index] = _ads[index].copyWith(
      imageUrl: imageUrl,
      externalLink: externalLink,
      isActive: isActive,
      title: title,
      subtitle: subtitle,
      buttonText: buttonText,
      fontFamily: fontFamily,
      titleSize: titleSize,
      subtitleSize: subtitleSize,
      titleColorValue: titleColorValue,
      subtitleColorValue: subtitleColorValue,
      buttonColorValue: buttonColorValue,
      buttonTextColorValue: buttonTextColorValue,
      overlayColorValue: overlayColorValue,
      overlayOpacity: overlayOpacity,
      textAlign: textAlign,
    );
    notifyListeners();
    // Sync to API
    try {
      final updates = <String, dynamic>{};
      if (imageUrl != null) updates['image_url'] = imageUrl;
      if (externalLink != null) updates['external_link'] = externalLink;
      if (isActive != null) updates['is_active'] = isActive;
      if (title != null) updates['title'] = title;
      if (subtitle != null) updates['subtitle'] = subtitle;
      if (buttonText != null) updates['button_text'] = buttonText;
      if (fontFamily != null) updates['font_family'] = fontFamily;
      if (titleSize != null) updates['title_size'] = titleSize;
      if (subtitleSize != null) updates['subtitle_size'] = subtitleSize;
      if (titleColorValue != null) updates['title_color_value'] = titleColorValue;
      if (subtitleColorValue != null) updates['subtitle_color_value'] = subtitleColorValue;
      if (buttonColorValue != null) updates['button_color_value'] = buttonColorValue;
      if (buttonTextColorValue != null) updates['button_text_color_value'] = buttonTextColorValue;
      if (overlayColorValue != null) updates['overlay_color_value'] = overlayColorValue;
      if (overlayOpacity != null) updates['overlay_opacity'] = overlayOpacity;
      if (textAlign != null) updates['text_align'] = textAlign;
      await _api.put('/api/advertisements/$id', body: updates);
    } catch (e) {
      debugPrint('AdvertisementStore API update error: $e');
    }
    _persistLocal();
  }

  Future<void> removeAd(String id) async {
    _ads.removeWhere((a) => a.id == id);
    notifyListeners();
    try {
      await _api.delete('/api/advertisements/$id');
    } catch (e) {
      debugPrint('AdvertisementStore API delete error: $e');
    }
    _persistLocal();
  }

  Advertisement? getById(String id) {
    try {
      return _ads.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Generate a unique ID
  String generateId() => 'ad_${DateTime.now().millisecondsSinceEpoch}';
}
