import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui'; // For ImageFilter
import 'chat_interface.dart'; // Import the chat interface
import '../theme/app_theme.dart';
import 'package:mesh_gradient/mesh_gradient.dart';
import '../Settings/SettingsPage.dart';
// ignore_for_file: prefer_const_constructors

class FadeScalePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration duration;

  FadeScalePageRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 500),
  }) : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionDuration: duration,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(
                  begin: 0.95,
                  end: 1.0,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
                child: child,
              ),
            );
          },
        );
}

// New page for suggestions
class SuggestionsPage extends StatelessWidget {
  const SuggestionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.65), // dim overlay
      body: Center(
        child: Hero(
          tag: 'suggestions-hero',
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: screenSize.width * 0.9,
              height: screenSize.height * 0.7,
              margin: EdgeInsets.all(screenSize.width * 0.05),
              decoration: BoxDecoration(
                color: AppTheme.panel, // was white
                borderRadius: BorderRadius.circular(AppTheme.radius),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.35),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header with close
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'More Suggestions',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white70),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),

                  // Suggestions list
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        _buildSuggestionTile(
                          context,
                          Icons.language,
                          "What are the visa requirements for Japan?",
                        ),
                        _buildSuggestionTile(
                          context,
                          Icons.attach_money,
                          "How much does a Schengen visa cost?",
                        ),
                        _buildSuggestionTile(
                          context,
                          Icons.schedule,
                          "Best time to visit New Zealand?",
                        ),
                        _buildSuggestionTile(
                          context,
                          Icons.local_hospital,
                          "Travel insurance requirements for Europe?",
                        ),
                        _buildSuggestionTile(
                          context,
                          Icons.restaurant,
                          "Top restaurants in Paris with vegetarian options?",
                        ),
                        _buildSuggestionTile(
                          context,
                          Icons.beach_access,
                          "Best beaches in Thailand for families?",
                        ),
                        _buildSuggestionTile(
                          context,
                          Icons.hiking,
                          "Hiking trails in Switzerland for beginners?",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionTile(BuildContext context, IconData icon, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppTheme.bubbleUser, // was light grey
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          splashColor: AppTheme.accent.withOpacity(0.12),
          highlightColor: Colors.white.withOpacity(0.02),
          onTap: () {
            // haptics for consistency
            HapticFeedback.selectionClick();
            Navigator.pop(context);
            Navigator.push(
              context,
              FadeScalePageRoute(
                page: ChatInterface(initialMessage: text),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: AppTheme.accent, size: 22),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white, // was dark text
                      height: 1.2,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class backgroundCanvas extends StatefulWidget {
  const backgroundCanvas({super.key});

  @override
  State<backgroundCanvas> createState() => _backgroundCanvasState();
}

class _backgroundCanvasState extends State<backgroundCanvas> {
  String newMessage = '';
  final TextEditingController _textController = TextEditingController();
  static const double _kInputBarHeight = 84.0;

  void _navigateToChat(String message) {
    if (message.trim().isNotEmpty) {
      Navigator.push(
        context,
        FadeScalePageRoute(
          page: ChatInterface(initialMessage: message),
        ),
      );
    }
  }

  void _openSuggestions() {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) => SuggestionsPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppTheme.bg,
      body: AnimatedMeshGradient(
        colors: const [
          Color(0xFF0a0b1e), // Deep space blue
          Color(0xFF4c1d95), // Rich purple
          Color(0xFF3b82f6), // Sky blue
          Color(0xFF06b6d4), // Cyan
        ],
        options: AnimatedMeshGradientOptions(
          amplitude: 30,
          frequency: 5,
          speed: 3,
        ),
        child: SafeArea(
          top: true,
          bottom: false,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => FocusScope.of(context).unfocus(),
            child: Stack(
              children: [
                // Settings button at top right
                Positioned(
                  top: 16,
                  right: 16,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              HapticFeedback.lightImpact();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SettingsPage(),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.settings, color: Colors.white, size: 18),
                                  SizedBox(width: 6),
                                  Text(
                                    'Settings',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            
                // Main content (bottom-anchored, above input bar)
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    // leave room for the input bar + safe area + a little breathing space
                    bottom: MediaQuery.of(context).padding.bottom + _kInputBarHeight + 12,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Centered "More suggestions" chip
                      Center(
                        child: GestureDetector(
                          onTap: _openSuggestions,
                          child: Hero(
                            tag: 'suggestions-hero',
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppTheme.bubbleUser.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.1),
                                      width: 1,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: RichText(
                                      textAlign: TextAlign.center,
                                      text: const TextSpan(
                                        children: [
                                          TextSpan(
                                            text: "More suggestions ",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.white,
                                            ),
                                          ),
                                          WidgetSpan(
                                            alignment: PlaceholderAlignment.middle,
                                            child: Icon(
                                              Icons.arrow_forward_ios,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
            
                      const SizedBox(height: 12),
            
                      // Suggestions grid (centered, responsive)
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final w = constraints.maxWidth;
            
                          int crossAxisCount;
                          if (w >= 1100) {
                            crossAxisCount = 3;          // big iPad / desktop-like widths
                          } else if (w >= 340) {
                            crossAxisCount = 2;          // phones (default)
                          } else {
                            crossAxisCount = 1;          // very narrow edge case
                          }
            
                          // Keep pills looking nice per column count
                          final double aspect =
                              (crossAxisCount == 3) ? 3.2 :
                              (crossAxisCount == 2) ? 2.8 :
                              2.4;
            
                          return Align(
                            alignment: Alignment.topCenter,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 1000),
                              child: GridView.count(
                                crossAxisCount: crossAxisCount,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: aspect,
                                children: [
                                  GestureDetector(
                                    onTap: () => _navigateToChat("Give me documents for a US Visa?"),
                                    child: centeredTextContainer(
                                      boldText: "Give me documents",
                                      normalText: " for a US Visa?",
                                      icon: const Icon(Icons.description, color: Colors.white, size: 20),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => _navigateToChat("How long does it take to process a UK work visa?"),
                                    child: centeredTextContainer(
                                      boldText: "How long does it take to process",
                                      normalText: " a UK work visa?",
                                      icon: const Icon(Icons.timelapse_rounded, color: Colors.white, size: 20),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => _navigateToChat("Give me flights to London if I want to leave at 20th October."),
                                    child: centeredTextContainer(
                                      boldText: "Give me flights to London",
                                      normalText: " if I want to leave at 20th October.",
                                      icon: const Icon(Icons.flight_rounded, color: Colors.white, size: 20),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => _navigateToChat("Give me hotel options in Athens from 16th May to 20th May 2026."),
                                    child: centeredTextContainer(
                                      boldText: "Give me hotel options in Athens",
                                      normalText: " from 16th May to 20th May 2026.",
                                      icon: const Icon(Icons.local_hotel_rounded, color: Colors.white, size: 20),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
            
                      ),
                    ],
                  ),
                ),
              ),
              // Input area absolutely stuck to the very bottom (ignores safe-area)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: MediaQuery.removePadding(
                  context: context,
                  removeBottom: true, // <- strips any inherited SafeArea/padding at bottom
                  child: Padding(
                    // Lift exactly by keyboard height (0 when closed)
                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 1000, sigmaY: 1000),
                        child: Container(
                          // no extra bottom padding here
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                            border: Border(
                              top: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
                              left: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
                              right: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.15),
                                      width: 1,
                                    ),
                                  ),
                                  child: TextField(
                                    controller: _textController,
                                    onChanged: (v) => setState(() => newMessage = v),
                                    onSubmitted: _navigateToChat,
                                    style: const TextStyle(color: Colors.white, fontSize: 16),
                                    decoration: InputDecoration(
                                      hintText: 'Where shall we travel?',
                                      hintStyle: TextStyle(
                                        color: Colors.black.withOpacity(0.45),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 12,
                                      ),
                                      prefixIcon: Icon(
                                        Icons.explore,
                                        color: Colors.black.withOpacity(0.45),
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                                    colors: [AppTheme.bubbleUser, AppTheme.accent],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.accent.withOpacity(0.3),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(50),
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      _navigateToChat(_textController.text);
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.all(12),
                                      child: Icon(Icons.send, color: Colors.white, size: 24),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            
            
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget centeredTextContainer({
    required String boldText,
    required String normalText,
    Widget? icon,
  }) {
    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(
          minHeight: 64,   // base touch target
          maxHeight: 100,  // keep it from getting too tall on huge screens
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.panel.withOpacity(0.85),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.05),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              icon,
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: boldText,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    TextSpan(
                      text: normalText,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.white70,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }


  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}