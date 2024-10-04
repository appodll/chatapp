import 'dart:convert';

import 'package:chatapp/Controller/AccountSave.dart';
import 'package:chatapp/Screen/Chats_Screen.dart';
import 'package:chatapp/Screen/OTP.dart';
import 'package:chatapp/Screen/OTP_password.dart';
import 'package:chatapp/Screen/forgot_password.dart';
import 'package:chatapp/Screen/loginScreen.dart';
import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;


class Auth extends GetxController{
  Future<void>register(username,email,password,context)async{
    try{
    var url = Uri.parse("http://10.0.2.2:5000/register");
    var created_at = DateTime.now().toIso8601String();
    var response = await http.post(
      url,
      headers: {"Content-Type" : "application/json"},
      body: jsonEncode({
        "username" : username,
        "email" : email,
        "password" : password,
        "created_at" : created_at
      })
    );
    var jsonData = jsonDecode(response.body);
    if (response.statusCode == 200){
      Get.to(OTP(email: email), transition: Transition.upToDown);
      
    }
    DelightToastBar(
      position: DelightSnackbarPosition.top,
      autoDismiss: true,
      animationCurve: Curves.elasticOut,
      builder: (context) {
        return ToastCard(
        leading: Icon(Icons.notification_important_rounded),
        title: Text(jsonData['message'].toString()));
      }  , ).show(context);
    }catch(e){
      print(e.toString());
    }
    

  }

  Future<void>verify_OTP(email ,otp, context)async{
    var url = Uri.parse("http://10.0.2.2:5000/verify_OTP");
    var response = await http.post(
      url,
      headers: {"Content-Type" : "application/json"},
      body: jsonEncode({
        "email" : email,
        "OTP" : otp
      })
      );
    var jsonData = jsonDecode(response.body);
    if (response.statusCode == 200){
      Get.off(LoginScreen(), transition: Transition.downToUp);
    }
    DelightToastBar(
      position: DelightSnackbarPosition.top,
      autoDismiss: true,
      animationCurve: Curves.elasticOut,
      builder: (context) {
        return ToastCard(
        leading: Icon(Icons.notification_important_rounded),
        title: Text(jsonData['message'].toString()));
      }  , ).show(context);
  }

  Future<void>resend_SMTP(email, context)async{
    var url = Uri.parse("http://10.0.2.2:5000/email_SMTP/$email");
    var response = await http.get(
      url,
      headers: {"Content-Type" : "application/json"},
      );
    var jsonData = jsonDecode(response.body);
    DelightToastBar(
      position: DelightSnackbarPosition.top,
      autoDismiss: true,
      animationCurve: Curves.elasticOut,
      builder: (context) {
        return ToastCard(
        leading: Icon(Icons.notification_important_rounded),
        title: Text(jsonData['message'].toString()));
      }  , ).show(context);
  }

  Future<void>login(email,password,context)async{
    var url = Uri.parse("http://10.0.2.2:5000/login");
    var response = await http.post(
      url,
      headers: {"Content-Type" : "application/json"},
      body: jsonEncode({
        "email" : email,
        "password" : password
      })
      );
    var jsonData = jsonDecode(response.body);
    if (response.statusCode == 200){
      await AccountSave().saveData();
      await AccountSave().userinfo_save(email, password);
      Get.off(Chats(), transition: Transition.rightToLeft,
                  duration: Duration(milliseconds: 500));
      //anasayfaya yonlendirecek
    }else{
      if (jsonData['message'] == "Please verify your OTP."){
        Get.to(OTP(email: email));
      }
    }

    DelightToastBar(
      position: DelightSnackbarPosition.top,
      autoDismiss: true,
      animationCurve: Curves.elasticOut,
      builder: (context) {
        return ToastCard(
        leading: Icon(Icons.notification_important_rounded),
        title: Text(jsonData['message'].toString()));
      }  , ).show(context);
  }


  Future<void>forgot_password(email, context)async{
    var url = Uri.parse("http://10.0.2.2:5000/forgot_password");
    var repo = await http.post(
      url,
      headers: {"Content-Type" : "application/json"},
      body: jsonEncode({
        "email" : email
      })
      
      );
      if (repo.statusCode == 200){
        Get.to(OTP_password(email: email),transition: Transition.rightToLeftWithFade);
      }
      var jsonData = jsonDecode(repo.body);
       DelightToastBar(
      position: DelightSnackbarPosition.top,
      autoDismiss: true,
      animationCurve: Curves.elasticOut,
      builder: (context) {
        return ToastCard(
        leading: Icon(Icons.notification_important_rounded),
        title: Text(jsonData['message'].toString()));
      }  , ).show(context);
  }

  Future<void>password_verify_OTP(otp, email, context)async{
    var url = Uri.parse("http://10.0.2.2:5000/password_verify_OTP");
    var repo  = await http.post(url,
    headers: {"Content-Type" : "application/json"},
    body: jsonEncode({
      "OTP" : otp,
      "email" : email
    })
    );
    if (repo.statusCode == 200){
      Get.off(ForgotPasword(email: email),transition: Transition.rightToLeftWithFade);
    }
    var jsonData = jsonDecode(repo.body);
    DelightToastBar(
      position: DelightSnackbarPosition.top,
      autoDismiss: true,
      animationCurve: Curves.elasticOut,
      builder: (context) {
        return ToastCard(
        leading: Icon(Icons.notification_important_rounded),
        title: Text(jsonData['message'].toString()));
      }  , ).show(context);
  }

  Future<void>reset_password(email, password, context)async{
    var url = Uri.parse("http://10.0.2.2:5000/reset_password");
    var repo = await http.post(
      url,
      headers: {"Content-Type" : "application/json"},
      body: jsonEncode({
        "email" : email,
        "password" : password
      })
      );
      if (repo.statusCode == 200){
        Get.off(LoginScreen());
      }
      var jsonData = jsonDecode(repo.body);
      DelightToastBar(
      position: DelightSnackbarPosition.top,
      autoDismiss: true,
      animationCurve: Curves.elasticOut,
      builder: (context) {
        return ToastCard(
        leading: Icon(Icons.notification_important_rounded),
        title: Text(jsonData['message'].toString()));
      }  , ).show(context);
  }

  Future<void>forgot_password_resendOTP(email,context)async{
    var url = Uri.parse("http://10.0.2.2:5000/forgot_password_resendOTP");
    var repo = await http.post(
      url,
      headers: {"Content-Type" : "application/json"},
      body: jsonEncode({
        "email" : email
      })
      );
      var jsonData = jsonDecode(repo.body);
      DelightToastBar(
      position: DelightSnackbarPosition.top,
      autoDismiss: true,
      animationCurve: Curves.elasticOut,
      builder: (context) {
        return ToastCard(
        leading: Icon(Icons.notification_important_rounded),
        title: Text(jsonData['message'].toString()));
      }  , ).show(context);
  }

}