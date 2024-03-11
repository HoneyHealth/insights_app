import 'package:flutter/material.dart';

import 'widgets/widgets.dart';

class InsightFilterCard extends StatefulWidget {
  final String title;
  final int count;
  final int total;
  final bool isSelected;
  final VoidCallback onTap;

  const InsightFilterCard({
    super.key,
    required this.title,
    required this.count,
    required this.total,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<InsightFilterCard> createState() => _InsightFilterCardState();
}

class _InsightFilterCardState extends State<InsightFilterCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: widget.isSelected
            ? AnimatedContainer(
                key: ValueKey('${widget.title}Filled'),
                duration: const Duration(milliseconds: 300),
                child: Card.filled(
                  child: InsightFilterCardData(
                    title: widget.title,
                    count: widget.count,
                    total: widget.total,
                  ),
                ),
              )
            : AnimatedContainer(
                key: ValueKey('${widget.title}Outlined'),
                duration: const Duration(milliseconds: 300),
                child: Card.outlined(
                  child: InsightFilterCardData(
                    title: widget.title,
                    count: widget.count,
                    total: widget.total,
                  ),
                ),
              ),
      ),
    );
  }
}
