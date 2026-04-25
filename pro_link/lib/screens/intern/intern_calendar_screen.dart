import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../providers/auth_provider.dart';
import '../../providers/intern_provider.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/responsive_page.dart';

class InternCalendarScreen extends ConsumerStatefulWidget {
  const InternCalendarScreen({super.key});

  @override
  ConsumerState<InternCalendarScreen> createState() => _InternCalendarScreenState();
}

class _InternCalendarScreenState extends ConsumerState<InternCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = ref.read(authProvider).currentUser?.id;
      if (userId != null) {
        ref.read(internProvider).loadAll(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(internProvider);

    final eventsByDay = <DateTime, List<String>>{};
    for (final event in controller.events) {
      final day = DateTime(event.date.year, event.date.month, event.date.day);
      eventsByDay.putIfAbsent(day, () => []).add(event.title);
    }

    final selectedEvents = eventsByDay[
            DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day)] ??
        const [];

    return Scaffold(
      appBar: AppBar(title: const Text('Internship Calendar')),
      body: LoadingOverlay(
        isLoading: controller.isLoading,
        child: ResponsivePage(
          maxWidth: 980,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: TableCalendar(
                    firstDay: DateTime.now().subtract(const Duration(days: 365)),
                    lastDay: DateTime.now().add(const Duration(days: 365)),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
                    eventLoader: (day) {
                      return eventsByDay[DateTime(day.year, day.month, day.day)] ?? const [];
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Events on ${_selectedDay.toIso8601String().split('T').first}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      if (selectedEvents.isEmpty)
                        const Text('No events')
                      else
                        for (final e in selectedEvents)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                const Icon(Icons.event, size: 16),
                                const SizedBox(width: 8),
                                Expanded(child: Text(e)),
                              ],
                            ),
                          ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
