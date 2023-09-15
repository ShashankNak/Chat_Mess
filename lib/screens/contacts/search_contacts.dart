import 'package:chat_mess/apis/api.dart';
import 'package:chat_mess/models/chat_user_model.dart';
import 'package:chat_mess/models/user_model.dart';
import 'package:chat_mess/screens/contacts/user_card_contacts.dart';
import 'package:chat_mess/widgets/consts.dart';
// import 'package:contacts_service/contacts_service.dart';
import 'package:fast_contacts/fast_contacts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class SearchContactsScreen extends StatefulWidget {
  const SearchContactsScreen({super.key});

  @override
  State<SearchContactsScreen> createState() => _SearchContactsScreenState();
}

class _SearchContactsScreenState extends State<SearchContactsScreen> {
  List<Contact> _contacts = [];
  bool isLoading = false;
  bool isContactLoading = false;
  String? _text;
  List<ChatUser> userDataList = [];

  @override
  void initState() {
    super.initState();
    loadContacts();
  }

  Future<void> loadContacts() async {
    try {
      bool isGranted = await Permission.contacts.status.isGranted;
      if (!isGranted) {
        isGranted = await Permission.contacts.request().isGranted;
      }
      if (isGranted) {
        isContactLoading = true;
        if (mounted) setState(() {});
        final sw = Stopwatch()..start();
        _contacts = await FastContacts.getAllContacts(
            fields: [ContactField.phoneNumbers]);
        sw.stop();
        _text = "${sw.elapsedMilliseconds}ms";
      }
    } on PlatformException {
      _text = 'error';
    } finally {
      isContactLoading = false;
    }
    if (!mounted) return;
    setState(() {});
  }

  Future<void> addUser(ChatUser user) async {
    setState(() {
      isLoading = true;
    });
    List<String> list = [];

    final value = await Api.firestore
        .collection('users')
        .doc(Api.auth.currentUser!.uid)
        .get();
    final value2 = await Api.firestore.collection('users').doc(user.uid).get();
    list = UserModel.fromMap(value.data()!).usersList;
    final list2 = UserModel.fromMap(value2.data()!).usersList;
    if (list.contains(user.uid)) {
      // ignore: use_build_context_synchronously
      showSnackBar(context, "User Already Added!");

      setState(() {
        isLoading = false;
      });
      return;
    }

    list.add(user.uid);
    list2.add(Api.auth.currentUser!.uid);

    await Api.firestore
        .collection('users')
        .doc(Api.auth.currentUser!.uid)
        .update({'usersList': list});
    await Api.firestore
        .collection('users')
        .doc(user.uid)
        .update({'usersList': list2});
    // ignore: use_build_context_synchronously
    showSnackBar(context, "User Added! You can Chat with ${user.name}");
    setState(() {
      isLoading = false;
    });
  }

  Widget centerWidget() {
    return Center(
      child: Text(
        "No users in contacts. Share the App",
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: Theme.of(context).colorScheme.onBackground,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          leading: IconButton(
            onPressed: () {
              if (!isLoading) {
                Navigator.of(context).pop();
              }
            },
            icon: const Icon(Icons.arrow_back),
          ),
          title: Text(
            "Select Contacts",
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontSize: size.height / 40,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
          ),
          actions: [
            if (isLoading || isContactLoading)
              Container(
                margin: EdgeInsets.only(right: size.width / 70),
                padding: EdgeInsets.all(size.width / 30),
                width: size.width / 8,
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            IconButton(
              icon: SizedBox(
                height: 24,
                width: 24,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: isContactLoading
                      ? const CircularProgressIndicator()
                      : const Icon(Icons.refresh),
                ),
              ),
              color: Theme.of(context).colorScheme.onPrimary,
              onPressed: loadContacts,
            ),
            Center(child: Text(_text ?? '', textAlign: TextAlign.center)),
          ],
        ),
        body: StreamBuilder(
          stream: Api.firestore.collection('userdata').snapshots(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
              case ConnectionState.none:
                return const Center(
                  child: CircularProgressIndicator(),
                );
              case ConnectionState.active:
              case ConnectionState.done:
                userDataList = [];
                if (!snapshot.hasData ||
                    snapshot.data == null ||
                    snapshot.data!.docs.isEmpty ||
                    _contacts.isEmpty) {
                  isContactLoading = false;
                  return centerWidget();
                }
                final data = snapshot.data!.docs;
                final userList =
                    data.map((e) => ChatUser.fromMap(e.data())).toList();
                for (Contact contact in _contacts) {
                  for (ChatUser chatUser in userList) {
                    // if (contact.phones == null) {
                    //   continue;
                    // }
                    // String phone = convertNumber(
                    //     contact.phones![0].value.toString());
                    String phone =
                        convertNumber(contact.phones[0].number.toString());
                    if (chatUser.phoneNumber.contains(phone)) {
                      userDataList.add(chatUser);
                    }
                  }
                }

                if (userDataList.isEmpty) {
                  isContactLoading = false;
                  return centerWidget();
                }

                return ListView.builder(
                  padding: EdgeInsets.only(top: size.height / 50),
                  itemCount: userDataList.length,
                  itemBuilder: (context, index) {
                    return UserCardContacts(
                        user: userDataList[index],
                        addUser: isLoading ? (user) {} : addUser);
                  },
                );
            }
          },
        ),
      ),
    );
  }
}
