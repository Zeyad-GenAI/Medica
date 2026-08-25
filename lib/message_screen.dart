import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'services/clinical_guidelines_api_service.dart';
import 'shared_widgets.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final ClinicalGuidelinesApi _api = ClinicalGuidelinesApi.instance;

  final List<_ChatMessage> _messages = <_ChatMessage>[];

  bool _showEmojiPicker = false;
  bool _isListening = false;
  bool _speechAvailable = false;
  bool _isSending = false;
  bool _isLoadingHistory = false;

  static const List<String> _emojis = <String>[
    '😀', '😃', '😄', '😁', '😆', '😅', '😂', '🤣',
    '😊', '😇', '🙂', '🙃', '😉', '😌', '😍', '🥰',
    '😘', '😎', '🤩', '🤔', '😐', '😴', '😢', '😭',
    '😡', '👍', '👎', '👏', '🙏', '❤️', '🔥', '🎉',
    '✅', '❌',
  ];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _speech.stop();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    if (!_api.isAuthenticated) return;

    setState(() {
      _isLoadingHistory = true;
    });

    try {
      final history = await _api.loadHistory();
      if (!mounted) return;

      setState(() {
        _messages
          ..clear()
          ..addAll(
            history.map(
                  (message) => _ChatMessage(
                text: message.content,
                imagePath: null,
                isMe: message.role.toLowerCase() == 'user',
                sentAt: DateTime.now(),
                sources: const <ApiSource>[],
              ),
            ),
          );
      });

      await _scrollToBottom();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not load chat history: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingHistory = false;
        });
      }
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() {
      _messages.add(
        _ChatMessage(
          text: text,
          imagePath: null,
          isMe: true,
          sentAt: DateTime.now(),
          sources: const <ApiSource>[],
        ),
      );
      _messageController.clear();
      _showEmojiPicker = false;
      _isSending = true;
    });

    await _scrollToBottom();

    try {
      final response = await _api.sendMessage(text);

      if (!mounted) return;

      setState(() {
        _messages.add(
          _ChatMessage(
            text: response.answer,
            imagePath: null,
            isMe: false,
            sentAt: DateTime.now(),
            sources: response.sources,
          ),
        );
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _messages.add(
          _ChatMessage(
            text: 'I could not answer right now.\n$error',
            imagePath: null,
            isMe: false,
            sentAt: DateTime.now(),
            sources: const <ApiSource>[],
          ),
        );
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
      await _scrollToBottom();
    }
  }

  Future<void> _pickImage() async {
    FocusScope.of(context).unfocus();

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Take a photo'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    try {
      final pickedImage = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1600,
      );

      if (pickedImage == null || !mounted) return;

      setState(() {
        _messages.add(
          _ChatMessage(
            text: null,
            imagePath: pickedImage.path,
            isMe: true,
            sentAt: DateTime.now(),
            sources: const <ApiSource>[],
          ),
        );
      });

      await _scrollToBottom();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not select image: $error')),
      );
    }
  }

  Future<void> _toggleMicrophone() async {
    if (_isListening) {
      await _speech.stop();
      if (!mounted) return;
      setState(() => _isListening = false);
      return;
    }

    try {
      _speechAvailable = await _speech.initialize(
        onStatus: (status) {
          if (!mounted) return;
          if (status == 'notListening' || status == 'done') {
            setState(() => _isListening = false);
          }
        },
        onError: (error) {
          if (!mounted) return;
          setState(() => _isListening = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Microphone error: ${error.errorMsg}')),
          );
        },
      );

      if (!_speechAvailable) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Speech recognition is not available.'),
          ),
        );
        return;
      }

      setState(() {
        _isListening = true;
        _showEmojiPicker = false;
      });

      await _speech.listen(
        onResult: (result) {
          if (!mounted) return;
          setState(() {
            _messageController.text = result.recognizedWords;
            _messageController.selection = TextSelection.fromPosition(
              TextPosition(offset: _messageController.text.length),
            );
          });
        },
        listenFor: const Duration(minutes: 2),
        pauseFor: const Duration(seconds: 5),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _isListening = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not start microphone: $error')),
      );
    }
  }

  void _toggleEmojiPicker() {
    FocusScope.of(context).unfocus();
    setState(() => _showEmojiPicker = !_showEmojiPicker);
  }

  void _insertEmoji(String emoji) {
    final currentText = _messageController.text;
    final selection = _messageController.selection;
    final start = selection.start < 0 ? currentText.length : selection.start;
    final end = selection.end < 0 ? currentText.length : selection.end;
    final updatedText = currentText.replaceRange(start, end, emoji);

    setState(() {
      _messageController.text = updatedText;
      _messageController.selection = TextSelection.collapsed(
        offset: start + emoji.length,
      );
    });
  }

  Future<void> _scrollToBottom() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    if (!_scrollController.hasClients) return;

    await _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Color(0xFF12879A)),
        centerTitle: true,
        title: Text(
          'Medica Assistant',
          style: TextStyle(
            color: kPrimaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildMessagesArea(context)),
            if (_showEmojiPicker) _buildEmojiPicker(),
            _buildMessageComposer(context),
          ],
        ),
      ),
      bottomNavigationBar: appBottomNav(context, 1),
    );
  }

  Widget _buildMessagesArea(BuildContext context) {
    if (_isLoadingHistory) {
      return const Center(
        child: CircularProgressIndicator(color: kPrimaryColor),
      );
    }

    if (_messages.isEmpty && !_isSending) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: Text(
            'Ask a clinical question to get evidence-based guidance from the Clinical Guidelines Assistant.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, height: 1.4),
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _messages.length + (_isSending ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length) {
          return const _TypingBubble();
        }
        return _buildMessageBubble(context, _messages[index]);
      },
    );
  }

  Widget _buildMessageBubble(
      BuildContext context,
      _ChatMessage message,
      ) {
    final bubbleColor = message.isMe
        ? kPrimaryColor
        : const Color(0xFFF0F5F5);

    return Align(
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 330),
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: message.imagePath != null
            ? ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(
            File(message.imagePath!),
            width: 230,
            height: 180,
            fit: BoxFit.cover,
          ),
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MarkdownBody(
              data: message.text ?? '',
              selectable: true,
              styleSheet: MarkdownStyleSheet(
                p: TextStyle(
                  color: message.isMe ? Colors.white : Colors.black87,
                  fontSize: 15,
                  height: 1.55,
                ),
                strong: TextStyle(
                  color: message.isMe ? Colors.white : Colors.black87,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  height: 1.55,
                ),
                em: TextStyle(
                  color: message.isMe ? Colors.white : Colors.black87,
                  fontSize: 15,
                  height: 1.55,
                ),
                listBullet: TextStyle(
                  color: message.isMe ? Colors.white : Colors.black87,
                  fontSize: 15,
                ),
                h1: const TextStyle(
                  color: kPrimaryColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                h2: const TextStyle(
                  color: kPrimaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                h3: const TextStyle(
                  color: kPrimaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                blockquote: TextStyle(
                  color: message.isMe ? Colors.white70 : Colors.black54,
                  fontSize: 14,
                ),
                code: TextStyle(
                  color: message.isMe ? Colors.white : Colors.black87,
                  fontSize: 13,
                  backgroundColor: message.isMe
                      ? Colors.white24
                      : Colors.white,
                ),
              ),
            ),
            if (!message.isMe && message.sources.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 6),
              Text(
                'Sources',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              ...message.sources.map(
                    (source) => Text(
                  '${source.source}${source.page == null ? '' : ' · p. ${source.page}'}',
                  style: const TextStyle(
                    color: Colors.black45,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMessageComposer(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.newline,
              onTap: () {
                if (_showEmojiPicker) {
                  setState(() => _showEmojiPicker = false);
                }
              },
              decoration: appInputDecoration(
                context,
                'Ask a clinical question...',
                prefixIcon: IconButton(
                  icon: const Icon(
                    Icons.emoji_emotions_outlined,
                    color: Colors.grey,
                  ),
                  onPressed: _toggleEmojiPicker,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.grey,
                  ),
                  onPressed: _pickImage,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _CircleActionButton(
            backgroundColor: _isListening ? Colors.red : kPrimaryColor,
            icon: _isListening ? Icons.stop : Icons.mic_none,
            onPressed: _toggleMicrophone,
          ),
          const SizedBox(width: 8),
          _CircleActionButton(
            backgroundColor: kPrimaryColor,
            icon: Icons.send,
            onPressed: _isSending ? () {} : _sendMessage,
          ),
        ],
      ),
    );
  }

  Widget _buildEmojiPicker() {
    return Container(
      height: 190,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFFF7F7F7),
        border: Border(top: BorderSide(color: Color(0xFFE5E5E5))),
      ),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
        ),
        itemCount: _emojis.length,
        itemBuilder: (context, index) {
          final emoji = _emojis[index];
          return InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => _insertEmoji(emoji),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 25)),
            ),
          );
        },
      ),
    );
  }
}

class _CircleActionButton extends StatelessWidget {
  final Color backgroundColor;
  final IconData icon;
  final VoidCallback onPressed;

  const _CircleActionButton({
    required this.backgroundColor,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: backgroundColor,
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 19),
        onPressed: onPressed,
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F5F5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: kPrimaryColor,
          ),
        ),
      ),
    );
  }
}

class _ChatMessage {
  final String? text;
  final String? imagePath;
  final bool isMe;
  final DateTime sentAt;
  final List<ApiSource> sources;

  const _ChatMessage({
    required this.text,
    required this.imagePath,
    required this.isMe,
    required this.sentAt,
    required this.sources,
  });
}
