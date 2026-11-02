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
  final ScrollController _scrollController = ScrollController();
  bool _showFab = true;

  void _handleScroll() {
    final shouldShow = !_scrollController.hasClients || _scrollController.position.pixels < 24 ||
        _scrollController.position.userScrollDirection == ScrollDirection.forward;
    if (shouldShow != _showFab && mounted) setState(() => _showFab = shouldShow);
  }


  String get currentMonthText {
    const shortMonths = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final now = DateTime.now();
    return '${shortMonths[now.month - 1]} ${now.year}';
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CateringProvider>();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final muted = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);

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
      floatingActionButton: AnimatedScale(
        scale: _showFab ? 1 : 0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        child: FloatingActionButton.extended(
        elevation: 4,
        backgroundColor: scheme.primary,
        foregroundColor: isDark ? Colors.black : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        icon: const Icon(Icons.add_rounded, size: 22),
        label: const Text('Add Work', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
        onPressed: () => _showAddWorkSheet(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Row
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: scheme.primary.withOpacity(isDark ? 0.18 : 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(Icons.business_center_rounded, color: scheme.primary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Works',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6,
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Manage schedule & payments',
                          style: TextStyle(fontSize: 13, color: muted),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: scheme.outline.withOpacity(0.35)),
                    ),
                    child: IconButton(
                      tooltip: 'Open calendar',
                      icon: const Icon(Icons.calendar_month_rounded, size: 20),
                      color: scheme.onSurface,
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CalendarPage())),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: scheme.outline.withOpacity(0.35)),
                    ),
                    child: IconButton(
                      tooltip: 'Advanced Filters',
                      icon: const Icon(Icons.tune_rounded, size: 20),
                      color: scheme.onSurface,
                      onPressed: () => _showFilterSheet(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Month Selector Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your bookings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      color: scheme.onSurface,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: scheme.outline.withOpacity(0.35)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 13, color: scheme.primary),
                        const SizedBox(width: 6),
                        Text(
                          currentMonthText,
                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: scheme.onSurface),
                        ),
                        const SizedBox(width: 3),
                        Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: muted),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Search Field
              Container(
                height: 52,
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: scheme.outline.withOpacity(0.35)),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => searchQuery = value),
                  style: TextStyle(fontSize: 14, color: scheme.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Search by venue, place or event...',
                    hintStyle: TextStyle(fontSize: 13, color: muted.withOpacity(0.7)),
                    prefixIcon: Icon(Icons.search_rounded, color: muted, size: 22),
                    suffixIcon: searchQuery.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear search',
                            icon: Icon(Icons.close_rounded, color: muted, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => searchQuery = '');
                            },
                          ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Filter Chips
              Row(
                children: ['All', 'Paid', 'Pending'].map((filter) {
                  final isSelected = selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => setState(() => selectedFilter = filter),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 9),
                        decoration: BoxDecoration(
                          color: isSelected ? scheme.primary : theme.cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? scheme.primary : scheme.outline.withOpacity(0.35),
                          ),
                        ),
                        child: Text(
                          filter,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? (isDark ? Colors.black : Colors.white)
                                : scheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),

              // Financial Overview (2x2 Grid)
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildOverviewTile(
                          title: 'Total Works',
                          value: '${provider.totalWorksCount}',
                          icon: Icons.assignment_outlined,
                          iconBg: Colors.blue.withOpacity(0.12),
                          iconColor: Colors.blueAccent,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildOverviewTile(
                          title: 'Total Income',
                          value: '₹${provider.totalIncome.toStringAsFixed(0)}',
                          icon: Icons.account_balance_wallet_outlined,
                          iconBg: Colors.teal.withOpacity(0.12),
                          iconColor: Colors.teal,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildOverviewTile(
                          title: 'Received',
                          value: '₹${provider.receivedAmount.toStringAsFixed(0)}',
                          icon: Icons.check_circle_outline_rounded,
                          iconBg: Colors.green.withOpacity(0.12),
                          iconColor: Colors.green,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildOverviewTile(
                          title: 'Pending',
                          value: '₹${provider.pendingAmount.toStringAsFixed(0)}',
                          icon: Icons.hourglass_bottom_rounded,
                          iconBg: Colors.orange.withOpacity(0.12),
                          iconColor: Colors.orangeAccent,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Bookings Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All Bookings',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      color: scheme.onSurface,
                    ),
                  ),
                  Text(
                    '${filteredWorks.length} ${filteredWorks.length == 1 ? 'work' : 'works'}',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: muted),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Works List / Empty State
              if (filteredWorks.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: scheme.outline.withOpacity(0.35)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: scheme.primary.withOpacity(0.10),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.event_busy_rounded, size: 28, color: scheme.primary),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No works found',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: scheme.onSurface),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        searchQuery.isNotEmpty
                            ? 'Try another search keyword.'
                            : 'Tap Add Work to create your first booking.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: muted),
                      ),
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
   // --- Financial Overview Tile ---
  Widget _buildOverviewTile({
    required String title,
    required String value,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required bool isDark,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: scheme.outline.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
                color: scheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Work Card Widget ---
  Widget _buildWorkCard(WorkItem work, BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final muted = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);

    final isPaid = work.isPaid;
    final statusBg = isPaid
        ? (isDark ? const Color(0xFF133826) : const Color(0xFFE6F4EA))
        : (isDark ? const Color(0xFF3F2B11) : const Color(0xFFFEF3E6));
    final statusColor = isPaid
        ? (isDark ? const Color(0xFF63E6BE) : const Color(0xFF0D652D))
        : (isDark ? const Color(0xFFFFB74D) : const Color(0xFFB06000));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: scheme.outline.withOpacity(0.35)),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.025),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: scheme.primary.withOpacity(isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  work.number,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: scheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        work.venue,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(isDark ? 0.2 : 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        work.eventType,
                        style: const TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Work options',
                padding: EdgeInsets.zero,
                icon: Icon(Icons.more_vert_rounded, color: muted, size: 20),
                onSelected: (value) {
                  if (value == 'edit') _showEditWorkSheet(context, work);
                  if (value == 'pdf') PdfService.exportWorkInvoice(work);
                  if (value == 'delete') _showDeleteDialog(context, work.id);
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: ListTile(dense: true, leading: Icon(Icons.edit_outlined, color: Colors.blue), title: Text('Edit')),
                  ),
                  PopupMenuItem(
                    value: 'pdf',
                    child: ListTile(dense: true, leading: Icon(Icons.picture_as_pdf_outlined, color: Colors.green), title: Text('Bill / Invoice')),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: ListTile(dense: true, leading: Icon(Icons.delete_outline, color: Colors.red), title: Text('Delete')),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Location & Amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 14, color: muted),
                  const SizedBox(width: 3),
                  Text(
                    work.location,
                    style: TextStyle(fontSize: 12.5, color: muted, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${work.amount.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: scheme.onSurface,
                        ),
                      ),
                      if (work.balance > 0)
                        Text(
                          'Bal: ₹${work.balance.toStringAsFixed(0)}',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: muted),
                        ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => context.read<CateringProvider>().togglePaymentStatus(work.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPaid ? Icons.check_circle_rounded : Icons.pending_rounded,
                            size: 12,
                            color: statusColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            work.status,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Date, Time, Pax
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? scheme.surfaceContainerHighest.withOpacity(0.35) : const Color(0xFFF8FAF8),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: scheme.outline.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCardInfoItem(Icons.calendar_today_rounded, work.dateText, muted, scheme.onSurface),
                _buildCardInfoItem(
                  Icons.schedule_rounded,
                  'Report: ${work.reportingTime}',
                  Colors.orange[800] ?? Colors.orange,
                  isDark ? const Color(0xFFFFB74D) : const Color(0xFFB06000),
                ),
                if (work.paxCount.isNotEmpty && work.paxCount != 'General')
                  _buildCardInfoItem(Icons.groups_2_outlined, '${work.paxCount} pax', muted, scheme.onSurface)
                else
                  _buildCardInfoItem(Icons.groups_2_outlined, 'General', muted, scheme.onSurface),
              ],
            ),
          ),

          if (work.note.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Note: ${work.note}',
                style: TextStyle(fontSize: 11, color: muted),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCardInfoItem(IconData icon, String text, Color iconColor, Color textColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: iconColor),
        const SizedBox(width: 5),
        Text(
          text,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textColor),
        ),
      ],
    );
  }

  void _showFilterSheet(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: const EdgeInsets.fromLTRB(22, 4, 22, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Filter Works', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: scheme.onSurface)),
              const SizedBox(height: 4),
              Text('Filter bookings based on status', style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
              const SizedBox(height: 14),
              ...['All', 'Paid', 'Pending'].map((value) => RadioListTile<String>(
                    contentPadding: EdgeInsets.zero,
                    activeColor: scheme.primary,
                    title: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    value: value,
                    groupValue: selectedFilter,
                    onChanged: (v) {
                      if (v != null) {
                        setState(() => selectedFilter = v);
                        setSheetState(() {});
                        Navigator.pop(ctx);
                      }
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }
  // --- ADD WORK BOTTOM SHEET ---
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

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 10,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Book Catering Work',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: scheme.onSurface),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                _buildModernTextField(
                  controller: venueController,
                  label: 'Venue / Auditorium Name *',
                  hint: 'eg: Grand Royal Auditorium',
                  icon: Icons.storefront_outlined,
                  isDark: isDark,
                  scheme: scheme,
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: _buildModernTextField(
                        controller: locationController,
                        label: 'Place / Location *',
                        hint: 'eg: Kochi',
                        icon: Icons.location_on_outlined,
                        isDark: isDark,
                        scheme: scheme,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedEventType,
                        dropdownColor: theme.cardColor,
                        decoration: _buildInputDecoration('Event Type', isDark, scheme),
                        items: ['Wedding', 'Reception', 'Birthday', 'Corporate', 'Other'].map((type) {
                          return DropdownMenuItem(value: type, child: Text(type, style: const TextStyle(fontSize: 13)));
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
                        borderRadius: BorderRadius.circular(16),
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
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: isDark ? scheme.surfaceContainerHighest.withOpacity(0.3) : const Color(0xFFF8FAF8),
                            border: Border.all(color: scheme.outline.withOpacity(0.35)),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Event Date', style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600])),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today_outlined, size: 14, color: scheme.primary),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: scheme.onSurface),
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
                        borderRadius: BorderRadius.circular(16),
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
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: isDark ? scheme.surfaceContainerHighest.withOpacity(0.3) : const Color(0xFFF8FAF8),
                            border: Border.all(color: scheme.outline.withOpacity(0.35)),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Reporting Time', style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600])),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  Icon(Icons.schedule_rounded, size: 14, color: scheme.primary),
                                  const SizedBox(width: 6),
                                  Text(
                                    selectedTime.format(context),
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: scheme.onSurface),
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
                      child: _buildModernTextField(
                        controller: amountController,
                        label: 'Total Amount (₹) *',
                        hint: '0',
                        keyboardType: TextInputType.number,
                        icon: Icons.currency_rupee_rounded,
                        isDark: isDark,
                        scheme: scheme,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildModernTextField(
                        controller: advanceController,
                        label: 'Advance (₹)',
                        hint: '0',
                        keyboardType: TextInputType.number,
                        icon: Icons.payments_outlined,
                        isDark: isDark,
                        scheme: scheme,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: _buildModernTextField(
                        controller: paxController,
                        label: 'Plates / Pax Count',
                        hint: 'eg: 800 Pax',
                        icon: Icons.people_outline_rounded,
                        isDark: isDark,
                        scheme: scheme,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildModernTextField(
                        controller: noteController,
                        label: 'Phone / Note',
                        hint: 'eg: 9876543210',
                        icon: Icons.notes_rounded,
                        isDark: isDark,
                        scheme: scheme,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: scheme.primary,
                      foregroundColor: isDark ? Colors.black : Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
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

                      context.read<CateringProvider>().addWork(newWork);
                      NotificationService.scheduleWorkReminder(newWork);
                      Navigator.pop(ctx);
                    },
                    child: const Text('Save Catering Work', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 10,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Edit Catering Work',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: scheme.onSurface),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                _buildModernTextField(
                  controller: venueController,
                  label: 'Venue Name',
                  icon: Icons.storefront_outlined,
                  isDark: isDark,
                  scheme: scheme,
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: _buildModernTextField(
                        controller: locationController,
                        label: 'Location',
                        icon: Icons.location_on_outlined,
                        isDark: isDark,
                        scheme: scheme,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: ['Wedding', 'Reception', 'Birthday', 'Corporate', 'Other'].contains(selectedEventType)
                            ? selectedEventType
                            : 'Other',
                        dropdownColor: theme.cardColor,
                        decoration: _buildInputDecoration('Event Type', isDark, scheme),
                        items: ['Wedding', 'Reception', 'Birthday', 'Corporate', 'Other'].map((type) {
                          return DropdownMenuItem(value: type, child: Text(type, style: const TextStyle(fontSize: 13)));
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
                        borderRadius: BorderRadius.circular(16),
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
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: isDark ? scheme.surfaceContainerHighest.withOpacity(0.3) : const Color(0xFFF8FAF8),
                            border: Border.all(color: scheme.outline.withOpacity(0.35)),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Event Date', style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600])),
                              const SizedBox(height: 3),
                              Text(
                                '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: scheme.onSurface),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
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
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: isDark ? scheme.surfaceContainerHighest.withOpacity(0.3) : const Color(0xFFF8FAF8),
                            border: Border.all(color: scheme.outline.withOpacity(0.35)),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Reporting Time', style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600])),
                              const SizedBox(height: 3),
                              Text(
                                reportingTime,
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: scheme.onSurface),
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
                      child: _buildModernTextField(
                        controller: amountController,
                        label: 'Total (₹)',
                        keyboardType: TextInputType.number,
                        icon: Icons.currency_rupee_rounded,
                        isDark: isDark,
                        scheme: scheme,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildModernTextField(
                        controller: advanceController,
                        label: 'Received (₹)',
                        keyboardType: TextInputType.number,
                        icon: Icons.payments_outlined,
                        isDark: isDark,
                        scheme: scheme,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: _buildModernTextField(
                        controller: paxController,
                        label: 'Pax / Plates',
                        icon: Icons.people_outline_rounded,
                        isDark: isDark,
                        scheme: scheme,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildModernTextField(
                        controller: noteController,
                        label: 'Phone / Note',
                        icon: Icons.notes_rounded,
                        isDark: isDark,
                        scheme: scheme,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: scheme.primary,
                      foregroundColor: isDark ? Colors.black : Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
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

                      context.read<CateringProvider>().updateWork(updated);
                      NotificationService.scheduleWorkReminder(updated);
                      Navigator.pop(ctx);
                    },
                    child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper Methods & Delete Dialog ---
  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    TextInputType? keyboardType,
    required bool isDark,
    required ColorScheme scheme,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: 13.5, color: scheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280)),
        hintText: hint,
        hintStyle: TextStyle(fontSize: 12, color: isDark ? Colors.grey[600] : Colors.grey[400]),
        prefixIcon: icon != null ? Icon(icon, size: 18, color: scheme.primary) : null,
        filled: true,
        fillColor: isDark ? scheme.surfaceContainerHighest.withOpacity(0.3) : const Color(0xFFF8FAF8),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.outline.withOpacity(0.35)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.outline.withOpacity(0.35)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, bool isDark, ColorScheme scheme) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280)),
      filled: true,
      fillColor: isDark ? scheme.surfaceContainerHighest.withOpacity(0.3) : const Color(0xFFF8FAF8),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: scheme.outline.withOpacity(0.35)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: scheme.outline.withOpacity(0.35)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: scheme.primary, width: 1.5),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String workId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Work?'),
        content: const Text('Are you sure you want to remove this catering record?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              context.read<CateringProvider>().deleteWork(workId);
              NotificationService.cancelWorkReminder(workId);
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
