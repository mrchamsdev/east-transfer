import 'package:bank_scan/Gold/core/utils/responsive_extensions.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DetailHeader extends StatelessWidget {
  final String title;
  final String amount;
  final String date;
  final String addedBy;
  final String? fileUrl;
  final String? iconUrl;

  const DetailHeader({
    super.key,
    required this.title,
    required this.amount,
    required this.date,
    required this.addedBy,
    this.fileUrl,
    this.iconUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.iconBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: iconUrl != null && iconUrl!.isNotEmpty
                ? iconUrl!.toLowerCase().endsWith('.svg')
                    ? SvgPicture.network(
                        iconUrl!.replaceAll(' ', '%20'),
                        width: 24,
                        height: 24,
                        placeholderBuilder: (context) => const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : Image.network(
                        iconUrl!.replaceAll(' ', '%20'),
                        width: 24,
                        height: 24,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.shopping_bag_outlined, color: AppColors.primaryBlue, size: 24),
                      )
                : const Icon(Icons.shopping_bag_outlined, color: AppColors.primaryBlue, size: 24),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.h2.copyWith(fontSize: 12.sp, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(
                '₹$amount',
                style: AppTextStyles.h1.copyWith(fontSize: 10.sp, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              _buildInfoText('Bill Date: $date'),
              _buildInfoText('Added by: $addedBy'),
            ],
          ),
        ),
        _buildReceiptImage(context),
      ],
    );
  }

  Widget _buildInfoText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text(
        text,
        style: AppTextStyles.infoText,
      ),
    );
  }

  Widget _buildReceiptImage(BuildContext context) {
    final hasImage = fileUrl != null && fileUrl!.isNotEmpty;
    return GestureDetector(
      onTap: hasImage
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Scaffold(
                    backgroundColor: Colors.black,
                    appBar: AppBar(
                      backgroundColor: Colors.black,
                      elevation: 0,
                      leading: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),
                      title: const Text(
                        'Receipt Preview',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      centerTitle: true,
                    ),
                    body: Center(
                      child: InteractiveViewer(
                        panEnabled: true,
                        boundaryMargin: const EdgeInsets.all(20),
                        minScale: 0.5,
                        maxScale: 4.0,
                        child: Image.network(
                          fileUrl!,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(child: CircularProgressIndicator(color: Colors.white));
                          },
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(Icons.broken_image_outlined, color: Colors.white70, size: 60),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }
          : null,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.divider,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: hasImage
              ? Image.network(
                  fileUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(Icons.broken_image_outlined, color: AppColors.iconLight, size: 40),
                  ),
                )
              : const Center(
                  child: Icon(Icons.image_outlined, color: AppColors.iconLight, size: 40),
                ),
        ),
      ),
    );
  }
}
