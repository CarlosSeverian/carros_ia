import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

class Gravar extends StatefulWidget {
  const Gravar({Key? key}) : super(key: key);

  @override
  State<Gravar> createState() => _GravarState();
}

class _GravarState extends State<Gravar> {
  String message = "Falhou";
  bool error = false;
  var data;
  String dataurl = "https://carlosseverian.pythonanywhere.com/lermarcas";
  Object? _vMarca;
  Object? _vTurbo;
  Object? _vArCondicionado;
  Object? _vPropulsao;
  Object? _vCombustivel;

  String _resultado = " ";
  TextEditingController _vCilindradas = TextEditingController();
  TextEditingController _vValvulas = TextEditingController();

  TextEditingController _vGc = TextEditingController();
  TextEditingController _vGe = TextEditingController();
  TextEditingController _vEc = TextEditingController();
  TextEditingController _vEe = TextEditingController();

  List<String> _lvTurbo = ['Sim', 'Não'];
  List<String> _lvArCondicionado = ['Sim', 'Não'];
  List<String> _lvPropulsao = ['Combustao', 'Hibrido', 'Plug-in'];
  List<String> _lvCombustivel = ['Flex', 'Gasolina', 'Diesel'];

  @override
  void initState() {
    error = false;
    super.initState();
    getMarca();
  }

  Future<void> getMarca() async {
    var URL = Uri.parse(dataurl);
    var res = await http.get(URL);

    if (res.statusCode == 200) {
      setState(() {
        data = json.decode(res.body);
        if (data["error"]) {
          //check if there is any error from server.
          error = true;
        }
      });
    } else {
      //there is error
      setState(() {
        error = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Consumo de Veículos - GRAVAR NOVOS DADOS"),
      ),
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text('DIGITE AS CARACTERÍSTICAS\n',
                  style: TextStyle(
                    fontSize: 20.0,
                  )),
              Container(
                //wrapper para lista de Marcas
                child: error
                    ? Text(message)
                    : data == null
                        ? Text(" ")
                        : marcaList(),
                //if there is error then show error message,
                //else check if data is null,
                //if not then show list,
              ),

              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Campo Cilindradas
                    Container(
                        width: 103,
                        child: TextField(
                            controller: _vCilindradas,
                            decoration: InputDecoration(
                                hintText: 'exemplo: 1.8',
                                labelText: 'Cilindradas'))),
                    Text(' '),
                    // Campo Valvulas
                    Container(
                        width: 103,
                        child: TextField(
                            controller: _vValvulas,
                            decoration: InputDecoration(
                                hintText: 'exemplo: 16',
                                labelText: 'Valvulas'))),
                  ]),

              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('\n    Turbo    '),
                    Text(' '),
                    Text('\n       Ar Condicionado'),
                  ]),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    DropdownButton(
                      hint:
                          Text('Selecione     '), // Not necessary for Option 1
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
                    Text(' '),
                    DropdownButton(
                      hint: Text('Selecione'), // Not necessary for Option 1
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
                  ]),
              // Campo Propulsao

              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('\nPropulsão         '),
                    Text(' '),
                    Text('\nCombustivel   '),
                  ]),

              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    DropdownButton(
                      hint: Text('Selecione'), // Not necessary for Option 1
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

                    Text("  "),
                    DropdownButton(
                      hint: Text('Selecione'), // Not necessary for Option 1
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
                  ]),

              Text("Consumo Gasolina/Diesel",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Campo Cilindradas
                  Container(
                      width: 100,
                      child: TextField(
                          controller: _vGc,
                          decoration: InputDecoration(
                              hintText: 'Km/L', labelText: 'Cidade'))),
                  Text(' '),
                  Container(
                      width: 100,
                      child: TextField(
                          controller: _vGe,
                          decoration: InputDecoration(
                              hintText: 'Km/L', labelText: 'Estrada'))),
                ],
              ),

              Text("\nConsumo ETANOL",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Campo Cilindradas
                  Container(
                      width: 100,
                      child: TextField(
                          controller: _vEc,
                          decoration: InputDecoration(
                              hintText: 'Km/L', labelText: 'Cidade'))),
                  Text(' '),
                  Container(
                      width: 100,
                      child: TextField(
                          controller: _vEe,
                          decoration: InputDecoration(
                              hintText: 'Km/L', labelText: 'Estrada'))),
                ],
              ),

              // Resultado
              Text('\n $_resultado')
            ]),
      ),
      floatingActionButton:
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        FloatingActionButton(
          child: const Icon(Icons.add_task_sharp),
          onPressed: () async {
            final Dio dio1 = Dio();
            var resposta = await dio1.post(
              'https://carlosseverian.pythonanywhere.com/gravar',
              data: jsonEncode(
                {
                  'Marca': _vMarca,
                  'Cilindradas': _vCilindradas.text,
                  'Valvulas': _vValvulas.text,
                  'Turbo': _vTurbo,
                  'ArCondicionado': _vArCondicionado,
                  'Propulsao': _vPropulsao,
                  'Combustivel': _vCombustivel,
                  'Gc': _vGc.text,
                  'Ge': _vGe.text,
                  'Ec': _vEc.text,
                  'Ee': _vEe.text,
                },
              ),
            );
            _resultado = '${resposta.data}';
            setState(() {});
          },
        ),
      ]),
    );
  }

  Widget marcaList() {
    //widget function for list
    List<MarcaOne> marcalist = List<MarcaOne>.from(data["data"].map((i) {
      return MarcaOne.fromJSON(i);
    })); //searilize marcalist json data to object model.

    return DropdownButton(
        hint: Text("Selecione a Marca              "),
        value: _vMarca,
        items: marcalist.map((marcaOne) {
          return DropdownMenuItem(
            child: Text(marcaOne.marcaname),
            value: marcaOne.marcaname,
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _vMarca = value;
          });
          //print("Marca selecionada é $value");
        });
  }
}

//model class to searilize list JSON data.
class MarcaOne {
  var marcaname;

  MarcaOne({this.marcaname});

  factory MarcaOne.fromJSON(Map<String, dynamic> json) {
    return MarcaOne(marcaname: json["Marca"]);
  }
}
