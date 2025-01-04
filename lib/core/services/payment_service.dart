// lib/core/services/payment_service.dart

import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentService {
  static const String _keyId = 'YOUR_RAZORPAY_KEY';
  final Razorpay _razorpay = Razorpay();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  PaymentService() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
  }

  void dispose() {
    _razorpay.clear();
  }

  Future<void> initiatePayment({
    required String eventId,
    required String eventTitle,
    required String description,
    required double amount,
    required Function(String) onSuccess,
    required Function(String) onError,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      var options = {
        'key': _keyId,
        'amount': (amount * 100).toInt(), // Convert to paise
        'name': eventTitle,
        'description': description,
        'prefill': {
          'contact': user.phoneNumber ?? '',
          'email': user.email ?? '',
        },
        'external': {
          'wallets': ['paytm']
        }
      };

      _razorpay.open(options);

      // Store the callbacks for later use
      _paymentCallbacks = {
        'eventId': eventId,
        'onSuccess': onSuccess,
        'onError': onError,
      };
    } catch (e) {
      onError(e.toString());
    }
  }

  Map<String, dynamic> _paymentCallbacks = {};

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      // Create ticket in Firestore
      await _firestore.collection('tickets').add({
        'eventId': _paymentCallbacks['eventId'],
        'userId': user.uid,
        'paymentId': response.paymentId,
        'orderId': response.orderId,
        'signature': response.signature,
        'status': 'completed',
        'purchasedAt': FieldValue.serverTimestamp(),
      });

      // Update event attendees
      await _firestore.collection('events').doc(_paymentCallbacks['eventId']).update({
        'attendees': FieldValue.arrayUnion([user.uid])
      });

      _paymentCallbacks['onSuccess']?.call(response.paymentId!);
    } catch (e) {
      _paymentCallbacks['onError']?.call(e.toString());
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _paymentCallbacks['onError']?.call(response.message ?? 'Payment failed');
  }

  // Get user's tickets
  Stream<QuerySnapshot> getUserTickets() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    return _firestore
        .collection('tickets')
        .where('userId', isEqualTo: user.uid)
        .orderBy('purchasedAt', descending: true)
        .snapshots();
  }

  // Verify payment
  Future<bool> verifyPayment(String paymentId) async {
    try {
      final response = await _firestore
          .collection('tickets')
          .where('paymentId', isEqualTo: paymentId)
          .get();
      
      return response.docs.isNotEmpty &&
          response.docs.first.data()['status'] == 'completed';
    } catch (e) {
      return false;
    }
  }
}