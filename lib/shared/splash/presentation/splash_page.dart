import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

/// Cek sesi singkat lalu arahkan ke HOME.
/// Login opsional (via tab Profil / route /login) - pencarian publik
/// tidak butuh auth.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.go('/');
    });
  }

  @override
  Widget build(BuildContext context) {
    return const FScaffold(
      childPad: true,
      child: Center(child: FCircularProgress()),
    );
  }
}
