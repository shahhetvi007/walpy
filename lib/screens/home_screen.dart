import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:work_manager_demo/helper/auth_helper.dart';
import 'package:work_manager_demo/helper/prefs_utils.dart';
import 'package:work_manager_demo/res/color_resources.dart';
import 'package:work_manager_demo/screens/admin_screens/admin_home_screen.dart';
import 'package:work_manager_demo/screens/admin_screens/favorite_screen.dart';
import 'package:work_manager_demo/screens/detail_screen.dart';
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
  bool? isAutoChange;
  bool? onWifi;
  bool? charging;
  bool? idle;
  String interval = '';
  String screen = '';
  String source = 'Random wallpapers';
  String theme = '';
  Duration duration = const Duration(minutes: 15);
  bool isAdmin = false;
  bool isLoading = false;
  bool isDrawerLoading = false;

  @override
  void initState() {
    super.initState();
    isAdmin = PreferenceUtils.getBool('isAdmin');
    getAutoChange();
    getAllSettings();
    getCategoryAndImage();
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    getAllSettings();
    super.didUpdateWidget(oldWidget);
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: getCategoryAndImage,
              child: Container(
                margin: EdgeInsets.all(size.width * 0.02),
                child: Column(
                  children: [
                    SizedBox(
                      height: size.height * 0.1,
                      child: ListView.builder(
                          itemCount: isAdmin ? categories.length + 1 : categories.length,
                          padding:
                              const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (ctx, index) {
                            // getImageUrl(categories[index]);
                            if (isAdmin) {
                              return index == 0
                                  ? GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (ctx) => AdminHomeScreen()));
                                      },
                                      child: Stack(
                                        children: [
                                          Container(
                                            height: 50,
                                            width: 100,
                                            margin: const EdgeInsets.only(
                                              left: 5,
                                              right: 5,
                                            ),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Theme.of(context).primaryColor,
                                              ),
                                              color: Theme.of(context)
                                                  .scaffoldBackgroundColor,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              Icons.add,
                                              size: 30,
                                              color: Theme.of(context).primaryColor,
                                            ),
                                          ),
                                        ],
                                      ))
                                  : GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _currentIndex = index - 1;
                                        });
                                      },
                                      child: CategoryTile(
                                        category: categories[index - 1],
                                      ),
                                    );
                            }
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _currentIndex = index;
                                });
                              },
                              child: CategoryTile(
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
                                return snapshot.hasData && AuthHelper().user != null
                                    ? GridView.builder(
                                        itemCount: isAdmin
                                            ? snapshot.data.docs.length + 1
                                            : snapshot.data.docs.length,
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          mainAxisSpacing: 3,
                                          crossAxisSpacing: 3,
                                          childAspectRatio: itemWidth / itemHeight,
                                        ),
                                        itemBuilder: (ctx, index) {
                                          RegExp regExp = RegExp(r'.+(\/|%2F)(.+)\?.+');
                                          if (isAdmin) {
                                            String filename = '';
                                            if (index != 0) {
                                              var matches = regExp.allMatches(
                                                  snapshot.data.docs[index - 1]['url']);
                                              var match = matches.elementAt(0);
                                              filename = Uri.decodeFull(match.group(2)!);
                                            }
                                            return index == 0
                                                ? GestureDetector(
                                                    onTap: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (ctx) => AdminHomeScreen(
                                                                  category:
                                                                      _collectionReference
                                                                          .doc(categories[
                                                                              _currentIndex])
                                                                          .id)));
                                                    },
                                                    child: addImageContainer())
                                                : GridItem(
                                                    snapshot.data.docs[index - 1]['url'],
                                                    filename);
                                          }
                                          var matches = regExp.allMatches(
                                              snapshot.data.docs[index]['url']);
                                          var match = matches.elementAt(0);
                                          String filename =
                                              Uri.decodeFull(match.group(2)!);
                                          return GridItem(
                                              snapshot.data.docs[index]['url'], filename);
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
    return SafeArea(
      child: Drawer(
        child: isDrawerLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  DrawerHeader(
                      child: Column(
                    children: [
                      CircleAvatar(
                        backgroundImage: profileImage != ''
                            ? NetworkImage(profileImage)
                            : Image.asset('assets/images/acc_placeholder.jpeg').image,
                        radius: 40,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        username,
                        style: TextStyle(
                          fontFamily: 'Jost',
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      Text(
                        email,
                        style: TextStyle(
                          fontFamily: 'Jost',
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  )),
                  if (!isAdmin)
                    ListTile(
                      title: Text(
                        'Settings',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Jost',
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  if (!isAdmin)
                    ListTile(
                      title: Text(
                        'Auto Change Wallpaper',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Jost',
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      subtitle: Text(
                        'Change wallpaper periodically, based on the conditions below',
                        style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).primaryColor,
                            fontFamily: 'Jost'),
                      ),
                      onTap: () {},
                      trailing: SizedBox(
                        height: 20,
                        child: Transform.scale(
                          scale: .7,
                          child: CupertinoSwitch(
                            value: isAutoChange ?? false,
                            onChanged: (value) {
                              toggleSwitch(value);
                              // setState(() {
                              //   isAutoChange = value;
                              // });
                            },
                            activeColor: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                  if (!isAdmin) const Divider(),
                  if (!isAdmin)
                    ListTile(
                      title: Text(
                        'Conditions',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Jost',
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  if (!isAdmin)
                    ListTile(
                      title: Text(
                        'On Wi-fi',
                        style: TextStyle(
                          fontFamily: 'Jost',
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      subtitle: Text(
                        'Device must be connected to a Wifi-network.',
                        style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).primaryColor,
                            fontFamily: 'Jost'),
                      ),
                      trailing: Checkbox(
                        value: onWifi,
                        fillColor: isAutoChange ?? false
                            ? MaterialStatePropertyAll<Color>(
                                Theme.of(context).primaryColor,
                              )
                            : const MaterialStatePropertyAll<Color>(grey),
                        checkColor: Theme.of(context).scaffoldBackgroundColor,
                        onChanged: isAutoChange ?? false
                            ? (value) {
                                setState(() {
                                  onWifi = value!;
                                });
                                PreferenceUtils.setBool('onWifi', onWifi ?? false);
                                autoChangeWallpaper();
                              }
                            : null,
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    ),
                  if (!isAdmin)
                    ListTile(
                      title: Text(
                        'Charging',
                        style: TextStyle(
                          fontFamily: 'Jost',
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      subtitle: Text(
                        'Device must be connected to a power source.',
                        style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).primaryColor,
                            fontFamily: 'Jost'),
                      ),
                      trailing: Checkbox(
                        fillColor: isAutoChange ?? false
                            ? MaterialStatePropertyAll<Color>(
                                Theme.of(context).primaryColor,
                              )
                            : const MaterialStatePropertyAll<Color>(grey),
                        checkColor: Theme.of(context).scaffoldBackgroundColor,
                        // checkColor: colorTheme,
                        value: charging,
                        onChanged: isAutoChange ?? false
                            ? (value) {
                                setState(() {
                                  charging = value!;
                                });
                                PreferenceUtils.setBool('charging', charging ?? false);
                                autoChangeWallpaper();
                              }
                            : null,
                      ),
                    ),
                  if (!isAdmin)
                    ListTile(
                      title: Text(
                        'Idle',
                        style: TextStyle(
                          fontFamily: 'Jost',
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      subtitle: Text(
                        'Device must be inactive.',
                        style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).primaryColor,
                            fontFamily: 'Jost'),
                      ),
                      trailing: Checkbox(
                        value: idle,
                        fillColor: isAutoChange ?? false
                            ? MaterialStatePropertyAll<Color>(
                                Theme.of(context).primaryColor,
                              )
                            : const MaterialStatePropertyAll<Color>(grey),
                        checkColor: Theme.of(context).scaffoldBackgroundColor,
                        onChanged: isAutoChange ?? false
                            ? (value) {
                                setState(() {
                                  idle = value!;
                                });
                                PreferenceUtils.setBool('idle', idle ?? false);
                                autoChangeWallpaper();
                              }
                            : null,
                      ),
                    ),
                  if (!isAdmin) const Divider(),
                  if (!isAdmin)
                    ListTile(
                      title: Text(
                        'Options',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Jost',
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  if (!isAdmin)
                    ListTile(
                      title: Text(
                        'Interval',
                        style: TextStyle(
                          fontFamily: 'Jost',
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      subtitle: Text(
                        'Each wallpaper will last for $interval',
                        style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).primaryColor,
                            fontFamily: 'Jost'),
                      ),
                      onTap: showIntervalOptions,
                    ),
                  if (!isAdmin)
                    ListTile(
                      title: Text(
                        'Screen',
                        style: TextStyle(
                          fontFamily: 'Jost',
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      subtitle: Text(
                        screen,
                        style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).primaryColor,
                            fontFamily: 'Jost'),
                      ),
                      onTap: showScreenOptions,
                    ),
                  if (!isAdmin)
                    ListTile(
                      title: Text(
                        'Source',
                        style: TextStyle(
                          fontFamily: 'Jost',
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      subtitle: Text(
                        source,
                        style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).primaryColor,
                            fontFamily: 'Jost'),
                      ),
                      onTap: showSourceOptions,
                    ),
                  GestureDetector(
                    onTap: () => showThemeOptions(),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          if (isAdmin)
                            Icon(
                              Icons.palette,
                              color: Theme.of(context).primaryColor,
                              size: 28,
                            ),
                          if (isAdmin)
                            const SizedBox(
                              width: 24,
                            ),
                          Column(
                            children: [
                              Text(
                                'Theme',
                                style: TextStyle(
                                  fontFamily: 'Jost',
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              Text(
                                theme,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).primaryColor,
                                    fontFamily: 'Jost'),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  if (!isAdmin) const Divider(),
                  if (!isAdmin)
                    ListTile(
                      title: Text(
                        'Favorites',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Jost',
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (ctx) => const FavoriteScreen()));
                      },
                    ),
                  Divider(),
                  GestureDetector(
                    onTap: logout,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          if (isAdmin)
                            Icon(
                              Icons.logout,
                              color: Theme.of(context).primaryColor,
                              size: 28,
                            ),
                          if (isAdmin)
                            const SizedBox(
                              width: 24,
                            ),
                          Text(
                            'Logout',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Jost',
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 4),
                ],
              ),
      ),
    );
  }

  logout() {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text(
              'Are you sure you want to logout?',
              style: TextStyle(fontFamily: 'Jost', color: Theme.of(context).primaryColor),
            ),
            actions: [
              TextButton(
                  onPressed: () async {
                    setState(() {
                      isLoading = true;
                    });
                    await AuthHelper().signOut().then((val) {
                      print('signed out');
                      print(AuthHelper().user);
                      Navigator.pop(context);
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (ctx) => const SignInScreen()));
                    });
                    setState(() {
                      isLoading = false;
                    });
                  },
                  child: Text(
                    'Yes',
                    style: TextStyle(
                      fontFamily: 'Jost',
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  )),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                        fontFamily: 'Jost', color: Theme.of(context).primaryColor),
                  )),
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

  Future getCategoryAndImage() async {
    await getProfile();
    await getCategories();
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
    print('toggle $value');
    await PreferenceUtils.setBool('isAutoChanges', value);
    print(PreferenceUtils.getBool('isAutoChanges'));
    autoChangeWallpaper();
  }

  getAutoChange() {
    print(PreferenceUtils.getBool('isAutoChanges'));
    isAutoChange = PreferenceUtils.getBool('isAutoChanges', false);
    setState(() {});
  }

  getAllSettings() {
    interval = PreferenceUtils.getString('interval', 'every 15 minutes');
    print(interval);
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
    onWifi = PreferenceUtils.getBool('onWifi', true);
    charging = PreferenceUtils.getBool('charging', true);
    idle = PreferenceUtils.getBool('idle', true);

    print('isAdmin $isAdmin');
    setState(() {});
  }

  autoChangeWallpaper() async {
    getAutoChange();
    print('isAutoChange $isAutoChange');
    if (isAutoChange == false) {
      print('task cancelled');
      Workmanager().cancelAll();
    } else {
      setState(() {
        isDrawerLoading = true;
      });
      Workmanager().cancelAll();
      await Workmanager()
          .registerPeriodicTask(
            "2",
            periodicTask,
            frequency: duration,
            constraints: Constraints(
              networkType: NetworkType.connected,
              requiresCharging: charging,
              requiresDeviceIdle: idle,
            ),
          )
          .then((value) => setState(() {
                isDrawerLoading = false;
              }));
      print('Duration');
      print(duration.toString());
    }
  }

  Future<void> showIntervalOptions() async {
    await showDialog(
        context: context,
        builder: (ctx) {
          return SimpleDialog(
            title: Text(
              'Select Interval',
              style: TextStyle(
                  fontFamily: 'Jost',
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor),
            ),
            children: List.generate(6, (index) {
              return RadioListTile(
                  value: intervals[index],
                  groupValue: interval,
                  activeColor: Theme.of(context).primaryColor,
                  title: Text(
                    intervals[index],
                    style: TextStyle(
                        fontFamily: 'Jost', color: Theme.of(context).primaryColor),
                  ),
                  selected: true,
                  onChanged: (value) {
                    print(value.toString().toLowerCase());
                    setState(() {
                      interval = value.toString().toLowerCase();
                      PreferenceUtils.setString(
                          'interval', value.toString().toLowerCase());
                    });
                    getDuration();
                    if (isAutoChange ?? false) autoChangeWallpaper();
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
            title: Text(
              'Select Screen',
              style: TextStyle(
                  fontFamily: 'Jost',
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor),
            ),
            children: [
              SimpleDialogOption(
                child: const Text(
                  'Home Screen',
                  style: TextStyle(fontFamily: 'Jost'),
                ),
                onPressed: () {
                  PreferenceUtils.setInt('screen', WallpaperManager.HOME_SCREEN);

                  Navigator.pop(context, 'Home Screen');
                },
              ),
              SimpleDialogOption(
                child: const Text(
                  'Lock Screen',
                  style: TextStyle(fontFamily: 'Jost'),
                ),
                onPressed: () {
                  PreferenceUtils.setInt('screen', WallpaperManager.LOCK_SCREEN);
                  Navigator.pop(context, 'Lock Screen');
                },
              ),
              SimpleDialogOption(
                child: const Text(
                  'Both',
                  style: TextStyle(fontFamily: 'Jost'),
                ),
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
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                        fontFamily: 'Jost',
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold),
                  ))
            ],
          );
        });
    setState(() {});
    if (isAutoChange ?? false) autoChangeWallpaper();
  }

  Future<void> showSourceOptions() async {
    source = await showDialog(
        context: context,
        builder: (ctx) {
          return SimpleDialog(
            title: Text(
              'Select Source',
              style: TextStyle(
                  fontFamily: 'Jost',
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor),
            ),
            children: [
              SimpleDialogOption(
                child: const Text(
                  'Favorite wallpapers',
                  style: TextStyle(fontFamily: 'Jost'),
                ),
                onPressed: () {
                  PreferenceUtils.setString('source', 'Favorite Wallpapers');
                  Navigator.pop(context, 'Favorite Wallpapers');
                },
              ),
              SimpleDialogOption(
                child: const Text(
                  'Random wallpapers',
                  style: TextStyle(fontFamily: 'Jost'),
                ),
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
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                        fontFamily: 'Jost',
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold),
                  ))
            ],
          );
        });
    setState(() {});
    if (isAutoChange ?? false) autoChangeWallpaper();
  }

  Future<void> showThemeOptions() async {
    theme = await showDialog(
        context: context,
        builder: (ctx) {
          return SimpleDialog(
            title: Text(
              'Theme',
              style: TextStyle(
                  fontFamily: 'Jost',
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor),
            ),
            children: [
              SimpleDialogOption(
                child: const Text(
                  'Light',
                  style: TextStyle(fontFamily: 'Jost'),
                ),
                onPressed: () {
                  MyApp.of(ctx)?.changeTheme(theme: ThemeMode.light);
                  PreferenceUtils.setString('theme', 'Light');
                  Navigator.pop(context, 'Light');
                },
              ),
              SimpleDialogOption(
                child: const Text(
                  'Dark',
                  style: TextStyle(fontFamily: 'Jost'),
                ),
                onPressed: () {
                  MyApp.of(ctx)?.changeTheme(theme: ThemeMode.dark);
                  PreferenceUtils.setString('theme', 'Dark');
                  Navigator.pop(context, 'Dark');
                },
              ),
              SimpleDialogOption(
                child: const Text(
                  'System',
                  style: TextStyle(fontFamily: 'Jost'),
                ),
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
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                        fontFamily: 'Jost',
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold),
                  ))
            ],
          );
        });
    print(theme);
    setState(() {});
  }

  void getDuration() {
    print('intervallllll $interval');
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
          border: Border.all(
            color: Theme.of(context).primaryColor,
          ),
          borderRadius: BorderRadius.circular(15),
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Icon(
          Icons.add,
          size: 60,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
