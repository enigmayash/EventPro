import 'package:flutter/material.dart';

class DynamicWidget extends StatefulWidget {
  final Function(DynamicWidget) onRemove;
  
  DynamicWidget({required this.onRemove});
  
  @override
  _DynamicWidgetState createState() => _DynamicWidgetState();
  
  Map<String, dynamic> toMap() {
    return {
      'label': _DynamicWidgetState.labelController.text,
      'type': _DynamicWidgetState.selectedType,
      'options': _DynamicWidgetState.options,
      'value': _DynamicWidgetState.valueController.text,
    };
  }
}

class _DynamicWidgetState extends State<DynamicWidget> {
  static TextEditingController labelController = TextEditingController();
  static TextEditingController valueController = TextEditingController();
  static String selectedType = 'text';
  static List<String> options = [];

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: labelController,
                    decoration: InputDecoration(
                      labelText: 'Field Label',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => widget.onRemove(widget),
                ),
              ],
            ),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedType,
              decoration: InputDecoration(
                labelText: 'Field Type',
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(value: 'text', child: Text('Text')),
                DropdownMenuItem(value: 'dropdown', child: Text('Dropdown')),
              ],
              onChanged: (value) {
                setState(() {
                  selectedType = value!;
                  if (value == 'dropdown') {
                    _showOptionsDialog();
                  }
                });
              },
            ),
            SizedBox(height: 8),
            if (selectedType == 'text')
              TextFormField(
                controller: valueController,
                decoration: InputDecoration(
                  labelText: 'Value',
                  border: OutlineInputBorder(),
                ),
              )
            else
              DropdownButtonFormField<String>(
                value: options.isNotEmpty ? options.first : null,
                decoration: InputDecoration(
                  labelText: 'Select Option',
                  border: OutlineInputBorder(),
                ),
                items: options
                    .map((option) =>
                        DropdownMenuItem(value: option, child: Text(option)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    valueController.text = value!;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showOptionsDialog() async {
    final controller = TextEditingController();
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Dropdown Options'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Option',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  setState(() {
                    options.add(controller.text);
                    controller.clear();
                  });
                }
              },
              child: Text('Add Option'),
            ),
            SizedBox(height: 8),
            ...options.map((option) => Chip(
                  label: Text(option),
                  onDeleted: () {
                    setState(() {
                      options.remove(option);
                    });
                  },
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Done'),
          ),
        ],
      ),
    );
  }
}