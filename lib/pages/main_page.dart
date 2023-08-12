import 'dart:io';
import 'dart:typed_data';

import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart' as m;
import 'package:pumli/pumli.dart';
import 'package:oktoast/oktoast.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';

import 'package:potplant/utils/image_from_widget.dart';
import 'package:potplant/utils/example_uml.dart' as ex;

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // *** STATE VARIABLES ***
  final TextEditingController _controller = TextEditingController();
  late List<String> _itemNames;
  File? renderFile;
  // ignore: non_constant_identifier_names
  int MAIN_HEIGHT = 160;
  String? _errorText;
  bool isLoading = false;
  static const String nameSequence = "Sequence Diagram";
  static const String nameUseCase = "Use Case Diagram";
  static const String nameClass = "Class Diagram";
  static const String nameObject = "Object Diagram";
  static const String nameActivity = "Activity Diagram";
  static const String nameComponent = "Component Diagram";
  static const String nameDeployment = "Deployment Diagram";
  static const String nameState = "State Diagram";
  static const String nameTiming = "Timing Diagram";
  String initialItemValue = "State Diagram";

  @override
  void initState() {
    super.initState();

    _controller.text = ex.stateDiagram;

    _itemNames = [
      nameSequence,
      nameUseCase,
      nameClass,
      nameObject,
      nameActivity,
      nameComponent,
      nameDeployment,
      nameState,
      nameTiming,
    ];
  }

  // *********************************************************
  // ********************** METHODS **************************
  // *********************************************************

  Future<void> viewUmlRender() async {
    try {
      setState(() {
        isLoading = true;
      });
      final pumliREST = PumliREST(serviceURL: PumliREST.plantUmlUrl);
      final rawSvg = await pumliREST.getSVG(_controller.text);
      File temp = await File('/tmp/temp_diagram.svg').writeAsString(rawSvg);
      setState(() {
        renderFile = File(temp.path);
        _errorText = null;
        isLoading = false;
      });
    } catch (err) {
      setState(() {
        _errorText = err.toString();
        isLoading = false;
      });
    }
  }

  void lightDarkModeToggle() {
    if (NeumorphicTheme.of(context)!.isUsingDark) {
      NeumorphicTheme.of(context)!.themeMode = ThemeMode.light;
    } else {
      NeumorphicTheme.of(context)!.themeMode = ThemeMode.dark;
    }
  }

  Color iconColor() {
    return NeumorphicTheme.of(context)!.themeMode == ThemeMode.dark
        ? Colors.orangeAccent
        : Colors.black54;
  }

  Future<void> saveDiagramDesktop(BuildContext context) async {
    try {
      Uint8List? bytes;
      double size = 1000.0;
      Directory appDocDir = await getApplicationDocumentsDirectory();
      const uuid = Uuid();
      final imagePath = "${appDocDir.path}/plantuml-diagram-${uuid.v4()}.png";
      File imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        imageFile.create(recursive: true);
      }

      // ignore: use_build_context_synchronously
      bytes = await createImageFromWidget(
          Center(
            child: SvgPicture.file(
              renderFile!,
              width: size,
              height: size,
            ),
          ),
          logicalSize: Size(size, size),
          imageSize: Size(size, size),
          context: context);

      File savedImageFile = await imageFile.writeAsBytes(bytes);

      showToast(
        "Saved to: ${savedImageFile.path}",
        textStyle: const TextStyle(color: Colors.black87),
        backgroundColor: Colors.green,
        position: ToastPosition.bottom,
        dismissOtherToast: true,
        duration: const Duration(seconds: 10),
      );
    } catch (err) {
      showToast(
        err.toString(),
        textStyle: const TextStyle(color: Colors.black87),
        backgroundColor: Colors.red,
        position: ToastPosition.bottom,
        dismissOtherToast: true,
        duration: const Duration(seconds: 5),
      );
    }
  }

  // *********************************************************
  // ********************** WIDGETS **************************
  // *********************************************************
  Widget potplantEditor() {
    return m.Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: ListView(
        shrinkWrap: true,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height - MAIN_HEIGHT,
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
              style: TextStyle(
                  fontFamily: "monospace",
                  fontWeight: FontWeight.w300,
                  fontSize: 16,
                  color:
                      NeumorphicTheme.of(context)!.themeMode == ThemeMode.dark
                          ? Colors.orangeAccent
                          : Colors.black54),
              keyboardType: TextInputType.multiline,
              minLines: 40, //Normal textInputField will be displayed
              maxLines: null, // when user presses enter it will adapt to it
            ),
            // child: QuillEditor.basic(
            //   controller: _controller,
            //   readOnly: false, // true for view only mode
            // ),
          ),
        ],
      ),
    );
  }

  Widget renderedImage() {
    return Column(
      children: [
        renderFile == null
            ? _errorText == null
                ? const m.Text('press play')
                : m.Text(_errorText!)
            : SizedBox(
                height: MediaQuery.of(context).size.height - MAIN_HEIGHT,
                width: MediaQuery.of(context).size.width / 2,
                child: Center(
                  child: SvgPicture.file(
                    renderFile!,
                  ),
                ),
              )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: NeumorphicTheme.baseColor(context),
        appBar: NeumorphicAppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          padding: 4,
        ),
        body: SingleChildScrollView(
          child: ResponsiveGridRow(
            children: [
              /*
                      12
              --------------------
                  6          6
                editor     render
              --------- ----------
                  6         6
               buttons    buttons
              --------- ----------

              */
              ResponsiveGridCol(
                  xs: 12,
                  md: 12,
                  lg: 12,
                  child: ResponsiveGridRow(
                    children: [
                      ResponsiveGridCol(
                          xs: 6, md: 6, lg: 6, xl: 6, child: potplantEditor()),
                      ResponsiveGridCol(
                          xs: 6,
                          md: 6,
                          lg: 6,
                          xl: 6,
                          child: isLoading
                              ? SizedBox(
                                  height: MediaQuery.of(context).size.height -
                                      MAIN_HEIGHT,
                                  width: MediaQuery.of(context).size.width / 2,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                        color: Colors.orange),
                                  ))
                              : renderedImage()),
                    ],
                  )),
              ResponsiveGridCol(
                  xs: 12,
                  md: 12,
                  lg: 12,
                  child: ResponsiveGridRow(
                    children: [
                      ResponsiveGridCol(
                          xs: 6,
                          md: 6,
                          lg: 6,
                          xl: 6,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              m.Padding(
                                padding:
                                    const EdgeInsets.only(left: 10, right: 10),
                                child: NeumorphicButton(
                                  child: Icon(
                                    Icons.play_arrow_rounded,
                                    color: iconColor(),
                                  ),
                                  onPressed: () async {
                                    await viewUmlRender();
                                  },
                                ),
                              ),
                              m.Padding(
                                padding:
                                    const EdgeInsets.only(left: 10, right: 10),
                                child: NeumorphicButton(
                                  child:
                                      NeumorphicTheme.of(context)!.themeMode ==
                                              ThemeMode.dark
                                          ? Icon(Icons.light_mode,
                                              color: iconColor())
                                          : Icon(Icons.dark_mode,
                                              color: iconColor()),
                                  onPressed: () {
                                    lightDarkModeToggle();
                                  },
                                ),
                              ),
                              m.Padding(
                                padding:
                                    const EdgeInsets.only(left: 10, right: 10),
                                child: DropdownButton(
                                    dropdownColor: NeumorphicTheme.of(context)!
                                                .themeMode ==
                                            ThemeMode.dark
                                        ? const m.Color.fromARGB(
                                            255, 58, 58, 58)
                                        : Colors.white,
                                    // focusColor: iconColor(),
                                    style: TextStyle(color: iconColor()),
                                    iconEnabledColor: iconColor(),
                                    value: initialItemValue,
                                    items: _itemNames
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
                                      return DropdownMenuItem(
                                        value: value,
                                        child: m.Text(value),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      // ``break`` is just syntax sugar
                                      switch (value) {
                                        case nameSequence:
                                          setState(() {
                                            initialItemValue = value!;
                                            _controller.text =
                                                ex.sequenceDiagram;
                                          });
                                        case nameUseCase:
                                          setState(() {
                                            initialItemValue = value!;
                                            _controller.text =
                                                ex.useCaseDiagram;
                                          });
                                        case nameClass:
                                          setState(() {
                                            initialItemValue = value!;
                                            _controller.text = ex.classDiagram;
                                          });
                                        case nameObject:
                                          setState(() {
                                            initialItemValue = value!;
                                            _controller.text = ex.objectDiagram;
                                          });
                                        case nameActivity:
                                          setState(() {
                                            initialItemValue = value!;
                                            _controller.text =
                                                ex.activityDiagram;
                                          });
                                        case nameComponent:
                                          setState(() {
                                            initialItemValue = value!;
                                            _controller.text =
                                                ex.componentDiagram;
                                          });
                                        case nameDeployment:
                                          setState(() {
                                            initialItemValue = value!;
                                            _controller.text =
                                                ex.deploymentDiagram;
                                          });

                                        case nameState:
                                          setState(() {
                                            initialItemValue = value!;
                                            _controller.text = ex.stateDiagram;
                                          });
                                        case nameTiming:
                                          setState(() {
                                            initialItemValue = value!;
                                            _controller.text = ex.timingDiagram;
                                          });
                                        default:
                                      }
                                    }),
                              )
                            ],
                          )),
                      ResponsiveGridCol(
                          xs: 6,
                          md: 6,
                          lg: 6,
                          xl: 6,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              NeumorphicButton(
                                child: Icon(Icons.download, color: iconColor()),
                                onPressed: () async {
                                  await saveDiagramDesktop(context);
                                },
                              ),
                            ],
                          )),
                    ],
                  )),
            ],
          ),
        ));
  }
}
