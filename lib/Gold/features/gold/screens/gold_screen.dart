import 'package:flutter/material.dart';
import 'package:bank_scan/Gold/core/constants/app_routes.dart';
import 'package:bank_scan/Gold/core/constants/app_colors.dart';
import 'package:bank_scan/Gold/core/network/gold_session.dart';
import 'package:bank_scan/Gold/core/utils/responsive_extensions.dart';
import 'package:bank_scan/Gold/core/utils/screen_utility.dart';
import 'package:bank_scan/Gold/widgets/no_access_widget.dart';
import 'package:bank_scan/Gold/features/expenses/widgets/section_header.dart';
import '../widgets/gold_record_card.dart';
import '../repository/gold_repository.dart';
import '../models/gold_purchase_model.dart';
import 'add_sale_modal.dart';

/// Global route observer — registered in main.dart's MaterialApp.
final RouteObserver<ModalRoute<void>> goldRouteObserver =
    RouteObserver<ModalRoute<void>>();

class GoldScreen extends StatefulWidget {
  const GoldScreen({super.key});

  @override
  State<GoldScreen> createState() => GoldScreenState();
}

class GoldScreenState extends State<GoldScreen> with RouteAware {
  final GoldRepository _repository = GoldRepository();
  bool _isLoading = true;
  List<GoldMonthGroup> _allPurchases = [];
  List<GoldMonthGroup> _groupedPurchases = [];

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _fetchData();
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
    super.dispose();
  }

  @override
  void didPopNext() => _fetchData();

  // ── Data ───────────────────────────────────────────────────────────────────

  void filterPurchases(String query) {
    if (query.isEmpty) {
      setState(() => _groupedPurchases = _allPurchases);
      return;
    }
    final lower = query.toLowerCase();
    final List<GoldMonthGroup> filtered = [];
    for (var group in _allPurchases) {
      final matched = group.records.where((r) {
        final party = r.partyName.toLowerCase();
        final dl = r.dlNumber.toLowerCase();
        final license = r.licenseNumber.toLowerCase();
        return party.contains(lower) ||
            dl.contains(lower) ||
            license.contains(lower);
      }).toList();
      if (matched.isNotEmpty) {
        filtered.add(GoldMonthGroup(month: group.month, records: matched));
      }
    }
    setState(() => _groupedPurchases = filtered);
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final data = await _repository.getAllGoldPurchases();
      if (mounted) {
        setState(() {
          _allPurchases = data;
          _groupedPurchases = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    ScreenUtility().init(context);

    if (!GoldSession.instance.canRead('Gold')) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: NoAccessWidget(moduleName: 'Gold'),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlue))
          : _groupedPurchases.isEmpty
              ? RefreshIndicator(
                  onRefresh: _fetchData,
                  color: AppColors.primaryBlue,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 5.h,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(5.w),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Icon(
                                    Icons.layers_outlined,
                                    size: 11.w,
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                                SizedBox(height: 3.h),
                                Text(
                                  'No records found',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.sp,
                                  ),
                                ),
                                SizedBox(height: 1.5.h),
                                Text(
                                  'Your gold transactions will appear here once recorded.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14.sp,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchData,
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                    itemCount: _calculateTotalItemCount(),
                    itemBuilder: (context, index) => _buildGroupedItem(index),
                  ),
                ),
    );
  }

  int _calculateTotalItemCount() {
    int count = 0;
    for (var group in _groupedPurchases) {
      count += 1; // Month header
      count += group.records.length;
    }
    return count;
  }

  Widget _buildGroupedItem(int targetIndex) {
    int currentIdx = 0;

    for (var group in _groupedPurchases) {
      if (currentIdx == targetIndex) {
        return SectionHeader(title: group.month);
      }
      currentIdx++;

      if (targetIndex < currentIdx + group.records.length) {
        final recordIndex = targetIndex - currentIdx;
        final item = group.records[recordIndex];

        return GestureDetector(
          onTap: () async {
            await Navigator.pushNamed(
              context,
              AppRoutes.goldDetails,
              arguments: item,
            );
          },
          child: GoldRecordCard(
            purchase: item,
            onSell: () => AddSaleModal.show(context, item),
          ),
        );
      }
      currentIdx += group.records.length;
    }

    return const SizedBox.shrink();
  }
}
