// path: apps/mobile/lib/presentation/widgets/mpesa_payment_modal.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/phone_number_formatter.dart';

class MpesaPaymentModal extends StatefulWidget {
  final double amount; // in KES
  final String initialPhoneNumber;
  final Function(String phoneNumber) onInitiatePayment;

  const MpesaPaymentModal({
    super.key,
    required this.amount,
    required this.initialPhoneNumber,
    required this.onInitiatePayment,
  });

  static Future<void> show(
    BuildContext context, {
    required double amount,
    required String initialPhoneNumber,
    required Function(String phoneNumber) onInitiatePayment,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => MpesaPaymentModal(
        amount: amount,
        initialPhoneNumber: initialPhoneNumber,
        onInitiatePayment: onInitiatePayment,
      ),
    );
  }

  @override
  State<MpesaPaymentModal> createState() => _MpesaPaymentModalState();
}

class _MpesaPaymentModalState extends State<MpesaPaymentModal> {
  late TextEditingController _phoneController;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.initialPhoneNumber);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    final rawPhone = _phoneController.text.trim();
    if (!PhoneNumberFormatter.isValidKenyanMobile(rawPhone)) {
      setState(() {
        _errorMessage = 'Please enter a valid Kenyan phone number (e.g., 0712 345 678)';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    widget.onInitiatePayment(rawPhone);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.account_balance_wallet, color: Colors.green, size: 28),
                  SizedBox(width: 8),
                  Text(
                    'Lipa na M-PESA',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Consultation Fee:',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                Text(
                  'KES ${widget.amount.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Safaricom M-Pesa Phone Number',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: '0712 345 678',
              prefixIcon: const Icon(Icons.phone_android, color: AppColors.primaryTeal),
              errorText: _errorMessage,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.send_rounded),
              label: Text(
                _isSubmitting ? 'Sending STK Push...' : 'Send STK Push Request',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
