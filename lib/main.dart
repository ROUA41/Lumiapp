// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lumiapp/pages/piece.dart';
import 'package:vertical_card_pager/vertical_card_pager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const Home());
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LumiApp',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      routes: {
        '/googleLogin': (context) => GoogleLoginPage(),
        '/welcome': (context) => const WelcomePage(
              displayName: '',
              photoURL: '',
            ),
      },
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      Get.off(() => _MyAppState());
    });

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 226, 194),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(25.0),
              child: Image.asset('assets/luminapp.png'),
            ),
            const SizedBox(height: 20),
            Stack(
              children: <Widget>[
                // Stroked text as border.
                Text(
                  'LumiApp',
                  style: TextStyle(
                    fontSize: 50,
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 6
                      ..color = Colors.black,
                  ),
                ),
                Text(
                  'LumiApp',
                  style: TextStyle(
                    fontSize: 50,
                    color: Colors.grey[300],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _MyAppState extends StatefulWidget {
  @override
  __MyAppStateState createState() => __MyAppStateState();
}

class __MyAppStateState extends State<_MyAppState> {
  final List<String> titles = [
    "CUISINE",
    "SALON",
    "CHAMBRE À COUCHER",
    "SALLE DE BAINS",
    "SALLE DE JEUX",
    "BUREAU À DOMICILE"
  ];
  final List<String> imglst = [
    "https://www.cuisines-aviva.com/storage/medias/e1/b6/44428/conversions/mia-atypique-noir--2023-paysage.jpg-crop-full.jpg",
    "https://www.idee2deco.com/wp-content/uploads/2022/05/choix-des-meubles-salon-moderne.jpg",
    "https://archzine.fr/wp-content/uploads/2018/04/ultra-moderne-chambre-blanc-et-gris-tendance-chambre-complete-adulte-boheme-chic-chambre-de%CC%81co-contemporaine.jpg",
    "https://blog.izi-by-edf.fr/2019/09/iStock-1073403366.jpg",
    "https://blog-media.but.fr/wp-content/uploads/2023/06/00-installer-salle-jeux-video.jpg",
    "https://www.dm-line.be/wp-content/uploads/2019/09/Bureaukast-met-bureaublad-in-verstek.jpeg"
  ];
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    List<Widget> images = imglst.map((image) {
      return Container(
          decoration: BoxDecoration(
              color: Colors.black45,
              image: DecorationImage(
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.7), BlendMode.dstATop),
                  image: NetworkImage(image)),
              borderRadius: BorderRadius.circular(10)));
    }).toList();

    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(label: 'accueil', icon: Icon(Icons.home)),
          BottomNavigationBarItem(
              label: 'paramètres', icon: Icon(Icons.settings)),
        ],
        currentIndex: currentIndex,
        onTap: (int index) {
          setState(() {
            currentIndex = index;
            if (currentIndex == 1) {
              Navigator.pushNamed(context, '/googleLogin');
            }
          });
        },
      ),
      backgroundColor: const Color.fromARGB(255, 243, 226, 194),
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Choisir la pièce"),
      ),
      body: SafeArea(
        child: VerticalCardPager(
          titles: titles,
          images: images,
          textStyle: const TextStyle(
              fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
          onPageChanged: (Page) {},
          onSelectedItem: (Page) {
            // Récupérer le nom de la chambre sélectionnée
            String roomName = titles[Page];
            // Naviguer vers la page de contrôle de la lumière avec le nom de la chambre
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LightControlPage(roomName: roomName),
              ),
            );
          },
        ),
      ),
    );
  }
}

class GoogleLoginPage extends StatefulWidget {
  GoogleLoginPage({Key? key});

  @override
  State<GoogleLoginPage> createState() => _GoogleLoginPageState();
}

class _GoogleLoginPageState extends State<GoogleLoginPage>
    with SingleTickerProviderStateMixin {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final double scrollSpeed = 0.2; // Adjust this value to control the scroll speed
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10), // Adjust the duration as needed
    );

    _animation = Tween<double>(begin: -1.0, end: 1.0).animate(_controller)
      ..addListener(() {
        setState(() {});
      });

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        String displayName = user.displayName ?? '';
        String photoURL = user.photoURL ?? '';

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) =>
                  WelcomePage(displayName: displayName, photoURL: photoURL)),
        );
      }
    } catch (error) {
      print('Erreur de connexion avec Google: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 226, 194),
      appBar: AppBar(
        title: const Text('Paramètres'),
      ),
      body: SizedBox(
        child: Stack(
          children: [
            Positioned(
              child: ListView.builder(
                itemCount: 2,
                itemBuilder: (BuildContext context, int index) {
                  double opacity = _animation.value +
                      1.0; // Map value from [-1.0, 1.0] to [0.0, 1.0]
                  if (opacity < 0.0) opacity = 0.0;
                  if (opacity > 1.0) opacity = 1.0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical:
                            8.0), // Add 16 pixels of vertical spacing between images
                    child: Transform.translate(
                      offset: Offset(
                          0,
                          _animation.value *
                              scrollSpeed *
                              100), // Adjust the offset to control the scrolling speed
                      child: Opacity(
                        opacity: opacity,
                        child: Image.asset(
                          'assets/image$index.png', // Replace with your image asset paths
                          height:
                              200, // Adjust the height of the images as needed
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const Positioned(
                bottom: 120,
                left: 90,
                right: 90,
                child: Text(
                  'Contrôlez vos lumières avec facilité et créez l\'ambiance parfaite pour chaque moment!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                )),
            Positioned(
              bottom: 30.0,
              left: 70.0,
              right: 70.0,
              child: SizedBox(
                height: 60.0,
                child: ElevatedButton(
                  onPressed: () => _handleGoogleSignIn(context),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FaIcon(
                          FontAwesomeIcons.google,
                          color: Colors.white,
                        ),
                        SizedBox(width: 8.0),
                        Text(
                          'Connexion avec Google',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WelcomePage extends StatefulWidget {
  final String displayName;
  final String photoURL;

  const WelcomePage({
    Key? key,
    required this.displayName,
    required this.photoURL,
  }) : super(key: key);

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _handleSignOut() async {
    try {
      await _googleSignIn.disconnect();
      await _auth.signOut();

      // Redirigez l'utilisateur vers la page de connexion
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (BuildContext context) => GoogleLoginPage()),
      );
    } catch (error) {
      print('Erreur lors de la déconnexion : $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 226, 194),
      appBar: AppBar(
        title: Text('Bienvenue, ${widget.displayName}'),
        actions: [
          CircleAvatar(
            backgroundImage: NetworkImage(widget.photoURL),
          ),
          const SizedBox(width: 16.0),
        ],
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/bienvenue.png'),
          const SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: _handleSignOut,
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }
}
