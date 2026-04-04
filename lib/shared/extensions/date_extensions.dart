import 'dart:core';

/// Date extensions for common operations
extension DateExtensions on DateTime {
  /// Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }

  /// Check if date is tomorrow
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year && month == tomorrow.month && day == tomorrow.day;
  }

  /// Check if date is this week
  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    return isAfter(startOfWeek) && isBefore(endOfWeek);
  }

  /// Check if date is this month
  bool get isThisMonth {
    final now = DateTime.now();
    return year == now.year && month == now.month;
  }

  /// Check if date is this year
  bool get isThisYear {
    final now = DateTime.now();
    return year == now.year;
  }

  /// Get start of day
  DateTime get startOfDay {
    return DateTime(year, month, day, 0, 0, 0, 0);
  }

  /// Get end of day
  DateTime get endOfDay {
    return DateTime(year, month, day, 23, 59, 59, 999);
  }

  /// Get start of week (Monday)
  DateTime get startOfWeek {
    final currentDay = weekday;
    final monday = weekday == 1 ? this : subtract(Duration(days: currentDay - 1));
    return DateTime(monday.year, monday.month, monday.day, 0, 0, 0, 0);
  }

  /// Get end of week (Sunday)
  DateTime get endOfWeek {
    final currentDay = weekday;
    final sunday = weekday == 7 ? this : add(Duration(days: 7 - currentDay));
    return DateTime(sunday.year, sunday.month, sunday.day, 23, 59, 59, 999);
  }

  /// Get start of month
  DateTime get startOfMonth {
    return DateTime(year, month, 1, 0, 0, 0, 0);
  }

  /// Get end of month
  DateTime get endOfMonth {
    final lastDay = DateTime(year, month + 1, 0).day;
    return DateTime(year, month, lastDay, 23, 59, 59, 999);
  }

  /// Get start of year
  DateTime get startOfYear {
    return DateTime(year, 1, 1, 0, 0, 0, 0);
  }

  /// Get end of year
  DateTime get endOfYear {
    return DateTime(year, 12, 31, 23, 59, 59, 999);
  }

  /// Get age from this date
  int get age {
    final now = DateTime.now();
    int age = now.year - year;
    
    if (now.month < month || (now.month == month && now.day < day)) {
      age--;
    }
    
    return age;
  }

  /// Get days until this date
  int get daysUntil {
    final now = DateTime.now();
    if (isBefore(now)) return 0;
    
    final difference = difference(now);
    return difference.inDays;
  }

  /// Get days since this date
  int get daysSince {
    final now = DateTime.now();
    if (isAfter(now)) return 0;
    
    final difference = now.difference(this);
    return difference.inDays;
  }

  /// Check if date is weekend
  bool get isWeekend {
    return weekday == DateTime.saturday || weekday == DateTime.sunday;
  }

  /// Check if date is weekday
  bool get isWeekday {
    return !isWeekend;
  }

  /// Get day of week name
  String get dayName {
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 
      'Friday', 'Saturday', 'Sunday'
    ];
    return days[weekday - 1];
  }

  /// Get short day of week name
  String get shortDayName {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  /// Get month name
  String get monthName {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  /// Get short month name
  String get shortMonthName {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  /// Format as readable date
  String formatDate({String format = 'MMM dd, yyyy'}) {
    const formats = {
      'dd/MM/yyyy': (d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}',
      'MM/dd/yyyy': (d) => '${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}/${d.year}',
      'yyyy-MM-dd': (d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}',
      'dd MMM yyyy': (d) => '${d.day.toString().padLeft(2, '0')} ${d.shortMonthName} ${d.year}',
      'MMM dd, yyyy': (d) => '${d.shortMonthName} ${d.day}, ${d.year}',
      'MMMM dd, yyyy': (d) => '${d.monthName} ${d.day}, ${d.year}',
      'dd MMMM yyyy': (d) => '${d.day.toString().padLeft(2, '0')} ${d.monthName} ${d.year}',
      'EEEE, MMM dd, yyyy': (d) => '${d.dayName}, ${d.shortMonthName} ${d.day}, ${d.year}',
    };
    
    return formats[format]?.call(this) ?? toString();
  }

  /// Format as time
  String formatTime({String format = 'hh:mm a'}) {
    const hour = hour;
    const minute = minute;
    
    switch (format) {
      case 'hh:mm a':
        final period = hour >= 12 ? 'PM' : 'AM';
        final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
      case 'HH:mm':
        return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
      case 'hh:mm':
        return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
      default:
        return toString();
    }
  }

  /// Format as date and time
  String formatDateTime({String dateFormat = 'MMM dd, yyyy', String timeFormat = 'hh:mm a'}) {
    return '${formatDate(format: dateFormat)} at ${formatTime(format: timeFormat)}';
  }

  /// Format as relative time (e.g., "2 hours ago")
  String formatRelativeTime() {
    final now = DateTime.now();
    final difference = now.difference(this);
    
    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }

  /// Add working days (excluding weekends)
  DateTime addWorkingDays(int days) {
    var currentDate = this;
    var remainingDays = days;
    
    while (remainingDays > 0) {
      currentDate = currentDate.add(const Duration(days: 1));
      if (!currentDate.isWeekend) {
        remainingDays--;
      }
    }
    
    return currentDate;
  }

  /// Subtract working days (excluding weekends)
  DateTime subtractWorkingDays(int days) {
    var currentDate = this;
    var remainingDays = days;
    
    while (remainingDays > 0) {
      currentDate = currentDate.subtract(const Duration(days: 1));
      if (!currentDate.isWeekend) {
        remainingDays--;
      }
    }
    
    return currentDate;
  }

  /// Get working days until another date
  int getWorkingDaysUntil(DateTime endDate) {
    var currentDate = this;
    var workingDays = 0;
    
    while (currentDate.isBefore(endDate)) {
      if (!currentDate.isWeekend) {
        workingDays++;
      }
      currentDate = currentDate.add(const Duration(days: 1));
    }
    
    return workingDays;
  }

  /// Check if date is a Nepal holiday (basic implementation)
  bool get isNepalHoliday {
    // Major Nepal holidays
    final holidays = [
      // Fixed dates
      (1, 1),   // New Year's Day
      (1, 11),  // Unity Day
      (1, 26),  // Martyrs' Day
      (2, 18),  // National Democracy Day
      (3, 8),   // Women's Day
      (3, 20),  // National Unity Day
      (4, 14),  // Nepali New Year
      (5, 1),   // Labor Day
      (7, 7),   // Lhosar
      (8, 8),   // Krishna Janmashtami
      (9, 20),  // Constitution Day
      (10, 2),  // Gandhi Jayanti
      (10, 20), // Vijaya Dashami
      (10, 21), // Laxmi Puja
      (10, 22), // Bhai Tika
      (11, 2),  // National Education Day
      (11, 14), // Children's Day
      (12, 25), // Christmas Day
    ];
    
    return holidays.any((holiday) => month == holiday.$1 && day == holiday.$2);
  }

  /// Get fiscal year (Nepal starts July 16)
  int get nepalFiscalYear {
    final fiscalYearStart = DateTime(year, month < 7 ? year - 1 : year, 7, 16);
    if (isBefore(fiscalYearStart)) {
      return year - 1;
    }
    return year;
  }

  /// Check if date is in current fiscal year
  bool get isInCurrentFiscalYear {
    final now = DateTime.now();
    final currentFiscalYear = now.nepalFiscalYear;
    return nepalFiscalYear == currentFiscalYear;
  }

  /// Get quarter of year
  int get quarter {
    return ((month - 1) ~/ 3) + 1;
  }

  /// Get quarter name
  String get quarterName {
    return 'Q$quarter';
  }

  /// Check if date is first day of month
  bool get isFirstDayOfMonth => day == 1;

  /// Check if date is last day of month
  bool get isLastDayOfMonth => day == DateTime(year, month + 1, 0).day;

  /// Get days in month
  int get daysInMonth => DateTime(year, month + 1, 0).day;

  /// Get week number of year
  int get weekOfYear {
    final startOfYear = DateTime(year, 1, 1);
    final daysDifference = difference(startOfYear).inDays;
    return ((daysDifference + startOfYear.weekday - 1) ~/ 7) + 1;
  }

  /// Get ISO week number
  int get isoWeek {
    final startOfYear = DateTime(year, 1, 4); // Thursday of week 1
    final daysDifference = difference(startOfYear).inDays;
    return ((daysDifference + startOfYear.weekday - 1) ~/ 7) + 1;
  }

  /// Add business days (excluding weekends and holidays)
  DateTime addBusinessDays(int days, {List<DateTime>? holidays}) {
    var currentDate = this;
    var remainingDays = days;
    
    while (remainingDays > 0) {
      currentDate = currentDate.add(const Duration(days: 1));
      
      if (!currentDate.isWeekend && 
          (holidays == null || !holidays!.any((holiday) => 
              holiday.day == currentDate.day && 
              holiday.month == currentDate.month && 
              holiday.year == currentDate.year))) {
        remainingDays--;
      }
    }
    
    return currentDate;
  }

  /// Get day suffix (st, nd, rd, th)
  String get daySuffix {
    if (day >= 11 && day <= 13) {
      return 'th';
    }
    
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  /// Format with day suffix
  String formatWithDaySuffix({String format = 'MMMM dd, yyyy'}) {
    return formatDate(format: format.replaceAll('dd', '${day}$daySuffix'));
  }

  /// Get zodiac sign
  String get zodiacSign {
    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return 'Aries';
    if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return 'Taurus';
    if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) return 'Gemini';
    if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) return 'Cancer';
    if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return 'Leo';
    if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return 'Virgo';
    if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) return 'Libra';
    if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) return 'Scorpio';
    if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) return 'Sagittarius';
    if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) return 'Capricorn';
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) return 'Aquarius';
    return 'Pisces';
  }

  /// Get season (Northern Hemisphere)
  String get season {
    if ((month >= 3 && month <= 5)) return 'Spring';
    if ((month >= 6 && month <= 8)) return 'Summer';
    if ((month >= 9 && month <= 11)) return 'Autumn';
    return 'Winter';
  }

  /// Get Nepal season
  String get nepalSeason {
    if ((month >= 3 && month <= 5)) return 'Basanta (Spring)';
    if ((month >= 6 && month <= 8)) return 'Gharma (Summer)';
    if ((month >= 9 && month <= 11)) return 'Sharad (Autumn)';
    return 'Hemanta (Winter)';
  }

  /// Check if date is leap year
  bool get isLeapYear {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  /// Get days in year
  int get daysInYear => isLeapYear ? 366 : 365;

  /// Get day of year
  int get dayOfYear {
    final startOfYear = DateTime(year, 1, 1);
    return difference(startOfYear).inDays + 1;
  }

  /// Get remaining days in year
  int get remainingDaysInYear {
    return daysInYear - dayOfYear;
  }

  /// Get percentage of year passed
  double get yearProgress {
    return (dayOfYear / daysInYear) * 100;
  }

  /// Get percentage of month passed
  double get monthProgress {
    return (day / daysInMonth) * 100;
  }
}
