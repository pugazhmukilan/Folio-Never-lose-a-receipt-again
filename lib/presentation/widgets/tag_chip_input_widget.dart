import 'package:flutter/material.dart';

/// A chip-based tag input where users can type a tag, hit Enter or comma, and it
/// appears as a chip that can be removed.
class TagChipInput extends StatefulWidget {
  final List<String> tags;
  final ValueChanged<List<String>> onChanged;
  final String? hint;

  const TagChipInput({
    super.key,
    required this.tags,
    required this.onChanged,
    this.hint = 'Add tags…',
  });

  @override
  State<TagChipInput> createState() => _TagChipInputState();
}

class _TagChipInputState extends State<TagChipInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addTag(String raw) {
    final tags = raw.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty);
    final current = List<String>.from(widget.tags);
    for (final tag in tags) {
      if (!current.contains(tag)) current.add(tag);
    }
    widget.onChanged(current);
    _controller.clear();
  }

  void _removeTag(String tag) {
    final current = List<String>.from(widget.tags)..remove(tag);
    widget.onChanged(current);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.tags.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: widget.tags
                  .map(
                    (tag) => Chip(
                      label: Text(
                        tag,
                        style: TextStyle(
                          fontSize: 13,
                          color: cs.onPrimaryContainer,
                        ),
                      ),
                      backgroundColor: cs.primaryContainer,
                      side: BorderSide.none,
                      deleteIconColor: cs.onPrimaryContainer.withValues(alpha: 0.7),
                      onDeleted: () => _removeTag(tag),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  )
                  .toList(),
            ),
          ),
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: widget.tags.isEmpty ? widget.hint : 'Add another tag…',
            suffixIcon: IconButton(
              icon: const Icon(Icons.add_rounded),
              onPressed: () => _addTag(_controller.text),
            ),
          ),
          onSubmitted: _addTag,
          onChanged: (val) {
            if (val.endsWith(',')) {
              _addTag(val.replaceAll(',', ''));
            }
          },
        ),
      ],
    );
  }
}
