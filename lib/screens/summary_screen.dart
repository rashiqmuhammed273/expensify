import 'package:expensify/models/expense.dart';
import 'package:expensify/models/expense_enum.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  late Box<Expense> _box;

  @override
  void initState() {
    super.initState();
    _box = Hive.box<Expense>('expenses');
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('SUMMARY'),
          bottom: const TabBar(
            indicatorColor: Colors.cyanAccent,
            labelColor: Colors.cyanAccent,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'Day'),
              Tab(text: 'Week'),
              Tab(text: 'Month'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _SummaryTab(timeframe: _Timeframe.day, box: _box),
            _SummaryTab(timeframe: _Timeframe.week, box: _box),
            _SummaryTab(timeframe: _Timeframe.month, box: _box),
          ],
        ),
      ),
    );
  }
}

enum _Timeframe { day, week, month }

class _SummaryTab extends StatelessWidget {
  final _Timeframe timeframe;
  final Box<Expense> box;

  const _SummaryTab({required this.timeframe, required this.box});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: box.listenable(),
      builder: (context, Box<Expense> box, _) {
        final now = DateTime.now();
        List<Expense> filtered = [];

        if (timeframe == _Timeframe.day) {
          filtered = box.values.where((e) {
            return e.date.year == now.year &&
                e.date.month == now.month &&
                e.date.day == now.day;
          }).toList();
        } else if (timeframe == _Timeframe.week) {
          final startOfWeek = DateTime(now.year, now.month, now.day)
              .subtract(Duration(days: now.weekday - 1));
          filtered = box.values.where((e) {
            return e.date.isAfter(startOfWeek.subtract(const Duration(days: 1)));
          }).toList();
        } else if (timeframe == _Timeframe.month) {
          filtered = box.values.where((e) {
            return e.date.year == now.year && e.date.month == now.month;
          }).toList();
        }

        if (filtered.isEmpty) {
          return Center(
            child: Text(
              'No expenses found.',
              style: TextStyle(
                color: Colors.cyanAccent.withOpacity(0.4),
                fontSize: 14,
                letterSpacing: 1,
              ),
            ),
          );
        }

        final totals = <ExpenseCategory, double>{};
        for (final e in filtered) {
          totals[e.category] = (totals[e.category] ?? 0) + e.amount;
        }

        final sorted = totals.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        final totalAmount = filtered.fold(0.0, (sum, e) => sum + e.amount);

        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF151A28),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TOTAL EXPENSES',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹${totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'CATEGORIES',
              style: TextStyle(
                color: Colors.cyanAccent,
                fontSize: 14,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 16),
            ...sorted.map((entry) {
              final pct = (totalAmount > 0) ? (entry.value / totalAmount * 100) : 0.0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: entry.key.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(entry.key.emoji, style: const TextStyle(fontSize: 24)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                entry.key.label,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                '₹${entry.value.toStringAsFixed(0)}',
                                style: TextStyle(
                                  color: entry.key.color,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: LinearProgressIndicator(
                                  value: pct / 100,
                                  backgroundColor: Colors.white10,
                                  color: entry.key.color,
                                  minHeight: 6,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              const SizedBox(width: 12),
                              SizedBox(
                                width: 45,
                                child: Text(
                                  '${pct.toStringAsFixed(0)}%',
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
