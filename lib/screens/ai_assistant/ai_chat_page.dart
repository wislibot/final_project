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
import '../../models/budget_model.dart';
import '../../core/services/budget_allocation_service.dart';

import '../../models/reminder_model.dart';
import '../../repositories/reminder_repository.dart';
import '../../widgets/chat/chat_header.dart';
import '../../core/services/habit_analyzer_service.dart';
import '../../core/services/date_override_service.dart';
import '../../core/services/spending_analyzer_service.dart';
import '../../models/weekly_snapshot_model.dart';
import '../../repositories/weekly_snapshot_repository.dart';
import '../../core/localization/app_localizations.dart';


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

  final List<MessageModel> messages = [];

  bool _welcomeAdded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_welcomeAdded) {
      _welcomeAdded = true;
      final loc = AppLocalizations.of(context);
      messages.add(MessageModel(
        text: loc.welcomeMessage,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    }
  }

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
      final rawIntent = await geminiService.detectIntent(text);
      // Normalize: trim, lowercase, take first word only
      final intent = rawIntent.trim().toLowerCase().split(RegExp(r'\s+')).first;

      switch (intent) {
        case "expense":
          await recordExpense(text);
          break;

        case "budget":
          await setMonthlyBudget(text);
          break;

        case "reset":
          await resetBudget();
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
          final reply = await geminiService.sendMessage(text);
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
    final loc = AppLocalizations.of(context);
    try {
      String response = await geminiService.extractExpense(text);
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
            text: loc.recordingExpense,
            isUser: false,
            timestamp: DateTime.now(),
            card: ExpenseRecordedCard(
              description: transaction.description,
              amount: transaction.amount.toStringAsFixed(2),
              category: transaction.category,
              date: "${transaction.createdAt.month}/${transaction.createdAt.day}/${transaction.createdAt.year}",
            ),
          ),
        );
      });
    } catch (e) {
      setState(() {
        messages.add(
          MessageModel(
            text: "${loc.failedRecordExpense}\n$e",
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
    }
  }

  Future<void> processReceipt() async {
      final loc = AppLocalizations.of(context);
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
              text: "${loc.failedReadReceipt}\n$e",
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
    Future<void> setMonthlyBudget(String text) async {
      final loc = AppLocalizations.of(context);
      try {
        // 1. Extract total amount via Gemini
        String response = await geminiService.extractBudgetAmount(text);
        response = response
            .replaceAll("```json", "")
            .replaceAll("```JSON", "")
            .replaceAll("```", "")
            .trim();

        final data = jsonDecode(response);
        final double totalAmount = double.parse(data["amount"].toString());

        if (totalAmount <= 0) {
          setState(() {
            messages.add(MessageModel(
              text: "Please specify a budget amount greater than zero.",
              isUser: false,
              timestamp: DateTime.now(),
            ));
          });
          return;
        }

        // 2. Fetch recent transactions for smart allocation
        final transactions = await transactionRepository.fetchTransactions();
        final now = DateTime.now();

        // 3. Generate suggested allocation
        final allocationService = BudgetAllocationService();
        final suggestedBudgets = allocationService.suggestAllocation(
          totalAmount,
          now.month,
          now.year,
          recentTransactions: transactions,
        );

        // 4. Build allocations data for the card
        final allocations = suggestedBudgets.map((b) {
          return {
            'category': b.category,
            'amount': b.limit,
            'percent': totalAmount > 0
                ? (b.limit / totalAmount * 100)
                : 0.0,
          };
        }).toList();

        // 5. Show confirmation card
        setState(() {
          messages.add(MessageModel(
            text: loc.suggestBreakdown,
            isUser: false,
            timestamp: DateTime.now(),
            card: BudgetAllocationCard(
              totalBudget: totalAmount.toStringAsFixed(0),
              allocations: allocations,
              onConfirm: () => _confirmBudget(suggestedBudgets, totalAmount),
              onEdit: () {
                setState(() {
                  messages.add(MessageModel(
                    text: loc.adjustHint,
                    isUser: false,
                    timestamp: DateTime.now(),
                  ));
                });
              },
            ),
          ));
        });
      } catch (e) {
        setState(() {
          messages.add(MessageModel(
            text: "${loc.failedSetBudget}\n$e",
            isUser: false,
            timestamp: DateTime.now(),
          ));
        });
      }
    }

    void _confirmBudget(List<BudgetModel> allocations, double totalAmount) async {
      final loc = AppLocalizations.of(context);
      try {
        final now = DateTime.now();
        final budgetsWithMonth = allocations.map((b) => BudgetModel(
          category: b.category,
          limit: b.limit,
          month: now.month,
          year: now.year,
        )).toList();

        await budgetRepository.saveMonthlyBudgets(budgetsWithMonth);

        // Build the allocations data for the confirmed card
        final allocationsData = allocations.map((b) {
          return {
            'category': b.category,
            'amount': b.limit,
            'percent': totalAmount > 0
                ? (b.limit / totalAmount * 100)
                : 0.0,
          };
        }).toList();

        // Find the message with the BudgetAllocationCard and replace it
        setState(() {
          final cardIndex = messages.lastIndexWhere((m) => m.card is BudgetAllocationCard);
          if (cardIndex != -1) {
            final old = messages[cardIndex];
            messages[cardIndex] = MessageModel(
              text: old.text,
              isUser: old.isUser,
              timestamp: old.timestamp,
              card: BudgetAllocationCard(
                totalBudget: totalAmount.toStringAsFixed(0),
                allocations: allocationsData,
                isConfirmed: true,
              ),
            );
          }

          // Add the success message
          messages.add(MessageModel(
            text: loc.budgetSavedMsg,
            isUser: false,
            timestamp: DateTime.now(),
            card: _buildInfoCard(
              icon: Icons.check_circle_rounded,
              iconColor: const Color(0xFF2E7D32),
              bgColor: const Color(0xFFE8F5E9),
              borderColor: const Color(0xFFA5D6A7),
              title: loc.budgetConfirmed,
              fields: {
                "Total": "\$${totalAmount.toStringAsFixed(2)}",
                "Categories": "${allocations.length} categories",
                "Month": "${now.month}/${now.year}",
              },
            ),
          ));
        });
      } catch (e) {
        setState(() {
          messages.add(MessageModel(
            text: "${loc.failedSaveBudget}\n$e",
            isUser: false,
            timestamp: DateTime.now(),
          ));
        });
      }
    }

    Future<void> resetBudget() async {
      final loc = AppLocalizations.of(context);
      try {
        final now = DateTime.now();
        final deleted = await budgetRepository.deleteBudgetsForMonth(now.month, now.year);

        if (deleted > 0) {
          setState(() {
            messages.add(MessageModel(
              text: "Budget reset! Deleted $deleted budget categories for this month.",
              isUser: false,
              timestamp: DateTime.now(),
              card: _buildInfoCard(
                icon: Icons.delete_sweep_rounded,
                iconColor: const Color(0xFFE53935),
                bgColor: const Color(0xFFFFEBEE),
                borderColor: const Color(0xFFEF9A9A),
                title: loc.budgetResetLabel,
                fields: {
                  "Month": "${now.month}/${now.year}",
                  "Deleted": "$deleted categories",
                },
              ),
            ));
          });
        } else {
          setState(() {
            messages.add(MessageModel(
              text: loc.noBudgetFound,
              isUser: false,
              timestamp: DateTime.now(),
            ));
          });
        }
      } catch (e) {
        setState(() {
          messages.add(MessageModel(
            text: "${loc.failedResetBudget}\n$e",
            isUser: false,
            timestamp: DateTime.now(),
          ));
        });
      }
    }

    Future<void> recordReminder(String text) async {
      final loc = AppLocalizations.of(context);
      try {
        String response = await geminiService.extractReminder(text);
        response = response
            .replaceAll("```json", "")
            .replaceAll("```JSON", "")
            .replaceAll("```", "")
            .trim();

        final data = jsonDecode(response);
        final reminder = ReminderModel(
          title: data["title"],
          date: data["date"],
        );

        await reminderRepository.addReminder(reminder);

        setState(() {
          messages.add(
            MessageModel(
              text: "Reminder saved!",
              isUser: false,
              timestamp: DateTime.now(),
              card: _buildInfoCard(
                icon: Icons.notifications_active_rounded,
                iconColor: const Color(0xFFFF8F00),
                bgColor: const Color(0xFFFFF8E1),
                borderColor: const Color(0xFFFFE082),
                title: loc.reminderSet,
                fields: {
                  "Title": reminder.title,
                  "Date": reminder.date,
                },
              ),
            ),
          );
        });
      } catch (e) {
        setState(() {
          messages.add(
            MessageModel(
              text: "${loc.failedSaveReminder}\n$e",
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
        });
      }
    }

  Future<void> analyzeMonthlySpending() async {
    final loc = AppLocalizations.of(context);
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

      final now = DateTime.now();
      final budgets =
          await budgetRepository.fetchBudgetsForMonth(
              now.month, now.year);

      String summary =
          "Total spending: \$${total.toStringAsFixed(2)}\n";

      if (budgets.isNotEmpty) {
        summary += "Budget allocations:\n";
        for (final b in budgets) {
          summary +=
              "  ${b.category}: \$${b.limit.toStringAsFixed(0)} allocated\n";
        }
      }

      summary += "Category breakdown:\n";
      categories.forEach(
        (key, value) {
          final budgeted = budgets.firstWhere(
            (b) => b.category == key,
            orElse: () => BudgetModel(
                category: key, limit: 0),
          );
          final remaining = budgeted.limit - value;
          summary +=
              "  $key: \$${value.toStringAsFixed(2)} spent";
          if (budgeted.limit > 0) {
            summary +=
                " / \$${budgeted.limit.toStringAsFixed(0)} budget (\$${remaining.toStringAsFixed(0)} remaining)";
          }
          summary += "\n";
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
            text: loc.failedAnalyze,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });

    }

  }

  Future<void> createBudgetPlan(
      String text) async {
    final loc = AppLocalizations.of(context);
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
                loc.failedCreateBudget,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );

      });

    }
  }

  Future<void> generateWeeklyCoach() async {
    final loc = AppLocalizations.of(context);
    try {
      final dateService = await DateOverrideService.getInstance();
      final now = dateService.now();
      final daysFromMonday = now.weekday - 1;
      final weekStart = DateTime(now.year, now.month, now.day).subtract(Duration(days: daysFromMonday));
      final weekEnd = weekStart.add(const Duration(days: 6));

      final transactions = await transactionRepository.fetchTransactions();
      final weekTransactions = transactions.where((t) =>
        t.createdAt.isAfter(weekStart.subtract(const Duration(seconds: 1))) &&
        t.createdAt.isBefore(weekEnd.add(const Duration(days: 1)))
      ).toList();

      final snapshotRepo = WeeklySnapshotRepository();
      final existingSnapshots = await snapshotRepo.fetchSnapshots();

      final currentSnapshot = WeeklySnapshotModel.fromTransactions(
        weekStart: weekStart,
        weekEnd: weekEnd,
        transactions: weekTransactions.map((t) =>
          TransactionData(amount: t.amount, category: t.category, date: t.createdAt)
        ).toList(),
      );

      await snapshotRepo.saveSnapshot(currentSnapshot);

      final allSnapshots = [currentSnapshot, ...existingSnapshots];
      final analyzer = SpendingAnalyzerService();
      final trends = analyzer.analyze(allSnapshots);

      final buffer = StringBuffer();
      buffer.writeln("=== Spending History (${allSnapshots.length} weeks) ===\n");

      for (final s in allSnapshots.take(6)) {
        buffer.writeln("Week of ${s.weekStart.month}/${s.weekStart.day}: \$${s.totalSpent.toStringAsFixed(2)} (${s.transactionCount} transactions)");
        final cats = s.categoryBreakdown.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
        for (final c in cats.take(3)) {
          buffer.writeln("  ${c.key}: \$${c.value.toStringAsFixed(2)}");
        }
        buffer.writeln();
      }

      buffer.writeln("=== Trends ===");
      if (trends.weekOverWeekChange != null) {
        final change = trends.weekOverWeekChange!;
        buffer.writeln("Week-over-week: ${change > 0 ? '+' : ''}${change.toStringAsFixed(1)}%");
      }
      buffer.writeln("Average weekly: \$${trends.averageWeeklySpending.toStringAsFixed(2)}");
      buffer.writeln("Savings streak: ${trends.savingsStreak} weeks");
      if (trends.peakDay != null) buffer.writeln("Peak spending day: ${trends.peakDay}");
      buffer.writeln("Consistency score: ${trends.spendingConsistency.toStringAsFixed(1)}% variation");

      if (trends.categoryTrends.isNotEmpty) {
        buffer.writeln("\nCategory trends:");
        for (final entry in trends.categoryTrends.entries) {
          final arrow = entry.value > 0 ? '↑' : '↓';
          buffer.writeln("  ${entry.key}: $arrow${entry.value.abs().toStringAsFixed(1)}%");
        }
      }

      final contextStr = buffer.toString();
      final reply = await geminiService.weeklyReflection(contextStr);

      setState(() {
        messages.add(MessageModel(
          text: reply,
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
    } catch (e) {
      setState(() {
        messages.add(MessageModel(
          text: "${loc.failedWeekly}\n$e",
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
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
                      padding: const EdgeInsets.only(top: 8),
                      itemCount: messages.length + (isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == messages.length) {
                          return ChatBubble(
                            message: loc.thinking,
                            isUser: false,
                            timestamp: DateTime.now(),
                          );
                        }

                        final message = messages[index];

                        return ChatBubble(
                          message: message.text,
                          isUser: message.isUser,
                          timestamp: message.timestamp,
                          card: message.card,
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
                          text: "✨ ${loc.recordLunch}",
                          onTap: () => messageController.text = loc.recordLunch,
                        ),
                        const SizedBox(width: 8),
                        QuickActionChip(
                          text: "📊 ${loc.adjustBudget}",
                          onTap: () => messageController.text = loc.adjustBudget,
                        ),
                        const SizedBox(width: 8),
                        QuickActionChip(
                          text: "💸 ${loc.setSpending}",
                          onTap: () => messageController.text = loc.setSpending,
                        ),
                        const SizedBox(width: 8),
                        QuickActionChip(
                          text: "🔔 ${loc.setReminder}",
                          onTap: () => messageController.text = loc.setReminder,
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

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required Color borderColor,
    required String title,
    required Map<String, String> fields,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: iconColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...fields.entries.map((entry) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  entry.key,
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                ),
                Text(
                  entry.value,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}