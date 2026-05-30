import 'package:flutter/material.dart';

class CustomStepper extends StatelessWidget {
  final List<String> steps;
  final int activeStep;

  const CustomStepper({
    super.key,
    required this.steps,
    required this.activeStep,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          return Expanded(
            child: Container(
              height: 2,
              color: (index ~/ 2 < activeStep)
                  ? const Color(0xFF2563EB)
                  : Colors.grey[300],
            ),
          );
        }

        final stepIndex = index ~/ 2;
        final isActive = stepIndex == activeStep;
        final isCompleted = stepIndex < activeStep;

        return Tooltip(
          message: steps[stepIndex],
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive
                      ? const Color(0xFF2563EB)
                      : (isCompleted ? const Color(0xFFDBEAFE) : Colors.white),
                  border: Border.all(
                    color: isActive
                        ? const Color(0xFF2563EB)
                        : (isCompleted
                              ? const Color(0xFF3B82F6)
                              : Colors.grey[300]!),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(
                          Icons.check,
                          size: 18,
                          color: Color(0xFF2563EB),
                        )
                      : Text(
                          '${stepIndex + 1}',
                          style: TextStyle(
                            color: isActive ? Colors.white : Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                steps[stepIndex],
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive ? const Color(0xFF1E293B) : Colors.grey[500],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
