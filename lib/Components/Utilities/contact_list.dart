import 'package:flutter/cupertino.dart';

import 'BackendUtilities/friends.dart';
import 'BackendUtilities/send_receive_messages.dart';
import 'SqfliteHelperClasses/contact_list_database_helper.dart';
import 'extras.dart';

class ContactList {
  Future<void> retrieveAndStoreContactListFromOnline(BuildContext context) async {
    String userId = await Extras().retrieveUserID();
    Map<String, dynamic> friends = await Friends().retrieveFriendList(await Extras().retrieveJWT());
    List<dynamic> conversations = await SendReceiveMessages().retrieveConversations(await Extras().retrieveJWT(), userId);
    if(friends.isEmpty){
      return;
    }
    for (var friend in friends['friends']) {
      String friendId = friend['id'] ?? '';
      String username = friend['username'] ?? '';
      String conversationId = '';

      for (var conversation in conversations) {
        List<dynamic> participants = conversation['participants'];
        if (participants.contains(userId) && participants.contains(friendId) && participants.length == 2) {
          conversationId = conversation['_id'];
          break;
        }
      }

      await addingContactToLocalDatabase(friendId, username, conversationId);
    }
  }

  Future<void> addingContactToLocalDatabase(
      String friendID, String userName, String conversationId
      ) async {
    if (friendID.isEmpty) return;
    final jwt = await Extras().retrieveJWT();
    final profile = await SendReceiveMessages().retrieveFriendProfile(friendID, jwt);
    final profileImage = profile['profileImage'] ?? '';
    final bio = profile['bio'] ?? '';
    final chatName = profile['chatName']?.toLowerCase() ?? '';
    final formattedUserName = userName.toLowerCase();
    final participantsId = [friendID];

    final userContact = {
      'userImage3': '',
      'numberOfUsers': (participantsId.length - 1).toString(),
      'isGroup': false,
      'userImage': profileImage,
      'userImage2': '',
      'name': chatName,
      'userName': formattedUserName,
      'groupImage': '',
      'conversationId': conversationId,
      'userBio': bio,
      'participantsId': participantsId.join(',')
    };
    saveContactToStorage({
      ...userContact,
      'isGroup': 0, // Ensuring 'isGroup' is stored as an integer
    });
  }

  Future<void> saveContactToStorage(Map<String, dynamic> userContact) async {
    await ContactListDatabaseHelper().insertContact(userContact);
  }
}