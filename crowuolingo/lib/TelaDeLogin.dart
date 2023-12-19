import 'package:Crowuolingo/TelaDeCadastro.dart';
import 'package:Crowuolingo/TelaPrincipal.dart';
import 'package:Crowuolingo/db/CrowuolingoDB.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class TelaDeLogin extends StatefulWidget {
  const TelaDeLogin({super.key});

  @override
  State<TelaDeLogin> createState() => _TelaDeLoginState();
}

class _TelaDeLoginState extends State<TelaDeLogin> {
  String login = "";
  String senha = "";
  bool ocultarSenha = true;
  bool campoVazio = false;
  bool dadosInvalidos = false;

  void exibirSnackbars() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    if (campoVazio) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text('Necessário preencher todos os campos'),
        behavior: SnackBarBehavior.floating,
      ));
    }
    if (dadosInvalidos) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text('Usuário ou senha inválidos'),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  void realizarLogin(login, senha) async {
    DatabaseHelper dbHelper = DatabaseHelper();
    Database db = await dbHelper.database;
    List<Map<String, dynamic>> resultado = await db.query('usuarios',
        where: 'usuario = ? AND senha = ?', whereArgs: [login, senha]);
    if (resultado.isNotEmpty) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => TelaPrincipal(usuario: <String, dynamic>{
          'id': resultado[0]['id'].toString(),
          'nome': resultado[0]['nome'],
          'email': resultado[0]['email'],
          'user': resultado[0]['usuario'],
          'nivel': resultado[0]['nivel'],
          'senha': resultado[0]['senha'],
          'score': resultado[0]['score'].toString(),
          'progresso': resultado[0]['progresso'].toString(),
        }),
      ));
    } else {
      setState(() {
        dadosInvalidos = true;
        campoVazio = false;
        exibirSnackbars();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
          child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 300,
                      height: 300,
                      child: Image.asset('assets/images/logo.png'),
                    ),
                    Container(
                      width: 300,
                      child: Column(children: [
                        Card(
                          child: TextField(
                              onChanged: (texto) {
                                login = texto;
                              },
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                  hintText: 'Digite seu login',
                                  labelText: 'Login',
                                  border: OutlineInputBorder())),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Card(
                          child: TextField(
                              onChanged: (texto) {
                                senha = texto;
                              },
                              obscureText: ocultarSenha,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                  hintText: 'Digite sua senha',
                                  labelText: 'Senha',
                                  suffixIcon: IconButton(
                                    icon: Icon(ocultarSenha
                                        ? Icons.visibility
                                        : Icons.visibility_off),
                                    onPressed: () {
                                      setState(() {
                                        ocultarSenha = !ocultarSenha;
                                      });
                                    },
                                  ),
                                  border: OutlineInputBorder())),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromRGBO(77, 51, 130, 1)),
                          onPressed: () {
                            setState(() {
                              dadosInvalidos = false;
                              campoVazio = false;
                            });
                            if (login != "" && senha != "") {
                              realizarLogin(login, senha);
                            } else {
                              setState(() {
                                dadosInvalidos = false;
                                campoVazio = true;
                                exibirSnackbars();
                              });
                            }
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            child: Text(
                              'Entrar',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromRGBO(77, 51, 130, 1)),
                          onPressed: () {
                            setState(() {
                              Navigator.of(context)
                                  .pushReplacement(MaterialPageRoute(
                                builder: (context) => TelaDeCadastro(),
                              ));
                            });
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            child: Text(
                              'Registra-se',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      ]),
                    )
                  ],
                ),
              ))),
    );
  }
}
