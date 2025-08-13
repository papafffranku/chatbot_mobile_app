import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
//import '../theme/app_theme.dart';  

class ChatInterface extends StatefulWidget {
  final String initialMessage;

  const ChatInterface({super.key, required this.initialMessage});

  @override
  State<ChatInterface> createState() => _ChatInterfaceState();
}

class _ChatInterfaceState extends State<ChatInterface> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  StreamSubscription? _streamSubscription;
  String _currentStreamingMessage = '';
  bool _showJumpToBottom = false;
  bool _didHapticOnFirstChunk = false;
  

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final atBottom = _scrollController.hasClients &&
          _scrollController.position.pixels >=
          (_scrollController.position.maxScrollExtent - 120);
      if (_showJumpToBottom == atBottom) {
        setState(() => _showJumpToBottom = !atBottom);
      }
    });
    // Send the initial message when the chat interface loads
    if (widget.initialMessage.isNotEmpty) {
      _sendMessage(widget.initialMessage);
    }
  }
  

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    HapticFeedback.selectionClick(); // tap feedback on send
    _didHapticOnFirstChunk = false;


    // Add user message to chat
    setState(() {
      _messages.add(ChatMessage(
        text: message,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
      _currentStreamingMessage = '';
    });

    // Clear the text field
    _messageController.clear();

    // Scroll to bottom
    _scrollToBottom();

    try {
      // Ensure URL is clean (no line breaks)
      const apiUrl = 'https://visa-bot-240459290396.asia-south1.run.app/query/stream';
      
      // Create the request for streaming
      final request = http.Request('POST', Uri.parse(apiUrl));
      request.headers['Content-Type'] = 'application/json';
      request.headers['Accept'] = 'text/event-stream';
      request.body = json.encode({
        'user_id': 'Test12',
        'message': message,
      });

      // Add timeout for connection
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Connection timeout');
        },
      );

      if (streamedResponse.statusCode == 200) {
        // Add placeholder for streaming message
        ChatMessage streamingMessage = ChatMessage(
          text: '',
          isUser: false,
          timestamp: DateTime.now(),
          isStreaming: true,
        );
        
        setState(() {
          _messages.add(streamingMessage);
        });

        // Process the stream
        _streamSubscription = streamedResponse.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .listen(
          (line) {
            if (line.startsWith('data: ')) {
              final dataStr = line.substring(6);
              if (dataStr.trim().isNotEmpty) {
                try {
                  final data = json.decode(dataStr);
                  _handleStreamEvent(data, streamingMessage);
                } catch (e) {
                  print('Error parsing stream data: $e');
                }
              }
            }
          },
          onError: (error) {
            print('Stream error: $error');
            _handleStreamError();
          },
          onDone: () {
            setState(() {
              _isLoading = false;
            });
          },
          cancelOnError: true,
        );
      } else {
        // Try fallback to non-streaming endpoint
        _handleFallbackToNonStreaming(message);
      }
    } catch (e) {
      print('Error details: $e');
      // Try fallback to non-streaming endpoint
      _handleFallbackToNonStreaming(message);
    }
  }

  Future<void> _handleFallbackToNonStreaming(String message) async {
    try {
      print('Falling back to non-streaming endpoint...');
      
      // Remove the streaming message if it exists
      if (_messages.isNotEmpty && _messages.last.isStreaming) {
        setState(() {
          _messages.removeLast();
        });
      }
      
      // Show loading
      setState(() {
        _isLoading = true;
      });
      
      const apiUrl = 'https://visa-bot-240459290396.asia-south1.run.app/query';
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': 'Test12',
          'message': message,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Request timeout');
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final rawResponse = responseData['answer'] ?? 'Sorry, I couldn\'t process that.';
        final htmlResponse = _markdownToHtml(rawResponse);

        setState(() {
          _messages.add(ChatMessage(
            text: htmlResponse,
            isUser: false,
            timestamp: DateTime.now(),
          ));
          _isLoading = false;
        });
        _scrollToBottom();
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Fallback error: $e');
      _handleError(e.toString());
    }
  }

  void _handleStreamEvent(Map<String, dynamic> event, ChatMessage streamingMessage) {
    final eventType = event['type'];
    
    switch (eventType) {
      case 'loading':
        // Show loading message
        setState(() {
          _currentStreamingMessage = event['content'] ?? 'Processing...';
          streamingMessage.text = _currentStreamingMessage;
        });
        break;
        
      case 'chunk':
        if (!_didHapticOnFirstChunk) {
          HapticFeedback.selectionClick(); // first token arrives
          _didHapticOnFirstChunk = true;
        }

        // IMPORTANT: The backend sends accumulated content, not incremental
        // So we directly replace the text, not append
        setState(() {
          _currentStreamingMessage = event['content'] ?? '';
          
          // Convert markdown to HTML for better rendering
          streamingMessage.text = _markdownToHtml(_currentStreamingMessage);
          
          // Optional: Add a typing indicator effect by showing raw text while streaming
          // and only converting to HTML when done
          // streamingMessage.text = _currentStreamingMessage; // For raw text during streaming
        });
        
        // Auto-scroll to bottom as new content arrives
        _scrollToBottom();
        break;
        
      case 'complete':
        // Final complete message (for non-streaming responses)
        HapticFeedback.mediumImpact(); // reply finished

        setState(() {
          final content = event['content'] ?? '';
          streamingMessage.text = _markdownToHtml(content);
          streamingMessage.isStreaming = false;
          _isLoading = false;
        });
        _scrollToBottom();
        break;
        
      case 'memory':
        // Memory update - you can store this if needed for session management
        // final memory = event['memory'];
        break;
        
      case 'done':
        // Streaming complete
        setState(() {
          // Apply final markdown formatting if we were showing raw text
          streamingMessage.text = _markdownToHtml(_currentStreamingMessage);
          streamingMessage.isStreaming = false;
          _isLoading = false;
        });
        HapticFeedback.mediumImpact(); // completion feedback
        break;
        
      case 'error':
        _handleError(event['error'] ?? 'Unknown error');
        break;
    }
  }

  void _handleStreamError() {
    setState(() {
      if (_messages.isNotEmpty && _messages.last.isStreaming) {
        _messages.last.text = 'Sorry, the stream was interrupted. Please try again.';
        _messages.last.isStreaming = false;
      }
      _isLoading = false;
    });
  }

  void _handleError(String errorMessage) {
    setState(() {
      // Remove streaming message if exists
      if (_messages.isNotEmpty && _messages.last.isStreaming) {
        _messages.removeLast();
      }
      
      // Provide more user-friendly error messages
      String userMessage = 'Sorry, something went wrong. ';
      
      if (errorMessage.contains('SocketException') || 
          errorMessage.contains('Failed host lookup') ||
          errorMessage.contains('No address associated')) {
        userMessage = 'Unable to connect. Please check your internet connection and try again.';
      } else if (errorMessage.contains('TimeoutException')) {
        userMessage = 'Connection timed out. Please try again.';
      } else if (errorMessage.contains('500') || errorMessage.contains('502') || errorMessage.contains('503')) {
        userMessage = 'Server is temporarily unavailable. Please try again later.';
      } else {
        userMessage += 'Please try again.';
      }
      
      _messages.add(ChatMessage(
        text: userMessage,
        isUser: false,
        timestamp: DateTime.now(),
      ));
      _isLoading = false;
    });
  }

  String _markdownToHtml(String markdown) {
    String html = markdown;

    // First, fix URLs that might be split across lines
    // Handle URLs in angle brackets first (more specific)
    html = html.replaceAllMapped(
      RegExp(r'<(https?://[^>]+?)>', dotAll: true),
      (match) {
        // Remove any whitespace (including newlines) from within the URL
        String url = match.group(1)!.replaceAll(RegExp(r'\s+'), '');
        return '<$url>';
      },
    );

    // Handle markdown-style links [text](url) - including those with angle brackets
    html = html.replaceAllMapped(
      RegExp(r'\[([^\]]+?)\]\(<?([^)>]+?)>?\)', dotAll: true),
      (match) {
        String linkText = match.group(1)!.trim();
        // Remove any whitespace from within the URL
        String url = match.group(2)!.replaceAll(RegExp(r'\s+'), '');
        return '[$linkText]($url)';
      },
    );

    // Also handle bare URLs that might be split (without angle brackets)
    html = html.replaceAllMapped(
      RegExp(r'(https?://[^\s<>\[\]]+)', dotAll: true),
      (match) {
        String url = match.group(1)!;
        // Check if this URL seems to be broken by newlines
        if (url.contains('\n') || url.contains('\r')) {
          url = url.replaceAll(RegExp(r'\s+'), '');
        }
        return url;
      },
    );

    // Convert headers
    html = html.replaceAllMapped(
      RegExp(r'^## (.+)$', multiLine: true),
      (match) => '<h2>${match.group(1)}</h2>',
    );
    html = html.replaceAllMapped(
      RegExp(r'^### (.+)$', multiLine: true),
      (match) => '<h3>${match.group(1)}</h3>',
    );

    // Convert bold text
    html = html.replaceAllMapped(
      RegExp(r'\*\*(.+?)\*\*'),
      (match) => '<strong>${match.group(1)}</strong>',
    );

    // Convert bullet points
    html = html.replaceAllMapped(
      RegExp(r'^• (.+)$', multiLine: true),
      (match) => '<li>${match.group(1)}</li>',
    );

    // Wrap consecutive list items in ul tags
    html = html.replaceAllMapped(
      RegExp(r'(<li>.*?</li>\n?)+', multiLine: true),
      (match) => '<ul>${match.group(0)}</ul>',
    );

    // Convert links (after fixing them above)
    html = html.replaceAllMapped(
      RegExp(r'\[([^\]]+?)\]\(([^)]+?)\)'),
      (match) => '<a href="${match.group(2)?.trim()}">${match.group(1)}</a>',
    );

    // Convert line breaks
    html = html.replaceAll('\n\n', '<br>');
    html = html.replaceAll('\n', '<br>');

    return html;
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _launchURL(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open the link'),
              backgroundColor: Color(0xFF282442),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening link: $e'),
            backgroundColor: const Color(0xFF282442),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0913),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1d1936),
        elevation: 0,
        title: const Text(
          'Travel Assistant',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Chat messages area
          Expanded(
            child: Stack(
              children: [
                ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length + (_isLoading && _messages.isNotEmpty && !_messages.last.isStreaming ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length && _isLoading) {
                      return const TravelLoader();
                    }
                    final message = _messages[index];

                    if (message.isStreaming && message.text.isEmpty) {
                      return const TravelLoader();
                    }

                    return MessageBubble(
                      message: message,
                      onLinkTap: _launchURL,
                    );
                  },
                ),

                if (_showJumpToBottom)
                  Positioned(
                    right: 16,
                    bottom: 12, // sits above the composer
                    child: GestureDetector(
                      onTap: _scrollToBottom,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF282442),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.arrow_downward, size: 16, color: Colors.white),
                            SizedBox(width: 6),
                            Text('Jump to latest', style: TextStyle(color: Colors.white, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Input area
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF1d1936),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    minLines: 1,
                    maxLines: 5,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Ask me anything about travel...',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onSubmitted: _isLoading ? null : (_) => _sendMessage(_messageController.text),
                    enabled: !_isLoading,
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: _isLoading 
                      ? const Color(0xFF282442).withOpacity(0.5) 
                      : const Color(0xFF282442),
                  child: IconButton(
                    icon: Icon(
                      Icons.send, 
                      color: _isLoading 
                          ? Colors.white.withOpacity(0.5) 
                          : Colors.white,
                    ),
                    onPressed: _isLoading 
                        ? null 
                        : () {
                          HapticFeedback.lightImpact(); // click feel
                          _sendMessage(_messageController.text);
                        },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

// Chat message model
class ChatMessage {
  String text;
  final bool isUser;
  final DateTime timestamp;
  bool isStreaming;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isStreaming = false,
  });
}

// Message bubble widget
class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final Function(String) onLinkTap;

  const MessageBubble({
    super.key,
    required this.message,
    required this.onLinkTap,
  });

  String _plainTextFromHtml(String html) {
    var s = html.replaceAll('<br>', '\n')
                .replaceAll(RegExp(r'</p>|</li>'), '\n');
    s = s.replaceAll(RegExp(r'<[^>]+>'), ''); // strip tags
    s = s.replaceAll('&nbsp;', ' ')
         .replaceAll('&amp;', '&')
         .replaceAll('&lt;', '<')
         .replaceAll('&gt;', '>');
    return s.trim();
  }

  @override
  Widget build(BuildContext context) {
    // The bubble itself
    final bubble = Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      decoration: BoxDecoration(
        color: message.isUser ? const Color(0xFF282442) : const Color(0xFF1d1936),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.isUser)
            Text(
              message.text,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            )
          else
            HtmlWidget(
              message.text,
              textStyle: TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.5,
                fontWeight: message.isStreaming ? FontWeight.w300 : FontWeight.normal,
              ),
              onTapUrl: (url) {
                onLinkTap(url);
                return true;
              },
              customStylesBuilder: (element) {
                if (element.localName == 'h2') {
                  return {
                    'color': '#FFFFFF',
                    'font-size': '20px',
                    'font-weight': 'bold',
                    'margin': '16px 0 8px 0',
                  };
                }
                if (element.localName == 'h3') {
                  return {
                    'color': '#FFFFFF',
                    'font-size': '18px',
                    'font-weight': 'bold',
                    'margin': '12px 0 6px 0',
                  };
                }
                if (element.localName == 'strong') {
                  return {
                    'color': '#FFFFFF',
                    'font-weight': 'bold',
                  };
                }
                if (element.localName == 'a') {
                  return {
                    'color': '#5DADE2',
                    'text-decoration': 'underline',
                  };
                }
                if (element.localName == 'ul') {
                  return {
                    'margin': '8px 0',
                    'padding-left': '20px',
                  };
                }
                if (element.localName == 'li') {
                  return {
                    'color': '#FFFFFF',
                    'margin': '4px 0',
                  };
                }
                return null;
              },
            ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                _formatTime(message.timestamp),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 11,
                ),
              ),
              if (message.isStreaming) ...[
                const SizedBox(width: 8),
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withOpacity(0.3),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );

    if (message.isUser) {
      // Right-aligned with user avatar
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(child: bubble),
          const SizedBox(width: 8),
          const CircleAvatar(
            radius: 12,
            backgroundColor: Color(0xFF282442),
            child: Icon(Icons.person, size: 14, color: Colors.white),
          ),
        ],
      );
    }

    // Assistant: left-aligned with bot avatar and a small copy button below
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(
          radius: 12,
          backgroundColor: Color(0xFF5DADE2),
          child: Icon(Icons.travel_explore, size: 14, color: Colors.white),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              bubble,
              const SizedBox(height: 4),
              TextButton.icon(
                onPressed: () async {
                  final text = _plainTextFromHtml(message.text);
                  await Clipboard.setData(ClipboardData(text: text));
                  HapticFeedback.selectionClick();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Copied')),
                  );
                },
                icon: const Icon(Icons.copy, size: 14, color: Colors.white70),
                label: const Text('Copy', style: TextStyle(fontSize: 12, color: Colors.white70)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}


// Travel-themed loader widget (keeping your existing implementation)
class TravelLoader extends StatefulWidget {
  const TravelLoader({super.key});

  @override
  State<TravelLoader> createState() => _TravelLoaderState();
}

class _TravelLoaderState extends State<TravelLoader>
    with TickerProviderStateMixin {
  late AnimationController _iconController;
  late AnimationController _dotController;
  late Animation<double> _iconScale;
  late Animation<double> _iconOpacity;
  late Animation<Offset> _iconSlide;
  
  int currentIconIndex = 0;
  
  final List<IconData> travelIcons = [
    Icons.flight_takeoff,
    Icons.directions_car,
    Icons.train,
    Icons.directions_boat,
    Icons.directions_bus,
    Icons.location_on,
    Icons.explore,
    Icons.luggage,
  ];

  @override
  void initState() {
    super.initState();
    
    // Icon animation controller
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    // Dot animation controller
    _dotController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
    
    // Icon animations with bounce effect
    _iconScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.7, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.2, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 50,
      ),
    ]).animate(_iconController);
    
    _iconOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _iconController,
      curve: Curves.easeOut,
    ));
    
    _iconSlide = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _iconController,
      curve: Curves.easeOut,
    ));
    
    // Start icon switching
    _startIconSwitching();
  }
  
  void _startIconSwitching() {
    Future.delayed(Duration.zero, () {
      _iconController.forward();
    });
    
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          currentIconIndex = (currentIconIndex + 1) % travelIcons.length;
        });
        _iconController.reset();
        _startIconSwitching();
      }
    });
  }

  @override
  void dispose() {
    _iconController.dispose();
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1d1936),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            SizedBox(
              width: 20,
              height: 20,
              child: SlideTransition(
                position: _iconSlide,
                child: ScaleTransition(
                  scale: _iconScale,
                  child: FadeTransition(
                    opacity: _iconOpacity,
                    child: Icon(
                      travelIcons[currentIconIndex],
                      size: 16,
                      color: const Color(0xFF5DADE2), // Light blue accent color
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Text
            Text(
              'Thinking',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
            const SizedBox(width: 4),
            // Dots
            Row(
              children: List.generate(3, (index) {
                return AnimatedBuilder(
                  animation: _dotController,
                  builder: (context, child) {
                    final value = (_dotController.value + index * 0.2) % 1.0;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF5DADE2).withOpacity(
                          value < 0.5 ? value * 2 : 2 - value * 2,
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}