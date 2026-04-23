import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:identiflora/database_utils.dart';
import 'package:identiflora/user_credentials/auth_objects.dart';
import 'package:identiflora/widgets/neon_widgets.dart';
import 'package:identiflora/theme/neon_theme.dart';
import 'package:identiflora/theme/general_utils.dart';
import 'submission_map.dart';

// NOTE: I used neonIcon for the icons on this page but I have no idea if thats right way to do this,
// I just couldnt find another standard themeing for icons besides the one thats just neon green
// in our current theme files

// This is a widget i made to test the history page that was just on the bottom right of
// main, but I thought maybe we could put it on the bottom right of the profile or something.
// I also thought that maybe we could just swipe left on the profile to go to history but I havent
// looked into how that works

class HistoryWidget extends StatelessWidget {
  const HistoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GestureDetector(
            onTap: () => Navigator.push(
                context, MaterialPageRoute(
                  builder: (context) => HistoryPage()
                )
              ), 
            child: Icon(
              Icons.history, 
              size: 90.0,
              color: Theme.of(context).colorScheme.surface,
              shadows: Theme.of(context).extension<NeonTheme>()?.homeIconShadow,
            ),
          ),
        ),
      ),
    );
  }
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<List<Map<String, dynamic>>> _historyFuture;

  Future<Map<String, String>> _loadCommonNameMap() async {
    final labelData = await rootBundle.loadString('assets/model/labels.txt');
    final commonData = await rootBundle.loadString('assets/model/common_names.txt');
    final labels = labelData.split('\n');
    final commons = commonData.split('\n');
    final map = <String, String>{};
    for (int i = 0; i < labels.length && i < commons.length; i++) {
      final parts = labels[i].trim().split('_');
      if (parts.length < 2) continue;
      final key = '${parts[0]}_${parts[1]}';
      final val = commons[i].trim();
      if (val.isNotEmpty) map[key] = val;
    }
    return map;
  }

  @override
  void initState() {
    super.initState();
    _historyFuture = _loadCommonNameMap().then(
      (commonNameMap) => fetchSubmissionHistory(commonNameMap: commonNameMap),
    );
    // _historyFuture = Future.error(AuthException("Your session has timed out", statusCode: 401));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant History'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: theme.colorScheme.primary));
          } else if (snapshot.hasError) {
            return _buildErrorState(snapshot.error, theme);
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No history found.'));
          }
          final historyList = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            itemCount: historyList.length,
            itemBuilder: (context, index) => _buildPlantCard(historyList[index], historyList, theme),
          );
        },
      ),
    );
  }

  Widget _placeholder(ThemeData theme) => Container(
    height: 200,
    width: double.infinity,
    color: theme.colorScheme.surface,
    child: const Center(child: NeonIcon(Icons.eco, size: 120.0)),
  );

  Widget _buildPlantCard(Map<String, dynamic> item, List<Map<String, dynamic>> allItems, ThemeData theme) {
    String displayDateTime = 'Unknown Date';
    if (item['time_submitted'] != null) {
      try {
        String rawTime = item['time_submitted'].toString();
        DateTime dt = DateTime.parse('${rawTime}Z').toLocal(); 
        displayDateTime = DateFormat('MMM d, yyyy - h:mm a').format(dt);
      } catch (e) { /*currently fails silently*/ }
    }

    return Column(
      children: [
        NeonContainer(
          borderRadius: const BorderRadius.all(Radius.circular(15.0)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo Section
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(13.5)),
                child: (item['scientific_name'] != null)
                    ? Image.asset(
                        localPlantAssetPath(item['scientific_name'].toString().replaceAll(" ", "_")),
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _placeholder(theme),
                      )
                    : _placeholder(theme),
              ),
              // Details Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (item['common_name']?.toString().isNotEmpty == true
                              ? item['common_name'] as String
                              : item['species_name'] as String? ?? 'Unknown Plant')
                          .toUpperCase(),
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    if (item['scientific_name'] != null)
                      Text(
                        item['scientific_name'],
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          fontStyle: FontStyle.italic,
                          fontSize: 14.0,
                        ),
                      ),
                    const SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const NeonIcon(Icons.access_time, size: 16.0),
                            const SizedBox(width: 8.0),
                            Text(
                              displayDateTime,
                              style: TextStyle(
                                fontSize: 13.0, 
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        // If location data is not correctly captured during submission both
                        // lat and long are set to 0
                        if ((item['latitude'] != 0) && (item['longitude'] != 0))
                          GestureDetector(
                            onTap: () {
                              final (allEntries, selectedIdx) = _buildMapEntries(allItems, item);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SubmissionMapPage(
                                    entries: allEntries,
                                    selectedIndex: selectedIdx,
                                  ),
                                ),
                              );
                            },
                            child: const NeonIcon(Icons.location_on, size: 20.0),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(padding: const EdgeInsets.symmetric(vertical: 8.0)),
      ],
    );
  }

  (List<HistoryMapEntry>, int) _buildMapEntries(
    List<Map<String, dynamic>> allItems,
    Map<String, dynamic> selected,
  ) {
    final entries = allItems
        .where((e) => (e['latitude'] as num? ?? 0) != 0 && (e['longitude'] as num? ?? 0) != 0)
        .map((e) => HistoryMapEntry(
              latitude: (e['latitude'] as num).toDouble(),
              longitude: (e['longitude'] as num).toDouble(),
              plantName: e['common_name']?.toString().isNotEmpty == true
                  ? e['common_name'] as String
                  : e['scientific_name'] as String? ?? 'Unknown Plant',
            ))
        .toList();
    final selectedLat = (selected['latitude'] as num).toDouble();
    final selectedLon = (selected['longitude'] as num).toDouble();
    final idx = entries.indexWhere((e) => e.latitude == selectedLat && e.longitude == selectedLon);
    return (entries, idx < 0 ? 0 : idx);
  }

  // Error handling in the case that user authentication fails or the application is unable to reach
  // the API. I think this could be repurposed into its own file in a generic form to use on any
  // screen that could fail in the same way, like failing to submit a plant submission.
  Widget _buildErrorState(Object? error, ThemeData theme) {
  final bool isAuthError = error is AuthException;

  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        NeonIcon(
          isAuthError ? Icons.lock_person_outlined : Icons.error_outline,
          size: 60.0,
        ),
        const SizedBox(height: 16),
        Text(
          isAuthError ? "SESSION EXPIRED" : "CONNECTION ERROR",
          style: TextStyle(
            color: theme.colorScheme.error,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isAuthError 
              ? "Please login again to view history." 
              : "Unable to reach the server.",
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
        const SizedBox(height: 32),

        // Connection error handling
        if (isAuthError)
          GestureDetector(
            onTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              // button has to be a box and dont have any explicit theme parameters for boxes
              // so i had to free ball
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.primary),
                boxShadow: [
                ],
              ),
              child: Text(
                "RETURN TO HOME",
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        else
          // Connection timeout screen, currently times out at 30 seconds
          // defined in fetchSubmissionHistory() in database_utils 
          OutlinedButton(
            onPressed: () => setState(() {
              _historyFuture = fetchSubmissionHistory();
            }),
            child: Text(
              "RETRY",
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
      ],
    ),
  );
}
}