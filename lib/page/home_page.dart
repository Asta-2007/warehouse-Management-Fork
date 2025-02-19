import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:werehouse_inventory/page/first_screen.dart';
import 'package:werehouse_inventory/shered_data_to_root/websocket_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePagesState();
}

class _HomePagesState extends State<HomePage> {
  final GlobalKey<ScaffoldState> drawer = GlobalKey<ScaffoldState>();
  final storage = FlutterSecureStorage();
  Future<dynamic> detailAdmin(BuildContext context) async {
    final String? name = await storage.read(key: "adminName");

    if (!context.mounted) {
      return;
    }
    return showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) {
        return Stack(
          children: [
            Positioned(
              top: 50,
              right: 10,
              child: Container(
                width: 150,
                height: 50,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(5),
                ),
                padding: EdgeInsets.only(
                  left: 5,
                  right: 5,
                ),
                child: Center(
                  child: Text(
                    "Name : $name",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
            )
          ],
        );
      },
    );
  }

  Future<dynamic> messages(BuildContext context, String response) {
    return showDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: false,
      builder: (context) => AlertDialog.adaptive(
        backgroundColor: Theme.of(context).colorScheme.error,
        title: Text(
          "MESSAGE",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        content: Text(
          response,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              "Yes",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final secondaryWs = Provider.of<WebsocketHelper>(context, listen: true);
    secondaryWs.chekVerifikasi();
    secondaryWs.removeTokenIfExp();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      key: drawer,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => drawer.currentState!.openDrawer(),
          icon: Icon(
            color: Theme.of(context).colorScheme.onPrimary,
            Icons.list,
          ),
        ),
        title: Text(
          "GUDANG TKJ",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => detailAdmin(context),
            icon: Icon(
              Icons.person,
            ),
          ),
          const SizedBox(
            width: 20,
          ),
        ],
      ),
      drawer: Drawer(
        child: Stack(
          children: [
            ListView(
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  duration: const Duration(milliseconds: 5),
                  child: Text(
                    "Menu ",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 15,
              right: 15,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
                onPressed: () async {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FirstScreen(),
                    ),
                    (route) => false,
                  );

                  await storage.delete(key: 'token');
                },
                child: Text(
                  'logout',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 680) {
            print(constraints.maxWidth);
            return Stack(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                Positioned(
                  left: constraints.maxWidth * 0.1,
                  top: constraints.maxWidth * 0.15,
                  right: constraints.maxWidth * 0.1,
                  child: Container(
                    width: constraints.maxWidth * 0.65,
                    height: constraints.maxWidth * 0.5,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                )
              ],
            );
          } else if (constraints.maxWidth < 800) {
            debugPrint("${constraints.maxWidth}");
            return Stack(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                Positioned(
                  left: constraints.maxWidth * 0.25,
                  top: constraints.maxHeight * 0.1,
                  child: Container(
                    width: constraints.maxWidth * 0.65,
                    height: constraints.maxWidth * 0.55,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                )
              ],
            );
          } else if (constraints.maxWidth < 990) {
            return Stack(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                Positioned(
                  left: constraints.maxWidth * 0.4,
                  top: constraints.maxHeight * 0.1,
                  child: Container(
                    width: constraints.maxWidth * 0.55,
                    height: constraints.maxWidth * 0.45,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                Positioned(
                  left: constraints.maxWidth * 0.02,
                  top: constraints.maxHeight * 0.35,
                  child: Container(
                    width: size.width * 0.33,
                    height: constraints.maxWidth * 0.15,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            );
          } else {
            debugPrint("${constraints.maxWidth}");
            return dekstop(context, size, constraints);
          }
        },
      ),
    );
  }

  Stack dekstop(BuildContext context, Size size, BoxConstraints constraints) {
    return Stack(
      children: [
        Row(
          children: [
            Expanded(
              flex: 4,
              child: Container(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        Positioned(
          left: size.width * 0.45,
          top: constraints.maxHeight * 0.1,
          child: Container(
            width: size.width * 0.5,
            height: constraints.maxWidth * 0.35,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        Positioned(
          left: constraints.maxWidth * 0.05,
          top: constraints.maxHeight * 0.25,
          child: Container(
            width: size.width * 0.35,
            height: constraints.maxWidth * 0.15,
            color: Theme.of(context).colorScheme.secondary,
          ),
        )
      ],
    );
  }
}
