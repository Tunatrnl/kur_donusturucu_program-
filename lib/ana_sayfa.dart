import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AnaSayfa extends StatefulWidget {
  const AnaSayfa({super.key});

  @override
  State<AnaSayfa> createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  final String _apiKey = "7e5d5f73451a4b5b5dceff7cdcd5d278";

  final String _baseUrl =
      "http://api.exchangeratesapi.io/v1/latest?access_key=";

  final TextEditingController _controller = TextEditingController();

  final Map<String, double> _oranlar = {};

  String _secilenKur = "USD";
  double _sonuc = 0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verileriInternettenCek();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: _oranlar.isNotEmpty
          ? _buildBody()
          : const Center(child: CircularProgressIndicator()),
    );
  }

  AppBar _appBar() {
    return AppBar(
      title: const Text("Kur Dönüştürücü"),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildExchangeRow(),
          const SizedBox(height: 16),
          _kuruEkranaYazdirma(),
          const SizedBox(height: 16),
          _buildAyiriciCizgi(),
          const SizedBox(height: 16),
          _buildKurList()
        ],
      ),
    );
  }

  Widget _buildExchangeRow() {
    return Row(
      children: [
        _buildKurTextField(),
        const SizedBox(width: 16),
        _buildKurDropDown(),
      ],
    );
  }

  Widget _buildKurTextField() {
    return Expanded(
      child: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: (String yeniDeger) {
          _hesapla();
        },
      ),
    );
  }

  Widget _buildKurDropDown() {
    return DropdownButton<String>(
      value: _secilenKur,
      // icon: Icon(Icons.arrow_downward), -> Listenin sağındaki ikonu değiştirir
      underline: const SizedBox(),
      items: _oranlar.keys.map((String kur) {
        return DropdownMenuItem(
          value: kur,
          child: Text(kur),
        );
      }).toList(),
      onChanged: (String? yeniDeger) {
        if (yeniDeger != null) {
          _secilenKur = yeniDeger;
          _hesapla();
        }
      },
    );
  }

  Widget _kuruEkranaYazdirma() {
    return Text(
      "${_sonuc.toStringAsFixed(2)} ₺",
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildKurList() => Expanded(
        child: ListView.builder(
          itemCount: _oranlar.keys.length,
          itemBuilder: _buildListItem,
        ),
      );

  Widget? _buildListItem(BuildContext context, int index) {
    return ListTile(
      title: Text(_oranlar.keys.toList()[index]),
      trailing: Text(_oranlar.values.toList()[index].toStringAsFixed(2)),
    );
  }

  Widget _buildAyiriciCizgi() => Container(
        height: 2,
        color: Colors.black,
      );

  void _hesapla() {
    double? deger = double.tryParse(_controller.text);
    double? oran = _oranlar[_secilenKur];

    if (deger != null && oran != null) {
      setState(() {
        _sonuc = deger * oran;
      });
    }
  }

  void _verileriInternettenCek() async {
    Uri uri = Uri.parse(_baseUrl + _apiKey);
    http.Response response = await http.get(uri);

    Map<String, dynamic> parsedResponse = jsonDecode(response.body);

    Map<String, dynamic> rates = parsedResponse["rates"];

    double? baseTlKuru = rates["TRY"];

    if (baseTlKuru != null) {
      for (String ulkeKuru in rates.keys) {
        double? baseKur = double.tryParse(rates[ulkeKuru].toString());
        if (baseKur != null) {
          double tlKuru = baseTlKuru / baseKur;
          _oranlar[ulkeKuru] = tlKuru;
        }
      }
    }
    setState(() {});
  }
}

/*
{
    "success": true,
    "timestamp": 1519296206,
    "base": "EUR",
    "date": "2021-03-17",
    "rates": {
        "AUD": 1.566015,
        "CAD": 1.560132,
        "CHF": 1.154727,
        "CNY": 7.827874,
        "GBP": 0.882047,
        "TRY": 30,
        "USD": 2,
    [...]
    }
}
 */
