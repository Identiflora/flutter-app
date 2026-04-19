import 'package:flutter/material.dart';
import 'package:identiflora/widgets/neon_widgets.dart';

class LevelModalBottomSheet {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      sheetAnimationStyle: AnimationStyle(
        duration: Duration(milliseconds: 600),
      ),
      builder: (context) => const LevelSheetContent(),
    );
  }
}

class LevelSheetContent extends StatefulWidget {
  const LevelSheetContent({super.key});

  @override
  State<LevelSheetContent> createState() => _LevelSheetContentState();
}

class _LevelSheetContentState extends State<LevelSheetContent> {
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      snap: true,
      snapAnimationDuration: const Duration(milliseconds: 300),
      snapSizes: [.7, .91],
      builder: (context, scrollController) {
        return Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withAlpha(220),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Points & Levels",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const LevelSystemExplanation(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}

class LevelSystemExplanation extends StatelessWidget {
  const LevelSystemExplanation({super.key});

  // Mirrors accountLevels in point_utils.dart. All thresholds are ≡2 (mod 3)
  // so users earning 3 pts/identification never land exactly on a threshold.
  static const Map<int, int> _accountLevels = {
    0: 0,
    1: 2,
    2: 5,
    3: 8,
    4: 11,
    5: 17,
    6: 23,
    7: 32,
    8: 44,
    9: 56,
    10: 68,
    11: 83,
    12: 101,
    13: 122,
    14: 143,
    15: 164,
    16: 188,
    17: 215,
    18: 242,
    19: 269,
    20: 299,
  };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final levels = _accountLevels.entries.toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "How Points Work",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Earn 3 points for every correct plant identification. "
            "Your first identification will get you to Level 1 right away, "
            "and Level 20 awaits after around 100 correct identifications!",
            style: TextStyle(fontSize: 14.0, color: colorScheme.onSurface),
          ),
          const SizedBox(height: 24),
          Text(
            "Level Progression",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Column(
            children: List.generate(levels.length, (i) {
              final level = levels[i].key;
              final cumulative = levels[i].value;
              final prev = i > 0 ? levels[i - 1].value : 0;
              final delta = cumulative - prev;
              final isMax = level == _accountLevels.keys.last;

              String deltaLabel;
              if (level == 0) {
                deltaLabel = "Starting level";
              } else if (isMax) {
                deltaLabel = "+$delta pts  (max)";
              } else {
                deltaLabel = "+$delta pts";
              }

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    NeonContainer(
                      width: 32,
                      height: 32,
                      border: Border.all(
                        color: colorScheme.secondary,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      backgroundColor: colorScheme.surface,
                      child: Center(
                        child: Text(
                          "$level",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13.0,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        level == 0 ? "0 pts total" : "$cumulative pts total",
                        style: TextStyle(
                          fontSize: 14.0,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Text(
                      deltaLabel,
                      style: TextStyle(
                        fontSize: 12.0,
                        fontStyle: FontStyle.italic,
                        color: colorScheme.onSurface.withAlpha(140),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
