import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/gold_purchase_model.dart';

class PartyDetailsCard extends StatelessWidget {
  final GoldPurchase purchase;
  final String title;

  const PartyDetailsCard({
    super.key,
    required this.purchase,
    this.title = 'Customer Details',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B), // Modern slate dark color
            ),
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
                color: const Color(0xFF0F172A).withOpacity(0.03),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _DetailRow(label: 'Purchase Date', value: purchase.purchaseDate),
              const SizedBox(height: 12),
              _DetailRow(label: 'Customer Name', value: purchase.partyName),
              const SizedBox(height: 12),
              _DetailRow(label: 'Ph No', value: purchase.partyPhoneNumber),
              const SizedBox(height: 12),
              _DetailRow(label: 'LIC No', value: purchase.licenseNumber),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF64748B), // Sleek Slate-500
          ),
        ),
        Text(
          value.isEmpty ? '---' : value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B), // Bold Slate-800
          ),
        ),
      ],
    );
  }
}
