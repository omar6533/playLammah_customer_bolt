import 'package:flutter/material.dart';

/// Sub-category illustration uploaded from the admin portal, falling back to
/// the generic placeholder while it is missing or fails to load.
class CategoryImage extends StatelessWidget {
  final String? url;
  final BoxFit fit;
  final Alignment alignment;

  const CategoryImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final placeholder = Image.asset(
      'assets/images/category_placeholder.png',
      fit: BoxFit.contain,
      alignment: Alignment.bottomCenter,
      width: double.infinity,
      height: double.infinity,
    );
    if (url == null || url!.isEmpty) return placeholder;
    return Image.network(
      url!,
      fit: fit,
      alignment: alignment,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, __, ___) => placeholder,
    );
  }
}
