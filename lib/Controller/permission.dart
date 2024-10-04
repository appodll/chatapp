import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionController {
  Future<void> requestPermission()async{
    final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
    final status = await Permission.microphone.request();
    if (status.isGranted){
      _recorder.startRecorder();
    }else if(status.isDenied){
      print('microphone denied');
    }else if(status.isPermanentlyDenied){
      openAppSettings();
    }
    
  }
}