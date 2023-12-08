import 'dart:core';

import 'package:flutter/material.dart';

enum CalendarDatePicker2Type {
  single,
  // multi,
  range,
}

typedef CalendarDayTextStylePredicate = TextStyle? Function({
  required DateTime date,
});

typedef CalendarDayBuilder = Widget? Function({
  required DateTime date,
  TextStyle? textStyle,
  BoxDecoration? decoration,
  bool? isSelected,
  bool? isDisabled,
  bool? isToday,
});

typedef CalendarYearBuilder = Widget? Function({
  required int year,
  TextStyle? textStyle,
  BoxDecoration? decoration,
  bool? isSelected,
  bool? isDisabled,
  bool? isCurrentYear,
});

typedef CalendarModePickerTextHandler = String? Function({
  required DateTime monthDate,
});

class CalendarDatePicker2Config {
  CalendarDatePicker2Config({
    DateTime? firstDate,
    DateTime? lastDate,
    DateTime? currentDate,
    DatePickerMode? calendarViewMode,

    // colors

    this.themeColor,
    this.arrowColor,
    this.currentDayBoarderColor,
    this.selectedDateBoxColor,
    this.selectedYearBoxColor,
    this.applyButtonBgColor,
    this.cancleButtonBgColor,
    this.dividerColor,
    this.cancleButtonTextColor,
    this.applyButtonTextColor,
    this.currentDateBorderColor,
    this.currentYearBgColor,

    //  styles

    this.yearNameTextStyle,
    this.weekNameTextStyle,
    this.notSelectedDataTextStyle,
    this.selectedDataTextStyle,
    this.notSelectedYearTextStyle,
    this.selectedYearTextStyle,
    this.monthNameTextStyle,

    // classes

    this.selectableDayPredicate,
    required this.calendarType,
    this.dayBuilder,
    this.modePickerTextHandler,
    this.yearBuilder,
    this.dayTextStylePredicate,

    // size

    this.controlsHeight,
    this.cancleButtonSize,
    this.applyButtonSize,
    this.spaceBetweenCalenderAndButtons,
    this.spaceBetweenButtons,
    this.calenderHeight,
    this.dateLeftRightPadding,
    this.dateTopBottomPadding,
    this.spaceBetweenYearAndCalender,
    this.calendarHorizontalPadding,

    // bool

    this.disableModePicker,
    this.displaySingleButton,

    // widget

    this.applyButtonWidget,
    this.cancleButtonWidget,
    this.singleButtonWidget,
  })  : firstDate = DateUtils.dateOnly(firstDate ?? DateTime(1970)),
        lastDate =
            DateUtils.dateOnly(lastDate ?? DateTime(DateTime.now().year + 100)),
        currentDate = currentDate ?? DateUtils.dateOnly(DateTime.now()),
        calendarViewMode = calendarViewMode ?? DatePickerMode.day;

  // datatime

  DateTime? firstDate;
  DateTime? lastDate;
  DateTime? currentDate;
  DatePickerMode? calendarViewMode;

  // color

  Color? themeColor;
  Color? arrowColor;
  Color? currentDayBoarderColor;
  Color? selectedDateBoxColor;
  Color? selectedYearBoxColor;
  Color? applyButtonBgColor;
  Color? cancleButtonBgColor;
  Color? dividerColor;
  Color? cancleButtonTextColor;
  Color? applyButtonTextColor;
  Color? currentDateBorderColor;
  Color? currentYearBgColor;

  // style

  TextStyle? yearNameTextStyle;
  TextStyle? weekNameTextStyle;
  TextStyle? notSelectedDataTextStyle;
  TextStyle? selectedDataTextStyle;
  TextStyle? notSelectedYearTextStyle;
  TextStyle? selectedYearTextStyle;
  TextStyle? monthNameTextStyle;

  // classes

  SelectableDayPredicate? selectableDayPredicate;
  CalendarDatePicker2Type? calendarType;
  CalendarDayBuilder? dayBuilder;
  CalendarModePickerTextHandler? modePickerTextHandler;
  CalendarYearBuilder? yearBuilder;
  CalendarDayTextStylePredicate? dayTextStylePredicate;

  // size

  double? controlsHeight;
  Size? cancleButtonSize;
  Size? applyButtonSize;
  double? spaceBetweenCalenderAndButtons;
  double? spaceBetweenButtons;
  double? calenderHeight;
  double? dateLeftRightPadding;
  double? dateTopBottomPadding;
  double? spaceBetweenYearAndCalender;
  double? calendarHorizontalPadding;

  // bool

  bool? disableModePicker;
  bool? displaySingleButton;

  // Widget

  Widget? applyButtonWidget;
  Widget? cancleButtonWidget;
  Widget? singleButtonWidget;
}

class CommonColor {
  static Color commonColor = const Color(0xff006C5C);
}
