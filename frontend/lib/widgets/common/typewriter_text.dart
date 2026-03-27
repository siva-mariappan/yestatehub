import 'dart:async';
import 'package:flutter/material.dart';

/// Animated typewriter text widget
class TypewriterText extends StatefulWidget {
  final List<String> texts;
  final TextStyle? style;
  final Duration typingSpeed;
  final Duration pauseDuration;
  final Duration deletingSpeed;

  const TypewriterText({
    super.key,
    required this.texts,
    this.style,
    this.typingSpeed = const Duration(milliseconds: 60),
    this.pauseDuration = const Duration(seconds: 2),
    this.deletingSpeed = const Duration(milliseconds: 30),
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  String _displayText = '';
  int _textIndex = 0;
  int _charIndex = 0;
  bool _isDeleting = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  void _startTyping() {
    _timer = Timer.periodic(
      _isDeleting ? widget.deletingSpeed : widget.typingSpeed,
      (_) {
        if (!mounted) return;
        final currentText = widget.texts[_textIndex];

        setState(() {
          if (_isDeleting) {
            if (_charIndex > 0) {
              _charIndex--;
              _displayText = currentText.substring(0, _charIndex);
            } else {
              _isDeleting = false;
              _textIndex = (_textIndex + 1) % widget.texts.length;
              _timer?.cancel();
              _startTyping();
            }
          } else {
            if (_charIndex < currentText.length) {
              _charIndex++;
              _displayText = currentText.substring(0, _charIndex);
            } else {
              _timer?.cancel();
              Future.delayed(widget.pauseDuration, () {
                if (!mounted) return;
                _isDeleting = true;
                _startTyping();
              });
            }
          }
        });
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            _displayText,
            style: widget.style,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Blinking cursor
        _BlinkingCursor(
          color: widget.style?.color ?? Colors.white,
          height: (widget.style?.fontSize ?? 16) * 1.2,
        ),
      ],
    );
  }
}

class _BlinkingCursor extends StatefulWidget {
  final Color color;
  final double height;

  const _BlinkingCursor({required this.color, required this.height});

  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 3,
        height: widget.height,
        margin: const EdgeInsets.only(left: 2),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(1.5),
        ),
      ),
    );
  }
}
