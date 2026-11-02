import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/catering_provider.dart';
import '../models/catering_models.dart';
import '../services/notification_service.dart';
import '../services/pdf_service.dart';
import 'calendar_page.dart';

class WorksPage extends StatefulWidget {
  const WorksPage({Key? key}) : super(key: key);

  @override
  State<WorksPage> createState() => _WorksPageState();
}

class _WorksPageState extends State<WorksPage> {
  String selectedFilter = 'All';
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // മാസത്തിന്റെ പേര് ചുരുക്കി 'Sep 2026' എന്നാക്കി ഓവർഫ്ലോ ഒഴിവാക്കുന്നു
  String get currentMonthText {
    const shortMonths = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final now = DateTime.now();
    return '${shortMonths[now.month - 1]} ${now.year}';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color get _green => const Color(0xFF087A5B);
  Color get _navy => const Color(0xFF153541);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CateringProvider>();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final muted = scheme.onSurfaceVariant;

    final filteredWorks = provider.works.reversed.where((item) {
      final query = searchQuery.trim().toLowerCase();
      final matchesSearch = query.isEmpty ||
          item.venue.toLowerCase().contains(query) ||
          item.location.toLowerCase().contains(query) ||
          item.eventType.toLowerCase().contains(query) ||
          item.number.toLowerCase().contains(query);
      if (!matchesSearch) return false;
      if (selectedFilter == 'Paid') return item.isPaid;
      if (selectedFilter == 'Pending') return !item.isPaid;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton.extended(
        elevation: 5,
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        icon: const Icon(Icons.add_rounded, size: 23),
        label: const Text('Add Work', style: TextStyle(fontWeight: FontWeight.w700)),
        onPressed: () => _showAddWorkSheet(context),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header follows the CaterPro home dashboard visual language.
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isDark ? scheme.primary.withOpacity(.16) : const Color(0xFFE5F1EC),
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: Icon(Icons.work_outline_rounded, color: scheme.primary, size: 25),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Works', style: TextStyle(fontSize: 25, height: 1.1, fontWeight: FontWeight.w800, letterSpacing: -.8, color: scheme.onSurface)),
                        const SizedBox(height: 4),
                        Text('Manage schedule & payments', style: TextStyle(fontSize: 12.5, color: muted)),
                      ],
                    ),
                  ),
                  Material(
                    color: theme.cardColor,
                    shape: CircleBorder(side: BorderSide(color: scheme.outline.withOpacity(.45))),
                    child: IconButton(
                      tooltip: 'Open calendar',
                      icon: const Icon(Icons.calendar_month_rounded),
                      color: scheme.onSurface,
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CalendarPage())),
                    ),
                  ),
                  const SizedBox(width: 7),
                  Material(
                    color: theme.cardColor,
                    shape: CircleBorder(side: BorderSide(color: scheme.outline.withOpacity(.45))),
                    child: IconButton(
                      tooltip: 'Filters',
                      icon: const Icon(Icons.tune_rounded),
                      color: scheme.onSurface,
                      onPressed: () => _showFilterSheet(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              Row(
                children: [
                  Expanded(
                    child: Text('Your bookings', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800, letterSpacing: -.5, color: scheme.onSurface)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: scheme.outline.withOpacity(.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 14, color: scheme.primary),
                        const SizedBox(width: 7),
                        Text(currentMonthText, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: scheme.onSurface)),
                        const SizedBox(width: 3),
                        Icon(Icons.keyboard_arrow_down_rounded, size: 17, color: muted),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              Container(
                height: 54,
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(19),
                  border: Border.all(color: scheme.outline.withOpacity(.55)),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => searchQuery = value),
                  style: TextStyle(fontSize: 14, color: scheme.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Search venue, place or event...',
                    hintStyle: TextStyle(fontSize: 13, color: muted.withOpacity(.75)),
                    prefixIcon: Icon(Icons.search_rounded, color: muted, size: 22),
                    suffixIcon: searchQuery.isEmpty ? null : IconButton(
                      tooltip: 'Clear search',
                      icon: Icon(Icons.close_rounded, color: muted, size: 19),
                      onPressed: () { _searchController.clear(); setState(() => searchQuery = ''); },
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              Row(
                children: ['All', 'Paid', 'Pending'].map((filter) {
                  final selected = selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 9),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () => setState(() => selectedFilter = filter),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 10),
                        decoration: BoxDecoration(
                          color: selected ? scheme.primary : theme.cardColor,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: selected ? scheme.primary : scheme.outline.withOpacity(.55)),
                        ),
                        child: Text(filter, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: selected ? scheme.onPrimary : scheme.onSurface)),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 22),

              Row(
                children: [
                  Expanded(child: _buildStatCard(icon: Icons.event_note_rounded, title: 'Total Works', value: '${provider.totalWorksCount}', tint: const Color(0xFF557CCB))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard(icon: Icons.account_balance_wallet_rounded, title: 'Total Income', value: '₹${provider.totalIncome.toStringAsFixed(0)}', tint: const Color(0xFF168568))),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildStatCard(icon: Icons.check_circle_rounded, title: 'Received', value: '₹${provider.receivedAmount.toStringAsFixed(0)}', tint: const Color(0xFF168568))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard(icon: Icons.hourglass_bottom_rounded, title: 'Pending', value: '₹${provider.pendingAmount.toStringAsFixed(0)}', tint: const Color(0xFFD99A35))),
                ],
              ),
              const SizedBox(height: 25),

              Row(
                children: [
                  Expanded(child: Text('All bookings', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, letterSpacing: -.4, color: scheme.onSurface))),
                  Text('${filteredWorks.length} ${filteredWorks.length == 1 ? 'work' : 'works'}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: muted)),
                ],
              ),
              const SizedBox(height: 13),
              if (filteredWorks.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 42),
                  decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(25), border: Border.all(color: scheme.outline.withOpacity(.45))),
                  child: Column(
                    children: [
                      Container(width: 62, height: 62, decoration: BoxDecoration(color: scheme.primary.withOpacity(.10), shape: BoxShape.circle), child: Icon(Icons.event_busy_rounded, size: 30, color: scheme.primary)),
                      const SizedBox(height: 13),
                      Text('No works found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: scheme.onSurface)),
                      const SizedBox(height: 5),
                      Text(searchQuery.isNotEmpty ? 'Try another search keyword.' : 'Tap Add Work to create your first booking.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12.5, color: muted)),
                    ],
                  ),
                )
              else
                ...filteredWorks.map((work) => _buildWorkCard(work, context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({required IconData icon, required String title, required String value, required Color tint}) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      constraints: const BoxConstraints(minHeight: 112),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: scheme.outline.withOpacity(.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 39, height: 39, decoration: BoxDecoration(color: tint.withOpacity(theme.brightness == Brightness.dark ? .19 : .11), borderRadius: BorderRadius.circular(14)), child: Icon(icon, size: 20, color: theme.brightness == Brightness.dark ? Color.lerp(tint, Colors.white, .25) : tint)),
          const SizedBox(height: 9),
          Text(title, style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant, fontWeight: FontWeight.w500)),
          const SizedBox(height: 3),
          FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(value, style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, letterSpacing: -.5, color: scheme.onSurface))),
        ],
      ),
    );
  }

  Widget _buildWorkCard(WorkItem work, BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final paidColor = work.isPaid ? const Color(0xFF23865D) : const Color(0xFFD58A28);
    final eventTint = isDark ? const Color(0xFF8DB7FF) : const Color(0xFF3568A8);

    Widget detailPill(IconData icon, String text, {Color? color, Color? background}) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(color: background ?? scheme.surfaceContainerHighest.withOpacity(.65), borderRadius: BorderRadius.circular(12)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 14, color: color ?? scheme.onSurfaceVariant), const SizedBox(width: 6), Flexible(child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color ?? scheme.onSurface), maxLines: 1, overflow: TextOverflow.ellipsis))]),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outline.withOpacity(.48)),
        boxShadow: isDark ? null : [BoxShadow(color: const Color(0xFF173D30).withOpacity(.035), blurRadius: 16, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: 38, height: 38, alignment: Alignment.center, decoration: BoxDecoration(color: scheme.primary.withOpacity(.10), borderRadius: BorderRadius.circular(13)), child: Text(work.number, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: scheme.primary))),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(work.venue, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: -.2, color: scheme.onSurface)),
              const SizedBox(height: 5),
              Row(children: [Icon(Icons.location_on_outlined, size: 13, color: scheme.onSurfaceVariant), const SizedBox(width: 3), Expanded(child: Text(work.location, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11.5, color: scheme.onSurfaceVariant)))]),
            ])),
            const SizedBox(width: 7),
            PopupMenuButton<String>(
              tooltip: 'Work options', padding: EdgeInsets.zero, icon: Icon(Icons.more_horiz_rounded, color: scheme.onSurfaceVariant),
              onSelected: (value) {
                if (value == 'edit') _showEditWorkSheet(context, work);
                if (value == 'pdf') PdfService.exportWorkInvoice(work);
                if (value == 'delete') _showDeleteDialog(context, work.id);
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: ListTile(dense: true, leading: Icon(Icons.edit_outlined, color: Colors.blue), title: Text('Edit'))),
                PopupMenuItem(value: 'pdf', child: ListTile(dense: true, leading: Icon(Icons.picture_as_pdf_outlined, color: Colors.green), title: Text('Bill / Invoice'))),
                PopupMenuItem(value: 'delete', child: ListTile(dense: true, leading: Icon(Icons.delete_outline, color: Colors.red), title: Text('Delete'))),
              ],
            ),
          ]),
          const SizedBox(height: 13),
          Row(children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: eventTint.withOpacity(.11), borderRadius: BorderRadius.circular(9)), child: Text(work.eventType, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: eventTint))),
            const Spacer(),
            Text('₹${work.amount.toStringAsFixed(0)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -.4, color: scheme.onSurface)),
          ]),
          const SizedBox(height: 5),
          Row(children: [
            const Spacer(),
            Text('Balance  ₹${work.balance.toStringAsFixed(0)}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: scheme.onSurfaceVariant)),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: Wrap(spacing: 7, runSpacing: 7, children: [
              detailPill(Icons.calendar_today_rounded, work.dateText),
              detailPill(Icons.schedule_rounded, work.reportingTime, color: isDark ? const Color(0xFFFFC56D) : const Color(0xFFB97818), background: isDark ? const Color(0xFF45351F) : const Color(0xFFFFF5E3)),
              if (work.paxCount.isNotEmpty && work.paxCount != 'General') detailPill(Icons.groups_2_outlined, work.paxCount),
            ])),
            const SizedBox(width: 8),
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => context.read<CateringProvider>().togglePaymentStatus(work.id),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
                decoration: BoxDecoration(color: paidColor.withOpacity(isDark ? .20 : .11), borderRadius: BorderRadius.circular(20)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(work.isPaid ? Icons.check_circle_rounded : Icons.pending_rounded, size: 13, color: paidColor), const SizedBox(width: 5), Text(work.status, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: paidColor))]),
              ),
            ),
          ]),
          if (work.note.trim().isNotEmpty) ...[
            const SizedBox(height: 11),
            Container(width: double.infinity, padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: scheme.surfaceContainerHighest.withOpacity(.5), borderRadius: BorderRadius.circular(12)), child: Text('Note: ${work.note}', style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant))),
          ],
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSheetState) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 4, 22, 28),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Filter works', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: scheme.onSurface)),
          const SizedBox(height: 5),
          Text('Choose which bookings you want to see.', style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
          const SizedBox(height: 17),
          ...['All', 'Paid', 'Pending'].map((value) => RadioListTile<String>(contentPadding: EdgeInsets.zero, activeColor: scheme.primary, title: Text(value), value: value, groupValue: selectedFilter, onChanged: (v) { if (v != null) { setState(() => selectedFilter = v); setSheetState(() {}); Navigator.pop(ctx); } })),
        ]),
      )),
    );
  }

  // --- ADD WORK BOTTOM SHEET (With 8 PM Previous Night Auto-Reminder) ---
  void _showAddWorkSheet(BuildContext context) {
    final venueController = TextEditingController();
    final locationController = TextEditingController();
    final amountController = TextEditingController();
    final advanceController = TextEditingController();
    final paxController = TextEditingController();
    final noteController = TextEditingController();

    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = const TimeOfDay(hour: 7, minute: 0);
    String selectedEventType = 'Wedding';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Book Catering Work', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: venueController,
                  decoration: const InputDecoration(
                    labelText: 'Venue / Auditorium Name *',
                    hintText: 'eg: Grand Royal Auditorium',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: locationController,
                        decoration: const InputDecoration(
                          labelText: 'Place / Location *',
                          hintText: 'eg: Kochi',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedEventType,
                        decoration: const InputDecoration(labelText: 'Event Type', border: OutlineInputBorder()),
                        items: ['Wedding', 'Reception', 'Birthday', 'Corporate', 'Other'].map((type) {
                          return DropdownMenuItem(value: type, child: Text(type, style: TextStyle(fontSize: 13)));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setModalState(() => selectedEventType = val);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2025),
                            lastDate: DateTime(2035),
                          );
                          if (picked != null) {
                            setModalState(() => selectedDate = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Event Date', style: TextStyle(fontSize: 10.5, color: Colors.grey)),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today_outlined, size: 13, color: Theme.of(context).colorScheme.onSurface),
                                  const SizedBox(width: 5),
                                  Text(
                                    '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: selectedTime,
                          );
                          if (picked != null) {
                            setModalState(() => selectedTime = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Reporting Time', style: TextStyle(fontSize: 10.5, color: Colors.grey)),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(Icons.schedule, size: 13, color: Theme.of(context).colorScheme.onSurface),
                                  const SizedBox(width: 5),
                                  Text(
                                    selectedTime.format(context),
                                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Total Amount (₹) *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: advanceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Advance (₹)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: paxController,
                        decoration: const InputDecoration(
                          labelText: 'Plates / Pax Count',
                          hintText: 'eg: 800 Pax',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: noteController,
                        decoration: const InputDecoration(
                          labelText: 'Phone / Note',
                          hintText: 'eg: 9876543210',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Colors.white),
                    onPressed: () {
                      if (venueController.text.trim().isEmpty) return;

                      final total = double.tryParse(amountController.text) ?? 0.0;
                      final received = double.tryParse(advanceController.text) ?? 0.0;
                      final balance = (total - received).clamp(0.0, double.infinity);
                      final isPaid = received >= total && total > 0;

                      final newWork = WorkItem(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        number: '${context.read<CateringProvider>().works.length + 1}'.padLeft(2, '0'),
                        venue: venueController.text.trim(),
                        location: locationController.text.trim().isEmpty ? 'General' : locationController.text.trim(),
                        date: selectedDate,
                        reportingTime: selectedTime.format(context),
                        eventType: selectedEventType,
                        paxCount: paxController.text.trim().isEmpty ? 'General' : paxController.text.trim(),
                        note: noteController.text.trim(),
                        amount: total,
                        balance: balance,
                        isPaid: isPaid,
                        status: isPaid ? 'Paid' : 'Pending',
                      );

                      // വർക്ക് ലിസ്റ്റിലേക്ക് ആഡ് ചെയ്യുന്നു
                      context.read<CateringProvider>().addWork(newWork);

                      // തലേദിവസം രാത്രി 8 മണിക്ക് ഓട്ടോമാറ്റിക് അലാറം ഷെഡ്യൂൾ ചെയ്യുന്നു
                      NotificationService.scheduleWorkReminder(newWork);

                      Navigator.pop(ctx);
                    },
                    child: Text('Save Catering Work', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- EDIT WORK BOTTOM SHEET ---
  void _showEditWorkSheet(BuildContext context, WorkItem work) {
    final venueController = TextEditingController(text: work.venue);
    final locationController = TextEditingController(text: work.location);
    final amountController = TextEditingController(text: work.amount.toStringAsFixed(0));
    final advanceController = TextEditingController(text: (work.amount - work.balance).toStringAsFixed(0));
    final paxController = TextEditingController(text: work.paxCount);
    final noteController = TextEditingController(text: work.note);

    DateTime selectedDate = work.date;
    String reportingTime = work.reportingTime;
    String selectedEventType = work.eventType;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Edit Catering Work', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: venueController,
                  decoration: const InputDecoration(labelText: 'Venue Name', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: locationController,
                        decoration: const InputDecoration(labelText: 'Location', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: ['Wedding', 'Reception', 'Birthday', 'Corporate', 'Other'].contains(selectedEventType)
                            ? selectedEventType
                            : 'Other',
                        decoration: const InputDecoration(labelText: 'Event Type', border: OutlineInputBorder()),
                        items: ['Wedding', 'Reception', 'Birthday', 'Corporate', 'Other'].map((type) {
                          return DropdownMenuItem(value: type, child: Text(type, style: TextStyle(fontSize: 13)));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setModalState(() => selectedEventType = val);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2025),
                            lastDate: DateTime(2035),
                          );
                          if (picked != null) {
                            setModalState(() => selectedDate = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Event Date', style: TextStyle(fontSize: 10.5, color: Colors.grey)),
                              const SizedBox(height: 2),
                              Text(
                                '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: const TimeOfDay(hour: 7, minute: 0),
                          );
                          if (picked != null) {
                            setModalState(() => reportingTime = picked.format(context));
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Reporting Time', style: TextStyle(fontSize: 10.5, color: Colors.grey)),
                              const SizedBox(height: 2),
                              Text(
                                reportingTime,
                                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Total (₹)', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: advanceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Received (₹)', border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: paxController,
                        decoration: const InputDecoration(labelText: 'Pax / Plates', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: noteController,
                        decoration: const InputDecoration(labelText: 'Phone / Note', border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Colors.white),
                    onPressed: () {
                      final total = double.tryParse(amountController.text) ?? work.amount;
                      final received = double.tryParse(advanceController.text) ?? (work.amount - work.balance);
                      final isPaid = received >= total;

                      final updated = work.copyWith(
                        venue: venueController.text,
                        location: locationController.text,
                        date: selectedDate,
                        reportingTime: reportingTime,
                        eventType: selectedEventType,
                        paxCount: paxController.text,
                        note: noteController.text,
                        amount: total,
                        balance: (total - received).clamp(0, double.infinity),
                        isPaid: isPaid,
                        status: isPaid ? 'Paid' : 'Pending',
                      );

                      // വിവരങ്ങൾ അപ്‌ഡേറ്റ് ചെയ്യുന്നു
                      context.read<CateringProvider>().updateWork(updated);

                      // മാറ്റിയ തീയതിക്കനുസരിച്ച് നോട്ടിഫിക്കേഷൻ റീഷെഡ്യൂൾ ചെയ്യുന്നു
                      NotificationService.scheduleWorkReminder(updated);

                      Navigator.pop(ctx);
                    },
                    child: Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String workId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Work?'),
        content: Text('Are you sure you want to remove this catering record?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              // വർക്ക് ഡിലീറ്റ് ചെയ്യുന്നു
              context.read<CateringProvider>().deleteWork(workId);

              // ഷെഡ്യൂൾ ചെയ്ത നോട്ടിഫിക്കേഷൻ റദ്ദാക്കുന്നു
              NotificationService.cancelWorkReminder(workId);

              Navigator.pop(ctx);
            },
            child: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}