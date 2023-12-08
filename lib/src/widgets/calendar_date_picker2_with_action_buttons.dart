import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';

class CalendarDatePicker2WithActionButtons extends StatefulWidget {
  const CalendarDatePicker2WithActionButtons({
    required this.value,
    required this.config,
    this.onValueChanged,
    this.onDisplayedMonthChanged,
    this.onCancelTapped,
    this.onOkTapped,
    Key? key,
  }) : super(key: key);

  final List<DateTime?> value;
  final ValueChanged<List<DateTime?>>? onValueChanged;
  final ValueChanged<DateTime>? onDisplayedMonthChanged;
  final CalendarDatePicker2Config config;
  final Function? onCancelTapped;
  final Function? onOkTapped;

  @override
  State<CalendarDatePicker2WithActionButtons> createState() => CalendarDatePicker2WithActionButtonsState();
}

class CalendarDatePicker2WithActionButtonsState extends State<CalendarDatePicker2WithActionButtons> {
  List<DateTime?> values = [];
  List<DateTime?> editCache = [];

  @override
  void initState() {
    values = widget.value;
    editCache = widget.value;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant CalendarDatePicker2WithActionButtons oldWidget) {
    var isValueSame = oldWidget.value.length == widget.value.length;

    if (isValueSame) {
      for (var i = 0; i < oldWidget.value.length; i++) {
        var isSame = (oldWidget.value[i] == null && widget.value[i] == null) ||
            DateUtils.isSameDay(oldWidget.value[i], widget.value[i]);
        if (!isSame) {
          isValueSame = false;
          break;
        }
      }
    }

    if (!isValueSame) {
      values = widget.value;
      editCache = widget.value;
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CalendarDatePicker2(
          value: editCache,
          config: widget.config,
          onValueChanged: (values) => editCache = values,
          onDisplayedMonthChanged: widget.onDisplayedMonthChanged,
        ),
        SizedBox(height: widget.config.spaceBetweenCalenderAndButtons ?? 5),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: InkWell(
            onTap: () => setState(() {
              values = editCache;
              widget.onValueChanged?.call(values);
              widget.onOkTapped?.call();
              Navigator.pop(context, values);
            }),
            child: widget.config.singleButtonWidget ??
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: buildCancelButton()),
                    SizedBox(
                      width: widget.config.spaceBetweenButtons ?? 20,
                    ),
                    Expanded(child: buildOkButton()),
                  ],
                ),
          ),
        ),
      ],
    );
  }

  Widget buildCancelButton() {
    MaterialLocalizations localizations = MaterialLocalizations.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(5),
      onTap: () => setState(() {
        editCache = values;
        widget.onCancelTapped?.call();
        Navigator.pop(context);
      }),
      child: widget.config.cancleButtonWidget ??
          Container(
            height: widget.config.cancleButtonSize?.height ?? 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: widget.config.themeColor?.withOpacity(0.5) ??
                    widget.config.cancleButtonBgColor?.withOpacity(0.5) ??
                    const Color.fromRGBO(255, 231, 210, 1),
                borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: Text(
              localizations.cancelButtonLabel.toUpperCase(),
              style: TextStyle(
                color: widget.config.cancleButtonTextColor ??  CommonColor.commonColor,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ),
    );
  }

  Widget buildOkButton() {
    return InkWell(
      borderRadius: BorderRadius.circular(5),
      onTap: () => setState(() {
        values = editCache;
        widget.onValueChanged?.call(values);
        widget.onOkTapped?.call();
        Navigator.pop(context, values);
      }),
      child: widget.config.applyButtonWidget ??
          Container(
            alignment: Alignment.center,
            height: widget.config.applyButtonSize?.height ?? 50,
            decoration: BoxDecoration(
              color:
                  widget.config.themeColor ?? widget.config.applyButtonBgColor ??  CommonColor.commonColor,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: Text(
              "Apply",
              style: TextStyle(
                color: widget.config.applyButtonTextColor ?? Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ),
    );
  }
}
