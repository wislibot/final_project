import '../../models/transaction_model.dart';

class WeeklyReportService {
  String generateSummary(List<TransactionModel> transactions) {
    if (transactions.isEmpty) {
      return "No transactions this week.";
    }

    String summary = "";

    for (final t in transactions) {
      summary +=
          "${_weekdayName(t.createdAt.weekday)} | "
          "${t.category} | "
          "\$${t.amount.toStringAsFixed(2)} | "
          "${t.description}\n";
    }

    return summary;
  }

  String _weekdayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return "Monday";
      case DateTime.tuesday:
        return "Tuesday";
      case DateTime.wednesday:
        return "Wednesday";
      case DateTime.thursday:
        return "Thursday";
      case DateTime.friday:
        return "Friday";
      case DateTime.saturday:
        return "Saturday";
      case DateTime.sunday:
        return "Sunday";
      default:
        return "Unknown";
    }
  }
}