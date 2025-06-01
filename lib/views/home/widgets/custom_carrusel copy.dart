import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class FadingImageCarousel extends StatefulWidget {
  final List<String> imagePaths;
  final bool useNetwork;
  final double? height;

  const FadingImageCarousel({
    Key? key,
    required this.imagePaths,
    this.useNetwork = false,
    this.height,
  }) : super(key: key);

  @override
  State<FadingImageCarousel> createState() => _FadingImageCarouselState();
}

class _FadingImageCarouselState extends State<FadingImageCarousel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;

  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();
    _startImageLoop();
  }

  Future<void> _startImageLoop() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 4));
      if (!mounted) break;

      await _controller.reverse(); // fade out
      setState(() {
        _currentImageIndex =
            (_currentImageIndex + 1) % widget.imagePaths.length;
      });
      await _controller.forward(); // fade in
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double height = widget.height ?? MediaQuery.of(context).size.height * 0.25;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: widget.useNetwork
            ? Image.network(
                widget.imagePaths[_currentImageIndex],
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.error),
              )
            : Image.asset(
                widget.imagePaths[_currentImageIndex],
                fit: BoxFit.cover,
              ),
      ),
    );
  }
}
