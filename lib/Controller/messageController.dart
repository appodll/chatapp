import 'dart:convert';

import 'package:chatapp/Controller/ProfileController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class Messagecontroller extends GetxController{

  Rx<TextEditingController> message_controller = TextEditingController().obs;
  RxList messages_list = [].obs;
  RxList account_info_list = [].obs;
  Future<void>send_message(sender_id, receiver_id, message, type)async{
    var url = Uri.parse("http://10.0.2.2:5000/send_message");
    http.post(
      url,
      headers: {"Content-Type" : "application/json"},
      body: jsonEncode({
        "sender_id" : sender_id,
        "receiver_id" : receiver_id,
        "message" : message,
        "created_at_message" : DateTime.now().toString(),
        "message_type" : type
      })
      );
  }
  Stream<List<dynamic>>get_messages(sender_id, receiver_id) async* {
    while(true){
      var url = Uri.parse("http://10.0.2.2:5000/get_messages");
      var repo = await http.post(
      url,
      headers: {"Content-Type" : "application/json"},
      body: jsonEncode({
         "sender_id" : sender_id,
         "receiver_id" : receiver_id
      })
      );
      messages_list.value = jsonDecode(repo.body);
      yield messages_list;
      
    }
  }

  Future<void>send_message_file(sender_id, receiver_id, created_at_message, message_type, file)async{
    var url = Uri.parse("http://10.0.2.2:5000/send_message_file?sender_id=${sender_id}&&receiver_id=${receiver_id}&&created_at_message=${created_at_message}&&message_type=${message_type}");
    var request = http.MultipartRequest("POST", url);
    request.files.add(await http.MultipartFile.fromPath("file", file.path));
    await request.send();
  
  }

  
  Future<void>send_message_sound(sender_id, receiver_id, created_at_message, message_type, sound)async{
    var url = Uri.parse("http://10.0.2.2:5000/send_message_sound?sender_id=${sender_id}&&receiver_id=${receiver_id}&&created_at_message=${created_at_message}&&message_type=${message_type}");
    var request = http.MultipartRequest('POST', url);
      if (sound != null) {
        var audioStream = http.ByteStream(sound.openRead());
        var audioLength = await sound.length();
        var multipartFile = http.MultipartFile('sound', audioStream, audioLength, filename: sound.path.split('/').last);
        request.files.add(multipartFile);
  }
  var response = await request.send();
  print(response.statusCode);

  }
  

}