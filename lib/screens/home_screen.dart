import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:work_manager_demo/helper/auth_helper.dart';
import 'package:work_manager_demo/res/color_resources.dart';
import 'package:work_manager_demo/screens/admin_screens/admin_home_screen.dart';
import 'package:work_manager_demo/widgets/category_tile.dart';
import 'package:work_manager_demo/widgets/grid_item.dart';
import 'package:workmanager/workmanager.dart';

import '../main.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

const String TAG = "BackGround_Work";

class _HomeScreenState extends State<HomeScreen> {
  List categories = [];
  final CollectionReference _collectionReference =
      FirebaseFirestore.instance.collection('wallpapers');
  List imageUrls = [];
  int _currentIndex = 0;
  String profileImage = '';
  String email = '';
  String username = '';
  bool isAutoChange = false;
  bool onWifi = false;
  bool charging = false;
  bool idle = false;
  String interval = '';
  String screen = 'Home and Lock Screen';
  String source = 'Random Wallpapers';
  String theme = 'System';

  // ThemeMode theme = ThemeMode.system;
  //
  // get themeMode => theme;

  @override
  void initState() {
    super.initState();
    // isAutoChange = false;
    getAutoChange();
    getCategoryAndImage();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    final double itemHeight = (size.height - kToolbarHeight - 24) / 2.5;
    final double itemWidth = size.width / 2;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Wallpaper',
        ),
        centerTitle: true,
      ),
      body: Container(
        margin: const EdgeInsets.all(8),
        child: Column(
          children: [
            SizedBox(
              height: 80,
              child: ListView.builder(
                  itemCount: categories.length,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (ctx, index) {
                    // getImageUrl(categories[index]);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                      child: CategoryTile(
                        imageUrl: imageUrls.isNotEmpty
                            ? imageUrls[index]
                            : 'https://firebasestorage.googleapis.com/v0/b/wallpaper-app-69c12.appspot.com/o/uploads%2Fimage_picker2649116931654427709.jpg?alt=media&token=f93b5e5f-9bf8-44c9-80bb-c4d999aa9671',
                        category: categories[index],
                      ),
                    );
                  }),
            ),
            Expanded(
              child: categories.isNotEmpty
                  ? StreamBuilder(
                      stream: _collectionReference
                          .doc(categories[_currentIndex])
                          .collection('images')
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<dynamic> snapshot) {
                        return snapshot.hasData
                            ? GridView.builder(
                                itemCount: snapshot.data.docs.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 3,
                                  crossAxisSpacing: 3,
                                  childAspectRatio: itemWidth / itemHeight,
                                ),
                                itemBuilder: (ctx, index) {
                                  return GridItem(
                                      snapshot.data.docs[index]['url']);
                                })
                            : const Center(child: CircularProgressIndicator());
                      })
                  : const Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
                child: Column(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(profileImage),
                  radius: 40,
                ),
                const SizedBox(height: 5),
                Text(
                  username,
                  // style: TextStyle(color: colorWhite),
                ),
                Text(email),
              ],
            )),
            const ListTile(
              title: Text('Settings'),
            ),
            ListTile(
              title: const Text('Auto Change Wallpaper'),
              onTap: () {},
              trailing: SizedBox(
                height: 20,
                child: Transform.scale(
                  scale: .7,
                  child: CupertinoSwitch(
                    value: isAutoChange,
                    onChanged: (value) {
                      toggleSwitch(value);
                    },
                  ),
                ),
              ),
            ),
            const Divider(),
            const ListTile(
              title: Text('Conditions'),
            ),
            ListTile(
              title: const Text('On Wi-fi'),
              subtitle: const Text(
                'Device must be connected to a Wifi-network.',
                style: TextStyle(fontSize: 12, color: grey),
              ),
              trailing: Checkbox(
                value: onWifi,
                onChanged: isAutoChange
                    ? (value) {
                        setState(() {
                          onWifi = value!;
                        });
                      }
                    : null,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            ),
            ListTile(
              title: const Text('Charging'),
              subtitle: const Text(
                'Device must be connected to a power source.',
                style: TextStyle(fontSize: 12, color: grey),
              ),
              trailing: Checkbox(
                value: charging,
                onChanged: isAutoChange
                    ? (value) {
                        setState(() {
                          charging = value!;
                        });
                        autoChangeWallpaper();
                      }
                    : null,
              ),
            ),
            ListTile(
              title: const Text('Idle'),
              subtitle: const Text(
                'Device must be inactive.',
                style: TextStyle(fontSize: 12, color: grey),
              ),
              trailing: Checkbox(
                value: idle,
                onChanged: isAutoChange
                    ? (value) {
                        setState(() {
                          idle = value!;
                        });
                        autoChangeWallpaper();
                      }
                    : null,
              ),
            ),
            const Divider(),
            const ListTile(
              title: Text('Options'),
            ),
            ListTile(
              title: const Text('Interval'),
              subtitle: Text(
                'Each wallpaper will last for $interval',
                style: TextStyle(fontSize: 12, color: grey),
              ),
              onTap: showIntervalOptions,
            ),
            ListTile(
              title: const Text('Screen'),
              subtitle: Text(
                screen,
                style: const TextStyle(fontSize: 12, color: grey),
              ),
              onTap: showScreenOptions,
            ),
            ListTile(
              title: const Text('Source'),
              subtitle: Text(
                source,
                style: const TextStyle(fontSize: 12, color: grey),
              ),
              onTap: showSourceOptions,
            ),
            ListTile(
              title: const Text('Theme'),
              subtitle: Text(
                theme,
                style: const TextStyle(fontSize: 12, color: grey),
              ),
              onTap: showThemeOptions,
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (ctx) => const AdminHomeScreen()));
        },
        child: const Icon(
          Icons.add,
          size: 30,
        ),
      ),
    );
  }

  Future getCategories() async {
    QuerySnapshot snapshot = await _collectionReference.get();
    final data = snapshot.docs.map((e) => e.id).toList();
    setState(() {
      categories = data;
    });
  }

  Future<void> getImageUrl() async {
    if (categories.isNotEmpty) {
      for (var category in categories) {
        Stream<QuerySnapshot> snapshot = _collectionReference
            .doc(category)
            .collection('images')
            .limit(1)
            .snapshots();
        snapshot.forEach((element) {
          element.docs.asMap().forEach((key, value) {
            imageUrls.add(element.docs.first.get('url'));
            setState(() {});
          });
        });
      }
    }
  }

  Future getCategoryAndImage() async {
    await getProfile();
    await getCategories();
    await getImageUrl();
  }

  Future<void> getProfile() async {
    final CollectionReference collectionReference =
        FirebaseFirestore.instance.collection('users');
    try {
      DocumentSnapshot snapshot =
          await collectionReference.doc(AuthHelper().user.uid).get();
      profileImage = snapshot.get('photoUrl');
      email = snapshot.get('email');
      username = snapshot.get('username');
      setState(() {});
    } on Exception catch (e) {
      print(e);
    }
    // return profileImage;
  }

  toggleSwitch(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isAutoChanges', value);
    autoChangeWallpaper();
  }

  getAutoChange() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isAutoChange = prefs.getBool('isAutoChanges') ?? false;
    setState(() {});
  }

  autoChangeWallpaper() async {
    // WallpaperSetting().buttonPressed(isAutoChange);
    await getAutoChange();
    print(isAutoChange);
    if (isAutoChange == false) {
      print('task cancelled');
      Workmanager().cancelAll();
    } else {
      Workmanager().cancelAll();
      Workmanager().registerPeriodicTask(
        "2",
        periodicTask,
        frequency: const Duration(minutes: 15),
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresCharging: charging,
          requiresDeviceIdle: idle,
        ),
      );
    }
  }

  // Future<void> showIntervalOption() async {
  //   interval = await showDialog(
  //       context: context,
  //       builder: (ctx) {
  //         return const SimpleDialog(
  //           children: [
  //             SimpleDialogOption(
  //                 child: ListTile(
  //                     // leading: Radio(
  //                     //   value: '15 minutes',
  //                     // ),
  //                     ))
  //           ],
  //         );
  //       });
  // }

  Future<void> showIntervalOptions() async {
    await showDialog(
        context: context,
        builder: (ctx) {
          return SimpleDialog(
            title: const Text('Select Interval'),
            children: List.generate(6, (index) {
              return RadioListTile(
                  value: intervals[index],
                  groupValue: interval,
                  title: Text(intervals[index]),
                  onChanged: (value) {
                    setState(() {
                      interval = value.toString();
                    });
                    Navigator.pop(context);
                  });
            }),
          );
        });
    // print(intervals[2]);
  }

  Future<void> showScreenOptions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    screen = await showDialog(
        context: context,
        builder: (ctx) {
          return SimpleDialog(
            title: const Text('Select Screen'),
            children: [
              SimpleDialogOption(
                child: const Text('Home Screen'),
                onPressed: () {
                  prefs.setInt('screen', WallpaperManager.HOME_SCREEN);
                  Navigator.pop(context, 'Home Screen');
                },
              ),
              SimpleDialogOption(
                child: const Text('Lock Screen'),
                onPressed: () {
                  prefs.setInt('screen', WallpaperManager.LOCK_SCREEN);
                  Navigator.pop(context, 'Lock Screen');
                },
              ),
              SimpleDialogOption(
                child: const Text('Both'),
                onPressed: () {
                  prefs.setInt('screen', WallpaperManager.BOTH_SCREEN);
                  Navigator.pop(context, 'Home and Lock Screen');
                },
              ),
              TextButton(
                  style: ButtonStyle(
                      alignment: Alignment.centerRight,
                      padding:
                          MaterialStateProperty.all(const EdgeInsets.all(20))),
                  onPressed: () {
                    Navigator.pop(context, screen);
                  },
                  child: const Text('Cancel'))
            ],
          );
        });
    setState(() {});
    autoChangeWallpaper();
  }

  Future<void> showSourceOptions() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    source = await showDialog(
        context: context,
        builder: (ctx) {
          return SimpleDialog(
            title: const Text('Select Source'),
            children: [
              SimpleDialogOption(
                child: const Text('Favorite wallpapers'),
                onPressed: () {
                  preferences.setString('source', 'Favorites');
                  Navigator.pop(context, 'Favorite Wallpapers');
                },
              ),
              SimpleDialogOption(
                child: const Text('Random wallpapers'),
                onPressed: () {
                  preferences.setString('source', 'Random');
                  Navigator.pop(context, 'Random Wallpapers');
                },
              ),
              TextButton(
                  style: ButtonStyle(
                      alignment: Alignment.centerRight,
                      padding:
                          MaterialStateProperty.all(const EdgeInsets.all(20))),
                  onPressed: () {
                    Navigator.pop(context, source);
                  },
                  child: const Text('Cancel'))
            ],
          );
        });
    setState(() {});
    autoChangeWallpaper();
  }

  Future<void> showThemeOptions() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    theme = await showDialog(
        context: context,
        builder: (ctx) {
          return SimpleDialog(
            title: const Text('Theme'),
            children: [
              SimpleDialogOption(
                child: const Text('Light'),
                onPressed: () {
                  MyApp.of(ctx)?.changeTheme(theme: ThemeMode.light);
                  Navigator.pop(context, 'Light');
                },
              ),
              SimpleDialogOption(
                child: const Text('Dark'),
                onPressed: () {
                  MyApp.of(ctx)?.changeTheme(theme: ThemeMode.dark);
                  Navigator.pop(context, 'Dark');
                },
              ),
              SimpleDialogOption(
                child: const Text('System'),
                onPressed: () {
                  MyApp.of(ctx)?.changeTheme(theme: ThemeMode.system);
                  Navigator.pop(context, 'System');
                },
              ),
              TextButton(
                  style: ButtonStyle(
                      alignment: Alignment.centerRight,
                      padding:
                          MaterialStateProperty.all(const EdgeInsets.all(20))),
                  onPressed: () {
                    Navigator.pop(context, theme);
                  },
                  child: const Text('Cancel'))
            ],
          );
        });
    setState(() {});
  }

  final intervals = [
    'Every 15 minutes',
    'Every 30 minutes',
    'Every 1 hour',
    'Every 2 hours',
    'Every 5 hours',
    'Every 10 hours'
  ];
}
