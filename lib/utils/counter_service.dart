import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CounterService {
  static const _storageKey = 'currentNumber';

  static Future<int> getCurrentNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_storageKey) ?? 0;
  }

  static Future<void> saveCurrentNumber(int number) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_storageKey, number);
  }

  static Future<int> generateNextNumber() async {
    final currentNumber = await getCurrentNumber();
    final nextNumber = (currentNumber % 10000) + 1;
    await saveCurrentNumber(nextNumber);
    return nextNumber;
  }
}


class CounterPage extends StatefulWidget {
  @override
  _CounterPageState createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  int _currentNumber = 0;

  @override
  void initState() {
    super.initState();
    _loadCurrentNumber();
  }

  Future<void> _loadCurrentNumber() async {
    final currentNumber = await CounterService.getCurrentNumber();
    setState(() {
      _currentNumber = currentNumber;
    });
  }

  Future<void> _generateNextNumber() async {
    final nextNumber = await CounterService.generateNextNumber();
    setState(() {
      _currentNumber = nextNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Counter'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Current Number:',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              '$_currentNumber',
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _generateNextNumber,
        tooltip: 'Generate Next Number',
        child: Icon(Icons.add),
      ),
    );
  }
}
