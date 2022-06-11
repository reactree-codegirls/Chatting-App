import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController messageController = TextEditingController();

  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(20),
  );

  sendMessage() {
    if (messageController.text.trim().isEmpty) return;
    FirebaseFirestore.instance.collection("groupChat").add({
      "message": messageController.text.trim(),
      "date": DateTime.now(),
      "uid": "maaz"
    });
    messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat Screen"),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection("groupChat")
                    .orderBy("date", descending: true)
                    .snapshots(),
                builder: (ctx, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return Center(
                      child: CircularProgressIndicator(),
                    );

                  return ListView.separated(
                      itemBuilder: (ctx, i) {
                        final message =
                            MessageModel.fromDocument(snapshot.data!.docs[i]);
                        return Text(message.message);
                      },
                      separatorBuilder: (ctx, i) => SizedBox(
                            height: 10,
                          ),
                      itemCount: snapshot.data!.docs.length);
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: "Enter Message",
                      isDense: true,
                      border: border,
                      errorBorder: border,
                      enabledBorder: border,
                      focusedBorder: border,
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                GestureDetector(
                  onTap: sendMessage,
                  child: CircleAvatar(
                    radius: 24,
                    child: Transform.rotate(
                      angle: 12,
                      child: Icon(Icons.send),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class MessageModel {
  final String id;
  final String message;
  final DateTime date;
  final String uid;

  MessageModel(
      {required this.id,
      required this.date,
      required this.message,
      required this.uid});

  factory MessageModel.fromDocument(DocumentSnapshot doc) => MessageModel(
      id: doc.id,
      date: doc["date"].toDate(),
      message: doc["message"],
      uid: doc["uid"]);
}
