import 'package:flutter/material.dart';
import 'package:meet_in_ground/Screens/chat/ChatScreen.dart';
import 'package:meet_in_ground/constant/format_time.dart';
import 'package:meet_in_ground/constant/themes_service.dart';
import 'package:meet_in_ground/util/Services/ChatService.dart';
import 'package:meet_in_ground/widgets/Loader.dart';
import 'package:meet_in_ground/widgets/NoDataFoundWidget.dart';

class ChatSearchDelegate extends SearchDelegate {
  final Chatservice _chatservice = Chatservice();
  late Future<List<Map<String, dynamic>>> _futureChatRooms;

  ChatSearchDelegate() {
    _futureChatRooms = _chatservice.getAllMessagesAndRooms();
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        color: ThemeService.textColor,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container(
      color: ThemeService.background,
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureChatRooms,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Loader();
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return NoDataFoundWidget(errorText: "NO MESSAGES FOUND",);
          }

          List<Map<String, dynamic>> chatRooms = snapshot.data!;
          final filteredChatRooms = chatRooms.where((chatRoom) {
            final name = chatRoom['sender'] == chatRoom['currentUserId']
                ? chatRoom['receiverName']
                : chatRoom['senderName'];
            return name.toLowerCase().contains(query.toLowerCase());
          }).toList();

          if (filteredChatRooms.isEmpty) {
            return NoDataFoundWidget(errorText: "No Messages yet",);
          }

          return ListView.builder(
            itemCount: filteredChatRooms.length,
            itemBuilder: (context, index) {
              var chatRoom = filteredChatRooms[index];

              return ListTile(
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        recieverName:
                            chatRoom['sender'] == chatRoom['currentUserId']
                                ? chatRoom['receiverName']
                                : chatRoom['senderName'],
                        recieverImage:
                            chatRoom['sender'] == chatRoom['currentUserId']
                                ? chatRoom['receiverImage']
                                : chatRoom['senderImage'],
                        receiverId:
                            chatRoom['sender'] == chatRoom['currentUserId']
                                ? chatRoom['receiver']
                                : chatRoom['sender'],
                      ),
                    ),
                  );
                },
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      chatRoom['sender'] == chatRoom['currentUserId']
                          ? chatRoom['receiverName']
                          : chatRoom['senderName'],
                      style: TextStyle(
                        fontSize: 15,
                        color: ThemeService.textColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      chatRoom['timestamp'] != null
                          ? formatDateTime(chatRoom['timestamp'])
                          : "",
                      style: TextStyle(
                        fontSize: 13,
                        color: ThemeService.placeHolder,
                      ),
                    ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text(
                    chatRoom['message'] ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: ThemeService.placeHolder),
                  ),
                ),
                leading: Container(
                  width: 50.0,
                  height: 50.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: ThemeService.primary,
                      width: 1.0,
                    ),
                  ),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(
                      chatRoom['sender'] == chatRoom['currentUserId']
                          ? chatRoom['receiverImage']
                          : chatRoom['senderImage'],
                    ),
                    backgroundColor: ThemeService.textColor,
                    foregroundColor: ThemeService.textColor,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }
}
