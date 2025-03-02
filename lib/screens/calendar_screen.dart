import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'recipes_screen.dart'; // Importation de RecipeDetailPage

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<String, List<Event>> _events = {};

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final eventsData = prefs.getString('events');
    if (eventsData != null) {
      final decodedEvents = json.decode(eventsData) as Map<String, dynamic>;
      setState(() {
        _events = decodedEvents.map((key, value) {
          final eventList = (value as List).map((e) => Event(e['name'], TimeOfDay(hour: e['hour'], minute: e['minute']), e['description'])).toList();
          return MapEntry(key, eventList);
        });
      });
      print('Événements chargés : $_events');
    }
  }

  Future<void> _saveEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final eventsData = _events.map((key, value) {
      final eventList = value.map((e) => {'name': e.name, 'hour': e.time.hour, 'minute': e.time.minute, 'description': e.description}).toList();
      return MapEntry(key, eventList);
    });
    await prefs.setString('events', json.encode(eventsData));
    print('Événements sauvegardés : $_events');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.grey[400],
        title: Text('Calendrier', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              eventLoader: (day) {
                final dayKey = day.toIso8601String().split('T')[0]; // Utiliser uniquement la date
                return _events[dayKey] ?? [];
              },
            ),
            SizedBox(height: 20),
            if (_selectedDay != null)
              Expanded(
                child: ListView.builder(
                  itemCount: _events[_selectedDay!.toIso8601String().split('T')[0]]?.length ?? 0,
                  itemBuilder: (context, index) {
                    final event = _events[_selectedDay!.toIso8601String().split('T')[0]]![index];
                    return ListTile(
                      title: Text(event.name),
                      subtitle: Text('Heure : ${event.time.format(context)}'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RecipeDetailPage(
                              title: event.name,
                              imagePath: 'assets/${event.name.toLowerCase().replaceAll(' ', '_')}.jpg',
                              description: event.description,
                            ),
                          ),
                        );
                      },
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showEditEventDialog(context, event, index),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteEvent(index),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_selectedDay != null) {
            _showAddEventDialog(context);
          }
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.orange[100],
      ),
    );
  }

  void _showAddEventDialog(BuildContext context) {
    TextEditingController _eventController = TextEditingController();
    TimeOfDay _selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Ajouter un événement'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _eventController,
                decoration: InputDecoration(
                  hintText: 'Entrez le nom de l\'événement',
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: _selectedTime,
                  );
                  if (pickedTime != null) {
                    setState(() {
                      _selectedTime = pickedTime;
                    });
                  }
                },
                child: Text('Choisir l\'heure'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                if (_eventController.text.isNotEmpty) {
                  setState(() {
                    final dayKey = _selectedDay!.toIso8601String().split('T')[0];
                    if (_events[dayKey] == null) {
                      _events[dayKey] = [];
                    }
                    _events[dayKey]!.add(Event(_eventController.text, _selectedTime, ''));
                    _saveEvents();
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }

  void _showEditEventDialog(BuildContext context, Event event, int index) {
    TextEditingController _eventController = TextEditingController(text: event.name);
    TimeOfDay _selectedTime = event.time;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Modifier l\'événement'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _eventController,
                decoration: InputDecoration(
                  hintText: 'Entrez le nom de l\'événement',
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: _selectedTime,
                  );
                  if (pickedTime != null) {
                    setState(() {
                      _selectedTime = pickedTime;
                    });
                  }
                },
                child: Text('Choisir l\'heure'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                if (_eventController.text.isNotEmpty) {
                  setState(() {
                    final dayKey = _selectedDay!.toIso8601String().split('T')[0];
                    _events[dayKey]![index] = Event(_eventController.text, _selectedTime, event.description);
                    _saveEvents();
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }

  void _deleteEvent(int index) {
    setState(() {
      final dayKey = _selectedDay!.toIso8601String().split('T')[0];
      _events[dayKey]!.removeAt(index);
      if (_events[dayKey]!.isEmpty) {
        _events.remove(dayKey);
      }
      _saveEvents();
    });
  }
}

class Event {
  final String name;
  final TimeOfDay time;
  final String description;

  Event(this.name, this.time, this.description);
}