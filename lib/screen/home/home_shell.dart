import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';
import '../../model/provider_model.dart';
import '../../widget/app_toast.dart';
import '../optimize/optimize_screen.dart';
import '../providers/providers_screen.dart';
import '../settings/settings_screen.dart';

/// Main screen with the bottom navigation bar.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => HomeShellState();
}

class HomeShellState extends State<HomeShell> {
  final _optimizeKey = GlobalKey<OptimizeScreenState>();
  int _index = 0;
  DateTime? _lastBack;

  /// Opens the optimizer with [provider] selected.
  void optimizeWith(Provider provider) {
    _select(0);
    _optimizeKey.currentState?.selectProvider(provider);
  }

  void _select(int index) {
    FocusScope.of(context).unfocus();
    if (index != _index) setState(() => _index = index);
  }

  void _onBack() {
    if (_index != 0) {
      _select(0);
      return;
    }
    final now = DateTime.now();
    if (_lastBack == null ||
        now.difference(_lastBack!) > const Duration(seconds: 2)) {
      _lastBack = now;
      AppToast.info(context, AppLocalizations.of(context).pressAgainToExit);
    } else {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onBack();
      },
      child: Scaffold(
        body: _TabStack(
          index: _index,
          children: [
            OptimizeScreen(key: _optimizeKey),
            const ProvidersScreen(),
            const SettingsScreen(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (index) {
            HapticFeedback.selectionClick();
            _select(index);
          },
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.calculate_outlined),
              selectedIcon: const Icon(Icons.calculate_rounded),
              label: l10n.tabOptimize,
            ),
            NavigationDestination(
              icon: const Icon(Icons.account_balance_wallet_outlined),
              selectedIcon: const Icon(Icons.account_balance_wallet_rounded),
              label: l10n.operators,
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: const Icon(Icons.settings_rounded),
              label: l10n.settings,
            ),
          ],
        ),
      ),
    );
  }
}

/// Keeps every tab alive and fades through when the tab changes: the old tab
/// fades out quickly, then the new one fades and settles in.
class _TabStack extends StatefulWidget {
  const _TabStack({required this.index, required this.children});

  final int index;
  final List<Widget> children;

  @override
  State<_TabStack> createState() => _TabStackState();
}

class _TabStackState extends State<_TabStack>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
    value: 1,
  )..addStatusListener(_onStatus);
  late final Animation<double> _fadeOut = ReverseAnimation(
    CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.35, curve: Curves.easeOut),
    ),
  );
  late final Animation<double> _fadeIn = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.35, 1, curve: Curves.easeOutCubic),
  );
  late final Animation<double> _scaleIn = Tween(
    begin: 0.985,
    end: 1.0,
  ).animate(_fadeIn);

  late int _current = widget.index;
  int? _previous;

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && _previous != null) {
      setState(() => _previous = null);
    }
  }

  @override
  void didUpdateWidget(covariant _TabStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.index == _current) return;
    _previous = _current;
    _current = widget.index;
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [for (var i = 0; i < widget.children.length; i++) _tab(i)],
  );

  // The wrapper chain stays the same for every state, so each tab keeps its
  // state (scroll position, inputs, results).
  Widget _tab(int i) {
    final active = i == _current;
    final leaving = i == _previous;
    final visible = active || leaving;
    return Offstage(
      offstage: !visible,
      child: TickerMode(
        enabled: visible,
        child: IgnorePointer(
          ignoring: !active,
          child: ExcludeSemantics(
            excluding: !active,
            child: FadeTransition(
              opacity: active
                  ? _fadeIn
                  : (leaving ? _fadeOut : kAlwaysDismissedAnimation),
              child: ScaleTransition(
                scale: active ? _scaleIn : kAlwaysCompleteAnimation,
                child: widget.children[i],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
