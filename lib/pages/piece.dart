import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:http/http.dart' as http;

class LightControlPage extends StatefulWidget {
  const LightControlPage({super.key, required String roomName});

  @override
  _LightControlPageState createState() => _LightControlPageState();
}

class _LightControlPageState extends State<LightControlPage> {
  bool isLEDOn = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: AppBar(
            title: const Text("Cliquer pour changer la couleur"),
            centerTitle: true,
          )),
      backgroundColor: currentColor,
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              isLEDOn = !isLEDOn;
              _turnOnLED(isLEDOn ? currentColor : const Color(0xFFFFFF00));
              // l'action du 1er bouton
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 209, 175, 175),
              shadowColor: Colors.black,
              shape: const CircleBorder(),
              fixedSize: const Size(100, 100),
            ),
            child: const Icon(
              Icons.power_settings_new,
              size: 50,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => showPicker(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 209, 175, 175),
              shadowColor: Colors.black,
              shape: const CircleBorder(),
              fixedSize: const Size(100, 100),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.invert_colors,
                  size: 50,
                ),
              ],
            ),
          ),
        ],
      )),
    );
  }

  Color pickerColor = const Color(0xff443a49);
  Color currentColor = const Color(0xff443a49);

  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  Future showPicker() {
    return showDialog(
      builder: (context) => AlertDialog(
        title: const Text('Choisir une couleur!'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: changeColor,
          ),
        ),
        actions: <Widget>[
          ElevatedButton(
            child: const Text('Appliquer'),
            onPressed: () {
              setState(() => currentColor = pickerColor);
              Navigator.of(context).pop();
              _changeLEDColor(pickerColor);
            },
          ),
        ],
      ),
      context: context,
    );
  }

  // Fonction pour allumer la LED avec la couleur spécifiée
  void _turnOnLED(Color color) async {
    // Convertir la couleur en une chaîne hexadécimale (RRGGBB)
    String hexColor = colorToHex(color);

    // Envoyer la requête HTTP à l'ESP32 pour allumer ou éteindre la LED avec la couleur spécifiée
    try {
      final response =
          await http.get(Uri.parse('http://192.168.1.7/on?color=$hexColor'));
      if (response.statusCode == 200) {
        if (color != const Color(0xFFFFFF00)) {
          print('LED allumée avec la couleur $hexColor');
        } else {
          print('LED éteinte');
        }
      } else {
        print('Erreur lors de l\'allumage de la LED');
      }
    } catch (e) {
      print('Erreur de connexion avec l\'ESP32 : $e');
    }
  }

  // Fonction pour changer la couleur de la LED avec la nouvelle couleur
  void _changeLEDColor(Color color) async {
    // Convertir la couleur en une chaîne hexadécimale (RRGGBB)
    String hexColor = color.value.toRadixString(16).padLeft(6, '0');

    // Envoyer la requête HTTP à l'ESP32 pour changer la couleur de la LED
    try {
      final response =
          await http.get(Uri.parse('http://192.168.1.7/color?color=$hexColor'));
      if (response.statusCode == 200) {
        print('Couleur de la LED changée en $hexColor');
      } else {
        print('Erreur lors du changement de la couleur de la LED');
      }
    } catch (e) {
      print('Erreur de connexion avec l\'ESP32 : $e');
    }
  }
}
