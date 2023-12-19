import 'package:Crowuolingo/TelaDeLogin.dart';
import 'package:Crowuolingo/db/CrowuolingoDB.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class TelaDeCadastro extends StatefulWidget {
  const TelaDeCadastro({super.key});

  @override
  State<TelaDeCadastro> createState() => _TelaDeCadastroState();
}

class _TelaDeCadastroState extends State<TelaDeCadastro> {
  String nome = "";
  String email = "";
  String usuario = "";
  String senha = "";
  String nivel = "Iniciante";
  bool ocultarSenha = true;

  bool campoVazio = false;
  bool usuarioCadastrado = false;
  bool usuarioRepetido = false;

  void exibirSnackbars() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    if (campoVazio) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text('Necessário preencher todos os campos'),
        behavior: SnackBarBehavior.floating,
      ));
    }
    if (usuarioRepetido) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text('Já existe um usuário com esse login'),
        behavior: SnackBarBehavior.floating,
      ));
    }
    if (usuarioCadastrado) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text('Usuario Cadastrado com sucesso'),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  void realizarCadastro(nome, email, usuario, senha, nivel) async {
    DatabaseHelper dbHelper = DatabaseHelper();
    Database db = await dbHelper.database;
    await db.insert('usuarios', {
      'nome': nome,
      'email': email,
      'usuario': usuario,
      'senha': senha,
      'nivel': nivel
    });
  }

  Future<bool> verificarUsuarioRepetido(usuario) async {
    DatabaseHelper dbHelper = DatabaseHelper();
    Database db = await dbHelper.database;
    List<Map<String, dynamic>> resultado =
        await db.query('usuarios', where: 'usuario = ?', whereArgs: [usuario]);
    if (resultado.isNotEmpty) {
      return false;
    } else {
      return true;
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
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 100,
              ),
              Center(
                  child: Text(
                'Registre-se',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              )),
              SizedBox(
                height: 30,
              ),
              Card(
                child: TextField(
                  onChanged: (texto) {
                    nome = texto;
                  },
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                      hintText: 'Digite seu nome completo',
                      labelText: 'Nome Completo',
                      border: OutlineInputBorder()),
                ),
              ),
              Card(
                child: TextField(
                  onChanged: (texto) {
                    email = texto;
                  },
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                      hintText: 'Digite seu e-mail',
                      labelText: 'E-mail',
                      border: OutlineInputBorder()),
                ),
              ),
              Card(
                child: TextField(
                  onChanged: (texto) {
                    usuario = texto;
                  },
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                      hintText: 'Digite um nome de usuário',
                      labelText: 'Usuário',
                      border: OutlineInputBorder()),
                ),
              ),
              Card(
                child: TextField(
                  onChanged: (texto) {
                    senha = texto;
                  },
                  obscureText: ocultarSenha,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                      hintText: 'Digite uma senha',
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
                      border: OutlineInputBorder()),
                ),
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
                      nivel = newValue!;
                    });
                  },
                  decoration: InputDecoration(
                      labelText: 'Dificuldade', border: OutlineInputBorder()),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(77, 51, 130, 1)),
                onPressed: () async {
                  setState(() {
                    usuarioCadastrado = false;
                    campoVazio = false;
                    usuarioRepetido = false;
                  });
                  if (nome != "" &&
                      email != "" &&
                      usuario != "" &&
                      senha != "" &&
                      nivel != "") {
                    if (await verificarUsuarioRepetido(usuario) == true) {
                      realizarCadastro(nome, email, usuario, senha, nivel);
                      usuarioCadastrado = true;
                      exibirSnackbars();
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => TelaDeLogin(),
                      ));
                    } else {
                      setState(() {
                        usuarioCadastrado = false;
                        campoVazio = false;
                        usuarioRepetido = true;
                        exibirSnackbars();
                      });
                    }
                    ;
                  } else {
                    setState(() {
                      usuarioCadastrado = false;
                      campoVazio = true;
                      usuarioRepetido = false;
                      exibirSnackbars();
                    });
                  }
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Text(
                    'Registrar',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(77, 51, 130, 1)),
                onPressed: () {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => TelaDeLogin(),
                  ));
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Text(
                    'Voltar',
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
}
