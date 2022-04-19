import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class Treinar extends StatefulWidget {
  const Treinar({Key? key}) : super(key: key);

  @override
  State<Treinar> createState() => _TreinarState();
}

class _TreinarState extends State<Treinar> {
  String _resultado = " ";
  String _Origem = "mauapos2022";

  //List<String> _lvCombustivel = ['Flex', 'Gasolina', 'Diesel'];
  //Object? _vCombustivel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TREINAR MODELOS'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // campo Combustivel
            ElevatedButton(
              child: const Text('Executar treinamento de TODOS os Modelos'),
              onPressed: () async {
                final Dio dio2 = Dio();
                var resposta = await dio2.post(
                  'https://carlosseverian.pythonanywhere.com/treinar',
                  data: jsonEncode(
                    {
                      'Origem': _Origem,
                    },
                  ),
                );
                _resultado = '${resposta.data}';
                setState(() {});
              },
            ),
            // Resultado
            Text('\n $_resultado')
          ],
        ),
      ),
    );
  }
}
