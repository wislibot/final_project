import '../../models/transaction_model.dart';
import '../../models/user_profile_model.dart';

class HabitAnalyzerService {

  UserProfileModel analyze(
      List<TransactionModel> transactions) {

    double total = 0;

    int earliestHour = 23;
    int latestHour = 0;

    double weekdayTotal = 0;
    double weekendTotal = 0;

    int weekdayCount = 0;
    int weekendCount = 0;

    for (final t in transactions) {

      total += t.amount;

      final hour = t.createdAt.hour;

      if (hour < earliestHour) {
        earliestHour = hour;
      }

      if (hour > latestHour) {
        latestHour = hour;
      }

      final day = t.createdAt.weekday;

      if (
        day == DateTime.saturday ||
        day == DateTime.sunday
      ) {

        weekendTotal += t.amount;
        weekendCount++;

      } else {

        weekdayTotal += t.amount;
        weekdayCount++;

      }

    }

    return UserProfileModel(

      averageDailySpending:
          total / transactions.length,

      weekdayBudget:
          weekdayCount == 0
              ? 0
              : weekdayTotal / weekdayCount,

      weekendBudget:
          weekendCount == 0
              ? 0
              : weekendTotal / weekendCount,

      wakeHour: earliestHour,

      sleepHour: latestHour + 1,
    );
  }
}