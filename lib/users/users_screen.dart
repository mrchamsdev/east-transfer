import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/app_theme.dart';
import '../services/network_service.dart';
import '../widgets/bank_loader.dart';
import 'widgets/user_card.dart';
import 'widgets/search_bar_widget.dart';
import 'user_detail_screen.dart';
import 'add_user_screen.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => UsersScreenState();
}

class UsersScreenState extends State<UsersScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allBanks = [];
  List<Map<String, dynamic>> _filteredBanks = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchBankInfo();
    _searchController.addListener(_filterBanks);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchBankInfo() async {
    print('🔄 [USERS TAB] Fetching bank information...');
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final bankInfoURL = '${dotenv.env['API_URL']}bank/bankInfo';
      print('🌐 [USERS TAB] API URL: $bankInfoURL');
      var response = await ServiceWithHeader(bankInfoURL).data();
      print('📥 [USERS TAB] API Response received');

      if (!mounted) return;

      if (response is List && response.length >= 2) {
        int statusCode = response[0];
        dynamic responseBody = response[1];

        if (statusCode == 200 && responseBody != null) {
          print('✅ [USERS TAB] API Status: $statusCode');
          if (responseBody is Map<String, dynamic>) {
            final bankList = responseBody['bank'] as List<dynamic>?;
            if (bankList != null) {
              print('📊 [USERS TAB] Found ${bankList.length} bank records');
              if (!mounted) return;
              setState(() {
                _allBanks = bankList
                    .map((item) => item as Map<String, dynamic>)
                    .toList();
                _filteredBanks = List.from(_allBanks);
                _isLoading = false;
              });
              print('✅ [USERS TAB] Data loaded successfully');
              return;
            }
          }
        }
        print('⚠️ [USERS TAB] Unexpected response format');
      }

      print('❌ [USERS TAB] Failed to load bank information');
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load bank information';
        _isLoading = false;
      });
    } catch (e) {
      print('❌ [USERS TAB] Error: $e');
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  // Public method to refresh data when tab becomes visible
  void refreshDataIfNeeded() {
    print('🔄 [USERS TAB] Tab clicked - Triggering API refresh...');
    _fetchBankInfo();
  }

  void _filterBanks() {
    if (!mounted) return;
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) {
      setState(() {
        _filteredBanks = List.from(_allBanks);
      });
    } else {
      setState(() {
        _filteredBanks = _allBanks.where((bank) {
          final customerName = (bank['customerName'] as String? ?? '')
              .toLowerCase();
          final nickname = (bank['nickname'] as String? ?? '').toLowerCase();
          final accountNumber = (bank['accountNumber'] as String? ?? '')
              .toLowerCase();
          final bankName = (bank['bankName'] as String? ?? '').toLowerCase();

          return customerName.contains(query) ||
              nickname.contains(query) ||
              accountNumber.contains(query) ||
              bankName.contains(query);
        }).toList();
      });
    }
  }

  void _navigateToUserDetail(Map<String, dynamic> userData) {
    final bankInfoId = userData['id'] as int?;

    print('🔍 [USERS TAB] Navigating to user detail with ID: $bankInfoId');
    if (bankInfoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid bank information ID')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserDetailScreen(bankInfoId: bankInfoId),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),

      child: Row(
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Users',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Bank account information',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddUserScreen(),
                      ),
                    );
                    // Refresh the list if user was added successfully
                    if (result == true) {
                      _fetchBankInfo();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top),
          _buildHeader(),
          SearchBarWidget(
            controller: _searchController,
            onChanged: (_) => _filterBanks(),
            onSearch: () => _filterBanks(),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: RefreshLoader(color: AppTheme.primaryBlue));
    }

    if (_errorMessage != null) {
      return Center(
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
              onPressed: _fetchBankInfo,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_filteredBanks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: 64,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isEmpty
                  ? 'No users found'
                  : 'No users match your search',
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchBankInfo,
      color: AppTheme.primaryBlue,
      child: ListView.builder(
        itemCount: _filteredBanks.length,
        itemBuilder: (context, index) {
          return UserCard(
            userData: _filteredBanks[index],
            onTap: () => _navigateToUserDetail(_filteredBanks[index]),
          );
        },
      ),
    );
  }
}
