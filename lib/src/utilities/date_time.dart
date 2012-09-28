/* ****************************************************** *
 *   DateTime class                                       *
 *   Method stamp([bool short = false]) returns           *
 *   a string for use as a time stamp                     *
 *   Library: ConvoWeb (c) 2012 scribeGriff               *
 * ****************************************************** */
class DateTime {

  HashMap months = new Map();
  HashMap weekdays = new Map();
  Date currentTime;
  int year, month, day, hour, minute, weekday;

  DateTime()
      : currentTime = new Date.now() {
    year = currentTime.year;
    month = currentTime.month;
    day = currentTime.day;
    hour = currentTime.hour;
    minute = currentTime.minute;
    weekday = currentTime.weekday;

    months[1] = 'Jan';
    months[2] = 'Feb';
    months[3] = 'Mar';
    months[4] = 'Apr';
    months[5] = 'May';
    months[6] = 'Jun';
    months[7] = 'Jul';
    months[8] = 'Aug';
    months[9] = 'Sep';
    months[10] = 'Oct';
    months[11] = 'Nov';
    months[12] = 'Dec';

    weekdays[1] = 'Mon';
    weekdays[2] = 'Tue';
    weekdays[3] = 'Wed';
    weekdays[4] = 'Thu';
    weekdays[5] = 'Fri';
    weekdays[6] = 'Sat';
    weekdays[7] = 'Sun';
  }

  String stamp([bool short = false]) {
    String dateTime;
    String meridian;
    String minutes = minute < 10 ? '0$minute' : '$minute';

    if (hour > 12) {
      hour -= 12;
      meridian = 'pm';
    } else {
      meridian = 'am';
    }

    if (short) {
      return dateTime = '$hour:$minutes$meridian $month/$day/$year';
    } else {
      return dateTime = '$hour:$minutes$meridian ${weekdays[weekday]} '
          '$day-${months[month]}-$year';
    }
  }
}
