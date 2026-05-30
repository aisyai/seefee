import 'package:flutter/material.dart';
import '../models/cv_models.dart';
import 'package:flutter/services.dart';

class OthersStep extends StatefulWidget {
  final List<String> skillsList;
  final TextEditingController languagesController;
  final List<Achievement> achievementList;
  final VoidCallback onDataChanged;

  const OthersStep({
    super.key,
    required this.skillsList,
    required this.languagesController,
    required this.achievementList,
    required this.onDataChanged,
  });

  @override
  State<OthersStep> createState() => _OthersStepState();
}

class _OthersStepState extends State<OthersStep> {
  final _skillInputController = TextEditingController();
  String? _expandedId;

  void _addNewAchievement() {
    final newItem = Achievement(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
    );
    setState(() {
      widget.achievementList.add(newItem);
      _expandedId = newItem.id;
    });
    widget.onDataChanged();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Bungkus Column utama pakai SingleChildScrollView biar bisa di-scroll
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Skills, Languages & Achievements',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // --- SKILLS SECTION (CHIPS) ---
          const Text(
            'Key Skills',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: widget.skillsList.map((skill) {
              return Chip(
                label: Text(skill, style: const TextStyle(fontSize: 12)),
                backgroundColor: Colors.blue[50],
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () {
                  setState(() => widget.skillsList.remove(skill));
                  widget.onDataChanged();
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _skillInputController,
            decoration: InputDecoration(
              hintText:
                  'Type a skill and press Enter (e.g. Flutter, UI/UX Design)',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.add_circle, color: Colors.blue),
                onPressed: () {
                  if (_skillInputController.text.trim().isNotEmpty) {
                    setState(() {
                      widget.skillsList.add(_skillInputController.text.trim());
                      _skillInputController.clear();
                    });
                    widget.onDataChanged();
                  }
                },
              ),
            ),
            onSubmitted: (val) {
              if (val.trim().isNotEmpty) {
                setState(() {
                  widget.skillsList.add(val.trim());
                  _skillInputController.clear();
                });
                widget.onDataChanged();
              }
            },
          ),
          const SizedBox(height: 20),

          // --- LANGUAGES SECTION ---
          const Text(
            'Languages',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: widget.languagesController,
            decoration: const InputDecoration(
              hintText: 'e.g. Indonesian (Native), English (Fluent)',
              border: OutlineInputBorder(),
            ),
            onChanged: (val) => widget.onDataChanged(),
          ),
          const SizedBox(height: 24),

          // --- ACHIEVEMENTS / PROJECTS SECTION ---
          const Text(
            'Projects, Awards & Certificates',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),

          // 2. HAPUS widget Expanded di sini.
          widget.achievementList.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      'No achievements added yet.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              : ReorderableListView.builder(
                  shrinkWrap:
                      true, // 3. TAMBAHKAN INI biar ukurannya pas dengan isi
                  physics:
                      const NeverScrollableScrollPhysics(), // 4. TAMBAHKAN INI biar gak tabrakan scroll-nya
                  itemCount: widget.achievementList.length,
                  onReorderItem: (oldIndex, newIndex) {
                    // Ubah jadi onReorder (standar Flutter)
                    setState(() {
                      if (newIndex > oldIndex) newIndex -= 1;
                      final item = widget.achievementList.removeAt(oldIndex);
                      widget.achievementList.insert(newIndex, item);
                    });
                    widget.onDataChanged();
                  },
                  itemBuilder: (context, index) {
                    final item = widget.achievementList[index];
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
          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _addNewAchievement,
              icon: const Icon(
                Icons.add_circle_outline,
                color: Color(0xFF2563EB),
              ),
              label: const Text(
                'Add Achievement / Certificate',
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
      ),
    );
  }

  Widget _buildCollapsedSummary(Achievement item) {
    return ListTile(
      leading: const Icon(Icons.drag_indicator, color: Colors.grey),
      title: Text(
        item.title.isEmpty ? 'New Record' : item.title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
            onPressed: () {
              setState(() => widget.achievementList.remove(item));
              widget.onDataChanged();
            },
          ),
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down),
            onPressed: () => setState(() => _expandedId = item.id),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedForm(Achievement item) {
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
                        widget.achievementList.remove(item);
                        _expandedId = null;
                      });
                      widget.onDataChanged();
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.keyboard_arrow_up,
                      color: Colors.grey,
                    ),
                    onPressed: () => setState(() => _expandedId = null),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: item.title,
            decoration: const InputDecoration(
              labelText: 'Title / Activity Name',
              hintText: 'e.g. HCIA-openGauss Certification',
              border: OutlineInputBorder(),
            ),
            onChanged: (val) {
              item.title = val;
              widget.onDataChanged();
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: years.contains(item.year) ? item.year : years.first,
            decoration: const InputDecoration(
              labelText: 'Year',
              border: OutlineInputBorder(),
            ),
            items: years
                .map((y) => DropdownMenuItem(value: y, child: Text(y)))
                .toList(),
            onChanged: (val) {
              setState(() => item.year = val!);
              widget.onDataChanged();
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: item.description,
            maxLines: 2,
            maxLength: 200,
            inputFormatters: [
              LengthLimitingTextInputFormatter(
                200,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
              ), 
            ],
            decoration: const InputDecoration(
              labelText: 'Elaboration (Optional)',
              hintText: 'Briefly describe your role or what you achieved...',
              border: OutlineInputBorder(),
            ),
            onChanged: (val) {
              item.description = val;
              widget.onDataChanged();
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: item.link,
            decoration: const InputDecoration(
              labelText: 'Document/Certificate Link (Optional)',
              hintText: 'e.g. drive.google.com/...',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.link),
            ),
            onChanged: (val) {
              item.link = val;
              widget.onDataChanged();
            },
          ),
        ],
      ),
    );
  }
}
