import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart'; // Import the audioplayers package

class QuizScreen extends StatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  late AudioPlayer _audioPlayer; // Declare an AudioPlayer

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'Le gluten est présent dans :',
      'answers': ['Le blé', 'Le riz', 'Le maïs', 'Le quinoa'],
      'correctAnswer': 'Le blé',
    },
    {
      'question': 'Quelle maladie est liée à l’intolérance au gluten ?',
      'answers': ['Diabète', 'Maladie cœliaque', 'Hypertension', 'Asthme'],
      'correctAnswer': 'Maladie cœliaque',
    },
    {
      'question': 'Le gluten est une protéine présente dans :',
      'answers': ['Les fruits', 'Les légumes', 'Les céréales', 'Les produits laitiers'],
      'correctAnswer': 'Les céréales',
    },
    {
      'question': 'Quel aliment est naturellement sans gluten ?',
      'answers': ['Pain', 'Pâtes', 'Sarrasin', 'Biscuits'],
      'correctAnswer': 'Sarrasin',
    },
    {
      'question': 'Quelle farine ne contient pas de gluten ?',
      'answers': ['Farine de blé', 'Farine de sarrasin', 'Farine de seigle', 'Farine d’épeautre'],
      'correctAnswer': 'Farine de sarrasin',
    },
    {
      'question': 'Le gluten est utilisé dans l’industrie agroalimentaire pour :',
      'answers': ['Améliorer la texture', 'Réduire la teneur en sel', 'Donner du goût', 'Rendre les aliments plus sucrés'],
      'correctAnswer': 'Améliorer la texture',
    },
  ];

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer(); // Initialize the AudioPlayer
    _playBackgroundMusic(); // Play music when the page opens
  }

  @override
  void dispose() {
    _audioPlayer.dispose(); // Release the AudioPlayer resources
    super.dispose();
  }

  // Function to play background music
  void _playBackgroundMusic() async {
    await _audioPlayer.play(AssetSource('music.mp3')); // Replace 'music.mp3' with your audio file path
  }

  void _answerQuestion(String selectedAnswer) {
    if (selectedAnswer == _questions[_currentQuestionIndex]['correctAnswer']) {
      setState(() {
        _score++;
      });
    }

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      _showScoreDialog();
    }
  }

  void _showScoreDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Quiz terminé ! 🎉'),
          content: Text(
            'Votre score est de $_score/${_questions.length}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text('Quiz sur le gluten', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / _questions.length,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation(Colors.teal),
            ),
            SizedBox(height: 20),
            Text(
              _questions[_currentQuestionIndex]['question'],
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ...(_questions[_currentQuestionIndex]['answers'] as List<String>).map((answer) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton(
                  onPressed: () => _answerQuestion(answer),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal[100],
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    answer,
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}