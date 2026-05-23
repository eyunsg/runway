import 'package:flutter/material.dart';

enum IconSize { xs, s, m, l }

class Avatar extends StatelessWidget {
  final IconSize size;

  const Avatar({super.key, required this.size});

  double get _iconDimension {
    switch (size) {
      case IconSize.xs:
        return 30;
      case IconSize.s:
        return 40;
      case IconSize.m:
        return 56;
      case IconSize.l:
        return 80;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _iconDimension,
      height: _iconDimension,
      child: Image.asset(
        '/icons/Avatar.png',
        width: _iconDimension,
        height: _iconDimension,
      ),
    );
  }
}
