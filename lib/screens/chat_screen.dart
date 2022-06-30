// ignore_for_file: deprecated_member_use

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = FirebaseFirestore.instance;
late User loggedInUser;
// ignore: prefer_typing_uninitialized_variables
late var datetime;
ScrollController scrollController = ScrollController();

// ignore: use_key_in_widget_constructors
class ChatScreen extends StatefulWidget {
  static String id = 'chat_screen';
  @override
  // ignore: library_private_types_in_public_api
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  final _messageTextController = TextEditingController();
  late String messageText;
  void getCurrentUser() async {
    try {
      // ignore: await_only_futures
      final user = await _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    Future.delayed(const Duration(milliseconds: 1100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
            scrollController.position.maxScrollExtent + 250,
            duration: Duration(seconds: 1),
            curve: Curves.easeInOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: const Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessagesStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _messageTextController,
                      onTap: () {
                        scrollController.animateTo(
                            scrollController.position.maxScrollExtent,
                            duration: const Duration(seconds: 1),
                            curve: Curves.easeInOut);
                        scrollController.animateTo(
                            scrollController.position.maxScrollExtent,
                            duration: const Duration(microseconds: 900),
                            curve: Curves.easeInOut);
                      },
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      datetime = DateTime.now().toUtc();

                      _messageTextController.clear();
                      if (messageText != '') {
                        _firestore.collection('messages').add({
                          'text': messageText,
                          'sender': loggedInUser.email,
                          'timeStamp': datetime,
                        });
                      }
                      messageText = '';
                      scrollController.animateTo(
                          scrollController.position.maxScrollExtent,
                          duration: const Duration(seconds: 1),
                          curve: Curves.easeInOut);
                      scrollController.animateTo(
                          scrollController.position.maxScrollExtent,
                          duration: const Duration(microseconds: 900),
                          curve: Curves.easeInOut);
                    },
                    child: const Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessagesStream extends StatelessWidget {
  const MessagesStream({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          _firestore.collection('messages').orderBy('timeStamp').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        final messages = snapshot.data?.docs;
        List<Widget> messageBubbles = [];
        Timestamp temp = messages!.first.get('timeStamp');
        DateTime dateTime = temp.toDate();
        messageBubbles.add(DateTitle(dayTime: dateTime));
        for (var message in messages) {
          final messageText = message.get('text');
          final messageSender = message.get('sender');
          final Timestamp messageTime = (message.get('timeStamp'));
          DateTime t1 =
                  DateTime.utc(dateTime.year, dateTime.month, dateTime.day),
              t2 = DateTime.utc(messageTime.toDate().year,
                  messageTime.toDate().month, messageTime.toDate().day);
          if (t2.compareTo(t1) > 0) {
            final dateTitle = DateTitle(dayTime: messageTime.toDate());

            messageBubbles.add(dateTitle);
            dateTime = messageTime.toDate();
          }

          final currentUser = loggedInUser.email;
          final messageBubble = MessageBubble(
            isMe: currentUser == messageSender,
            sender: messageSender,
            text: messageText,
            time: messageTime.toDate(),
          );
          if (messageText != '') messageBubbles.add(messageBubble);
        }
        if (messageBubbles.isNotEmpty) {
          return Flexible(
            child: ListView(
              dragStartBehavior: DragStartBehavior.down,
              controller: scrollController,
              padding:
                  const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
              children: messageBubbles,
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.only(top: 100),
            child: Center(
              child: AnimatedTextKit(
                isRepeatingAnimation: false,
                pause: Duration(seconds: 2),
                animatedTexts: [
                  TypewriterAnimatedText(
                    'No messages \n start chat \n now',
                    textAlign: TextAlign.center,
                    speed: Duration(milliseconds: 300),
                    textStyle: (TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.w900,
                      color: Colors.black45,
                    )),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String sender, text;
  final bool isMe;
  final DateTime time;
  MessageBubble(
      {required this.isMe,
      required this.sender,
      required this.text,
      required this.time});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              sender,
              style: TextStyle(
                fontSize: 12.0,
                color: Colors.black54,
              ),
            ),
          ),
          Material(
            elevation: 5.0,
            borderRadius: BorderRadius.only(
              topLeft: isMe ? Radius.circular(30) : Radius.circular(0),
              topRight: isMe ? Radius.circular(0) : Radius.circular(30),
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            color: isMe ? Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                '$text',
                style: TextStyle(
                  fontSize: 15,
                  color: isMe ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              '${time.toLocal().hour}:${time.toLocal().minute}',
              style: TextStyle(
                fontSize: 12.0,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DateTitle extends StatelessWidget {
  final DateTime dayTime;
  DateTitle({required this.dayTime});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
          child: Text(
            '${dayTime.toLocal().day} : ${dayTime.toLocal().month} : ${dayTime.toLocal().year}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
