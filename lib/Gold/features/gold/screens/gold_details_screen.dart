import 'package:bank_scan/Gold/core/constants/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:bank_scan/Gold/core/constants/app_colors.dart';
import 'package:bank_scan/Gold/core/constants/app_text_styles.dart';
import 'package:bank_scan/Gold/core/network/gold_session.dart';
import 'package:bank_scan/Gold/core/utils/responsive_extensions.dart';
import 'package:bank_scan/Gold/core/utils/screen_utility.dart';
import 'package:bank_scan/Gold/widgets/gold_app_bar.dart';
import 'package:bank_scan/Gold/widgets/gold_dialogs.dart';
import 'package:bank_scan/Gold/widgets/gold_back_button.dart';
import '../widgets/party_details_card.dart';
import '../widgets/billed_item_card.dart';
import '../models/gold_purchase_model.dart';
import '../repository/gold_repository.dart';
import 'add_sale_modal.dart';

class GoldDetailsScreen extends StatefulWidget {
  final GoldPurchase? purchase;
  final int? purchaseId;

  const GoldDetailsScreen({super.key, this.purchase, this.purchaseId});

  @override
  State<GoldDetailsScreen> createState() => _GoldDetailsScreenState();
}

class _GoldDetailsScreenState extends State<GoldDetailsScreen> {
  final GoldRepository _repository = GoldRepository();
  GoldPurchase? _purchase;
  bool _isLoading = false;
  String? _errorMessage;
  int? _activeItemIndex;

  @override
  void initState() {
    super.initState();
    if (widget.purchase != null) {
      _purchase = widget.purchase;
      if (_purchase?.id != null) _fetchDetails(_purchase!.id!);
    } else if (widget.purchaseId != null) {
      _fetchDetails(widget.purchaseId!);
    }
  }

  Future<void> _fetchDetails(int id) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final freshData = await _repository.getGoldPurchaseById(id);
      if (mounted) {
        if (freshData != null) {
          setState(() => _purchase = freshData);
        } else {
          setState(() => _errorMessage = 'Record details not found.');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Failed to load record details.');
        GoldDialogs.showSnackBar(context, 'Error: ${e.toString()}',
            isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleDelete() async {
    final purchase = _purchase;
    if (purchase == null || purchase.id == null) return;

    final confirm = await GoldDialogs.showPermissionDialog(
      context: context,
      title: 'Delete Record?',
      message:
          'Are you sure you want to delete this gold purchase record? This action cannot be undone.',
      confirmLabel: 'Delete',
      icon: Icons.delete_outline,
      iconColor: Colors.redAccent,
    );

    if (!confirm) return;

    setState(() => _isLoading = true);
    try {
      final success = await _repository.deleteGold(purchase.id!);
      if (success) {
        if (mounted) {
          GoldDialogs.showSnackBar(context, 'Record deleted successfully.');
          AppRoutes.pop(context, true);
        }
      } else {
        if (mounted) {
          GoldDialogs.showSnackBar(context, 'Failed to delete record.',
              isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        GoldDialogs.showSnackBar(context, 'Error: ${e.toString()}',
            isError: true);
      }
  }}

  Future<void> _handleDeleteItem(int index) async {
    final purchase = _purchase;
    if (purchase == null || purchase.id == null || purchase.items == null) return;

    final confirm = await GoldDialogs.showPermissionDialog(
      context: context,
      title: 'Delete Item?',
      message: 'Are you sure you want to delete this item? This action cannot be undone.',
      confirmLabel: 'Delete',
      icon: Icons.delete_outline,
      iconColor: Colors.redAccent,
    );

    if (!confirm) return;

    final updatedItems = List<GoldBilledItem>.from(purchase.items!)..removeAt(index);
    final totalGross = updatedItems.fold(0.0, (sum, item) => sum + item.grossWeight);
    final totalPure = updatedItems.fold(0.0, (sum, item) => sum + item.pureWeight);

    final baseAmount = purchase.amount ?? 0.0;
    final rP = double.tryParse(purchase.royaltyCifHiv ?? '0') ?? 0.0;
    final tP = double.tryParse(purchase.tra ?? '0') ?? 0.0;
    final sP = double.tryParse(purchase.svl ?? '0') ?? 0.0;
    final rTax = (baseAmount * rP) / 100;
    final tTax = (baseAmount * tP) / 100;
    final sTax = (baseAmount * sP) / 100;
    final totalTax = rTax + tTax + sTax;
    final grandTotal = baseAmount + totalTax;

    final updatedPurchase = GoldPurchase(
      id: purchase.id,
      purchaseDate: purchase.purchaseDate,
      partyName: purchase.partyName,
      partyPhoneNumber: purchase.partyPhoneNumber,
      dlNumber: purchase.dlNumber,
      licenseNumber: purchase.licenseNumber,
      status: purchase.status,
      totalGrossWeight: totalGross,
      totalPureWeight: totalPure,
      royaltyCifHiv: purchase.royaltyCifHiv,
      tra: purchase.tra,
      svl: purchase.svl,
      amount: purchase.amount,
      totalAmount: purchase.amount,
      tax: totalTax,
      grandTotal: grandTotal,
      note: purchase.note,
      items: updatedItems,
      party: purchase.party,
      saleParty: purchase.saleParty,
      saleDate: purchase.saleDate,
      saleAmount: purchase.saleAmount,
      soldOut: purchase.soldOut,
      partyId: purchase.partyId,
      salePartyId: purchase.salePartyId,
      profitLossStatus: purchase.profitLossStatus,
      profitLossAmount: purchase.profitLossAmount,
      profitAmount: purchase.profitAmount,
      lossAmount: purchase.lossAmount,
    );

    setState(() => _isLoading = true);
    try {
      final success = await _repository.updateGold(purchase.id!, updatedPurchase);
      if (success) {
        await _repository.createItems(purchase.id!, updatedItems);
        if (mounted) {
          setState(() {
            _purchase = updatedPurchase;
            _activeItemIndex = null;
          });
          GoldDialogs.showSnackBar(context, 'Billed item deleted successfully.');
        }
      } else {
        if (mounted) {
          GoldDialogs.showSnackBar(context, 'Failed to delete item.', isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        GoldDialogs.showSnackBar(context, 'Error: ${e.toString()}', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleEditItem() async {
    final purchase = _purchase;
    if (purchase == null || purchase.id == null || purchase.items == null) return;

    final result = await Navigator.pushNamed(
      context,
      AppRoutes.addGoldItem,
      arguments: List<GoldBilledItem>.from(purchase.items!),
    );

    if (result != null && result is List<GoldBilledItem>) {
      final updatedItems = result;
      final totalGross = updatedItems.fold(0.0, (sum, item) => sum + item.grossWeight);
      final totalPure = updatedItems.fold(0.0, (sum, item) => sum + item.pureWeight);

      final baseAmount = purchase.amount ?? 0.0;
      final rP = double.tryParse(purchase.royaltyCifHiv ?? '0') ?? 0.0;
      final tP = double.tryParse(purchase.tra ?? '0') ?? 0.0;
      final sP = double.tryParse(purchase.svl ?? '0') ?? 0.0;
      final rTax = (baseAmount * rP) / 100;
      final tTax = (baseAmount * tP) / 100;
      final sTax = (baseAmount * sP) / 100;
      final totalTax = rTax + tTax + sTax;
      final grandTotal = baseAmount + totalTax;

      final updatedPurchase = GoldPurchase(
        id: purchase.id,
        purchaseDate: purchase.purchaseDate,
        partyName: purchase.partyName,
        partyPhoneNumber: purchase.partyPhoneNumber,
        dlNumber: purchase.dlNumber,
        licenseNumber: purchase.licenseNumber,
        status: purchase.status,
        totalGrossWeight: totalGross,
        totalPureWeight: totalPure,
        royaltyCifHiv: purchase.royaltyCifHiv,
        tra: purchase.tra,
        svl: purchase.svl,
        amount: purchase.amount,
        totalAmount: purchase.amount,
        tax: totalTax,
        grandTotal: grandTotal,
        note: purchase.note,
        items: updatedItems,
        party: purchase.party,
        saleParty: purchase.saleParty,
        saleDate: purchase.saleDate,
        saleAmount: purchase.saleAmount,
        soldOut: purchase.soldOut,
        partyId: purchase.partyId,
        salePartyId: purchase.salePartyId,
        profitLossStatus: purchase.profitLossStatus,
        profitLossAmount: purchase.profitLossAmount,
        profitAmount: purchase.profitAmount,
        lossAmount: purchase.lossAmount,
      );

      setState(() => _isLoading = true);
      try {
        final success = await _repository.updateGold(purchase.id!, updatedPurchase);
        if (success) {
          await _repository.createItems(purchase.id!, updatedItems);
          if (mounted) {
            setState(() {
              _purchase = updatedPurchase;
              _activeItemIndex = null;
            });
            GoldDialogs.showSnackBar(context, 'Billed items updated successfully.');
          }
        } else {
          if (mounted) {
            GoldDialogs.showSnackBar(context, 'Failed to update items.', isError: true);
          }
        }
      } catch (e) {
        if (mounted) {
          GoldDialogs.showSnackBar(context, 'Error: ${e.toString()}', isError: true);
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtility().init(context);

    if (_purchase == null && _isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
            child: CircularProgressIndicator(color: AppColors.primaryBlue)),
      );
    }

    if (_purchase == null || _errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('View Details',
              style: TextStyle(
                  fontSize: 14.sp, fontWeight: FontWeight.bold)),
          elevation: 0,
          backgroundColor: Colors.white,
          leading: GoldBackButton(
            onPressed: () => AppRoutes.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 12.w, color: Colors.grey[400]),
              SizedBox(height: 2.h),
              Text(_errorMessage ?? 'No record found.',
                  style: TextStyle(
                      color: Colors.grey[600], fontSize: 14.sp)),
              SizedBox(height: 3.h),
              ElevatedButton(
                onPressed: () {
                  final id = widget.purchaseId ?? widget.purchase?.id;
                  if (id != null) _fetchDetails(id);
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final purchase = _purchase!;
    final isSold = purchase.status?.toUpperCase() == 'SALE';

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: GoldAppBar(
        showSearch: false,
        title: isSold ? 'Sale Details' : 'View Details',
        showBackButton: true,

        centerTitle: true,
        showNotification: false,
        actions: [
          if (GoldSession.instance.canWrite('Gold')) ...[
            GestureDetector(
              onTap: () async {
                if (isSold) {
                  await AddSaleModal.show(context, _purchase!);
                  if (_purchase?.id != null) {
                    _fetchDetails(_purchase!.id!);
                  }
                } else {
                  final result = await Navigator.pushNamed(
                    context,
                    AppRoutes.addGold,
                    arguments: _purchase,
                  );
                  if (result == true && _purchase?.id != null) {
                    _fetchDetails(_purchase!.id!);
                  }
                }
              },
              child: Image.asset(
                'assets/images/edit.png',
                width: 18.sp,
                height: 18.sp,
                fit: BoxFit.contain,
              ),
            ),
            if (!isSold) ...[
              SizedBox(width: 4.w),
              GestureDetector(
                onTap: _handleDelete,
                child: Image.asset(
                  'assets/images/delete.png',
                  width: 18.sp,
                  height: 18.sp,
                  fit: BoxFit.contain,
                ),
              ),
            ],
            SizedBox(width: 4.w),
          ],
        ],
      ),
      body: GestureDetector(
        onTap: () {
          if (_activeItemIndex != null) {
            setState(() => _activeItemIndex = null);
          }
        },
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(5.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isSold) ...[
                        _buildSaleInfoCard(purchase),
                        SizedBox(height: 3.h),
                        const Padding(
                          padding: EdgeInsets.only(left: 4.0),
                          child: Text(
                            'Purchase Details',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ),
                        SizedBox(height: 2.h),
                      ],
                      PartyDetailsCard(
                        purchase: purchase,
                        title: isSold ? 'Party Details' : 'Customer Details',
                      ),
                      SizedBox(height: 4.h),
                      // Billed Items Header
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                            horizontal: 5.w, vertical: 1.5.h),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryBlue.withValues(alpha: 0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          'Billed Items',
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.white,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 2.5.h),
                      if (purchase.items != null && purchase.items!.isNotEmpty)
                        Column(
                          children: purchase.items!
                              .asMap()
                              .entries
                              .map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            return BilledItemCard(
                              index: index + 1,
                              weight: item.grossWeight.toStringAsFixed(2),
                              side1: item.side1.toStringAsFixed(2),
                              side2: item.side2.toStringAsFixed(2),
                              average:
                                  item.averagePercentage.toStringAsFixed(2),
                              pureWeight: item.pureWeight.toStringAsFixed(2),
                              showActions: _activeItemIndex == index,
                              onTap: () {
                                if (_activeItemIndex != null) {
                                  setState(() => _activeItemIndex = null);
                                }
                              },
                              onLongPress: () {
                                setState(() => _activeItemIndex = index);
                              },
                              onDelete: () => _handleDeleteItem(index),
                              onEdit: () => _handleEditItem(),
                            );
                          }).toList(),
                        )
                      else if (!_isLoading)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 2.5.h),
                          child: const Center(
                              child: Text('No items found.')),
                        ),

                      SizedBox(height: 2.h),
                      _SummaryRow(
                          label: 'Total Gross Weight',
                          value: purchase.totalGrossWeight
                                  ?.toStringAsFixed(2) ??
                              '0.00'),
                      _SummaryRow(
                          label: 'Total Pure Weight',
                          value: purchase.totalPureWeight
                                  ?.toStringAsFixed(2) ??
                              '0.00'),

                      SizedBox(height: 4.h),
                      _buildFinancialsCard(purchase),
                      SizedBox(height: 3.h),
                      _buildFinalSummary(purchase),
                    ],
                  ),
                ),
              ),
              _buildBottomButton(context, purchase),
            ],
          ),
          if (_isLoading && _purchase != null)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                color: AppColors.primaryBlue,
                backgroundColor: Colors.transparent,
              ),
            ),
        ],
      ),
    ),
  );
}

  String _formatIndianCurrency(double amount) {
    String str = amount.toStringAsFixed(0);
    if (str.length <= 3) return str;
    String lastThree = str.substring(str.length - 3);
    String other = str.substring(0, str.length - 3);
    String result = '';
    int count = 0;
    for (int i = other.length - 1; i >= 0; i--) {
      result = other[i] + result;
      count++;
      if (count == 2 && i != 0) {
        result = ',$result';
        count = 0;
      }
    }
    return '$result,$lastThree';
  }

  String _formatDisplayDate(String dateStr) {
    try {
      final parsed = DateTime.tryParse(dateStr);
      if (parsed == null) return dateStr;
      const months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      return '${parsed.day} ${months[parsed.month - 1]} ${parsed.year}';
    } catch (_) {
      return dateStr;
    }
  }

  Widget _buildSaleInfoCard(GoldPurchase purchase) {
    String buyerName = '---';
    String buyerPhone = '---';
    String buyerDl = '---';
    final note = purchase.note ?? '';
    if (note.startsWith('Sold to:')) {
      final content = note.replaceFirst('Sold to:', '').trim();
      final dlParts = content.split('| DL:');
      if (dlParts.length > 1) {
        buyerDl = dlParts[1].trim();
      }
      final mainPart = dlParts[0].trim();
      final phoneMatch = RegExp(r'\(([^)]+)\)$').firstMatch(mainPart);
      if (phoneMatch != null) {
        buyerPhone = phoneMatch.group(1) ?? '---';
        buyerName = mainPart.substring(0, mainPart.lastIndexOf('(')).trim();
      } else {
        buyerName = mainPart;
      }
    }

    if (buyerDl == '---' || buyerDl.isEmpty) {
      buyerDl = purchase.dlNumber;
    }

    final isLoss = purchase.profitLossStatus?.toUpperCase() == 'LOSS';
    final isProfit = purchase.profitLossStatus?.toUpperCase() == 'PROFIT';
    final profitLossAmt = purchase.profitLossAmount ?? 0.0;

    final profitStr = isProfit
        ? 'Profit - ${_formatIndianCurrency(profitLossAmt)}'
        : isLoss
            ? 'Loss - ${_formatIndianCurrency(profitLossAmt)}'
            : 'Pending';

    final plColor = isProfit
        ? const Color(0xFF10B981)
        : isLoss
            ? Colors.red
            : AppColors.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Sold Out Details',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              Text(
                profitStr,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: plColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _SaleDetailRow(
                label: 'Date',
                value: purchase.saleDate != null ? _formatDisplayDate(purchase.saleDate!) : '---',
              ),
              const SizedBox(height: 12),
              _SaleDetailRow(
                label: 'Customer Name',
                value: buyerName,
              ),
              const SizedBox(height: 12),
              _SaleDetailRow(
                label: 'Ph No',
                value: buyerPhone,
              ),
              const SizedBox(height: 12),
              _SaleDetailRow(
                label: 'DL Number',
                value: buyerDl,
              ),
              const SizedBox(height: 12),
              _SaleDetailRow(
                label: 'Amount',
                value: purchase.saleAmount != null ? '₹ ${_formatIndianCurrency(purchase.saleAmount!)}' : '₹ 0',
                valueBold: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialsCard(GoldPurchase purchase) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _FinancialRow(
            label: 'Amount',
            value: purchase.amount?.toStringAsFixed(2) ?? '0.00',
          ),
          SizedBox(height: 1.5.h),
          _FinancialRow(
            label: 'Royalty CIF / HIV',
            value: purchase.royaltyCifHiv ?? '0.00',
          ),
          SizedBox(height: 1.5.h),
          _FinancialRow(
            label: 'TRA',
            value: purchase.tra ?? '0.00',
          ),
          SizedBox(height: 1.5.h),
          _FinancialRow(
            label: 'SVL',
            value: purchase.svl ?? '0.00',
          ),
        ],
      ),
    );
  }

  Widget _buildFinalSummary(GoldPurchase purchase) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Column(
        children: [
          _FinancialRow(
              label: 'Amount',
              value:
                  purchase.totalAmount?.toStringAsFixed(2) ?? '0.00'),
          SizedBox(height: 1.5.h),
          _FinancialRow(
              label: 'Tax',
              value: purchase.tax?.toStringAsFixed(2) ?? '0.00'),
          SizedBox(height: 2.h),
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: 4.w, vertical: 1.8.h),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Amount',
                    style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue)),
                Text(
                  purchase.grandTotal?.toStringAsFixed(2) ?? '0.00',
                  style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context, GoldPurchase purchase) {
    if (purchase.status == 'SALE' ||
        !GoldSession.instance.canWrite('Gold')) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      height: 7.h,
      child: ElevatedButton(
        onPressed: () async {
          final result = await AddSaleModal.show(context, purchase);
          if (result == true && purchase.id != null) {
            _fetchDetails(purchase.id!);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2.r)),
          elevation: 0,
        ),
        child: Text('Add Sale',
            style: AppTextStyles.label.copyWith(color: AppColors.white)),
      ),
    );
  }
}

// ─── _SummaryRow ──────────────────────────────────────────────────────────────
class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── _FinancialRow ────────────────────────────────────────────────────────────
class _FinancialRow extends StatelessWidget {
  final String label;
  final String value;

  const _FinancialRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF64748B),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }
}

// ─── _SaleDetailRow ───────────────────────────────────────────────────────────
class _SaleDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool valueBold;

  const _SaleDetailRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.valueBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF64748B),
          ),
        ),
        Text(
          value.isEmpty ? '---' : value,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: valueBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }
}
