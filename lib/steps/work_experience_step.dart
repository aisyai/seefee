// lib/steps/work_experience_step.dart
import 'package:flutter/material.dart';
import '../models/cv_models.dart';

class WorkExperienceStep extends StatelessWidget {
  final List<Experience> workList;
  final VoidCallback onAddExperience;
  final Function(int) onDeleteExperience;

  const WorkExperienceStep({
    super.key,
    required this.workList,
    required this.onAddExperience,
    required this.onDeleteExperience,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Work Experience',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: onAddExperience,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Experience'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: workList.isEmpty
              ? const Center(
                  child: Text(
                    'No experience added yet. Click "+ Add Experience" above.',
                  ),
                )
              : ListView.builder(
                  itemCount: workList.length,
                  itemBuilder: (context, index) {
                    final item = workList[index];
                    return Card(
                      elevation: 0,
                      color: Colors.grey[50],
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(
                          item.company,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('${item.role} (${item.duration})'),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () => onDeleteExperience(index),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
