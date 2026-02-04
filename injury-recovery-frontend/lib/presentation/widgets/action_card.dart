// lib/presentation/widgets/action_card.dart
// Modern card widget for displaying selectable action types

import 'package:flutter/material.dart';
import 'package:VOMAS/data/models/action_type.dart';

/// A tappable card representing an action type with hover/press animations
class ActionCard extends StatefulWidget {
  final ActionType actionType;
  final VoidCallback? onTap;
  final bool isSelected;

  const ActionCard({
    super.key,
    required this.actionType,
    this.onTap,
    this.isSelected = false,
  });

  @override
  State<ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<ActionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final gradientColors = widget.actionType.gradientColors;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(scale: _scaleAnimation.value, child: child);
      },
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: widget.onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isPressed
                    ? gradientColors.map((c) => c.withOpacity(0.8)).toList()
                    : gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: gradientColors.first.withOpacity(
                    _isPressed ? 0.3 : 0.4,
                  ),
                  blurRadius: _isPressed ? 8 : 16,
                  offset: Offset(0, _isPressed ? 4 : 8),
                  spreadRadius: _isPressed ? 0 : 2,
                ),
              ],
              // Selected border
              border: widget.isSelected
                  ? Border.all(
                      color: isDarkMode ? Colors.white : Colors.black,
                      width: 3,
                    )
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      widget.actionType.icon,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Action Name
                  Text(
                    widget.actionType.displayName,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Description
                  Expanded(
                    child: Text(
                      widget.actionType.description,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 11,
                        height: 1.3,
                      ),
                    ),
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

/// A grid displaying all 6 action cards
class ActionsGrid extends StatelessWidget {
  final void Function(ActionType) onActionSelected;
  final ActionType? selectedAction;

  const ActionsGrid({
    super.key,
    required this.onActionSelected,
    this.selectedAction,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      itemCount: ActionType.values.length,
      itemBuilder: (context, index) {
        final action = ActionType.values[index];
        return ActionCard(
          actionType: action,
          isSelected: selectedAction == action,
          onTap: () => onActionSelected(action),
        );
      },
    );
  }
}
