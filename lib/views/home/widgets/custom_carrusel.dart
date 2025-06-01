import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SlideCarousel extends StatefulWidget {
  final List<String> imageUrls;
  final double height;

  const SlideCarousel({
    Key? key,
    required this.imageUrls,
    this.height = 400,
  }) : super(key: key);

  @override
  State<SlideCarousel> createState() => _SlideCarouselState();
}

class _SlideCarouselState extends State<SlideCarousel> {
  late final PageController _controller;
  late Timer _timer;

  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.85);

    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (_controller.hasClients) {
        _currentPage++;
        _controller.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: PageView.builder(
        controller: _controller,
        itemBuilder: (context, index) {
          final image = widget.imageUrls[index % widget.imageUrls.length];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                image,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          );
        },
      ),
    );
  }
}

class FadingImageCarousel extends StatefulWidget {
  final List<String> imagePaths;
  final bool useNetwork;

  const FadingImageCarousel({
    Key? key,
    required this.imagePaths,
    this.useNetwork = false,
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
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    _controller.forward();
    _startImageLoop();
  }

  void _startImageLoop() async {
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
    return FadeTransition(
      opacity: _fadeAnimation,
      child: widget.useNetwork
          ? Image.network(
              widget.imagePaths[_currentImageIndex],
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
            )
          : Image.asset(
              widget.imagePaths[_currentImageIndex],
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
    );
  }
}

