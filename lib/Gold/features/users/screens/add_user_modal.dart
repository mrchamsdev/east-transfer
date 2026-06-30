import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../widgets/gold_dialogs.dart';
import '../../../widgets/gold_detail_input.dart';
import '../../../widgets/gold_back_button.dart';
import '../../../core/network/gold_session.dart';
import '../models/user_model.dart';
import '../repository/user_repository.dart';

class AddUserModal extends StatefulWidget {
  final User? user;
  const AddUserModal({super.key, this.user});

  @override
  State<AddUserModal> createState() => _AddUserModalState();
}

class _AddUserModalState extends State<AddUserModal> {
  final _repository = UserRepository();
  
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _genderController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _roleController = TextEditingController();
  
  bool _isLoading = false;

  Country _selectedCountry = Country(
    phoneCode: '91',
    countryCode: 'IN',
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: 'India',
    example: 'India',
    displayName: 'India (IN) [+91]',
    displayNameNoCountryCode: 'India (IN)',
    e164Key: '',
  );

  final List<String> _moduleNames = [
    'Gold',
    'Expenses',
    'Loan',
    'Category',
    'Users',
    'Customer'
  ];

  late List<UserAccess> _accessList;

  @override
  void initState() {
    super.initState();
    _initializeAccessList();

    if (widget.user != null) {
      _nameController.text = widget.user!.name;
      _lastNameController.text = widget.user!.lastName ?? '';
      _genderController.text = widget.user!.gender ?? '';
      _emailController.text = widget.user!.email ?? '';
      
      final phone = widget.user!.phoneNumber ?? '';
      if (phone.startsWith('+')) {
        bool found = false;
        for (int i = 4; i >= 1; i--) {
          if (phone.length > i) {
            final code = phone.substring(1, i + 1);
            try {
              final country = CountryService().getAll().firstWhere((c) => c.phoneCode == code);
              _selectedCountry = country;
              _phoneController.text = phone.substring(i + 1);
              found = true;
              break;
            } catch (_) {}
          }
        }
        if (!found) {
          _phoneController.text = phone;
        }
      } else {
        _phoneController.text = phone;
      }
      
      _roleController.text = widget.user!.role ?? '';
    }
  }

  void _initializeAccessList() {
    if (widget.user != null && widget.user!.userAccess.isNotEmpty) {
      // Map existing access
      _accessList = _moduleNames.map((modName) {
        final existing = widget.user!.userAccess.firstWhere(
          (m) => m.module == modName, 
          orElse: () => UserAccess(module: modName)
        );
        return UserAccess(module: modName, read: existing.read, write: existing.write);
      }).toList();
    } else {
      _accessList = _moduleNames.map((modName) => UserAccess(module: modName)).toList();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _genderController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_nameController.text.trim().isEmpty || _emailController.text.trim().isEmpty) return;

    setState(() => _isLoading = true);
    
    // Only include modules that have at least read or write access
    final activeModules = _accessList
        .where((a) => a.read || a.write)
        .map((a) => a.module)
        .toList();

    final user = User(
      id: widget.user?.id,
      name: _nameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      gender: _genderController.text.trim(),
      email: _emailController.text.trim(),
      phoneNumber: '+${_selectedCountry.phoneCode}${_phoneController.text.trim()}',
      role: _roleController.text.trim(),
      createdBy: widget.user == null ? (GoldSession.instance.userId ?? 1) : widget.user?.createdBy,
      modules: activeModules,
      userAccess: _accessList,
    );

    try {
      String? errorMessage;
      if (widget.user != null) {
        errorMessage = await _repository.updateUser(widget.user!.id!, user);
      } else {
        errorMessage = await _repository.createUser(user);
      }

      if (mounted) {
        if (errorMessage == null) {
          GoldDialogs.showSuccessDialog(
            context: context,
            title: 'Success',
            message: widget.user != null ? 'User updated successfully.' : 'User created successfully.',
            onOkPressed: () {
              Navigator.pop(context, true);
            },
          );
        } else {
          GoldDialogs.showErrorDialog(
            context: context,
            title: 'Action Failed',
            message: errorMessage,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        GoldDialogs.showErrorDialog(
          context: context,
          title: 'Error',
          message: e.toString(),
        );
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
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: GoldBackButton(
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.user != null ? 'Edit User' : 'Add User',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('User Details', style: AppTextStyles.h2.copyWith(fontSize: 18)),
                  const SizedBox(height: 24),
                  
                  GoldDetailInputGroup(
                    padding: EdgeInsets.zero,
                    children: [
                      GoldDetailInputField(
                        label: 'Name',  
                        controller: _nameController,
                        hint: 'Enter name',
                      ),
                      GoldDetailInputField(
                        label: 'Last Name',
                        controller: _lastNameController,
                        hint: 'Enter last name',
                      ),
                      GoldDetailInputField(
                        label: 'Gender',
                        controller: _genderController,
                        hint: 'Enter gender',
                      ),
                      GoldDetailInputField(
                        label: 'Email',
                        controller: _emailController,
                        hint: 'Enter email',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      GoldDetailInputField(
                        label: 'Country Code',
                        value: '+${_selectedCountry.phoneCode} ${_selectedCountry.flagEmoji}',
                        hint: 'Select country code',
                        onTap: () {
                          showCountryPicker(
                            context: context,
                            showPhoneCode: true,
                            onSelect: (Country country) {
                              setState(() {
                                _selectedCountry = country;
                              });
                            },
                          );
                        },
                      ),
                      GoldDetailInputField(
                        label: 'Phone Number',
                        controller: _phoneController,
                        hint: 'Enter phone number',
                        keyboardType: TextInputType.phone,
                      ),
                      GoldDetailInputField(
                        label: 'Role',
                        controller: _roleController,
                        hint: 'Enter role',
                        showBottomBorder: false,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  Text('User Access', style: AppTextStyles.h2.copyWith(fontSize: 18)),
                  const SizedBox(height: 16),
                  
                  // Access Table Header
                  Row(
                    children: [
                      Expanded(flex: 3, child: Text('Modules', style: AppTextStyles.label.copyWith(fontSize: 10, fontWeight: FontWeight.bold))),
                      Expanded(child: Center(child: Text('Read', style: AppTextStyles.label.copyWith(fontSize: 10, fontWeight: FontWeight.bold)))),
                      Expanded(child: Center(child: Text('Write', style: AppTextStyles.label.copyWith(fontSize: 10, fontWeight: FontWeight.bold)))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Access Rows
                  ...List.generate(_accessList.length, (index) {
                    final item = _accessList[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3, 
                            child: Text(item.module, style: AppTextStyles.bodyMedium.copyWith(fontSize: 12))
                          ),
                          Expanded(
                            child: Center(
                              child: SizedBox(
                                width: 20, height: 20,
                                child: Checkbox(
                                  value: item.read,
                                  activeColor: Colors.cyan,
                                  side: const BorderSide(color: Colors.cyan),
                                  onChanged: (val) {
                                    final newRead = val ?? false;
                                    final newWrite = !newRead ? false : item.write;
                                    setState(() => _accessList[index] = UserAccess(
                                      module: item.module, read: newRead, write: newWrite
                                    ));
                                  },
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: SizedBox(
                                width: 20, height: 20,
                                child: Checkbox(
                                  value: item.write,
                                  activeColor: Colors.cyan,
                                  side: const BorderSide(color: Colors.cyan),
                                  onChanged: (val) {
                                    final newWrite = val ?? false;
                                    final newRead = newWrite ? true : item.read;
                                    setState(() => _accessList[index] = UserAccess(
                                      module: item.module, read: newRead, write: newWrite
                                    ));
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          
          // Submit Button
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF003366),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('SUBMIT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
