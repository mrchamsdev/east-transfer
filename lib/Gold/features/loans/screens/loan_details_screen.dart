import 'package:bank_scan/Gold/core/constants/app_colors.dart';
import 'package:bank_scan/Gold/core/network/gold_session.dart';
import 'package:bank_scan/Gold/widgets/gold_dialogs.dart';
import 'package:flutter/material.dart';

import '../models/loan_models.dart';
import '../repository/loan_repository.dart';
import 'payment_update_modal.dart';
import 'edit_loan_modal.dart';
import 'additional_loan_modal.dart';
import 'add_loan_screen.dart';

class LoanDetailsScreen extends StatefulWidget {
  final int personId;
  const LoanDetailsScreen({super.key, required this.personId});

  @override
  State<LoanDetailsScreen> createState() => _LoanDetailsScreenState();
}

class _LoanDetailsScreenState extends State<LoanDetailsScreen> {
  final _repository = LoanRepository();
  bool _isLoading = true;
  PersonDetails? _details;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    setState(() => _isLoading = true);
    try {
      final details = await _repository.getPersonDetails(widget.personId);
      setState(() => _details = details);
    } catch (e) {
      // Error handling
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleDelete() async {
    if (_details == null) return;

    final confirm = await GoldDialogs.showPermissionDialog(
      context: context,
      title: 'Delete Record?',
      message: 'Are you sure you want to delete this loan record? This action cannot be undone.',
      confirmLabel: 'Delete',
      icon: Icons.delete_outline,
      iconColor: Colors.redAccent,
    );

    if (!confirm) return;

    setState(() => _isLoading = true);
    try {
      final success = await _repository.deletePerson(_details!.id);
      if (success) {
        if (mounted) {
          GoldDialogs.showSnackBar(context, 'Record deleted successfully.');
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          GoldDialogs.showSnackBar(context, 'Failed to delete record.', isError: true);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.white,
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary, size: 14),
              onPressed: () => Navigator.pop(context, true),
            ),
          ),
        ),
        title: const Text('View Details', style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          if (GoldSession.instance.canWrite('Loan')) ...[
            IconButton(
              icon: Image.asset(
                'assets/images/edit.png',
                width: 18,
                height: 18,
                fit: BoxFit.contain,
              ),
              onPressed: () async {
                if (_details != null && _details!.loans.isNotEmpty) {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddLoanScreen(
                        person: _details,
                        loan: _details!.loans.first,
                      ),
                    ),
                  );
                  if (result == true) _fetchDetails();
                }
              },
            ),
            IconButton(
              icon: Image.asset(
                'assets/images/delete.png',
                width: 18,
                height: 18,
                fit: BoxFit.contain,
              ),
              onPressed: _handleDelete,
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _details == null
              ? const Center(child: Text('No details found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPersonDetails(),
                      const SizedBox(height: 24),
                      if (_details!.loans.isNotEmpty) _buildLoanDetails(_details!.loans.first),
                      const SizedBox(height: 24),
                      if (_details!.loans.isNotEmpty && _details!.loans.first.paymentUpdates.isNotEmpty)
                        _buildPaymentHistory(_details!.loans.first.paymentUpdates),
                      const SizedBox(height: 120), // Space for buttons
                    ],
                  ),
                ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: (_details != null && GoldSession.instance.canWrite('Loan'))
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: const BoxDecoration(
                color: AppColors.scaffoldBackground,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_details != null) {
                          final result = await showModalBottomSheet<bool>(
                            context: context,
                            backgroundColor: Colors.transparent,
                            isScrollControlled: true,
                            builder: (_) => AdditionalLoanModal(personId: _details!.id),
                          );
                          if (result == true) _fetchDetails();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF003366),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        elevation: 0,
                      ),
                      child: const Text('Additional Loan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_details!.loans.isNotEmpty) {
                          final result = await showModalBottomSheet<bool>(
                            context: context,
                            backgroundColor: Colors.transparent,
                            isScrollControlled: true,
                            builder: (_) => PaymentUpdateModal(
                              personId: _details!.id,
                              loanId: _details!.loans.first.id ?? 0,
                            ),
                          );
                          if (result == true) _fetchDetails();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF003366),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        elevation: 0,
                      ),
                      child: const Text('Pay Interest', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildPersonDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Person Details', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Name', _details!.name),
              _buildDetailRow('Mobile Number', _details!.mobileNumber.startsWith('+') ? _details!.mobileNumber : '+91 ${_details!.mobileNumber}'),
              _buildDetailRow('Id Proof', _details!.idProof ?? 'Aadhaar'),
              _buildImagePlaceholder('Id Proof Upload', _details!.idProofImage),
              _buildDetailRow('Address', _details!.address ?? 'N/A'),
              _buildDetailRow('Witness Name', _details!.witnessName ?? 'N/A'),
              _buildDetailRow(
                'Witness Mobile Number',
                _details!.witnessMobileNumber != null && _details!.witnessMobileNumber!.isNotEmpty
                    ? (_details!.witnessMobileNumber!.startsWith('+') ? _details!.witnessMobileNumber! : '+91 ${_details!.witnessMobileNumber!}')
                    : 'N/A',
              ),
              _buildDetailRow('Witness Relation', _details!.witnessRelation ?? 'N/A'),
              _buildDetailRow('Witness Id Proof', _details!.witnessIdProof ?? 'Aadhaar'),
              _buildImagePlaceholder('Witness Id Proof Upload', _details!.witnessIdProofImage),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoanDetails(Loan loan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Loan Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Loan Period', '${loan.loanPeriod} ${loan.loanPeriodType == "MONTHLY" ? "Months" : loan.loanPeriodType ?? "Months"}'),
              _buildDetailRow('Loan Date', loan.loanDate ?? 'N/A'),
              _buildDetailRow('Principal Amount', '₹ ${loan.principalAmount}'),
              _buildDetailRow('Interest Rate', '${loan.interestRate}%'),
              _buildDetailRow('Interest Payment Period', '${loan.interestPaymentPeriodType == "MONTHLY" ? "Monthly" : loan.interestPaymentPeriodType ?? "Monthly"} / ${loan.interestPaymentPeriod ?? 30}'),
              _buildImagePlaceholder('Agreement Image', loan.agreementImage),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentHistory(List<PaymentUpdate> payments) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Payment History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              ...payments.map((p) => Column(
                children: [
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.paymentDate, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                          const SizedBox(height: 12),
                          const Text('Interest Amount', style: TextStyle(fontSize: 11, color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 12),
                          if (p.principalAmount > 0)
                            const Text('Principal Amount Paid', style: TextStyle(fontSize: 11, color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('₹ ${p.principalAmount + p.interestAmount}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.north_east, size: 8, color: Colors.green),
                              const SizedBox(width: 4),
                              Text('₹ ${p.interestAmount}', style: const TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (payments.last != p)
                    Divider(color: Colors.grey.shade100, height: 1),
                ],
              )),
              Divider(color: Colors.grey.shade200, height: 1),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('View more', style: TextStyle(fontSize: 11, color: AppColors.textSecondary, decoration: TextDecoration.underline)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder(String label, String? imageUrl) {
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () {
              if (hasImage) {
                _showFullScreenImage(context, label, imageUrl);
              }
            },
            child: Container(
              width: double.infinity,
              height: 140,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
              ),
              child: hasImage
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(color: AppColors.primaryBlue),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.broken_image_outlined, color: Colors.redAccent, size: 36),
                                    SizedBox(height: 8),
                                    Text('Failed to load image', style: TextStyle(fontSize: 11, color: Colors.redAccent)),
                                  ],
                                ),
                              );
                            },
                          ),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.zoom_in, color: Colors.white, size: 12),
                                  SizedBox(width: 4),
                                  Text(
                                    'Tap to view',
                                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_not_supported_outlined, color: Color(0xFF94A3B8), size: 32),
                          SizedBox(height: 8),
                          Text('No Image Uploaded', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String title, String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.9),
      builder: (context) => Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.black.withValues(alpha: 0.5),
          elevation: 0,
          title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: InteractiveViewer(
            panEnabled: true,
            minScale: 0.5,
            maxScale: 4.0,
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator(color: Colors.white));
              },
              errorBuilder: (context, error, stackTrace) {
                return const Center(child: Icon(Icons.broken_image, color: Colors.white, size: 50));
              },
            ),
          ),
        ),
      ),
    );
  }
}
