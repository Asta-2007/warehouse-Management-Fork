import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatelessWidget {
  HomePage({
    super.key,
  });

  final GlobalKey<ScaffoldState> drawer = GlobalKey<ScaffoldState>();

  Future<String?> nameAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    final String? name = prefs.getString("adminName");

    return name;
  }

  Future<dynamic> detailAdmin(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final String? name = prefs.getString("adminName");

    if (!context.mounted) {
      return;
    }
    return showDialog(
      context: context,
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 680) {
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
                    height: constraints.maxHeight * 0.66,
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
