import 'package:artist/config/colors.dart';
import 'package:flutter/material.dart';

class CustomDropdown extends StatefulWidget {
  final dynamic items; // Supports both List<String> and Map<String, String>
  final String? initialValue;
  final Function(String selectedValue, int selectedIndex, String? selectedId)?
      onChanged;

  CustomDropdown({required this.items, this.initialValue, this.onChanged});

  @override
  _CustomDropdownState createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  String? _selectedValue;
  String? _selectedId;
  List<String> _keys = [];
  List<String> _values = [];
  // bool _firstOpen = false;

  @override
  void initState() {
    super.initState();
    _processItems();
    _selectedValue = widget.initialValue;

    // Open dropdown first time automatically
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (_firstOpen) {
    //     _toggleDropdown();
    //     _firstOpen = false;
    //   }
    // });
  }

  void _processItems() {
    if (widget.items is List<String>) {
      _keys = widget.items;
      _values = widget.items;
    } else if (widget.items is Map<String, String>) {
      _keys = (widget.items as Map<String, String>).keys.toList();
      _values = (widget.items as Map<String, String>).values.toList();
    }
  }

  void _toggleDropdown() {
    if (_overlayEntry == null) {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
    } else {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Size size = renderBox.size;
    return OverlayEntry(
      builder: (context) => Positioned(
        // width: MediaQuery.of(context).size.width * 0.9,
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          offset: Offset(0, 50),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              child: Container(
                color: Colors.white,
                constraints: BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _values.length,
                  itemBuilder: (context, index) {
                    return
                      ListTile(
                      title: Text(_values[index]),
                      onTap: () {
                        setState(() {
                          _selectedValue = _values[index];
                          _selectedId = widget.items is Map<String, String>
                              ? _keys[index]
                              : null;
                        });
                        widget.onChanged
                            ?.call(_selectedValue!, index, _selectedId);
                        _toggleDropdown();
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedValue ?? "Select",
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
              Icon(Icons.keyboard_arrow_down_outlined),
            ],
          ),
        ),
      ),
    );
  }
}
