import 'package:expensify/models/expense.dart';
import 'package:expensify/models/expense_enum.dart';
import 'package:expensify/screens/addexpense.dart';
import 'package:expensify/screens/summary_screen.dart';
import 'package:expensify/widgets/common_widget.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'package:hive_flutter/hive_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Box<Expense> _box;

  @override
  void initState() {
    super.initState();
    _box = Hive.box<Expense>('expenses');
  }
  DateTime? _filterDate;
  ExpenseCategory? _filterCategory;
  double? _minAmount;
  double? _maxAmount;
  String _sortOrder = 'recent'; // 'recent', 'oldest'

  List<Expense> get _expenses {
    var list = _box.values.toList();
    
    if (_filterCategory != null) {
      list = list.where((e) => e.category == _filterCategory).toList();
    }
    if (_filterDate != null) {
      list = list.where((e) => e.date.year == _filterDate!.year && e.date.month == _filterDate!.month && e.date.day == _filterDate!.day).toList();
    }
    if (_minAmount != null) {
      list = list.where((e) => e.amount >= _minAmount!).toList();
    }
    if (_maxAmount != null) {
      list = list.where((e) => e.amount <= _maxAmount!).toList();
    }

    if (_sortOrder == 'recent') {
      list.sort((a, b) => b.date.compareTo(a.date));
    } else {
      list.sort((a, b) => a.date.compareTo(b.date));
    }

    return list;
  }
  double get _total => _expenses.fold(0, (sum, e) => sum + e.amount);

  // replace _deleteExpense
  void _deleteExpense(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF151A28),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(16),
          side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.6)),
        ),
        title: const Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
            SizedBox(width: 8),
            Text(
              "DELETE EXPENSE",
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 14,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        content: Text(
          "are you sure you eant to delete this expense",
          style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // cancel
            child: const Text(
              'CANCEL',
              style: TextStyle(color: Colors.grey, letterSpacing: 1),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              final index = _box.values.toList().indexWhere((e) => e.id == id);
              if (index != -1) {
                 _box.deleteAt(index).then((_) {
                setState(() {}); // explicit rebuild after Hive async delete
              });
              }
            },
            child: const Text(
              'DELETE',
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
          ),
        ],
      ),
    );
  }

  ExpenseCategory? get _topCategory {
    if (_expenses.isEmpty) return null;
    final totals = <ExpenseCategory, double>{};
    for (final e in _expenses) {
      totals[e.category] = (totals[e.category] ?? 0) + e.amount;
    }
    return totals.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  // void _openExpenseSheet({Expense? existing}) async {
  //   final result = await showModalBottomSheet<Expense>(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     builder: (_) => ExpenseSheet(existing: existing),
  //   );
  //   if (result != null) {
  //     setState(() {
  //       if (existing != null) {
  //         final idx = _expenses.indexWhere((e) => e.id == existing.id);
  //         if (idx != -1) _expenses[idx] = result;
  //       } else {
  //         _expenses.add(result);
  //       }
  //     });
  //   }
  // }

  void _openExpenseSheet({Expense? existing}) async {
    final result = await showModalBottomSheet<Expense>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ExpenseSheet(existing: existing),
    );

    if (result != null) {
      setState(() {
        if (existing != null) {
          // edit — find and replace at same index
          final index = _box.values.toList().indexWhere(
            (e) => e.id == existing.id,
          );
          if (index != -1) _box.putAt(index, result);
        } else {
          // add new
          _box.add(result);
        }
      });
    }
  }



  void _showFilterSheet() {
    DateTime? tempDate = _filterDate;
    ExpenseCategory? tempCat = _filterCategory;
    TextEditingController minCtrl = TextEditingController(text: _minAmount?.toString() ?? '');
    TextEditingController maxCtrl = TextEditingController(text: _maxAmount?.toString() ?? '');
    String tempSort = _sortOrder;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF151A28),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              left: 24,
              right: 24,
              top: 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'FILTER EXPENSES',
                    style: TextStyle(
                      color: Colors.cyanAccent,
                      fontSize: 16,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Date Picker
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.white70, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          tempDate == null 
                            ? 'Select Date' 
                            : '${tempDate!.day}/${tempDate!.month}/${tempDate!.year}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: tempDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setSheetState(() => tempDate = date);
                          }
                        },
                        child: const Text('Choose'),
                      ),
                      if (tempDate != null)
                        IconButton(
                          icon: const Icon(Icons.clear, color: Colors.redAccent, size: 20),
                          onPressed: () => setSheetState(() => tempDate = null),
                        )
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Category Dropdown
                  DropdownButtonFormField<ExpenseCategory?>(
                    value: tempCat,
                    dropdownColor: const Color(0xFF151A28),
                    decoration: InputDecoration(
                      labelText: 'Category',
                      labelStyle: const TextStyle(color: Colors.grey),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.withOpacity(0.3))),
                      focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent)),
                    ),
                    items: [
                      const DropdownMenuItem<ExpenseCategory?>(
                        value: null,
                        child: Text('All Categories', style: TextStyle(color: Colors.white)),
                      ),
                      ...ExpenseCategory.values.map((cat) {
                        return DropdownMenuItem<ExpenseCategory?>(
                          value: cat,
                          child: Row(
                            children: [
                              Text(cat.emoji),
                              const SizedBox(width: 8),
                              Text(cat.label, style: const TextStyle(color: Colors.white)),
                            ],
                          ),
                        );
                      }),
                    ],
                    onChanged: (val) => setSheetState(() => tempCat = val),
                  ),
                  const SizedBox(height: 20),

                  // Amount Range
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: minCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Min Amount',
                            labelStyle: const TextStyle(color: Colors.grey),
                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.withOpacity(0.3))),
                            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: maxCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Max Amount',
                            labelStyle: const TextStyle(color: Colors.grey),
                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.withOpacity(0.3))),
                            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Sort Order
                  const Text('Sort By', style: TextStyle(color: Colors.grey)),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Recent', style: TextStyle(color: Colors.white, fontSize: 14)),
                          value: 'recent',
                          groupValue: tempSort,
                          activeColor: Colors.cyanAccent,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (val) => setSheetState(() => tempSort = val!),
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Oldest', style: TextStyle(color: Colors.white, fontSize: 14)),
                          value: 'oldest',
                          groupValue: tempSort,
                          activeColor: Colors.cyanAccent,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (val) => setSheetState(() => tempSort = val!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              _filterDate = null;
                              _filterCategory = null;
                              _minAmount = null;
                              _maxAmount = null;
                              _sortOrder = 'recent';
                            });
                            Navigator.pop(context);
                          },
                          child: const Text('Clear All', style: TextStyle(color: Colors.redAccent)),
                        ),
                      ),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.cyanAccent.withOpacity(0.1),
                            foregroundColor: Colors.cyanAccent,
                            side: const BorderSide(color: Colors.cyanAccent),
                          ),
                          onPressed: () {
                            setState(() {
                              _filterDate = tempDate;
                              _filterCategory = tempCat;
                              _minAmount = double.tryParse(minCtrl.text);
                              _maxAmount = double.tryParse(maxCtrl.text);
                              _sortOrder = tempSort;
                            });
                            Navigator.pop(context);
                          },
                          child: const Text('Apply'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EXPENSIFY'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.cyanAccent),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              // ── Summary bar ──
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    _StatCard(
                      label: 'TOTAL',
                      value: '₹${_total.toStringAsFixed(0)}',
                      color: Colors.cyanAccent,
                    ),
                    const SizedBox(width: 10),
                    _StatCard(
                      label: 'ENTRIES',
                      value: '${_expenses.length}',
                      color: Colors.purpleAccent,
                    ),
                    const SizedBox(width: 10),
                    _StatCard(
                      label: 'TOP CAT',
                      value: _topCategory?.emoji ?? '—',
                      color: _topCategory?.color ?? Colors.grey,
                    ),
                  ],
                ),
              ),

              // ── List ──
              Expanded(
                child: _expenses.isEmpty
                    ? Center(
                        child: Text(
                          'No expenses added yet.\nInitialize databank.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.cyanAccent.withOpacity(0.4),
                            fontSize: 14,
                            letterSpacing: 1,
                            height: 2,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _expenses.length,
                        itemBuilder: (_, i) {
                          final exp = _expenses[i];
                          return ExpenseCard(
                            expense: exp,
                            onEdit: () => _openExpenseSheet(existing: exp),
                            onDelete: () => _deleteExpense(exp.id),
                          );
                        },
                      ),
              ),

              const SizedBox(height: 12),

              // ── Buttons ──
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      label: 'ADD EXPENSE',
                      icon: Icons.add,
                      color: Colors.cyanAccent,
                      onPressed: () => _openExpenseSheet(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionButton(
                      label: 'SUMMARY',
                      icon: Icons.bar_chart,
                      color: Colors.purpleAccent,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SummaryScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Reusable Widgets ─────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF151A28),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 9,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: const TextStyle(letterSpacing: 1, fontSize: 12),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        side: BorderSide(color: color),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }
}


// import 'package:expensify/models/expense.dart';
// import 'package:expensify/models/expense_enum.dart';
// import 'package:expensify/screens/addexpense.dart';
// import 'package:expensify/widgets/common_widget.dart';
// import 'package:flutter/material.dart';
// import 'package:hive/hive.dart';
// import 'package:hive_flutter/hive_flutter.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   late Box<Expense> _box;

//   @override
//   void initState() {
//     super.initState();
//     _box = Hive.box<Expense>('expenses');
//   }

//   List<Expense> get _expenses => _box.values.toList();

//   double get _total =>
//       _expenses.fold(0, (sum, e) => sum + e.amount);

//   void _deleteExpense(String id) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         backgroundColor: const Color(0xFF1A1D2A),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(24),
//         ),
//         title: const Row(
//           children: [
//             Icon(
//               Icons.delete_outline_rounded,
//               color: Colors.redAccent,
//             ),
//             SizedBox(width: 10),
//             Text(
//               "Delete Expense",
//               style: TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//         content: const Text(
//           "Are you sure you want to delete this expense?",
//           style: TextStyle(
//             color: Colors.white70,
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//             },
//             child: const Text(
//               "Cancel",
//               style: TextStyle(color: Colors.white54),
//             ),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.redAccent,
//               foregroundColor: Colors.white,
//             ),
//             onPressed: () {
//               Navigator.pop(context);

//               final index = _box.values
//                   .toList()
//                   .indexWhere((e) => e.id == id);

//               if (index != -1) {
//                 _box.deleteAt(index).then((_) {
//                   setState(() {});
//                 });
//               }
//             },
//             child: const Text("Delete"),
//           ),
//         ],
//       ),
//     );
//   }

//   ExpenseCategory? get _topCategory {
//     if (_expenses.isEmpty) return null;

//     final totals = <ExpenseCategory, double>{};

//     for (final e in _expenses) {
//       totals[e.category] =
//           (totals[e.category] ?? 0) + e.amount;
//     }

//     return totals.entries
//         .reduce((a, b) => a.value >= b.value ? a : b)
//         .key;
//   }

//   void _openExpenseSheet({Expense? existing}) async {
//     final result = await showModalBottomSheet<Expense>(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) => ExpenseSheet(existing: existing),
//     );

//     if (result != null) {
//       setState(() {
//         if (existing != null) {
//           final index = _box.values
//               .toList()
//               .indexWhere((e) => e.id == existing.id);

//           if (index != -1) {
//             _box.putAt(index, result);
//           }
//         } else {
//           _box.add(result);
//         }
//       });
//     }
//   }

//   void _showSummary() {
//     if (_expenses.isEmpty) return;

//     final totals = <ExpenseCategory, double>{};

//     for (final e in _expenses) {
//       totals[e.category] =
//           (totals[e.category] ?? 0) + e.amount;
//     }

//     final sorted = totals.entries.toList()
//       ..sort((a, b) => b.value.compareTo(a.value));

//     showModalBottomSheet(
//       context: context,
//       backgroundColor: const Color(0xFF1A1D2A),
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(
//           top: Radius.circular(30),
//         ),
//       ),
//       builder: (_) => Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text(
//               "Expense Summary",
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),

//             const SizedBox(height: 10),

//             Text(
//               "Total: ₹${_total.toStringAsFixed(2)}",
//               style: const TextStyle(
//                 color: Colors.white70,
//                 fontSize: 15,
//               ),
//             ),

//             const SizedBox(height: 25),

//             ...sorted.map((entry) {
//               final pct = (_total > 0)
//                   ? (entry.value / _total * 100)
//                   : 0.0;

//               return Padding(
//                 padding:
//                     const EdgeInsets.symmetric(vertical: 10),
//                 child: Column(
//                   children: [
//                     Row(
//                       children: [
//                         Text(
//                           entry.key.emoji,
//                           style: const TextStyle(
//                             fontSize: 22,
//                           ),
//                         ),

//                         const SizedBox(width: 12),

//                         Expanded(
//                           child: Text(
//                             entry.key.label,
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 15,
//                             ),
//                           ),
//                         ),

//                         Text(
//                           "₹${entry.value.toStringAsFixed(0)}",
//                           style: TextStyle(
//                             color: entry.key.color,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),

//                     const SizedBox(height: 8),

//                     LinearProgressIndicator(
//                       value: pct / 100,
//                       backgroundColor: Colors.white10,
//                       color: entry.key.color,
//                       borderRadius:
//                           BorderRadius.circular(10),
//                       minHeight: 8,
//                     ),
//                   ],
//                 ),
//               );
//             }),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0E1017),

//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         centerTitle: false,
//         titleSpacing: 20,
//         title: const Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               "Expensify",
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 28,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 2),
//             Text(
//               "Track your money smartly",
//               style: TextStyle(
//                 color: Colors.white54,
//                 fontSize: 13,
//               ),
//             ),
//           ],
//         ),
//       ),

//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(
//             20,
//             10,
//             20,
//             10,
//           ),
//           child: Column(
//             children: [
//               /// SUMMARY CARDS
//               Row(
//                 children: [
//                   _StatCard(
//                     label: "TOTAL",
//                     value:
//                         "₹${_total.toStringAsFixed(0)}",
//                     color: Colors.greenAccent,
//                   ),

//                   const SizedBox(width: 12),

//                   _StatCard(
//                     label: "ENTRIES",
//                     value: "${_expenses.length}",
//                     color: Colors.blueAccent,
//                   ),

//                   const SizedBox(width: 12),

//                   _StatCard(
//                     label: "TOP",
//                     value:
//                         _topCategory?.emoji ?? "—",
//                     color:
//                         _topCategory?.color ??
//                             Colors.grey,
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 25),

//               /// EXPENSE LIST
//               Expanded(
//                 child: _expenses.isEmpty
//                     ? Center(
//                         child: Column(
//                           mainAxisAlignment:
//                               MainAxisAlignment.center,
//                           children: [
//                             Icon(
//                               Icons
//                                   .account_balance_wallet_rounded,
//                               size: 75,
//                               color: Colors.white10,
//                             ),

//                             const SizedBox(height: 20),

//                             const Text(
//                               "No expenses yet",
//                               style: TextStyle(
//                                 color: Colors.white70,
//                                 fontSize: 22,
//                                 fontWeight:
//                                     FontWeight.bold,
//                               ),
//                             ),

//                             const SizedBox(height: 8),

//                             const Text(
//                               "Start managing your expenses beautifully.",
//                               textAlign:
//                                   TextAlign.center,
//                               style: TextStyle(
//                                 color: Colors.white38,
//                                 fontSize: 13,
//                               ),
//                             ),
//                           ],
//                         ),
//                       )
//                     : ListView.builder(
//                         itemCount: _expenses.length,
//                         itemBuilder: (_, i) {
//                           final exp = _expenses[
//                               _expenses.length -
//                                   1 -
//                                   i];

//                           return Padding(
//                             padding:
//                                 const EdgeInsets.only(
//                               bottom: 14,
//                             ),
//                             child: ExpenseCard(
//                               expense: exp,
//                               onEdit: () =>
//                                   _openExpenseSheet(
//                                 existing: exp,
//                               ),
//                               onDelete: () =>
//                                   _deleteExpense(
//                                 exp.id,
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//               ),

//               const SizedBox(height: 10),

//               /// BUTTONS
//               Row(
//                 children: [
//                   Expanded(
//                     child: _ActionButton(
//                       label: "Add Expense",
//                       icon: Icons.add_rounded,
//                       color: Colors.greenAccent,
//                       onPressed: () =>
//                           _openExpenseSheet(),
//                     ),
//                   ),

//                   const SizedBox(width: 15),

//                   Expanded(
//                     child: _ActionButton(
//                       label: "Summary",
//                       icon: Icons.bar_chart_rounded,
//                       color: Colors.deepPurpleAccent,
//                       onPressed: _showSummary,
//                     ),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 14),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// /// ─────────────────────────────────────────────
// /// STAT CARD
// /// ─────────────────────────────────────────────

// class _StatCard extends StatelessWidget {
//   final String label;
//   final String value;
//   final Color color;

//   const _StatCard({
//     required this.label,
//     required this.value,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.all(18),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(24),
//           gradient: LinearGradient(
//             colors: [
//               color.withOpacity(0.16),
//               const Color(0xFF1B1E2B),
//             ],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           border: Border.all(
//             color: color.withOpacity(0.25),
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: color.withOpacity(0.08),
//               blurRadius: 20,
//               spreadRadius: 2,
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment:
//               CrossAxisAlignment.start,
//           children: [
//             Text(
//               label,
//               style: const TextStyle(
//                 color: Colors.white54,
//                 fontSize: 11,
//                 letterSpacing: 1.2,
//               ),
//             ),

//             const SizedBox(height: 12),

//             Text(
//               value,
//               style: TextStyle(
//                 color: color,
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// /// ─────────────────────────────────────────────
// /// BUTTON
// /// ─────────────────────────────────────────────

// class _ActionButton extends StatelessWidget {
//   final String label;
//   final IconData icon;
//   final Color color;
//   final VoidCallback onPressed;

//   const _ActionButton({
//     required this.label,
//     required this.icon,
//     required this.color,
//     required this.onPressed,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton(
//       onPressed: onPressed,

//       style: ElevatedButton.styleFrom(
//         backgroundColor: color,
//         foregroundColor: Colors.black,
//         elevation: 0,
//         padding: const EdgeInsets.symmetric(
//           vertical: 18,
//         ),
//         shape: RoundedRectangleBorder(
//           borderRadius:
//               BorderRadius.circular(18),
//         ),
//       ),

//       child: Row(
//         mainAxisAlignment:
//             MainAxisAlignment.center,
//         children: [
//           Icon(icon, size: 20),

//           const SizedBox(width: 10),

//           Text(
//             label,
//             style: const TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

