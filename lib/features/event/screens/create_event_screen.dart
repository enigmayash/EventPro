import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:event_pro/features/event/widgets/dynamic_widget.dart';

class CreateEventScreen extends StatefulWidget {
  final bool isPublic;

  const CreateEventScreen({Key? key, required this.isPublic}) : super(key: key);

  @override
  _CreateEventScreenState createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<DynamicWidget> _dynamicWidgets = [];
  String? _selectedImage;
  bool _isLoading = false;

  // Basic event details
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _priceController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.isPublic ? 'Create Public Event' : 'Create Private Event'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image picker
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _selectedImage != null
                      ? Image.network(_selectedImage!, fit: BoxFit.cover)
                      : Center(child: Text('Tap to add event banner')),
                ),
              ),
              SizedBox(height: 16),

              // Basic details
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Event Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter event title' : null,
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter description' : null,
              ),
              SizedBox(height: 16),

              // Date & Time picker
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pickDate,
                      icon: Icon(Icons.calendar_today),
                      label: Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pickTime,
                      icon: Icon(Icons.access_time),
                      label: Text(
                        '${_selectedTime.format(context)}',
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter location' : null,
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                  prefixText: '₹',
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter price' : null,
              ),
              SizedBox(height: 24),

              // Dynamic widgets section
              Text(
                'Additional Details',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 8),

              ..._dynamicWidgets,

              ElevatedButton.icon(
                onPressed: _addDynamicWidget,
                icon: Icon(Icons.add),
                label: Text('Add Field'),
              ),
              SizedBox(height: 24),

              ElevatedButton(
                onPressed: _isLoading ? null : _createEvent,
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Create Event'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createEvent,
        child: _isLoading
            ? CircularProgressIndicator(color: Colors.white)
            : Icon(Icons.check),
        tooltip: 'Create Event',
      ),
    );
  }

  void _addDynamicWidget() {
    setState(() {
      _dynamicWidgets.add(DynamicWidget(
        onRemove: (widget) {
          setState(() {
            _dynamicWidgets.remove(widget);
          });
        },
      ));
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // Upload to Firebase Storage
      final ref = FirebaseStorage.instance
          .ref()
          .child('event_banners')
          .child('${DateTime.now()}.jpg');

      await ref.putFile(File(image.path));
      final url = await ref.getDownloadURL();

      setState(() {
        _selectedImage = url;
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _createEvent() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) throw Exception('User not logged in');

        // Combine date and time
        final eventDateTime = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        );

        // Create event document
        final docRef =
            await FirebaseFirestore.instance.collection('events').add({
          'title': _titleController.text,
          'description': _descriptionController.text,
          'date': Timestamp.fromDate(eventDateTime),
          'location': _locationController.text,
          'price': double.parse(_priceController.text),
          'creatorId': user.uid,
          'bannerUrl': _selectedImage,
          'isPublic': widget.isPublic,
          'createdAt': FieldValue.serverTimestamp(),
          'additionalFields':
              _dynamicWidgets.map((widget) => widget.toMap()).toList(),
        });

        Navigator.pop(context);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Event created successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating event: ${e.toString()}')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }
}

// lib/features/events/widgets/dynamic_widget.dart

