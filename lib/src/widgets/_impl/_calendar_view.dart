part of '../calendar_date_picker2.dart';

T? _ambiguate<T>(T? value) => value;

class _CalendarView extends StatefulWidget {
  const _CalendarView({
    required this.config,
    required this.initialMonth,
    required this.selectedDates,
    required this.onChanged,
    required this.onDisplayedMonthChanged,
    Key? key,
  }) : super(key: key);

  final CalendarDatePicker2Config config;

  final DateTime initialMonth;

  final List<DateTime?> selectedDates;

  final ValueChanged<DateTime> onChanged;

  final ValueChanged<DateTime> onDisplayedMonthChanged;

  @override
  _CalendarViewState createState() => _CalendarViewState();
}

class _CalendarViewState extends State<_CalendarView> {
  late DateTime _currentMonth;
  late PageController _pageController;
  late MaterialLocalizations _localizations;
  late TextDirection _textDirection;
  Map<ShortcutActivator, Intent>? _shortcutMap;
  Map<Type, Action<Intent>>? _actionMap;
  late FocusNode _dayGridFocus;
  DateTime? _focusedDay;

  @override
  void initState() {
    super.initState();
    _currentMonth = widget.initialMonth;
    _pageController = PageController(
        initialPage:
            DateUtils.monthDelta(widget.config.firstDate!, _currentMonth));
    _shortcutMap = const <ShortcutActivator, Intent>{
      SingleActivator(LogicalKeyboardKey.arrowLeft):
          DirectionalFocusIntent(TraversalDirection.left),
      SingleActivator(LogicalKeyboardKey.arrowRight):
          DirectionalFocusIntent(TraversalDirection.right),
      SingleActivator(LogicalKeyboardKey.arrowDown):
          DirectionalFocusIntent(TraversalDirection.down),
      SingleActivator(LogicalKeyboardKey.arrowUp):
          DirectionalFocusIntent(TraversalDirection.up),
    };
    _actionMap = <Type, Action<Intent>>{
      NextFocusIntent:
          CallbackAction<NextFocusIntent>(onInvoke: _handleGridNextFocus),
      PreviousFocusIntent: CallbackAction<PreviousFocusIntent>(
          onInvoke: _handleGridPreviousFocus),
      DirectionalFocusIntent: CallbackAction<DirectionalFocusIntent>(
          onInvoke: _handleDirectionFocus),
    };
    _dayGridFocus = FocusNode(debugLabel: 'Day Grid');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _localizations = MaterialLocalizations.of(context);
    _textDirection = Directionality.of(context);
  }

  @override
  void didUpdateWidget(_CalendarView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialMonth != oldWidget.initialMonth &&
        widget.initialMonth != _currentMonth) {
      _ambiguate(WidgetsBinding.instance)!.addPostFrameCallback(
        (Duration timeStamp) => _showMonth(widget.initialMonth, jump: true),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _dayGridFocus.dispose();
    super.dispose();
  }

  void _handleDateSelected(DateTime selectedDate) {
    _focusedDay = selectedDate;
    widget.onChanged(selectedDate);
  }

  void _handleMonthPageChanged(int monthPage) {
    setState(() {
      final DateTime monthDate =
          DateUtils.addMonthsToMonthDate(widget.config.firstDate!, monthPage);
      if (!DateUtils.isSameMonth(_currentMonth, monthDate)) {
        _currentMonth = DateTime(monthDate.year, monthDate.month);
        widget.onDisplayedMonthChanged(_currentMonth);
        if (_focusedDay != null &&
            !DateUtils.isSameMonth(_focusedDay, _currentMonth)) {
          _focusedDay = _focusableDayForMonth(_currentMonth, _focusedDay!.day);
        }
        SemanticsService.announce(
          _localizations.formatMonthYear(_currentMonth),
          _textDirection,
        );
      }
    });
  }

  DateTime? _focusableDayForMonth(DateTime month, int preferredDay) {
    final int daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);

    if (preferredDay <= daysInMonth) {
      final DateTime newFocus = DateTime(month.year, month.month, preferredDay);
      if (_isSelectable(newFocus)) return newFocus;
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final DateTime newFocus = DateTime(month.year, month.month, day);
      if (_isSelectable(newFocus)) return newFocus;
    }
    return null;
  }

  void _handleNextMonth() {
    if (!_isDisplayingLastMonth) {
      _pageController.nextPage(
        duration: _monthScrollDuration,
        curve: Curves.ease,
      );
    }
  }

  void _handlePreviousMonth() {
    if (!_isDisplayingFirstMonth) {
      _pageController.previousPage(
        duration: _monthScrollDuration,
        curve: Curves.ease,
      );
    }
  }

  void _showMonth(DateTime month, {bool jump = false}) {
    final int monthPage = DateUtils.monthDelta(widget.config.firstDate!, month);
    if (jump) {
      _pageController.jumpToPage(monthPage);
    } else {
      _pageController.animateToPage(
        monthPage,
        duration: _monthScrollDuration,
        curve: Curves.ease,
      );
    }
  }

  bool get _isDisplayingFirstMonth {
    return !_currentMonth.isAfter(
      DateTime(widget.config.firstDate!.year, widget.config.firstDate!.month),
    );
  }

  bool get _isDisplayingLastMonth {
    return !_currentMonth.isBefore(
      DateTime(widget.config.lastDate!.year, widget.config.lastDate!.month),
    );
  }

  void _handleGridFocusChange(bool focused) {
    setState(() {
      if (focused && _focusedDay == null && widget.selectedDates.isNotEmpty) {
        if (DateUtils.isSameMonth(widget.selectedDates[0], _currentMonth)) {
          _focusedDay = widget.selectedDates[0];
        } else if (DateUtils.isSameMonth(
            widget.config.currentDate, _currentMonth)) {
          _focusedDay = _focusableDayForMonth(
              _currentMonth, widget.config.currentDate!.day);
        } else {
          _focusedDay = _focusableDayForMonth(_currentMonth, 1);
        }
      }
    });
  }

  void _handleGridNextFocus(NextFocusIntent intent) {
    _dayGridFocus.requestFocus();
    _dayGridFocus.nextFocus();
  }

  void _handleGridPreviousFocus(PreviousFocusIntent intent) {
    _dayGridFocus.requestFocus();
    _dayGridFocus.previousFocus();
  }

  void _handleDirectionFocus(DirectionalFocusIntent intent) {
    setState(() {
      if (_focusedDay != null) {
        final nextDate = _nextDateInDirection(_focusedDay!, intent.direction);
        if (nextDate != null) {
          _focusedDay = nextDate;
          if (!DateUtils.isSameMonth(_focusedDay, _currentMonth)) {
            _showMonth(_focusedDay!);
          }
        }
      } else {
        _focusedDay ??= widget.initialMonth;
      }
    });
  }

  static const Map<TraversalDirection, int> _directionOffset =
      <TraversalDirection, int>{
    TraversalDirection.up: -DateTime.daysPerWeek,
    TraversalDirection.right: 1,
    TraversalDirection.down: DateTime.daysPerWeek,
    TraversalDirection.left: -1,
  };

  int _dayDirectionOffset(
      TraversalDirection traversalDirection, TextDirection textDirection) {
    if (textDirection == TextDirection.rtl) {
      if (traversalDirection == TraversalDirection.left) {
        traversalDirection = TraversalDirection.right;
      } else if (traversalDirection == TraversalDirection.right) {
        traversalDirection = TraversalDirection.left;
      }
    }
    return _directionOffset[traversalDirection]!;
  }

  DateTime? _nextDateInDirection(DateTime date, TraversalDirection direction) {
    final TextDirection textDirection = Directionality.of(context);
    DateTime nextDate = DateUtils.addDaysToDate(
        date, _dayDirectionOffset(direction, textDirection));
    while (!nextDate.isBefore(widget.config.firstDate!) &&
        !nextDate.isAfter(widget.config.lastDate!)) {
      if (_isSelectable(nextDate)) {
        return nextDate;
      }
      nextDate = DateUtils.addDaysToDate(
          nextDate, _dayDirectionOffset(direction, textDirection));
    }
    return null;
  }

  bool _isSelectable(DateTime date) {
    return widget.config.selectableDayPredicate?.call(date) ?? true;
  }

  Widget _buildItems(BuildContext context, int index) {
    final DateTime month =
        DateUtils.addMonthsToMonthDate(widget.config.firstDate!, index);
    return _DayPicker(
      key: ValueKey<DateTime>(month),
      selectedDates: (widget.selectedDates..removeWhere((d) => d == null))
          .cast<DateTime>(),
      onChanged: _handleDateSelected,
      config: widget.config,
      displayedMonth: month,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          height: (widget.config.controlsHeight ?? _subHeaderHeight),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.chevron_left,
                  size: 35,
                  color: widget.config.themeColor ??
                      widget.config.arrowColor ??
                      CommonColor.commonColor,
                ),
                tooltip: _isDisplayingFirstMonth
                    ? null
                    : _localizations.previousMonthTooltip,
                onPressed:
                    _isDisplayingFirstMonth ? null : _handlePreviousMonth,
              ),
              IconButton(
                icon: Icon(
                  Icons.chevron_right,
                  size: 35,
                  color: widget.config.themeColor ??
                      widget.config.arrowColor ??
                      CommonColor.commonColor,
                ),
                tooltip: _isDisplayingLastMonth
                    ? null
                    : _localizations.nextMonthTooltip,
                onPressed: _isDisplayingLastMonth ? null : _handleNextMonth,
              ),
            ],
          ),
        ),
        SizedBox(
          height: widget.config.spaceBetweenYearAndCalender ?? 10,
        ),
        Expanded(
          child: FocusableActionDetector(
            shortcuts: _shortcutMap,
            actions: _actionMap,
            focusNode: _dayGridFocus,
            onFocusChange: _handleGridFocusChange,
            child: _FocusedDate(
              date: _dayGridFocus.hasFocus ? _focusedDay : null,
              child: SizedBox(
                height: 200,
                width: 550,
                child: PageView.builder(
                  controller: _pageController,
                  itemBuilder: _buildItems,
                  itemCount: DateUtils.monthDelta(
                          widget.config.firstDate!, widget.config.lastDate!) +
                      1,
                  onPageChanged: _handleMonthPageChanged,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
