import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// Xin quyền đọc nhạc (Android 10 → 14)
  Future<bool> requestAudioPermission() async {
    // tránh lỗi Activity chưa sẵn sàng
    await Future.delayed(const Duration(milliseconds: 300));

    if (Platform.isAndroid) {
      // Android 13+ dùng Permission.audio
      var audioStatus = await Permission.audio.status;

      if (audioStatus.isGranted) return true;

      if (audioStatus.isDenied || audioStatus.isRestricted) {
        audioStatus = await Permission.audio.request();
        if (audioStatus.isGranted) return true;
      }

      // fallback cho Android cũ
      var storageStatus = await Permission.storage.status;

      if (storageStatus.isGranted) return true;

      if (storageStatus.isDenied) {
        storageStatus = await Permission.storage.request();
        return storageStatus.isGranted;
      }

      if (audioStatus.isPermanentlyDenied ||
          storageStatus.isPermanentlyDenied) {
        await openAppSettings();
        return false;
      }

      return false;
    }

    // iOS (nếu sau này bạn build)
    return true;
  }

  /// Check nhanh đã có quyền chưa
  Future<bool> hasPermission() async {
    if (Platform.isAndroid) {
      return await Permission.audio.isGranted ||
          await Permission.storage.isGranted;
    }
    return true;
  }

  /// Xin tất cả quyền cần thiết (optional)
  Future<void> requestAllPermissions() async {
    if (Platform.isAndroid) {
      await [Permission.audio, Permission.storage].request();
    }
  }
}
