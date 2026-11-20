import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/catering_models.dart';
import '../providers/catering_provider.dart';
import '../theme/caterpro_theme_controller.dart';
import 'calendar_page.dart';

class HomeDashboardPage extends StatefulWidget {
  const HomeDashboardPage({super.key});
  @override
  State<HomeDashboardPage> createState() => _HomeDashboardPageState();
}

class _HomeDashboardPageState extends State<HomeDashboardPage> {
  DateTime? _selectedMonth; // null means All time

  Future<void> _chooseMonth(BuildContext context, CateringProvider provider) async {
    final months = provider.moneyFlowMonths;
    final selected = await showDialog<DateTime>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Select month'),
        content: SizedBox(
          width: double.maxFinite,
          height: 320,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: months.length,
            itemBuilder: (context, index) {
              final month = months[index];
              final active = _selectedMonth != null && _selectedMonth!.year == month.year && _selectedMonth!.month == month.month;
              return ListTile(
                title: Text('${_monthName(month.month)} ${month.year}'),
                trailing: active ? Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.primary) : null,
                onTap: () => Navigator.pop(dialogContext, month),
              );
            },
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel'))],
      ),
    );
    if (selected != null && mounted) setState(() => _selectedMonth = selected);
  }

  static String _monthName(int month) => const ['January','February','March','April','May','June','July','August','September','October','November','December'][month - 1];

  String _money(double amount) => '₹${amount.toStringAsFixed(0)}';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CateringProvider>();
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final received = provider.receivedAmount;
    final pending = provider.pendingAmount;
    final expenses = provider.totalExpenses;
    final cashInHand = received - expenses;
    final flow = provider.moneyFlowForMonth(_selectedMonth);
    final flowIncome = flow['income']!;
    final flowExpenses = flow['expenses']!;
    final flowSavings = flow['savings']!;
    final flowPending = flow['pending']!;
    final totalIncome = provider.totalIncome;
    final works = provider.works.toList()..sort((a, b) => b.date.compareTo(a.date));
    final recentWorks = works.take(4).toList();
    final now = DateTime.now();
    const months = ['January','February','March','April','May','June','July','August','September','October','November','December'];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(milliseconds: 650),
          curve: Curves.easeOutCubic,
          builder: (context, progress, child) => Opacity(
            opacity: progress,
            child: Transform.translate(offset: Offset(0, 18 * (1 - progress)), child: child),
          ),
          child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              sliver: SliverList(delegate: SliverChildListDelegate([
                Row(children: [
                  Container(
                    width: 46, height: 46,
                    decoration: BoxDecoration(color: const Color(0xFF142B3A), borderRadius: BorderRadius.circular(15)),
                    child: const Icon(Icons.restaurant_menu_rounded, color: Colors.white, size: 23),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('CaterPro', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.7)),
                    Text('Catering business, under control', style: theme.textTheme.bodySmall?.copyWith(color: theme.textTheme.bodySmall?.color?.withOpacity(.68))),
                  ])),
                  _HeaderIcon(icon: Icons.calendar_month_rounded, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CalendarPage()))),
                  const SizedBox(width: 8),
                  Consumer<CaterProThemeController>(builder: (context, controller, _) => _HeaderIcon(
                    icon: controller.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    onTap: controller.toggle,
                    rotationTurns: controller.isDark ? 1 : 0,
                  )),
                  const SizedBox(width: 4),
                  PopupMenuButton<String>(
                    tooltip: 'Backup & restore',
                    icon: Icon(Icons.more_horiz_rounded, color: theme.colorScheme.onSurface),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    onSelected: (value) {
                      if (value == 'backup') provider.exportBackup(context);
                      if (value == 'restore') provider.restoreBackup(context);
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'backup', child: ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.cloud_upload_outlined), title: Text('Export backup'))),
                      PopupMenuItem(value: 'restore', child: ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.settings_backup_restore_rounded), title: Text('Restore backup'))),
                    ],
                  ),
                ]),
                const SizedBox(height: 28),
                Text('Good ${now.hour < 12 ? 'morning' : now.hour < 17 ? 'afternoon' : 'evening'} 👋', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.8)),
                const SizedBox(height: 5),
                Text('Here is your business overview for today.', style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodySmall?.color?.withOpacity(.75))),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF17394A), Color(0xFF102630)]),
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [BoxShadow(color: const Color(0xFF142B3A).withOpacity(.16), blurRadius: 22, offset: const Offset(0, 10))],
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      const Expanded(child: Text('CASH IN HAND', style: TextStyle(color: Color(0xFFB9CFD5), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.3))),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.white.withOpacity(.10), borderRadius: BorderRadius.circular(30)), child: Text('${months[now.month - 1]} ${now.year}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))),
                    ]),
                    const SizedBox(height: 12),
                    _AnimatedMoneyText(value: cashInHand, prefix: '₹', style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: -1.2)),
                    const SizedBox(height: 7),
                    Text('Received cash minus recorded expenses', style: TextStyle(color: Colors.white.withOpacity(.68), fontSize: 12)),
                    const SizedBox(height: 22),
                    Container(height: 1, color: Colors.white.withOpacity(.14)),
                    const SizedBox(height: 16),
                    Row(children: [
                      Expanded(child: _HeroMiniMetric(label: 'Received', amount: _money(received), icon: Icons.south_west_rounded, color: const Color(0xFF70D9A5))),
                      Container(width: 1, height: 38, color: Colors.white.withOpacity(.16)),
                      const SizedBox(width: 16),
                      Expanded(child: _HeroMiniMetric(label: 'Pending', amount: _money(pending), icon: Icons.schedule_rounded, color: const Color(0xFFFFC66D))),
                    ]),
                  ]),
                ),
                const SizedBox(height: 18),
                _MoneyFlowCard(
                  selectedMonth: _selectedMonth,
                  income: flowIncome, expenses: flowExpenses, savings: flowSavings, pending: flowPending,
                  onSelectAll: () => setState(() => _selectedMonth = null),
                  onSelectMonths: () => _chooseMonth(context, provider),
                ),
                const SizedBox(height: 24),
                const _SectionHeading(title: 'Financial snapshot', subtitle: 'Your numbers at a glance'),
                const SizedBox(height: 13),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.48,
                  children: [
                    _SnapshotCard(title: 'Total income', value: _money(totalIncome), icon: Icons.account_balance_wallet_rounded, tint: const Color(0xFF16865B)),
                    _SnapshotCard(title: 'Expenses', value: _money(expenses), icon: Icons.receipt_long_rounded, tint: const Color(0xFFD65D52)),
                    _SnapshotCard(title: 'Booked works', value: '${provider.totalWorksCount}', icon: Icons.event_available_rounded, tint: const Color(0xFF5579D6), footnote: 'All time'),
                    _SnapshotCard(title: 'Outstanding', value: _money(pending), icon: Icons.hourglass_bottom_rounded, tint: const Color(0xFFD99A35)),
                  ],
                ),
                const SizedBox(height: 25),
                const _SectionHeading(title: 'Money flow', subtitle: 'Received vs pending payments'),
                const SizedBox(height: 13),
                _SurfaceCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Collection progress', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                    Text(totalIncome > 0 ? '${((received / totalIncome).clamp(0.0, 1.0) * 100).round()}% received' : 'No income yet', style: theme.textTheme.labelMedium?.copyWith(color: colors.primary, fontWeight: FontWeight.w800)),
                  ]),
                  const SizedBox(height: 14),
                  ClipRRect(borderRadius: BorderRadius.circular(20), child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: totalIncome > 0 ? (received / totalIncome).clamp(0.0, 1.0) : 0),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) => LinearProgressIndicator(value: value, minHeight: 9, backgroundColor: theme.dividerColor.withOpacity(.7), valueColor: const AlwaysStoppedAnimation(Color(0xFF16865B))),
                  )),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(child: _FlowLegend(label: 'Received', amount: _money(received), dot: const Color(0xFF16865B))),
                    const SizedBox(width: 12),
                    Expanded(child: _FlowLegend(label: 'Pending', amount: _money(pending), dot: const Color(0xFFD99A35))),
                  ]),
                ])),
                const SizedBox(height: 25),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Expanded(child: _SectionHeading(title: 'Recent works', subtitle: 'Your latest event bookings')),
                  Text('${provider.works.length} total', style: theme.textTheme.labelMedium?.copyWith(color: theme.textTheme.bodySmall?.color?.withOpacity(.7), fontWeight: FontWeight.w700)),
                ]),
                const SizedBox(height: 13),
                if (recentWorks.isEmpty)
                  _SurfaceCard(child: Padding(padding: const EdgeInsets.symmetric(vertical: 20), child: Center(child: Column(children: [
                    Container(width: 56, height: 56, decoration: BoxDecoration(color: colors.primary.withOpacity(.09), shape: BoxShape.circle), child: Icon(Icons.event_note_rounded, color: colors.primary, size: 26)),
                    const SizedBox(height: 12),
                    Text('Your next event starts here', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 5),
                    Text('Add a work from the Works tab to see it here.', textAlign: TextAlign.center, style: theme.textTheme.bodySmall?.copyWith(color: theme.textTheme.bodySmall?.color?.withOpacity(.7))),
                  ]))))
                else
                  ...recentWorks.map((work) => Padding(padding: const EdgeInsets.only(bottom: 10), child: _RecentWorkCard(work: work))),
                const SizedBox(height: 6),
              ])),
            ),
          ],
          ),
        ),
      ),
    );
  }
}

class _MoneyFlowCard extends StatelessWidget {
  const _MoneyFlowCard({required this.selectedMonth, required this.income, required this.expenses, required this.savings, required this.pending, required this.onSelectAll, required this.onSelectMonths});
  final DateTime? selectedMonth;
  final double income, expenses, savings, pending;
  final VoidCallback onSelectAll, onSelectMonths;

  String _money(double value) => '₹${value.round()}';
  String _percent(double value) => income > 0 ? '${(value / income * 100).round()}%' : '0%';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const green = Color(0xFF16865B);
    const red = Color(0xFFD94F4F);
    const blue = Color(0xFF3979E8);
    const orange = Color(0xFFE6A02E);
    return _SurfaceCard(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(Icons.bar_chart_rounded, color: theme.colorScheme.onSurface, size: 22),
        const SizedBox(width: 9),
        Expanded(child: Text('Monthly Money Flow', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900))),
        PopupMenuButton<String>(
          tooltip: 'Choose all time or a month',
          onSelected: (value) { if (value == 'all') onSelectAll(); if (value == 'months') onSelectMonths(); },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'all', child: Row(children: [Icon(Icons.all_inclusive_rounded, size: 19), SizedBox(width: 10), Text('All') ])),
            PopupMenuItem(value: 'months', child: Row(children: [Icon(Icons.calendar_month_rounded, size: 19), SizedBox(width: 10), Text('Months') ])),
          ],
          child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9), decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(.08), borderRadius: BorderRadius.circular(24), border: Border.all(color: theme.colorScheme.primary.withOpacity(.25))), child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(selectedMonth == null ? 'All' : '${_monthLabel(selectedMonth!.month)} ${selectedMonth!.year}', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(width: 7), const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
          ])),
        ),
      ]),
      const SizedBox(height: 18),
      Row(children: [
        Expanded(flex: 5, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_money(income), maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -.8)),
          const SizedBox(height: 4), Text('Total Income', style: theme.textTheme.bodySmall?.copyWith(color: theme.textTheme.bodySmall?.color?.withOpacity(.72))),
        ])),
        SizedBox(width: 104, height: 104, child: CustomPaint(painter: _MoneyFlowDonutPainter(values: [expenses, savings > 0 ? savings : 0, pending], colors: [red, blue, orange], trackColor: theme.dividerColor.withOpacity(.5)), child: Center(child: Text('100%', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900))))),
        const SizedBox(width: 12),
        Expanded(flex: 6, child: Column(children: [
          _MoneyFlowLegend(label: 'Income', amount: _money(income), percent: '100%', color: green),
          const SizedBox(height: 9),
          _MoneyFlowLegend(label: 'Expenses', amount: _money(expenses), percent: _percent(expenses), color: red),
          const SizedBox(height: 9),
          _MoneyFlowLegend(label: 'Savings', amount: _money(savings), percent: _percent(savings), color: blue),
          const SizedBox(height: 9),
          _MoneyFlowLegend(label: 'Pending', amount: _money(pending), percent: _percent(pending), color: orange),
        ])),
      ]),
      if (savings < 0) Padding(padding: const EdgeInsets.only(top: 10), child: Text('Expenses exceed received payments by ${_money(savings.abs())}.', style: theme.textTheme.bodySmall?.copyWith(color: red))),
    ]));
  }

  static String _monthLabel(int month) => const ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][month - 1];
}

class _MoneyFlowLegend extends StatelessWidget {
  const _MoneyFlowLegend({required this.label, required this.amount, required this.percent, required this.color});
  final String label, amount, percent; final Color color;
  @override
  Widget build(BuildContext context) => FittedBox(
    fit: BoxFit.scaleDown,
    alignment: Alignment.centerLeft,
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 5),
      Text(label, style: Theme.of(context).textTheme.bodySmall),
      const SizedBox(width: 6),
      Text(amount, style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800)),
      const SizedBox(width: 4),
      Text(percent, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w800)),
    ]),
  );
}

class _MoneyFlowDonutPainter extends CustomPainter {
  _MoneyFlowDonutPainter({required this.values, required this.colors, required this.trackColor});
  final List<double> values; final List<Color> colors; final Color trackColor;
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final stroke = size.width * .14;
    final center = rect.center;
    final radius = (size.width - stroke) / 2;
    final bounds = Rect.fromCircle(center: center, radius: radius);
    final track = Paint()..color = trackColor..style = PaintingStyle.stroke..strokeWidth = stroke;
    canvas.drawCircle(center, radius, track);
    final total = values.fold<double>(0, (a, b) => a + (b > 0 ? b : 0));
    if (total <= 0) return;
    var start = -1.57079632679;
    for (var i = 0; i < values.length; i++) {
      final value = values[i] > 0 ? values[i] : 0;
      if (value == 0) continue;
      final sweep = value / total * 6.28318530718;
      final paint = Paint()..color = colors[i]..style = PaintingStyle.stroke..strokeWidth = stroke..strokeCap = StrokeCap.butt;
      canvas.drawArc(bounds, start, sweep, false, paint);
      start += sweep;
    }
  }
  @override
  bool shouldRepaint(covariant _MoneyFlowDonutPainter oldDelegate) => values != oldDelegate.values || colors != oldDelegate.colors || trackColor != oldDelegate.trackColor;
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({required this.icon, required this.onTap, this.rotationTurns = 0.0});
  final IconData icon;
  final VoidCallback onTap;
  final double rotationTurns;
  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).cardColor,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: Theme.of(context).dividerColor)),
    child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(14), child: SizedBox(width: 40, height: 40, child: Center(child: AnimatedRotation(turns: rotationTurns, duration: const Duration(milliseconds: 500), curve: Curves.easeInOutCubic, child: Icon(icon, size: 19, color: Theme.of(context).colorScheme.onSurface))))),
  );
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.subtitle});
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -.35)),
    const SizedBox(height: 3),
    Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.7))),
  ]);
}

class _HeroMiniMetric extends StatelessWidget {
  const _HeroMiniMetric({required this.label, required this.amount, required this.icon, required this.color});
  final String label; final String amount; final IconData icon; final Color color;
  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 34, height: 34, decoration: BoxDecoration(color: color.withOpacity(.14), borderRadius: BorderRadius.circular(11)), child: Icon(icon, color: color, size: 17)),
    const SizedBox(width: 9),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(color: Colors.white.withOpacity(.65), fontSize: 11)), const SizedBox(height: 3), _AnimatedValueText(value: amount, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800))])),
  ]);
}

class _SnapshotCard extends StatelessWidget {
  const _SnapshotCard({required this.title, required this.value, required this.icon, required this.tint, this.footnote});
  final String title; final String value; final IconData icon; final Color tint; final String? footnote;
  @override
  Widget build(BuildContext context) => _SurfaceCard(padding: const EdgeInsets.all(15), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Row(children: [Container(width: 34, height: 34, decoration: BoxDecoration(color: tint.withOpacity(.11), borderRadius: BorderRadius.circular(11)), child: Icon(icon, color: tint, size: 18)), const Spacer(), if (footnote != null) Text(footnote!, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.65))) ]),
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.72))), const SizedBox(height: 4), FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 21, fontWeight: FontWeight.w900, letterSpacing: -.7))) ]),
  ]));
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({required this.child, this.padding = const EdgeInsets.all(18)});
  final Widget child; final EdgeInsets padding;
  @override
  Widget build(BuildContext context) => Container(padding: padding, decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(22), border: Border.all(color: Theme.of(context).dividerColor)), child: child);
}

class _FlowLegend extends StatelessWidget {
  const _FlowLegend({required this.label, required this.amount, required this.dot});
  final String label; final String amount; final Color dot;
  @override
  Widget build(BuildContext context) => Row(children: [Container(width: 8, height: 8, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)), const SizedBox(width: 7), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.72))), const SizedBox(height: 3), Text(amount, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900))]))]);
}

class _RecentWorkCard extends StatelessWidget {
  const _RecentWorkCard({required this.work});
  final WorkItem work;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final paidColor = const Color(0xFF16865B);
    final statusColor = work.isPaid ? paidColor : const Color(0xFFD99A35);
    return Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: theme.dividerColor)), child: Row(children: [
      Container(width: 46, height: 46, decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(.09), borderRadius: BorderRadius.circular(15)), child: Icon(work.icon, color: theme.colorScheme.primary, size: 22)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(work.venue, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text('${work.eventType}  ·  ${work.dateText}', maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall?.copyWith(color: theme.textTheme.bodySmall?.color?.withOpacity(.7))),
        const SizedBox(height: 7),
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: statusColor.withOpacity(.11), borderRadius: BorderRadius.circular(30)), child: Text(work.isPaid ? 'PAID' : 'PAYMENT PENDING', style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: .4))),
      ])),
      const SizedBox(width: 10),
      Text('₹${work.amount.toStringAsFixed(0)}', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -.4)),
    ]));
  }
}


/// Lightweight number animation; keeps the existing displayed value and formatting.
class _AnimatedValueText extends StatelessWidget {
  const _AnimatedValueText({required this.value, this.style, this.maxLines, this.overflow});
  final String value;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    final numeric = double.tryParse(value.replaceAll(RegExp(r'[^0-9.\-]'), ''));
    if (numeric == null) return Text(value, style: style, maxLines: maxLines, overflow: overflow);
    final prefix = value.startsWith('₹') ? '₹' : '';
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: numeric),
      duration: const Duration(milliseconds: 850),
      curve: Curves.easeOutCubic,
      builder: (context, current, _) => Text('$prefix${current.round()}', style: style),
    );
  }
}

class _AnimatedMoneyText extends StatelessWidget {
  const _AnimatedMoneyText({required this.value, required this.prefix, required this.style});
  final double value;
  final String prefix;
  final TextStyle style;
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween<double>(begin: 0, end: value),
    duration: const Duration(milliseconds: 950),
    curve: Curves.easeOutCubic,
    builder: (context, current, _) => Text('$prefix${current.round()}', style: style),
  );
}
