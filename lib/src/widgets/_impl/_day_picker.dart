part of '../calendar_date_picker2.dart';

class _DayPicker extends StatefulWidget {
  const _DayPicker({
    required this.config,
    required this.displayedMonth,
    required this.selectedDates,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  final CalendarDatePicker2Config config;

  final List<DateTime> selectedDates;

  final ValueChanged<DateTime> onChanged;

  final DateTime displayedMonth;

  @override
  _DayPickerState createState() => _DayPickerState();
}

class _DayPickerState extends State<_DayPicker> {
  late List<FocusNode> _dayFocusNodes;

  Color defaultTextColor = CommonColor.commonColor;

  @override
  void initState() {
    super.initState();
    final int daysInMonth = DateUtils.getDaysInMonth(
        widget.displayedMonth.year, widget.displayedMonth.month);
    _dayFocusNodes = List<FocusNode>.generate(
      daysInMonth,
      (int index) =>
          FocusNode(skipTraversal: true, debugLabel: 'Day ${index + 1}'),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final DateTime? focusedDate = _FocusedDate.maybeOf(context);
    if (focusedDate != null &&
        DateUtils.isSameMonth(widget.displayedMonth, focusedDate)) {
      _dayFocusNodes[focusedDate.day - 1].requestFocus();
    }
  }

  @override
  void dispose() {
    for (final FocusNode node in _dayFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  List<Widget> _dayHeaders(
      TextStyle? headerStyle, MaterialLocalizations localizations) {
    final List<Widget> result = <Widget>[];
    final weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
    final firstDayOfWeek = localizations.firstDayOfWeekIndex;
    assert(firstDayOfWeek >= 0 && firstDayOfWeek <= 6,
        'firstDayOfWeek must between 0 and 6');
    for (int i = firstDayOfWeek; true; i = (i + 1) % 7) {
      final String weekday = weekdays[i];
      result.add(
        Container(
          alignment: Alignment.center,
          child: Text(
            weekday,
            style: widget.config.weekNameTextStyle ??
                TextStyle(
                  color: widget.config.themeColor ?? defaultTextColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      );
      if (i == (firstDayOfWeek - 1) % 7) break;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    const Color disabledDayColor = Colors.black54;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final TextStyle? headerStyle = textTheme.bodySmall?.apply(
      color: colorScheme.onSurface.withOpacity(0.60),
    );
    final Color enabledDayColor = colorScheme.onSurface.withOpacity(0.87);
    const Color selectedDayBackground = Color.fromRGBO(183, 84, 0, 1);

    final int year = widget.displayedMonth.year;
    final int month = widget.displayedMonth.month;

    final int daysInMonth = DateUtils.getDaysInMonth(year, month);
    final int dayOffset =
        getMonthFirstDayOffset(year, month, localizations.firstDayOfWeekIndex);

    final List<Widget> dayItems = _dayHeaders(headerStyle, localizations);
    int day = -dayOffset;
    while (day < daysInMonth) {
      day++;
      if (day < 1) {
        dayItems.add(Container());
      } else {
        final DateTime dayToBuild = DateTime(year, month, day);
        final bool isDisabled = dayToBuild.isAfter(widget.config.lastDate!) ||
            dayToBuild.isBefore(widget.config.firstDate!) ||
            !(widget.config.selectableDayPredicate?.call(dayToBuild) ?? true);
        final bool isSelectedDay =
            widget.selectedDates.any((d) => DateUtils.isSameDay(d, dayToBuild));

        final bool isToday =
            DateUtils.isSameDay(widget.config.currentDate, dayToBuild);

        BoxDecoration? decoration;
        Color dayColor = enabledDayColor;
        if (isSelectedDay) {
          dayColor = Colors.white;
          decoration = BoxDecoration(
            color: widget.config.themeColor ??
                widget.config.selectedDateBoxColor ??
                defaultTextColor,
            shape: BoxShape.circle,
          );
        } else if (isDisabled) {
          dayColor = disabledDayColor;
        } else if (isToday) {
          dayColor = widget.config.themeColor ?? defaultTextColor;
          decoration = BoxDecoration(
            border: Border.all(
                color: widget.config.currentDateBorderColor ?? dayColor),
            shape: BoxShape.circle,
          );
        }
        var customDayTextStyle = isSelectedDay
            ? widget.config.selectedDataTextStyle
            : widget.config.notSelectedDataTextStyle ??
                const TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                    fontWeight: FontWeight.w500);

        if (isDisabled) {
          customDayTextStyle = customDayTextStyle?.copyWith(
            color: disabledDayColor,
            fontWeight: FontWeight.normal,
          );
        }

        final isFullySelectedRangePicker =
            widget.config.calendarType == CalendarDatePicker2Type.range &&
                widget.selectedDates.length == 2;
        var isDateInBetweenRangePickerSelectedDates = false;

        if (isFullySelectedRangePicker) {
          final startDate = DateUtils.dateOnly(widget.selectedDates[0]);
          final endDate = DateUtils.dateOnly(widget.selectedDates[1]);

          isDateInBetweenRangePickerSelectedDates =
              !(dayToBuild.isBefore(startDate) ||
                      dayToBuild.isAfter(endDate)) &&
                  !DateUtils.isSameDay(startDate, endDate);
        }
        final dayTextStyle =
            customDayTextStyle ?? const TextStyle(color: Colors.white);
        Widget dayWidget = _buildDefaultDayWidgetContent(
          decoration,
          localizations,
          day,
          dayTextStyle,
        );

        if (isDateInBetweenRangePickerSelectedDates) {
          final rangePickerIncludedDayDecoration = BoxDecoration(
            color: widget.config.themeColor?.withOpacity(0.30) ??
                widget.config.selectedDateBoxColor?.withOpacity(0.30) ??
                selectedDayBackground.withOpacity(0.30),
          );

          if (DateUtils.isSameDay(
              DateUtils.dateOnly(widget.selectedDates[0]), dayToBuild)) {
            dayWidget = Stack(
              children: [
                Row(
                  children: [
                    const Spacer(),
                    Expanded(
                      child: Container(
                        decoration: rangePickerIncludedDayDecoration,
                      ),
                    ),
                  ],
                ),
                dayWidget,
              ],
            );
          } else if (DateUtils.isSameDay(
              DateUtils.dateOnly(widget.selectedDates[1]), dayToBuild)) {
            dayWidget = Stack(
              children: [
                Row(children: [
                  Expanded(
                    child: Container(
                      decoration: rangePickerIncludedDayDecoration,
                    ),
                  ),
                  const Spacer(),
                ]),
                dayWidget,
              ],
            );
          } else {
            dayWidget = Stack(
              children: [
                Container(
                  decoration: rangePickerIncludedDayDecoration,
                ),
                dayWidget,
              ],
            );
          }
        }

        dayWidget = Padding(
          padding: const EdgeInsets.symmetric(vertical: 1),
          child: dayWidget,
        );

        if (isDisabled) {
          dayWidget = ExcludeSemantics(
            child: dayWidget,
          );
        } else {
          dayWidget = InkResponse(
            focusNode: _dayFocusNodes[day - 1],
            onTap: () => widget.onChanged(dayToBuild),
            radius: _dayPickerRowHeight / 2 + 4,
            child: Semantics(
              label:
                  '${localizations.formatDecimal(day)}, ${localizations.formatFullDate(dayToBuild)}',
              selected: isSelectedDay,
              excludeSemantics: true,
              child: dayWidget,
            ),
          );
        }

        dayItems.add(dayWidget);
      }
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: widget.config.calendarHorizontalPadding ??
            _monthPickerHorizontalPadding,
      ),
      child: GridView.custom(
        padding: EdgeInsets.zero,
        physics: const ClampingScrollPhysics(),
        gridDelegate: _DayPickerGridDelegate(config: widget.config),
        childrenDelegate: SliverChildListDelegate(
          dayItems,
          addRepaintBoundaries: false,
        ),
      ),
    );
  }

  Widget _buildDefaultDayWidgetContent(
    BoxDecoration? decoration,
    MaterialLocalizations localizations,
    int day,
    TextStyle dayTextStyle,
  ) {
    return Row(
      children: [
        const Spacer(),
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: decoration,
            child: Center(
              child: Text(
                localizations.formatDecimal(day),
                style: dayTextStyle,
              ),
            ),
          ),
        ),
        const Spacer(),
      ],
    );
  }
}

class _DayPickerGridDelegate extends SliverGridDelegate {
  _DayPickerGridDelegate({required this.config});

  final CalendarDatePicker2Config config;
  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    const int columnCount = DateTime.daysPerWeek;
    final double tileWidth = constraints.crossAxisExtent / columnCount;
    final double tileHeight = math.min(
      _dayPickerRowHeight,
      constraints.viewportMainAxisExtent / (_maxDayPickerRowCount + 0),
    );
    return SliverGridRegularTileLayout(
      childCrossAxisExtent: tileWidth,
      childMainAxisExtent: tileHeight,
      crossAxisCount: columnCount,
      crossAxisStride: config.dateLeftRightPadding ?? tileWidth,
      mainAxisStride: config.dateTopBottomPadding ?? tileHeight,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(_DayPickerGridDelegate oldDelegate) => false;
}
