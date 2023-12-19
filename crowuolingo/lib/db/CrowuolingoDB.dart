import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'crowuolingo.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE usuarios (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL,
            email TEXT NOT NULL,
            usuario TEXT NOT NULL,
            senha TEXT NOT NULL,
            nivel TEXT NOT NULL,
            score INTEGER DEFAULT 0,
            progresso INTEGER DEFAULT 1
          );
        ''');
        await db.execute('''
          CREATE TABLE modulos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL,
            pontuacao_iniciante TEXT NOT NULL,
            pontuacao_intermediario TEXT NOT NULL,
            pontuacao_avancado TEXT NOT NULL
          );
        ''');
        await db.execute('''
          CREATE TABLE palavras (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            palavra TEXT NOT NULL,
            traducao TEXT NOT NULL,
            imagem TEXT NOT NULL,
            modulos_id INTEGER,
            FOREIGN KEY (modulos_id) REFERENCES modulos (id)
          );
        ''');
        await db.execute('''
          CREATE TABLE frases (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            inicio TEXT NOT NULL,
            final TEXT NOT NULL,
            traducao TEXT NOT NULL,
            resposta_correta TEXT NOT NULL,
            resposta_errada1 TEXT NOT NULL,
            resposta_errada2 TEXT NOT NULL,
            resposta_errada3 TEXT NOT NULL,
            resposta_errada4 TEXT NOT NULL,
            dificuldade TEXT NOT NULL,
            modulos_id INTEGER,
            FOREIGN KEY (modulos_id) REFERENCES modulos (id)
          );
        ''');

        void cadastrarModulos() async {
          DatabaseHelper dbHelper = DatabaseHelper();
          Database db = await dbHelper.database;
          Batch batch = db.batch();
          batch.insert('modulos', {
            'nome': 'Modulo 1',
            'pontuacao_iniciante': '200',
            'pontuacao_intermediario': '400',
            'pontuacao_avancado': '1200'
          });
          batch.insert('modulos', {
            'nome': 'Modulo 2',
            'pontuacao_iniciante': '300',
            'pontuacao_intermediario': '600',
            'pontuacao_avancado': '1800'
          });
          batch.insert('modulos', {
            'nome': 'Modulo 3',
            'pontuacao_iniciante': '500',
            'pontuacao_intermediario': '1000',
            'pontuacao_avancado': '3000'
          });
          batch.insert('modulos', {
            'nome': 'Modulo 4',
            'pontuacao_iniciante': '800',
            'pontuacao_intermediario': '1600',
            'pontuacao_avancado': '4800'
          });
          batch.insert('modulos', {
            'nome': 'Modulo 5',
            'pontuacao_iniciante': '1000',
            'pontuacao_intermediario': '2000',
            'pontuacao_avancado': '6000'
          });
          batch.insert('modulos', {
            'nome': 'Modulo 6',
            'pontuacao_iniciante': '2000',
            'pontuacao_intermediario': '4000',
            'pontuacao_avancado': '12000'
          });
          await batch.commit();
        }

        void cadastrarPalavras() async {
          DatabaseHelper dbHelper = DatabaseHelper();
          Database db = await dbHelper.database;
          Batch batch = db.batch();
          batch.insert('palavras', {
            'palavra': 'Bat',
            'traducao': 'Morcego',
            'imagem': 'https://i.ibb.co/SvFW1wM/bat.jpg',
            'modulos_id': '1'
          });
          batch.insert('palavras', {
            'palavra': 'Night',
            'traducao': 'Noite',
            'imagem': 'https://i.ibb.co/HKcMdBn/night.jpg',
            'modulos_id': '1'
          });
          batch.insert('palavras', {
            'palavra': 'Nightmare',
            'traducao': 'Pesadelo',
            'imagem': 'https://i.ibb.co/J2nQzDs/nightmare.jpg',
            'modulos_id': '1'
          });

          await batch.commit();
        }

        void cadastrarFrases() async {
          DatabaseHelper dbHelper = DatabaseHelper();
          Database db = await dbHelper.database;
          Batch batch = db.batch();
          batch.insert('frases', {
            'inicio': '"Every ',
            'final': ', I go for a walk in the park.',
            'traducao': 'Todas as _____, dou um passeio no parque.',
            'resposta_correta': 'Night',
            'resposta_errada1': 'Bat',
            'resposta_errada2': 'Nightware',
            'resposta_errada3': 'Moon',
            'resposta_errada4': 'Dog',
            'dificuldade': 'Iniciante',
            'modulos_id': '1'
          });
          batch.insert('frases', {
            'inicio': 'Every night, I encounter a flying ',
            'final': '.',
            'traducao': 'Todas as noites, encontro um _____ voando.',
            'resposta_correta': 'Bat',
            'resposta_errada1': 'Night',
            'resposta_errada2': 'Nightmare',
            'resposta_errada3': 'Moon',
            'resposta_errada4': 'Dog',
            'dificuldade': 'Iniciante',
            'modulos_id': '1'
          });
          batch.insert('frases', {
            'inicio': 'Facing your fears can feel like a ',
            'final': '.',
            'traducao': 'Enfrentar seus medos pode parecer um _____.',
            'resposta_correta': 'Nightmare',
            'resposta_errada1': 'Bat',
            'resposta_errada2': 'Night',
            'resposta_errada3': 'Challenge',
            'resposta_errada4': 'Adventure',
            'dificuldade': 'Iniciante',
            'modulos_id': '1'
          });
          batch.insert('frases', {
            'inicio': 'The ',
            'final': ' sky is adorned with stars.',
            'traducao': 'O céu _____ é adornado com estrelas.',
            'resposta_correta': 'Night',
            'resposta_errada1': 'Bat',
            'resposta_errada2': 'Day',
            'resposta_errada3': 'Space',
            'resposta_errada4': 'Moon',
            'dificuldade': 'Iniciante',
            'modulos_id': '1'
          });
          batch.insert('frases', {
            'inicio': 'After watching a horror movie, I had a ',
            'final': '.',
            'traducao':
                'Depois de assistir a um filme de terror, tive um _____.',
            'resposta_correta': 'Nightmare',
            'resposta_errada1': 'Bat',
            'resposta_errada2': 'Night',
            'resposta_errada3': 'Dream',
            'resposta_errada4': 'Adventure',
            'dificuldade': 'Iniciante',
            'modulos_id': '1'
          });

          await batch.commit();
        }

        cadastrarModulos();
        cadastrarPalavras();
        cadastrarFrases();
      },
    );
  }
}
