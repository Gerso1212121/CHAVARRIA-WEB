import 'dart:async';
import 'package:flutter/material.dart';

class SlideCarrusell extends StatefulWidget {
  const SlideCarrusell({super.key});

  @override
  State<SlideCarrusell> createState() => _SlideCarrusellState();
}

class _SlideCarrusellState extends State<SlideCarrusell> {
  late final PageController _controller;
  late final Timer _timer;

  final List<String> _images = [
    'https://cdn.pixabay.com/photo/2020/10/18/09/16/bedroom-5664221_1280.jpg',
    'https://cdn.pixabay.com/photo/2016/11/18/17/20/living-room-1835923_1280.jpg',
    'https://cdn.pixabay.com/photo/2020/05/24/09/52/sofa-5213406_1280.jpg',
  ];

  static const int _initialPage = 1000;
  int _currentPage = _initialPage;

  @override
  void initState() {
    super.initState();
    _controller = PageController(
      viewportFraction: 0.85,
      initialPage: _initialPage,
    );

    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_controller.hasClients) {
        _currentPage++;
        _controller.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 2000),
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
    final double height = MediaQuery.of(context).size.height * 0.4;

    return SizedBox(
      height: 400,
      child: PageView.builder(
        controller: _controller,
        itemBuilder: (context, index) {
          final image = _images[index % _images.length];
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
