import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:security_manager/utils.dart';
import 'package:security_manager/view/widgets/app_update_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUpdateInfo {
  final bool hasUpdate;
  final String currentVersion;
  final String storeVersion;
  final String storeUrl;
  final String? releaseNotes;
  final bool isLiveStore;

  AppUpdateInfo({
    required this.hasUpdate,
    required this.currentVersion,
    required this.storeVersion,
    required this.storeUrl,
    this.releaseNotes,
    this.isLiveStore = false,
  });
}

class AppUpdateService {
  static const String androidPackageName = 'com.security.manager.app';
  static const String iosBundleId = 'com.security.manager.app';

  // Prevent showing update popup multiple times in a single session
  static bool _hasCheckedThisSession = false;

  /// Performs background update check and shows dialog if update is available
  static Future<void> checkAndShowUpdateDialog(
    BuildContext context, {
    bool forceShow = false,
  }) async {
    if (!forceShow && _hasCheckedThisSession) {
      return;
    }

    try {
      final updateInfo = await checkUpdate();
      
      if (updateInfo != null) {
        _hasCheckedThisSession = true;

        if (updateInfo.isLiveStore) {
          if (updateInfo.hasUpdate) {
            if (context.mounted) {
              showDialog(
                context: context,
                barrierDismissible: true,
                barrierColor: Colors.black.withValues(alpha: 0.75),
                builder: (dialogContext) => AppUpdateDialog(updateInfo: updateInfo),
              );
            }
          } else if (forceShow && context.mounted) {
            App.showSnackBar(
              title: 'Up to Date',
              message: 'You are using the latest version (${updateInfo.currentVersion}).',
            );
          }
        } else if (forceShow && context.mounted) {
          App.showSnackBar(
            title: 'Local Build',
            message: 'Update check will be active once the app is live on Play Store / App Store.',
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in checkAndShowUpdateDialog: $e');
      }
    }
  }

  /// Core update check logic for iOS and Android
  static Future<AppUpdateInfo?> checkUpdate() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String currentVersion = packageInfo.version;

      if (Platform.isIOS) {
        return await _checkIosUpdate(currentVersion);
      } else if (Platform.isAndroid) {
        return await _checkAndroidUpdate(currentVersion);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching package info or checking version: $e');
      }
    }
    return null;
  }

  /// iOS App Store lookup using iTunes lookup API
  static Future<AppUpdateInfo?> _checkIosUpdate(String currentVersion) async {
    final fallbackUrl = 'https://apps.apple.com/app/id/com.security.manager.app';
    try {
      final url = Uri.parse('https://itunes.apple.com/lookup?bundleId=$iosBundleId');
      final response = await http.get(url).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        final int resultCount = json['resultCount'] ?? 0;

        if (resultCount > 0) {
          final result = json['results'][0];
          final String storeVersion = (result['version'] ?? currentVersion).toString();
          final String trackViewUrl = (result['trackViewUrl'] ?? fallbackUrl).toString();
          final String? releaseNotes = result['releaseNotes']?.toString();

          final bool hasUpdate = _isVersionNewer(storeVersion, currentVersion);

          return AppUpdateInfo(
            hasUpdate: hasUpdate,
            currentVersion: currentVersion,
            storeVersion: storeVersion,
            storeUrl: trackViewUrl,
            releaseNotes: releaseNotes,
            isLiveStore: true,
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('iOS update check error: $e');
      }
    }

    return AppUpdateInfo(
      hasUpdate: false,
      currentVersion: currentVersion,
      storeVersion: currentVersion,
      storeUrl: fallbackUrl,
      isLiveStore: false,
    );
  }

  /// Android Google Play Store version check
  static Future<AppUpdateInfo?> _checkAndroidUpdate(String currentVersion) async {
    const marketUrl = 'market://details?id=$androidPackageName';
    const webUrl = 'https://play.google.com/store/apps/details?id=$androidPackageName';

    try {
      final response = await http.get(
        Uri.parse('$webUrl&hl=en'),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Mobile Safari/537.36',
        },
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final html = response.body;

        String? storeVersion;

        // Try extracting version string from Play Store HTML using common regex patterns
        final versionRegex = RegExp(r'\[\[\[\"(\d+\.\d+(\.\d+)?)\"\]\]');
        final match = versionRegex.firstMatch(html);
        if (match != null) {
          storeVersion = match.group(1);
        } else {
          final altRegex = RegExp(r'\"(\d+\.\d+\.\d+)\"');
          final matches = altRegex.allMatches(html);
          for (final m in matches) {
            final val = m.group(1);
            if (val != null && _isVersionNewer(val, currentVersion)) {
              storeVersion = val;
              break;
            }
          }
        }

        if (storeVersion != null) {
          final bool hasUpdate = _isVersionNewer(storeVersion, currentVersion);
          return AppUpdateInfo(
            hasUpdate: hasUpdate,
            currentVersion: currentVersion,
            storeVersion: storeVersion,
            storeUrl: marketUrl,
            isLiveStore: true,
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Android update check error: $e');
      }
    }

    return AppUpdateInfo(
      hasUpdate: false,
      currentVersion: currentVersion,
      storeVersion: currentVersion,
      storeUrl: marketUrl,
      isLiveStore: false,
    );
  }

  /// Compare store version string with current version string
  static bool _isVersionNewer(String storeVersion, String currentVersion) {
    try {
      final storeParts = storeVersion
          .replaceAll(RegExp(r'[^0-9.]'), '')
          .split('.')
          .map((e) => int.tryParse(e) ?? 0)
          .toList();
      final currentParts = currentVersion
          .replaceAll(RegExp(r'[^0-9.]'), '')
          .split('.')
          .map((e) => int.tryParse(e) ?? 0)
          .toList();

      final maxLength = storeParts.length > currentParts.length ? storeParts.length : currentParts.length;

      for (int i = 0; i < maxLength; i++) {
        final storePart = i < storeParts.length ? storeParts[i] : 0;
        final currentPart = i < currentParts.length ? currentParts[i] : 0;

        if (storePart > currentPart) {
          return true;
        } else if (storePart < currentPart) {
          return false;
        }
      }
    } catch (_) {}
    return false;
  }

  /// Launch store URL (Play Store or App Store)
  static Future<void> launchStore(String storeUrl) async {
    try {
      final Uri uri = Uri.parse(storeUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // If market:// scheme fails, fallback to web https link for Play Store
        if (storeUrl.startsWith('market://')) {
          final fallbackWebUri = Uri.parse('https://play.google.com/store/apps/details?id=$androidPackageName');
          if (await canLaunchUrl(fallbackWebUri)) {
            await launchUrl(fallbackWebUri, mode: LaunchMode.externalApplication);
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error launching store link: $e');
      }
    }
  }
}
