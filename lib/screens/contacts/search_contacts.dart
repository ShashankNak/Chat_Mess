import 'package:chat_mess/apis/api.dart';
import 'package:chat_mess/models/chat_user_model.dart';
import 'package:chat_mess/models/user_model.dart';
import 'package:chat_mess/screens/contacts/user_card_contacts.dart';
import 'package:chat_mess/widgets/consts.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class SearchContactsScreen extends StatefulWidget {
  const SearchContactsScreen({super.key});

  @override
  State<SearchContactsScreen> createState() => _SearchContactsScreenState();
}

class _SearchContactsScreenState extends State<SearchContactsScreen> {
  List<Contact> contacts = [];
  bool isLoading = true;
  List<ChatUser> userList = [];
  List<ChatUser> userDataList = [];
  @override
  void initState() {
    super.initState();
    getContactPermission();
  }

  void getContactPermission() async {
    if (await Permission.contacts.isGranted) {
      fetchContacts();
    } else {
      await Permission.contacts.request();
    }
  }

  void fetchContacts() async {
    await ContactsService.getContacts().then((value) {
      contacts = value;
    });

    setState(() {
      isLoading = false;
    });
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
    list = UserModel.fromMap(value.data()!).usersList;
    if (list.contains(user.uid)) {
      // ignore: use_build_context_synchronously
      showSnackBar(context, "User Already Added!");

      setState(() {
        isLoading = false;
      });
      return;
    }

    list.add(user.uid);

    await Api.firestore
        .collection('users')
        .doc(Api.auth.currentUser!.uid)
        .update({'usersList': list});
    // ignore: use_build_context_synchronously
    showSnackBar(context, "User Added! You can Chat with ${user.name}");
    setState(() {
      isLoading = false;
    });
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
            if (isLoading)
              Container(
                margin: EdgeInsets.only(right: size.width / 70),
                padding: EdgeInsets.all(size.width / 30),
                width: size.width / 8,
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              )
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
                if (snapshot.data == null) {
                  return Center(
                    child: Text(
                      "No users in contacts. Share the App",
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                    ),
                  );
                }
                final data = snapshot.data!.docs;
                userList = data.map((e) => ChatUser.fromMap(e.data())).toList();
                for (Contact contact in contacts) {
                  for (ChatUser chatUser in userList) {
                    String phone =
                        convertNumber(contact.phones![0].value.toString());
                    if (chatUser.phoneNumber.contains(phone)) {
                      userDataList.add(chatUser);
                    }
                  }
                }

                if (userDataList.isEmpty) {
                  return Center(
                    child: Text(
                      "No users in contacts. Share the App",
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                    ),
                  );
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
