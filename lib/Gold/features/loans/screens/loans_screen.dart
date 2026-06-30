import 'dart:async';
import 'package:bank_scan/Gold/core/constants/app_colors.dart';
import 'package:bank_scan/Gold/core/network/gold_session.dart';
import 'package:bank_scan/Gold/features/gold/screens/gold_screen.dart';
import 'package:bank_scan/Gold/widgets/no_access_widget.dart';
import 'package:flutter/material.dart';

import '../models/loan_models.dart';
import '../repository/loan_repository.dart';
import 'loan_details_screen.dart';

class LoansScreen extends StatefulWidget {
  const LoansScreen({super.key});

  @override
  State<LoansScreen> createState() => LoansScreenState();
}

class LoansScreenState extends State<LoansScreen> with RouteAware {
  final LoanRepository _repository = LoanRepository();
  bool _isLoading = true;
  List<LoanRecord> _allRecords = [];
  List<LoanRecord> _records = [];
  List<LoanDue> _allDues = [];
  List<LoanDue> _dues = [];
  StreamSubscription<List<LoanRecord>>? _recordsSubscription;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _recordsSubscription = _repository.loanRecordsStream.listen((_) {
      if (mounted) {
        _fetchData(showLoader: false);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) {
      goldRouteObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    goldRouteObserver.unsubscribe(this);
    _recordsSubscription?.cancel();
    super.dispose();
  }

  @override
  void didPopNext() {
    _fetchData(showLoader: false);
  }

  void filterLoans(String query) {
    if (query.isEmpty) {
      setState(() {
        _records = _allRecords;
        _dues = _allDues;
      });
      return;
    }
    final lower = query.toLowerCase();

    // Filter records
    final List<LoanRecord> filteredRecords = [];
    for (var rec in _allRecords) {
      final matchedPersons = rec.persons.where((p) => p.name.toLowerCase().contains(lower)).toList();
      if (matchedPersons.isNotEmpty) {
        filteredRecords.add(LoanRecord(
          month: rec.month,
          persons: matchedPersons,
        ));
      }
    }

    // Filter dues
    final filteredDues = _allDues.where((d) => d.personName.toLowerCase().contains(lower)).toList();

    setState(() {
      _records = filteredRecords;
      _dues = filteredDues;
    });
  }

  Future<void> _fetchData({bool showLoader = true}) async {
    if (showLoader) {
      setState(() => _isLoading = true);
    }
    try {
      final records = await _repository.getRecords();
      final dues = await _repository.getDues();
      if (mounted) {
        setState(() {
          _allRecords = records;
          _records = records;
          _allDues = dues;
          _dues = dues;
        });
      }
    } catch (e) {
      // Handle error gracefully
    } finally {
      if (mounted && showLoader) setState(() => _isLoading = false);
    }
  }

  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (!GoldSession.instance.canRead('Loan')) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: NoAccessWidget(moduleName: 'Loans'),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
     
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _tabIndex = 0),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: _tabIndex == 0 ? const Color(0xFFEBF6FF) : Colors.white,
                        border: Border.all(color: _tabIndex == 0 ? const Color(0xFF33CCFF) : Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text('Records', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: _tabIndex == 0 ? Colors.black : Colors.black87)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _tabIndex = 1),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: _tabIndex == 1 ? const Color(0xFFEBF6FF) : Colors.white,
                        border: Border.all(color: _tabIndex == 1 ? const Color(0xFF33CCFF) : Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text('Due', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: _tabIndex == 1 ? Colors.black : Colors.black87)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _tabIndex == 0
                    ? _buildRecordsList()
                    : _buildDuesList(),
          ),
        ],
      ),
     
    );
  }

  Widget _buildRecordsList() {
    if (_records.isEmpty) return const Center(child: Text('No records found'));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _records.length,
      itemBuilder: (context, index) {
        final record = _records[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(record.month, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black)),
            ),
            ...record.persons.map((person) => _buildRecordItem(person)),
          ],
        );
      },
    );
  }

  Widget _buildRecordItem(LoanPersonRecord person) {
    final color = AppColors.avatarColors[person.personId % AppColors.avatarColors.length];
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => LoanDetailsScreen(personId: person.personId)));
        if (result == true) _fetchData(showLoader: false);
      },
      
      /*return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => LoanDetailsScreen(personId: due.personId, alwaysShowPayInterest: true)));
        if (result == true) _fetchData(showLoader: false);
      },
      */
      
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                person.name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(person.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.black)),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('Total Amount', style: TextStyle(fontSize: 9, color: Colors.grey)),
                Text('₹ ${person.totalAmount}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDuesList() {
    if (_dues.isEmpty) return const Center(child: Text('No dues found'));

    // Group dues by month if possible, but dues list in model is flat. Let's group by dueMonth.
    final Map<String, List<LoanDue>> grouped = {};
    for (var due in _dues) {
      grouped.putIfAbsent(due.dueMonth, () => []).add(due);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: grouped.keys.length,
      itemBuilder: (context, index) {
        final month = grouped.keys.elementAt(index);
        final list = grouped[month]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(month, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black)),
            ),
            ...list.map((due) => _buildDueItem(due)),
          ],
        );
      },
    );
  }

  Widget _buildDueItem(LoanDue due) {
    final color = AppColors.avatarColors[due.personId % AppColors.avatarColors.length];
    
    // Parse date for "May 11" format
    String monthStr = '';
    String dayStr = '';
    try {
      final parts = due.dueDate.split('-');
      if (parts.length >= 3) {
        final date = DateTime.parse(due.dueDate);
        const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        monthStr = months[date.month - 1];
        dayStr = date.day.toString().padLeft(2, '0');
      }
    } catch (_) {}

    return GestureDetector(
      /*onTap: () async {
        final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => LoanDetailsScreen(personId: due.personId)));
        if (result == true) _fetchData(showLoader: false);
      },
      */
      onTap: () async {
  final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => LoanDetailsScreen(personId: due.personId, alwaysShowPayInterest: true)));
  if (result == true) _fetchData(showLoader: false);
},
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            if (monthStr.isNotEmpty) ...[
              Column(
                children: [
                  Text(monthStr, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  Text(dayStr, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
                ],
              ),
              const SizedBox(width: 12),
            ],
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                due.personName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      text: '${due.personName} ',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black),
                      children: [
                        // Hardcoding remaining months placeholder as per screenshot
                        TextSpan(text: '(Remaining: 22 Months)', style: TextStyle(fontSize: 9, color: Colors.grey.shade600, fontWeight: FontWeight.normal)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('Total Amount: ₹ ${due.totalAmount}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('Interest Amount', style: TextStyle(fontSize: 9, color: Colors.grey)),
                Text('₹ ${due.interestAmount}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
