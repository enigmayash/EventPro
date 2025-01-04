
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting the date

class EventForm extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController locationController;
  final TextEditingController priceController;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final Function(DateTime, TimeOfDay) onDateTimeChange;

  EventForm({
    Key? key,
    required this.titleController,
    required this.descriptionController,
    required this.locationController,
    required this.priceController,
    required this.selectedDate,
    required this.selectedTime,
    required this.onDateTimeChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        TextFormField(
          controller: titleController,
          decoration: InputDecoration(
            labelText: 'Event Title',
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 16),

        // Description
        TextFormField(
          controller: descriptionController,
          decoration: InputDecoration(
            labelText: 'Description',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        SizedBox(height: 16),

        // Location
        TextFormField(
          controller: locationController,
          decoration: InputDecoration(
            labelText: 'Location',
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 16),

        // Price
        TextFormField(
          controller: priceController,
          decoration: InputDecoration(
            labelText: 'Price',
            border: OutlineInputBorder(),
            prefixText: '₹',
          ),
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 16),

        // Date & Time
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _pickDate(context),
                icon: Icon(Icons.calendar_today),
                label: Text(DateFormat.yMd().format(selectedDate)),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _pickTime(context),
                icon: Icon(Icons.access_time),
                label: Text(selectedTime.format(context)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Date picker
  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null) {
      onDateTimeChange(picked, selectedTime);
    }
  }

  // Time picker
  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null) {
      onDateTimeChange(selectedDate, picked);
    }
  }
}
