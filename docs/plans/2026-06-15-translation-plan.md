# Translation Plan — Hardcoded English → Traditional Chinese

**Goal:** Replace all hardcoded English strings with `AppLocalizations` lookups so the app fully supports Traditional Chinese.

**Scope:** ~60 strings across 8 files. No new features, just i18n.

---

## Strings to Add to `app_localizations.dart`

### Analytics — Overview Card
| Key | English | Chinese |
|-----|---------|---------|
| `overview` | Overview | 總覽 |
| `monthly_spent` | Monthly Spent | 本月支出 |
| `budget_limit` | Budget Limit | 預算上限 |
| `today_spending` | Today's Spending | 今日支出 |
| `vs_last_month` | vs Last Month | 與上月比較 |
| `set_a_budget` | Set a budget | 設定預算 |
| `go_to_ai_budget` | Go to AI Assistant and say "Set budget $2000" | 前往 AI 助理說「設定預算 $2000」 |

### Analytics — Monthly Progress Card
| Key | English | Chinese |
|-----|---------|---------|
| `monthly_progress` | Monthly Progress | 每月進度 |
| `remaining` | remaining | 剩餘 |
| `set_budget_track` | Set a budget to track progress | 設定預算以追蹤進度 |
| `percent_used` | {percent}% used | 已使用 {percent}% |

### Analytics — Insights Section
| Key | English | Chinese |
|-----|---------|---------|
| `insights` | Insights | 洞察 |

### Analytics — Chart Section
| Key | English | Chinese |
|-----|---------|---------|
| `budget_vs_spent` | Budget vs Spent | 預算 vs 支出 |
| `category` | Category | 分類 |
| `transactions` | Transactions | 交易紀錄 |

### Analytics — Budget Chart
| Key | English | Chinese |
|-----|---------|---------|
| `budget_progress` | Budget Progress | 預算進度 |
| `set_budget_see_progress` | Set a budget to see progress | 設定預算以查看進度 |
| `on_track` | On track | 正常 |
| `caution` | Caution | 注意 |
| `over_pace` | Over pace | 超支 |
| `over_budget` | Over budget | 超出預算 |
| `no_spending_yet` | No spending yet | 尚無支出 |
| `budget_exhausted` | Budget exhausted | 預算已用完 |
| `days_left_at` | {days} days left at ${rate}/day | 剩餘 {days} 天，每天 ${rate} |

### Insights Service
| Key | English | Chinese |
|-----|---------|---------|
| `start_tracking` | Start Tracking | 開始記錄 |
| `start_tracking_desc` | Record your first transaction to see personalized insights. | 記錄您的第一筆交易，即可看到個人化的洞察。 |
| `keep_going` | Keep Going | 繼續加油 |
| `keep_going_desc` | More data means better insights. Keep tracking! | 更多數據意味著更好的洞察。繼續記錄！ |
| `first_month` | First Month | 第一個月 |
| `first_month_desc` | You've spent ${amount} this month. Next month we can compare! | 您本月已花費 $${amount}。下個月我們可以比較！ |
| `steady_spending` | Steady Spending | 穩定支出 |
| `steady_desc` | Your spending is about the same as last month. | 您的支出與上月大致相同。 |
| `great_progress` | Great Progress! | 表現優秀！ |
| `spending_up` | Spending Up | 支出增加 |
| `spent_less` | You spent {percent}% less than last month. Keep up the good work! | 您比上月少花了 {percent}%。繼續保持！ |
| `spent_more` | You spent {percent}% more than last month. Watch your budget. | 您比上月多花了 {percent}%。請注意預算。 |
| `over_budget_title` | Over Budget | 超出預算 |
| `over_budget_desc` | You've spent {percent}% over your monthly budget. | 您已超出月預算 {percent}%。 |
| `ahead_of_pace` | Ahead of Pace | 支出超前 |
| `on_track_desc` | You're {percent}% through your monthly budget with great pacing. | 您已使用月預算的 {percent}%，進度良好。 |
| `ahead_desc` | You're {percent}% through your budget but only {day}/{total} days in. | 您已使用預算的 {percent}%，但只過了 {day}/{total} 天。 |
| `daily_average` | Daily Average | 每日平均 |
| `daily_avg_desc` | You're averaging ${amount}/day this month. | 您本月平均每天花費 $${amount}。 |
| `{category}_leads` | {category} Leads | {category} 領先 |
| `{category}_biggest` | {category} is your biggest expense at ${amount} ({percent}% of total). | {category} 是您最大的支出，共 $${amount}（佔 {percent}%）。 |

### Chat — Header
| Key | English | Chinese |
|-----|---------|---------|
| `ai_assistant` | AI Assistant | AI 助理 |
| `ready_to_help` | Ready to help | 準備為您服務 |
| `smart_companion` | Your smart financial companion | 您的智慧財務夥伴 |

### Chat — Messages
| Key | English | Chinese |
|-----|---------|---------|
| `welcome_message` | Welcome! How can I help you manage your finances today? | 歡迎！今天我能幫您管理什麼財務呢？ |
| `thinking` | Thinking... | 思考中... |
| `record_lunch` | Record lunch $15 | 記錄午餐 $15 |
| `adjust_budget` | Adjust my budget | 調整預算 |
| `set_spending_limit` | Set spending limit | 設定支出限額 |
| `set_reminder` | 設定提醒 | 設定提醒 |
| `recorded_expense` | I've recorded your expense! | 已記錄您的消費！ |
| `failed_record_expense` | Failed to record expense. | 記錄消費失敗。 |
| `failed_read_receipt` | Failed to read receipt. | 讀取收據失敗。 |
| `suggest_breakdown` | Here's a suggested budget breakdown for ${amount}/month. You can confirm or edit: | 這是每月 $${amount} 的建議預算分配。您可以確認或編輯： |
| `adjust_hint` | You can say things like 'Set food budget to $300' to adjust individual categories. | 您可以說「設定食物預算為 $300」來調整個別類別。 |
| `failed_set_budget` | Failed to set budget. Please try again. | 設定預算失敗，請重試。 |
| `budget_saved` | Budget set! Your ${amount}/month allocation has been saved. | 預算已設定！您的每月 $${amount} 配置已儲存。 |
| `failed_save_budget` | Failed to save budget. | 儲存預算失敗。 |
| `no_budget_found` | No budget found for this month. Say "Set budget $2000" to create one. | 找不到本月預算。說「設定預算 $2000」來建立。 |
| `failed_reset_budget` | Failed to reset budget. | 重設預算失敗。 |
| `failed_save_reminder` | Failed to save reminder. Please try again. | 儲存提醒失敗，請重試。 |
| `failed_analyze` | Failed to analyze spending. | 分析支出失敗。 |
| `failed_budget_plan` | Failed to create budget plan. | 建立預算計畫失敗。 |
| `failed_weekly` | Failed to generate weekly coaching insight. | 產生每週教練洞察失敗。 |

### Chat — Cards
| Key | English | Chinese |
|-----|---------|---------|
| `expense_recorded` | Expense Recorded | 消費已記錄 |
| `suggested_allocation` | Suggested Allocation | 建議配置 |
| `confirmed_allocation` | Confirmed Allocation | 已確認配置 |
| `budget_confirmed` | Budget Confirmed | 預算已確認 |
| `budget_reset` | Budget Reset | 預算已重設 |
| `budget_recorded` | Budget Recorded | 預算已記錄 |
| `reminder_set` | Reminder Set | 提醒已設定 |
| `edit` | Edit | 編輯 |
| `confirm` | Confirm | 確認 |
| `delete` | Delete | 刪除 |

---

## Files to Modify

1. `lib/core/localization/app_localizations.dart` — add ~60 new keys (en + zh)
2. `lib/widgets/analytics/overview_card.dart` — use loc for all labels
3. `lib/widgets/analytics/monthly_progress_card.dart` — use loc for all labels
4. `lib/widgets/analytics/insights_section.dart` — use loc for "Insights"
5. `lib/widgets/analytics/chart_section.dart` — use loc for tab labels
6. `lib/widgets/analytics/budget_chart.dart` — use loc for all labels
7. `lib/widgets/chat/chat_header.dart` — use loc for header text
8. `lib/screens/ai_assistant/ai_chat_page.dart` — use loc for all messages
9. `lib/widgets/ai_assistant/chat_bubble.dart` — use loc for card labels
10. `lib/core/services/insights_service.dart` — pass loc or use keys

---

## Execution Order

1. Add all keys to `app_localizations.dart` (en + zh)
2. Update `overview_card.dart` + `monthly_progress_card.dart`
3. Update `chart_section.dart` + `budget_chart.dart` + `insights_section.dart`
4. Update `chat_header.dart` + `chat_bubble.dart`
5. Update `ai_chat_page.dart`
6. Update `insights_service.dart` (needs context passed or use static keys)

---

## Notes

- `insights_service.dart` is a plain Dart class with no `BuildContext`. Options:
  a. Pass context to `generateInsights()` — breaks separation
  b. Return raw data keys, let the widget translate — cleaner
  c. Use static string keys and translate in the widget — best approach
- `DateFormat('EEEE, MMMM d')` in monthly_progress_card will auto-localize if locale is set correctly
- Quick action chips in chat page also need translation
