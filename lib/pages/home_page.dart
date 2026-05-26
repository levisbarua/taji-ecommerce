import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../utils/constants.dart';
import '../services/update_service.dart';
import 'auth_page.dart';
import 'swipe_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late final AnimationController _shineController;
  late final AnimationController _glowController;
  late final AnimationController _floatController;
  late final AnimationController _logoController;
  
  late final Animation<double> _shineOffset;
  late final Animation<double> _glowRadius;
  late final Animation<double> _floatOffset;
  
  final String _fullTitle = 'TAJI THE CREATOR';

  Map<String, dynamic>? _updateInfo;

  @override
  void initState() {
    super.initState();
    
    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _readVersionAndCheck();

    _shineOffset = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _shineController, curve: Curves.easeInOut),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _glowRadius = Tween<double>(begin: 2.0, end: 12.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _floatOffset = Tween<double>(begin: -4.0, end: 4.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  Future<void> _readVersionAndCheck() async {
    String version = '0.1.0';
    try {
      final info = await PackageInfo.fromPlatform();
      version = info.version;
    } catch (_) {}
    _checkForUpdate(version);
  }

  Future<void> _checkForUpdate(String currentVersion) async {
    final update = await UpdateService.checkForUpdate(currentVersion);
    if (!mounted) return;
    setState(() {
      _updateInfo = update;
    });
    if (update != null) {
      _showUpdateDialog(update);
    }
  }

  void _showUpdateDialog(Map<String, dynamic> update) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A202C),
        title: Row(
          children: [
            const Icon(Icons.system_update, color: pureYellow, size: 24),
            const SizedBox(width: 8),
            const Text('Update Available', style: TextStyle(color: pureWhite)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Version ', style: TextStyle(color: tajiTextMutedDark)),
                Text('v${update['version']}', style: const TextStyle(color: pureYellow, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Text(update['notes'] as String, style: const TextStyle(color: pureWhite, fontSize: 13)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Later', style: TextStyle(color: tajiTextMutedDark)),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.download, size: 18),
            label: const Text('Update Now'),
            onPressed: () {
              Navigator.pop(ctx);
              _downloadUpdate(update['url'] as String);
            },
            style: ElevatedButton.styleFrom(backgroundColor: pureYellow, foregroundColor: pureBlack),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadUpdate(String url) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(children: [CircularProgressIndicator(strokeWidth: 2, color: pureYellow), SizedBox(width: 16), Text('Downloading update...')]),
        duration: Duration(minutes: 2),
        backgroundColor: Color(0xFF1A202C),
      ),
    );
    await UpdateService.downloadAndInstall(url, context);
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  @override
  void dispose() {
    _shineController.dispose();
    _glowController.dispose();
    _floatController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 30),

            if (_updateInfo != null)
              GestureDetector(
                onTap: () => _showUpdateDialog(_updateInfo!),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: pureYellow.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: pureYellow.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.system_update, color: pureYellow, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Update v${_updateInfo!['version']} available',
                          style: const TextStyle(color: pureWhite, fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: pureYellow, size: 14),
                    ],
                  ),
                ),
              ),

            Center(
              child: AnimatedBuilder(
                animation: Listenable.merge([_shineController, _glowController, _floatController]),
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _floatOffset.value),
                    child: ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            pureYellow,
                            pureWhite.withValues(alpha: 0.9),
                            pureYellow,
                          ],
                          stops: [
                            _shineOffset.value - 0.2,
                            _shineOffset.value,
                            _shineOffset.value + 0.2,
                          ],
                        ).createShader(bounds);
                      },
                      child: Text(
                        _fullTitle,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Theme.of(context).colorScheme.onSurface,
                          letterSpacing: 2.0, 
                          fontFamily: 'monospace',
                          shadows: [
                            Shadow(
                              color: pureYellow.withValues(alpha: 0.6), 
                              blurRadius: _glowRadius.value,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 40),

                Expanded(
                  flex: 6,
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(
                          'assets/images/bg_layer.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                        ),
                        
                        Align(
                          alignment: const Alignment(0, -0.85),
                          child: Container(
                            width: double.infinity,
                            height: 100,
                            color: Theme.of(context).scaffoldBackgroundColor,
                          ),
                        ),

                        Align(
                          alignment: const Alignment(0, -0.77), 
                          child: Text(
                            'COVER ART - MERCH - BRAND DESIGN',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: pureWhite,
                              letterSpacing: 1.2,
                              shadows: [
                                Shadow(
                                  color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.5),
                                  offset: const Offset(0, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),

                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Theme.of(context).scaffoldBackgroundColor,
                                  Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.0),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        Align(
                          alignment: const Alignment(0.85, 0.88), 
                          child: Container(
                            width: 60, 
                            height: 60,
                            decoration: BoxDecoration(
                              color: pureBlack.withValues(alpha: 0.95),
                              shape: BoxShape.circle,
                              boxShadow: const [
                                BoxShadow(
                                  color: pureBlack,
                                  blurRadius: 20,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                          ),
                        ),

                        Center(
                          child: AnimatedBuilder(
                            animation: _logoController,
                            builder: (context, child) {
                              return Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()
                                  ..setEntry(3, 2, 0.001)
                                  ..rotateY(_logoController.value * 2 * 3.14159),
                                child: child,
                              );
                            },
                            child: ClipRect(
                              child: Align(
                                alignment: Alignment.topCenter,
                                heightFactor: 0.88,
                                child: ColorFiltered(
                                  colorFilter: const ColorFilter.matrix([
                                    1.3, 0, 0, 0, 10,
                                    0, 1.3, 0, 0, 10,
                                    0, 0, 1.3, 0, 10,
                                    -4, -4, -4, 11, 0,
                                  ]),
                                  child: Image.asset(
                                    'assets/images/person_layer.png',
                                    height: 500,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(Icons.person, color: tajiTextLight.withValues(alpha: 0.12), size: 200);
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 120,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.0),
                                  Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.4),
                                  Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.95),
                                ],
                                stops: const [0.0, 0.4, 1.0],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  Text(
                    'Elevating Digital Art\n& Graphic Design',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                      height: 1.1,
                      letterSpacing: -1.0,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Discover a new era of artistic expression through\ncurated concepts and innovative culture-driven design.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.85),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(flex: 1),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: SwipeButton(
                onSwipe: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => const AuthPage(),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
