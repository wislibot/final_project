import 'package:flutter/material.dart';

import '../../core/services/gemini_service.dart';
import '../../models/message_model.dart';
import '../../widgets/ai_assistant/chat_bubble.dart';
import '../../widgets/ai_assistant/message_input.dart';
import '../../widgets/ai_assistant/quick_action_chip.dart';

import 'dart:convert';

import '../../models/transaction_model.dart';
import '../../repositories/transaction_repository.dart';
import '../../core/services/image_service.dart';
import '../../core/services/speech_service.dart';

import '../../repositories/budget_repository.dart';

import '../../models/reminder_model.dart';
import '../../repositories/reminder_repository.dart';
import '../../widgets/chat/chat_header.dart';
import '../../core/services/habit_analyzer_service.dart';
import '../../core/services/weekly_report_service.dart';


class AIChatPage extends StatefulWidget {
  const AIChatPage({super.key});

  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> {
  final TextEditingController messageController = TextEditingController();
  final GeminiService geminiService = GeminiService();
  final ImageService imageService = ImageService();
  final SpeechService speechService =
    SpeechService();
  final BudgetRepository budgetRepository =
    BudgetRepository();
  final ReminderRepository reminderRepository =
    ReminderRepository();

  final TransactionRepository transactionRepository =
    TransactionRepository();

  bool isLoading = false;

  final List<MessageModel> messages = [
    MessageModel(
      text: "Welcome! How can I help you manage your finances today?",
      isUser: false,
      timestamp: DateTime.now(),
    ),
  ];
  Future<void> sendMessage() async {
    final text = messageController.text.trim();

    if (text.isEmpty) return;

    setState(() {
      messages.add(
        MessageModel(
          text: text,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );

      isLoading = true;
    });

    messageController.clear();

    try {
      final intent =
          await geminiService.detectIntent(text);

      switch (intent) {

        case "expense":

        await recordExpense(text);

        break;

      case "budget":

        await recordBudget(text);

        break;

      case "reminder":

        await recordReminder(text);

        break;
      
      case "analysis":

        await analyzeMonthlySpending();

        break;
      
      case "planner":

      await createBudgetPlan(text);

      break;

      case "weekly":
      await generateWeeklyCoach();
      break;

        default:

          final reply =
              await geminiService.sendMessage(text);

          setState(() {
            messages.add(
              MessageModel(
                text: reply,
                isUser: false,
                timestamp: DateTime.now(),
              ),
            );
          });
      }

    } catch (e) {

      setState(() {
        messages.add(
          MessageModel(
            text: "Sorry, I couldn't connect to Gemini.\n$e",
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });

    } finally {

      setState(() {
        isLoading = false;
      });

    }
  }
 
  Future<void> recordExpense(String text) async {

    try {

      String response =
          await geminiService.extractExpense(text);

      response = response
          .replaceAll("```json", "")
          .replaceAll("```JSON", "")
          .replaceAll("```", "")
          .trim();

      final data =
          jsonDecode(response);

      final transaction =
          TransactionModel(
        type: data["type"],
        category: data["category"],
        amount: double.parse(
          data["amount"].toString(),
        ),
        description: data["description"],
        createdAt: DateTime.now(),
      );

      await transactionRepository
          .addTransaction(transaction);

      setState(() {
        messages.add(
          MessageModel(
            text:
                "Recorded ${transaction.category} expense of \$${transaction.amount}.",
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });

    } catch (e) {

      setState(() {
        messages.add(
          MessageModel(
            text:
                "Failed to record expense.\n$e",
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });

    }
  }

  Future<void> processReceipt() async {
      try {
        final image = await imageService.pickImage();

        if (image == null) return;

        setState(() {
          messages.add(
            MessageModel(
              text: "Receipt image selected. Reading receipt...",
              isUser: true,
              timestamp: DateTime.now(),
            ),
          );
          isLoading = true;
        });

        final imageBytes = await image.readAsBytes();

        String response = await geminiService.extractReceipt(imageBytes);

        response = response
            .replaceAll("```json", "")
            .replaceAll("```JSON", "")
            .replaceAll("```", "")
            .trim();

        final data = jsonDecode(response);

        final transaction = TransactionModel(
          type: data["type"],
          category: data["category"],
          amount: double.parse(data["amount"].toString()),
          description: data["description"],
          createdAt: DateTime.now(),
        );

        await transactionRepository.addTransaction(transaction);

        setState(() {
          messages.add(
            MessageModel(
              text:
                  "Receipt recorded: ${transaction.description}, ${transaction.category}, \$${transaction.amount}.",
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
        });
      } catch (e) {
        setState(() {
          messages.add(
            MessageModel(
              text: "Failed to read receipt.\n$e",
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
        });
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }

    Future<void> startVoiceInput() async {

      final available =
          await speechService.initialize();

      if (!available) {
        return;
      }

      await speechService.startListening(
        (recognizedText) {

          setState(() {

            messageController.text =
                recognizedText;

          });

        },
      );

    }
    Future<void> recordBudget(String text) async {

    }
    Future<void> recordReminder(String text) async {

      try {

        String response =
            await geminiService.extractReminder(text);

        response = response
            .replaceAll("```json", "")
            .replaceAll("```JSON", "")
            .replaceAll("```", "")
            .trim();

        final data =
            jsonDecode(response);

        final reminder =
            ReminderModel(
          title: data["title"],
          date: data["date"],
        );

        await reminderRepository
            .addReminder(reminder);

        setState(() {
          messages.add(
            MessageModel(
              text:
                  "Reminder '${reminder.title}' saved.",
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
        });

      } catch (e) {

        setState(() {
          messages.add(
            MessageModel(
              text:
                  "Failed to save reminder.",
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
        });

      }

    }
  Future<void> analyzeMonthlySpending() async {

    try {

      final transactions =
          await transactionRepository
              .fetchTransactions();

      double total = 0;

      final Map<String, double> categories = {};

      for (final t in transactions) {

        total += t.amount;

        categories[t.category] =
            (categories[t.category] ?? 0)
                + t.amount;

      }

      String summary =
          "Total spending: \$${total.toStringAsFixed(2)}\n";

      categories.forEach(
        (key, value) {

          summary +=
              "$key: \$${value.toStringAsFixed(2)}\n";

        },
      );

      final reply =
          await geminiService
              .analyzeSpending(summary);

      setState(() {

        messages.add(
          MessageModel(
            text: reply,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );

      });

    } catch (e) {

      setState(() {

        messages.add(
          MessageModel(
            text: "Failed to analyze spending.",
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );

      });

    }

  }

  Future<void> createBudgetPlan(
      String text) async {

    try {

      final transactions =
          await transactionRepository
              .fetchTransactions();

      final profile =
          HabitAnalyzerService()
              .analyze(transactions);

      final summary = """

  Weekday budget:

  ${profile.weekdayBudget}

  Weekend budget:

  ${profile.weekendBudget}

  Wake hour:

  ${profile.wakeHour}

  Sleep hour:

  ${profile.sleepHour}

  """;

      final reply =
          await geminiService
              .createBudgetPlan(
                  text,
                  summary);

      setState(() {

        messages.add(
          MessageModel(
            text: reply,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );

      });

    } catch (e) {

      setState(() {

        messages.add(
          MessageModel(
            text:
                "Failed to create budget plan.",
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );

      });

    }
  }

  Future<void> generateWeeklyCoach() async {
    try {
      final transactions =
          await transactionRepository.fetchTransactions();

      final summary =
          WeeklyReportService().generateSummary(transactions);

      final reply =
          await geminiService.weeklyReflection(summary);

      setState(() {
        messages.add(
          MessageModel(
            text: reply,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
    } catch (e) {
      setState(() {
        messages.add(
          MessageModel(
            text: "Failed to generate weekly coaching insight.",
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
  child: Column(
    children: [
      const ChatHeader(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  Expanded(
                    child: ListView.builder(
                      itemCount:
                          messages.length +
                          (isLoading ? 1 : 0),

                      itemBuilder:
                          (context, index) {

                        if (index == messages.length) {
                          return ChatBubble(
                            message: "Thinking...",
                            isUser: false,
                            timestamp: DateTime.now(),
                          );
                        }

                        final message = messages[index];

                        return ChatBubble(
                          message: message.text,
                          isUser: message.isUser,
                          timestamp: message.timestamp,
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 10),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,

                    child: Row(
                      children: [
                        QuickActionChip(
                          text: "✨ Record lunch \$15",
                          onTap: () => messageController.text = "Record lunch \$15",
                        ),

                        const SizedBox(width: 10),

                        QuickActionChip(
                          text: "📈 Analyze spending",
                          onTap: () => messageController.text = "Analyze spending",
                        ),

                        const SizedBox(width: 10),

                        QuickActionChip(
                          text: "💰 Set budget",
                          onTap: () => messageController.text = "Set budget",
                        ),

                        const SizedBox(width: 10),

                        QuickActionChip(
                          text: "🔔 Set reminder",
                          onTap: () => messageController.text = "Set reminder",
                        ),

                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  MessageInput(
                    controller: messageController,
                    onSend: sendMessage,
                    onAttachImage: processReceipt,
                    onVoiceInput: startVoiceInput,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }
}