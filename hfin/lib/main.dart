import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Color System - Dual Tone Design (Zomato/Swiggy inspired)
class AppColors {
  // Primary Brand Colors - Zomato Orange
  static const Color primary = Color(0xFFE23744); // Zomato Red-Orange
  static const Color primaryDark = Color(0xFFCB2D3A); // Darker Orange
  static const Color primaryLight = Color(0xFFF15A5A); // Lighter Orange
  
  // Secondary Colors - Neutral
  static const Color secondary = Color(0xFF2D2D2D); // Dark Gray
  static const Color secondaryDark = Color(0xFF1A1A1A); // Darker Gray
  static const Color secondaryLight = Color(0xFF404040); // Lighter Gray
  
  // Dark Mode Colors
  static const Color darkBackground = Color(0xFF121212); // Pure Black
  static const Color darkSurface = Color(0xFF1E1E1E); // Dark Gray
  static const Color darkSurfaceLight = Color(0xFF2D2D2D); // Medium Gray
  static const Color darkCardBackground = Color(0xFF2A2A2A); // Card Gray
  
  // Light Mode Colors
  static const Color lightBackground = Color(0xFFFAFAFA); // Off White
  static const Color lightSurface = Color(0xFFFFFFFF); // Pure White
  static const Color lightSurfaceLight = Color(0xFFF5F5F5); // Light Gray
  static const Color lightCardBackground = Color(0xFFFFFFFF); // White
  
  // Text Colors
  static const Color darkTextPrimary = Color(0xFFFFFFFF); // White
  static const Color darkTextSecondary = Color(0xFFB3B3B3); // Light Gray
  static const Color darkTextTertiary = Color(0xFF808080); // Medium Gray
  
  static const Color lightTextPrimary = Color(0xFF1A1A1A); // Dark Gray
  static const Color lightTextSecondary = Color(0xFF666666); // Medium Gray
  static const Color lightTextTertiary = Color(0xFF999999); // Light Gray
  
  // Semantic Colors
  static const Color success = Color(0xFF4CAF50); // Green
  static const Color warning = Color(0xFFFF9800); // Orange
  static const Color error = Color(0xFFE23744); // Same as primary
  static const Color info = Color(0xFF2196F3); // Blue
  
  // Category Colors - Muted
  static const Color food = Color(0xFFE23744); // Primary Orange
  static const Color utility = Color(0xFF4CAF50); // Green
  static const Color chill = Color(0xFF9C27B0); // Purple
  static const Color transport = Color(0xFF2196F3); // Blue
  static const Color shopping = Color(0xFFFF9800); // Orange
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient darkBackgroundGradient = LinearGradient(
    colors: [darkBackground, darkSurface],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const LinearGradient lightBackgroundGradient = LinearGradient(
    colors: [lightBackground, lightSurface],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [darkCardBackground, darkSurfaceLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient lightCardGradient = LinearGradient(
    colors: [lightCardBackground, lightSurfaceLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('transactions');
  await Hive.openBox('history');
  await Hive.openBox('cancelled');
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = true;

  void toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HFin',
      theme: _isDarkMode ? _buildDarkTheme() : _buildLightTheme(),
      home: MainScreen(
        isDarkMode: _isDarkMode,
        onThemeToggle: toggleTheme,
      ),
      debugShowCheckedModeBanner: false,
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.darkSurface,
        background: AppColors.darkBackground,
        error: AppColors.error,
        onPrimary: AppColors.darkTextPrimary,
        onSecondary: AppColors.darkTextPrimary,
        onSurface: AppColors.darkTextPrimary,
        onBackground: AppColors.darkTextPrimary,
        onError: AppColors.darkTextPrimary,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.darkTextPrimary,
        ),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.darkCardBackground,
        elevation: 8,
        shadowColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.darkTextTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 8,
        shape: CircleBorder(),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.darkTextPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.darkTextPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.darkTextPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.darkTextPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: AppColors.darkTextSecondary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: AppColors.darkTextSecondary,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.darkTextPrimary,
        ),
      ),
      iconTheme: const IconThemeData(
        color: AppColors.darkTextSecondary,
        size: 24,
      ),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.lightSurface,
        background: AppColors.lightBackground,
        error: AppColors.error,
        onPrimary: AppColors.lightTextPrimary,
        onSecondary: AppColors.lightTextPrimary,
        onSurface: AppColors.lightTextPrimary,
        onBackground: AppColors.lightTextPrimary,
        onError: AppColors.lightTextPrimary,
      ),
      scaffoldBackgroundColor: AppColors.lightBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightSurface,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.lightTextPrimary,
        ),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.lightCardBackground,
        elevation: 8,
        shadowColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.lightTextTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 8,
        shape: CircleBorder(),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.lightTextPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.lightTextPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.lightTextPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.lightTextPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: AppColors.lightTextSecondary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: AppColors.lightTextSecondary,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.lightTextPrimary,
        ),
      ),
      iconTheme: const IconThemeData(
        color: AppColors.lightTextSecondary,
        size: 24,
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, required this.isDarkMode, required this.onThemeToggle});

  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;
  late List<Map<String, dynamic>> _transactions;
  late List<Map<String, dynamic>> _history;
  late int _nextId;
  static const MethodChannel _channel = MethodChannel('sms_channel');
  late Box _transactionsBox;
  late Box _historyBox;
  late Box _cancelledBox;
  
  // Track which cards are expanded
  Set<int> _expandedCards = {};
  Set<int> _expandedDeletedCards = {};
  Set<int> _expandedCalendarCards = {};
  
  // Loading state
  bool _isLoading = true;
  String _loadingMessage = 'Initializing...';
  
  // Cancelled transactions list
  List<Map<String, dynamic>> _cancelledTransactions = [];
  
  // Calendar navigation
  DateTime _currentMonth = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedIndex = 1; // 0: history, 1: home, 2: cancelled, 3: plus
    _initApp();
  }

  void _initApp() async {
    setState(() {
      _loadingMessage = 'Initializing storage...';
    });
    
    // Add delay to show the initial message
    await Future.delayed(const Duration(milliseconds: 800));
    
    _initStorage();
    _loadData();
    
    setState(() {
      _loadingMessage = 'Scanning SMS messages...';
    });
    
    // Add delay to show the scanning message
    await Future.delayed(const Duration(milliseconds: 1200));
    
    await _initSmsListener();
    
    // Add final delay before hiding splash screen
    await Future.delayed(const Duration(milliseconds: 500));
    
    setState(() {
      _isLoading = false;
    });
  }

  void _initStorage() {
    _transactionsBox = Hive.box('transactions');
    _historyBox = Hive.box('history');
    _cancelledBox = Hive.box('cancelled');
  }

  void _loadData() {
    // Load transactions
    final savedTransactions = _transactionsBox.get('transactions', defaultValue: <Map<String, dynamic>>[]);
    final savedHistory = _historyBox.get('history', defaultValue: <Map<String, dynamic>>[]);
    final savedCancelled = _cancelledBox.get('cancelled', defaultValue: <Map<String, dynamic>>[]);
    
    setState(() {
      _transactions = _convertFromStorage(savedTransactions);
      _history = _convertFromStorage(savedHistory);
      _cancelledTransactions = _convertFromStorage(savedCancelled);
      
      // Sort transactions by timestamp (latest first)
      _transactions.sort((a, b) => (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime));
      _history.sort((a, b) => (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime));
      _cancelledTransactions.sort((a, b) => (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime));
      
      // Find the highest ID to set _nextId
      int maxId = 0;
      for (final tx in [..._transactions, ..._history, ..._cancelledTransactions]) {
        if (tx['id'] is int && tx['id'] > maxId) {
          maxId = tx['id'];
        }
      }
      _nextId = maxId + 1;
    });
    
    // Load pending transactions from native storage
    _loadPendingTransactions();
  }

  void _loadPendingTransactions() async {
    try {
      final pendingTransactions = await _channel.invokeMethod('getPendingTransactions');
      if (pendingTransactions is List && pendingTransactions.isNotEmpty) {
        setState(() {
          for (final tx in pendingTransactions) {
            if (tx is Map) {
              final transaction = _parseTransactionFromSms(
                tx['body'] as String?,
                tx['sender'] as String?,
                tx['timestamp'] != null ? DateTime.fromMillisecondsSinceEpoch(tx['timestamp'] as int) : null,
              );
              if (transaction != null) {
                _transactions.insert(0, transaction);
                _nextId++;
              }
            }
          }
        });
        // Sort transactions by timestamp (latest first)
        _transactions.sort((a, b) => (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime));
        _saveTransactions();
        // Clear pending transactions after loading
        await _channel.invokeMethod('clearPendingTransactions');
      }
    } catch (e) {
      print('Error loading pending transactions: $e');
    }
  }

  List<Map<String, dynamic>> _convertFromStorage(List<dynamic> data) {
    return data.map((item) {
      final map = Map<String, dynamic>.from(item);
      // Convert timestamp back to DateTime
      if (map['timestamp'] is int) {
        map['timestamp'] = DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int);
      }
      return map;
    }).toList();
  }

  List<Map<String, dynamic>> _convertToStorage(List<Map<String, dynamic>> data) {
    return data.map((item) {
      final map = Map<String, dynamic>.from(item);
      // Convert DateTime to milliseconds for storage
      if (map['timestamp'] is DateTime) {
        map['timestamp'] = (map['timestamp'] as DateTime).millisecondsSinceEpoch;
      }
      return map;
    }).toList();
  }

  void _saveTransactions() {
    _transactionsBox.put('transactions', _convertToStorage(_transactions));
  }

  void _saveHistory() {
    _historyBox.put('history', _convertToStorage(_history));
  }

  void _saveCancelledTransactions() {
    _cancelledBox.put('cancelled', _convertToStorage(_cancelledTransactions));
  }

  Future<void> _initSmsListener() async {
    try {
      // Request SMS permissions
      final bool? hasPermission = await _channel.invokeMethod('requestSmsPermissions');
      if (hasPermission == true) {
        // Scan SMS for today's transactions when app opens
        await _scanTodaySms();
      }
    } catch (e) {
      print('Error initializing SMS scanner: $e');
    }
  }

  Future<void> _scanTodaySms() async {
    try {
      // Get today's SMS and parse for transactions
      final todaySms = await _channel.invokeMethod('getTodaySms');
      if (todaySms is List && todaySms.isNotEmpty) {
        setState(() {
          for (final sms in todaySms) {
            if (sms is Map) {
              final transaction = _parseTransactionFromSms(
                sms['body'] as String?,
                sms['sender'] as String?,
                sms['timestamp'] != null ? DateTime.fromMillisecondsSinceEpoch(sms['timestamp'] as int) : null,
              );
              if (transaction != null) {
                // Create a unique identifier for this transaction based on SMS content and time
                final transactionKey = '${transaction['amount']}_${transaction['merchant']}_${(transaction['timestamp'] as DateTime).millisecondsSinceEpoch ~/ 60000}'; // Round to minute
                
                // Check if this transaction is already in history
                final isInHistory = _history.any((h) {
                  final historyKey = '${h['amount']}_${h['merchant']}_${(h['timestamp'] as DateTime).millisecondsSinceEpoch ~/ 60000}';
                  return historyKey == transactionKey;
                });
                
                // Check if this transaction is already in current transactions
                final isInCurrent = _transactions.any((t) {
                  final currentKey = '${t['amount']}_${t['merchant']}_${(t['timestamp'] as DateTime).millisecondsSinceEpoch ~/ 60000}';
                  return currentKey == transactionKey;
                });
                
                // Check if this transaction was cancelled/deleted
                final isCancelled = _cancelledTransactions.any((c) {
                  final cancelledKey = '${c['amount']}_${c['merchant']}_${(c['timestamp'] as DateTime).millisecondsSinceEpoch ~/ 60000}';
                  return cancelledKey == transactionKey;
                });
                
                if (!isInHistory && !isInCurrent && !isCancelled) {
                  _transactions.insert(0, transaction);
                  _nextId++;
                }
              }
            }
          }
        });
        // Sort transactions by timestamp (latest first)
        _transactions.sort((a, b) => (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime));
        _saveTransactions();
      }
    } catch (e) {
      print('Error scanning today\'s SMS: $e');
    }
  }

  Map<String, dynamic>? _parseTransactionFromSms(String? body, String? sender, DateTime? timeReceived) {
    final text = body ?? '';
    
    // Enhanced regex patterns for better parsing
    final amountRegex = RegExp(r'(?:₹|Rs\.?|INR)\s?(\d+[.,]?\d*)');
    final amountMatch = amountRegex.firstMatch(text);
    
    if (amountMatch != null) {
      final amount = double.tryParse(amountMatch.group(1)!.replaceAll(',', '')) ?? 0.0;
      
      // Parse "from" account (usually starts with "from" or "debited from")
      String? fromAccount;
      final fromRegex = RegExp(r'(?:debited from|from|sent from)\s+([A-Za-z0-9\s]+?)(?:\s+to|\s+account|\s+₹|\s+Rs|$)');
      final fromMatch = fromRegex.firstMatch(text);
      if (fromMatch != null) {
        fromAccount = fromMatch.group(1)?.trim();
      }
      
      // Parse "to" account (usually starts with "to" or "credited to")
      String? toAccount;
      final toRegex = RegExp(r'(?:credited to|to|sent to|paid to)\s+([A-Za-z0-9\s]+?)(?:\s+account|\s+₹|\s+Rs|$)');
      final toMatch = toRegex.firstMatch(text);
      if (toMatch != null) {
        toAccount = toMatch.group(1)?.trim();
      }
      
      // Parse merchant/recipient (fallback to "to" account or sender)
      String merchant = 'Unknown';
      if (toAccount != null && toAccount.isNotEmpty) {
        merchant = toAccount;
      } else {
        // Try to find merchant in the text
        final merchantRegex = RegExp(r'(?:at|from|to)\s+([A-Za-z0-9\s&]+?)(?:\s+₹|\s+Rs|$)');
        final merchantMatch = merchantRegex.firstMatch(text);
        if (merchantMatch != null) {
          merchant = merchantMatch.group(1)?.trim() ?? 'Unknown';
        } else {
          merchant = sender ?? 'Unknown';
        }
      }
      
      return {
        'id': _nextId,
        'amount': amount,
        'merchant': merchant,
        'fromAccount': fromAccount ?? 'Your Account',
        'toAccount': toAccount ?? merchant,
        'timestamp': timeReceived ?? DateTime.now(),
        'tag': null,
      };
    }
    return null;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _tagTransaction(int id, String tag) {
    setState(() {
      final tx = _transactions.firstWhere((t) => t['id'] == id);
      tx['tag'] = tag;
      _history.insert(0, Map<String, dynamic>.from(tx));
      _transactions.removeWhere((t) => t['id'] == id);
    });
    _saveTransactions();
    _saveHistory();
  }

  void _cancelTransaction(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text('Are you sure you want to delete this transaction?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      setState(() {
        final cancelledTx = _transactions.firstWhere((t) => t['id'] == id);
        _cancelledTransactions.insert(0, Map<String, dynamic>.from(cancelledTx));
        _transactions.removeWhere((t) => t['id'] == id);
      });
      _saveTransactions();
      _saveCancelledTransactions();
    }
  }

  Widget _transactionCard(Map<String, dynamic> tx) {
    final isExpanded = _expandedCards.contains(tx['id']);
    final isDark = widget.isDarkMode;
    final isDebited = true; // All transactions are debited for now
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDebited 
              ? AppColors.error.withOpacity(0.3)
              : AppColors.success.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            setState(() {
              if (isExpanded) {
                _expandedCards.remove(tx['id']);
              } else {
                _expandedCards.add(tx['id']);
              }
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '₹${tx['amount'].toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDebited ? AppColors.error : AppColors.success,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDebited 
                                ? AppColors.error.withOpacity(0.1)
                                : AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isDebited ? 'DEBITED' : 'CREDITED',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isDebited ? AppColors.error : AppColors.success,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isDark 
                                ? AppColors.darkSurfaceLight.withOpacity(0.3)
                                : AppColors.lightSurfaceLight.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            isExpanded ? Icons.expand_less : Icons.expand_more,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (isExpanded) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark 
                          ? AppColors.darkSurfaceLight.withOpacity(0.3)
                          : AppColors.lightSurfaceLight.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                                              children: [
                          _buildTransactionDetail(
                            tx['fromAccount'] ?? 'Your Account',
                            tx['toAccount'] ?? tx['merchant'] ?? 'Unknown Merchant'
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow('Date:', _formatDate(tx['timestamp']), Icons.calendar_today),
                          const SizedBox(height: 12),
                          _buildDetailRow('Time:', _formatTime(tx['timestamp']), Icons.access_time),
                        ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      icon: Icons.restaurant,
                      label: 'Food',
                      tooltip: 'Tag as Food',
                      onPressed: () => _tagTransaction(tx['id'], 'Food'),
                    ),
                    _buildActionButton(
                      icon: Icons.lightbulb,
                      label: 'Utility',
                      tooltip: 'Tag as Utility',
                      onPressed: () => _tagTransaction(tx['id'], 'Utility'),
                    ),
                    _buildActionButton(
                      icon: Icons.celebration,
                      label: 'Chill',
                      tooltip: 'Tag as Chill',
                      onPressed: () => _tagTransaction(tx['id'], 'Chill'),
                    ),
                    _buildActionButton(
                      icon: Icons.delete_outline,
                      label: 'Delete',
                      tooltip: 'Delete Transaction',
                      onPressed: () => _cancelTransaction(tx['id']),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionDetail(String fromAccount, String toAccount) {
    final isDark = widget.isDarkMode;
    
    return Row(
      children: [
        Icon(
          Icons.swap_horiz,
          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '$fromAccount → $toAccount',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    final isDark = widget.isDarkMode;
    
    return Row(
      children: [
        Icon(
          icon,
          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          size: 16,
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    final isDark = widget.isDarkMode;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark 
            ? AppColors.darkSurfaceLight.withOpacity(0.3)
            : AppColors.lightSurfaceLight.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(icon, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary, size: 18),
            tooltip: tooltip,
            onPressed: onPressed,
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dateTime.day} ${months[dateTime.month - 1]}, ${dateTime.year}';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final displayMinute = minute.toString().padLeft(2, '0');
    return '$displayHour:$displayMinute $period';
  }

  Widget _getBody() {
    switch (_selectedIndex) {
      case 0:
        // History with calendar view
        return _buildCalendarView();
      case 1:
        // Home: show transaction cards
        if (_transactions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long,
                  size: 64,
                  color: widget.isDarkMode ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                ),
                const SizedBox(height: 16),
                Text(
                  'No new transactions.',
                  style: TextStyle(
                    fontSize: 18,
                    color: widget.isDarkMode ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                  ),
                ),
              ],
            ),
          );
        }
        return ListView(
          children: _transactions.map(_transactionCard).toList(),
        );
      case 2:
        // Cancelled transactions
        if (_cancelledTransactions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.delete_outline,
                  size: 64,
                  color: widget.isDarkMode ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                ),
                const SizedBox(height: 16),
                Text(
                  'No cancelled transactions.',
                  style: TextStyle(
                    fontSize: 18,
                    color: widget.isDarkMode ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                  ),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _cancelledTransactions.length,
          itemBuilder: (context, index) {
            final tx = _cancelledTransactions[index];
            final isDark = widget.isDarkMode;
            final isDebited = true; // All transactions are debited for now
            final isExpanded = _expandedDeletedCards.contains(tx['id']);
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.error.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    setState(() {
                      if (isExpanded) {
                        _expandedDeletedCards.remove(tx['id']);
                      } else {
                        _expandedDeletedCards.add(tx['id']);
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '₹${tx['amount'].toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.error.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'DELETED',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.error,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: isDark 
                                        ? AppColors.darkSurfaceLight.withOpacity(0.3)
                                        : AppColors.lightSurfaceLight.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(
                                    isExpanded ? Icons.expand_less : Icons.expand_more,
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (isExpanded) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark 
                                  ? AppColors.darkSurfaceLight.withOpacity(0.3)
                                  : AppColors.lightSurfaceLight.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                _buildTransactionDetail(
                                  tx['fromAccount'] ?? 'Your Account',
                                  tx['toAccount'] ?? tx['merchant'] ?? 'Unknown Merchant'
                                ),
                                const SizedBox(height: 8),
                                _buildDetailRow('Date:', _formatDate(tx['timestamp']), Icons.calendar_today),
                                const SizedBox(height: 8),
                                _buildDetailRow('Time:', _formatTime(tx['timestamp']), Icons.access_time),
                              ],
                            ),
                          ),
                          if (tx['tag'] != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _getTagColor(tx['tag']).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _getTagColor(tx['tag']).withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                tx['tag']!,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _getTagColor(tx['tag']),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSplashScreen() {
    final isDark = widget.isDarkMode;
    
    return Container(
      color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              const SizedBox(height: 32),
              
              // App Title
              Text(
                'Hfin',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              
              // Subtitle
              Text(
                'Smart Transaction Tracker',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 60),
              
              // Loading Animation
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark 
                      ? AppColors.darkSurfaceLight.withOpacity(0.5)
                      : AppColors.lightSurfaceLight.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                        strokeWidth: 3,
                        backgroundColor: AppColors.primary.withOpacity(0.2),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _loadingMessage,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isLoading ? null : AppBar(
        title: const Text('HFin'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: widget.isDarkMode ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
            onPressed: widget.onThemeToggle,
            tooltip: widget.isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
          ),
        ],
      ),
      body: _isLoading ? _buildSplashScreen() : _getBody(),
      bottomNavigationBar: _isLoading ? null : Container(
        decoration: BoxDecoration(
          color: widget.isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _buildNavItem(
                  icon: Icons.calendar_month,
                  label: 'History',
                  index: 0,
                  isSelected: _selectedIndex == 0,
                ),
                _buildNavItem(
                  icon: Icons.home,
                  label: 'Home',
                  index: 1,
                  isSelected: _selectedIndex == 1,
                ),
                _buildNavItem(
                  icon: Icons.delete_outline,
                  label: 'Deleted',
                  index: 2,
                  isSelected: _selectedIndex == 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
  }) {
    final textColor = widget.isDarkMode ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final selectedColor = AppColors.primary;
    final unselectedColor = widget.isDarkMode ? AppColors.darkTextTertiary : AppColors.lightTextTertiary;
    
    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(index),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? selectedColor : unselectedColor,
                size: 22,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? selectedColor : unselectedColor,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Calendar helper methods
  List<Map<String, dynamic>> _getTransactionsForMonth(DateTime month) {
    return _history.where((tx) {
      final txDate = tx['timestamp'] as DateTime;
      return txDate.year == month.year && txDate.month == month.month;
    }).toList();
  }

  List<Map<String, dynamic>> _getTransactionsForDay(DateTime day) {
    return _history.where((tx) {
      final txDate = tx['timestamp'] as DateTime;
      return txDate.year == day.year && 
             txDate.month == day.month && 
             txDate.day == day.day;
    }).toList();
  }

  double _getTotalForMonth(DateTime month) {
    final monthTransactions = _getTransactionsForMonth(month);
    return monthTransactions.fold(0.0, (sum, tx) => sum + (tx['amount'] as double));
  }

  double _getTotalForDay(DateTime day) {
    final dayTransactions = _getTransactionsForDay(day);
    return dayTransactions.fold(0.0, (sum, tx) => sum + (tx['amount'] as double));
  }

  Map<int, double> _getDailyTotalsForMonth(DateTime month) {
    final monthTransactions = _getTransactionsForMonth(month);
    final dailyTotals = <int, double>{};
    
    for (final tx in monthTransactions) {
      final day = (tx['timestamp'] as DateTime).day;
      dailyTotals[day] = (dailyTotals[day] ?? 0.0) + (tx['amount'] as double);
    }
    
    return dailyTotals;
  }

  Widget _buildCalendarView() {
    final monthTransactions = _getTransactionsForMonth(_currentMonth);
    final dailyTotals = _getDailyTotalsForMonth(_currentMonth);
    final monthTotal = _getTotalForMonth(_currentMonth);
    final isDark = widget.isDarkMode;
    
    return Container(
      color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      child: Column(
        children: [
          // Month navigation header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.darkSurfaceLight : AppColors.lightSurfaceLight,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavigationButton(
                  icon: Icons.chevron_left,
                  onPressed: () {
                    setState(() {
                      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
                      _selectedDay = null;
                    });
                  },
                ),
                Text(
                  '${_getMonthName(_currentMonth.month)} ${_currentMonth.year}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                _buildNavigationButton(
                  icon: Icons.chevron_right,
                  onPressed: () {
                    setState(() {
                      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
                      _selectedDay = null;
                    });
                  },
                ),
              ],
            ),
          ),
          
          // Calendar grid
          Expanded(
            child: _selectedDay == null ? _buildMonthCalendar(dailyTotals) : _buildDayDetails(_selectedDay!),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    final isDark = widget.isDarkMode;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark 
            ? AppColors.darkSurfaceLight.withOpacity(0.3)
            : AppColors.lightSurfaceLight.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(icon, color: AppColors.primary, size: 20),
        onPressed: onPressed,
        style: IconButton.styleFrom(
          padding: const EdgeInsets.all(8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildMonthCalendar(Map<int, double> dailyTotals) {
    final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final firstWeekday = firstDayOfMonth.weekday;
    final isDark = widget.isDarkMode;
    
    return Column(
      children: [
        // Weekday headers
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                .map((day) => Expanded(
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
        
        // Calendar days
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.0,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
            ),
            itemCount: 42, // 6 weeks * 7 days
            itemBuilder: (context, index) {
              final dayOffset = index - (firstWeekday - 1);
              final day = dayOffset + 1;
              
              if (day < 1 || day > daysInMonth) {
                return Container(); // Empty space
              }
              
              final dayTotal = dailyTotals[day] ?? 0.0;
              final isToday = day == DateTime.now().day && 
                             _currentMonth.month == DateTime.now().month && 
                             _currentMonth.year == DateTime.now().year;
              
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedDay = DateTime(_currentMonth.year, _currentMonth.month, day);
                  });
                },
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  decoration: BoxDecoration(
                    color: dayTotal > 0 
                        ? AppColors.primary.withOpacity(0.1)
                        : (isDark 
                            ? AppColors.darkSurfaceLight.withOpacity(0.2)
                            : AppColors.lightSurfaceLight.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(6),
                    border: isToday 
                        ? Border.all(color: AppColors.primary, width: 2)
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        day.toString(),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isToday 
                              ? AppColors.primary 
                              : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                        ),
                      ),
                      if (dayTotal > 0) ...[
                        const SizedBox(height: 1),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            '₹${dayTotal.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 7,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDayDetails(DateTime day) {
    final dayTransactions = _getTransactionsForDay(day);
    final dayTotal = _getTotalForDay(day);
    final isDark = widget.isDarkMode;
    
    return Container(
      color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      child: Column(
        children: [
          // Day header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.darkSurfaceLight : AppColors.lightSurfaceLight,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                _buildNavigationButton(
                  icon: Icons.arrow_back,
                  onPressed: () {
                    setState(() {
                      _selectedDay = null;
                    });
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${_getMonthName(day.month)} ${day.day}, ${day.year}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '₹${dayTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Day transactions
          Expanded(
            child: dayTransactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 48,
                          color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No transactions for this day',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: dayTransactions.length,
                    itemBuilder: (context, index) {
                      final tx = dayTransactions[index];
                      final isDebited = true; // All transactions are debited for now
                      final isExpanded = _expandedCalendarCards.contains(tx['id']);
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDebited 
                                ? AppColors.error.withOpacity(0.3)
                                : AppColors.success.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () {
                              setState(() {
                                if (isExpanded) {
                                  _expandedCalendarCards.remove(tx['id']);
                                } else {
                                  _expandedCalendarCards.add(tx['id']);
                                }
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '₹${tx['amount'].toStringAsFixed(2)}',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: isDebited ? AppColors.error : AppColors.success,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              tx['merchant'] ?? 'Unknown',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          if (tx['tag'] != null) Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: _getTagColor(tx['tag']).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              tx['tag']!,
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: _getTagColor(tx['tag']),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: isDark 
                                                  ? AppColors.darkSurfaceLight.withOpacity(0.3)
                                                  : AppColors.lightSurfaceLight.withOpacity(0.5),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Icon(
                                              isExpanded ? Icons.expand_less : Icons.expand_more,
                                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                              size: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  if (isExpanded) ...[
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: isDark 
                                            ? AppColors.darkSurfaceLight.withOpacity(0.3)
                                            : AppColors.lightSurfaceLight.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        children: [
                                          _buildTransactionDetail(
                                            tx['fromAccount'] ?? 'Your Account',
                                            tx['toAccount'] ?? tx['merchant'] ?? 'Unknown Merchant'
                                          ),
                                          const SizedBox(height: 8),
                                          _buildDetailRow('Date:', _formatDate(tx['timestamp']), Icons.calendar_today),
                                          const SizedBox(height: 8),
                                          _buildDetailRow('Time:', _formatTime(tx['timestamp']), Icons.access_time),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Color _getTagColor(String? tag) {
    switch (tag) {
      case 'Food':
        return AppColors.food;
      case 'Utility':
        return AppColors.utility;
      case 'Chill':
        return AppColors.chill;
      default:
        return widget.isDarkMode ? AppColors.darkTextTertiary : AppColors.lightTextTertiary;
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}