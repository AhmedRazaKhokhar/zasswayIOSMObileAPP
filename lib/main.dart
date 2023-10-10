import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webview_pro/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:zassway/splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:zassway/firebase_options.dart';
import 'firebase_options.dart';
import 'package:wakelock/wakelock.dart';
import 'package:geolocator/geolocator.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
as bg;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
  );
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final context = SecurityContext.defaultContext;
  context.allowLegacyUnsafeRenegotiation = true;
  final httpClient = HttpClient(context: context);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: Splash());
  }
}

class webapp extends StatefulWidget {
  const webapp({super.key});

  @override
  State<webapp> createState() => _webappState();
}

class _webappState extends State<webapp> with WidgetsBindingObserver {
  late StreamSubscription subscription;
  var isDeviceConnected = true;
  bool isAlertSet = false;
  final GlobalKey<NavigatorState> _navigator = GlobalKey<NavigatorState>();
  late WebViewController controller;
  final Completer<WebViewController> _controller =
  Completer<WebViewController>();
  double progresss = 0;
  var isLoading = false;
  var whatsapp;
  var w;
  late String deviceToken;
  late Timer _locationAndLatitudeTimer;
  Position? _currentPosition;
  double latitude = 0.0;
  double longitude = 0.0;

  @override
  initState() {
    init();
    super.initState();
    final AudioCache player = AudioCache();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Handle the received message here
      if (message.notification != null) {
        // Display the notification or perform any other desired action
        final player = AudioCache();
        player.play('Notification.mp3');
        showDialogBox1(message.notification!.body);
      }
    });
    getConnectivity();
    Wakelock.enable();
    // final news=AudioCache();
    // news.play('Mitwa.mp3');
    // setMediaPlaybackRequiresUserGesture:false;
    WidgetsBinding.instance.addObserver(this);
    _locationAndLatitudeTimer =
        Timer.periodic(Duration(seconds: 10), (Timer timer) {
          print("Set Location");
          _updatenewone();
          // Fired whenever the plugin changes motion-state (stationary->moving and vice-versa)
          // bg.BackgroundGeolocation.onMotionChange((bg.Location location) {
          //   print('[motionchange] - $location');
          // });
          //
          // // Fired whenever the state of location-services changes.  Always fired at boot
          // bg.BackgroundGeolocation.onProviderChange((bg.ProviderChangeEvent event) {
          //   print('[providerchange] - $event');
          // });
          //   printLatLng();
          //   _updateLatitude();
          //   _updatenewone();
          //   // Call the function here
        });
  }
  init() async {
     deviceToken=await getDeviceToken();
    print("######### PRINT DEVICE TOKEN TO USE FOR PUSH NOTIFICATIONS#####");
    print(deviceToken);
    print("########");
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      // The app is in the foreground

      // Perform WebView-related actions here
      // For example, reload the WebView or execute JavaScript code
      if (controller != null) {
        // controller.reload(); // Uncomment to perform the WebView action
      }
    } else if (state == AppLifecycleState.inactive) {
      // The app is in an inactive state (e.g., phone call or overlay)
      print("App is in an inactive state");
    } else if (state == AppLifecycleState.paused) {
      // The app is in the background
      print("App is in the background");
    } else if (state == AppLifecycleState.detached) {
      // The app is detached (e.g., terminated)
      bg.BackgroundGeolocation.stop();
      print("App is detached");
    }
  }
  @override
  void dispose() {
    // subscription.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _locationAndLatitudeTimer.cancel();
    super.dispose();
  }


  Future<void> _printLatLng() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
      });
      print("Latitude: ${position.latitude}, Longitude: ${position.longitude}");
    } catch (e) {
      // Handle location error
      print("Error getting location: $e");
    }
  }

  Future<void> chkinternet() async {
    isDeviceConnected = await InternetConnectionChecker().hasConnection;
    print("device connection$isDeviceConnected");
    if (isDeviceConnected == true) {
      setState(() {
        print("device connected:$isDeviceConnected");
        isDeviceConnected = true;
      });
    } else {
      setState(() {
        print("device connected:$isDeviceConnected");
        isDeviceConnected = false;
        // hideloc=true;
        // hide=true;
      });
    }
  }

  Future<void> getConnectivity() async {
    chkinternet();

    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) async {
      isDeviceConnected = await InternetConnectionChecker().hasConnection;
      print("isDeviceConnected=$isDeviceConnected");
      print("isAlertSet=$isAlertSet");
      if (!isDeviceConnected && isAlertSet == false) {
        showDialogBox();
        setState(() {
          isAlertSet = true;
        });
      }
    });
    await Future<void>.delayed(const Duration(seconds: 3));
    await subscription.cancel();
  }

  showDialogBox() {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext) => CupertinoAlertDialog(
        title: const Text("No Connection"),
        content: const Text("Please Check your Internet Connection"),
        actions: <Widget>[
          TextButton(
              onPressed: () async {
                setState(() {
                  Navigator.pop(context, 'cancel');
                });
                setState(() async {
                  isAlertSet = false;
                  isDeviceConnected =
                  await InternetConnectionChecker().hasConnection;
                  if (!isDeviceConnected) {
                    showDialogBox();
                    setState(() {
                      isAlertSet = true;
                    });
                  }
                });
              },
              child: const Text("OK")),
        ],
      ),
    );
  }


  showDialogBox1(var a) async {
    setState(() {
      showCupertinoDialog(

        context: context,
        builder: (BuildContex) => CupertinoAlertDialog(

          title: const Text("Zasway Notification"),
          content: Text('$a'),
          actions: <Widget>[
            TextButton(
                onPressed: () async {
                  Navigator.pop(context, 'cancel');
                },
                child: const Text("OK")),
          ],
        ),
      );
    });
  }



  Launchwhatsapp() async{
    String evaluatephoneNO = await controller.runJavascriptReturningResult(
        "document.getElementById('PhoneNumberValue').innerHTML");
    String phno = evaluatephoneNO;
    String res=phno.replaceAll(RegExp(" "),"");
    phno=res;
    print(phno);
    // launchUrl(Uri.parse('https://wa.me/$phno?text=hi'));
    // var whatsappURl_android = "whatsapp://send?phone="+whatsapp+"&text=hello";
    var whatappURL_ios =  "https://wa.me/${Uri.parse(phno)}?text=${Uri.parse("hello")}";
    if(Platform.isIOS){
      print("open ios wts");
      // for iOS phone only
      if( await canLaunch(whatappURL_ios)){
        await launch(whatappURL_ios,forceSafariVC: false);
      }else{
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: new Text("whatsapp no installed")));
      }
    }
  }

  void clickwhatsapp() {
    // setState(() {
    print("getwtsicon");
    controller.runJavascriptReturningResult('''
                       document.getElementById("WAImageID").addEventListener("click", function() {
                        window.CHANNEL_NAME.postMessage('whatsapp');
                                  });
                                ''');
    // });

  }

  void _updateLatitude() {
    double currentLatitude = _currentPosition?.latitude ?? 0.0;
    double currentLongitude = _currentPosition?.longitude ?? 0.0;
    String javascriptCode = '''
    var latitudeElement = document.getElementById("FlutterSideLatitude");
    var longitudeElement = document.getElementById("FlutterSideLongitude");
    if (latitudeElement) {
      latitudeElement.textContent = "$currentLatitude";
    }
    if (longitudeElement) {
      longitudeElement.textContent = "$currentLongitude";
    }
  ''';

    controller.runJavascript(javascriptCode);
    print("ahmi");
    // print(currentLatitude);
    // print(currentLongitude);
  }

  Future<void> _updatenewone() async {
    print("api func call");
    // var nnllaat = await controller.runJavascriptReturningResult(
    //     "document.getElementById('FlutterSideLatitude').innerHTML");
    // var nnllong = await controller.runJavascriptReturningResult(
    //     "document.getElementById('FlutterSideLongitude').innerHTML");
    var bkid = await controller.runJavascriptReturningResult(
        "document.getElementById('BookingID').innerHTML");
    var drvid = await controller.runJavascriptReturningResult(
        "document.getElementById('DriverID').innerHTML");
    var bkstatid = await controller.runJavascriptReturningResult(
        "document.getElementById('BookingStatusID').innerHTML");
    print('ZA');
    double currentLatitude = latitude;
    double currentLongitude = longitude;
    String newlat = "";
    newlat = currentLatitude.toString();
    //newlat = newlat.replaceAll('"', ''); // Remove double quotes
    print(newlat);
    String newlong = currentLongitude.toString();
    //newlong = newlong.replaceAll('"', '');
    print(newlong);
    String Bokid = bkid.toString();
    Bokid = Bokid.replaceAll('"', '');
    BigInt bkingid = BigInt.parse(Bokid.toString());
    print(bkingid);
    String Drvrid = drvid.toString();
    Drvrid = Drvrid.replaceAll('"', '');
    BigInt DriverID = BigInt.parse(Drvrid.toString());
    print("DriverId");
    print(DriverID);
    String BkgStatID = bkstatid.toString();
    BkgStatID = BkgStatID.replaceAll('"', '');
    BigInt BookingStatusID = BigInt.parse(BkgStatID.toString());
    print("BookingStatusID");
    print(BookingStatusID);
    if (bkingid != null) {
      bg.BackgroundGeolocation.ready(bg.Config(
          desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
          distanceFilter: 10.0,
          stopOnTerminate: true,
          startOnBoot: false,
          debug: false,
          logLevel: bg.Config.LOG_LEVEL_VERBOSE))
          .then((bg.State state) {
        if (!state.enabled) {
          ////
          // 3.  Start the plugin.
          //
          bg.BackgroundGeolocation.start();
        }
      });
      var a = bg.BackgroundGeolocation.getCurrentPosition();
      print(a);
      print("Get Location");
      bg.BackgroundGeolocation.onLocation((bg.Location location) {
        print('[location] - $location');
        print(location.coords.latitude);
        print(location.coords.longitude);
        latitude = location.coords.latitude;
        longitude = location.coords.longitude;
      });
      if (newlat != null &&
          newlat != "null" &&
          newlat != "" &&
          newlat != "0.0" &&
          newlong != "0.0" &&
          newlong != null &&
          newlong != "null" &&
          newlong != "" &&
          DriverID != null &&
          BookingStatusID != null &&
          bkingid != null) {
        const String apiUrl =
            'https://api.zasway.com:8443/Booking/AddLiveLocationLog';
        Map<String, dynamic> requestData = {
          "driverId": DriverID.toString(),
          "bookingId": bkingid.toString(),
          "longitude": newlong.toString(),
          "latitude": newlat.toString(),
          "bookingStatusID": BookingStatusID.toString(),
        };
        print("before---");
        var response = await http.post(
          Uri.parse(apiUrl),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(requestData),
        );
        if (response.statusCode == 200) {
          print("response---:${response.body}");
        } else {
          print("status code---${response.statusCode}");
        }
      } else {
        print("nothing");
      }
    }
  }


  void clickmapicon() {
    controller.runJavascriptReturningResult('''
                       document.getElementById("Navigation").addEventListener("click", function() {
                        window.CHANNEL_NAME.postMessage('Map');
                                  });
  
                                ''');
  }

  void clickhelpline() {
    controller.runJavascriptReturningResult('''
                       document.getElementById("Support").addEventListener("click", function() {
                        window.CHANNEL_NAME.postMessage('Helpline');

                                  });
  
                                ''');
  }

  void openMaps() async {
    print("111");
    var evaluatelocation = await controller.runJavascriptReturningResult(
        "document.getElementById('AddressValue').innerHTML");
    print("111");
    String query=Uri.encodeComponent(evaluatelocation);
    String googleurl = 'comgooglemaps://?saddr=&daddr=$query&directionsmode=driving';
    if (await canLaunch(googleurl)) {
      print("yes can launch");
      await launchUrl(Uri.parse(googleurl),mode: LaunchMode.externalApplication);
      print("launched");
    }
    else{
      print("cannot launch");
      showDialogBox1("Google Maps Not Installed");
    }
  }

  Future<void> openDialer() async {
    Uri phoneno = Uri.parse('tel:+442039970092');
    if (await launchUrl(phoneno)) {
      print("Dailer is opened");
    } else {
      print("Dailer is not opened");
    }
  }

  void isLoadingFalse(){
    setState(() {
      isLoading=false;
    });
  }

   CallApi() async {
  // GetDeviceType();
  print("url is start");
  // var uurl= await controller.currentUrl();
  // debugPrint("Current URL: $uurl");
  // var url="https://www.google.com?281717";
  var Geturl= await controller.currentUrl();
  print("currentul"+Geturl!);
  String userID;
  userID=Geturl.split("uid=").last;
  print("userID---:$userID");
  const String apiUrl = 'https://api.zasway.com:8443/UserLogin/UpdatUserDeviceToken';
  Map<String, dynamic> requestData = {
    "id": userID,
    "deviceToken": deviceToken,
    "deviceType": 2
  };
  print("before---");
  var response = await http.post(Uri.parse(apiUrl),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(requestData),
  );
  if(response.statusCode==200)
  {
    print("Token added");
    print("response---:${response.body}");
  }
  else
  {
    print("status code---${response.statusCode}");
  }
}



  Widget build(BuildContext context) {
    return MaterialApp(
      color: Color(0xff28C76F),
      navigatorKey: _navigator,
      debugShowCheckedModeBanner: false,
      home: WillPopScope(
        onWillPop: () async {
          if (await controller.canGoBack()) {
            controller.goBack();
            print("aaaaaa-------");
            return false;
          } else {
            return true;
          }
        },
        child: Scaffold(
            appBar: null,
          // floatingActionButton: new FloatingActionButton(
          //
          //     onPressed: (){
          //     }
          // ),
            body: SafeArea(
              bottom: true,
              top: true,
              left: true,
              right: true,
              // child: Expanded(
              child: Stack(
                children: <Widget>[
                  isDeviceConnected
                      ? WebView(
                    initialUrl: 'https://app.zasway.com',
                    gestureNavigationEnabled: true,
                    // initialUrl: 'https://www.facebook.com/',
                    javascriptMode: JavascriptMode.unrestricted,
                    onPageFinished: (String url) async {
                      isLoadingFalse();
                      setState(() async {
                        // isLoading = false;
                        if (_controller.isCompleted) {
                          print("finished status $isLoading");
                          print("con strt");
                          // setState(() async {
                          await Future.delayed(
                              const Duration(milliseconds: 4400));
                          clickmapicon();
                          clickhelpline();
                          clickwhatsapp();
                          print("finished...");
                          print("alert11");
                          // });
                        }
                      print('Page finished loading: $url');
                      });
                      },
                    onPageStarted: (String url) {

                      setState(() {
                        isLoading = true;
                      });
                        print("starting status $isLoading");
                      print('Page started loading: $url');

                      },
                    onWebViewCreated:
                        (WebViewController webViewController) async {
                      controller = webViewController;
                      _controller.isCompleted;
                      _controller.complete(webViewController);
                      // controller= await _controller.future;
                      print("started111");
                      print(_controller.isCompleted);
                    },
                    onProgress: (progress) async {
                      // if (_controller.isCompleted) {
                      //   print("onprogress:getwtsicon");
                      //   getwtsicon();
                      // }
                    },
                    javascriptChannels: Set.from([
                      JavascriptChannel(
                        name: 'CHANNEL_NAME',
                        onMessageReceived:
                            (JavascriptMessage message) async {
                          print(message.message);
                          w = message.message;
                          print("phoneno$w");
                          if (message.message == "whatsapp") {
                            // _launchWhatsapp();
                            Launchwhatsapp();
                          }
                          if (message.message == "Map") {
                            openMaps();
                          }
                          if (message.message == "Helpline") {
                            openDialer();
                          }
                          // Here you can take message.message and use
                          // your string from webview
                        },
                      )
                    ]),
                    navigationDelegate: (NavigationRequest request) async {
                      print("navigation called");
                      if (request.url.contains('='))
                      { // Check if the URL contains a specific keyword
                        print("yes url contains ?");

                        await CallApi(); // Call the function when the keyword is found
                      }
                      else{
                        print("no url found");
                      }
                      print('allowing navigation to $request');
                      return NavigationDecision.navigate;
                    },
                    geolocationEnabled: true,
                    initialMediaPlaybackPolicy:
                    AutoMediaPlaybackPolicy.always_allow,
                    allowsInlineMediaPlayback: false,
                    // debuggingEnabled: true,
                  )
                      : Container(
                    child: Column(
                      children: [
                        SizedBox(height: 300),
                        const Center(
                          child: Text(
                            "Check your internet Connection",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 22),
                          ),
                        ),
                        ElevatedButton(
                          // textColor: Colors.white,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xff28C76F),
                          ),
                          onPressed: () async {
                            setState(() {
                              showDialogBox();
                            });
                          },
                          child: Text("Reload"),
                          // shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
                        ),
                      ],
                    ),
                  ),
                  if(isLoading)
                      Center(
                    child: Container(
                      // width: 200.0,
                      // height: 300.0,
                      color: Colors.grey.shade100,
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.green),
                        ),
                      ),
                    ),
                  )
                      // : SizedBox.shrink(),
                ],
              ),
            )),
      ),
    );

  }
  Future getDeviceToken() async {
    print("devicetokencall");
    FirebaseMessaging.instance.requestPermission();
    print("testing firebase");
    FirebaseMessaging _firebaseMessage = FirebaseMessaging.instance;
    String? deviceToken =await _firebaseMessage.getToken();
    return (deviceToken ==null)? "" : deviceToken;
  }
}
