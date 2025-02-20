import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Wand {
  final String name;
  final String wood;
  final String core;
  final String length;
  final String image;
  final String description;

  Wand({
    required this.name,
    required this.wood,
    required this.core,
    required this.length,
    required this.image,
    required this.description,
  });

  factory Wand.fromJson(Map<String, dynamic> json) {
    return Wand(
      name: json['name'],
      wood: json['wood'],
      core: json['core'],
      length: json['length'],
      image: json['image'],
      description: json['description'],
    );
  }
}

class WandCatalogPage extends StatefulWidget {
  @override
  _WandCatalogPageState createState() => _WandCatalogPageState();
}

class _WandCatalogPageState extends State<WandCatalogPage> {
  List<Wand> wands = [];
  List<Wand> filteredWands = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadWands();
  }

  Future<void> loadWands() async {
    final String response = await rootBundle.loadString('assets/wands.json');
    final List<dynamic> data = json.decode(response);
    setState(() {
      wands = data.map((json) => Wand.fromJson(json)).toList();
      filteredWands = wands;
    });
  }

  void filterWands(String query) {
    setState(() {
      filteredWands = wands.where((wand) {
        return wand.name.toLowerCase().contains(query.toLowerCase()) ||
               wand.wood.toLowerCase().contains(query.toLowerCase()) ||
               wand.core.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightGreen[100]!, Colors.green[700]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            AppBar(
              title: Text("Wand Catalog", style: TextStyle(fontFamily: "Cinzel")),
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "Search for a wand...",
                  prefixIcon: Icon(Icons.search, color: Colors.black54),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: filterWands,
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(10),
                itemCount: filteredWands.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WandDetailPage(wand: filteredWands[index]),
                          ),
                        );
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 5,
                        color: Colors.lightGreen[200],
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(filteredWands[index].image, width: 60, height: 60, fit: BoxFit.cover),
                          ),
                          title: Text(
                            filteredWands[index].name,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          subtitle: Text(
                            "${filteredWands[index].wood} - ${filteredWands[index].core}",
                            style: TextStyle(fontSize: 14),
                          ),
                          trailing: Icon(Icons.arrow_forward_ios, color: Colors.black45),
                        ),
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

class WandDetailPage extends StatelessWidget {
  final Wand wand;

  const WandDetailPage({super.key, required this.wand});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightGreen[100]!, Colors.green[700]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            AppBar(
              title: Text(wand.name, style: TextStyle(fontFamily: "Cinzel")),
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
            ),
            SizedBox(height: 10),
            Hero(
              tag: wand.name,
              child: Image.asset(
                wand.image,
                width: MediaQuery.of(context).size.width * 0.7,
                height: 250,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 6,
                color: Colors.white.withOpacity(0.9),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, 
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Wood: ${wand.wood}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 6),
                      Text("Core: ${wand.core}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 6),
                      Text("Length: ${wand.length}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Text(
                        wand.description,
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.justify, 
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int questionIndex = 0;
  Map<String, int> wandScores = {};
  List<Wand> wands = []; 

  @override
  void initState() {
    super.initState();
    loadWands(); 
  }

  Future<void> loadWands() async {
    final String response = await rootBundle.loadString('assets/wands.json');
    final List<dynamic> data = json.decode(response);
    setState(() {
      wands = data.map((json) => Wand.fromJson(json)).toList();
    });
  }

  void answerQuestion(String wand) {
    wandScores[wand] = (wandScores[wand] ?? 0) + 1;
    setState(() {
      if (questionIndex < questions.length - 1) {
        questionIndex++;
      } else {
        String bestWand = wandScores.entries.reduce((a, b) => a.value > b.value ? a : b).key;

        Wand selectedWand = wands.firstWhere(
          (w) => w.name == bestWand,
          orElse: () => Wand(
            name: bestWand,
            wood: "Unknown",
            core: "Unknown",
            length: "Unknown",
            image: "assets/default_wand.png",
            description: "Your recommended wand based on quiz results."
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => WandDetailPage(wand: selectedWand),
          ),
        );
      }
    });
  }

  final List<Map<String, dynamic>> questions = [
  {
    "question": "What is your strongest personality trait?",
    "answers": {
      "Bravery": "Elder Wand",
      "Intelligence": "Harry Potter's Wand",
      "Loyalty": "Ron Weasley's Wand",
      "Cunning": "Voldemort's Wand"
    }
  },
  {
    "question": "Which Hogwarts house do you feel most connected to?",
    "answers": {
      "Gryffindor": "Elder Wand",
      "Ravenclaw": "Harry Potter's Wand",
      "Hufflepuff": "Ron Weasley's Wand",
      "Slytherin": "Voldemort's Wand"
    }
  },
  {
    "question": "Which spell do you use the most?",
    "answers": {
      "Expelliarmus": "Harry Potter's Wand",
      "Lumos": "Ron Weasley's Wand",
      "Avada Kedavra": "Voldemort's Wand",
      "Expecto Patronum": "Elder Wand"
    }
  },
  {
    "question": "Which magical subject interests you the most?",
    "answers": {
      "Charms": "Hermione Granger's Wand",
      "Transfiguration": "Elder Wand",
      "Dark Arts": "Voldemort's Wand",
      "Potions": "Draco Malfoy's Wand"
    }
  },
  {
    "question": "What kind of magic do you prefer?",
    "answers": {
      "Defensive Spells": "Hermione Granger's Wand",
      "Powerful Curses": "Voldemort's Wand",
      "Dueling Spells": "Draco Malfoy's Wand",
      "Healing Spells": "Harry Potter's Wand"
    }
  },
  {
    "question": "Which material feels right for your wand?",
    "answers": {
      "Phoenix Feather": "Harry Potter's Wand",
      "Dragon Heartstring": "Hermione Granger's Wand",
      "Unicorn Hair": "Ron Weasley's Wand",
      "Thestral Tail Hair": "Elder Wand"
    }
  },
  {
    "question": "Which wizard do you admire the most?",
    "answers": {
      "Albus Dumbledore": "Elder Wand",
      "Harry Potter": "Harry Potter's Wand",
      "Hermione Granger": "Hermione Granger's Wand",
      "Draco Malfoy": "Draco Malfoy's Wand"
    }
  }
];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightGreen[100]!, Colors.green[700]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            AppBar(
              title: Text("Find Your Wand", style: TextStyle(fontFamily: "Cinzel")),
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      questions[questionIndex]["question"],
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    ...(questions[questionIndex]["answers"] as Map<String, String>).entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                          ),
                          onPressed: () => answerQuestion(entry.value),
                          child: Text(
                            entry.key,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {///
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightGreen[100]!, Colors.green[700]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.auto_fix_high, size: 80, color: Colors.black87), // Иконка волшебной палочки
              SizedBox(height: 10),
              Text(
                "Harry Potter Wand Shop",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Cinzel",
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 40),
              CustomButton(
                text: "Take the Quiz",
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QuizPage()),
                ),
              ),
              SizedBox(height: 15),
              CustomButton(
                text: "View Wand Catalog",
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WandCatalogPage()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 220,
        padding: EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: Colors.green[700],
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(2, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primarySwatch: Colors.green,
      scaffoldBackgroundColor: Colors.lightGreen[50],
    ),
    home: HomePage(),
  ));
}
