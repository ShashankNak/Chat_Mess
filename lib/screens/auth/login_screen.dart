import 'dart:async';

import 'package:chat_mess/provider/auth_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/consts.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formkey = GlobalKey<FormState>();
  final TextEditingController phoneController = TextEditingController();
  Country selectedCountry = Country(
      phoneCode: "91",
      countryCode: "IN",
      e164Sc: 0,
      geographic: true,
      level: 1,
      name: "India",
      example: "India",
      displayName: "India",
      displayNameNoCountryCode: "India",
      e164Key: "");
  bool isNumber = false;

  void _submit() {
    final isValid = _formkey.currentState!.validate();
    if (!isValid) {
      return;
    }
    FocusScope.of(context).unfocus();
    _formkey.currentState!.save();

    sendPhoneNumber();
  }

  void sendPhoneNumber() {
    ref.read(authProvider.notifier).signInWithPhone(
        context, phoneController.text.trim(), selectedCountry.phoneCode);
  }

  bool hasInternet = true;
  late StreamSubscription subscription;
  late StreamSubscription internetSubscription;
  void checkConnectionStatus() {
    subscription = Connectivity().onConnectivityChanged.listen((event) {
      final isInternet = event != ConnectivityResult.none;
      if (mounted) {
        setState(() {
          hasInternet = isInternet;
        });
      }
    });
    internetSubscription =
        InternetConnectionChecker().onStatusChange.listen((event) {
      final isInternet = event == InternetConnectionStatus.connected;
      if (mounted) {
        setState(() {
          hasInternet = isInternet;
        });
        if (!hasInternet) {
          showSnackBar(context, "No Internet");
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    checkConnectionStatus();
  }

  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
    internetSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final ap = ref.watch(authProvider);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildSticker(
                        image: image2,
                        size1: size.height / 20,
                        size2: size.height / 2.3),
                    Text(
                      "Chat Messenger",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            fontSize: size.height / 45,
                            color: Theme.of(context)
                                .colorScheme
                                .onBackground
                                .withOpacity(0.8),
                          ),
                    ),
                    SizedBox(
                      height: size.height / 90,
                    ),
                    Text(
                      "Login/Create Account",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontSize: size.height / 35,
                            color: Theme.of(context)
                                .colorScheme
                                .onBackground
                                .withOpacity(0.8),
                          ),
                    ),
                    SizedBox(
                      height: size.height / 30,
                    ),
                    Form(
                      key: _formkey,
                      child: TextFormField(
                        maxLength: 10,
                        onTap: checkConnectionStatus,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (!isNumber) {
                            return "Invalid Phone Number";
                          }
                          return null;
                        },
                        autocorrect: false,
                        controller: phoneController,
                        onChanged: (value) {
                          setState(() {
                            try {
                              isNumber = value.isNotEmpty &&
                                  (num.tryParse(value.trim()) != null) &&
                                  value.trim().length == 10;
                            } catch (e) {
                              isNumber = false;
                            }
                          });
                        },
                        cursorColor: Theme.of(context).colorScheme.onSecondary,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              fontSize: size.height / 45,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSecondary
                                  .withOpacity(0.8),
                            ),
                        decoration: InputDecoration(
                          prefixIcon: Container(
                            padding: const EdgeInsets.all(10),
                            height: size.height / 13,
                            width: size.width / 5,
                            child: GestureDetector(
                              onTap: () {
                                showCountryPicker(
                                  context: context,
                                  countryListTheme: CountryListThemeData(
                                    bottomSheetHeight: size.height / 2,
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .secondaryContainer,
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                          fontSize: size.height / 45,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                        ),
                                  ),
                                  onSelect: (value) {
                                    setState(() {
                                      selectedCountry = value;
                                    });
                                  },
                                );
                              },
                              child: Center(
                                child: Text(
                                  "${selectedCountry.countryCode} ${selectedCountry.phoneCode}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(
                                        fontWeight: FontWeight.w900,
                                        fontSize: size.height / 50,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSecondary,
                                      ),
                                ),
                              ),
                            ),
                          ),
                          hintText: "Enter Phone Number",
                          hintStyle: Theme.of(context)
                              .textTheme
                              .labelLarge!
                              .copyWith(
                                color:
                                    Theme.of(context).colorScheme.onSecondary,
                              ),
                          contentPadding: const EdgeInsets.all(20),
                          fillColor: Theme.of(context).colorScheme.secondary,
                          filled: true,
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(40),
                              borderSide: BorderSide.none),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(40)),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: size.height / 40,
                    ),
                    buildButton(
                      size: size,
                      color1: w2,
                      submit: ap.isLoading || !hasInternet ? () {} : _submit,
                      widget: ap.isLoading
                          ? const CircularProgressIndicator()
                          : const Text(
                              "Continue",
                              style: TextStyle(
                                color: b1,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                    ),
                  ],
                ),
                Positioned(
                  top: size.height / 15,
                  left: size.width / 20,
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
