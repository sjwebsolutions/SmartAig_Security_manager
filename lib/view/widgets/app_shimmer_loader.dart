import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:security_manager/utils.dart';

// ============================================================================
// 1. DASHBOARD SKELETON SHIMMER SCREEN (Active until API data arrives)
// ============================================================================

/// Premium Full-Screen Skeleton Shimmer Screen for Dashboard Loading
class AppShimmerLoader extends StatelessWidget {
  const AppShimmerLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(
          Icons.menu_rounded,
          color: Color(0xFF0F172A),
          size: 26,
        ),
        title: const Text(
          'SECURITY DASHBOARD',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        scrolledUnderElevation: 0,
        backgroundColor: App.appBarBackgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: App.screenBackgroundColor,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: const SafeArea(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Profile, Name & School Shimmer Card
                _ProfileCardShimmer(),
                SizedBox(height: 12),

                // 2. Statistics 2x2 Grid Shimmer (4 Cards)
                _StatsGridShimmer(),
                SizedBox(height: 12),

                // 3. Attendance Clock Shimmer Card
                _AttendanceCardShimmer(),
                SizedBox(height: 12),

                // 4. Security Modules Shimmer Grid
                _ModulesGridShimmer(),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Profile Card Shimmer
class _ProfileCardShimmer extends StatelessWidget {
  const _ProfileCardShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const AppShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ShimmerBox(width: 55, height: 55, borderRadius: 12),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBox(width: 150, height: 16, borderRadius: 6),
                      SizedBox(height: 6),
                      ShimmerBox(width: 105, height: 12, borderRadius: 4),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Divider(color: Color(0xFFE2E8F0), height: 1),
            SizedBox(height: 12),
            Row(
              children: [
                ShimmerCircle(radius: 8),
                SizedBox(width: 8),
                Expanded(
                  child: ShimmerBox(
                    width: double.infinity,
                    height: 12,
                    borderRadius: 4,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                ShimmerCircle(radius: 7),
                SizedBox(width: 8),
                ShimmerBox(width: 120, height: 11, borderRadius: 4),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer 2x2 Statistics Grid
class _StatsGridShimmer extends StatelessWidget {
  const _StatsGridShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: AppShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                ShimmerBox(width: 28, height: 28, borderRadius: 10),
                SizedBox(width: 10),
                ShimmerBox(width: 140, height: 14, borderRadius: 4),
              ],
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 3.2,
              children: List.generate(
                4,
                (index) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ShimmerBox(width: 22, height: 22, borderRadius: 6),
                      SizedBox(width: 8),
                      Expanded(
                        child: ShimmerBox(
                          width: double.infinity,
                          height: 11,
                          borderRadius: 4,
                        ),
                      ),
                      SizedBox(width: 6),
                      ShimmerBox(width: 24, height: 16, borderRadius: 6),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer Attendance Clock Card
class _AttendanceCardShimmer extends StatelessWidget {
  const _AttendanceCardShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const AppShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ShimmerBox(width: 28, height: 28, borderRadius: 10),
                SizedBox(width: 10),
                ShimmerBox(width: 110, height: 14, borderRadius: 4),
                Spacer(),
                ShimmerBox(width: 75, height: 22, borderRadius: 6),
              ],
            ),
            SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: ShimmerBox(
                    width: double.infinity,
                    height: 44,
                    borderRadius: 10,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ShimmerBox(
                    width: double.infinity,
                    height: 44,
                    borderRadius: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer Security Modules Section
class _ModulesGridShimmer extends StatelessWidget {
  const _ModulesGridShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: AppShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Row(
              children: [
                ShimmerBox(width: 28, height: 28, borderRadius: 10),
                SizedBox(width: 10),
                ShimmerBox(width: 120, height: 14, borderRadius: 4),
              ],
            ),
            const SizedBox(height: 14),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
              childAspectRatio: 1.35,
              children: List.generate(
                2,
                (index) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ShimmerCircle(radius: 14),
                      SizedBox(height: 6),
                      ShimmerBox(width: 50, height: 10, borderRadius: 4),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 2. REUSABLE LIST SKELETON SHIMMER (For GatePass & Visitor lists)
// ============================================================================

class ShimmerListLoading extends StatelessWidget {
  final int itemCount;

  const ShimmerListLoading({
    super.key,
    this.itemCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const AppShimmer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerBox(width: 85, height: 15, borderRadius: 5),
                    ShimmerBox(width: 75, height: 22, borderRadius: 12),
                  ],
                ),
                SizedBox(height: 12),
                ShimmerBox(width: 170, height: 20, borderRadius: 6),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerBox(width: 115, height: 13, borderRadius: 5),
                    ShimmerBox(width: 95, height: 13, borderRadius: 5),
                  ],
                ),
                Divider(color: Color(0xFFE2E8F0), height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerBox(width: 105, height: 13, borderRadius: 5),
                    ShimmerBox(width: 85, height: 13, borderRadius: 5),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ============================================================================
// 3. CORE CUSTOM FROSTED WHITE SHIMMER WIDGETS
// ============================================================================

/// Shimmer Box Placeholder with customizable dimensions and smooth corners
class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Color? color;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 6,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color ?? const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Shimmer Circle Placeholder for avatars, badges, and icon buttons
class ShimmerCircle extends StatelessWidget {
  final double radius;
  final Color? color;

  const ShimmerCircle({
    super.key,
    required this.radius,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color ?? const Color(0xFFE2E8F0),
      ),
    );
  }
}

/// High-Performance Animated Shimmer Shader Wrapper
class AppShimmer extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;
  final Duration duration;

  const AppShimmer({
    super.key,
    required this.child,
    this.baseColor = const Color(0xFFE2E8F0), // Clean Slate 200 Base
    this.highlightColor = const Color(0xFFFFFFFF), // Pure White Sheen
    this.duration = const Duration(milliseconds: 1200),
  });

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final position = _shimmerController.value;
            return LinearGradient(
              begin: const Alignment(-1.0, -0.3),
              end: const Alignment(1.0, 0.3),
              stops: const [0.0, 0.35, 0.50, 0.65, 1.0],
              colors: [
                widget.baseColor,
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
                widget.baseColor,
              ],
              transform: _SlidingGradientTransform(slidePercent: position),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;

  const _SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(
      bounds.width * (slidePercent * 2.4 - 1.2),
      0.0,
      0.0,
    );
  }
}

// ============================================================================
// 4. CIRCULAR SHIMMER LOADER WIDGET (For Standalone / Dialog usage)
// ============================================================================

class AppCircularLoader extends StatefulWidget {
  final double size;
  final double strokeWidth;
  final bool showPercentage;
  final Widget? centerWidget;
  final List<Color>? gradientColors;

  const AppCircularLoader({
    super.key,
    this.size = 200,
    this.strokeWidth = 20.0,
    this.showPercentage = true,
    this.centerWidget,
    this.gradientColors,
  });

  @override
  State<AppCircularLoader> createState() => _AppCircularLoaderState();
}

class _AppCircularLoaderState extends State<AppCircularLoader>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    _progressAnimation = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOutCubic,
    );

    _progressController.repeat();

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _shimmerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _shimmerController,
        curve: Curves.linear,
      ),
    );

    _shimmerController.repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _progressController.dispose();
    _shimmerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _progressAnimation,
        _shimmerAnimation,
        _pulseAnimation,
      ]),
      builder: (context, child) {
        final progress = _progressAnimation.value.clamp(0.0, 1.0);
        final shimmerValue = _shimmerAnimation.value;
        final pulseValue = _pulseAnimation.value;
        final percentage = (progress * 100).toInt();

        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: pulseValue,
                child: Container(
                  width: widget.size * 0.9,
                  height: widget.size * 0.9,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.tealAccent.withValues(alpha: 0.12),
                        blurRadius: 35,
                        spreadRadius: 8,
                      ),
                      BoxShadow(
                        color: const Color(0xFF00E5FF).withValues(alpha: 0.08),
                        blurRadius: 50,
                        spreadRadius: 15,
                      ),
                    ],
                  ),
                ),
              ),
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: CircularShimmerPainter(
                  progress: progress,
                  shimmerProgress: shimmerValue,
                  strokeWidth: widget.strokeWidth,
                  gradientColors: widget.gradientColors,
                ),
              ),
              Center(
                child: widget.centerWidget ??
                    (widget.showPercentage
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AppShimmer(
                                highlightColor: Colors.white,
                                baseColor: Colors.tealAccent.shade100,
                                child: Text(
                                  '$percentage%',
                                  style: TextStyle(
                                    fontSize: widget.size * 0.22,
                                    fontWeight: FontWeight.w200,
                                    color: Colors.white,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'PROCESSING',
                                style: TextStyle(
                                  fontSize: widget.size * 0.05,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.tealAccent.withValues(alpha: 0.7),
                                  letterSpacing: 2.0,
                                ),
                              ),
                            ],
                          )
                        : const SizedBox.shrink()),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CircularShimmerPainter extends CustomPainter {
  final double progress;
  final double shimmerProgress;
  final double strokeWidth;
  final List<Color>? gradientColors;

  CircularShimmerPainter({
    required this.progress,
    required this.shimmerProgress,
    this.strokeWidth = 20.0,
    this.gradientColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    final innerTrackBorderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, radius - strokeWidth / 2, innerTrackBorderPaint);
    canvas.drawCircle(center, radius + strokeWidth / 2, innerTrackBorderPaint);

    if (progress <= 0.001) return;

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    final colors = gradientColors ??
        const [
          Color(0xFF5EE7FC),
          Color(0xFF2879FE),
          Color(0xFF8A2BE2),
          Color(0xFFD81B98),
          Color(0xFFFF007F),
          Color(0xFF5EE7FC),
        ];

    final gradient = SweepGradient(
      startAngle: 0.0,
      endAngle: 2 * math.pi,
      colors: colors,
      stops: const [0.0, 0.25, 0.50, 0.75, 0.90, 1.0],
      transform: const GradientRotation(-math.pi / 2),
    );

    final glowPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 4.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    canvas.drawArc(rect, startAngle, sweepAngle, false, glowPaint);

    final progressPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, sweepAngle, false, progressPaint);

    final shimmerAngle = (shimmerProgress * 2 * math.pi);
    final shimmerGradient = SweepGradient(
      startAngle: 0.0,
      endAngle: 2 * math.pi,
      colors: [
        Colors.transparent,
        Colors.white.withValues(alpha: 0.0),
        Colors.white.withValues(alpha: 0.8),
        Colors.white,
        Colors.white.withValues(alpha: 0.8),
        Colors.white.withValues(alpha: 0.0),
        Colors.transparent,
      ],
      stops: const [0.0, 0.40, 0.47, 0.50, 0.53, 0.60, 1.0],
      transform: GradientRotation(shimmerAngle - math.pi),
    );

    final shimmerPaint = Paint()
      ..shader = shimmerGradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 0.75
      ..strokeCap = StrokeCap.round
      ..blendMode = BlendMode.screen;

    canvas.drawArc(rect, startAngle, sweepAngle, false, shimmerPaint);

    const totalTicks = 160;
    final innerRadius = radius - strokeWidth / 2 + 2;
    final outerRadius = radius + strokeWidth / 2 - 2;

    for (int i = 0; i < totalTicks; i++) {
      final tickAngle = startAngle + (2 * math.pi * (i / totalTicks));
      final tickProgress = i / totalTicks;

      if (tickProgress <= progress) {
        final normalizedTick = (tickAngle + math.pi / 2) % (2 * math.pi);
        final normalizedShimmer = shimmerAngle % (2 * math.pi);
        final angleDiff = (normalizedTick - normalizedShimmer).abs();
        final shortestDiff = math.min(angleDiff, 2 * math.pi - angleDiff);

        double tickAlpha = 0.25;
        if (shortestDiff < 0.4) {
          final intensity = 1.0 - (shortestDiff / 0.4);
          tickAlpha = 0.25 + (0.65 * intensity);
        }

        final tickPaint = Paint()
          ..color = Colors.white.withValues(alpha: tickAlpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = tickAlpha > 0.4 ? 1.4 : 0.8;

        final cosA = math.cos(tickAngle);
        final sinA = math.sin(tickAngle);

        final p1 = Offset(center.dx + innerRadius * cosA, center.dy + innerRadius * sinA);
        final p2 = Offset(center.dx + outerRadius * cosA, center.dy + outerRadius * sinA);

        canvas.drawLine(p1, p2, tickPaint);
      }
    }

    final headAngle = startAngle + sweepAngle;
    final headCenter = Offset(
      center.dx + radius * math.cos(headAngle),
      center.dy + radius * math.sin(headAngle),
    );

    final headGlowPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawCircle(headCenter, strokeWidth * 0.35, headGlowPaint);

    final headDotPaint = Paint()..color = Colors.white;
    canvas.drawCircle(headCenter, strokeWidth * 0.2, headDotPaint);
  }

  @override
  bool shouldRepaint(covariant CircularShimmerPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.shimmerProgress != shimmerProgress;
  }
}
