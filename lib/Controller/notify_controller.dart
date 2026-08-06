import 'package:get/get.dart';
import 'package:intl/intl.dart';

class NotifyController extends GetxController {
  String formatToReadableDateTime(String dateString) {
    try {
      // Parse the ISO date and convert to local time
      DateTime dateTime = DateTime.parse(dateString).toLocal();

      // Format date as dd-MM-yyyy
      String formattedDate = DateFormat('d-M-yyyy').format(dateTime);

      // Format time as h:mm AM/PM
      String formattedTime = DateFormat('h:mm a').format(dateTime);

      // Combine date and time
      return '$formattedDate $formattedTime';
    } catch (e) {
      return 'Invalid date';
    }
  }

// Alternative function with Arabic AM/PM
  String formatToReadableDateTimeArabic(String dateString) {
    try {
      // Parse the ISO date and convert to local time
      DateTime dateTime = DateTime.parse(dateString).toLocal();

      // Format date as dd-MM-yyyy
      String formattedDate = DateFormat('d-M-yyyy').format(dateTime);

      // Format time with Arabic AM/PM
      String hour = DateFormat('h').format(dateTime);
      String minute = DateFormat('mm').format(dateTime);
      String period = dateTime.hour < 12 ? 'ص' : 'م'; // Arabic AM/PM

      return '$formattedDate $hour:$minute $period';
    } catch (e) {
      return 'تاريخ غير صحيح';
    }
  }
}
