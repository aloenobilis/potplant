import 'package:oktoast/oktoast.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:potplant/pages/main_page.dart';

void main() {
  runApp(const Potplant());
}

class Potplant extends StatelessWidget {
  const Potplant({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const OKToast(
      child: NeumorphicApp(
        debugShowCheckedModeBanner: false,
        title: 'QrCreator',
        themeMode: ThemeMode.light,
        theme: NeumorphicThemeData(
          iconTheme: IconThemeData(color: Colors.black54),
          defaultTextColor: Color.fromARGB(255, 0, 206, 0),
          accentColor: Color.fromARGB(255, 212, 38, 32),
          variantColor: Colors.black38,
          depth: 10,
          intensity: .85,
          baseColor: Color.fromARGB(255, 235, 235, 235),
          lightSource: LightSource.topLeft,
        ),
        darkTheme: NeumorphicThemeData(
          baseColor: Color(0xFF3E3E3E),
          lightSource: LightSource.topLeft,
          defaultTextColor: Color.fromARGB(255, 84, 255, 32),
          depth: 8,
          intensity: 0.25,
        ),
        home: MainPage(),
      ),
    );
  }
}
