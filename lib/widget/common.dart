import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import '../util/icon_util.dart';
import '../util/money.dart';

// -----------------------------------------------------------------------------
// Interaction
// -----------------------------------------------------------------------------

/// Shrinks its child slightly while pressed (fingers, mouse, stylus).
class PressScale extends StatefulWidget {
  const PressScale({
    super.key,
    required this.child,
    this.enabled = true,
    this.scale = 0.97,
  });

  final Widget child;
  final bool enabled;
  final double scale;

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _down = false;

  void _set(bool value) {
    if (_down != value && mounted) setState(() => _down = value);
  }

  @override
  Widget build(BuildContext context) => Listener(
    onPointerDown: widget.enabled ? (_) => _set(true) : null,
    onPointerUp: (_) => _set(false),
    onPointerCancel: (_) => _set(false),
    child: AnimatedScale(
      scale: _down ? widget.scale : 1,
      duration: _down ? Motion.fast : Motion.medium,
      curve: _down ? Curves.easeOut : Curves.easeOutBack,
      child: widget.child,
    ),
  );
}

/// Tappable surface with consistent feedback: press scale, calm ripple,
/// hover tint and click cursor.
class Pressable extends StatelessWidget {
  const Pressable({
    super.key,
    required this.child,
    required this.onTap,
    this.onLongPress,
    this.color,
    this.borderRadius = Space.radiusLg,
    this.haptic = false,
    this.scale = 0.98,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? color;
  final double borderRadius;
  final bool haptic;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    final enabled = onTap != null || onLongPress != null;
    final surface = Material(
      color: color ?? Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: radius),
      clipBehavior: Clip.antiAlias,
      child: enabled
          ? InkWell(
              onTap: onTap == null
                  ? null
                  : () {
                      if (haptic) HapticFeedback.selectionClick();
                      onTap!();
                    },
              onLongPress: onLongPress,
              child: child,
            )
          : child,
    );
    return enabled ? PressScale(scale: scale, child: surface) : surface;
  }
}

/// Visual weight of an [AppButton].
enum AppButtonStyle { filled, tonal, outlined, text }

/// Full-width button with press animation and built-in loading state.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.style = AppButtonStyle.filled,
    this.expand = true,
    this.destructive = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final AppButtonStyle style;
  final bool expand;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final foreground = switch (style) {
      AppButtonStyle.filled => destructive ? colors.onError : colors.onPrimary,
      AppButtonStyle.tonal => colors.onPrimaryContainer,
      _ => destructive ? colors.error : colors.primary,
    };
    final content = AnimatedSwitcher(
      duration: Motion.medium,
      switchInCurve: Motion.curve,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween(begin: 0.9, end: 1.0).animate(animation),
          child: child,
        ),
      ),
      child: loading
          ? SizedBox.square(
              key: const ValueKey('loading'),
              dimension: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color: foreground,
              ),
            )
          : Row(
              key: const ValueKey('label'),
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20),
                  const SizedBox(width: 10),
                ],
                Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
              ],
            ),
    );
    final action = loading || onPressed == null
        ? null
        : () {
            HapticFeedback.lightImpact();
            onPressed!();
          };
    final button = switch (style) {
      AppButtonStyle.filled => FilledButton(
        onPressed: action,
        style: destructive
            ? FilledButton.styleFrom(
                backgroundColor: colors.error,
                foregroundColor: colors.onError,
              )
            : null,
        child: content,
      ),
      AppButtonStyle.tonal => FilledButton.tonal(
        onPressed: action,
        child: content,
      ),
      AppButtonStyle.outlined => OutlinedButton(
        onPressed: action,
        style: destructive
            ? OutlinedButton.styleFrom(
                foregroundColor: colors.error,
                side: BorderSide(color: colors.error),
              )
            : null,
        child: content,
      ),
      AppButtonStyle.text => TextButton(
        onPressed: action,
        style: destructive
            ? TextButton.styleFrom(foregroundColor: colors.error)
            : null,
        child: content,
      ),
    };
    final pressable = PressScale(enabled: action != null, child: button);
    return expand
        ? SizedBox(width: double.infinity, child: pressable)
        : pressable;
  }
}

// -----------------------------------------------------------------------------
// Layout
// -----------------------------------------------------------------------------

/// Flat rounded surface grouping related content; tappable when [onTap] is set.
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(Space.lg),
    this.onTap,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) => Pressable(
    onTap: onTap,
    color: color ?? context.colors.surfaceContainerLow,
    child: Padding(padding: padding, child: child),
  );
}

/// Small header above a group of content.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(Space.xs, 0, Space.xs, Space.sm),
    child: Row(
      children: [
        Expanded(
          child: Text(
            text,
            style: context.text.labelMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ),
        ?trailing,
      ],
    ),
  );
}

/// Row of a grouped list: icon, title, optional subtitle and a chevron.
class MenuRow extends StatelessWidget {
  const MenuRow({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.trailing,
    this.color,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  /// Icon and title color (e.g. for destructive actions).
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Pressable(
      onTap: onTap,
      borderRadius: 0,
      scale: 0.99,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Space.lg, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: color ?? colors.onSurfaceVariant),
            const SizedBox(width: Space.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.text.titleSmall?.copyWith(color: color),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    AnimatedSwitcher(
                      duration: Motion.medium,
                      layoutBuilder: (current, previous) => Stack(
                        alignment: Alignment.centerLeft,
                        children: [...previous, ?current],
                      ),
                      child: Text(
                        subtitle!,
                        key: ValueKey(subtitle),
                        style: context.text.bodySmall,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Space.gapSm,
            trailing ??
                Icon(Icons.chevron_right_rounded, color: colors.outline),
          ],
        ),
      ),
    );
  }
}

/// Rounded group of [MenuRow]s separated by dividers.
class MenuGroup extends StatelessWidget {
  const MenuGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: context.colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(Space.radiusLg),
    ),
    clipBehavior: Clip.antiAlias,
    child: Column(
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const Divider(indent: 54),
          children[i],
        ],
      ],
    ),
  );
}

/// Icon + message + optional action.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: Space.xl,
      vertical: Space.xxl,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 40, color: context.colors.onSurfaceVariant),
        Space.gapLg,
        Text(
          title,
          style: context.text.titleMedium,
          textAlign: TextAlign.center,
        ),
        if (message != null) ...[
          Space.gapSm,
          Text(
            message!,
            style: context.text.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        if (action != null) ...[Space.gapLg, action!],
      ],
    ),
  );
}

// -----------------------------------------------------------------------------
// Motion
// -----------------------------------------------------------------------------

/// Fades and slides its child in once, after [delay] plus a stagger of
/// [index] steps (for lists).
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.index = 0,
    this.delay = Duration.zero,
    this.offset = 12,
  });

  final Widget child;
  final int index;
  final Duration delay;
  final double offset;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  // The wait is part of the animation: while tickers are paused (under the
  // launch splash), the whole sequence waits, and the stagger is kept.
  late final Duration _wait =
      widget.delay + Duration(milliseconds: 45 * widget.index.clamp(0, 8));
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _wait + Motion.slow,
  )..forward();
  late final Animation<double> _curve = CurvedAnimation(
    parent: _controller,
    curve: Interval(
      _wait.inMicroseconds / (_wait + Motion.slow).inMicroseconds,
      1,
      curve: Motion.curve,
    ),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _curve,
    child: widget.child,
    builder: (context, child) => Opacity(
      opacity: _curve.value,
      child: Transform.translate(
        offset: Offset(0, widget.offset * (1 - _curve.value)),
        child: child,
      ),
    ),
  );
}

/// Amount that counts up to [value] when it appears or changes.
class AnimatedMoney extends StatelessWidget {
  const AnimatedMoney(this.value, {super.key, this.style});

  final double value;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: value),
    duration: const Duration(milliseconds: 700),
    curve: Curves.easeOutCubic,
    builder: (context, current, _) => Text(
      // Whole numbers while counting, exact value at the end.
      context.money(current == value ? value : current.roundToDouble()),
      style: style?.copyWith(fontFeatures: AppTheme.tabular),
    ),
  );
}

/// Pulsing placeholder shown while content loads.
class Skeleton extends StatefulWidget {
  const Skeleton({super.key, this.width, this.height = 16, this.radius = 8});

  final double? width;
  final double height;
  final double radius;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 850),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = context.colors.surfaceContainerHigh;
    final light = context.colors.surfaceContainerLow;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Color.lerp(
            base,
            light,
            Curves.easeInOut.transform(_controller.value),
          ),
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}

/// Skeleton of a list of cards.
class SkeletonList extends StatelessWidget {
  const SkeletonList({super.key, this.count = 3, this.padding});

  final int count;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) => Padding(
    padding: padding ?? const EdgeInsets.all(Space.page),
    child: Column(
      children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0) Space.gapMd,
          const SectionCard(
            child: Row(
              children: [
                Skeleton(width: 44, height: 44, radius: 12),
                Space.gapMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Skeleton(width: 140),
                      Space.gapSm,
                      Skeleton(width: 210, height: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    ),
  );
}

// -----------------------------------------------------------------------------
// Domain widgets
// -----------------------------------------------------------------------------

/// Square avatar of an operator, in its brand colors when known.
class ProviderAvatar extends StatelessWidget {
  const ProviderAvatar({
    super.key,
    required this.name,
    required this.iconName,
    this.size = 44,
  });

  final String name;
  final String iconName;
  final double size;

  static (Color, Color)? brandColors(String name) {
    final n = name.toLowerCase();
    if (n.contains('orange')) return (const Color(0xFFFF7900), Colors.black);
    if (n.contains('airtel')) return (const Color(0xFFE40000), Colors.white);
    if (n.contains('mvola') || n.contains('yas') || n.contains('telma')) {
      return (const Color(0xFFFFD100), const Color(0xFF101828));
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final brand = brandColors(name);
    final background = brand?.$1 ?? context.colors.primaryContainer;
    final foreground = brand?.$2 ?? context.colors.onPrimaryContainer;
    final trimmed = name.trim();
    final initial = trimmed.isEmpty ? '?' : trimmed[0].toUpperCase();
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: brand != null
          ? Text(
              initial,
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                fontSize: size * 0.44,
                height: 1,
                color: foreground,
              ),
            )
          : Icon(
              IconUtil.getIcon(iconName),
              color: foreground,
              size: size * 0.5,
            ),
    );
  }
}

/// Selectable pill (operators, operations).
class ChoicePill extends StatelessWidget {
  const ChoicePill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.leading,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = BorderRadius.circular(Space.radiusMd);
    return PressScale(
      child: AnimatedContainer(
        duration: Motion.medium,
        curve: Motion.curve,
        decoration: BoxDecoration(
          color: selected
              ? colors.primaryContainer
              : colors.surfaceContainerLow,
          borderRadius: radius,
          border: Border.all(
            color: selected ? colors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: radius,
            onTap: () {
              HapticFeedback.selectionClick();
              onTap();
            },
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                leading == null ? Space.lg : Space.sm,
                Space.sm,
                Space.lg,
                Space.sm,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (leading != null) ...[leading!, Space.gapSm],
                  AnimatedDefaultTextStyle(
                    duration: Motion.medium,
                    style: context.text.titleSmall!.copyWith(
                      color: selected
                          ? colors.onPrimaryContainer
                          : colors.onSurface,
                    ),
                    child: Text(label),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// `−  value  +` control for small integers; [value] 0 shows [zeroLabel].
class CountStepper extends StatelessWidget {
  const CountStepper({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.zeroLabel,
    this.max = 999,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  final String zeroLabel;
  final int max;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    Widget button(IconData icon, VoidCallback? onTap) => PressScale(
      enabled: onTap != null,
      scale: 0.9,
      child: IconButton.filledTonal(
        onPressed: onTap == null
            ? null
            : () {
                HapticFeedback.selectionClick();
                onTap();
              },
        icon: Icon(icon, size: 20),
      ),
    );
    return Container(
      padding: const EdgeInsets.all(Space.sm),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(Space.radiusMd),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: context.text.labelMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          Space.gapXs,
          Row(
            children: [
              button(
                Icons.remove_rounded,
                value > 0 ? () => onChanged(value - 1) : null,
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: Motion.medium,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween(
                        begin: const Offset(0, 0.3),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                  child: Text(
                    value == 0 ? zeroLabel : '$value',
                    key: ValueKey(value),
                    textAlign: TextAlign.center,
                    style:
                        (value == 0
                                ? context.text.bodyMedium
                                : context.text.titleLarge)
                            ?.copyWith(fontFeatures: AppTheme.tabular),
                  ),
                ),
              ),
              button(
                Icons.add_rounded,
                value < max ? () => onChanged(value + 1) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Dialogs and sheets
// -----------------------------------------------------------------------------

/// Opens a modal bottom sheet with a title, scrolling content and keyboard
/// avoidance.
Future<T?> showAppSheet<T>(
  BuildContext context, {
  required String title,
  required WidgetBuilder builder,
}) => showModalBottomSheet<T>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  sheetAnimationStyle: const AnimationStyle(
    duration: Duration(milliseconds: 320),
    reverseDuration: Duration(milliseconds: 220),
    curve: Curves.easeOutCubic,
  ),
  builder: (sheetContext) => Padding(
    padding: EdgeInsets.only(
      bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
    ),
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(Space.page, 0, Space.page, Space.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: sheetContext.text.titleLarge),
          Space.gapLg,
          builder(sheetContext),
        ],
      ),
    ),
  ),
);

/// Asks for confirmation; returns `true` when confirmed.
Future<bool> confirm(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  required String cancelLabel,
  bool destructive = true,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(cancelLabel),
        ),
        FilledButton(
          style: destructive
              ? FilledButton.styleFrom(
                  backgroundColor: dialogContext.colors.error,
                  foregroundColor: dialogContext.colors.onError,
                  minimumSize: const Size(64, 44),
                )
              : FilledButton.styleFrom(minimumSize: const Size(64, 44)),
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}
