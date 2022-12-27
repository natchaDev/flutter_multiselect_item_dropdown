library multiselected_item_dropdown;

import 'package:flutter/material.dart';

const String DROP_DOWN_ITEM_ALL = 'all';

class MultiSelectedItemDropdown<T> extends StatefulWidget {
  final List<T> list;
  final String hintText;
  final Function(T) onSelectedItem;
  final T? initialValue;
  final TextStyle? hintTextStyle;
  final TextStyle? itemTextStyle;
  final Color? iconColor;
  final Color? backgroundDropdownColor;
  final Color? backgroundChipColor;
  final Color? backgroundChipTextColor;
  final bool? showAll;
  final bool showBorder;
  final bool isMultiSelected;
  final bool isShowMultiSelected;
  final List<T?>? selectedList;
  final Function(List<T?> selectedList)? onUpdateSelectedList;
  String Function(T item)? stringBuilder;

  MultiSelectedItemDropdown(
    this.list,
    this.hintText, {
    required this.onSelectedItem,
    this.initialValue,
    this.itemTextStyle,
    this.hintTextStyle,
    this.iconColor,
    this.backgroundDropdownColor = const Color(0xFFFFFFFF),
    this.backgroundChipColor = const Color(0xFFFFFFFF),
    this.backgroundChipTextColor = const Color(0xFF000000),
    this.showAll = false,
    this.showBorder = false,
    this.isMultiSelected = false,
    this.isShowMultiSelected = false,
    this.selectedList,
    this.onUpdateSelectedList,
    this.stringBuilder,
  }) {
    this.stringBuilder ??= (T item) => '$item';
  }

  @override
  _MultiSelectedItemDropdownState<T> createState() =>
      _MultiSelectedItemDropdownState<T>();
}

class _MultiSelectedItemDropdownState<T>
    extends State<MultiSelectedItemDropdown<T>> {
  List<T> _list = [];
  T? _selectedItem;
  List<T?> _selectedList = [];
  bool isUpdated = false;

  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant MultiSelectedItemDropdown<T> oldWidget) {
    _init();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _selectedList = [];
    _list = [];
    _selectedItem = null;
    super.dispose();
  }

  _init() {
    setState(() {
      _list = widget.list;
      if (widget.initialValue != null) {
        _selectedItem = widget.initialValue;
      }
      if (widget.isShowMultiSelected) {
        _selectedList = widget.selectedList ?? [];
      }
    });
  }

  _updateSelectedList(T selectedValue, {required bool isAddData}) {
    setState(() {
      bool hasData = _selectedList.firstWhere((item) {
            var selectedStr = widget.stringBuilder?.call(selectedValue);
            var itemStr = widget.stringBuilder?.call(item!);
            if (selectedStr == itemStr) return true;
            return false;
          }, orElse: () => null) !=
          null;

      if (hasData) {
        if (isAddData) return;
        _selectedList.remove(selectedValue);
        return;
      }
      _selectedList.add(selectedValue);
    });
  }

  _isSelectedAll(T value) {
    bool isString = value is String;
    if (isString) {
      return value == DROP_DOWN_ITEM_ALL;
    } else {
      var valueString = widget.stringBuilder?.call(value);
      return valueString == DROP_DOWN_ITEM_ALL;
    }
  }

  List<DropdownMenuItem<T>> _buildDropDownMenuItems(List<T> listItems) {
    List<DropdownMenuItem<T>> items = [];
    listItems.forEach(
      (value) {
        items.add(
          DropdownMenuItem(
            value: value,
            child: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                value != null ? widget.stringBuilder?.call(value) ?? '-' : '',
                textAlign: TextAlign.center,
                style: widget.itemTextStyle,
              ),
            ),
          ),
        );
      },
    );
    return items;
  }

  Widget _dropdownContent() {
    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: widget.backgroundDropdownColor,
      ),
      child: Container(
        padding: const EdgeInsets.only(top: 5, bottom: 5),
        decoration: widget.showBorder
            ? BoxDecoration(
                color: widget.backgroundDropdownColor,
                borderRadius: const BorderRadius.all(Radius.circular(8)),
              )
            : null,
        child: DropdownButtonHideUnderline(
          child: ButtonTheme(
            alignedDropdown: false,
            padding: EdgeInsets.zero,
            height: 0.0,
            child: DropdownButton<T>(
              isExpanded: true,
              hint: Container(
                margin: const EdgeInsets.only(left: 12),
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.hintText,
                  textAlign: TextAlign.left,
                  style: widget.hintTextStyle,
                ),
              ),
              selectedItemBuilder: (con) {
                return _list.map(
                  (item) {
                    return Container(
                      margin: const EdgeInsets.only(left: 12),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        item != null
                            ? widget.stringBuilder?.call(item) ?? '-'
                            : '',
                        textAlign: TextAlign.center,
                        style: widget.itemTextStyle,
                      ),
                    );
                  },
                ).toList();
              },
              icon: Container(
                alignment: Alignment.centerLeft,
                child: Icon(
                  Icons.arrow_drop_down_sharp,
                  size: 24,
                  color: widget.iconColor ?? const Color(0xFF8F8F8F),
                ),
              ),
              value: _selectedItem,
              items: _buildDropDownMenuItems(_list),
              onChanged: (T? value) {
                setState(
                  () {
                    if (value == null) return;
                    if (widget.showAll ?? false) {
                      _selectedItem = _isSelectedAll(value) ? null : value;
                    } else {
                      _selectedItem = value;
                    }

                    if (widget.isMultiSelected) {
                      _updateSelectedList(value, isAddData: true);
                      widget.onUpdateSelectedList?.call(_selectedList);
                    }

                    widget.onSelectedItem(value);
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _chipListView() {
    if (_selectedList.isBlank) return Container();
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Wrap(
        spacing: 8.0, // gap between adjacent chips
        runSpacing: 4.0, // gap between lines
        children: _selectedList.map(
          (item) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Chip(
                backgroundColor: widget.backgroundChipColor,
                label: Text(
                  widget.stringBuilder?.call(item!) ?? '-',
                  style: TextStyle(
                    color: widget.backgroundChipTextColor,
                  ),
                ),
                deleteIcon: Icon(
                  Icons.close,
                  size: 16,
                  color: widget.backgroundChipTextColor,
                ),
                onDeleted: () {
                  _updateSelectedList(item!, isAddData: false);
                  widget.onUpdateSelectedList?.call(_selectedList);
                },
              ),
            );
          },
        ).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _dropdownContent(),
        _chipListView(),
      ],
    );
  }
}
