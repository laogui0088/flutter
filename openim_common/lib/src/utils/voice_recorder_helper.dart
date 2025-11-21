import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:openim_common/openim_common.dart';

class VoiceRecorderHelper {
  static Future<bool> checkAndRequestPermission() async {
    try {
      final status = await Permission.microphone.status;
      
      if (status == PermissionStatus.granted) {
        return true;
      }
      
      if (status == PermissionStatus.denied) {
        final result = await Permission.microphone.request();
        if (result == PermissionStatus.granted) {
          return true;
        } else {
          IMViews.showToast('需要录音权限才能发送语音消息');
          return false;
        }
      }
      
      if (status == PermissionStatus.permanentlyDenied) {
        IMViews.showToast('录音权限被拒绝，请在设置中开启');
        return false;
      }
      
      return false;
    } catch (e) {
      IMViews.showToast('权限检查失败');
      return false;
    }
  }
  
  static RecordConfig getDefaultRecordConfig() {
    return RecordConfig(
      encoder: AudioEncoder.aacLc,
      bitRate: 128000,
      sampleRate: 44100,
    );
  }
  
  static Future<String> createRecordPath() async {
    final dir = await IMUtils.createTempDir(dir: "voice");
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '$dir/$timestamp.m4a';
  }
  
  static bool isValidRecordDuration(int duration) {
    return duration > 0 && duration >= 1; // 至少1秒
  }
  
  static void cleanupRecordFile(String path) {
    try {
      final file = File(path);
      if (file.existsSync()) {
        file.deleteSync();
      }
    } catch (e) {
      // 静默处理文件删除错误
    }
  }
}