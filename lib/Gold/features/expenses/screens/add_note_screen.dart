import 'package:bank_scan/Gold/widgets/gold_app_bar.dart';
import 'package:bank_scan/Gold/widgets/gold_dialogs.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_extensions.dart';
import '../../../core/utils/screen_utility.dart';

class AddNoteScreen extends StatefulWidget {
  final Map<String, String>? initialData;

  const AddNoteScreen({super.key, this.initialData});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _noteController =
        TextEditingController(text: widget.initialData?['note'] ?? '');
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _handleSave() {
    final note = _noteController.text.trim();
    if (note.isEmpty) {
      GoldDialogs.showSnackBar(context, 'Please enter a note', isError: true);
      return;
    }
    Navigator.pop(context, {'note': note});
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtility().init(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: GoldAppBar(
          showSearch: false,
          title: 'Add Details',
          showBackButton: true,
          centerTitle: true,
          showNotification: false,
          actions: [
            IconButton(
              onPressed: _handleSave,
              icon: Icon(Icons.check, color: AppColors.textPrimary, size: 28.sp),
            ),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 5.w,
            vertical: 3.h,
          ),
          child: TextField(
            controller: _noteController,
            maxLines: 4,
            autofocus: true,
            style: TextStyle(
              fontSize: 15.sp,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
              height: 1.6,
            ),
            decoration: InputDecoration(
              hintText: 'Write a note...',
              hintStyle: TextStyle(
                color: AppColors.textHint,
                fontSize: 15.sp,
              ),
              filled: true,
              fillColor: const Color(0xFFF8F9FB),
              contentPadding: EdgeInsets.all(4.w),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ScreenUtility.radiusMedium.r),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ScreenUtility.radiusMedium.r),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ScreenUtility.radiusMedium.r),
                borderSide:
                    const BorderSide(color: AppColors.primaryBlue, width: 1.5),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
