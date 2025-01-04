import 'dart:io';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:event_pro/core/model/event.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';



class EventDetailsScreen extends StatefulWidget {
  final Event event;
  
  const EventDetailsScreen({Key? key, required this.event}) : super(key: key);
  
  @override
  _EventDetailsScreenState createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  final Razorpay _razorpay = Razorpay();
  Map<String, dynamic> _deviceData = {};
  Position? _currentPosition;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> _initializeData() async {
    await _getDeviceInfo();
    await _getCurrentLocation();
    setState(() => _isLoading = false);
  }

  Future<void> _getDeviceInfo() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        _deviceData = {
          'model': androidInfo.model,
          'manufacturer': androidInfo.manufacturer,
          'screenSize': '${MediaQuery.of(context).size.width.toStringAsFixed(1)} x ${MediaQuery.of(context).size.height.toStringAsFixed(1)}',
          'version': androidInfo.version.release,
        };
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        _deviceData = {
          'model': iosInfo.model,
          'manufacturer': 'Apple',
          'screenSize': '${MediaQuery.of(context).size.width.toStringAsFixed(1)} x ${MediaQuery.of(context).size.height.toStringAsFixed(1)}',
          'version': iosInfo.systemVersion,
        };
      }
    } catch (e) {
      print('Error getting device info: $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
      
      _currentPosition = await Geolocator.getCurrentPosition();
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Update ticket status in Firestore
    FirebaseFirestore.instance.collection('tickets').add({
      'eventId': widget.event.id,
      'userId': FirebaseAuth.instance.currentUser?.uid,
      'paymentId': response.paymentId,
      'amount': widget.event.price,
      'purchasedAt': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Successful!')),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Failed: ${response.message}')),
    );
  }

  void _startPayment() {
    var options = {
      'key': 'YOUR_RAZORPAY_KEY',
      'amount': widget.event.price * 100, // amount in paise
      'name': widget.event.title,
      'description': widget.event.description,
      'prefill': {
        'contact': FirebaseAuth.instance.currentUser?.phoneNumber,
        'email': FirebaseAuth.instance.currentUser?.email,
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 200,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(widget.event.title),
                    background: Image.network(
                      widget.event.bannerUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Event Details
                        Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Event Details',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                SizedBox(height: 8),
                                ListTile(
                                  leading: Icon(Icons.calendar_today),
                                  title: Text(
                                    DateFormat('EEEE, dd MMMM yyyy')
                                        .format(widget.event.date),
                                  ),
                                ),
                                ListTile(
                                  leading: Icon(Icons.access_time),
                                  title: Text(
                                    DateFormat('hh:mm a').format(widget.event.date),
                                  ),
                                ),
                                ListTile(
                                  leading: Icon(Icons.location_on),
                                  title: Text(widget.event.location),
                                ),
                                ListTile(
                                  leading: Icon(Icons.attach_money),
                                  title: Text(
                                    '₹${widget.event.price.toStringAsFixed(2)}',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 16),

                        // Device Information
                        Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Device Information',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                SizedBox(height: 8),
                                ListTile(
                                  title: Text('Model'),
                                  trailing: Text(_deviceData['model'] ?? 'N/A'),
                                ),
                                ListTile(
                                  title: Text('Manufacturer'),
                                  trailing:
                                      Text(_deviceData['manufacturer'] ?? 'N/A'),
                                ),
                                ListTile(
                                  title: Text('Screen Size'),
                                  trailing:
                                      Text(_deviceData['screenSize'] ?? 'N/A'),
                                ),
                                ListTile(
                                  title: Text('OS Version'),
                                  trailing: Text(_deviceData['version'] ?? 'N/A'),
                                ),
                                if (_currentPosition != null)
                                  ListTile(
                                    title: Text('Location'),
                                    trailing: Text(
                                      '${_currentPosition!.latitude.toStringAsFixed(2)}, ${_currentPosition!.longitude.toStringAsFixed(2)}',
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 16),

                        // Additional Fields
                        if (widget.event.additionalFields.isNotEmpty)
                          Card(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Additional Information',
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                  SizedBox(height: 8),
                                  ...widget.event.additionalFields.map((field) =>
                                      ListTile(
                                        title: Text(field['label']?? 'N/A'),
                                        trailing: Text(field['value']?? 'N/A'),
                                      )),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _startPayment,
            child: Text('Book Ticket - ₹${widget.event.price.toStringAsFixed(2)}'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ),
    );
  }
}