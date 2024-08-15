import 'dart:io';
import 'package:chat_bubbles/bubbles/bubble_file.dart';
import 'package:chat_bubbles/bubbles/bubble_normal_audio.dart';
import 'package:chat_bubbles/bubbles/bubble_normal_image.dart';
import 'package:chat_bubbles/bubbles/bubble_normal_video.dart';
import 'package:chat_bubbles/bubbles/bubble_special_three.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'Utilities/record_audio.dart';

class ChatBubble extends StatefulWidget {
  const ChatBubble({super.key, this.message,
    required this.isSender, required this.chatId,
    required this.isGroup, required this.chatTime,
    required this.senderName, required this.isDelivered,
    required this.isSent, required this.hasDifferentSender,
    required this.isStarred, required this.showCopyMessage,
    required this.showReplyMessage, required this.isLongPressed,
    required this.changeIsLongPressed, required this.increaseDecreaseNumberOfSelectedBubbles,
    required this.numberOfSelectedBubbles, required this.isChatSelected,
    required this.changeIsChatSelected, required this.storeCopyDetailsSecureStorage,
    required this.chatDate, required this.removeCopyDetailSecureStorage,
    required this.isSeen, required this.messageType, required this.isNewDay,

    required this.fileName, this.duration, required this.file,
    required this.extension, required this.size, required this.fileLogo,

    required this.isVoiceNotePlaying, required this.isVoiceNotePaused, required this.currentVoiceNotePosition,
    required this.changeIsVoiceNotePaused, required this.changeIsVoiceNotePlaying, required this.playAudio

  });

  // this is for text message
  final bool isSender;
  final String senderName;
  final String? message;
  final bool isGroup;
  final bool isDelivered;
  final bool isSent;
  final bool isSeen;
  final String chatId;
  final String chatTime;
  final String chatDate;
  final String messageType;
  final bool hasDifferentSender;
  final bool isStarred;
  final Function() showCopyMessage;
  final Function() changeIsLongPressed;
  final Function(String increaseOrDecrease) increaseDecreaseNumberOfSelectedBubbles;
  final bool isLongPressed;
  final int numberOfSelectedBubbles;
  final Function(String replyMessage, String replyName) showReplyMessage;
  final bool isChatSelected;
  final Function() changeIsChatSelected;
  final Function(String entry) storeCopyDetailsSecureStorage;
  final Function(String entry) removeCopyDetailSecureStorage;
  final bool isNewDay;

  final String fileName;
  final File file;
  final Duration? duration;
  final String extension;
  final String size;
  final String fileLogo;

  final bool isVoiceNotePlaying;
  final bool isVoiceNotePaused;
  final Duration currentVoiceNotePosition;
  final Function(bool value) changeIsVoiceNotePlaying;
  final Function(bool value) changeIsVoiceNotePaused;
  final PlayAudio playAudio;

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  late bool isStarred;
  // final PlayAudio _playAudio = PlayAudio();
  //
  // late StreamSubscription _playbackCompleteSubscription;
  // late StreamSubscription _positionSubscription;

  // Duration currentPosition = Duration.zero;
  //
  // bool isPlaying = false;
  // bool isPause = false;
  bool isCurrentlyPlaying = false;

  void handleReplyButtonPressed() {
    widget.showReplyMessage(widget.message ?? widget.fileName, widget.senderName);
  }

  @override
  void initState() {
    super.initState();
    isStarred = widget.isStarred;
    // if(widget.messageType == 'audio'){
    //   audioInit();
    // }
  }

  @override
  void dispose() {
    // if(widget.messageType == 'audio'){
    //   _playAudio.dispose();
    //   _playbackCompleteSubscription.cancel();
    //   _positionSubscription.cancel();
    // }
    super.dispose();
  }

  // Future<void> audioInit() async {
  //   _playbackCompleteSubscription = _playAudio.playbackCompleteStream.listen((_) {
  //     setState(() {
  //       isPlaying = false;
  //       isPause = false;
  //     });
  //     widget.changeIsAudioPlayingAlready();
  //   });
  //   _positionSubscription = _playAudio.positionStream.listen((position) {
  //     print('current position: $position');
  //     setState(() {
  //       currentPosition = position;
  //     });
  //   });
  // }

  double formatDuration(Duration? duration) {
    int? totalSeconds = duration?.inSeconds;
    int? remainingMilliseconds = duration?.inMilliseconds.remainder(1000);
    double fractionOfSecond = remainingMilliseconds! / 1000.0;
    return totalSeconds! + fractionOfSecond;
  }

  Duration parseDuration(double seconds) {
    int totalSeconds = seconds.floor();
    double fractionalPart = seconds - totalSeconds;
    int remainingMilliseconds = (fractionalPart * 1000).round();

    int minutes = totalSeconds ~/ 60;
    int remainingSeconds = totalSeconds % 60;

    return Duration(minutes: minutes, seconds: remainingSeconds, milliseconds: remainingMilliseconds);
  }

  void playOrPauseVoiceNote() {
    if(!widget.isVoiceNotePlaying){
      setState(() {
        isCurrentlyPlaying = !isCurrentlyPlaying;
      });
      widget.playAudio.playVoiceNote(widget.fileName ?? '');
      widget.changeIsVoiceNotePlaying(true);
    } else {
      if(!widget.isVoiceNotePaused){
        widget.playAudio.pauseVoiceNote();
        // _playAudio.pauseVoiceNote(widget.fileName);
        widget.changeIsVoiceNotePaused(true);
      } else {
        widget.playAudio.resumeVoiceNote();
        // _playAudio.resumeVoiceNote(widget.fileName);
        widget.changeIsVoiceNotePaused(false);
      }
    }
    // if(!isPlaying){
    //   _playAudio.playVoiceNote(widget.fileName ?? '');
    //   setState(() {
    //     isPlaying =  true;
    //   });
    //   widget.changeIsAudioPlayingAlready();
    // } else {
    //   if(!isPause){
    //     _playAudio.pauseVoiceNote();
    //     // _playAudio.pauseVoiceNote(widget.fileName);
    //     setState(() {
    //       isPause = true;
    //     });
    //   } else {
    //     _playAudio.resumeVoiceNote();
    //     // _playAudio.resumeVoiceNote(widget.fileName);
    //     setState(() {
    //       isPause = false;
    //     });
    //   }
    // }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget>chatOrder = [
      (widget.messageType == 'text') ? chatBubble() : (widget.messageType == 'audio') ? audioBubble() : (widget.messageType == 'image') ? photoBubble() : (widget.messageType == 'file') ? fileBubble() : videoBubble(),
      Text(widget.chatTime, style: const TextStyle(color: Color(0xFF979C9E), fontSize: 8, fontFamily: 'Inter',),),
    ];
    List<Widget> reversedChatOrder = chatOrder.reversed.toList();

    return Padding(
        padding: EdgeInsets.only(top: 5, bottom: (widget.hasDifferentSender) ? 20 : 0),
        child: Column(
          children: [
            GestureDetector(
              onLongPress: (){
                if (widget.isChatSelected) {
                  widget.increaseDecreaseNumberOfSelectedBubbles('decrease');
                  widget.removeCopyDetailSecureStorage('[${widget.chatDate}, ${widget.chatTime}] ${widget.senderName}: ${(widget.messageType == 'text') ? widget.message : widget.fileName}');
                } else {
                  widget.increaseDecreaseNumberOfSelectedBubbles('increase');
                  widget.storeCopyDetailsSecureStorage('[${widget.chatDate}, ${widget.chatTime}] ${widget.senderName}: ${(widget.messageType == 'text') ? widget.message : widget.fileName}');
                }
                widget.changeIsChatSelected();
                widget.changeIsLongPressed();
              },
              onTap: (){
                if (widget.isChatSelected) {
                  widget.increaseDecreaseNumberOfSelectedBubbles('decrease');
                  widget.removeCopyDetailSecureStorage('[${widget.chatDate}, ${widget.chatTime}] ${widget.senderName}: ${(widget.messageType == 'text') ? widget.message : widget.fileName}');
                }
                if (widget.isLongPressed && !widget.isChatSelected){
                  widget.increaseDecreaseNumberOfSelectedBubbles('increase');
                  widget.storeCopyDetailsSecureStorage('[${widget.chatDate}, ${widget.chatTime}] ${widget.senderName}: ${(widget.messageType == 'text') ? widget.message : widget.fileName}');
                }
                if (widget.isChatSelected || widget.isLongPressed) {
                  widget.changeIsChatSelected();
                }
              },
              child: Row(
                mainAxisAlignment: (widget.isSender) ? MainAxisAlignment.end : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: (widget.isSender) ? reversedChatOrder : chatOrder
              ),
            ),
            chatBubbleOptions(),
          ],
        )
    );
  }

  Widget chatBubble() {
    return Stack(
      children: [
        BubbleSpecialThree(
          constraints: const BoxConstraints(
              maxWidth: 200,
              minHeight: 20
          ),
          text: widget.message ?? '',
          tail: widget.hasDifferentSender || widget.isNewDay ? true : false,
          isSender: widget.isSender,
          color: (widget.isSender)
              ? (widget.isChatSelected && widget.numberOfSelectedBubbles > 0)
              ? const Color(0xFFc0b5f9)
              : const Color(0xFF5538EE)
              : (widget.isChatSelected && widget.numberOfSelectedBubbles > 0)
              ? const Color(0xFFafb4b9)
              : const Color(0xFF303437),
          textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400
          ),
          userName: (widget.isGroup && !widget.isSender) ? widget.senderName : null,
          userNameTextStyle: const TextStyle(
              color: Color(0xFF979C9E),
              fontSize: 12,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400
          ),
          seen: widget.isSeen,
          sent: widget.isSent,
          delivered: true,
          chatId: widget.chatId
        ),
        Visibility(
          visible: isStarred,
          child: Positioned(
              left: (widget.isSender) ? 6 : null,
              right: (widget.isSender) ? null : 6,
              child: const Icon(Icons.star, size: 10, color: Colors.grey,)
          ),
        ),
      ],
    );
  }

  Widget audioBubble() {
    return Stack(
      children: [
        BubbleNormalAudio(
          onSeekChanged: (e){
            widget.playAudio.seekToPosition(parseDuration(e));
            // _playAudio.seekToPosition(widget.fileName, parseDuration(e));
          },
          onPlayPauseButtonClick: () {
            playOrPauseVoiceNote();
          },
          tail: widget.hasDifferentSender || widget.isNewDay ? true : false,
          isPlaying: (isCurrentlyPlaying) ? widget.isVoiceNotePlaying : false,
          isSender: widget.isSender,
          isPause: (isCurrentlyPlaying) ? widget.isVoiceNotePaused : false,
          duration: formatDuration(widget.duration),
          position: (widget.isVoiceNotePlaying && isCurrentlyPlaying) ? formatDuration(widget.currentVoiceNotePosition) : formatDuration(Duration.zero),
          bubbleRadius: 6,
          seen: widget.isSeen,
          sent: widget.isSent,
          chatId: widget.chatId,
          senderName: (widget.isGroup && !widget.isSender) ? widget.senderName : null,
          delivered: widget.isDelivered,
          textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 8,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400
          ),
          color: (widget.isSender)
              ? (widget.isChatSelected && widget.numberOfSelectedBubbles > 0)
              ? const Color(0xFFc0b5f9)
              : const Color(0xFF5538EE)
              : (widget.isChatSelected && widget.numberOfSelectedBubbles > 0)
              ? const Color(0xFFafb4b9)
              : const Color(0xFF303437),
        ),
        Visibility(
          visible: isStarred,
          child: Positioned(
              left: (widget.isSender) ? 9 : null,
              right: (widget.isSender) ? null : 7,
              top: (widget.isSender) ? 1 : 3,
              child: const Icon(Icons.star, size: 10, color: Colors.grey,)
          ),
        ),
      ],
    );
  }

  Widget photoBubble() {
    return Stack(
      children: [
        BubbleNormalImage(
          id: widget.fileName,
          senderName: widget.senderName,
          image: widget.file,
          isSender: widget.isSender,
          isGroup: widget.isGroup,
          bubbleRadius: 6,
          tail: widget.hasDifferentSender || widget.isNewDay ? true : false,
          color: (widget.isSender)
              ? (widget.isChatSelected && widget.numberOfSelectedBubbles > 0)
              ? const Color(0xFFc0b5f9)
              : const Color(0xFF5538EE)
              : (widget.isChatSelected && widget.numberOfSelectedBubbles > 0)
              ? const Color(0xFFafb4b9)
              : const Color(0xFF303437),
          seen: widget.isSeen,
          sent: widget.isSent,
          delivered: true,
          chatId: widget.chatId
        ),
        Visibility(
          visible: isStarred,
          child: Positioned(
              left: (widget.isSender) ? 7 : null,
              right: (widget.isSender) ? null : 5,
              top: (widget.isSender) ? -1 : 1,
              child: const Icon(Icons.star, size: 10, color: Colors.grey,)
          ),
        ),
      ],
    );
  }

  Widget fileBubble() {
    return Stack(
      children: [
        BubbleFile(
          extension: widget.extension,
          senderName: widget.senderName,
          isSender: widget.isSender,
          isGroup: widget.isGroup,
          fileName: widget.fileName,
          fileLogo: widget.fileLogo,
          seen: widget.isSeen,
          sent: widget.isSent,
          delivered: true,
          chatId: widget.chatId,
          size: widget.size,
          tail: widget.hasDifferentSender || widget.isNewDay ? true : false,
          bubbleRadius: 6,
          color: (widget.isSender)
              ? (widget.isChatSelected && widget.numberOfSelectedBubbles > 0)
              ? const Color(0xFFc0b5f9)
              : const Color(0xFF5538EE)
              : (widget.isChatSelected && widget.numberOfSelectedBubbles > 0)
              ? const Color(0xFFafb4b9)
              : const Color(0xFF303437),
        ),
        Visibility(
          visible: isStarred,
          child: Positioned(
              left: (widget.isSender) ? 6 : null,
              right: (widget.isSender) ? null : 6,
              top: (widget.isSender) ? -1 : 1,
              child: const Icon(Icons.star, size: 10, color: Colors.grey,)
          ),
        ),      ],
    );
  }

  Widget videoBubble() {
    return Stack(
      children: [
        BubbleNormalVideo(
          isGroup: widget.isGroup,
          senderName: widget.senderName,
          seen: widget.isSeen,
          sent: widget.isSent,
          delivered: true,
          chatId: widget.chatId,
          video: widget.file,
          bubbleRadius: 6,
          tail: widget.hasDifferentSender || widget.isNewDay ? true : false,
          color: (widget.isSender)
              ? (widget.isChatSelected && widget.numberOfSelectedBubbles > 0)
              ? const Color(0xFFc0b5f9)
              : const Color(0xFF5538EE)
              : (widget.isChatSelected && widget.numberOfSelectedBubbles > 0)
              ? const Color(0xFFafb4b9)
              : const Color(0xFF303437),
        ),
        Visibility(
          visible: isStarred,
          child: Positioned(
              left: (widget.isSender) ? 7 : null,
              right: (widget.isSender) ? null : 5,
              top: (widget.isSender) ? -1 : 1,
              child: const Icon(Icons.star, size: 10, color: Colors.grey,)
          ),
        ),
      ],
    );
  }

  Widget chatBubbleOptions () {
    return Visibility(
      visible: (widget.isChatSelected && widget.numberOfSelectedBubbles < 2),
      child: Padding(
        padding: EdgeInsets.only(bottom: (widget.hasDifferentSender) ? 0: 10, left: 20, top: 5, right: (widget.isSender) ? 20: 0),
        child: Row(
          mainAxisAlignment: (widget.isSender) ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: (){},
              child: SvgPicture.asset('assets/icons/corner_up_right_icon.svg', width: 14,),
            ), // forward
            const SizedBox(width: 10,),
            GestureDetector(
              onTap: () {
                if (widget.isChatSelected) {
                  widget.increaseDecreaseNumberOfSelectedBubbles('decrease');
                }
                FlutterClipboard.copy(((widget.messageType == 'text') ? widget.message : widget.fileName) ?? '');
                widget.changeIsChatSelected();
                widget.showCopyMessage();
              },
              child: const Icon(Icons.copy, size: 12, color: Color(0xFF979C9E),),
            ), // copy
            const SizedBox(width: 10,),
            GestureDetector(
                onTap: (){},
                child: Image.asset('assets/icons/push_pin_icon.png', width: 14, color: const Color(0xFF979C9E),)
            ), // pin
            const SizedBox(width: 10,),
            GestureDetector(
              onTap: (){
                if (widget.isChatSelected) {
                  widget.increaseDecreaseNumberOfSelectedBubbles('decrease');
                }
                setState(() {
                  isStarred = !isStarred;
                });
                widget.changeIsChatSelected();
              },
              child: Icon((isStarred)
                  ? Icons.star
                  : Icons.star_border_outlined,
                size: 14,
                color: (isStarred)
                    ? const Color(0xFF6B4EFF)
                    : const Color(0xFF979C9E),),
            ), // star
            const SizedBox(width: 10,),
            GestureDetector(
                onTap: handleReplyButtonPressed,
                child: Image.asset('assets/icons/reply_icon.png', width: 14, color: const Color(0xFF979C9E),)
            ), // reply
          ],
        ),
      ),
    );
  }
}
