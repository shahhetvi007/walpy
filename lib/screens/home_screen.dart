import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:work_manager_demo/helper/auth_helper.dart';
import 'package:work_manager_demo/helper/prefs_utils.dart';
import 'package:work_manager_demo/res/color_resources.dart';
import 'package:work_manager_demo/screens/admin_screens/admin_home_screen.dart';
import 'package:work_manager_demo/screens/admin_screens/favorite_screen.dart';
import 'package:work_manager_demo/screens/signin_screen.dart';
import 'package:work_manager_demo/widgets/category_tile.dart';
import 'package:work_manager_demo/widgets/grid_item.dart';
import 'package:workmanager/workmanager.dart';

import '../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

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
  String screen = '';
  String source = 'Random wallpapers';
  String theme = '';
  Duration duration = const Duration(minutes: 15);
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    getAllSettings();
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
          'Walpy',
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: getCategoryAndImage,
        child: Container(
          margin: EdgeInsets.all(size.width * 0.02),
          child: Column(
            children: [
              SizedBox(
                height: size.height * 0.1,
                child: ListView.builder(
                    itemCount: isAdmin ? categories.length + 1 : categories.length,
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (ctx, index) {
                      // getImageUrl(categories[index]);
                      return index == 0
                          ? GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (ctx) => AdminHomeScreen()));
                              },
                              child: Container(
                                height: 50,
                                width: 100,
                                margin:
                                    const EdgeInsets.only(left: 5, right: 5, bottom: 8),
                                decoration: BoxDecoration(
                                  border: Border.all(color: colorTheme),
                                  color: colorWhite,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.add,
                                  size: 30,
                                ),
                              ))
                          : GestureDetector(
                              onTap: () {
                                setState(() {
                                  _currentIndex = index - 1;
                                });
                              },
                              child: CategoryTile(
                                imageUrl: imageUrls.isNotEmpty
                                    ? imageUrls[index - 1]
                                    : 'https://firebasestorage.googleapis.com/v0/b/wallpaper-app-69c12.appspot.com/o/uploads%2Fimage_picker2649116931654427709.jpg?alt=media&token=f93b5e5f-9bf8-44c9-80bb-c4d999aa9671',
                                category: categories[index - 1],
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
                        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                          return snapshot.hasData
                              ? GridView.builder(
                                  itemCount: isAdmin
                                      ? snapshot.data.docs.length + 1
                                      : snapshot.data.docs.length,
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 3,
                                    crossAxisSpacing: 3,
                                    childAspectRatio: itemWidth / itemHeight,
                                  ),
                                  itemBuilder: (ctx, index) {
                                    return index == 0
                                        ? GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (ctx) => AdminHomeScreen(
                                                          category: _collectionReference
                                                              .doc(categories[
                                                                  _currentIndex])
                                                              .id)));
                                            },
                                            child: addImageContainer())
                                        : GridItem(snapshot.data.docs[index - 1]['url']);
                                  })
                              : const Center(child: CircularProgressIndicator());
                        })
                    : const Center(child: CircularProgressIndicator()),
              ),
            ],
          ),
        ),
      ),
      drawer: drawer(),
    );
  }

  Widget drawer() {
    return Drawer(
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
            title: Text(
              'Settings',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            title: const Text(
              'Auto Change Wallpaper',
              style: TextStyle(fontSize: 14),
            ),
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
            title: Text(
              'Conditions',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
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
            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
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
            title: Text(
              'Options',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            title: const Text('Interval'),
            subtitle: Text(
              'Each wallpaper will last for $interval',
              style: const TextStyle(fontSize: 12, color: grey),
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
            onTap: () => showThemeOptions(),
          ),
          const Divider(),
          ListTile(
            title: const Text(
              'Favorites',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (ctx) => const FavoriteScreen()));
            },
          ),
          ListTile(
            title: const Text(
              'Logout',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            onTap: logout,
          ),
        ],
      ),
    );
  }

  logout() {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                  onPressed: () async {
                    await AuthHelper().signOut().then((val) {
                      print('signed out');
                      print(AuthHelper().user);
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (ctx) => const SignInScreen()));
                    });
                  },
                  child: const Text('Yes')),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel')),
            ],
          );
        });
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
        Stream<QuerySnapshot> snapshot =
            _collectionReference.doc(category).collection('images').limit(1).snapshots();
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
    print(value);
    PreferenceUtils.setBool('isAutoChanges', value);
    autoChangeWallpaper();
  }

  getAutoChange() async {
    isAutoChange = PreferenceUtils.getBool('isAutoChanges', false);
    setState(() {});
  }

  getAllSettings() {
    interval = PreferenceUtils.getString('interval', 'every 15 minutes');
    int val = PreferenceUtils.getInt('screen', 1);
    if (val == 1) {
      screen = 'Home Screen';
    } else if (val == 2) {
      screen = 'Lock Screen';
    } else {
      screen = 'Home and Lock Screen';
    }
    source = PreferenceUtils.getString('source', 'Random Wallpapers');
    theme = PreferenceUtils.getString('theme', 'System');
    setState(() {});
    isAdmin = PreferenceUtils.getBool('isAdmin');
  }

  autoChangeWallpaper() async {
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
        frequency: duration,
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresCharging: charging,
          requiresDeviceIdle: idle,
        ),
      );
      print('Duration');
      print(duration.toString());
    }
  }

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
                  selected: true,
                  onChanged: (value) {
                    print(value);
                    setState(() {
                      interval = value.toString();
                      PreferenceUtils.setString(
                          'interval', value.toString().toLowerCase());
                    });
                    getDuration();
                    if (isAutoChange) autoChangeWallpaper();
                    Navigator.pop(context);
                  });
            }),
          );
        });
    // print(interval);
  }

  Future<void> showScreenOptions() async {
    screen = await showDialog(
        context: context,
        builder: (ctx) {
          return SimpleDialog(
            title: const Text('Select Screen'),
            children: [
              SimpleDialogOption(
                child: const Text('Home Screen'),
                onPressed: () {
                  PreferenceUtils.setInt('screen', WallpaperManager.HOME_SCREEN);

                  Navigator.pop(context, 'Home Screen');
                },
              ),
              SimpleDialogOption(
                child: const Text('Lock Screen'),
                onPressed: () {
                  PreferenceUtils.setInt('screen', WallpaperManager.LOCK_SCREEN);
                  Navigator.pop(context, 'Lock Screen');
                },
              ),
              SimpleDialogOption(
                child: const Text('Both'),
                onPressed: () {
                  PreferenceUtils.setInt('screen', WallpaperManager.BOTH_SCREEN);
                  Navigator.pop(context, 'Home and Lock Screen');
                },
              ),
              TextButton(
                  style: ButtonStyle(
                      alignment: Alignment.centerRight,
                      padding: MaterialStateProperty.all(const EdgeInsets.all(20))),
                  onPressed: () {
                    Navigator.pop(context, screen);
                  },
                  child: const Text('Cancel'))
            ],
          );
        });
    setState(() {});
    if (isAutoChange) autoChangeWallpaper();
  }

  Future<void> showSourceOptions() async {
    source = await showDialog(
        context: context,
        builder: (ctx) {
          return SimpleDialog(
            title: const Text('Select Source'),
            children: [
              SimpleDialogOption(
                child: const Text('Favorite wallpapers'),
                onPressed: () {
                  PreferenceUtils.setString('source', 'Favorite Wallpapers');
                  Navigator.pop(context, 'Favorite Wallpapers');
                },
              ),
              SimpleDialogOption(
                child: const Text('Random wallpapers'),
                onPressed: () {
                  PreferenceUtils.setString('source', 'Random Wallpapers');
                  Navigator.pop(context, 'Random Wallpapers');
                },
              ),
              TextButton(
                  style: ButtonStyle(
                      alignment: Alignment.centerRight,
                      padding: MaterialStateProperty.all(const EdgeInsets.all(20))),
                  onPressed: () {
                    Navigator.pop(context, source);
                  },
                  child: const Text('Cancel'))
            ],
          );
        });
    setState(() {});
    if (isAutoChange) autoChangeWallpaper();
  }

  Future<void> showThemeOptions() async {
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
                  PreferenceUtils.setString('theme', 'Light');
                  Navigator.pop(context, 'Light');
                },
              ),
              SimpleDialogOption(
                child: const Text('Dark'),
                onPressed: () {
                  MyApp.of(ctx)?.changeTheme(theme: ThemeMode.dark);
                  PreferenceUtils.setString('theme', 'Dark');
                  Navigator.pop(context, 'Dark');
                },
              ),
              SimpleDialogOption(
                child: const Text('System'),
                onPressed: () {
                  MyApp.of(ctx)?.changeTheme(theme: ThemeMode.system);
                  PreferenceUtils.setString('theme', 'System');
                  Navigator.pop(context, 'System');
                },
              ),
              TextButton(
                  style: ButtonStyle(
                      alignment: Alignment.centerRight,
                      padding: MaterialStateProperty.all(const EdgeInsets.all(20))),
                  onPressed: () {
                    Navigator.pop(context, theme);
                  },
                  child: const Text('Cancel'))
            ],
          );
        });
    setState(() {});
  }

  void getDuration() {
    switch (interval) {
      case 'every 15 minutes':
        duration = const Duration(minutes: 15);
        break;
      case 'every 30 minutes':
        duration = const Duration(minutes: 30);
        break;
      case 'every 1 hour':
        duration = const Duration(hours: 1);
        break;
      case 'every 2 hours':
        duration = const Duration(hours: 2);
        break;
      case 'every 5 hours':
        duration = const Duration(hours: 5);
        break;
      case 'every 10 hours':
        duration = const Duration(hours: 10);
        break;
      default:
        duration = const Duration(minutes: 15);
        break;
    }
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

  Widget addImageContainer() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            border: Border.all(color: colorTheme),
            borderRadius: BorderRadius.circular(15),
            color: colorWhite),
        child: const Icon(
          Icons.add,
          size: 40,
        ),
      ),
    );
  }
}
