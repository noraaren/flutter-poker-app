import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import '../utils/validators.dart';

enum VenmoTransactionType {
  pay,
  request,
}

class VenmoService {
  /// Launches Venmo transaction (payment or request) with the specified parameters
  /// 
  /// [venmoUsername] - The Venmo username to pay or request from
  /// [amount] - The amount to pay or request
  /// [note] - The note/message for the transaction
  /// [context] - BuildContext for showing error messages
  /// [transactionType] - Whether to pay or request money (default: pay)
  /// 
  /// Returns true if Venmo was successfully launched, false otherwise
  static Future<bool> launchVenmoTransaction({
    required String venmoUsername,
    required double amount,
    required String note,
    required BuildContext context,
    VenmoTransactionType transactionType = VenmoTransactionType.pay,
  }) async {
    final transactionTypeString = transactionType == VenmoTransactionType.pay ? 'pay' : 'charge';
    
    // Try the Venmo app first
    final venmoUrl = Uri.parse(
      'venmo://paycharge?txn=$transactionTypeString'
      '&recipients=$venmoUsername'
      '&amount=${amount.toStringAsFixed(2)}'
      '&note=${Uri.encodeComponent(note)}'
    );

    // Fallback to web URL
    final webUrl = Uri.parse(
      'https://venmo.com/$venmoUsername?txn=$transactionTypeString'
      '&amount=${amount.toStringAsFixed(2)}'
      '&note=${Uri.encodeComponent(note)}'
    );

    try {
      if (await canLaunchUrl(venmoUrl)) {
        await launchUrl(venmoUrl, mode: LaunchMode.externalApplication);
        return true;
      } else if (await canLaunchUrl(webUrl)) {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
        return true;
      } else {
        // Show a snackbar to inform the user
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not launch Venmo. Please install Venmo or visit venmo.com'),
            ),
          );
        }
        return false;
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error launching Venmo: $e'),
          ),
        );
      }
      return false;
    }
  }

  /// Launches Venmo payment with the specified parameters
  /// 
  /// [venmoUsername] - The Venmo username to pay
  /// [amount] - The amount to pay
  /// [note] - The note/message for the payment
  /// [context] - BuildContext for showing error messages
  /// 
  /// Returns true if Venmo was successfully launched, false otherwise
  static Future<bool> payWithVenmo({
    required String venmoUsername,
    required double amount,
    required String note,
    required BuildContext context,
  }) async {
    return launchVenmoTransaction(
      venmoUsername: venmoUsername,
      amount: amount,
      note: note,
      context: context,
      transactionType: VenmoTransactionType.pay,
    );
  }

  /// Launches Venmo request with the specified parameters
  /// 
  /// [venmoUsername] - The Venmo username to request money from
  /// [amount] - The amount to request
  /// [note] - The note/message for the request
  /// [context] - BuildContext for showing error messages
  /// 
  /// Returns true if Venmo was successfully launched, false otherwise
  static Future<bool> requestWithVenmo({
    required String venmoUsername,
    required double amount,
    required String note,
    required BuildContext context,
  }) async {
    return launchVenmoTransaction(
      venmoUsername: venmoUsername,
      amount: amount,
      note: note,
      context: context,
      transactionType: VenmoTransactionType.request,
    );
  }

  /// Formats amount for Venmo transaction
  /// 
  /// [amount] - The amount to format
  /// Returns formatted amount string
  static String formatAmount(double amount) {
    return amount.toStringAsFixed(2);
  }
} 