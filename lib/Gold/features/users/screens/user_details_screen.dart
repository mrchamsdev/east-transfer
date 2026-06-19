import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/gold_session.dart';
import '../../../widgets/gold_dialogs.dart';
import '../../../widgets/no_access_widget.dart';
import '../models/user_model.dart';
import '../repository/user_repository.dart';
import 'add_user_modal.dart';

class UserDetailsScreen extends StatefulWidget {
  final int userId;
  final String? userName;

  const UserDetailsScreen({
    super.key,
    required this.userId,
    this.userName,
  });

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  final _repository = UserRepository();
  User? _user;
  bool _isLoading = true;
  bool _isActioning = false;

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    setState(() => _isLoading = true);
    try {
      final user = await _repository.getUser(widget.userId);
      if (mounted) setState(() => _user = user);
    } catch (e) {
      if (mounted) GoldDialogs.showSnackBar(context, 'Failed to load user details.', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleAccountStatus() async {
    if (_user == null) return;
    final isActive = _user!.accountStatus == 'Active';
    final action = isActive ? 'Deactivate' : 'Activate';

    final confirm = await GoldDialogs.showPermissionDialog(
      context: context,
      title: '$action User?',
      message: 'Are you sure you want to $action this user?',
    );
    if (confirm != true) return;

    setState(() => _isActioning = true);
    try {
      final success = await _repository.updateAccountStatus(
        widget.userId,
        activate: !isActive,
      );
      if (success) {
        if (mounted) {
          GoldDialogs.showSnackBar(context, 'User ${action}d successfully.');
          _fetchUser();
        }
      } else {
        if (mounted) GoldDialogs.showSnackBar(context, 'Failed to $action user.', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isActioning = false);
    }
  }

  void _openEdit() async {
    if (_user == null) return;
    final result = await showDialog(
      context: context,
      builder: (context) => AddUserModal(user: _user),
    );
    if (result == true) _fetchUser();
  }

  @override
  Widget build(BuildContext context) {
    if (!GoldSession.instance.canRead('Users')) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: NoAccessWidget(moduleName: 'Users'),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.chevron_left, color: AppColors.textPrimary, size: 28),
        ),
        title: Text(
          widget.userName ?? 'User Details',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
          : _user == null
              ? const Center(child: Text('User not found.', style: TextStyle(color: AppColors.textSecondary)))
              : _buildBody(),
    );
  }

  Widget _buildBody() {
    final user = _user!;
    final isActive = user.accountStatus == 'Active';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Avatar + name card ───────────────────────────────────
          _buildProfileCard(user, isActive),
          const SizedBox(height: 20),

          // ── User Details ─────────────────────────────────────────
          _buildSection(
            title: 'User Details',
            icon: Icons.person_outline,
            child: Column(
              children: [
                _DetailRow(label: 'Name', value: [user.name, user.lastName].where((e) => e != null && e.isNotEmpty).join(' ')),
                _DetailRow(label: 'Email', value: user.email ?? '—'),
                _DetailRow(label: 'Phone', value: user.phoneNumber ?? '—'),
                _DetailRow(label: 'Gender', value: user.gender ?? '—'),
                _DetailRow(label: 'Role', value: user.role ?? '—', isLast: true),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── User Access ──────────────────────────────────────────
          if (user.userAccess.isNotEmpty) ...[
            _buildSection(
              title: 'User Access',
              icon: Icons.security_outlined,
              child: _buildAccessTable(user.userAccess),
            ),
            const SizedBox(height: 20),
          ],

          // ── Action Buttons ───────────────────────────────────────
          if (GoldSession.instance.canWrite('Users'))
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _openEdit,
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryBlue,
                      side: const BorderSide(color: AppColors.primaryBlue),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isActioning ? null : _toggleAccountStatus,
                    icon: _isActioning
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Icon(isActive ? Icons.block_outlined : Icons.check_circle_outline, size: 16),
                    label: Text(isActive ? 'Deactivate' : 'Activate'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isActive ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildProfileCard(User user, bool isActive) {
    final initials = _getInitials(user.name, user.lastName);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        
       
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: _getRoleColor(user.role).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initials,
                style: TextStyle(
                  color: _getRoleColor(user.role),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  [user.name, user.lastName].where((e) => e != null && e.isNotEmpty).join(' '),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(user.email ?? '—', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _RoleBadge(role: user.role ?? 'Unknown'),
                    const SizedBox(width: 8),
                    _StatusBadge(isActive: isActive),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required IconData icon, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      
      ),
      child: Column(
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 15, color: AppColors.primaryBlue),
                ),
                const SizedBox(width: 10),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary)),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.5, indent: 16, endIndent: 16),
          child,
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildAccessTable(List<UserAccess> access) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        children: [
          // Table header
          Row(
            children: const [
              Expanded(
                flex: 3,
                child: Text('Module', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              ),
              SizedBox(
                width: 56,
                child: Center(child: Text('Read', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary))),
              ),
              SizedBox(
                width: 56,
                child: Center(child: Text('Write', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary))),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...access.map((a) => _AccessRow(access: a)),
        ],
      ),
    );
  }

  String _getInitials(String name, String? lastName) {
    final first = name.isNotEmpty ? name[0].toUpperCase() : '';
    final last = (lastName != null && lastName.isNotEmpty) ? lastName[0].toUpperCase() : '';
    return '$first$last'.isNotEmpty ? '$first$last' : '?';
  }

  Color _getRoleColor(String? role) {
    switch (role?.toLowerCase()) {
      case 'admin': return const Color(0xFF7C3AED);
      case 'developer': return const Color(0xFF2563EB);
      case 'manager': return const Color(0xFF059669);
      default: return const Color(0xFF6B7280);
    }
  }
}

// ── Reusable sub-widgets ─────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const _DetailRow({required this.label, required this.value, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              SizedBox(
                width: 110,
                child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ),
              Expanded(
                child: Text(
                  value.isEmpty ? '—' : value,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1, thickness: 0.5, indent: 16, endIndent: 16),
      ],
    );
  }
}

class _AccessRow extends StatelessWidget {
  final UserAccess access;
  const _AccessRow({required this.access});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(access.module, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
          ),
          SizedBox(
            width: 56,
            child: Center(child: _AccessIcon(allowed: access.read)),
          ),
          SizedBox(
            width: 56,
            child: Center(child: _AccessIcon(allowed: access.write)),
          ),
        ],
      ),
    );
  }
}

class _AccessIcon extends StatelessWidget {
  final bool allowed;
  const _AccessIcon({required this.allowed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: allowed ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        allowed ? Icons.check : Icons.close,
        size: 14,
        color: allowed ? const Color(0xFF059669) : const Color(0xFFEF4444),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String role;
  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        role,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.primaryBlue),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isActive;
  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF059669) : const Color(0xFFEF4444),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            isActive ? 'Active' : 'Inactive',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isActive ? const Color(0xFF059669) : const Color(0xFFEF4444),
            ),
          ),
        ],
      ),
    );
  }
}
