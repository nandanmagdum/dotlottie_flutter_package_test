import 'package:dotlottie_flutter/dotlottie_flutter.dart';
import 'package:flutter/material.dart';

void _trace(String msg) {
  debugPrint('[dotlottie-trace] $msg');
}

void main() {
  runApp(const MyApp());
}

const _animations = [
  (
    url:
        'https://lottie.host/37cfaf9d-6805-4d77-a4d1-a44c2c66e340/e41cghHS0p.lottie',
    label: 'Animation 1',
  ),
  (
    url:
        'https://lottie.host/6b7b97ab-b440-4bc6-844a-1c863c0fe118/Ofg3beI37F.lottie',
    label: 'Animation 2',
  ),
  (
    url:
        'https://lottie.host/749236ba-351e-49f6-9ed0-b88d8c5ce023/6nY3dSYtwx.lottie',
    label: 'Animation 3',
  ),
  (
    url:
        'https://lottie.host/76229bd4-4e2c-4718-9737-fa8b8bedae29/qqaRzSPO8n.lottie',
    label: 'Animation 4',
  ),
  (
    url:
        'https://lottie.host/a1641002-1aee-4506-89e2-a18210bfc9c7/PSdkPPlzA5.lottie',
    label: 'Animation 5',
  ),
];

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'dotlottie',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const CarouselPage(),
    );
  }
}

class CarouselPage extends StatefulWidget {
  const CarouselPage({super.key});

  @override
  State<CarouselPage> createState() => _CarouselPageState();
}

class _CarouselPageState extends State<CarouselPage> {
  late PageController _pageController;
  late List<GlobalKey<_AnimationPageState>> _pageKeys;
  int _currentPage = 0;
  int _carouselRevision = 0;

  @override
  void initState() {
    super.initState();
    _trace('Carousel.initState hash=${identityHashCode(this)}');
    _pageController = PageController();
    _pageKeys = List.generate(
      _animations.length,
      (_) => GlobalKey<_AnimationPageState>(),
    );
  }

  void _hardRebuildCarousel() {
    _trace(
      'HardRebuild.CTA tapped revision=$_carouselRevision -> ${_carouselRevision + 1}',
    );
    final restorePage = _currentPage;
    _pageController.dispose();
    setState(() {
      _carouselRevision++;
      _pageController = PageController(initialPage: restorePage);
      _pageKeys = List.generate(
        _animations.length,
        (_) => GlobalKey<_AnimationPageState>(),
      );
    });
  }

  @override
  void dispose() {
    _trace('Carousel.DISPOSE hash=${identityHashCode(this)} <-- TEARDOWN');
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    _pageKeys[_currentPage].currentState?.pause();
    _pageKeys[index].currentState?.play();
    setState(() => _currentPage = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('dotlottie')),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              key: ValueKey<int>(_carouselRevision),
              controller: _pageController,
              itemCount: _animations.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                final anim = _animations[index];
                return _AnimationPage(
                  key: _pageKeys[index],
                  index: index,
                  url: anim.url,
                  label: anim.label,
                );
              },
            ),
          ),
          _PageIndicator(count: _animations.length, current: _currentPage),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _hardRebuildCarousel,
                icon: const Icon(Icons.autorenew),
                label: const Text('Hard rebuild'),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'STR:\n1. Swipe all lottie from 1 to 5, press this CTA, and try to swipe again.\nCan crash in 1-3 attempts.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _AnimationPage extends StatefulWidget {
  const _AnimationPage({
    super.key,
    required this.index,
    required this.url,
    required this.label,
  });

  final int index;
  final String url;
  final String label;

  @override
  State<_AnimationPage> createState() => _AnimationPageState();
}

class _AnimationPageState extends State<_AnimationPage>
    with AutomaticKeepAliveClientMixin {
  DotLottieViewController? _controller;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _trace(
      'AnimationPage.initState index=${widget.index} url=${widget.url} hash=${identityHashCode(this)}',
    );
  }

  @override
  void dispose() {
    _trace(
      'AnimationPage.DISPOSE index=${widget.index} hash=${identityHashCode(this)}',
    );
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }

  void play() => _controller?.play();
  void pause() => _controller?.pause();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: DotLottieView(
              sourceType: 'url',
              source: widget.url,
              autoplay: true,
              loop: true,
              fit: BoxFit.contain,
              onViewCreated: (controller) {
                _trace('DotLottieView.onViewCreated index=${widget.index}');
                _controller = controller;
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Text(
            widget.label,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: i == current ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: i == current ? primary : Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
