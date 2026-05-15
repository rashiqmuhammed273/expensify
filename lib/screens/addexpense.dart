import 'package:expensify/models/expense.dart';
import 'package:expensify/models/expense_enum.dart';
import 'package:flutter/material.dart';

class ExpenseSheet extends StatefulWidget {
  final Expense? existing;
  const ExpenseSheet({super.key, this.existing});

  @override
  State<ExpenseSheet> createState() => _ExpenseSheetState();
}

class _ExpenseSheetState extends State<ExpenseSheet> {
  late final TextEditingController _title;
  late final TextEditingController _amount;
  late final TextEditingController _notes;
  late DateTime _date;
  // late ExpenseCategory _category;
  ExpenseCategory? _category;
  late PaymentMode _paymentMode;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _title = TextEditingController(text: e?.title ?? '');
    _amount = TextEditingController(
      text: e != null ? e.amount.toStringAsFixed(2) : '',
    );
    _notes = TextEditingController(text: e?.notes ?? '');
    _date = e?.date ?? DateTime.now();
    _category = e?.category ?? ExpenseCategory.food;
    _paymentMode = e?.paymentMode ?? PaymentMode.upi;
  }

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Colors.cyanAccent,
            surface: Color(0xFF151A28),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _save() {
    final title = _title.text.trim();
    final amount = double.tryParse(_amount.text.trim());

    // collect what's missing
    final List<String> missing = [];
    if (title.isEmpty) missing.add('Title');
    if (amount == null || amount <= 0) missing.add('Amount');
    if (_category == null) missing.add('Category');

    if (missing.isNotEmpty) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: const Color(0xFF151A28),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.redAccent.withOpacity(0.6)),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.redAccent,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'MISSING FIELDS',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 14,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          content: Text(
            'Please fill in the following:\n\n• ${missing.join('\n• ')}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.6,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'GOT IT',
                style: TextStyle(color: Colors.cyanAccent, letterSpacing: 1),
              ),
            ),
          ],
        ),
      );
      return;
    }

    final result =
        widget.existing?.copyWith(
          title: title,
          amount: amount,
          date: _date,
          category: _category,
          paymentMode: _paymentMode,
          notes: _notes.text.trim(),
        ) ??
        Expense(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title,
          amount: amount!,
          date: _date,
          category: _category ?? ExpenseCategory.other,
          paymentMode: _paymentMode,
          notes: _notes.text.trim(),
        );
    // rest of your save logic...
    Navigator.of(context).pop(result);
  }

  InputDecoration _inputDec(String label) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(
      color: Colors.grey,
      fontSize: 12,
      letterSpacing: 1,
    ),
    filled: true,
    fillColor: Colors.white.withOpacity(0.04),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
      borderRadius: BorderRadius.circular(10),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.cyanAccent),
      borderRadius: BorderRadius.circular(10),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF151A28),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: Colors.cyanAccent.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              isEdit ? 'EDIT EXPENSE' : 'ADD EXPENSE',
              style: const TextStyle(
                color: Colors.cyanAccent,
                fontSize: 14,
                letterSpacing: 3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Title
            TextField(
              controller: _title,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDec('TITLE'),
            ),
            const SizedBox(height: 12),

            // Amount + Date
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _amount,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDec('AMOUNT (₹)'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: Colors.grey,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${_date.day.toString().padLeft(2, '0')}/${_date.month.toString().padLeft(2, '0')}/${_date.year}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Category
            const Text(
              'CATEGORY',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 11,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ExpenseCategory.values.map((cat) {
                final selected = _category == cat;
                return GestureDetector(
                  onTap: () => setState(() => _category = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? cat.color.withOpacity(0.2)
                          : Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected
                            ? cat.color
                            : Colors.grey.withOpacity(0.3),
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      '${cat.emoji} ${cat.label}',
                      style: TextStyle(
                        color: selected ? cat.color : Colors.grey,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),

            // Payment mode
            const Text(
              'PAYMENT MODE',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 11,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: PaymentMode.values.map((mode) {
                final selected = _paymentMode == mode;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _paymentMode = mode),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: EdgeInsets.only(
                        right: mode != PaymentMode.values.last ? 8 : 0,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selected
                            ? Colors.cyanAccent.withOpacity(0.15)
                            : Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected
                              ? Colors.cyanAccent
                              : Colors.grey.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            mode.icon,
                            size: 18,
                            color: selected ? Colors.cyanAccent : Colors.grey,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            mode.label,
                            style: TextStyle(
                              color: selected ? Colors.cyanAccent : Colors.grey,
                              fontSize: 10,
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),

            // Notes
            TextField(
              controller: _notes,
              style: const TextStyle(color: Colors.white),
              maxLines: 2,
              decoration: _inputDec('NOTES (optional)'),
            ),
            const SizedBox(height: 20),

            // Actions
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'CANCEL',
                      style: TextStyle(color: Colors.grey, letterSpacing: 1),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyanAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      isEdit ? 'UPDATE' : 'SAVE',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
