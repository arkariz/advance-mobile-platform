import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:navigation/src/dev/dev_entry.dart';
import 'package:navigation/src/route_registry.dart';

/// A debug-only screen that lists all registered [DevEntry]s grouped by
/// feature category, allowing developers and QA to open any screen directly
/// without navigating through the normal app flow.
///
/// This widget is a no-op in release builds — wrap launch points with
/// [kDebugMode] guards or use [DevMenuButton] to prevent exposure.
///
/// ## Integration
/// Push this screen from a debug affordance in your [App] widget:
/// ```dart
/// if (kDebugMode)
///   FloatingActionButton(
///     onPressed: () => Navigator.of(context).push(
///       MaterialPageRoute(builder: (_) => DevMenuScreen(registry: registry)),
///     ),
///   ),
/// ```
class DevMenuScreen extends StatelessWidget {
  /// Creates a [DevMenuScreen] with the given [registry] and [onEntryTap] callback.
  const DevMenuScreen({
    required this.registry,
    required this.onEntryTap,
    super.key,
  });

  /// The registry from which [DevEntry]s are sourced.
  final RouteRegistry registry;

  /// Called when an entry is tapped. The caller should use this to trigger
  /// navigation (typically via [AppNavService.push]).
  final void Function(DevEntry entry) onEntryTap;

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();

    final entries = registry.devEntries;

    if (entries.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Dev Menu')),
        body: const Center(
          child: Text('No DevEntry items registered.'),
        ),
      );
    }

    // Group entries by category.
    final grouped = <String, List<DevEntry>>{};
    for (final entry in entries) {
      grouped.putIfAbsent(entry.category, () => []).add(entry);
    }
    final categories = grouped.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dev Menu'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final categoryEntries = grouped[category]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CategoryHeader(label: category),
              ...categoryEntries.map(
                (entry) => _EntryTile(
                  entry: entry,
                  onTap: () => onEntryTap(entry),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.deepPurple.shade50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.deepPurple,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({required this.entry, required this.onTap});
  final DevEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(entry.label),
      subtitle: Text(
        entry.keyId,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey,
              fontFamily: 'monospace',
            ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      onTap: onTap,
    );
  }
}
