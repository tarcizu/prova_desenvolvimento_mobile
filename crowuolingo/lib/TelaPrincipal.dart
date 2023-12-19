import 'dart:async';

import 'package:Crowuolingo/TelaDeLogin.dart';
import 'package:Crowuolingo/db/CrowuolingoDB.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class TelaPrincipal extends StatefulWidget {
  final Map<String, dynamic> usuario;

  TelaPrincipal({required this.usuario});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  late Map<String, dynamic> usuario;
  late String telaAtual;
  late TextEditingController _nome;
  late TextEditingController _email;
  late TextEditingController _usuario;
  late String id;
  late String nivel;
  late String senha;
  late String user;
  late String fieldNome;
  late String fieldEmail;
  late String fieldNivel;
  late String fieldSenhaAntiga = "";
  late String fieldSenhaNova = "";
  late String progresso;
  late List<Map<String, dynamic>> palavras = [];
  late List<Map<String, dynamic>> frases = [];
  late int passoAtual = 1;
  late bool ocultarSenhaAntiga = true;
  late bool ocultarSenhaNova = true;
  late int premioEmPontos = 0;
  late String respostaEscolhida = '_____';
  late int pontuacaoDoRound = 0;
  late int acertosRound = 0;
  @override
  void initState() {
    super.initState();
    usuario = widget.usuario;
    telaAtual = "Aprendizado";
    _nome = new TextEditingController(text: usuario['nome']);
    _email = new TextEditingController(text: usuario['email']);
    _usuario = new TextEditingController(text: usuario['user']);
    fieldNome = usuario['nome'];
    fieldEmail = usuario['email'];
    fieldNivel = usuario['nivel'];
    id = usuario['id'];
    nivel = usuario['nivel'];
    senha = usuario['senha'];
    user = usuario['user'];
    progresso = usuario['progresso'];
    carregarFaseAtual(progresso, nivel);
  }

  void carregarFaseAtual(progresso, nivel) async {
    DatabaseHelper dbHelper = DatabaseHelper();
    Database db = await dbHelper.database;
    palavras = await db.query('palavras',
        where: 'modulos_id = ?', whereArgs: [int.parse(progresso)]);
    frases = await db.query('frases',
        where: 'modulos_id = ? AND dificuldade = ?',
        whereArgs: [int.parse(progresso), nivel]);
    String? colunaPontuacao;

    switch (nivel) {
      case 'Iniciante':
        colunaPontuacao = 'pontuacao_iniciante';
        break;
      case 'Intermediário':
        colunaPontuacao = 'pontuacao_intermediario';
        break;
      case 'Avançado':
        colunaPontuacao = 'pontuacao_avancado';
        break;
    }
    if (colunaPontuacao != null) {
      List<Map<String, dynamic>> resultado = await db.query('modulos',
          columns: [colunaPontuacao],
          where: 'id = ?',
          whereArgs: [int.parse(progresso)]);
      if (resultado.isNotEmpty) {
        premioEmPontos = int.parse(resultado[0][colunaPontuacao]);
      }
      setState(() {});
    }
  }

  Future<String> buscarPontuacao(id) async {
    DatabaseHelper dbHelper = DatabaseHelper();
    Database db = await dbHelper.database;
    List<Map<String, dynamic>> resultado = await db.query('usuarios',
        columns: ['score'], where: 'id = ?', whereArgs: [int.parse(id)]);
    if (resultado.isNotEmpty) {
      return resultado[0]['score'].toString();
    }
    return '500';
  }

  void atualizarPontucao(id, int pontuacao) async {
    DatabaseHelper dbHelper = DatabaseHelper();
    Database db = await dbHelper.database;

    int novaPontuacao = int.parse(await buscarPontuacao(id)) + pontuacao;
    Map<String, dynamic> colunaAtualizada = {'score': novaPontuacao.toString()};
    int retorno = await db.update('usuarios', colunaAtualizada,
        where: 'id = ?', whereArgs: [int.parse(id)]);
  }

  void atualizarPerfil(id, nome, email, usuario, nivel, senha) async {
    DatabaseHelper dbHelper = DatabaseHelper();
    Database db = await dbHelper.database;
    Map<String, dynamic> usuarioAtualizado = {
      'nome': nome,
      'email': email,
      'usuario': usuario,
      'nivel': nivel,
      'senha': senha,
    };
    int retorno = await db.update('usuarios', usuarioAtualizado,
        where: 'id = ?', whereArgs: [int.parse(id)]);
  }

  Widget palavra(palavra) {
    return FutureBuilder(
      future: carregarImagem(palavra['imagem']),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Container(
            child: Center(
              child: Column(
                children: [
                  SizedBox(
                    height: 50,
                  ),
                  Text(
                    'Palavra ' + passoAtual.toString() + '/3',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    width: 300,
                    height: 200,
                    child: Image.network(palavra['imagem']),
                  ),
                  Text(
                    palavra['palavra'],
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    palavra['traducao'],
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(77, 51, 130, 1)),
                    onPressed: () {
                      setState(() {
                        passoAtual++;
                      });
                    },
                    child: Container(
                      width: 200,
                      child: Text(
                        'Continuar',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Container(
            child: Text('Deu Erro'),
          );
        } else {
          return Container(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  Widget frase(frase) {
    List<Widget> opcoes = [
      Container(
        padding: EdgeInsets.all(5),
        child: ElevatedButton(
            onPressed: () {
              setState(() {
                respostaEscolhida = frase['resposta_correta'];
              });
            },
            child: Text(frase['resposta_correta'],
                style: TextStyle(fontSize: 30))),
      ),
      Container(
          padding: EdgeInsets.all(5),
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                respostaEscolhida = frase['resposta_errada1'];
              });
            },
            child: Text(
              frase['resposta_errada1'],
              style: TextStyle(fontSize: 30),
            ),
          )),
      Container(
          padding: EdgeInsets.all(5),
          child: ElevatedButton(
              onPressed: () {
                setState(() {
                  respostaEscolhida = frase['resposta_errada2'];
                });
              },
              child: Text(frase['resposta_errada2'],
                  style: TextStyle(fontSize: 30)))),
      Container(
          padding: EdgeInsets.all(5),
          child: ElevatedButton(
              onPressed: () {
                setState(() {
                  respostaEscolhida = frase['resposta_errada3'];
                });
              },
              child: Text(frase['resposta_errada3'],
                  style: TextStyle(fontSize: 30)))),
      Container(
          padding: EdgeInsets.all(5),
          child: ElevatedButton(
              onPressed: () {
                setState(() {
                  respostaEscolhida = frase['resposta_errada4'];
                });
              },
              child: Text(frase['resposta_errada4'],
                  style: TextStyle(fontSize: 30)))),
    ];
    if (respostaEscolhida == '_____') {
      opcoes.shuffle();
    }
    return Container(
      child: Center(
          child: Column(
        children: [
          SizedBox(
            height: 50,
          ),
          Text(
            'Complete a frase:',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 30,
          ),
          Center(
              child: Wrap(
            children: [
              RichText(
                text:
                    TextSpan(style: TextStyle(color: Colors.black), children: [
                  TextSpan(
                    text: frase['inicio'],
                    style: TextStyle(fontSize: 25),
                  ),
                  TextSpan(
                      text: respostaEscolhida,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
                  TextSpan(text: frase['final'], style: TextStyle(fontSize: 25))
                ]),
              )
            ],
          )),
          SizedBox(
            height: 60,
          ),
          Center(child: Wrap(children: opcoes)),
          SizedBox(
            height: 100,
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(77, 51, 130, 1)),
            onPressed: () {
              setState(() {
                if (respostaEscolhida != '_____') {
                  if (respostaEscolhida == frase['resposta_correta']) {
                    pontuacaoDoRound =
                        pontuacaoDoRound + (premioEmPontos / 10).toInt();
                    acertosRound++;
                  }
                  respostaEscolhida = '_____';
                  passoAtual++;
                }
              });
            },
            child: Container(
              width: 200,
              child: Text(
                'Confirmar',
                textAlign: TextAlign.center,
              ),
            ),
          )
        ],
      )),
    );
  }

  Widget resultado() {
    if (acertosRound >= 3) {
      return Container(
        child: Center(
            child: Column(
          children: [
            SizedBox(
              height: 50,
            ),
            Text(
              'Parabéns!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 50,
            ),
            Text(
              'Aproveitamento:',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            Text(
              (20 * acertosRound).toString() + '%',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            Text(
              'Pontuação:',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            Text(
              (premioEmPontos + pontuacaoDoRound).toString() + ' pts',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(77, 51, 130, 1)),
              onPressed: () {
                atualizarPontucao(id, premioEmPontos + pontuacaoDoRound);
                pontuacaoDoRound = 0;
                acertosRound = 0;
                passoAtual = 1;
                // Função que levará para proxima fase (ainda não cadastrada)
                // if (int.parse(progresso) < 2) {
                //   progresso = (int.parse(progresso) + 1).toString();
                // }
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) =>
                      TelaPrincipal(usuario: <String, dynamic>{
                    'id': id,
                    'nome': fieldNome,
                    'email': fieldEmail,
                    'user': user,
                    'nivel': fieldNivel,
                    'senha': senha,
                    'progresso': progresso
                  }),
                ));
              },
              child: Container(
                width: 200,
                child: Text(
                  'Proxima Fase',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          ],
        )),
      );
    } else {
      return Container(
        child: Center(
            child: Column(
          children: [
            SizedBox(
              height: 50,
            ),
            Text(
              'Reprovado! Tente de novo',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 50,
            ),
            Text(
              'Aproveitamento:',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            Text(
              (20 * acertosRound).toString() + '%',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(77, 51, 130, 1)),
              onPressed: () {
                pontuacaoDoRound = 0;
                acertosRound = 0;
                passoAtual = 1;
                // Função que levará para proxima fase (ainda não cadastrada)
                // if (int.parse(progresso) < 2) {
                //   progresso = (int.parse(progresso) + 1).toString();
                // }
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) =>
                      TelaPrincipal(usuario: <String, dynamic>{
                    'id': id,
                    'nome': fieldNome,
                    'email': fieldEmail,
                    'user': user,
                    'nivel': fieldNivel,
                    'senha': senha,
                    'progresso': progresso
                  }),
                ));
              },
              child: Container(
                width: 200,
                child: Text(
                  'Proxima Fase',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          ],
        )),
      );
    }
  }

  Widget telaAprendizado() {
    switch (passoAtual) {
      case 1:
        return palavra(palavras[0]);

      case 2:
        return palavra(palavras[1]);

      case 3:
        return palavra(palavras[2]);

      case 4:
        return frase(frases[0]);

      case 5:
        return frase(frases[1]);

      case 6:
        return frase(frases[2]);

      case 7:
        return frase(frases[3]);

      case 8:
        return frase(frases[4]);

      case 9:
        return resultado();
    }
    ;
    return Container();
  }

  Future<Image> carregarImagem(url) async {
    final Completer<Image> completer = Completer<Image>();
    final Image image = Image.network(url);
    image.image.resolve(ImageConfiguration()).addListener(
      ImageStreamListener((info, synchronousCall) {
        completer.complete(image);
      }),
    );
    return completer.future;
  }

  Widget telaPontuacao() {
    return FutureBuilder(
      future: buscarPontuacao(id),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Container(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Pontuação',
                    style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    snapshot.data ?? '1000',
                    style: TextStyle(fontSize: 35),
                  )
                ],
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Text('Erro: ${snapshot.error}');
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Container telaEditarPerfil() {
    return Container(
        child: SingleChildScrollView(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 50,
              ),
              Center(
                child: Text(
                  'Perfil',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Card(
                child: TextField(
                    controller: _nome,
                    keyboardType: TextInputType.name,
                    onChanged: (valor) {
                      fieldNome = valor;
                    },
                    decoration: InputDecoration(
                        labelText: 'Nome Completo',
                        border: OutlineInputBorder())),
              ),
              Card(
                child: TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (valor) {
                      fieldEmail = valor;
                    },
                    decoration: InputDecoration(
                        labelText: 'E-Mail', border: OutlineInputBorder())),
              ),
              Card(
                child: TextField(
                    enabled: false,
                    controller: _usuario,
                    decoration: InputDecoration(
                        labelText: 'Usuario', border: OutlineInputBorder())),
              ),
              Card(
                child: DropdownButtonFormField(
                  value: nivel,
                  items: <String>['Iniciante', 'Intermediário', 'Avançado']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      fieldNivel = newValue!;
                    });
                  },
                  decoration: InputDecoration(
                      labelText: 'Dificuldade', border: OutlineInputBorder()),
                ),
              ),
              Card(
                child: TextField(
                    keyboardType: TextInputType.text,
                    onChanged: (valor) {
                      fieldSenhaAntiga = valor;
                    },
                    obscureText: ocultarSenhaAntiga,
                    decoration: InputDecoration(
                        labelText: 'Senha Antiga',
                        suffixIcon: IconButton(
                          icon: Icon(ocultarSenhaAntiga
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              ocultarSenhaAntiga = !ocultarSenhaAntiga;
                            });
                          },
                        ),
                        border: OutlineInputBorder())),
              ),
              Card(
                child: TextField(
                    keyboardType: TextInputType.text,
                    onChanged: (valor) {
                      fieldSenhaNova = valor;
                    },
                    obscureText: ocultarSenhaNova,
                    decoration: InputDecoration(
                        labelText: 'Senha Nova',
                        suffixIcon: IconButton(
                          icon: Icon(ocultarSenhaNova
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              ocultarSenhaNova = !ocultarSenhaNova;
                            });
                          },
                        ),
                        border: OutlineInputBorder())),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(77, 51, 130, 1)),
                onPressed: () {
                  if (fieldSenhaAntiga != "" &&
                      fieldSenhaNova != "" &&
                      fieldSenhaAntiga == senha) {
                    senha = fieldSenhaNova;
                  }
                  atualizarPerfil(
                      id, fieldNome, fieldEmail, user, fieldNivel, senha);
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) =>
                        TelaPrincipal(usuario: <String, dynamic>{
                      'id': id,
                      'nome': fieldNome,
                      'email': fieldEmail,
                      'user': user,
                      'nivel': fieldNivel,
                      'senha': senha,
                      'progresso': progresso
                    }),
                  ));
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Text(
                    'Atualizar',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(telaAtual)),
        drawer: Drawer(
          width: 200,
          child: Column(children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Color.fromRGBO(77, 51, 130, 1)),
              currentAccountPicture: CircleAvatar(
                backgroundImage:
                    NetworkImage('https://i.ibb.co/qn13KPm/male.jpg'),
              ),
              accountName: Text(usuario['nome']),
              accountEmail: Text(usuario['email']),
            ),
            ListTile(
              leading: Icon(Icons.account_box),
              title: Text('Perfil'),
              onTap: () {
                Navigator.of(context).pop();
                setState(() {
                  telaAtual = 'Editar Perfil';
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.school),
              title: Text('Aprendizado'),
              onTap: () {
                Navigator.of(context).pop();
                setState(() {
                  telaAtual = 'Aprendizado';
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.scoreboard),
              title: Text('Pontuação'),
              onTap: () {
                Navigator.of(context).pop();
                setState(() {
                  telaAtual = 'Pontuação';
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => TelaDeLogin(),
                ));
              },
            )
          ]),
        ),
        body: Builder(builder: (BuildContext context) {
          if (telaAtual == 'Aprendizado') {
            return telaAprendizado();
          }
          if (telaAtual == 'Editar Perfil') {
            return telaEditarPerfil();
          }
          if (telaAtual == 'Pontuação') {
            return telaPontuacao();
          }
          return Container();
        }));
  }
}
