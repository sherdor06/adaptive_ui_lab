import 'dart:async';

import 'package:flutter/cupertino.dart';

abstract final class CToast {
  static void show(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final overlay = Overlay.of(context, rootOverlay: true);
    late final OverlayEntry entry;
    var removed = false;
    void remove() {
      if (removed || !entry.mounted) return;
      removed = true;
      entry.remove();
    }

    entry = OverlayEntry(
      builder: (_) => _CToastBody(
        message: message,
        actionLabel: actionLabel,
        onAction: onAction,
        onDismissed: remove,
      ),
    );
    overlay.insert(entry);
  }
}

class _CToastBody extends StatefulWidget {
  const _CToastBody({
    required this.message,
    required this.onDismissed,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback onDismissed;

  @override
  State<_CToastBody> createState() => _CToastBodyState();
}

class _CToastBodyState extends State<_CToastBody>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  );

  late final CurvedAnimation _curve = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );

  late final Animation<Offset> _offset = Tween<Offset>(
    begin: const Offset(0, 1.4),
    end: Offset.zero,
  ).animate(_curve);

  Timer? _autoHide;

  @override
  void initState() {
    super.initState();
    _controller.forward();
    _autoHide = Timer(const Duration(seconds: 3), _hide);
  }

  Future<void> _hide() async {
    _autoHide?.cancel();
    if (!mounted) return;
    await _controller.reverse();
    if (!mounted) return;
    widget.onDismissed();
  }

  @override
  void dispose() {
    _autoHide?.cancel();
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 96,
      child: SlideTransition(
        position: _offset,
        child: FadeTransition(
          opacity: _curve,
          child: CupertinoPopupSurface(
            isSurfacePainted: false,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6.resolveFrom(context),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: CupertinoColors.separator.resolveFrom(context),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.message,
                        style: CupertinoTheme.of(context).textTheme.textStyle,
                      ),
                    ),
                    if (widget.actionLabel != null)
                      CupertinoButton(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        onPressed: () {
                          widget.onAction?.call();
                          _hide();
                        },
                        child: Text(widget.actionLabel!),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
