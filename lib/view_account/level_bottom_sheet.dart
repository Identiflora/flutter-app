import 'package:flutter/material.dart';

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
            //anything to add to the sheet goes in this child
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
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withAlpha(220),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Text("Level"),
              ],
            ),
          ),
        );
      },
    );
  }
}
