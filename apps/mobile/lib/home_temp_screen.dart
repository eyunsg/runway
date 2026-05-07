import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeTempScreen extends StatelessWidget {
  const HomeTempScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dev Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              context.push('/profile');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _button(
              context,
              'Create Portfolio',
              () => context.push('/simulation'),
            ),
            const SizedBox(height: 16),
            _button(
              context,
              'Get Portfolio',
              () => context.push('/portfolio/get'),
            ),
            const SizedBox(height: 16),
            _button(context, 'Create Post', () => context.push('/post/create')),
            const SizedBox(height: 16),
            _button(context, 'Get Post', () => context.push('/post/get')),
          ],
        ),
      ),
    );
  }
}

Widget _button(BuildContext context, String title, VoidCallback onPressed) {
  return SizedBox(
    width: double.infinity,
    height: 100,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      onPressed: onPressed,
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
    ),
  );
}
