// lib/steps/organisational_step.dart
import 'package:flutter/material.dart';
import '../models/cv_models.dart';

class OrganisationalStep extends StatefulWidget {
  final List<Organisation> orgList;
  final VoidCallback onListChanged;

  const OrganisationalStep({
    super.key,
    required this.orgList,
    required this.onListChanged,
  });

  @override
  State<OrganisationalStep> createState() => _OrganisationalStepState();
}

class _OrganisationalStepState extends State<OrganisationalStep> {
  String? _expandedId;

  void _addNewOrganisation() {
    final newItem = Organisation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
    );
    setState(() {
      widget.orgList.add(newItem);
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
          'Organisational Experience',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Include relevant clubs, committees, or volunteer work.',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),

        // List Organisation (Drag & Drop)
        Expanded(
          child: widget.orgList.isEmpty
              ? const Center(child: Text('No organisation added yet.'))
              : ReorderableListView.builder(
                  itemCount: widget.orgList.length,
                  onReorderItem: (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) newIndex -= 1;
                      final item = widget.orgList.removeAt(oldIndex);
                      widget.orgList.insert(newIndex, item);
                    });
                    widget.onListChanged();
                  },
                  itemBuilder: (context, index) {
                    final item = widget.orgList[index];
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

        // Tombol Add Organisation
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _addNewOrganisation,
            icon: const Icon(
              Icons.add_circle_outline,
              color: Color(0xFF2563EB),
            ),
            label: const Text(
              'Add Org Experience',
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

  Widget _buildCollapsedSummary(Organisation item) {
    return ListTile(
      leading: const Icon(Icons.drag_indicator, color: Colors.grey),
      title: Text(
        item.role.isEmpty && item.name.isEmpty
            ? 'New Organisation'
            : '${item.role} in ${item.name}',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
            onPressed: () {
              setState(() => widget.orgList.remove(item));
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

  Widget _buildExpandedForm(Organisation item) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final years = List.generate(
      30,
      (index) => (DateTime.now().year - index).toString(),
    );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                        widget.orgList.remove(item);
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

          TextFormField(
            initialValue: item.name,
            decoration: const InputDecoration(
              labelText: 'Organisation Name',
              hintText: 'e.g. BEM UMN',
              border: OutlineInputBorder(),
            ),
            onChanged: (val) {
              item.name = val;
              widget.onListChanged();
            },
          ),
          const SizedBox(height: 12),

          TextFormField(
            initialValue: item.role,
            decoration: const InputDecoration(
              labelText: 'Role / Position',
              hintText: 'e.g. Head of Documentation',
              border: OutlineInputBorder(),
            ),
            onChanged: (val) {
              item.role = val;
              widget.onListChanged();
            },
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: months.contains(item.startMonth)
                      ? item.startMonth
                      : months.first,
                  decoration: const InputDecoration(
                    labelText: 'Start Month',
                    border: OutlineInputBorder(),
                  ),
                  items: months
                      .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                      .toList(),
                  onChanged: (val) {
                    setState(() => item.startMonth = val!);
                    widget.onListChanged();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: years.contains(item.startYear)
                      ? item.startYear
                      : years.first,
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
            ],
          ),
          const SizedBox(height: 12),

          if (!item.isCurrent) ...[
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: months.contains(item.endMonth)
                        ? item.endMonth
                        : months.first,
                    decoration: const InputDecoration(
                      labelText: 'End Month',
                      border: OutlineInputBorder(),
                    ),
                    items: months
                        .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                    onChanged: (val) {
                      setState(() => item.endMonth = val!);
                      widget.onListChanged();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: years.contains(item.endYear)
                        ? item.endYear
                        : years.first,
                    decoration: const InputDecoration(
                      labelText: 'End Year',
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
          ],

          CheckboxListTile(
            title: const Text('I am currently active here'),
            value: item.isCurrent,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            onChanged: (val) {
              setState(() => item.isCurrent = val ?? false);
              widget.onListChanged();
            },
          ),
          const SizedBox(height: 8),

          TextFormField(
            initialValue: item.description,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Activity / Task Description',
              hintText:
                  'e.g. Managed documentation team; Handled media relations',
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
