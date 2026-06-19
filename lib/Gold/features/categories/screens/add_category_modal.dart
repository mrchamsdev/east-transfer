import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../widgets/gold_detail_input.dart';
import '../models/category_model.dart';
import '../repository/category_repository.dart';

class AddCategoryModal extends StatefulWidget {
  final ExpenseCategory? category;
  const AddCategoryModal({super.key, this.category});

  @override
  State<AddCategoryModal> createState() => _AddCategoryModalState();
}

class _AddCategoryModalState extends State<AddCategoryModal> {
  final _nameController = TextEditingController();
  final _repository = CategoryRepository();
  bool _isLoading = false;
  String? _selectedFilePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedFilePath = image.path;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (_nameController.text.trim().isEmpty) return;

    setState(() => _isLoading = true);
    try {
      bool success;
      if (widget.category != null) {
        success = await _repository.updateCategory(
          widget.category!.id!,
          ExpenseCategory(name: _nameController.text.trim()),
          filePath: _selectedFilePath,
        );
      } else {
        success = await _repository.createCategory(
          ExpenseCategory(name: _nameController.text.trim()),
          filePath: _selectedFilePath,
        );
      }

      if (success && mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      // Error handled in repo
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.category == null ? 'Add Categories' : 'Edit Category',
                  style: AppTextStyles.h2.copyWith(fontSize: 20),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppColors.textPrimary),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 32),
            GoldDetailInputGroup(
              padding: EdgeInsets.zero,
              children: [
                GoldDetailInputField(
                  label: 'Category Name',
                  controller: _nameController,
                  hint: 'Enter here',
                ),
                GoldDetailInputField(
                  label: 'Category Upload',
                  value: _selectedFilePath?.split('/').last,
                  hint: 'No file chosen',
                  onTap: _pickImage,
                  showBottomBorder: false,
                ),
              ],
            ),
            const SizedBox(height: 40),
            SizedBox(
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
          ],
        ),
      ),
    );
  }
}
