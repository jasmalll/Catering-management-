import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/catering_provider.dart';
import '../services/pdf_service.dart';

class SummaryPage extends StatefulWidget {
  const SummaryPage({super.key});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  late DateTime selectedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedMonth = DateTime(now.year, now.month, 1);
  }

  String get monthLabel {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[selectedMonth.month - 1]} ${selectedMonth.year}';
  }

  String money(double value) => '₹${value.toStringAsFixed(0)}';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CateringProvider>();
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final muted = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);

    final monthlyWorks = provider.works.where((w) => w.date.year == selectedMonth.year && w.date.month == selectedMonth.month).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    final monthlyExpenses = provider.expenses.where((e) => e.date.year == selectedMonth.year && e.date.month == selectedMonth.month).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final totalIncome = monthlyWorks.fold<double>(0, (sum, w) => sum + w.amount);
    final totalReceived = monthlyWorks.fold<double>(0, (sum, w) => sum + (w.amount - w.balance));
    final totalPending = monthlyWorks.fold<double>(0, (sum, w) => sum + w.balance);
    final totalExpenses = monthlyExpenses.fold<double>(0, (sum, e) => sum + e.amount);
    final netSavings = totalReceived - totalExpenses;
    final progress = totalIncome > 0 ? (totalReceived / totalIncome).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
          children: [
            // 1. Consistent Header Row
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: colors.primary.withOpacity(isDark ? 0.18 : 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.insights_rounded, color: colors.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Financial reports',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.6,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Track income, collections and expenses',
                        style: TextStyle(fontSize: 13, color: muted),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.outline.withOpacity(0.35)),
                  ),
                  child: IconButton(
                    tooltip: 'Export PDF Report',
                    icon: const Icon(Icons.picture_as_pdf_outlined, size: 20),
                    color: colors.onSurface,
                    onPressed: () => PdfService.exportMonthlyReport(
                      monthLabel: monthLabel,
                      totalIncome: totalIncome,
                      totalExpenses: totalExpenses,
                      netSavings: netSavings,
                      works: monthlyWorks,
                      expenses: monthlyExpenses,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // 2. Month Selector Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colors.outline.withOpacity(0.35)),
              ),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Previous month',
                    icon: const Icon(Icons.chevron_left_rounded, size: 22),
                    onPressed: () => setState(() => selectedMonth = DateTime(selectedMonth.year, selectedMonth.month - 1, 1)),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          monthLabel,
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: colors.onSurface),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: colors.primary.withOpacity(isDark ? 0.2 : 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${monthlyWorks.length} works',
                                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: colors.primary),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withOpacity(isDark ? 0.2 : 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${monthlyExpenses.length} expenses',
                                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: isDark ? const Color(0xFFFF8A80) : Colors.redAccent),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Next month',
                    icon: const Icon(Icons.chevron_right_rounded, size: 22),
                    onPressed: () => setState(() => selectedMonth = DateTime(selectedMonth.year, selectedMonth.month + 1, 1)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. Cash In Hand Hero Card (Emerald Gradient)
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0C4032), Color(0xFF166F50)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: const Color(0xFF0C4032).withOpacity(0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        )
                      ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CASH IN HAND',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 11,
                      letterSpacing: 1.4,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    money(netSavings),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      letterSpacing: -1,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Received collections minus recorded expenses',
                    style: TextStyle(color: Colors.white.withOpacity(0.72), fontSize: 12),
                  ),
                  const SizedBox(height: 18),
                  Container(height: 1, color: Colors.white.withOpacity(0.18)),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _HeroValue(
                          label: 'Received',
                          value: money(totalReceived),
                          icon: Icons.south_west_rounded,
                          tint: const Color(0xFF83E0B4),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _HeroValue(
                          label: 'Pending',
                          value: money(totalPending),
                          icon: Icons.schedule_rounded,
                          tint: const Color(0xFFFFD18A),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            // 4. Monthly Overview (2x2 Grid)
            Text(
              'Monthly overview',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, letterSpacing: -0.3, color: colors.onSurface),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.45,
              children: [
                _MetricCard(
                  title: 'Total income',
                  value: money(totalIncome),
                  icon: Icons.account_balance_wallet_rounded,
                  iconBg: Colors.teal.withOpacity(0.12),
                  iconColor: Colors.teal,
                  isDark: isDark,
                ),
                _MetricCard(
                  title: 'Expenses',
                  value: money(totalExpenses),
                  icon: Icons.receipt_long_rounded,
                  iconBg: Colors.redAccent.withOpacity(0.12),
                  iconColor: Colors.redAccent,
                  isDark: isDark,
                ),
                _MetricCard(
                  title: 'Cash in hand',
                  value: money(netSavings),
                  icon: Icons.savings_rounded,
                  iconBg: (netSavings >= 0 ? Colors.green : Colors.redAccent).withOpacity(0.12),
                  iconColor: netSavings >= 0 ? Colors.green : Colors.redAccent,
                  isDark: isDark,
                ),
                _MetricCard(
                  title: 'Booked works',
                  value: '${monthlyWorks.length}',
                  icon: Icons.event_available_rounded,
                  iconBg: Colors.blue.withOpacity(0.12),
                  iconColor: Colors.blueAccent,
                  isDark: isDark,
                ),
              ],
            ),
            const SizedBox(height: 22),

            // 5. Collection Progress
            _SectionTitle(
              title: 'Collection progress',
              subtitle: totalIncome > 0 ? '${(progress * 100).round()}% of income collected' : 'No income recorded this month',
              muted: muted,
            ),
            const SizedBox(height: 12),
            _Panel(
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor: isDark ? const Color(0xFF293B37) : const Color(0xFFE2E9E3),
                      valueColor: AlwaysStoppedAnimation(colors.primary),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _Legend(label: 'Received', amount: money(totalReceived), color: colors.primary),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _Legend(label: 'Pending', amount: money(totalPending), color: const Color(0xFFD99A35)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 6. Full-Width Export PDF Button
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                onPressed: () => PdfService.exportMonthlyReport(
                  monthLabel: monthLabel,
                  totalIncome: totalIncome,
                  totalExpenses: totalExpenses,
                  netSavings: netSavings,
                  works: monthlyWorks,
                  expenses: monthlyExpenses,
                ),
                icon: const Icon(Icons.picture_as_pdf_rounded, size: 20),
                label: Text(
                  'Export $monthLabel PDF report',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // 7. Works Breakdown List
            _SectionTitle(
              title: 'Works this month',
              subtitle: '${monthlyWorks.length} bookings · ${money(totalIncome)} total value',
              muted: muted,
            ),
            const SizedBox(height: 12),
            if (monthlyWorks.isEmpty)
              _EmptyPanel(
                icon: Icons.event_busy_rounded,
                title: 'No works this month',
                message: 'Bookings for this month will appear here.',
                isDark: isDark,
              )
            else
              ...monthlyWorks.map((work) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _Panel(
                      isDark: isDark,
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: colors.primary.withOpacity(isDark ? 0.2 : 0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(Icons.event_note_rounded, color: colors.primary, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  work.venue,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: colors.onSurface),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${work.dateText} · ${work.eventType}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 11.5, color: muted),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Balance ${money(work.balance)}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: work.balance > 0 ? const Color(0xFFD99A35) : colors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                money(work.amount),
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: colors.onSurface),
                              ),
                              const SizedBox(height: 5),
                              _StatusPill(label: work.status, paid: work.isPaid, isDark: isDark),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )),
            const SizedBox(height: 18),

            // 8. Expenses Breakdown List
            _SectionTitle(
              title: 'Expenses this month',
              subtitle: '${monthlyExpenses.length} records · ${money(totalExpenses)} total',
              muted: muted,
            ),
            const SizedBox(height: 12),
            if (monthlyExpenses.isEmpty)
              _EmptyPanel(
                icon: Icons.receipt_long_rounded,
                title: 'No expenses this month',
                message: 'Recorded expenses will appear here.',
                isDark: isDark,
              )
            else
              ...monthlyExpenses.map((expense) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _Panel(
                      isDark: isDark,
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withOpacity(isDark ? 0.2 : 0.1),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: const Icon(Icons.receipt_long_rounded, color: Colors.redAccent, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  expense.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: colors.onSurface),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${expense.date.day}/${expense.date.month}/${expense.date.year} · ${expense.category}',
                                  style: TextStyle(fontSize: 11.5, color: muted),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '-${money(expense.amount)}',
                            style: const TextStyle(color: Colors.redAccent, fontSize: 14.5, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                    ),
                  )),
            const SizedBox(height: 30),

            // 9. DANGER ZONE (Clear All System Records)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(isDark ? 0.08 : 0.05),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 20),
                      SizedBox(width: 7),
                      Text(
                        'Danger Zone',
                        style: TextStyle(color: Colors.redAccent, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Reset and clear all booked catering works, received payments, and recorded expenses.',
                    style: TextStyle(fontSize: 12, color: muted),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.redAccent),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent, size: 20),
                      label: const Text(
                        'Reset / Clear All Records',
                        style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      onPressed: () => _showClearAllDataDialog(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Clear All Data Dialog ---
  void _showClearAllDataDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        backgroundColor: Theme.of(context).cardColor,
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 26),
            SizedBox(width: 8),
            Text('Clear All Records?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: const Text(
          'This will permanently delete all catering works, cash collections, and expenses from the application.\n\nThis action cannot be undone.',
          style: TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700], fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              final provider = context.read<CateringProvider>();
              // Provider-ൽ ഉള്ള works-ഉം expenses-ഉം ഒന്നിച്ച് ക്ലിയർ ചെയ്യുന്നു
              provider.works.clear();
              provider.expenses.clear();
              // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
              provider.notifyListeners();

              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: Colors.redAccent,
                  content: Text('All data has been reset successfully!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              );
            },
            child: const Text('Delete Everything'),
          ),
        ],
      ),
    );
  }
}

// --- Supporting Widgets ---

class _HeroValue extends StatelessWidget {
  const _HeroValue({required this.label, required this.value, required this.icon, required this.tint});
  final String label, value;
  final IconData icon;
  final Color tint;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: tint.withOpacity(0.18), borderRadius: BorderRadius.circular(11)),
            child: Icon(icon, color: tint, size: 17),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.white.withOpacity(0.68), fontSize: 11)),
                const SizedBox(height: 2),
                Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
              ],
            ),
          ),
        ],
      );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.isDark,
  });

  final String title, value;
  final IconData icon;
  final Color iconBg, iconColor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outline.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.4, color: scheme.onSurface),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child, required this.isDark});
  final Widget child;
  final bool isDark;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.35)),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
        ),
        child: child,
      );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle, required this.muted});
  final String title, subtitle;
  final Color muted;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800, letterSpacing: -0.3, color: Theme.of(context).colorScheme.onSurface),
          ),
          const SizedBox(height: 2),
          Text(subtitle, style: TextStyle(fontSize: 12, color: muted)),
        ],
      );
}

class _Legend extends StatelessWidget {
  const _Legend({required this.label, required this.amount, required this.color});
  final String label, amount;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11, color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280))),
                const SizedBox(height: 2),
                Text(amount, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onSurface)),
              ],
            ),
          ),
        ],
      );
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.paid, required this.isDark});
  final String label;
  final bool paid;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bg = paid
        ? (isDark ? const Color(0xFF133826) : const Color(0xFFE6F4EA))
        : (isDark ? const Color(0xFF3F2B11) : const Color(0xFFFEF3E6));
    final textColor = paid
        ? (isDark ? const Color(0xFF63E6BE) : const Color(0xFF0D652D))
        : (isDark ? const Color(0xFFFFB74D) : const Color(0xFFB06000));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: TextStyle(color: textColor, fontSize: 10.5, fontWeight: FontWeight.w800)),
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel({required this.icon, required this.title, required this.message, required this.isDark});
  final IconData icon;
  final String title, message;
  final bool isDark;

  @override
  Widget build(BuildContext context) => _Panel(
        isDark: isDark,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Column(
              children: [
                Icon(icon, size: 30, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280)),
                const SizedBox(height: 8),
                Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: 3),
                Text(message, textAlign: TextAlign.center, style: TextStyle(fontSize: 11.5, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280))),
              ],
            ),
          ),
        ),
      );
}
