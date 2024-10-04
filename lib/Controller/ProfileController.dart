import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profilecontroller extends GetxController{

  RxString my_id = "".obs;

  RxString username = "".obs;
  RxBool loading = false.obs;
  RxString profile_image = "".obs;
  File? selectfile;
  Future<void>get_username_API(email,password)async{
    loading.value = false;
    var url = Uri.parse("http://10.0.2.2:5000/get_account_info?email=$email&&password=$password");
    var repo = await http.get(
      url,
      headers: {"Content-Type" : "application/json"},
      );
    var jsonData = jsonDecode(repo.body);
    username.value = jsonData['username'];
    loading.value = true;
  }

  Future<void>get_username()async{
    final prefs = await SharedPreferences.getInstance();
    get_username_API(prefs.getString("email"), prefs.getString("password"));
  }

  Future<void>push_profile_image(username, image)async{
    var url = Uri.parse("http://10.0.2.2:5000/push_profile_image?username=${username}");
    var request = await http.MultipartRequest("POST", url);
    request.files.add(await http.MultipartFile.fromPath("profile_image", image.path));
    var repo = await request.send();
    print(repo.statusCode);
  }

  
  Future<void>uploadImage(username)async{
    final picker = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picker != null){
      selectfile = File(picker.path);
      Profilecontroller().push_profile_image(username, selectfile);
    }
    
  }

  
  Future<void>get_profileImage()async{
    final prefs = await SharedPreferences.getInstance();
    var email = prefs.getString("email");
    profile_image.value = "http://10.0.2.2:5000/get_profile_image?email=${email}&timestamp=${DateTime.now().millisecondsSinceEpoch}";
    
  }

  Future<void>my_account_info()async{
    loading.value = false;
    final prefs = await SharedPreferences.getInstance();
    var email = prefs.getString("email");
    var url = Uri.parse("http://10.0.2.2:5000/account_info?email=${email}");
    var repo = await http.get(
      url,
      headers: {"Content-Type" : "application/json"},
      );
    var jsonData = jsonDecode(repo.body);

    my_id.value = jsonData['id'].toString();
    loading.value = true;
  }

  
}