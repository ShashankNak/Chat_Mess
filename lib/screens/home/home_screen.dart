import 'package:chat_mess/apis/api.dart';
import 'package:chat_mess/screens/auth/start_screen.dart';
import 'package:chat_mess/screens/chats/group_chat.dart';
import 'package:chat_mess/screens/chats/user_chat.dart';
import 'package:chat_mess/screens/contacts/search_contacts.dart';
import 'package:chat_mess/screens/home/profile_screen.dart';
import 'package:chat_mess/widgets/consts.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Api.getSelfInfo();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          leading: Image.asset(
            chatIcon,
            fit: BoxFit.cover,
            height: size.height / 150,
            width: size.height / 150,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          title: Text(
            "Chat Messenger",
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
          ),
          actions: [
            PopupMenuButton<String>(
              shadowColor: Theme.of(context).colorScheme.primary,
              shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              icon: const Icon(Icons.menu),
              onSelected: (value) {
                if (value == 'profile') {
                  Navigator.of(context).push(
                    PageTransition(
                      child: const ProfileScreen(),
                      type: PageTransitionType.rightToLeftWithFade,
                    ),
                  );
                } else if (value == 'logout') {
                  Api.auth.signOut();
                  Navigator.of(context).pushAndRemoveUntil(
                      PageTransition(
                          child: const StartScreen(),
                          type: PageTransitionType.leftToRightWithFade),
                      (route) => false);
                }
              },
              itemBuilder: (context) {
                return [
                  PopupMenuItem<String>(
                    value: 'profile',
                    child: Text(
                      'Profile',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'logout',
                    child: Text(
                      'Logout',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                    ),
                  ),
                ];
              },
            ),
          ],
          bottom: TabBar(
            splashBorderRadius: BorderRadius.circular(40),
            indicatorColor: isDark ? Colors.white : Colors.black,
            labelColor: isDark ? Colors.white : Colors.black,
            indicatorPadding: const EdgeInsets.only(bottom: 4),
            unselectedLabelColor: isDark ? Colors.white60 : Colors.black54,
            physics: const BouncingScrollPhysics(),
            controller: _tabController,
            tabs: const [
              Tab(
                icon: Icon(Icons.person),
                text: "Chat",
              ),
              Tab(
                icon: Icon(Icons.group),
                text: "Group Chat",
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          physics: const BouncingScrollPhysics(
            decelerationRate: ScrollDecelerationRate.normal,
          ),
          children: const [
            UserChatTab(),
            GroupChatTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          splashColor: Theme.of(context).colorScheme.primary,
          backgroundColor:
              isDark ? Colors.white : Theme.of(context).colorScheme.primary,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(size.width / 30),
              bottomLeft: Radius.circular(size.width / 20),
              topRight: Radius.circular(size.width / 20),
            ),
          ),
          onPressed: () {
            Navigator.of(context).push(
              PageTransition(
                duration: const Duration(milliseconds: 400),
                child: const SearchContactsScreen(),
                type: PageTransitionType.rightToLeftWithFade,
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
