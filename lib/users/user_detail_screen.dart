import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as path;
import '../utils/app_theme.dart';
import '../services/network_service.dart';
import '../services/excel_service.dart';
import '../widgets/bank_loader.dart';
import 'add_transaction_screen.dart';

class UserDetailScreen extends StatefulWidget {
  final int bankInfoId;

  const UserDetailScreen({super.key, required this.bankInfoId});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _bankInfo;
  List<dynamic> _bankInfoList = [];
  String? _idType;
  List<dynamic> _futureTransactions = [];
  List<dynamic> _pastTransactions = [];

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final url =
          '${dotenv.env['API_URL']}bank/userDetails/${widget.bankInfoId}';
      print('🌐 [USER DETAILS] Fetching from: $url');
      var response = await ServiceWithHeader(url).data();

      if (response is List && response.length >= 2) {
        int statusCode = response[0];
        dynamic responseBody = response[1];

        if (statusCode == 200 && responseBody != null) {
          _idType = responseBody['idType'] as String?;
          _userData = responseBody['user'] as Map<String, dynamic>?;

          // Handle bankInfo - can be either a single object or a list
          final bankInfoData = responseBody['bankInfo'];
          if (bankInfoData is List) {
            // When idType is "userId", bankInfo is a list
            _bankInfoList = bankInfoData;
            // Find the bankInfo that matches the bankInfoId
            try {
              _bankInfo =
                  bankInfoData.firstWhere(
                        (item) =>
                            (item as Map<String, dynamic>)['id'] ==
                            widget.bankInfoId,
                      )
                      as Map<String, dynamic>?;
            } catch (e) {
              // BankInfo not found in list, use first one or null
              _bankInfo = bankInfoData.isNotEmpty
                  ? bankInfoData[0] as Map<String, dynamic>?
                  : null;
            }
          } else if (bankInfoData is Map) {
            // When idType is "bankInfoId", bankInfo is a single object
            _bankInfo = bankInfoData as Map<String, dynamic>?;
            _bankInfoList = [];
          } else {
            _bankInfo = null;
            _bankInfoList = [];
          }

          setState(() {
            _futureTransactions =
                responseBody['futureTransactions'] as List<dynamic>? ?? [];
            _pastTransactions =
                responseBody['pastTransactions'] as List<dynamic>? ?? [];
            _isLoading = false;
          });
          return;
        }
      }

      setState(() {
        _errorMessage = 'Failed to load user details';
        _isLoading = false;
      });
    } catch (e) {
      print('❌ [USER DETAILS] Error: $e');
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  String get displayName {
    if (_bankInfo == null) return '';
    final customerName = _bankInfo!['customerName'] as String? ?? '';
    final nickname = _bankInfo!['nickname'] as String? ?? '';
    return customerName.isNotEmpty ? customerName : nickname;
  }

  String get initials {
    if (_bankInfo == null) return 'U';
    final customerName = _bankInfo!['customerName'] as String? ?? '';
    if (customerName.isNotEmpty) {
      final parts = customerName.trim().split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return customerName[0].toUpperCase();
    }
    final nickname = _bankInfo!['nickname'] as String? ?? '';
    if (nickname.isNotEmpty) {
      return nickname[0].toUpperCase();
    }
    return 'U';
  }

  String get firstInitial {
    if (_bankInfo == null) return 'U';
    final customerName = _bankInfo!['customerName'] as String? ?? '';
    if (customerName.isNotEmpty) {
      return customerName.trim()[0].toUpperCase();
    }
    final nickname = _bankInfo!['nickname'] as String? ?? '';
    if (nickname.isNotEmpty) {
      return nickname[0].toUpperCase();
    }
    return 'U';
  }

  String get role {
    // Check if there's a role field in bankInfo, otherwise use default
    if (_bankInfo == null) return 'Dealer';
    return _bankInfo!['role'] as String? ??
        _bankInfo!['designation'] as String? ??
        'Dealer';
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM-dd-yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String _formatDateShort(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String _getInitial(String name) {
    if (name.isEmpty) return 'U';
    return name.trim()[0].toUpperCase();
  }

  String _formatAmount(String amount) {
    try {
      final value = double.parse(amount);
      return '₹${NumberFormat('#,##0').format(value)}';
    } catch (e) {
      return '₹$amount';
    }
  }

  Future<void> _downloadExcel() async {
    if (_bankInfo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No bank information available'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryBlue),
        ),
      );

      // Generate Excel file using the service
      final filePath = await ExcelService.generateBankStatementExcel(
        customerName: displayName,
        bankInfo: _bankInfo!,
        futureTransactions: _futureTransactions,
        pastTransactions: _pastTransactions,
        entryPersonName: _userData?['name'] as String?,
      );

      // Close loading dialog
      if (mounted) {
        Navigator.pop(context);
      }

      // Get file name from path
      final fileName = path.basename(filePath);

      // Show success message and share/open file
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Excel file saved: $fileName'),
            backgroundColor: AppTheme.primaryBlue,
            action: SnackBarAction(
              label: 'Open',
              textColor: Colors.white,
              onPressed: () async {
                await OpenFilex.open(filePath);
              },
            ),
          ),
        );

        // Share the file
        await Share.shareXFiles([
          XFile(filePath),
        ], text: 'Bank Statement for $displayName');
      }
    } catch (e) {
      // Close loading dialog if still open
      if (mounted) {
        Navigator.pop(context);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating Excel: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
      print('Error generating Excel: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'User Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              'View Mode',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: AppTheme.textPrimary),
            onPressed: _downloadExcel,
            tooltip: 'Download Excel',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: RefreshLoader(color: AppTheme.primaryBlue))
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppTheme.errorColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchUserDetails,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : _buildViewMode(),
    );
  }

  Widget _buildViewMode() {
    if (_bankInfo == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_outlined,
              size: 64,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No bank information available',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please try refreshing or contact support',
              style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Details Card - Matching Image Design (Responsive)
          LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = MediaQuery.of(context).size.width;
              final isSmallScreen = screenWidth < 360;
              final isMediumScreen = screenWidth < 400;

              // Responsive sizes
              final avatarSize = isSmallScreen
                  ? 48.0
                  : (isMediumScreen ? 52.0 : 56.0);
              final avatarFontSize = isSmallScreen
                  ? 24.0
                  : (isMediumScreen ? 26.0 : 28.0);
              final nameFontSize = isSmallScreen
                  ? 20.0
                  : (isMediumScreen ? 22.0 : 24.0);
              final roleFontSize = isSmallScreen ? 12.0 : 14.0;
              final editButtonSize = isSmallScreen
                  ? 32.0
                  : (isMediumScreen ? 34.0 : 36.0);
              final editIconSize = isSmallScreen ? 18.0 : 20.0;
              final cardPadding = isSmallScreen
                  ? 16.0
                  : (isMediumScreen ? 20.0 : 24.0);
              final horizontalSpacing = isSmallScreen
                  ? 12.0
                  : (isMediumScreen ? 14.0 : 16.0);
              final verticalSpacing = isSmallScreen ? 16.0 : 20.0;
              final infoItemSpacing = isSmallScreen
                  ? 8.0
                  : (isMediumScreen ? 12.0 : 16.0);

              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF002E6E), Color(0xFF2A66B9)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.all(cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Section: Avatar, Name, Role, and Edit Button
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile Initial Avatar (White square with dark blue initial)
                        Container(
                          width: avatarSize,
                          height: avatarSize,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              firstInitial,
                              style: TextStyle(
                                fontSize: avatarFontSize,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: horizontalSpacing),
                        // Name and Role
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                style: TextStyle(
                                  fontSize: nameFontSize,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                role,
                                style: TextStyle(
                                  fontSize: roleFontSize,
                                  fontWeight: FontWeight.normal,
                                  color: const Color(0xFFB0B0B0), // Light gray
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        // Edit Button
                        // Container(
                        //   width: editButtonSize,
                        //   height: editButtonSize,
                        //   decoration: BoxDecoration(
                        //     color: const Color.fromARGB(
                        //       255,
                        //       255,
                        //       255,
                        //       255,
                        //     ).withOpacity(0.2),
                        //     borderRadius: BorderRadius.circular(8),
                        //   ),
                        //   child: IconButton(
                        //     padding: EdgeInsets.zero,
                        //     icon: Icon(
                        //       Icons.edit,
                        //       color: AppTheme.textWhite,
                        //       size: editIconSize,
                        //     ),
                        //     onPressed: () {
                        //       // TODO: Implement edit functionality
                        //     },
                        //   ),
                        // ),
                      ],
                    ),
                    SizedBox(height: verticalSpacing),
                    // Divider
                    Container(height: 1, color: Colors.white.withOpacity(0.2)),
                    SizedBox(height: verticalSpacing),
                    // Bottom Section: PAN, AC, IFSC (Horizontal Layout - Always Row)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: _buildInfoItem(
                            'PAN',
                            _bankInfo!['panNumber'] as String? ?? 'N/A',
                            isSmallScreen: isSmallScreen,
                            isMediumScreen: isMediumScreen,
                            screenWidth: screenWidth,
                          ),
                        ),
                        SizedBox(width: infoItemSpacing),
                        Expanded(
                          flex: 1,
                          child: _buildInfoItem(
                            'AC',
                            _bankInfo!['accountNumber'] as String? ?? 'N/A',
                            isSmallScreen: isSmallScreen,
                            isMediumScreen: isMediumScreen,
                            screenWidth: screenWidth,
                          ),
                        ),
                        SizedBox(width: infoItemSpacing),
                        Expanded(
                          flex: 1,
                          child: _buildInfoItem(
                            'IFSC',
                            _bankInfo!['ifscCode'] as String? ?? 'N/A',
                            isSmallScreen: isSmallScreen,
                            isMediumScreen: isMediumScreen,
                            screenWidth: screenWidth,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Future Transactions Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Future Transactions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),

              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddTransactionScreen(
                        bankInfoId: widget.bankInfoId,
                        displayName: displayName,
                        initials: initials,
                        bankInfo: _bankInfo,
                      ),
                    ),
                  ).then((result) {
                    // Refresh user details if transaction was added successfully
                    if (result == true) {
                      _fetchUserDetails();
                    }
                  });
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.primaryBlue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Add',
                  style: TextStyle(color: AppTheme.primaryBlue),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _futureTransactions.isEmpty
              ? Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'No future transactions',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _futureTransactions.length,
                  itemBuilder: (context, index) {
                    final transaction =
                        _futureTransactions[index] as Map<String, dynamic>;
                    return _buildTransactionItem(transaction, isFuture: true);
                  },
                ),

          const SizedBox(height: 24),

          // Past Transactions Section
          const Text(
            'Transactions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _pastTransactions.isEmpty
              ? Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'No transactions',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _pastTransactions.length,
                  itemBuilder: (context, index) {
                    final transaction =
                        _pastTransactions[index] as Map<String, dynamic>;
                    return _buildTransactionItem(transaction, isFuture: false);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    String label,
    String value, {
    bool isSmallScreen = false,
    bool isMediumScreen = false,
    double? screenWidth,
  }) {
    // More aggressive font size reduction for very small screens
    final isVerySmallScreen = (screenWidth ?? 400) < 320;

    final labelFontSize = isVerySmallScreen
        ? 9.0
        : (isSmallScreen ? 10.0 : (isMediumScreen ? 11.0 : 12.0));
    final valueFontSize = isVerySmallScreen
        ? 11.0
        : (isSmallScreen ? 12.0 : (isMediumScreen ? 13.0 : 16.0));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label :',
          style: TextStyle(
            fontSize: labelFontSize,
            color: const Color(0xFFB0B0B0), // Light gray
            fontWeight: FontWeight.normal,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: TextStyle(
              fontSize: valueFontSize,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.left,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(
    Map<String, dynamic> transaction, {
    required bool isFuture,
  }) {
    final amount = transaction['amountToPay'] as String? ?? '0';
    final paymentDate = transaction['paymentDate'] as String? ?? '';
    final entryPerson = _userData?['name'] as String? ?? '';
    final entryPersonInitial = _getInitial(entryPerson);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Avatar with initial (Left Section)
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.lightBlueAccent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                entryPersonInitial,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Creator Details (Middle Section)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Created by',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  entryPerson.isNotEmpty ? entryPerson : 'Unknown',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Date and Amount (Right Section)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (paymentDate.isNotEmpty)
                Text(
                  '${_formatDateShort(paymentDate)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.normal,
                  ),
                )
              else
                const SizedBox.shrink(),
              const SizedBox(height: 2),
              Text(
                _formatAmount(amount),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
