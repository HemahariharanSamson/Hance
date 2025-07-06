import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('transactions');
  await Hive.openBox('history');
  await Hive.openBox('cancelled');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hfin App',
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.black,
          selectedItemColor: Colors.deepPurpleAccent,
          unselectedItemColor: Colors.grey,
        ),
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1; // 0: history, 1: home, 2: cancelled, 3: plus

  List<Map<String, dynamic>> _transactions = [];
  List<Map<String, dynamic>> _history = [];
  int _nextId = 1;
  static const MethodChannel _channel = MethodChannel('sms_channel');

  late Box _transactionsBox;
  late Box _historyBox;
  late Box _cancelledBox;
  
  // Track which cards are expanded
  Set<int> _expandedCards = {};
  
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
      
      // Add mock data if no data exists
      if (_transactions.isEmpty && _history.isEmpty) {
        _transactions = [
          {
            'id': 1,
            'amount': 120.50,
            'merchant': 'Starbucks',
            'timestamp': DateTime.now().subtract(const Duration(minutes: 10)),
            'tag': null,
          },
          {
            'id': 2,
            'amount': 45.00,
            'merchant': 'Amazon',
            'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
            'tag': null,
          },
        ];
        _nextId = 3;
      } else {
        // Find the highest ID to set _nextId
        int maxId = 0;
        for (final tx in [..._transactions, ..._history, ..._cancelledTransactions]) {
          if (tx['id'] is int && tx['id'] > maxId) {
            maxId = tx['id'];
          }
        }
        _nextId = maxId + 1;
      }
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
    // Simple regex for amount (₹ or Rs or INR), merchant (word after at/from), and timestamp
    final amountRegex = RegExp(r'(?:₹|Rs\.?|INR)\s?(\d+[.,]?\d*)');
    final merchantRegex = RegExp(r'(?:at|from)\s+([A-Za-z0-9 &]+)');
    final amountMatch = amountRegex.firstMatch(text);
    final merchantMatch = merchantRegex.firstMatch(text);
    if (amountMatch != null) {
      final amount = double.tryParse(amountMatch.group(1)!.replaceAll(',', '')) ?? 0.0;
      final merchant = merchantMatch != null ? merchantMatch.group(1)!.trim() : (sender ?? 'Unknown');
      return {
        'id': _nextId,
        'amount': amount,
        'merchant': merchant,
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
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.grey[900],
      child: InkWell(
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
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey,
                  ),
                ],
              ),
              if (isExpanded) ...[
                const SizedBox(height: 4),
                Text(
                  tx['merchant'] ?? 'Unknown Merchant',
                  style: const TextStyle(fontSize: 16, color: Colors.deepPurpleAccent),
                ),
                const SizedBox(height: 4),
                Text(
                  (tx['timestamp'] as DateTime).toLocal().toString(),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 12),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.restaurant, color: Colors.orange),
                    tooltip: 'Food',
                    onPressed: () => _tagTransaction(tx['id'], 'Food'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.lightbulb, color: Colors.blue),
                    tooltip: 'Utility',
                    onPressed: () => _tagTransaction(tx['id'], 'Utility'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.celebration, color: Colors.purple),
                    tooltip: 'Chill',
                    onPressed: () => _tagTransaction(tx['id'], 'Chill'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    tooltip: 'Cancel',
                    onPressed: () => _cancelTransaction(tx['id']),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getBody() {
    switch (_selectedIndex) {
      case 0:
        // History with calendar view
        return _buildCalendarView();
      case 1:
        // Home: show transaction cards
        if (_transactions.isEmpty) {
          return const Center(child: Text('No new transactions.', style: TextStyle(fontSize: 18)));
        }
        return ListView(
          children: _transactions.map(_transactionCard).toList(),
        );
      case 2:
        // Cancelled transactions
        if (_cancelledTransactions.isEmpty) {
          return const Center(child: Text('No cancelled transactions.', style: TextStyle(fontSize: 18)));
        }
        return ListView(
          children: _cancelledTransactions.map((tx) => Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: Colors.grey[850],
            child: ListTile(
              title: Text('₹${tx['amount'].toStringAsFixed(2)}'),
              subtitle: Text('${tx['merchant'] ?? 'Unknown'}\n${(tx['timestamp'] as DateTime).toLocal()}'),
              trailing: Text(tx['tag'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
              isThreeLine: true,
            ),
          )).toList(),
        );
      case 3:
        return const Center(child: Text('Add New', style: TextStyle(fontSize: 24)));
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSplashScreen() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.deepPurple, Colors.black],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Icon/Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.account_balance_wallet,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),
            
            // App Title
            const Text(
              'Hfin',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            
            // Subtitle
            const Text(
              'Smart Transaction Tracker',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 60),
            
            // Loading Animation
            Column(
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                const SizedBox(height: 20),
                Text(
                  _loadingMessage,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isLoading ? null : AppBar(
        title: const Text('Hfin App'),
        centerTitle: true,
      ),
      body: _isLoading ? _buildSplashScreen() : _getBody(),
      bottomNavigationBar: _isLoading ? null : BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.history, color: _selectedIndex == 0 ? Theme.of(context).colorScheme.secondary : Colors.grey),
                onPressed: () => _onItemTapped(0),
                tooltip: 'History',
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, color: _selectedIndex == 2 ? Theme.of(context).colorScheme.secondary : Colors.grey),
                onPressed: () => _onItemTapped(2),
                tooltip: 'Cancelled',
              ),
              const SizedBox(width: 40), // space for FAB
              IconButton(
                icon: Icon(Icons.add, color: _selectedIndex == 3 ? Theme.of(context).colorScheme.secondary : Colors.grey),
                onPressed: () => _onItemTapped(3),
                tooltip: 'Add',
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _isLoading ? null : FloatingActionButton(
        onPressed: () => _onItemTapped(1),
        tooltip: 'Home',
        child: Icon(Icons.home, color: _selectedIndex == 1 ? Colors.white : Colors.grey),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 4.0,
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
    
    return Column(
      children: [
        // Month navigation header
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[900],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.white),
                onPressed: () {
                  setState(() {
                    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
                    _selectedDay = null;
                  });
                },
              ),
              Column(
                children: [
                  Text(
                    '${_getMonthName(_currentMonth.month)} ${_currentMonth.year}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Total: ₹${monthTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.deepPurpleAccent,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: Colors.white),
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
    );
  }

  Widget _buildMonthCalendar(Map<int, double> dailyTotals) {
    final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final firstWeekday = firstDayOfMonth.weekday;
    
    return Column(
      children: [
        // Weekday headers
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                .map((day) => Expanded(
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
        
        // Calendar days
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
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
                child: Container(
                  decoration: BoxDecoration(
                    color: dayTotal > 0 ? Colors.deepPurple.withOpacity(0.3) : Colors.grey[800],
                    borderRadius: BorderRadius.circular(8),
                    border: isToday ? Border.all(color: Colors.deepPurpleAccent, width: 2) : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        day.toString(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isToday ? Colors.deepPurpleAccent : Colors.white,
                        ),
                      ),
                      if (dayTotal > 0) ...[
                        const SizedBox(height: 2),
                        Text(
                          '₹${dayTotal.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.deepPurpleAccent,
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
    
    return Column(
      children: [
        // Day header
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[900],
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  setState(() {
                    _selectedDay = null;
                  });
                },
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${_getMonthName(day.month)} ${day.day}, ${day.year}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Total: ₹${dayTotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.deepPurpleAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Day transactions
        Expanded(
          child: dayTransactions.isEmpty
              ? const Center(
                  child: Text(
                    'No transactions for this day',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: dayTransactions.length,
                  itemBuilder: (context, index) {
                    final tx = dayTransactions[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                      color: Colors.grey[850],
                      child: ListTile(
                        title: Text('₹${tx['amount'].toStringAsFixed(2)}'),
                        subtitle: Text(tx['merchant'] ?? 'Unknown'),
                        trailing: Text(
                          tx['tag'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}