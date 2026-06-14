import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:typed_data';

class GeminiService {
  late final GenerativeModel model;

  GeminiService() {
    model = GenerativeModel(
      model: "gemini-2.5-flash",
      apiKey: dotenv.env["GEMINI_API_KEY"]!,
    );
  }

  Future<String> sendMessage(String message) async {
    final response = await model.generateContent(
      [
        Content.text(message),
      ],
    );

    return response.text ?? "";
  }
  Future<String> extractExpense(
    String userMessage) async {

      final prompt = """
          You are an AI financial assistant.

          Extract the transaction information from the user's message.

          Return ONLY valid JSON.

          Schema:

          {
          "type":"",
          "category":"",
          "amount":0,
          "description":""
          }

          Examples:

          User:
          Spent \$20 on lunch

          Output:
          {
          "type":"expense",
          "category":"Food",
          "amount":20,
          "description":"Lunch"
          }

          User:
          Bought coffee for \$5

          Output:
          {
          "type":"expense",
          "category":"Food",
          "amount":5,
          "description":"Coffee"
          }

          User message:

          $userMessage
          """;

      final response =
          await model.generateContent(
        [
          Content.text(prompt),
        ],
      );

      return response.text ?? "";
    }
  Future<String> detectIntent(
    String userMessage) async {

      final prompt = """
            You are an AI financial assistant.

            Classify the user's message.

            Return ONLY one word.

            Possible values:

            expense
            budget
            reminder
            planner
            analysis
            chat

            Examples:

            Spent \$20 on lunch

            expense

            Set my food budget to \$300

            budget

            Remind me to pay rent tomorrow

            reminder

            Hello, how are you?

            chat

            User message:

            $userMessage
            """;

        final response =
            await model.generateContent(
          [
            Content.text(prompt),
          ],
        );

        return response.text!
            .trim()
            .toLowerCase();
      }
    Future<String> extractBudget(
          String userMessage) async {

        final prompt = """
      You are an AI financial assistant.

      Return ONLY JSON.

      Schema:

      {
      "category":"",
      "limit":0
      }

      User message:

      $userMessage
      """;

        final response =
            await model.generateContent(
          [
            Content.text(prompt),
          ],
        );

        return response.text ?? "";
      }
    
    Future<String> extractReminder(
        String userMessage) async {

      final prompt = """
    Return ONLY JSON.

    Schema:

    {
    "title":"",
    "date":""
    }

    Example:

    User:
    Remind me to pay rent tomorrow

    Output:

    {
    "title":"Pay rent",
    "date":"tomorrow"
    }

    User message:

    $userMessage
    """;

      final response =
          await model.generateContent(
        [
          Content.text(prompt),
        ],
      );

      return response.text ?? "";
    }

  Future<String> extractReceipt(
        Uint8List imageBytes) async {

      const prompt = """
    You are an AI financial assistant.

    Analyze the receipt image.

    Return ONLY valid JSON.

    Schema:

    {
    "type":"",
    "category":"",
    "amount":0,
    "description":""
    }

    Example:

    {
    "type":"expense",
    "category":"Food",
    "amount":15.5,
    "description":"McDonald's"
    }
    """;

      final response =
          await model.generateContent(
        [
          Content.multi([
            TextPart(prompt),
            DataPart(
              "image/jpeg",
              imageBytes,
            ),
          ]),
        ],
      );

      return response.text ?? "";
    }

  Future<String> analyzeSpending(
    String summary) async {

      final prompt = """
    You are an AI financial advisor.

    Analyze the user's spending summary.

    Give useful insights and recommendations.

    Spending summary:

    $summary
    """;

      final response =
          await model.generateContent(
        [
          Content.text(prompt),
        ],
      );

      return response.text ?? "";
    }
  Future<String> weeklyReflection(
        String weeklySummary) async {

      final prompt = """
    You are an AI financial coach.

    Analyze the user's weekly spending.

    Provide:

    1. Good habits.
    2. Problems.
    3. Suggestions.

    Weekly spending:

    $weeklySummary
    """;

      final response =
          await model.generateContent(
        [
          Content.text(prompt),
        ],
      );

      return response.text ?? "";
    }

  Future<String> createBudgetPlan(
        String income,
        String habitSummary) async {

      final prompt = """
    You are an AI financial advisor.

    The user has monthly income:

    $income

    User habits:

    $habitSummary

    Create:

    1. Weekday budget.
    2. Weekend budget.
    3. Savings target.
    4. Emergency reserve.

    Provide practical recommendations.
    """;

      final response =
          await model.generateContent(
        [
          Content.text(prompt),
        ],
      );

      return response.text ?? "";
    }
  Future<String> generateNotification(
    String summary) async {

      final prompt = """
    Generate a short financial notification.

    Keep it friendly.

    Information:

    $summary
    """;

      final response =
          await model.generateContent(
        [
          Content.text(prompt),
        ],
      );

      return response.text ?? "";
    }  
}