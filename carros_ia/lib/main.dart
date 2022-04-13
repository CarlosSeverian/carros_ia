import 'package:flutter/material.dart';
import 'package:carros_ia/ui/gravar.dart';
import 'package:carros_ia/ui/treinar.dart';
import 'package:carros_ia/ui/predicao.dart';
import 'package:carros_ia/ui/sobre.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Grupo Inteligência em Negócios',
        theme: ThemeData(primarySwatch: Colors.amber),
        //home: const CarrosIA(),
        home: Selecao());
  }
}

class Selecao extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Consumo de Veículos - SELEÇÃO'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              child: Text('Entrada de Dados Novos',
                  style: TextStyle(
                    fontSize: 18.0,
                  )),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Gravar()),
                  //MaterialPageRoute(builder: (context) => MyHomePage()),
                );
              },
            ),
            Text(''),
            ElevatedButton(
              child: Text('Treinar Modelos',
                  style: TextStyle(
                    fontSize: 18.0,
                  )),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Treinar()),
                );
              },
            ),
            Text(''),
            ElevatedButton(
              child: Text('Predição de Consumo',
                  style: TextStyle(
                    fontSize: 18.0,
                  )),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CarrosIA()),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton:
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        FloatingActionButton(
          child: const Icon(Icons.help),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Sobre()),
            );
          },
        )
      ]),
    );
  }
}
