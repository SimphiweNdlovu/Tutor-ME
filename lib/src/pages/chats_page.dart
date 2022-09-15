import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:tutor_me/services/models/globals.dart';
import 'package:tutor_me/services/services/user_services.dart';
import 'package:tutor_me/src/colorpallete.dart';
import 'package:tutor_me/src/pages/tutors_list.dart';
// import '../../services/models/tutors.dart';
import '../../services/models/users.dart';
import '../Groups/tutee_group.dart';
import '../chat/one_to_one_chat.dart';
// import 'package:tutor_me/modules/api.services.dart';
// import 'package:tutor_me/modules/tutors.dart';
// import 'tutorProfilePages/tutor_profile_view.dart';
// import 'Navigation/nav_drawer.dart';
// import 'tuteeProfilePages/tutee_data.dart';
// import 'theme/themes.dart';

class Chats extends StatefulWidget {
  const Chats({Key? key, required this.globals}) : super(key: key);

  final Globals globals;

  @override
  State<StatefulWidget> createState() {
    return ChatsState();
  }
}

class ChatsState extends State<Chats> {
  bool _isLoading = true;
  List<Tutor> tutorChats = List<Tutor>.empty(growable: true);
  List<Tutee> tuteeChats = List<Tutee>.empty(growable: true);
  List<Uint8List> images = List<Uint8List>.empty(growable: true);
  List<int> hasImage = List<int>.empty(growable: true);
  late UserType userType;
  List<Users> userChats = List<Users>.empty();

  getUserType() async {
    final type =

        await UserServices.getUserType(widget.globals.getUser.getUserTypeID, widget.globals);


    userType = type;

    getConnections();
  }

  void getConnections() async {
    try {
      userChats =

          await UserServices.getConnections(widget.globals.getUser.getId, widget.globals);

      setState(() {
        userChats = userChats;
      });
      getChatsProfileImages();
    } catch (e) {
      getChatsProfileImages();
    }
  }

  getChatsProfileImages() async {
    for (int i = 0; i < userChats.length; i++) {
      try {
        final image = await UserServices.getProfileImage(userChats[i].getId, widget.globals);
        setState(() {
          images.add(image);
        });
      } catch (e) {
        final byte = Uint8List(128);
        images.add(byte);
        hasImage.add(i);
      }
    }
    for (int i = 0; i < userChats.length; i++) {
      setState(() {
        bool val = true;
        for (int j = 0; j < hasImage.length; j++) {
          if (hasImage[j] == i) {
            val = false;
            break;
          }
        }
        if (!val) {
          tuteeChats.add(Tutee(userChats[i], images[i], false));
        } else {
          tuteeChats.add(Tutee(userChats[i], images[i], true));
        }
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();

    getUserType();
  }

  @override
  Widget build(BuildContext context) {
    getUserType();
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : userChats.isNotEmpty
              ? Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.01),
                  child: SizedBox(
                    child: ListView.builder(
                      itemBuilder: _chatBuilder,
                      itemCount: userChats.length,
                    ),
                  ),
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.chat,
                        size: MediaQuery.of(context).size.height * 0.09,
                        color: colorOrange,
                      ),
                      const Text('No Chats found')
                    ],
                  ),
                ),
    );
  }

  Widget _chatBuilder(BuildContext context, int i) {
    String name;
    if (userType.getType == "Tutors") {
      name = tuteeChats[i].tutee.getName + ' ' + userChats[i].getLastName;
    } else {
      name = tutorChats[i].tutor.getName + ' ' + userChats[i].getLastName;
    }

    return GestureDetector(
        child: Card(
          elevation: 0,
          color: Colors.transparent,
          // shape: RoundedRectangleBorder(
          //   side: const BorderSide(color: Colors.red, width: 1),
          //   borderRadius: BorderRadius.circular(10),
          // ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: CircleAvatar(
                  child: userType.getType == 'Tutors'
                      ? tuteeChats[i].hasImage
                          ? ClipOval(
                              child: Image.memory(
                                tuteeChats[i].image,
                                fit: BoxFit.cover,
                                width: MediaQuery.of(context).size.width * 0.15,
                                height:
                                    MediaQuery.of(context).size.width * 0.18,
                              ),
                            )
                          : ClipOval(
                              child: Image.asset(
                                'assets/Pictures/penguin.png',
                                fit: BoxFit.cover,
                                width: MediaQuery.of(context).size.width * 0.15,
                                height:
                                    MediaQuery.of(context).size.width * 0.18,
                              ),
                            )
                      : tutorChats[i].hasImage
                          ? ClipOval(
                              child: Image.memory(
                                tutorChats[i].image,
                                fit: BoxFit.cover,
                                width: MediaQuery.of(context).size.width * 0.15,
                                height:
                                    MediaQuery.of(context).size.width * 0.18,
                              ),
                            )
                          : ClipOval(
                              child: Image.asset(
                                'assets/Pictures/penguin.png',
                                fit: BoxFit.cover,
                                width: MediaQuery.of(context).size.width * 0.15,
                                height:
                                    MediaQuery.of(context).size.width * 0.18,
                              ),
                            ),
                ),
                title: Text(name),
                subtitle: const Text('Hi, how are you'),
                // trailing: ,
              ),
            ],
          ),
        ),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => Chat(
                  reciever: userChats[i],
                  globals: widget.globals,
                  image: userType.getType == 'Tutors'
                      ? tuteeChats[i].image
                      : tutorChats[i].image,
                  hasImage: userType.getType == 'Tutors'
                      ? tuteeChats[i].hasImage
                      : tutorChats[i].hasImage)));
        });
  }
}