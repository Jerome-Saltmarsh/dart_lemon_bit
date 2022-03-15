

import 'package:intl/intl.dart';

final dateFormat = DateFormat(DateFormat.YEAR_MONTH_DAY);

String formatDate(DateTime value){
  return dateFormat.format(value.toLocal());
}