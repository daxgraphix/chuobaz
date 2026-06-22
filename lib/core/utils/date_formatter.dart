import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class DateFormatter {
  DateFormatter._();

  static String relative(DateTime date) => timeago.format(date);

  static String short(DateTime date) => DateFormat('MMM d, yyyy').format(date);

  static String full(DateTime date) =>
      DateFormat('MMM d, yyyy • h:mm a').format(date);

  static String time(DateTime date) => DateFormat('h:mm a').format(date);

  static String chatDivider(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return DateFormat('MMM d, yyyy').format(date);
  }
}
