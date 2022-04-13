import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Sobre extends StatelessWidget {
  final String maua_img;

  const Sobre({this.maua_img = "Pos_Maua.png", Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Consumo de Veículos - SOBRE'),
        ),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              this.maua_img,
              width: 200.0,
              height: 100.0,
              fit: BoxFit.contain,
            ),
            Text("Desenvolvimento de Sistemas de IA_CD",
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text("\nProf. Murilo Zanini de Carvalho"),
            Text("\n\nDesenvolvedores",
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text("\nCARLOS ROBERTO S CARVALHO"),
            Text("FABIO LIMA DA COSTA"),
            Text("HELIANA LOMBARDI ARTIGIANI"),
            Text("\n\n"),
            Text("Fonte de Dados\n",
                style: TextStyle(fontWeight: FontWeight.bold)),
            InkWell(
                child: Text('Tabela de Marcas - FIPE',
                    style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline)),
                onTap: () => launch('https://tabelafipecarros.com.br/carros/')),
            Text(" "),
            InkWell(
                child: Text('Tabela de Consumos - INMETRO',
                    style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline)),
                onTap: () => launch(
                    "https://www.gov.br/inmetro/pt-br/assuntos/avaliacao-da-conformidade/programa-brasileiro-de-etiquetagem/tabelas-de-eficiencia-energetica/veiculos-automotivos-pbe-veicular/veiculos-leves-2021/view")),
            Text("\n\n\n\n\n\n\n2022"),
          ],
        )));
  }
}
