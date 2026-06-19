import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAFC),
        elevation: 0,
        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Center(
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0F000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 14),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
        title: const Text(
          'Privacy & Policy',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardBlock(
              child: const Text(
                'MilloraPay (we, our or us) is determined to ensure the privacy of its users. This Privacy Policy describes how we handle the information that you provide to us when you use the MilloraPay mobile application (the "App"). Through MilloraPay, you are accepting the practices provided in this policy.',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.6,
                  color: Color(0xFF727271),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            
            _buildSectionHeader('Information We Collect'),
            _buildCardBlock(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'a. Information You Provide',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'The information we can gather is voluntarily provided by you during your use of the app, and it includes:',
                    style: TextStyle(fontSize: 12, height: 1.5, color: Color(0xFF727271)),
                  ),
                  const SizedBox(height: 8),
                  _buildBulletPoint('Entry of business and customer details is manually done.'),
                  _buildBulletPoint('Transaction-related information'),
                  _buildBulletPoint('Images that were uploaded or photographed of documents like passbooks, cheques, PAN cards, payment slips and hand written records.'),
                  const SizedBox(height: 16),
                  const Text(
                    'b. Information that is collected automatically.',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'In order to enhance the performance and reliability of the apps, we might gather some restricted technical data like:',
                    style: TextStyle(fontSize: 12, height: 1.5, color: Color(0xFF727271)),
                  ),
                  const SizedBox(height: 8),
                  _buildBulletPoint('Type of device, operating system and app version.'),
                  _buildBulletPoint('Log information on applications use and problem.'),
                  const SizedBox(height: 12),
                  const Text(
                    'MilloraPay is not storing any redundant personal information that is not related to its main operations.',
                    style: TextStyle(fontSize: 12, height: 1.5, color: Color(0xFF727271)),
                  ),
                ],
              ),
            ),
            
            _buildSectionHeader('How We Use the Information'),
            _buildCardBlock(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Information gathered is applied with the sole purpose of:',
                    style: TextStyle(fontSize: 12, height: 1.5, color: Color(0xFF727271)),
                  ),
                  const SizedBox(height: 8),
                  _buildBulletPoint('Store transaction records, capturing, processing and storage.'),
                  _buildBulletPoint('Auto-fill transactions information on uploaded documents.'),
                  _buildBulletPoint('Prepare data in sheet ledger formats.'),
                  _buildBulletPoint('Allow one to share transaction sheets with banks or authorized personnel (it must be done by the user)'),
                  _buildBulletPoint('Enhance the performance of apps, their accuracy and user experience.'),
                  const SizedBox(height: 12),
                  const Text(
                    'We are not selling, leasing or exchanging user information to third parties.',
                    style: TextStyle(fontSize: 12, height: 1.5, color: Color(0xFF727271)),
                  ),
                ],
              ),
            ),
            
            _buildSectionHeader('Document and Image Handling'),
            _buildCardBlock(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBulletPoint('Any images of documents (e.g., passbooks, cheques, PAN cards, payment slips) uploaded by users are processed solely to extract transaction information.'),
                  _buildBulletPoint('Images are securely stored and are only accessible to the user and authorized application services for data extraction and display.'),
                  _buildBulletPoint('Users have the ability to upload, modify, or delete their document images at any time.'),
                ],
              ),
            ),
            
            _buildSectionHeader('Data Storage and Security'),
            _buildCardBlock(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'MilloraPay has rational security procedures that safeguard user information, which include:',
                    style: TextStyle(fontSize: 12, height: 1.5, color: Color(0xFF727271)),
                  ),
                  _buildSubBulletPoint('Secure storage mechanisms'),
                  _buildSubBulletPoint('Limited access to confidential data.'),
                  _buildSubBulletPoint('Periodical check-up on unauthorized access.'),
                  const SizedBox(height: 8),
                  const Text(
                    'Although we do everything to keep your information safe, no electronic system offers one hundred percent security.',
                    style: TextStyle(fontSize: 12, height: 1.5, color: Color(0xFF727271)),
                  ),
                ],
              ),
            ),
            
            _buildSectionHeader('Data Sharing and Disclosure'),
            _buildCardBlock(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'We can share information in the following situations:',
                    style: TextStyle(fontSize: 12, height: 1.5, color: Color(0xFF727271)),
                  ),
                  _buildSubBulletPoint('Upon the request by the user who wants to provide transaction sheets to banks or third parties.'),
                  _buildSubBulletPoint('When it is necessary according to the law or legal authorities.'),
                  const SizedBox(height: 8),
                  const Text(
                    'We do not sell user information to advertisers and marketers.',
                    style: TextStyle(fontSize: 12, height: 1.5, color: Color(0xFF727271)),
                  ),
                ],
              ),
            ),
            
            _buildSectionHeader('User Control and Responsibilities.'),
            _buildCardBlock(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Users are responsible for:',
                    style: TextStyle(fontSize: 12, height: 1.5, color: Color(0xFF727271)),
                  ),
                  _buildSubBulletPoint('Making sure that uploaded documents and data that is entered is accurate.'),
                  _buildSubBulletPoint('Keeping the confidentiality of their device and login credentials.'),
                  const SizedBox(height: 8),
                  const Text(
                    'Users can access, edit or control their stored transaction record in the app.',
                    style: TextStyle(fontSize: 12, height: 1.5, color: Color(0xFF727271)),
                  ),
                ],
              ),
            ),
            
            _buildSectionHeader('Account Deletion and Data Removal'),
            _buildCardBlock(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBulletPoint('Users have the right to delete their MilloraPay account at any time.'),
                  _buildBulletPoint('Account deletion can be initiated from within the app or by contacting our support team.'),
                  _buildBulletPoint('Once the account deletion request is processed, associated user data and transaction records will be permanently removed from our systems, except where retention is required by law.'),
                  _buildBulletPoint('After deletion, users will no longer have access to their stored data.'),
                  _buildBulletPoint('This action is irreversible.'),
                ],
              ),
            ),
            
            _buildSectionHeader("Children's Privacy"),
            _buildCardBlock(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBulletPoint('MilloraPay is not aimed at any consumers. It is not meant to target people who are below the age of 13. We do not gather information of minors with awareness.'),
                ],
              ),
            ),
            
            _buildSectionHeader('Changes to This Privacy Policy.'),
            _buildCardBlock(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBulletPoint('We can revise this Privacy Policy occasionally. Any updates will be displayed in the app or in the listing of the app. Further use of MilloraPay following updates will amount to acceptance of the new policy.'),
                ],
              ),
            ),
            
            _buildSectionHeader('Contact Us'),
            _buildCardBlock(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBulletPoint('You can contact us in case of any questions or concerns regarding this Privacy Policy or data practices:'),
                  _buildBulletPoint('Company Name: Millorapay'),
                  _buildBulletPoint('Email: support@msohams.com'),
                  _buildBulletPoint('By using MilloraPay, you acknowledge that you have read and understood this Privacy Policy.'),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildCardBlock({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F2F5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x03000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: child,
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF727271),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                height: 1.5,
                color: Color(0xFF727271),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '- ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF727271),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                height: 1.5,
                color: Color(0xFF727271),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
