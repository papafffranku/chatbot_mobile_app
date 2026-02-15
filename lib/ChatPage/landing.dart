import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui'; // For ImageFilter
import 'dart:math'; // For trigonometric functions and Random
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
class SuggestionsPage extends StatefulWidget {
  const SuggestionsPage({super.key});

  @override
  State<SuggestionsPage> createState() => _SuggestionsPageState();
}

class _SuggestionsPageState extends State<SuggestionsPage> 
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    
    // Start fade-in after Hero animation completes
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _fadeController.forward();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async => true,
      child: GestureDetector(
        onTap: () => Navigator.pop(context), // Tap outside to close
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              // Frosted glass backdrop
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    color: Colors.black.withOpacity(0.3), // Slight dark tint
                  ),
                ),
              ),
              Center(
                child: GestureDetector(
                  onTap: () {}, // Prevent tap-through
                  child: Hero(
                    tag: 'suggestions-hero',
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        width: screenSize.width * 0.9,
                        height: screenSize.height * 0.7,
                        margin: EdgeInsets.all(screenSize.width * 0.05),
                        decoration: BoxDecoration(
                          color: AppTheme.panel.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(AppTheme.radius),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppTheme.radius),
                          child: Column(
                            children: [
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
                              Expanded(
                                child: FadeTransition(
                                  opacity: _fadeAnimation,
                                  child: ListView(
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    physics: const BouncingScrollPhysics(),
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
                                  ),],),
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
    )
  ));
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

class _backgroundCanvasState extends State<backgroundCanvas> 
    with TickerProviderStateMixin {
  String newMessage = '';
  final TextEditingController _textController = TextEditingController();
  
  // Animation controllers
  late AnimationController _greetingFadeController;
  late AnimationController _subtextScaleController;
  late Animation<double> _greetingFadeAnimation;
  late Animation<double> _subtextScaleAnimation;
  late Animation<double> _subtextFadeAnimation;
  
  // Flight animations
  final List<AnimationController> _flightControllers = [];
  final List<Animation<double>> _flightAnimations = [];
  final List<double> _flightYOffsets = []; // Random Y positions
  final List<double> _flightSpeeds = []; // Random speeds
  final List<double> _parabolaHeights = []; // Random parabola heights
  final List<bool> _flightDirections = []; // true = left to right, false = right to left
  final Random _random = Random();
  final List<double> _endYOffsets = [];
  final List<double> _ctrlXJitters = [];
  
  // Get time-based greeting
  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  // Format a DateTime as "15th March 2026"
  String _formatDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    final day = date.day;
    String suffix;
    if (day >= 11 && day <= 13) {
      suffix = 'th';
    } else {
      switch (day % 10) {
        case 1: suffix = 'st'; break;
        case 2: suffix = 'nd'; break;
        case 3: suffix = 'rd'; break;
        default: suffix = 'th';
      }
    }
    return '$day$suffix ${months[date.month - 1]} ${date.year}';
  }
  
  @override
  void initState() {
    super.initState();
    
    // Initialize greeting fade animation
    _greetingFadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _greetingFadeAnimation = CurvedAnimation(
      parent: _greetingFadeController,
      curve: Curves.easeIn,
    );
    
    // Initialize subtext scale animation
    _subtextScaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _subtextScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _subtextScaleController,
      curve: Curves.elasticOut,
    ));
    
    _subtextFadeAnimation = CurvedAnimation(
      parent: _subtextScaleController,
      curve: Curves.easeIn,
    );
    
    // Initialize 6 flight animations
    for (int i = 0; i < 6; i++) {
    final controller = AnimationController(
      duration: Duration(seconds: 8 + _random.nextInt(8)),
      vsync: this,
    );
    _flightControllers.add(controller);

    // Random direction (true = L→R)
    final bool goingRight = _random.nextBool();
    _flightDirections.add(goingRight);

    // Always 0→1; we’ll handle direction in the builder
    _flightAnimations.add(Tween<double>(begin: 0.0, end: 1.0).animate(controller));

    // Randomized path params
    _flightYOffsets.add(_random.nextDouble() * 60.0);           // start Y (0..60)
    _endYOffsets.add(_random.nextDouble() * 60.0);              // end Y (0..60)
    _parabolaHeights.add(-15.0 + _random.nextDouble() * 30.0);  // vertical bump
    _ctrlXJitters.add((_random.nextDouble() - 0.5) * 80.0);     // +/- 40px
    _flightSpeeds.add(0.7 + _random.nextDouble() * 0.6);

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // New random path next loop
        _flightYOffsets[i]  = _random.nextDouble() * 60.0;
        _endYOffsets[i]     = _random.nextDouble() * 60.0;
        _parabolaHeights[i] = -15.0 + _random.nextDouble() * 30.0;
        _ctrlXJitters[i]    = (_random.nextDouble() - 0.5) * 80.0;
        _flightSpeeds[i]    = 0.7 + _random.nextDouble() * 0.6;

        // Maybe flip direction
        _flightDirections[i] = _random.nextBool();

        // Keep tween 0→1; restart
        controller.duration = Duration(
          milliseconds: ((8000 + _random.nextInt(8000)) / _flightSpeeds[i]).round(),
        );
        controller.forward(from: 0.0);
      }
    });
  }    
    // Start animations
    _greetingFadeController.forward().then((_) {
      // After greeting fades in, start subtext animation
      _subtextScaleController.forward();
      
      // Start flight animations with staggered delays
      for (int i = 0; i < _flightControllers.length; i++) {
        Future.delayed(Duration(milliseconds: i * 1500), () {
          if (mounted) {
            _flightControllers[i].forward(from: 0.0);
          }
        });
      }
    });
  }
  
  @override
  void dispose() {
    _greetingFadeController.dispose();
    _subtextScaleController.dispose();
    for (var controller in _flightControllers) {
      controller.dispose();
    }
    _textController.dispose();
    super.dispose();
  }

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
      opaque: false, 
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 400),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => const SuggestionsPage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ),
          child: child,
        );
      },
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final keyboardHeight = media.viewInsets.bottom;
    final hasKeyboard = keyboardHeight > 0;

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
        child: Stack(
          children: [
            // Settings button at top right
            Positioned(
              top: media.padding.top + 16,
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
            // Flying airplane animations - wrap in a Stack that allows overflow
            Stack(
              clipBehavior: Clip.none, // This is the key - allows rendering outside bounds
              children: [
                for (int i = 0; i < _flightAnimations.length; i++)
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 70,
                    left: 0,
                    child: AnimatedBuilder(
                      animation: _flightAnimations[i],
                      builder: (context, child) {
                        final double screenWidth = MediaQuery.of(context).size.width;
                        const double iconSize = 16.0;
                        
                        // Now planes can truly go off-screen
                        final double minX = -iconSize - 20;  // Start fully off-screen left
                        final double maxX = screenWidth + 20; // End fully off-screen right
                        
                        final double t = _flightAnimations[i].value;
                        final bool goingRight = _flightDirections[i];
                        
                        final double startX = goingRight ? minX : maxX;
                        final double endX   = goingRight ? maxX : minX;
                        
                        // Vertical positions
                        final double startY = _flightYOffsets[i];
                        final double endY   = _endYOffsets[i];
                        
                        // Control point centered on screen
                        final double ctrlX = (screenWidth / 2) + _ctrlXJitters[i];
                        final double ctrlY = ((startY + endY) / 2) + _parabolaHeights[i];
                        
                        // Quadratic Bézier calculation
                        final double u = 1.0 - t;
                        final double x = u*u*startX + 2*u*t*ctrlX + t*t*endX;
                        final double y = u*u*startY + 2*u*t*ctrlY + t*t*endY;
                        
                        // Tangent for rotation
                        final double dx = 2*u*(ctrlX - startX) + 2*t*(endX - ctrlX);
                        final double dy = 2*u*(ctrlY - startY) + 2*t*(endY - ctrlY);
                        final double angle = atan2(dy, dx);
                        
                        return Transform.translate(
                          offset: Offset(x, y),
                          child: Transform.rotate(
                            angle: angle + pi / 2,
                            child: const Icon(
                              Icons.flight,
                              color: Color(0xFF93C5FD),
                              size: iconSize,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),

            // Animated Greeting at top left
            Positioned(
              top: media.padding.top + 70,
              left: 20,
              width: MediaQuery.of(context).size.width + 32,
              height: 80,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeTransition(
                    opacity: _greetingFadeAnimation,
                    child: Text(
                      getGreeting(),
                      style: const TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                        height: 1.1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  FadeTransition(
                    opacity: _subtextFadeAnimation,
                    child: ScaleTransition(
                      scale: _subtextScaleAnimation,
                      child: Text(
                        'Where shall we go today?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withOpacity(0.85),
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Main content with input bar
            Column(
              children: [
                // Greeting and suggestions content
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: hasKeyboard ? 20 : 16,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // "More suggestions" chip
                        GestureDetector(
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
                        
                        const SizedBox(height: 6),
                        
                        // Suggestions grid
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 600),
                          child: GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1.8,
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
                                onTap: () => _navigateToChat("Prepare an itinerary for a 7-day trip to Paris"),
                                child: centeredTextContainer(
                                  boldText: "Prepare an itinerary for a 7-day",
                                  normalText: " trip to Paris ",
                                  icon: const Icon(Icons.timelapse_rounded, color: Colors.white, size: 20),
                                ),
                              ),
                              Builder(
                                builder: (context) {
                                  final now = DateTime.now();
                                  final flightDate = DateTime(now.year, now.month + 1, now.day);
                                  final flightDateStr = _formatDate(flightDate);
                                  return GestureDetector(
                                    onTap: () => _navigateToChat("Give me flights to London if I want to leave at $flightDateStr."),
                                    child: centeredTextContainer(
                                      boldText: "Give me flights to London",
                                      normalText: " if I want to leave at $flightDateStr.",
                                      icon: const Icon(Icons.flight_rounded, color: Colors.white, size: 20),
                                      maxLines: 4,
                                    ),
                                  );
                                },
                              ),
                              Builder(
                                builder: (context) {
                                  final now = DateTime.now();
                                  final checkIn = DateTime(now.year, now.month + 2, now.day);
                                  final checkOut = checkIn.add(const Duration(days: 4));
                                  final checkInStr = _formatDate(checkIn);
                                  final checkOutStr = _formatDate(checkOut);
                                  return GestureDetector(
                                    onTap: () => _navigateToChat("Give me hotel options in Athens from $checkInStr to $checkOutStr."),
                                    child: centeredTextContainer(
                                      boldText: "Give me hotel options in Athens",
                                      normalText: " from $checkInStr to $checkOutStr.",
                                      icon: const Icon(Icons.local_hotel_rounded, color: Colors.white, size: 20),
                                      maxLines: 4,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Input bar at bottom
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  transform: Matrix4.translationValues(0, hasKeyboard ? -keyboardHeight : 0, 0),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 1000, sigmaY: 1000),
                      child: Container(
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
                        child: SafeArea(
                          top: false,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
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
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
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
          ],
        ),
      ),
    );
  }

  Widget centeredTextContainer({
    required String boldText,
    required String normalText,
    Widget? icon,
    int maxLines = 3,
  }) {
    // Determine if this is a longer text item that needs more height
    final bool needsTallerBox = maxLines >= 4;
    
    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          minHeight: needsTallerBox ? 80 : 64,
          maxHeight: needsTallerBox ? 180 : 120,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 12, 
          vertical: needsTallerBox ? 12 : 10,
        ),
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
          mainAxisAlignment: MainAxisAlignment.start,
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
                textAlign: TextAlign.start,
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}