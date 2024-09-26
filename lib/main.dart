import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: DigitalPetApp(),
  ));
}

class DigitalPetApp extends StatefulWidget {
  @override
  _DigitalPetAppState createState() => _DigitalPetAppState();
}

class _DigitalPetAppState extends State<DigitalPetApp> {
  String petName = "Your Pet";
  int happinessLevel = 50;
  int hungerLevel = 50;
  int _energyLevel = 50;
  Timer? _hungerTimer;
  Timer? _winCheckTimer;
  bool _hasWon = false;
  bool _isGameOver = false;

  @override
  void initState() {
    super.initState();
    _startHungerTimer();
    _startWinCheckTimer();
  }

  void _startHungerTimer() {
    _hungerTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      _incrementHunger();
    });
  }

  void _startWinCheckTimer() {
    _winCheckTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      _checkWinCondition();
      _checkGameOverCondition();
    });
  }

  void _incrementHunger() {
    setState(() {
      hungerLevel = (hungerLevel + 5).clamp(0, 100);
      happinessLevel = (happinessLevel - 10).clamp(0, 100);
      _energyLevel = happinessLevel;
      if (hungerLevel >= 100) {
        hungerLevel = 100;
        happinessLevel = (happinessLevel - 20).clamp(0, 100);
      }
    });
  }

  void _checkWinCondition() {
    if (happinessLevel > 80) {
      _winCheckTimer?.cancel();
      Future.delayed(Duration(minutes: 1), () {
        if (happinessLevel > 80) {
          _showWinDialog();
        }
      });
    }
  }

  void _checkGameOverCondition() {
    if (hungerLevel >= 100 && happinessLevel <= 10) {
      _isGameOver = true;
      _showGameOverDialog();
      _hungerTimer?.cancel();
      _winCheckTimer?.cancel();
    }
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('You Win!'),
          content: Text('You kept $petName happy for 1 minute!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetGame();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Game Over!'),
          content: Text('Your pet is too hungry and unhappy!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetGame();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _resetGame() {
    setState(() {
      petName = "Your Pet";
      happinessLevel = 50;
      hungerLevel = 50;
      _energyLevel = 50;
      _hasWon = false;
      _isGameOver = false;
    });
    _startHungerTimer();
    _startWinCheckTimer();
  }

  void _changePetName() async {
    String? newName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String? name;
        return AlertDialog(
          title: Text('Change Pet Name'),
          content: TextField(
            onChanged: (value) {
              name = value;
            },
            decoration: InputDecoration(hintText: "Enter your pet's name"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(name);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );

    if (newName != null && newName.isNotEmpty) {
      setState(() {
        petName = newName;
      });
    }
  }

  void _playWithPet() {
    setState(() {
      happinessLevel = (happinessLevel + 10).clamp(0, 100);
      _energyLevel = happinessLevel;
      _updateHunger();
    });
  }

  void _feedPet() {
    setState(() {
      hungerLevel = (hungerLevel - 10).clamp(0, 100);
      _updateHappiness();
    });
  }

  void _updateHappiness() {
    if (hungerLevel < 30) {
      happinessLevel = (happinessLevel - 20).clamp(0, 100);
    } else {
      happinessLevel = (happinessLevel + 10).clamp(0, 100);
    }
    _energyLevel = happinessLevel;
  }

  void _updateHunger() {
    hungerLevel = (hungerLevel + 5).clamp(0, 100);
    if (hungerLevel > 100) {
      hungerLevel = 100;
      happinessLevel = (happinessLevel - 20).clamp(0, 100);
    }
    _energyLevel = happinessLevel;
  }

  Widget _getMoodWithEmoji() {
    String mood;
    String emoji;

    if (happinessLevel > 70) {
      mood = "Happy";
      emoji = "😊";
    } else if (happinessLevel >= 30) {
      mood = "Neutral";
      emoji = "😐";
    } else {
      mood = "Unhappy";
      emoji = "😢";
    }

    return Row(
      children: [
        Text(
          'Current Mood: $mood ',
          style: TextStyle(fontSize: 14.0, color: Colors.white),
        ),
        Text(
          emoji,
          style: TextStyle(fontSize: 14.0),
        ),
      ],
    );
  }

  Color _getDogColor() {
    if (happinessLevel > 70) {
      return Colors.green;
    } else if (happinessLevel >= 30) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }

  @override
  void dispose() {
    _hungerTimer?.cancel();
    _winCheckTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Digital Pet'),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Container(color: Colors.grey),
          Container(
            width: 300,
            height: 300,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  'img/dog.png',
                  fit: BoxFit.contain,
                ),
                Opacity(
                  opacity: 0.5,
                  child: Container(
                    color: _getDogColor(),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _getMoodWithEmoji(),
                    Spacer(),
                  ],
                ),
                Spacer(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Name: $petName',
                      style: TextStyle(fontSize: 20.0, color: Colors.white),
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      'Happiness Level: $happinessLevel',
                      style: TextStyle(fontSize: 20.0, color: Colors.white),
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      'Hunger Level: $hungerLevel',
                      style: TextStyle(fontSize: 20.0, color: Colors.white),
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      'Energy Level: $_energyLevel',
                      style: TextStyle(fontSize: 20.0, color: Colors.white),
                    ),
                    SizedBox(height: 8.0),
                    LinearProgressIndicator(
                      value: _energyLevel / 100,
                      minHeight: 10,
                      color: Colors.blue,
                      backgroundColor: Colors.grey[300],
                    ),
                    SizedBox(height: 32.0),
                    ElevatedButton(
                      onPressed: _playWithPet,
                      child: Text('Play with Your Pet'),
                    ),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: _feedPet,
                      child: Text('Feed Your Pet'),
                    ),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: _changePetName,
                      child: Text('Change Pet Name'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
