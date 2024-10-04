import 'dart:io';

import 'package:chatapp/Controller/ProfileController.dart';
import 'package:chatapp/Controller/UserController.dart';
import 'package:chatapp/Controller/groupElementController.dart';
import 'package:chatapp/Controller/messageController.dart';
import 'package:chatapp/Model/AllAccount.dart';
import 'package:chatapp/Model/Friends.dart';
import 'package:chatapp/Screen/Message_Screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Chats extends StatefulWidget {
  Chats({super.key});

  @override
  State<Chats> createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
 
  Future<void>loadData()async{
    final users_controller = Get.put(Usercontroller());
    final profile_controller = Get.put(Profilecontroller());
    final group_controller = Get.put(Groupelementcontroller());
    await profile_controller.my_account_info(); // id 
    await profile_controller.get_username(); // username
    await profile_controller.get_profileImage(); // profile_image
    await users_controller.get_all_users(); // all users
    await group_controller.all_friends(int.parse(profile_controller.my_id.value)); // friendsler
  }
  Future<void>resfreshPage()async{
    return loadData();
  }
  RxBool value_bool = RxBool(false);
  List filteredUsers = [];
  
  @override
  void initState() {
    super.initState();
    loadData();
  }
  Widget build(BuildContext context) {

  final users_controller = Get.put(Usercontroller());
  final profile_controller = Get.put(Profilecontroller());
  final group_controller = Get.put(Groupelementcontroller());
  final message_controller = Get.put(Messagecontroller());
  /////////////////////SEARCH FUNCTION/////////////////////////
  void filterUsers(enterKeyword) {
    setState(() {
      filteredUsers = users_controller.all_users.value.where((p0) =>
              p0['name'].toLowerCase().startsWith(enterKeyword.toLowerCase()))
          .toList();    
    });
  }
    var itemcount = (MediaQuery.of(context).size.height/150).floor();
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() => RefreshIndicator(
        onRefresh: resfreshPage,
        child: SafeArea(
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                            onPressed: () async{
                              await profile_controller.uploadImage(profile_controller.username);
                              await Future.delayed(Duration(milliseconds: 500));
                              profile_controller.get_profileImage();
                              
                            },
                            icon: Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(image: NetworkImage(profile_controller.profile_image.value), fit: BoxFit.cover)
                              ),
                            )),
                            SizedBox(width: 4,),
                        Text(
                          profile_controller.username.value,
                          style: GoogleFonts.montserrat(
                              fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 12),
                        child: Text(
                          "Messages",
                          style: GoogleFonts.montserrat(
                              fontSize: 35, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SizedBox(height: 20,),
                    Container(
                      width: Get.width - 50,
                      child: TextField(
                        onChanged: (value){
                          setState(() {
                            if (value == ""){
                              value_bool.value = false;
                          }else{
                            value_bool.value = true;
                            filterUsers(value);
                          }
                          });
                          
                        },
                        decoration: InputDecoration(
                          hintStyle: GoogleFonts.montserrat(
                            fontSize: 17,
                            fontWeight: FontWeight.w500
                          ),
                            prefixIcon: Icon(Icons.search),
                            filled: true,
                            fillColor: Color.fromRGBO(241, 244, 255, 1),
                            hintText: "Search ...",
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(13),
                                borderSide: BorderSide(
                                    color: Color.fromARGB(255, 3, 0, 182))),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.transparent))),
                      ),
                    ),
                    SizedBox(height: 25,),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 15),
                            child: Text("Friends", style: GoogleFonts.montserrat(
                              fontSize: 19,
                              fontWeight: FontWeight.bold
                            ),),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: TextButton(onPressed: (){}, child: Row(
                              children: [
                                Text("All", style: GoogleFonts.montserrat(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 3, 0, 182),
                      
                                ),),
                                Icon(Icons.chevron_right_rounded ,color: Color.fromARGB(255, 3, 0, 182),)
                              ],
                            )))
                        ],
                      ),
                      group_controller.friends.isEmpty?Center(child: Text("Your friendship list is empty.", 
                      style: GoogleFonts.montserrat(fontSize: 15),)):Container(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: group_controller.friends.value.length,
                          itemBuilder: (context, index) {
                            var name = group_controller.friends[index]['name'];
                            return InkWell(
                              onTap: ()async{
                                Get.to(MessageScreen(
                                  sender_id: int.parse(profile_controller.my_id.toString()),
                                  receiver_id: int.parse(group_controller.friends[index]['id'].toString()),
                                  send_message: () async{
                                    RegExp letterRegExp = RegExp(r'^[a-zA-Z]');
                                    if (letterRegExp.hasMatch(message_controller.message_controller.value.text.trim())){
                                      
                                       await group_controller.push_receiver_group_members(int.parse(group_controller.friends[index]['id'].toString()), int.parse(profile_controller.my_id.toString()));
                                      message_controller.send_message(int.parse(profile_controller.my_id.toString()), int.parse(group_controller.friends[index]['id'].toString()), message_controller.message_controller.value.text, "TEXT");
                                      message_controller.message_controller.value.clear();
                                    }
                                     
                                  },
                                  profile_image: "http://10.0.2.2:5000/get_profile_image?email=${group_controller.friends[index]["email"]}", 
                                  name: name
                                  ),
                                  transition: Transition.rightToLeft,
                                  duration: Duration(milliseconds: 500));
        
                              },
                              child: Friend(
                                profile_image: "http://10.0.2.2:5000/get_profile_image?email=${group_controller.friends[index]["email"]}", 
                                name: name
                                ));
                          },),
                      ),
                      Container(
                        width: Get.width - 20,
                        height: 1,
                        color: Colors.grey,
                      )
                      ],
                    ),
                    
                    value_bool.value == true?Expanded(
                      child: ListView.builder(
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () async{
                              await group_controller.push_group_members(int.parse(profile_controller.my_id.toString()), int.parse(filteredUsers[index]['id'].toString()), context);
        
                            },
                            child: AllAccount(
                            name: filteredUsers[index]['name'],
                            profile_image: "http://10.0.2.2:5000/get_profile_image?email=${filteredUsers[index]['email']}",
                            content: "Salam",
                            ),
                          );
                        },
                        ),
                    ):Expanded(
                      child: ListView.builder(
                        itemCount: itemcount,
                        itemBuilder: (context, index) {
                          return Column(
        children: [
          SizedBox(height: 20,),
          Padding(
            padding: EdgeInsets.only(left: 20),
            child: Row(
            children: [
              Container(
                child: Container(
                  height: 55,
                  width: 55,
                  decoration: BoxDecoration(       
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(8),
                    
                    gradient: LinearGradient(colors: [
                      Color.fromRGBO(158, 158, 158, 0.2),
                      Color.fromRGBO(158, 158, 158, 0.5)
                    ])
                  ),
                ),
              ),
              SizedBox(width: 20,),
              Column(
                children: [
                  Container(
                    height: 15,
                    width: 70,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Color.fromRGBO(158, 158, 158, 0.2),
                        Color.fromRGBO(158, 158, 158, 0.5)
                      ]),
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(15)
                    ),
                  ),
                  SizedBox(height: 10,),
                Container(
                    height: 10,
                    width: 40,
                    decoration: BoxDecoration(
                      
                      gradient: LinearGradient(colors: [
                        Color.fromRGBO(158, 158, 158, 0.2),
                        Color.fromRGBO(158, 158, 158, 0.5)
                      ]),
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(15)
                    ),
                  ),],
              )
            ],
                  ),
          ),
        SizedBox(height: 10,)
        ],
            );
                      },),
                    )
                  ],
                ),
              ),
      )),
    );
  }
}
