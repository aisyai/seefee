// lib/steps/education_step.dart
import 'package:flutter/material.dart';
import '../models/cv_models.dart';

class EducationStep extends StatefulWidget {
  final List<Education> educationList;
  final VoidCallback onListChanged;

  const EducationStep({
    super.key,
    required this.educationList,
    required this.onListChanged,
  });

  @override
  State<EducationStep> createState() => _EducationStepState();
}

class _EducationStepState extends State<EducationStep> {
  String? _expandedId;

  void _addNewEducation() {
    final newItem = Education(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
    );
    setState(() {
      widget.educationList.add(newItem);
      _expandedId = newItem.id;
    });
    widget.onListChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Education History',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Start with your highest degree or most recent education.',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),

        // List Education (Bisa di Drag & Drop)
        Expanded(
          child: widget.educationList.isEmpty
              ? const Center(child: Text('No Education added yet.'))
              : ReorderableListView.builder(
                  itemCount: widget.educationList.length,
                  onReorderItem: (oldIndex, newIndex) {
                    // Pakai onReorder (standar Flutter)
                    setState(() {
                      if (newIndex > oldIndex) newIndex -= 1;
                      final item = widget.educationList.removeAt(oldIndex);
                      widget.educationList.insert(newIndex, item);
                    });
                    widget.onListChanged();
                  },
                  itemBuilder: (context, index) {
                    final item = widget.educationList[index];
                    final isExpanded = _expandedId == item.id;

                    return Card(
                      key: ValueKey(item.id),
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                      child: isExpanded
                          ? _buildExpandedForm(item)
                          : _buildCollapsedSummary(item),
                    );
                  },
                ),
        ),

        const SizedBox(height: 16),

        // Tombol Add Education
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _addNewEducation,
            icon: const Icon(
              Icons.add_circle_outline,
              color: Color(0xFF2563EB),
            ),
            label: const Text(
              'Add Education',
              style: TextStyle(color: Color(0xFF2563EB)),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(
                color: Color(0xFF2563EB),
                style: BorderStyle.solid,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- UI saat form sedang ditutup (Collapsed) ---
  Widget _buildCollapsedSummary(Education item) {
    return ListTile(
      leading: const Icon(Icons.drag_indicator, color: Colors.grey),
      title: Text(
        item.degree.isEmpty && item.school.isEmpty
            ? 'New Education'
            : '${item.degree} at ${item.school}',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
            onPressed: () {
              setState(() => widget.educationList.remove(item));
              widget.onListChanged();
            },
          ),
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down),
            onPressed: () {
              setState(() => _expandedId = item.id);
            },
          ),
        ],
      ),
    );
  }

  // --- UI saat form sedang terbuka (Expanded) ---
  Widget _buildExpandedForm(Education item) {
    // Generate tahun dari masa depan (+5 tahun) untuk Expected Graduation
    final years = List.generate(
      30,
      (index) => (DateTime.now().year - index + 5).toString(),
    );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Expand & Control
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.drag_indicator, color: Colors.grey),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        widget.educationList.remove(item);
                        _expandedId = null;
                      });
                      widget.onListChanged();
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.keyboard_arrow_up,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() => _expandedId = null);
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // University Name
          TextFormField(
            initialValue: item.school,
            decoration: const InputDecoration(
              labelText: 'University / School Name',
              hintText: 'e.g. Universitas Multimedia Nusantara',
              border: OutlineInputBorder(),
            ),
            onChanged: (val) {
              item.school = val;
              widget.onListChanged();
            },
          ),
          const SizedBox(height: 12),

          // Degree
          TextFormField(
            initialValue: item.degree,
            decoration: const InputDecoration(
              labelText: 'Degree / Major',
              hintText: 'e.g. Bachelor of Informatics',
              border: OutlineInputBorder(),
            ),
            onChanged: (val) {
              item.degree = val;
              widget.onListChanged();
            },
          ),
          const SizedBox(height: 12),

          // Dates (Only Years for Education)
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: years.contains(item.startYear)
                      ? item.startYear
                      : '2021',
                  decoration: const InputDecoration(
                    labelText: 'Start Year',
                    border: OutlineInputBorder(),
                  ),
                  items: years
                      .map((y) => DropdownMenuItem(value: y, child: Text(y)))
                      .toList(),
                  onChanged: (val) {
                    setState(() => item.startYear = val!);
                    widget.onListChanged();
                  },
                ),
              ),
              const SizedBox(width: 8),
              if (!item.isCurrent)
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: years.contains(item.endYear) ? item.endYear : '2025',
                    decoration: const InputDecoration(
                      labelText: 'End Year (or Expected)',
                      border: OutlineInputBorder(),
                    ),
                    items: years
                        .map((y) => DropdownMenuItem(value: y, child: Text(y)))
                        .toList(),
                    onChanged: (val) {
                      setState(() => item.endYear = val!);
                      widget.onListChanged();
                    },
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Currently Studying Checkbox
          CheckboxListTile(
            title: const Text('I currently study here'),
            value: item.isCurrent,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            onChanged: (val) {
              setState(() => item.isCurrent = val ?? false);
              widget.onListChanged();
            },
          ),
          const SizedBox(height: 8),

          // Additional Info
          TextFormField(
            initialValue: item.description,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Additional Info (GPA, Awards, etc.)',
              hintText:
                  'e.g. GPA: 3.90/4.00; Received Academic Excellence Award',
              border: OutlineInputBorder(),
            ),
            onChanged: (val) {
              item.description = val;
              widget.onListChanged();
            },
          ),
        ],
      ),
    );
  }
}
