import 'dart:convert'; //Импорт для работы с json
import 'package:flutter/material.dart'; //Импорт Flutter для пользовательского интерфейса
import 'package:flutter/services.dart'; //Импорт для загрузки json из assets

class Wand {
  final String name;
  final String wood;
  final String core;
  final String length;
  final String image;
  final String description;

//Констуктор класса палочки
//(гарантия что поля обьекта будут инициализированы при его создании) 
  Wand({
    required this.name,
    required this.wood,
    required this.core,
    required this.length,
    required this.image,
    required this.description,
  });

//Метод для создания объекта Wand из json (загрузка и обработка инфы из БД (factory Class.fromJson))
  factory Wand.fromJson(Map<String, dynamic> json) {
    return Wand(
      //Ключи
      name: json['name'],
      wood: json['wood'],
      core: json['core'],
      length: json['length'],
      image: json['image'],
      description: json['description'],
    );
  }
}

//Страница каталога палок
class WandCatalogPage extends StatefulWidget { //Экран может изменяться (во время загрузки)
  @override
  _WandCatalogPageState createState() => _WandCatalogPageState(); //Создание обьекта, управляющего состоянием экрана
}

class _WandCatalogPageState extends State<WandCatalogPage> {//Класс наследуется и становится состоянием (данные (инфа о палочках), которые могут измениться во время работы)
  List<Wand> wands = []; //Список для заполнения данными


  @override
  //Создание страницы
  void initState() { 
    super.initState(); //включение самого устройства
    loadWands(); //загружает json
  }

  Future<void> loadWands() async { //Функция не сразу выполняется (ждет прихода данных), async дает возможность юзать await внутри функции
    final String response = await rootBundle.loadString('assets/wands.json'); //await ждет пока загрузит данные, response получает даннные из json
    final List<dynamic> data = json.decode(response); //перевод текста из json в список обьектов
    setState(() { //обновление экрана
      wands = data.map((json) => Wand.fromJson(json)).toList(); //замена пустого списка полученными данными 
    });
  }

  @override
  Widget build(BuildContext context) { //Метод создающий и отображающий интерфейс страницы каталога
    return Scaffold( //Контейнер для экрана
      appBar: AppBar(title: Text("Wand Catalog")), //Верхняя панель
      body: wands.isEmpty //wands.isEmpty проверяет, загружены ли палки
          ? Center(child: CircularProgressIndicator()) // если тру, показывает загр круг; если нет, то показывает список палок
          : ListView.builder( //Создание списка палочек, который можно прокручивать
              itemCount: wands.length, //Сколько элементов в списке палок
              itemBuilder: (context, index) { //функция, которая создаёт каждый элемент списка
                return Card(
                  color: Colors.lightGreen[100],//Card + ListTile — создание карточки палочки
                  child: ListTile(
                    leading: Image.asset(wands[index].image, width: 50, height: 50), //leading -> картинка слева
                    title: Text(wands[index].name, style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("${wands[index].wood} - ${wands[index].core}"), //subtitle -> материал и сердцевина
                    onTap: () { //переход на страницу деталей
                      Navigator.push( //перемещает пользователя на новый экран
                        context,
                        MaterialPageRoute( //создаёт плавный переход между экранами
                          builder: (context) => WandDetailPage(wand: wands[index]), //builder отвечает за создание нового экрана
                                                                                    //context передаётся в WandDetailPage, чтобы Flutter понимал, где этот экран в навигации
                                                                                    // что после => создает новый объект WandDetailPage, в который передаётся конкретная палка
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

//Экран с инфой о палочке 
class WandDetailPage extends StatelessWidget { //extends StatelessWidget -> экран не изменяется после создания
  final Wand wand; //объявляет переменную wand, которая хранит конкретную палку
  const WandDetailPage({super.key, required this.wand}); //палочка обязательна для передачи в WandDetailPage

  @override
  Widget build(BuildContext context) {
    return Scaffold( //основа экрана
      appBar: AppBar(title: Text(wand.name)), //в заголовке отображается имя палочки
      body: Padding(
        padding: EdgeInsets.all(16.0), //отступы вокруг содержимого
        child: Column( //список элементов (картинка + инфа), Column располагает элементы вертикально
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(wand.image, width: 250, height: 150),
            SizedBox(height: 20), //добавляет пространство между картинкой и текстом
            Card( //карточка с информацией о палочке
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [ //наполнение карточки
                    Text("Wood: ${wand.wood}"),
                    Text("Core: ${wand.core}"),
                    Text("Length: ${wand.length}"),
                    Text(wand.description),
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

//Экран с тестом
class QuizPage extends StatefulWidget { //состояние может изменяться (меняются вопросы)
  @override
  _QuizPageState createState() => _QuizPageState(); //createState() -> создаёт объект, который управляет тестом
}

//Управление викториной
class _QuizPageState extends State<QuizPage> {
  int questionIndex = 0; //какой вопрос сейчас показывается
  Map<String, int> wandScores = {}; //хранит очки для каждой палочки

  //Список вопросов
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
    }
  ];

  void answerQuestion(String wand) {
    wandScores[wand] = (wandScores[wand] ?? 0) + 1; //когда выбирается ответ, увеличиваем очки для выбранной палочки
    setState(() {                                   //wandScores[wand] ?? 0 -> если у этой палочки ещё нет очков, ставим 0
      if (questionIndex < questions.length - 1) { //проверка 
        questionIndex++;
      } else {
        String bestWand = wandScores.entries.reduce((a, b) => a.value > b.value ? a : b).key; //находим палочку, которая набрала больше всего очков
                                                                                              //.entries превращает wandScores в список "палочка" -> "очки"
                                                                                              //.reduce() находит самую популярную палочку
        //переход на страницу с результатами
        Navigator.pop(context); //Закрываем викторину
        Navigator.push( //добавляет новый экран поверх текущего
          context,
          MaterialPageRoute(
            builder: (context) => WandDetailPage(wand: Wand( //Передаём результат в WandDetailPage
              name: bestWand,
              wood: "Unknown",
              core: "Unknown",
              length: "Unknown",
              image: "assets/default_wand.png",
              description: "Your recommended wand based on quiz results."
            )),
          ),
        );
      }
    });
  }


  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Find Your Wand")),
      body: Center(
        child: Column( //вертикальное расположение элементов
          mainAxisAlignment: MainAxisAlignment.center, //всё в колонке будет по центру
          children: [
            Text( //отображает текущий вопрос
              questions[questionIndex]["question"], //берёт текущий вопрос из списка questions
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20), //отступ перед кнопками
            ...(questions[questionIndex]["answers"] as Map<String, String>).entries.map((entry) { //Берём список ответов для текущего вопроса (questions[questionIndex]["answers"])
                                                                                                  //.entries.map((entry) {}) создаёт кнопку для каждого ответа
                                                                                                  //entry.key это текст кнопки
                                                                                                  //entry.value это палочка, к которой относится ответ
              return ElevatedButton( //создаёт кнопки с ответами
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                ),
                onPressed: () => answerQuestion(entry.value), //передаёт выбранную палочку в answerQuestion()
                child: Text(entry.key), //устанавливает текст кнопки
                                        //entry.key это текст самого варианта ответа
              );
            }).toList(), //делает из результата готовый список (List<Widget>)
          ],
        ),
      ),
    );
  }
}

//Главная страница с двумя кнопками
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Wand Selector")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => QuizPage())), |//Открывает страницу викторины
              child: Text("Take the Quiz", style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => WandCatalogPage())),
              child: Text("View Wand Catalog", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

//Точка входа в приложение
void main() {
  runApp(MaterialApp( //запуск приложения
    debugShowCheckedModeBanner: false, //убирает "debug" в углу экрана
    theme: ThemeData(
      primarySwatch: Colors.green,
      scaffoldBackgroundColor: Colors.lightGreen[50],
    ),
    home: HomePage(), //первый экран приложения — HomePage
  ));
}
