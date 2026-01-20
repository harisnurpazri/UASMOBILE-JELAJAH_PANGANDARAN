// Dummy animation classes to replace animate_do package on Web (no-op wrappers)
// These simply return the child widget so the UI remains identical without the
// animate_do debug print spam on Flutter Web.

import 'package:flutter/material.dart';

class FadeIn extends StatelessWidget {
  final Widget child;
  final bool? animate;
  final Duration? delay;
  final Duration? duration;

  const FadeIn({super.key, required this.child, this.animate, this.delay, this.duration});
  @override
  Widget build(BuildContext context) => child;
}

class FadeInUp extends StatelessWidget {
  final Widget child;
  final bool? animate;
  final Duration? delay;
  final Duration? duration;

  const FadeInUp({super.key, required this.child, this.animate, this.delay, this.duration});
  @override
  Widget build(BuildContext context) => child;
}

class FadeInDown extends StatelessWidget {
  final Widget child;
  final bool? animate;
  final Duration? delay;
  final Duration? duration;

  const FadeInDown({super.key, required this.child, this.animate, this.delay, this.duration});
  @override
  Widget build(BuildContext context) => child;
}

class FadeInLeft extends StatelessWidget {
  final Widget child;
  final bool? animate;
  final Duration? delay;
  final Duration? duration;

  const FadeInLeft({super.key, required this.child, this.animate, this.delay, this.duration});
  @override
  Widget build(BuildContext context) => child;
}

class FadeInRight extends StatelessWidget {
  final Widget child;
  final bool? animate;
  final Duration? delay;
  final Duration? duration;

  const FadeInRight({super.key, required this.child, this.animate, this.delay, this.duration});
  @override
  Widget build(BuildContext context) => child;
}

class ZoomIn extends StatelessWidget {
  final Widget child;
  final bool? animate;
  final Duration? delay;
  final Duration? duration;

  const ZoomIn({super.key, required this.child, this.animate, this.delay, this.duration});
  @override
  Widget build(BuildContext context) => child;
}

class SlideInUp extends StatelessWidget {
  final Widget child;
  final bool? animate;
  final Duration? delay;
  final Duration? duration;

  const SlideInUp({super.key, required this.child, this.animate, this.delay, this.duration});
  @override
  Widget build(BuildContext context) => child;
}

class SlideInDown extends StatelessWidget {
  final Widget child;
  final bool? animate;
  final Duration? delay;
  final Duration? duration;

  const SlideInDown({super.key, required this.child, this.animate, this.delay, this.duration});
  @override
  Widget build(BuildContext context) => child;
}
