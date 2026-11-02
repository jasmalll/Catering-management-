import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/catering_provider.dart';
import '../models/catering_models.dart';
import 'calendar_page.dart';

class ExpensesPage extends StatefulWidget {
  const ExpensesPage({Key? key}) : super(key: key);

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
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

    // Dynamic categories list
    final Set<String> categoriesSet = {'All', 'Travel', 'Food', 'Uniform', 'Other'};
    for (var exp in provider.expenses) {
      if (exp.category.trim().isNotEmpty) {
        categoriesSet.add(exp.category.trim());
      }
    }
    final allCategoryFilters = categoriesSet.toList();

    // Filtered expenses list
    final filteredExpenses = provider.expenses.reversed.where((item) {
      final matchesSearch = item.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          item.subNote.toLowerCase().contains(searchQuery.toLowerCase());

      if (!matchesSearch) return false;

      if (selectedFilter.toLowerCase() == 'all') return true;
      return item.category.toLowerCase() == selectedFilter.toLowerCase();
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
        label: const Text('Add Expense', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
        onPressed: () => _showAddExpenseSheet(context),
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
                    child: Icon(Icons.account_balance_wallet_rounded, color: scheme.primary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Expenses',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6,
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Track daily & catering expenses',
                          style: TextStyle(fontSize: 13, color: muted),
                        ),
                      ],
                    ),
                  ),
                  // Calendar Navigation
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
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CalendarPage()),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Month Selector Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your spendings',
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

              // 2. Search Field & Tune Icon
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: scheme.outline.withOpacity(0.35)),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() => searchQuery = val),
                        style: TextStyle(fontSize: 14, color: scheme.onSurface),
                        decoration: InputDecoration(
                          hintText: 'Search expenses...',
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
                  ),
                  const SizedBox(width: 10),
                  Container(
                    height: 52,
                    width: 52,
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: scheme.outline.withOpacity(0.35)),
                    ),
                    child: Icon(Icons.tune_rounded, color: scheme.onSurface, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 3. Category Filter Chips (Horizontal Scrollable)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: allCategoryFilters.map((category) {
                    final isSelected = selectedFilter.toLowerCase() == category.toLowerCase();
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => setState(() => selectedFilter = category),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
                          decoration: BoxDecoration(
                            color: isSelected ? scheme.primary : theme.cardColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? scheme.primary : scheme.outline.withOpacity(0.35),
                            ),
                          ),
                          child: Text(
                            category,
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
              ),
              const SizedBox(height: 18),

              // 4. Financial Overview (2x2 Grid)
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          icon: Icons.receipt_long_rounded,
                          title: 'Total Expenses',
                          value: '₹${provider.totalExpenses.toStringAsFixed(0)}',
                          iconBg: Colors.redAccent.withOpacity(0.12),
                          iconColor: Colors.redAccent,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricCard(
                          icon: Icons.format_list_bulleted_rounded,
                          title: 'Total Records',
                          value: '${provider.expenses.length}',
                          iconBg: Colors.blue.withOpacity(0.12),
                          iconColor: Colors.blueAccent,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          icon: Icons.directions_bus_filled_rounded,
                          title: 'Travel Trips',
                          value: '${provider.travelCount}',
                          iconBg: Colors.teal.withOpacity(0.12),
                          iconColor: Colors.teal,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricCard(
                          icon: Icons.restaurant_rounded,
                          title: 'Food Entries',
                          value: '${provider.foodCount}',
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

              // 5. Expense Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All Records',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      color: scheme.onSurface,
                    ),
                  ),
                  Text(
                    '${filteredExpenses.length} ${filteredExpenses.length == 1 ? 'record' : 'records'}',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: muted),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Expense List / Empty State
              if (filteredExpenses.isEmpty)
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
                        child: Icon(Icons.receipt_long_rounded, size: 28, color: scheme.primary),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No expenses found',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: scheme.onSurface),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        searchQuery.isNotEmpty
                            ? 'Try another search keyword.'
                            : 'Tap Add Expense to log your first expenditure.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: muted),
                      ),
                    ],
                  ),
                )
              else
                ...filteredExpenses.map((expense) => _buildExpenseCard(expense, context)),
            ],
          ),
        ),
      ),
    );
  }
  // --- 2x2 Metric Card Tile Widget ---
  Widget _buildMetricCard({
    required IconData icon,
    required String title,
    required String value,
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

  // --- Modernized Expense Card ---
  Widget _buildExpenseCard(ExpenseItem expense, BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final muted = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);

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
          // Top Row: Number, Icon, Title, Amount & Menu
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: scheme.primary.withOpacity(isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  expense.number,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: scheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: Icon(expense.icon, size: 16, color: scheme.primary),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  expense.title,
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
              Text(
                '₹${expense.amount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface,
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Options',
                padding: EdgeInsets.zero,
                icon: Icon(Icons.more_vert_rounded, color: muted, size: 20),
                onSelected: (val) {
                  if (val == 'edit') {
                    _showEditExpenseSheet(context, expense);
                  } else if (val == 'delete') {
                    _showDeleteDialog(context, expense.id);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      dense: true,
                      leading: Icon(Icons.edit_outlined, color: Colors.blue),
                      title: Text('Edit'),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      dense: true,
                      leading: Icon(Icons.delete_outline, color: Colors.red),
                      title: Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Bottom Detail Pill Box: Date, Sub Note & Category Pill
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
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 12, color: muted),
                    const SizedBox(width: 4),
                    Text(
                      expense.dateText,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: scheme.onSurface),
                    ),
                  ],
                ),
                Expanded(
                  child: Row(
                    children: [
                      const SizedBox(width: 10),
                      Icon(Icons.location_on_outlined, size: 13, color: muted),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          expense.subNote,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11, color: muted, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: scheme.primary.withOpacity(isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    expense.category,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: scheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  // --- ADD EXPENSE BOTTOM SHEET ---
  void _showAddExpenseSheet(BuildContext context) {
    final titleController = TextEditingController();
    final noteController = TextEditingController();
    final amountController = TextEditingController();
    final customCatController = TextEditingController();

    DateTime selectedExpenseDate = DateTime.now();
    String selectedCat = 'Travel';
    bool isCustom = false;

    final standardCategories = [
      'Travel',
      'Food',
      'Uniform',
      'Provisions / Grocery',
      'Gas & Fuel',
      'Staff Wage',
      'Other / Custom'
    ];

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
                      'Add New Expense',
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
                  controller: titleController,
                  label: 'Expense Description *',
                  hint: 'eg: Chicken 20kg',
                  icon: Icons.edit_note_rounded,
                  isDark: isDark,
                  scheme: scheme,
                ),
                const SizedBox(height: 10),

                // Manual Date Picker Box
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedExpenseDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2035),
                    );
                    if (picked != null) {
                      setModalState(() => selectedExpenseDate = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? scheme.surfaceContainerHighest.withOpacity(0.3) : const Color(0xFFF8FAF8),
                      border: Border.all(color: scheme.outline.withOpacity(0.35)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calendar_today_rounded, size: 16, color: scheme.primary),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Expense Date', style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600])),
                                Text(
                                  '${selectedExpenseDate.day}/${selectedExpenseDate.month}/${selectedExpenseDate.year}',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: scheme.onSurface),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Icon(Icons.keyboard_arrow_down_rounded, color: scheme.onSurfaceVariant),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                _buildModernTextField(
                  controller: amountController,
                  label: 'Amount (₹) *',
                  hint: '0',
                  keyboardType: TextInputType.number,
                  icon: Icons.currency_rupee_rounded,
                  isDark: isDark,
                  scheme: scheme,
                ),
                const SizedBox(height: 10),

                DropdownButtonFormField<String>(
                  value: selectedCat,
                  dropdownColor: theme.cardColor,
                  decoration: _buildInputDecoration('Category', isDark, scheme),
                  items: standardCategories.map((cat) {
                    return DropdownMenuItem(value: cat, child: Text(cat, style: const TextStyle(fontSize: 13)));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setModalState(() {
                        selectedCat = val;
                        isCustom = (val == 'Other / Custom');
                      });
                    }
                  },
                ),

                if (isCustom) ...[
                  const SizedBox(height: 10),
                  _buildModernTextField(
                    controller: customCatController,
                    label: 'Enter Custom Category Name *',
                    hint: 'eg: Ice block, Plastic items etc.',
                    icon: Icons.label_outline_rounded,
                    isDark: isDark,
                    scheme: scheme,
                  ),
                ],
                const SizedBox(height: 10),

                _buildModernTextField(
                  controller: noteController,
                  label: 'Sub Note / Shop Name',
                  hint: 'eg: Daily bazaar Kochi',
                  icon: Icons.storefront_outlined,
                  isDark: isDark,
                  scheme: scheme,
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
                      if (titleController.text.trim().isEmpty) return;

                      final amount = double.tryParse(amountController.text) ?? 0.0;
                      final finalCat = (isCustom && customCatController.text.trim().isNotEmpty)
                          ? customCatController.text.trim()
                          : (isCustom ? 'Other' : selectedCat);

                      final newExpense = ExpenseItem(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        number: '${context.read<CateringProvider>().expenses.length + 1}'.padLeft(2, '0'),
                        title: titleController.text.trim(),
                        subNote: noteController.text.trim().isEmpty ? 'General' : noteController.text.trim(),
                        category: finalCat,
                        date: selectedExpenseDate,
                        amount: amount,
                      );

                      context.read<CateringProvider>().addExpense(newExpense);
                      Navigator.pop(ctx);
                    },
                    child: const Text('Save Expense', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- EDIT EXPENSE BOTTOM SHEET ---
  void _showEditExpenseSheet(BuildContext context, ExpenseItem expense) {
    final titleController = TextEditingController(text: expense.title);
    final amountController = TextEditingController(text: expense.amount.toStringAsFixed(0));
    final noteController = TextEditingController(text: expense.subNote);
    final customCatController = TextEditingController();

    DateTime selectedExpenseDate = expense.date;
    final standardCategories = [
      'Travel',
      'Food',
      'Uniform',
      'Provisions / Grocery',
      'Gas & Fuel',
      'Staff Wage',
      'Other / Custom'
    ];

    bool isCustom = !['Travel', 'Food', 'Uniform', 'Provisions / Grocery', 'Gas & Fuel', 'Staff Wage'].contains(expense.category);
    String selectedCat = isCustom ? 'Other / Custom' : expense.category;
    if (isCustom) {
      customCatController.text = expense.category;
    }

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
                      'Edit Expense',
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
                  controller: titleController,
                  label: 'Expense Title',
                  icon: Icons.edit_note_rounded,
                  isDark: isDark,
                  scheme: scheme,
                ),
                const SizedBox(height: 10),

                // Manual Date Selection
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedExpenseDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2035),
                    );
                    if (picked != null) {
                      setModalState(() => selectedExpenseDate = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? scheme.surfaceContainerHighest.withOpacity(0.3) : const Color(0xFFF8FAF8),
                      border: Border.all(color: scheme.outline.withOpacity(0.35)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calendar_today_rounded, size: 16, color: scheme.primary),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Expense Date', style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600])),
                                Text(
                                  '${selectedExpenseDate.day}/${selectedExpenseDate.month}/${selectedExpenseDate.year}',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: scheme.onSurface),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Icon(Icons.keyboard_arrow_down_rounded, color: scheme.onSurfaceVariant),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                _buildModernTextField(
                  controller: amountController,
                  label: 'Amount (₹)',
                  keyboardType: TextInputType.number,
                  icon: Icons.currency_rupee_rounded,
                  isDark: isDark,
                  scheme: scheme,
                ),
                const SizedBox(height: 10),

                DropdownButtonFormField<String>(
                  value: selectedCat,
                  dropdownColor: theme.cardColor,
                  decoration: _buildInputDecoration('Category', isDark, scheme),
                  items: standardCategories.map((cat) {
                    return DropdownMenuItem(value: cat, child: Text(cat, style: const TextStyle(fontSize: 13)));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setModalState(() {
                        selectedCat = val;
                        isCustom = (val == 'Other / Custom');
                      });
                    }
                  },
                ),

                if (isCustom) ...[
                  const SizedBox(height: 10),
                  _buildModernTextField(
                    controller: customCatController,
                    label: 'Custom Category Name',
                    icon: Icons.label_outline_rounded,
                    isDark: isDark,
                    scheme: scheme,
                  ),
                ],
                const SizedBox(height: 10),

                _buildModernTextField(
                  controller: noteController,
                  label: 'Note / Location',
                  icon: Icons.storefront_outlined,
                  isDark: isDark,
                  scheme: scheme,
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
                      final amount = double.tryParse(amountController.text) ?? expense.amount;
                      final finalCat = (isCustom && customCatController.text.trim().isNotEmpty)
                          ? customCatController.text.trim()
                          : (isCustom ? 'Other' : selectedCat);

                      final updated = expense.copyWith(
                        title: titleController.text,
                        subNote: noteController.text,
                        amount: amount,
                        category: finalCat,
                        date: selectedExpenseDate,
                      );

                      context.read<CateringProvider>().updateExpense(updated);
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

  // --- Helper Widgets for Form Inputs ---
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

  // --- DELETE CONFIRMATION DIALOG ---
  void _showDeleteDialog(BuildContext context, String expenseId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Expense?'),
        content: const Text('Are you sure you want to remove this expense record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              context.read<CateringProvider>().deleteExpense(expenseId);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Expense record deleted!')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
