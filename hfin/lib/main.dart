import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('transactions');
  await Hive.openBox('history');
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
  int _selectedIndex = 1; // 0: history, 1: home, 2: plus

  List<Map<String, dynamic>> _transactions = [];
  List<Map<String, dynamic>> _history = [];
  int _nextId = 1;
  static const MethodChannel _channel = MethodChannel('sms_channel');
  static const EventChannel _smsEventChannel = EventChannel('sms_events');

  late Box _transactionsBox;
  late Box _historyBox;

  @override
  void initState() {
    super.initState();
    _initStorage();
    _loadData();
    _initSmsListener();
  }

  void _initStorage() {
    _transactionsBox = Hive.box('transactions');
    _historyBox = Hive.box('history');
  }

  void _loadData() {
    // Load transactions
    final savedTransactions = _transactionsBox.get('transactions', defaultValue: <Map<String, dynamic>>[]);
    final savedHistory = _historyBox.get('history', defaultValue: <Map<String, dynamic>>[]);
    
    setState(() {
      _transactions = _convertFromStorage(savedTransactions);
      _history = _convertFromStorage(savedHistory);
      
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
        for (final tx in [..._transactions, ..._history]) {
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

  void _initSmsListener() async {
    try {
      // Request SMS permissions
      final bool? hasPermission = await _channel.invokeMethod('requestSmsPermissions');
      if (hasPermission == true) {
        // Listen for incoming SMS
        _smsEventChannel.receiveBroadcastStream().listen((dynamic event) {
          if (event is Map) {
            final tx = _parseTransactionFromSms(
              event['body'] as String?,
              event['sender'] as String?,
              event['timestamp'] != null ? DateTime.fromMillisecondsSinceEpoch(event['timestamp'] as int) : null,
            );
            if (tx != null) {
              setState(() {
                _transactions.insert(0, tx);
                _nextId++;
              });
              _saveTransactions();
            }
          }
        });
      }
    } catch (e) {
      print('Error initializing SMS listener: $e');
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
        _transactions.removeWhere((t) => t['id'] == id);
      });
      _saveTransactions();
    }
  }

  Widget _transactionCard(Map<String, dynamic> tx) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '₹${tx['amount'].toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
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
    );
  }

  Widget _getBody() {
    switch (_selectedIndex) {
      case 0:
        // History
        if (_history.isEmpty) {
          return const Center(child: Text('No transactions in history.', style: TextStyle(fontSize: 18)));
        }
        return ListView(
          children: _history.map((tx) => Card(
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
      case 1:
        // Home: show transaction cards
        if (_transactions.isEmpty) {
          return const Center(child: Text('No new transactions.', style: TextStyle(fontSize: 18)));
        }
        return ListView(
          children: _transactions.map(_transactionCard).toList(),
        );
      case 2:
        return const Center(child: Text('Add New', style: TextStyle(fontSize: 24)));
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hfin App'),
        centerTitle: true,
      ),
      body: _getBody(),
      bottomNavigationBar: BottomAppBar(
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
              const SizedBox(width: 40), // space for FAB
              IconButton(
                icon: Icon(Icons.add, color: _selectedIndex == 2 ? Theme.of(context).colorScheme.secondary : Colors.grey),
                onPressed: () => _onItemTapped(2),
                tooltip: 'Add',
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onItemTapped(1),
        tooltip: 'Home',
        child: Icon(Icons.home, color: _selectedIndex == 1 ? Colors.white : Colors.grey),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 4.0,
      ),
    );
  }
}