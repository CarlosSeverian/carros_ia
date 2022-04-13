import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class CarrosIA extends StatefulWidget {
  const CarrosIA({Key? key}) : super(key: key);

  @override
  State<CarrosIA> createState() => _CarrosIAState();
}

class _CarrosIAState extends State<CarrosIA> {
  String _resultado = " ";
  TextEditingController _vCilindradas = TextEditingController();
  TextEditingController _vValvulas = TextEditingController();

  List<String> _lvTurbo = ['Sim', 'Não'];
  List<String> _lvArCondicionado = ['Sim', 'Não'];
  List<String> _lvPropulsao = ['Combustao', 'Hibrido', 'Plug-in'];
  List<String> _lvCombustivel = ['Flex', 'Gasolina', 'Diesel'];
  Object? _vTurbo;
  Object? _vArCondicionado;
  Object? _vPropulsao;
  Object? _vCombustivel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consumo de Veículos - PREDIÇÃO'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('DIGITE AS CARACTERÍSTICAS\n',
                style: TextStyle(
                  fontSize: 20.0,
                )),
            // Campo Cilindradas
            Container(
                width: 200,
                child: TextField(
                    controller: _vCilindradas,
                    decoration: InputDecoration(
                        hintText: 'exemplo: 1.8', labelText: 'Cilindradas'))),
            // Campo Vlavulas
            Container(
                width: 200,
                child: TextField(
                    controller: _vValvulas,
                    decoration: InputDecoration(
                        hintText: 'exemplo: 16', labelText: 'Valvulas'))),
            Text('\nTurbo                                              '),
            DropdownButton(
              hint: Text(
                  'Selecione                         '), // Not necessary for Option 1
              value: _vTurbo,
              onChanged: (newValue) {
                setState(() {
                  _vTurbo = newValue;
                });
              },
              items: _lvTurbo.map((_vTurbo) {
                return DropdownMenuItem(
                  child: new Text(_vTurbo),
                  value: _vTurbo,
                );
              }).toList(),
            ),
            // Campo Ar Condicionado
            Text('Ar Condicionado                          '),
            DropdownButton(
              hint: Text(
                  'Selecione                         '), // Not necessary for Option 1
              value: _vArCondicionado,
              onChanged: (newValue) {
                setState(() {
                  _vArCondicionado = newValue;
                });
              },
              items: _lvArCondicionado.map((_vArCondicionado) {
                return DropdownMenuItem(
                  child: new Text(_vArCondicionado),
                  value: _vArCondicionado,
                );
              }).toList(),
            ),
            // Campo Propulsao
            Text('Propulsão                                     '),
            DropdownButton(
              hint: Text(
                  'Selecione                         '), // Not necessary for Option 1
              value: _vPropulsao,
              onChanged: (newValue) {
                setState(() {
                  _vPropulsao = newValue;
                });
              },
              items: _lvPropulsao.map((_vPropulsao) {
                return DropdownMenuItem(
                  child: new Text(_vPropulsao),
                  value: _vPropulsao,
                );
              }).toList(),
            ),
            // campo Combustivel
            Text('Combustivel                                 '),
            DropdownButton(
              hint: Text(
                  'Selecione                         '), // Not necessary for Option 1
              value: _vCombustivel,
              onChanged: (newValue) {
                setState(() {
                  _vCombustivel = newValue;
                });
              },
              items: _lvCombustivel.map((_vCombustivel) {
                return DropdownMenuItem(
                  child: new Text(_vCombustivel),
                  value: _vCombustivel,
                );
              }).toList(),
            ),
            // Resultado
            Text('\n $_resultado')
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.local_gas_station),
        onPressed: () async {
          final Dio dio1 = Dio();
          var resposta = await dio1.post(
            'https://carlosseverian.pythonanywhere.com/predict',
            data: jsonEncode(
              {
                'Cilindradas': _vCilindradas.text,
                'Valvulas': _vValvulas.text,
                'Turbo': _vTurbo,
                'ArCondicionado': _vArCondicionado,
                'Propulsao': _vPropulsao,
                'Combustivel': _vCombustivel,
              },
            ),
          );
          _resultado = '${resposta.data}';
          setState(() {});
        },
      ),
    );
  }
}
