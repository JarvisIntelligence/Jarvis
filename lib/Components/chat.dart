import 'dart:async';
import 'dart:convert';
// import 'dart:io';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inapp_notifications/flutter_inapp_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:jarvis_app/Components/AIChats/ai_chat_history.dart';
import 'package:jarvis_app/Components/Utilities/camera.dart';
import 'package:jarvis_app/Components/Utilities/record_audio.dart';
import 'package:jarvis_app/Components/cache_image.dart';
import 'package:jarvis_app/Components/chat_bubble.dart';
import 'package:jarvis_app/Components/Utilities/encrypter.dart';
import 'package:jarvis_app/Components/Utilities/send_message.dart';
import 'package:jarvis_app/Components/ChangeNotifiers/user_chat_list_change_notifier.dart';
import 'package:lottie/lottie.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'Utilities/file_picker.dart';

class Chat extends StatefulWidget {
  const Chat({super.key, required this.chatName,
    required this.isGroup,  required this.userImage,
    this.userImage2, required this.id,
    this.userImage3, required this.numberOfUsers, required this.isPinned, required this.isArchived});

  final String chatName;
  final bool isGroup;
  final String userImage;
  final String? userImage2;
  final String id;
  final String numberOfUsers;
  final String? userImage3;
  final bool isPinned;
  final bool isArchived;

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TextEditingController messageController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final SecureStorageHelper _secureStorageHelper = SecureStorageHelper();
  final AutoScrollController scrollController = AutoScrollController();
  final FocusNode focusNode = FocusNode();
  final AudioPlayer audioPlayer = AudioPlayer();
  final RecordAudio _recordAudio = RecordAudio();
  bool showScrollBottomButton = false;
  bool isShowCameraOptions = false;
  bool emojiShowing = false;
  double keyboardHeight = 0.0;
  bool isCopyMessageVisible = false;
  bool isReply = false;
  String replyMessage = '';
  String replyName = '';
  String currentReplyMessage = '';
  bool isLongPressed = false;
  int numberOfSelectedBubbles = 0;
  int conversationCounter = 1;
  // Map to track chat selection state of each chat bubble
  Map<int, bool> isChatSelectedMap = {};
  List<Widget> chatWidgets = [];
  Map<String, dynamic> copyData = {};
  bool _isRecording = false;
  bool canPlayOrPauseAudio = false;
  bool isPlaying = false;
  bool isAudioPlaybackPaused = false;
  bool isShowingRecordingOptions = false;
  String _fileAudioName = '';
  Duration currentRecordingDuration = Duration.zero;
  Duration currentPosition = Duration.zero;

  late StreamSubscription<void> _playerFinishedSubscription;
  late StreamSubscription<Duration> _positionSubscription;

  List<Map<String, dynamic>> userChat = [];

  final PlayAudio _playAudio = PlayAudio();

  late StreamSubscription _playbackVoiceNoteCompleteSubscription;
  late StreamSubscription _positionVoiceNoteSubscription;
  Duration currentVoiceNotePosition = Duration.zero;
  bool isVoiceNotePlaying = false;
  bool isVoiceNotePause = false;

  @override
  void initState() {
    super.initState();
    init();
    voiceNoteAudioInit();
  }

  @override
  void dispose() {
    scrollController.removeListener(scrollListener);
    focusNode.removeListener(focusNodeListener);
    scrollController.dispose();
    focusNode.dispose();
    RecordAudio().dispose();
    _playAudio.dispose();
    super.dispose();
  }

  Future<void> init() async {
    // retrieve user's chat list from secure storage
    List<Map<String, dynamic>>? tempUserChat = await _secureStorageHelper.readListData(widget.id);
    if(tempUserChat != null){
      setState(() {
        userChat = tempUserChat;
      });
    }
    scrollController.addListener(scrollListener);
    focusNode.addListener(focusNodeListener);
    _initializeChatSelectionState();
  }

  Future<void> audioInit() async {
    _playerFinishedSubscription = _recordAudio.onPlayerFinished.listen((_) {
      setState(() {
        isPlaying = false;
      });
    });
    _positionSubscription = _recordAudio.onPositionChanged.listen((position) {
      setState(() {
        currentPosition = position;
      });
    });
    _recordAudio.onRecordingDurationChanged.listen((duration) {
      setState(() {
        currentRecordingDuration = duration;
      });
    });
  }

  Future<void> voiceNoteAudioInit() async {
    _playbackVoiceNoteCompleteSubscription = _playAudio.playbackVoiceNoteCompleteStream.listen((_) {
      setState(() {
        isVoiceNotePlaying = false;
        isVoiceNotePause = false;
      });
    });
    _positionVoiceNoteSubscription = _playAudio.positionVoiceNoteStream.listen((position) {
      setState(() {
        currentVoiceNotePosition = position;
      });
    });
  }

  void focusNodeListener() {
    if(focusNode.hasFocus){
      if(emojiShowing){
        SystemChannels.textInput.invokeMethod('TextInput.hide');
      }
      Future.delayed(const Duration(milliseconds: 500), () {
        scrollToBottom();
      });
    }
  }

  void scrollListener() {
    bool atBottom = scrollController.position.pixels == scrollController.position.minScrollExtent;
    setState(() {
      showScrollBottomButton = !atBottom;
    });
  }

  // Scroll to the bottom of the chat
  void scrollToBottom() {
    scrollController.animateTo(
      scrollController.position.minScrollExtent,
      duration: const Duration(milliseconds: 1000),
      curve: Curves.fastOutSlowIn
    );
  }

  void scrollToReply(int index) {
    scrollController.scrollToIndex(
      5,
      preferPosition: AutoScrollPosition.middle,
    );
  }

  String formatDate(String dateString) {
    final inputFormat = DateFormat('MMM d, y');
    DateTime date = inputFormat.parse(dateString);
    DateTime now = DateTime.now();
    DateTime yesterday = DateTime.now().subtract(const Duration(days: 1));

    if (DateFormat.yMd().format(date) == DateFormat.yMd().format(now)) {
      return 'Today';
    } else if (DateFormat.yMd().format(date) == DateFormat.yMd().format(yesterday)) {
      return 'Yesterday';
    } else {
      return inputFormat.format(date); // Format as "Jun 5, 2024"
    }
  }

  void showCopyMessage () {
    setState(() {
      isCopyMessageVisible = !isCopyMessageVisible;
    });
    Timer(const Duration(seconds: 1), () {
      setState(() {
        isCopyMessageVisible = !isCopyMessageVisible;
      });
    });
  }

  void showReplyMessage (String replyMessage, String replyName) {
    if(!isReply){
      setState(() {
        isReply = !isReply;
      });
    }
    updateReplyMessage(replyMessage, replyName);
  }

  void updateReplyMessage(String message, String name) {
    setState(() {
      replyMessage = message;
      replyName = name;
    });
  }

  void changeIsLongPressed() {
    setState(() {
      isLongPressed = true;
    });
  }

  void increaseDecreaseNumberOfSelectedBubbles (String increaseOrDecrease) {
    const storage = FlutterSecureStorage();
    setState(() {
      if (increaseOrDecrease == 'increase') {
        numberOfSelectedBubbles++;
      } else {
        numberOfSelectedBubbles--;
        if (numberOfSelectedBubbles == 0){
          isLongPressed = !isLongPressed;
          setState(() {
            conversationCounter = 1;
            copyData = {};
          });
          storage.delete(key: 'copy_data');
        }
      }
    });
  }

  void _initializeChatSelectionState() {
    int index = 0;
    for (var chatDateMap in userChat) {
      chatDateMap.forEach((date, messages) {
        for(int i = 0; i < messages.length; i++) {
          isChatSelectedMap[index++] = false;
        }
      });
    }
  }

  void changeIsChatSelected(int index) {
    setState(() {
      isChatSelectedMap[index] = !isChatSelectedMap[index]!;
    });
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '$twoDigitMinutes:$twoDigitSeconds';
  }

  Future<void> sendAudioMessage() async {
    setState(() {
      isShowingRecordingOptions = false;
    });
    if(isPlaying){
      await _recordAudio.stopAudioRecordingPlayback();
    }
    if(_isRecording){
      await _recordAudio.stopAudioRecording(true);
    }
    Duration? duration;
    duration = await SendMessage().getAudioRecordingDuration(_fileAudioName);
    setState(() {
      List<Map<String, dynamic>> updatedUserChat = SendMessage().sendAudioMessageBubbleChat(List.from(userChat), _fileAudioName, duration!);
      userChat = updatedUserChat;
      _initializeChatSelectionState();
    });
    audioPlayer.play(AssetSource('sound_effects/chat_received_sent.mp3'));
    await resetAudioRecordingAndPlayback();
    await updateUserChatInStorage();
    if(widget.id != '0'){
      checkIfChatIsInChatList();
    }
  }

  Future<void> _deselectAllChats() async {
    const storage = FlutterSecureStorage();
    setState(() {
      isChatSelectedMap.updateAll((key, value) => false);
      conversationCounter = 1;
      copyData = {};
    });
    await storage.delete(key: 'copy_data');
  }

  Future<void> storeCopyDetailsSecureStorage(String entry) async {
    const storage = FlutterSecureStorage();
    // Generate the next conversation key
    String key = 'conversation${conversationCounter++}';
    if (copyData.containsKey(key)) {
      copyData[key]!.add(entry);
    } else {
      copyData[key] = [entry];
    }

    String jsonString = jsonEncode(copyData);
    await storage.write(key: 'copy_data', value: jsonString);
  }

  Future<void> removeCopyDetailSecureStorage(String entry) async {
    const storage = FlutterSecureStorage();

    bool isRemoved = false;
    String keyToRemove = '';
    String? jsonString = await storage.read(key: 'copy_data');

    if (jsonString != null) {
      Map<String, dynamic> storedData = jsonDecode(jsonString);
      storedData.forEach((key, value) {
        if (value is List) {
          isRemoved = value.remove(entry);
          if (isRemoved && value.isEmpty) {
            keyToRemove = key;
          }
        }
      });
      storedData.remove(keyToRemove);
      jsonString = jsonEncode(storedData);
      await storage.write(key: 'copy_data', value: jsonString);
    }
  }

  Future<void> copyMultipleMessagesToClipboard() async {
    const storage = FlutterSecureStorage();
    Map<String, dynamic> copyData = {};
    String? jsonString = await storage.read(key: 'copy_data');

    if (jsonString != null) {
      copyData = jsonDecode(jsonString);
    } else {
      return;
    }

    // Collect all entries into a single string
    StringBuffer allEntriesBuffer = StringBuffer();
    copyData.forEach((key, values) {
      for (var value in values) {
        allEntriesBuffer.writeln(value);
      }
    });

    // Convert the StringBuffer to a single string
    String allEntries = allEntriesBuffer.toString();

    // Copy the string to the clipboard
    FlutterClipboard.copy(allEntries);
  }

  Future<void> startAudioRecording() async {
    await audioInit();
    bool isInitialized = await _recordAudio.init();
    if (isInitialized) {
      _fileAudioName = await _recordAudio.startAudioRecording();
      if(_fileAudioName != '') {
        setState(() {
          _isRecording = true;
          isShowingRecordingOptions = true;
        });
      }
    }
  }

  Future<void> stopAudioRecording() async {
    await _recordAudio.stopAudioRecording(false);
    setState(() {
      _isRecording = false;
      canPlayOrPauseAudio = true;
    });
  }

  Future<void> playRecording() async {
    await _recordAudio.playAudioRecordingPlayback(_fileAudioName);
    setState(() {
      isPlaying = true;
      isAudioPlaybackPaused = false;
    });
  }

  Future<void> pauseRecording() async {
    await _recordAudio.pauseAudioRecording();
    setState(() {
      isPlaying = false;
      isAudioPlaybackPaused = true;
    });
  }

  Future<void> resetAudioRecordingAndPlayback () async {
    setState(() {
      _fileAudioName = '';
      isPlaying = false;
      isAudioPlaybackPaused = false;
      canPlayOrPauseAudio = false;
      currentRecordingDuration = Duration.zero;
    });
    _playerFinishedSubscription.cancel();
    _positionSubscription.cancel();
  }

  Future<void> updateUserChatInStorage() async {
    await _secureStorageHelper.saveListData(widget.id, userChat);
  }

  Map<String, dynamic> getLastMessage() {
    if (userChat.isEmpty) return {};

    // Get the last date's key by accessing the last entry in userChat
    String lastDateKey = userChat.last.keys.last;

    // Get the list of messages for the last date
    List<Map<String, dynamic>> messages = List<Map<String, dynamic>>.from(userChat.last[lastDateKey]);

    if (messages.isEmpty) return {};

    // Get the last message
    Map<String, dynamic> lastMessage = messages.last;
    late String message;
    String senderName = lastMessage['senderName'];

    if (widget.isGroup) {
      if (lastMessage['message'] != '') {
        message = '$senderName: ${lastMessage['message']}';
      } else {
        message = (lastMessage['messageType'] == 'audio') ? '$senderName: Audio Recording' : (lastMessage['messageType'] == 'image') ? '$senderName: Image' : (lastMessage['messageType'] == 'video') ? '$senderName: Video' : '$senderName: File';
      }
    } else {
      if (lastMessage['message'] != '') {
        message = lastMessage['message'];
      } else {
        message = (lastMessage['messageType'] == 'audio') ? 'Audio Recording' : (lastMessage['messageType'] == 'image') ? 'Image' : (lastMessage['messageType'] == 'video') ? 'Video' : 'File';
      }
    }

    return {
      'message': message,
      'time': lastMessage['time'],
    };
  }

  void saveUpdatedUserChatList(List<Map<String, dynamic>>? userChatList) {
    Map<String, dynamic> lastMessageAndTime = getLastMessage();
    String lastMessage = lastMessageAndTime['message'];
    String lastMessageTime = lastMessageAndTime['time'];

    Provider.of<UserChatListChangeNotifier>(context, listen: false).addItem(
        chatId: widget.id,
        userImage: widget.userImage, chatName: widget.chatName,
        lastMessage: lastMessage, lastMessageTime: lastMessageTime, isGroup: widget.isGroup,
        userImage2: widget.userImage2, numberOfUsers: widget.numberOfUsers,
        userImage3: widget.userImage3, groupImage: widget.userImage,
        notification: false, isPinned: widget.isPinned, isArchived: widget.isArchived
    );
  }

  Future<void> checkIfChatIsInChatList() async {
    List<Map<String, dynamic>>? userChatList = await _secureStorageHelper.readListData('userChatList');
    saveUpdatedUserChatList(userChatList);
  }

  static Duration parseDuration(String duration) {
    List<String> parts = duration.split(':');
    int hours = int.parse(parts[0]);
    int minutes = int.parse(parts[1]);
    List<String> secondsParts = parts[2].split('.');
    int seconds = int.parse(secondsParts[0]);
    int microseconds = int.parse(secondsParts[1].padRight(6, '0'));
    return Duration(hours: hours, minutes: minutes, seconds: seconds, microseconds: microseconds);
  }

  Future<void> checkInternetConnection() async {
    bool isNetworkOn = await InternetConnectionChecker().hasConnection;
    if(!isNetworkOn){
      InAppNotifications.show(
          description: "Please check your internet connection, you won't be able to send or receive messages",
          onTap: (){}
      );
    }
  }

  Future<void> sendMediaMessage(Map<String, dynamic> details, List<Map<String, dynamic>> sendMedia) async {
    if(details.isNotEmpty){
      setState(() {
        List<Map<String, dynamic>> updatedUserChat = sendMedia;
        userChat = updatedUserChat;
        _initializeChatSelectionState();
      });
      audioPlayer.play(AssetSource('sound_effects/chat_received_sent.mp3'));
      scrollToBottom();
      await updateUserChatInStorage();
      if(widget.id != '0'){
        await checkIfChatIsInChatList();
      }
      checkInternetConnection();
    }
    setState(() {
      isShowCameraOptions = false;
    });
  }

  Future<void> sendPlainMessage() async {
    String message = messageController.text;
    if (message.isNotEmpty) {
      setState(() {
        List<Map<String, dynamic>> updatedUserChat;
        if(containsURL(message)){
          updatedUserChat = SendMessage().sendLinkMessageBubbleChat(List.from(userChat), message);
        } else {
          updatedUserChat = SendMessage().sendMessageBubbleChat(List.from(userChat), message);
        }
        userChat = updatedUserChat;
        _initializeChatSelectionState();
      });
      audioPlayer.play(AssetSource('sound_effects/chat_received_sent.mp3'));
      scrollToBottom();
      await updateUserChatInStorage();
      if(widget.id != '0'){
        await checkIfChatIsInChatList();
      }
      checkInternetConnection();
      messageController.clear();
    }
  }

  bool containsURL(String string) {
    const urlPattern = r'(https?:\/\/[^\s]+)';
    final result = RegExp(urlPattern, caseSensitive: false).hasMatch(string);
    return result;
  }

  List<String> extractURLs(String string) {
    const urlPattern = r'(https?:\/\/[^\s]+)';
    final matches = RegExp(urlPattern, caseSensitive: false).allMatches(string);
    return matches.map((match) => match.group(0)!).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      resizeToAvoidBottomInset: true,
      drawer: Drawer(
        width: MediaQuery
            .of(context)
            .size
            .width, // Set width to match screen width,
        child: const AiChatHistory(),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              children: [
                chatHeader(),
                chatMessagesScreen()
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            right: (showScrollBottomButton) ? 10 : 24,
            child: Column(
              children: [
                scrollToBottomButton(),
                recordingOptions()
              ],
            )
          ),
          copyMessage(),
          messagesSelectedDisplay(),
          messagesSelectedOptions(),
          cameraOptions(),
        ],
      ),
      bottomNavigationBar: chatInputBar(),
    );
  }

  Widget chatHeader(){
    return Container(
      padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10, top: 50),
      color: Theme.of(context).colorScheme.secondary,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () {
                context.pop();
              },
              icon: Icon(
                Icons.arrow_back, color: Theme.of(context).colorScheme.scrim, size: 20,),
            ),
          ),
          Column(
            children: [
              (widget.id == '0') ?
              SvgPicture.asset(
                'assets/icons/ai_logo.svg',
                height: 40,
              ) //JARVIS AI Logo
                  :
              (widget.isGroup)
                  ? (int.parse(widget.numberOfUsers) > 2)
                    ? SizedBox(
                        width: 40,
                        height: 40,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              left: 23, // Third image position, slightly moved to the right
                              child: CacheImage(
                                  imageUrl: widget.userImage3 ?? '', // Change this to the third user's image URL
                                  isGroup: widget.isGroup,
                                  numberOfUsers: widget.numberOfUsers
                              ),
                            ),
                            Positioned(
                              left: 13, // Second image position, slightly moved to the right
                              child: CacheImage(
                                  imageUrl: widget.userImage2 ?? '', // Change this to the second user's image URL
                                  isGroup: widget.isGroup,
                                  numberOfUsers: widget.numberOfUsers
                              ),
                            ),
                            Positioned(
                              left: 0, // First image position
                              child: CacheImage(
                                  imageUrl: widget.userImage, // Change this to the first user's image URL
                                  isGroup: widget.isGroup,
                                  numberOfUsers: widget.numberOfUsers
                              ),
                            ),
                          ],
                        ),
                      )
                    : SizedBox(
                        width: 40,
                        height: 40,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              left: -3,
                              top: -3,
                              child: CacheImage(
                                  imageUrl: widget.userImage,
                                  isGroup: widget.isGroup,
                                  numberOfUsers: widget.numberOfUsers),
                            ),
                            Positioned(
                              right: -3,
                              bottom: -3,
                              child: CacheImage(
                                imageUrl: widget.userImage2 ?? '',
                                isGroup: widget.isGroup,
                                numberOfUsers: widget.numberOfUsers,),
                            ),
                          ],
                        ),
                      )
                  : CacheImage(numberOfUsers: widget.numberOfUsers, imageUrl: widget.userImage, isGroup: widget.isGroup,),
              const SizedBox(height: 5,), //Two people/Group
              Text(widget.chatName, style: TextStyle(
                  color: Theme.of(context).colorScheme.scrim,
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400),)
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: (widget.id == '0')
                ? IconButton(
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
              icon: SvgPicture.asset(
                'assets/icons/hamburger_icon.svg', height: 20, colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.scrim,
                  BlendMode.srcIn,
                ),
              ),
            )
                : IconButton(
              onPressed: () {},
              icon: Icon(Icons.more_vert, size: 20, color: Theme.of(context).colorScheme.scrim,),
            ),
          ),
        ],
      ),
    );
  }

  Widget chatMessagesScreen() {
    List<Widget> chatWidgets = [];
    bool isFirstDate = true;
    String? previousDate;
    int index = 0;

    for (var chatDateMap in userChat) {
      chatDateMap.forEach((date, messages) {
        String formattedDate = formatDate(date);
        chatWidgets.add(
          Padding(
            padding: EdgeInsets.only(bottom: 10, top: (isFirstDate) ? 0 : 20),
            child: Text(
              formattedDate,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
                fontSize: 8,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
        isFirstDate = false;

        for (int i = 0; i < messages.length; i++) {
          var message = messages[i];
          bool isNewDay = false;
          if (previousDate == null || DateFormat.yMd().format(DateFormat('MMM d, y').parse(date)) != DateFormat.yMd().format(DateFormat('MMM d, y').parse(previousDate!))) {
            isNewDay = true;
          }
          previousDate = date;

          bool hasDifferentSender = false;
          if (i < messages.length - 1) {
            hasDifferentSender = messages[i + 1]['isSender'] != message['isSender'];
          }

          // Capture the correct index for the closure
          final currentIndex = index;
          chatWidgets.add(
            ChatBubble(
              isNewDay: isNewDay,
              message: message['message'],
              fileName: message['fileName'],
              isSender: message['isSender'],
              isStarred: message['isStarred'],
              showCopyMessage: showCopyMessage,
              chatId: widget.id,
              isGroup: widget.isGroup, // Replace with actual isGroup value if needed
              chatTime: DateFormat('HH:mm').format(DateTime.parse(message['time'])), // Replace with actual chatTime if needed
              senderName: message['senderName'],
              isDelivered: message['isDelivered'],
              isSent: message['isSent'],
              isSeen: message['isSeen'],
              messageType: message['messageType'],
              duration: parseDuration(message['duration']),
              showReplyMessage: showReplyMessage,
              hasDifferentSender: hasDifferentSender,
              isLongPressed: isLongPressed,
              changeIsLongPressed: changeIsLongPressed,
              increaseDecreaseNumberOfSelectedBubbles: increaseDecreaseNumberOfSelectedBubbles,
              numberOfSelectedBubbles: numberOfSelectedBubbles,
              isChatSelected: isChatSelectedMap[currentIndex] ?? false,
              changeIsChatSelected: () => changeIsChatSelected(currentIndex),
              storeCopyDetailsSecureStorage: storeCopyDetailsSecureStorage,
              chatDate: formattedDate,
              removeCopyDetailSecureStorage: removeCopyDetailSecureStorage,
              file: message['file'],
              extension: message['extension'],
              size: message['size'],
              fileLogo: message['fileLogo'],
              isVoiceNotePlaying: isVoiceNotePlaying,
              isVoiceNotePaused: isVoiceNotePause,
              currentVoiceNotePosition: currentVoiceNotePosition,
              changeIsVoiceNotePaused: (bool value) { setState(() {isVoiceNotePause = value;}); },
              changeIsVoiceNotePlaying: (bool value) { setState(() {isVoiceNotePlaying = value;}); },
              playAudio: _playAudio,
            ),
          );
          index++;
        }
      });
    }

    // Reverse the chatWidgets list
    chatWidgets = chatWidgets.reversed.toList();

    return Expanded(
      child: (userChat.isEmpty)
          ? buildEmptyChat()
          : buildChat(chatWidgets),
    );
  }

  Widget buildEmptyChat() {
    return Padding(
        padding: const EdgeInsets.only(top: 20),
        child: ListView(
          padding: EdgeInsets.zero,
          controller: scrollController,
          children: [
            Column(
              children: [
                Lottie.asset((widget.id == '0')
                    ? 'assets/lottie_animations/new_ai_chat_animation.json'
                    : 'assets/lottie_animations/new_user_chat_animation.json', width: 80),
                SizedBox(height: (widget.id == '0') ? 0 : 10,),
                Text('Quiet around here..start a conversation', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontFamily: 'Inter', fontSize: 8),)
              ],
            ),
          ],
        )
    );
  }

  Widget buildChat(List<Widget> chatWidgets) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 0, top: 20),
      child: ListView.builder(
        reverse: true,
        padding: EdgeInsets.zero,
        controller: scrollController,
        itemCount: chatWidgets.length,
        itemBuilder: (context, index) {
          return AutoScrollTag(
            index: index,
            controller: scrollController,
            key: ValueKey(index), // Unique key for ListView.builder
            child: chatWidgets[index]
          );
        },
      ),
    );
  }

  Widget scrollToBottomButton() {
    return Visibility(
      visible: (showScrollBottomButton) ? true : false,
      child: ElevatedButton(
        onPressed: () {
          scrollToBottom();
        },
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          backgroundColor: Theme.of(context).colorScheme.tertiary,
        ),
        child: Icon(Icons.arrow_downward, color: Theme.of(context).colorScheme.scrim, size: 20,),
      )
    );
  }

  Widget recordingOptions() {
    return Visibility(
      visible: (isShowingRecordingOptions) ? true : false,
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        width: 40,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(5), // Curved edges
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () async {
                setState(() {
                  isShowingRecordingOptions = false;
                });
                if(isPlaying){
                  await _recordAudio.stopAudioRecordingPlayback();
                }
                if(_isRecording){
                  await _recordAudio.stopAudioRecording(true);
                }
                await _recordAudio.deleteAudioRecording(_fileAudioName);
                resetAudioRecordingAndPlayback();
              },
              child: Icon(Icons.delete, size: 16, color: Theme.of(context).colorScheme.onSecondaryContainer,),
            ), // delete
            const SizedBox(height: 20,),
            GestureDetector(
              onTap: () {
                if(!_isRecording && canPlayOrPauseAudio){
                  (isPlaying) ? pauseRecording() : playRecording();
                  return;
                }
                stopAudioRecording();
              },
              child: Icon((_isRecording && !canPlayOrPauseAudio)
                  ? Icons.stop
                  : (isPlaying)
                    ? Icons.pause
                    : Icons.play_arrow, size: 18,
                color: (_isRecording && !canPlayOrPauseAudio)
                    ? Colors.red
                    : (isPlaying)
                      ? Theme.of(context).colorScheme.onSecondaryContainer
                      : Colors.green,
              ),
            ), // stop/play
            const SizedBox(height: 20,),
            GestureDetector(
                onTap: () async {
                  await sendAudioMessage();
                },
                child: Icon(Icons.send_rounded, size: 16, color: Theme.of(context).colorScheme.tertiary,),
            ), // send
          ],
        ),
      )
    );
  }

  Widget copyMessage() {
    return Visibility(
      visible: isCopyMessageVisible,
      child: Positioned(
        child:  Center(
          child: IntrinsicWidth(
            child: IntrinsicHeight(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  (numberOfSelectedBubbles > 1)
                      ? '$numberOfSelectedBubbles Messages copied!'
                      : 'Message copied!',
                  style: const TextStyle(
                      fontSize: 10,
                      color: Colors.black,
                      fontFamily: 'Inter'
                  ),),
              ),
            ),
          ),
        ),
      )
    );
  }

  Widget chatInputBar() {
    // Listen to changes in viewInsets (keyboard height)
    final viewInsets = MediaQuery.of(context).viewInsets;
    if (viewInsets.bottom != 0.0) {
      setState(() {
        keyboardHeight = viewInsets.bottom;
      });
    }
    return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery
            .of(context)
            .viewInsets
            .bottom), // Adjusts padding based on keyboard
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            replyContainer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              height: 70,
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  border: Border(
                      top: BorderSide(color: Theme.of(context).colorScheme.surface, width: 1)
                  )
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        isShowCameraOptions = !isShowCameraOptions;
                      });
                    },
                    icon: Icon(Icons.camera_alt, color: Theme.of(context).colorScheme.onPrimary,),
                  ),
                  const SizedBox(width: 7,),
                  GestureDetector(
                      onTap: () async {
                        List<Map<String, dynamic>> pickedFiles = await CustomFilePicker().pickFiles();
                        List<Map<String, dynamic>> updatedUserChat = [];
                        if (pickedFiles.isNotEmpty) {
                          for (var file in pickedFiles) {
                            updatedUserChat = SendMessage().sendFileMessageBubbleChat(userChat, file['extension'], file['name'], file['size'], file['fileLogo']);
                            setState(() {
                              userChat = updatedUserChat;
                              _initializeChatSelectionState();
                            });
                          }
                          scrollToBottom();
                          await updateUserChatInStorage();
                          if (widget.id != '0') {
                            await checkIfChatIsInChatList();
                          }
                          checkInternetConnection();
                        }
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(9), // Adjust the radius as needed
                        child: Container(
                          width: 24,
                          height: 20,
                          color: Theme.of(context).colorScheme.onPrimary,
                          child: Center(
                            child: SvgPicture.asset(
                              'assets/icons/attach_icon.svg', height: 12, colorFilter: ColorFilter.mode(
                              Theme.of(context).colorScheme.surface,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 18,),
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          width: 1, // Adjust width as needed
                          color: Theme.of(context).colorScheme.primaryContainer // Adjust color as needed
                        ),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                              onPressed: () {
                                setState(() {
                                  if (emojiShowing) {
                                    // Wait for a brief moment to ensure the emojiSelector is hidden
                                    Future.delayed(const Duration(milliseconds: 50), () {
                                      SystemChannels.textInput.invokeMethod('TextInput.show');
                                    });
                                    emojiShowing = !emojiShowing;
                                  } else {
                                    // Wait for a brief moment to ensure the keyboard is hidden
                                    Future.delayed(const Duration(milliseconds: 200), () {
                                      setState(() {
                                        emojiShowing = !emojiShowing; // Then, show the emoji selector
                                      });
                                    });
                                    SystemChannels.textInput.invokeMethod('TextInput.hide');
                                  }
                                });
                              },
                              icon: SvgPicture.asset(
                                (emojiShowing) ? 'assets/icons/keyboard_icon.svg' : 'assets/icons/emoji_icon.svg', height: 30,)
                          ),
                          Expanded(
                            child: TextField(
                              enableSuggestions: true,
                              autocorrect: true,
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                              textInputAction: TextInputAction.newline,
                              controller: messageController,
                              focusNode: focusNode,
                              style: TextStyle(color: Theme.of(context).colorScheme.scrim,
                                  fontSize: 12,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400),
                              cursorColor: Theme.of(context).colorScheme.onSecondaryContainer,
                              decoration: InputDecoration(
                                hintText: 'Message',
                                border: InputBorder.none,
                                hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSecondaryContainer,
                                    fontSize: 12,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                          ),
                          IconButton(
                              onPressed: () async {
                                sendPlainMessage();
                              },
                              icon: SvgPicture.asset('assets/icons/send_icon.svg',
                                height: 30,)
                          )
                        ],
                      ),
                    ),
                  ),
                  Visibility(
                    visible: (isShowingRecordingOptions) ? false : true,
                    child: IconButton(
                        onPressed: startAudioRecording,
                        icon: Icon(Icons.mic, color: Theme.of(context).colorScheme.onPrimary,)
                    ),
                  ),
                  Visibility(
                    visible:(isShowingRecordingOptions) ? true : false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: (isPlaying || isAudioPlaybackPaused) ? Text(formatDuration(currentPosition), style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.scrim
                      ),)
                          : Text(formatDuration(currentRecordingDuration),
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: Colors.red
                      ),),
                    )
                  )
                ],
              ),
            ),
            Offstage(
              offstage: !emojiShowing,
              child: Container(
                constraints: const BoxConstraints(
                  minHeight: 150
                ),
                height: (keyboardHeight != 0.0) ? keyboardHeight : 320,
                child: EmojiPicker(
                  textEditingController: messageController,
                  config: Config(
                    height: 20,
                    checkPlatformCompatibility: true,
                    emojiViewConfig: EmojiViewConfig(
                        emojiSizeMax: 26 *
                            (foundation.defaultTargetPlatform == TargetPlatform.iOS
                                ?  1.20
                                :  1.0),
                        backgroundColor: Theme.of(context).colorScheme.scrim,
                        columns: 8,
                        noRecents: Text('No Recents',
                            style: TextStyle(
                                fontSize: 10, fontFamily: 'Inter',
                                color: Theme.of(context).colorScheme.secondaryContainer,),
                            textAlign: TextAlign.center)
                    ),
                    swapCategoryAndBottomBar: true,
                    skinToneConfig: SkinToneConfig(
                      enabled: true,
                      indicatorColor: Theme.of(context).colorScheme.tertiary,
                    ),
                    categoryViewConfig: CategoryViewConfig(
                        indicatorColor: Theme.of(context).colorScheme.tertiary,
                        iconColorSelected: Theme.of(context).colorScheme.tertiary,
                        backgroundColor: Theme.of(context).colorScheme.scrim
                    ),
                    bottomActionBarConfig: BottomActionBarConfig(
                        backgroundColor: Theme.of(context).colorScheme.scrim,
                        buttonIconColor: Theme.of(context).colorScheme.tertiary,
                        buttonColor: Colors.transparent
                    ),
                    searchViewConfig: SearchViewConfig(
                        backgroundColor: Theme.of(context).colorScheme.scrim
                    ),
                  ),
                ),
              ),
            ),
          ],
        )
    );
  }

  Widget replyContainer() {
    return Visibility(
      visible: isReply,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10, left: 20, right: 20),
        padding: const EdgeInsets.only(right: 15, left: 20, top: 15, bottom: 15),
        height: 110,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onTertiaryContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Replying $replyName',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onTertiary,
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w400
                      ),),
                    const SizedBox(width: 10,),
                    Icon(Icons.reply, color: Theme.of(context).colorScheme.onTertiary,)
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                GestureDetector(
                  onTap: () {
                    int replyIndex = 1; // Replace with the actual index
                    scrollToReply(replyIndex);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(left: 10),
                        width: MediaQuery.of(context).size.width - 130,
                        child: Text(replyMessage,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.scrim,
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.w400
                          ),
                        ),
                      ),
                      Image.asset('assets/icons/linking_icon.png', width: 25,)
                    ],
                  ),
                )
              ],
            ),
            Positioned(
                top: -15,
                right: -10,
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      isReply = !isReply;
                    });
                  },
                  icon: Icon(Icons.close, color: Theme.of(context).colorScheme.secondary, size: 14,),
                )
            )
          ],
        ),
      )
    );
  }

  Widget messagesSelectedDisplay() {
    return Visibility(
      visible: numberOfSelectedBubbles > 1,
      child: Stack(
        children: [
          Positioned(
            top: 200,
            right: 20,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.tertiaryFixed,
              ),
              child: Center(
                child: Text(
                  numberOfSelectedBubbles.toString(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.scrim,
                    fontFamily: 'Inter',
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
              top: 195,
              right: 15,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          isLongPressed = !isLongPressed;
                          numberOfSelectedBubbles = 0;
                          _deselectAllChats();
                        });
                      },
                      icon: Icon(
                        Icons.close,
                        size: 8,
                        color: Theme.of(context).colorScheme.scrim,
                      ),
                      padding: EdgeInsets.zero, // Remove default padding
                      constraints: const BoxConstraints(), // Remove constraints to allow precise positioning
                    ),
                  ],
                ),
              )
          ),
        ],
      )
    );
  }

  Widget messagesSelectedOptions() {
    return Visibility(
        visible: (numberOfSelectedBubbles > 1) ? true : false,
        child: Positioned(
            top: 250,
            right: 20,
            child: Container(
              width: 40,
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(5), // Curved edges
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: (){},
                    child: SvgPicture.asset('assets/icons/corner_up_right_icon.svg', width: 14,),
                  ), // forward
                  const SizedBox(height: 20,),
                  GestureDetector(
                    onTap: () {
                      copyMultipleMessagesToClipboard();
                      showCopyMessage();
                      setState(() {
                        isLongPressed = !isLongPressed;
                        _deselectAllChats();
                      });
                      Timer(const Duration(seconds: 1), () {
                        setState(() {
                          numberOfSelectedBubbles = 0; //So that the showCopyMessage can display before setting the value to 0
                        });
                      });
                    },
                    child: Icon(Icons.copy, size: 12, color: Theme.of(context).colorScheme.onSecondaryContainer,),
                  ), // copy
                  const SizedBox(height: 20,),
                  GestureDetector(
                      onTap: (){},
                      child: SvgPicture.asset('assets/icons/push_pin_icon.svg', height: 14, colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.onSecondaryContainer,
                        BlendMode.srcIn,
                      ),)
                  ), // pin
                  const SizedBox(height: 20,),
                  GestureDetector(
                    onTap: (){

                    },
                    child: Icon(Icons.star_border_outlined,
                      size: 14,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                  ), // star
                ],
              ),
            )
        )
    );
  }

  Widget cameraOptions() {
    return Visibility(
        visible: (isShowCameraOptions) ? true : false,
        child: Positioned(
          bottom: 0,
          left: 8,
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(5), // Curved edges
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () async {
                    Map<String, dynamic> photoDetails = await Camera().takeImageWithCamera();
                    sendMediaMessage(photoDetails, SendMessage().sendPhotoMessageBubbleChat(userChat,
                      photoDetails['file'], photoDetails['name'],
                    ));
                  },
                  child: Row(
                    children: [
                      Icon(Icons.camera, size: 18, color: Theme.of(context).colorScheme.onSecondaryContainer,),
                      const SizedBox(
                        width: 5,
                      ),
                      Text('Photo Camera', style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                        fontFamily: 'Inter',
                        fontSize: 10
                      ),)
                    ]
                  )
                ),
                const SizedBox(height: 20,),
                GestureDetector(
                  onTap: () async {
                    Map<String, dynamic> videoDetails = await Camera().takeVideoWithCamera();
                    sendMediaMessage(videoDetails, SendMessage().sendVideoMessageBubbleChat(userChat,
                      videoDetails['file'], videoDetails['name'],
                    ));
                  },
                  child: Row(
                      children: [
                        Icon(Icons.video_camera_back, size: 18, color: Theme.of(context).colorScheme.onSecondaryContainer,),
                        const SizedBox(
                          width: 5,
                        ),
                        Text('Video Camera', style: TextStyle(
                          color: Theme.of(context).colorScheme.onSecondaryContainer,
                          fontFamily: 'Inter',
                          fontSize: 10
                        ),)
                      ]
                  ),
                ), //take video//take picture
                const SizedBox(height: 20,),
                GestureDetector(
                  onTap: () async {
                    Map<String, dynamic> photoVideoDetails = await Camera().getMediaFromFolder();
                    sendMediaMessage(photoVideoDetails, SendMessage().sendMediaMessageBubbleChat(userChat,
                      photoVideoDetails['file'], photoVideoDetails['name'], photoVideoDetails['mediaType']
                    ));
                  },
                  child: Row(
                      children: [
                        Icon(Icons.image, size: 18, color: Theme.of(context).colorScheme.onSecondaryContainer,),
                        const SizedBox(
                          width: 5,
                        ),
                        Text('Attach Single Media', style: TextStyle(
                          color: Theme.of(context).colorScheme.onSecondaryContainer,
                          fontFamily: 'Inter',
                          fontSize: 10
                        ),)
                      ]
                  ),
                ), //pick from files
                const SizedBox(height: 20,),
                GestureDetector(
                  onTap: () async {
                    List<Map<String, dynamic>> mediaDetails = await Camera().getMultipleMediaFromFolder();
                    List<Map<String, dynamic>> updatedUserChat = [];
                    if (mediaDetails.isNotEmpty) {
                      for (var mediaDetail in mediaDetails) {
                        updatedUserChat = SendMessage().sendMediaMessageBubbleChat(userChat,
                          mediaDetail['file'], mediaDetail['name'], mediaDetail['mediaType']
                        );
                        setState(() {
                          userChat = updatedUserChat;
                          _initializeChatSelectionState();
                        });
                      }
                      scrollToBottom();
                      await updateUserChatInStorage();
                      if (widget.id != '0') {
                        await checkIfChatIsInChatList();
                      }
                      checkInternetConnection();
                    }
                    setState(() {
                      isShowCameraOptions = false;
                    });
                  },

                  child: Row(
                      children: [
                        Icon(Icons.perm_media, size: 18, color: Theme.of(context).colorScheme.onSecondaryContainer,),
                        const SizedBox(
                          width: 5,
                        ),
                        Text('Attach Multiple Media', style: TextStyle(
                          color: Theme.of(context).colorScheme.onSecondaryContainer,
                          fontFamily: 'Inter',
                          fontSize: 10
                        ),)
                      ]
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }
}
