import 'package:flutter/material.dart';

/// A compact, professional search bar widget.
///
/// Usage:
/// ```dart
/// import 'package:your_project/widgets/search_bar_new.dart';
/// 
/// SearchBar(
///   hintText: 'Cari destinasi wisata...',
///   onChanged: (q) => print('search: $q'),
///   onSearch: (q) => print('do search: $q'),
/// )
/// ```
class SearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSearch;
  final VoidCallback? onTapPrefix;

  const SearchBar({
    super.key,
    this.controller,
    this.hintText = 'Cari...',
    this.onChanged,
    this.onSearch,
    this.onTapPrefix,
  });

  @override
  Widget build(BuildContext context) {
    final ctrl = controller ?? TextEditingController();

    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          // simple prefix circle
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFFFF7043),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),

          // Input
          Expanded(
            child: TextField(
              controller: ctrl,
              onChanged: onChanged,
              onSubmitted: (v) => onSearch?.call(v),
              textInputAction: TextInputAction.search,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(
                  color: Color(0xFF9E9E9E),
                  fontSize: 15,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          // suffix
          GestureDetector(
            onTap: () => onSearch?.call(ctrl.text),
            child: Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(right: 8),
              decoration: const BoxDecoration(
                color: Color(0xFFFF7043),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
