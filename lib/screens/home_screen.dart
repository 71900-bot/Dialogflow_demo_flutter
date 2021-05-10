import 'package:dialogflow_demo_flutter/models/chat_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dialogflow/dialogflow_v2.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Dialogflow dialogflow;
  AuthGoogle authGoogle;
  List<ChatMessage> messages = [];
  TextEditingController _inputMessageController = new TextEditingController();

  ScrollController _scrollController = new ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 300), () async {
      await initiateDialogFlow();
    });
  }

  _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        flexibleSpace: SafeArea(
          child: Container(
            padding: EdgeInsets.only(right: 16),
            child: Row(
              children: <Widget>[
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                  ),
                ),
                SizedBox(
                  width: 2,
                ),
                SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Kriss Benwat",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: 6,
                      ),
                      Text(
                        "Online",
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.settings,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
        ),
      ),
      body: Center(
          child: Container(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ListView.builder(
                          itemCount: messages.length,
                          shrinkWrap: true,
                          padding: EdgeInsets.only(top: 10, bottom: 10),
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return Container(
                              padding: EdgeInsets.only(
                                  left: 14, right: 14, top: 10, bottom: 10),
                              child: Align(
                                alignment:
                                    (messages[index].messageType == "receiver"
                                        ? Alignment.topLeft
                                        : Alignment.topRight),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: (messages[index].messageType ==
                                            "receiver"
                                        ? Colors.grey.shade200
                                        : Colors.blue[200]),
                                  ),
                                  padding: EdgeInsets.all(16),
                                  child: Text(
                                    messages[index].messageContent,
                                    style: TextStyle(fontSize: 15),
                                  ),
                                ),
                              ),
                            );
                          }),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
                height: 60,
                width: double.infinity,
                child: bottomChatView(),
              )
            ],
          ),
        ),
      )),
    );
  }

  Widget bottomChatView() {
    return Row(
      children: <Widget>[
        SizedBox(
          width: 15,
        ),
        Expanded(
          child: TextField(
            controller: _inputMessageController,
            // onSubmitted: fetchFromDialogFlow(_inputMessageController.text),
            decoration: InputDecoration(
                hintText: "Write message...",
                hintStyle: TextStyle(color: Colors.black54),
                border: InputBorder.none),
          ),
        ),
        SizedBox(
          width: 15,
        ),
        FloatingActionButton(
          onPressed: () {
            fetchFromDialogFlow(_inputMessageController.text);
          },
          child: Icon(
            Icons.send,
            color: Colors.white,
            size: 18,
          ),
          backgroundColor: Colors.blue,
          elevation: 0,
        ),
      ],
    );
  }

  initiateDialogFlow() async {
    AuthGoogle authGoogle =
        await AuthGoogle(fileJson: "assets/creds.json").build();
    dialogflow = Dialogflow(authGoogle: authGoogle, language: Language.english);
  }

  fetchFromDialogFlow(String input) async {
    _inputMessageController.clear();
    setState(() {
      messages.add(ChatMessage(messageContent: input, messageType: "sender"));
    });
    _scrollToBottom();

    AIResponse response = await dialogflow.detectIntent(input);
    print(response.getMessage());
    messages.add(ChatMessage(
        messageContent: response.getMessage(), messageType: "receiver"));
    setState(() {
      _scrollToBottom();
    });
  }
}
