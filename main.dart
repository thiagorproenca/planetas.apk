import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Planetas do Sistema Solar',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[200],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Planetas do Sistema Solar',
              style: TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const PlanetListScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                backgroundColor: Colors.blueAccent,
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Começar'),
            ),
            const SizedBox(height: 20),
            const Text(
              'By: Thiago',
              style: TextStyle(fontSize: 14, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class PlanetListScreen extends StatefulWidget {
  const PlanetListScreen({super.key});

  @override
  PlanetListScreenState createState() => PlanetListScreenState();
}

class PlanetListScreenState extends State<PlanetListScreen> {
  late Database _database;
  List<Map<String, dynamic>> _planets = [];

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    _database = await openDatabase(
      join(dbPath, 'planets.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE planets(id INTEGER PRIMARY KEY, name TEXT, nickname TEXT, size_km REAL, distance_km REAL)'
        );
      },
      version: 1,
    );
    await _populatePlanets();
    _loadPlanets();
  }

  Future<void> _populatePlanets() async {
    final planets = [
      {'name': 'Mercúrio', 'nickname': 'O pequeno', 'size_km': 4879.4, 'distance_km': 57910000},
      {'name': 'Vênus', 'nickname': 'O brilhante', 'size_km': 12104, 'distance_km': 108200000},
      {'name': 'Terra', 'nickname': 'Nosso lar', 'size_km': 12742, 'distance_km': 149600000},
      {'name': 'Marte', 'nickname': 'O vermelho', 'size_km': 6779, 'distance_km': 227900000},
      {'name': 'Júpiter', 'nickname': 'O gigante', 'size_km': 139820, 'distance_km': 778500000},
      {'name': 'Saturno', 'nickname': 'O dos anéis', 'size_km': 116460, 'distance_km': 1434000000},
      {'name': 'Urano', 'nickname': 'O gelado', 'size_km': 50724, 'distance_km': 2871000000},
      {'name': 'Netuno', 'nickname': 'O azul', 'size_km': 49244, 'distance_km': 4495000000},
    ];

    for (final planet in planets) {
      await _database.insert('planets', planet, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  Future<void> _loadPlanets() async {
    final List<Map<String, dynamic>> planets = await _database.query('planets');
    setState(() {
      _planets = planets;
    });
  }

  Future<void> _deletePlanet(int id) async {
    await _database.delete('planets', where: 'id = ?', whereArgs: [id]);
    _loadPlanets();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planetas do Sistema Solar'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _planets.length,
                itemBuilder: (context, index) {
                  final planet = _planets[index];
                  return Card(
                    child: ListTile(
                      title: Text(planet['name']),
                      subtitle: Text(
                          'Apelido: ${planet['nickname'] ?? 'N/A'}, Tamanho: ${planet['size_km']} km, Distância: ${planet['distance_km']} km'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deletePlanet(planet['id']),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
