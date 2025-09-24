import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import 'dart:math' as math;

// Add to pubspec.yaml:
// dependencies:
//   flutter_animate: ^4.5.0
//   flutter_3d_controller: ^1.3.1

class TravelAnimationsShowcase extends StatefulWidget {
  @override
  _TravelAnimationsShowcaseState createState() => _TravelAnimationsShowcaseState();
}

class _TravelAnimationsShowcaseState extends State<TravelAnimationsShowcase> {
  late Flutter3DController controller;
  
  @override
  void initState() {
    super.initState();
    controller = Flutter3DController();
    
    // Auto-rotate the globe
    Future.delayed(Duration(milliseconds: 100), () {
      controller.playAnimation();
    });
  }
  
  @override
  void dispose() {
    // Flutter3DController doesn't have dispose method
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 3D Globe
            Container(
              height: 250,
              width: 250,
              child: Flutter3DViewer(
                controller: controller,
                src: 'https://raw.githubusercontent.com/m-r-davari/flutter_3d_controller/master/assets/earth.glb', // Earth 3D model
                progressBarColor: Colors.cyanAccent,
              ),
            ),
            
            SizedBox(height: 40),
            
            // Travel feature phrases with staggered fade-in
            Column(
              children: [
                _buildPhraseItem('Visa guidance', 0),
                _buildPhraseItem('Book flights', 1),
                _buildPhraseItem('Book hotels', 2),
                _buildPhraseItem('Create an itinerary', 3),
                _buildPhraseItem('Explore local attractions', 4),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPhraseItem(String text, int index) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w300,
          color: Colors.white.withOpacity(0.9),
          letterSpacing: 0.5,
        ),
      ),
    ).animate()
      .fadeIn(
        delay: Duration(milliseconds: 500 + (index * 200)),
        duration: Duration(milliseconds: 800),
        curve: Curves.easeOut,
      )
      .slideY(
        begin: -0.5,
        end: 0,
        delay: Duration(milliseconds: 500 + (index * 200)),
        duration: Duration(milliseconds: 800),
        curve: Curves.easeOutCubic,
      );
  }
}

// Alternative: If flutter_3d_controller doesn't work well, here's a custom 3D sphere implementation
class Custom3DGlobe extends StatefulWidget {
  @override
  _Custom3DGlobeState createState() => _Custom3DGlobeState();
}

class _Custom3DGlobeState extends State<Custom3DGlobe> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double rotationX = 0;
  double rotationY = 0;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          rotationY += details.delta.dx * 0.01;
          rotationX -= details.delta.dy * 0.01;
        });
      },
      child: Container(
        height: 250,
        width: 250,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: Globe3DPainter(
                rotationX: rotationX,
                rotationY: rotationY + _controller.value * 2 * math.pi,
              ),
            );
          },
        ),
      ),
    );
  }
}

class Globe3DPainter extends CustomPainter {
  final double rotationX;
  final double rotationY;
  
  Globe3DPainter({required this.rotationX, required this.rotationY});
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;
    
    // Create gradient for sphere illusion
    final gradient = RadialGradient(
      center: Alignment(-0.3, -0.3),
      colors: [
        Colors.cyanAccent.withOpacity(0.3),
        Colors.blue.withOpacity(0.2),
        Colors.blue.shade900.withOpacity(0.1),
      ],
      stops: [0.0, 0.7, 1.0],
    );
    
    // Draw sphere base with gradient
    final spherePaint = Paint()
      ..shader = gradient.createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, radius, spherePaint);
    
    // Draw latitude and longitude lines
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    
    // Latitude lines
    for (int lat = -60; lat <= 60; lat += 30) {
      final y = math.sin(lat * math.pi / 180) * radius;
      final circleRadius = math.cos(lat * math.pi / 180) * radius;
      
      if (circleRadius > 0) {
        // Apply 3D transformation
        final points = <Offset>[];
        for (double lon = 0; lon <= 360; lon += 10) {
          final angle = lon * math.pi / 180;
          double x = circleRadius * math.cos(angle);
          double z = circleRadius * math.sin(angle);
          
          // Apply rotation
          final rotatedX = x * math.cos(rotationY) - z * math.sin(rotationY);
          final rotatedZ = x * math.sin(rotationY) + z * math.cos(rotationY);
          
          // Apply perspective
          if (rotatedZ > -radius) {
            final projectedX = rotatedX;
            final projectedY = y * math.cos(rotationX) - rotatedZ * math.sin(rotationX);
            
            points.add(Offset(center.dx + projectedX, center.dy + projectedY));
          }
        }
        
        if (points.isNotEmpty) {
          final path = Path();
          path.addPolygon(points, false);
          canvas.drawPath(path, linePaint);
        }
      }
    }
    
    // Longitude lines
    for (int lon = 0; lon < 360; lon += 30) {
      final points = <Offset>[];
      for (int lat = -90; lat <= 90; lat += 10) {
        final latRad = lat * math.pi / 180;
        final lonRad = (lon + rotationY * 180 / math.pi) * math.pi / 180;
        
        double x = radius * math.cos(latRad) * math.cos(lonRad);
        double y = radius * math.sin(latRad);
        double z = radius * math.cos(latRad) * math.sin(lonRad);
        
        // Apply rotation around X axis
        final rotatedY = y * math.cos(rotationX) - z * math.sin(rotationX);
        final rotatedZ = y * math.sin(rotationX) + z * math.cos(rotationX);
        
        // Only draw if visible (z > 0 means front-facing)
        if (rotatedZ > -radius * 0.3) {
          points.add(Offset(center.dx + x, center.dy + rotatedY));
        }
      }
      
      if (points.length > 1) {
        final path = Path();
        path.addPolygon(points, false);
        canvas.drawPath(path, linePaint);
      }
    }
    
    // Draw glowing connection points (cities)
    final List<Map<String, double>> cities = [
      {'lat': 40.7, 'lon': -74.0},  // New York
      {'lat': 51.5, 'lon': -0.1},    // London
      {'lat': 35.6, 'lon': 139.6},   // Tokyo
      {'lat': -33.8, 'lon': 151.2},  // Sydney
      {'lat': 1.35, 'lon': 103.8},   // Singapore
    ];
    
    for (var city in cities) {
      final lat = city['lat']! * math.pi / 180;
      final lon = (city['lon']! + rotationY * 180 / math.pi) * math.pi / 180;
      
      double x = radius * math.cos(lat) * math.cos(lon);
      double y = radius * math.sin(lat);
      double z = radius * math.cos(lat) * math.sin(lon);
      
      // Apply rotation
      final rotatedY = y * math.cos(rotationX) - z * math.sin(rotationX);
      final rotatedZ = y * math.sin(rotationX) + z * math.cos(rotationX);
      
      // Only draw if visible
      if (rotatedZ > 0) {
        final cityPoint = Offset(center.dx + x, center.dy + rotatedY);
        
        // Glow effect
        final glowPaint = Paint()
          ..color = Colors.cyanAccent.withOpacity(0.3)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawCircle(cityPoint, 5, glowPaint);
        
        // City dot
        final dotPaint = Paint()
          ..color = Colors.cyanAccent
          ..style = PaintingStyle.fill;
        canvas.drawCircle(cityPoint, 2, dotPaint);
      }
    }
    
    // Draw outline
    final outlinePaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, outlinePaint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Main page that combines the globe with text
class TravelGlobeWithText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 3D Globe
            Custom3DGlobe(),
            
            SizedBox(height: 50),
            
            // Travel feature phrases
            Column(
              children: [
                _buildPhraseItem('Visa guidance', 0),
                _buildPhraseItem('Book flights', 1),
                _buildPhraseItem('Book hotels', 2),
                _buildPhraseItem('Create an itinerary', 3),
                _buildPhraseItem('Explore local attractions', 4),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPhraseItem(String text, int index) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w300,
          color: Colors.white.withOpacity(0.9),
          letterSpacing: 1.2,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.3),
              offset: Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
      ),
    ).animate()
      .fadeIn(
        delay: Duration(milliseconds: 800 + (index * 250)),
        duration: Duration(milliseconds: 1000),
        curve: Curves.easeOut,
      )
      .slideY(
        begin: -0.3,
        end: 0,
        delay: Duration(milliseconds: 800 + (index * 250)),
        duration: Duration(milliseconds: 1000),
        curve: Curves.easeOutCubic,
      );
  }
}