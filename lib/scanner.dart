import 'dart:developer';
import 'dart:io';

import 'package:project_kelompok_uas/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class Scanning extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ScanningState();
}

class _ScanningState extends State<Scanning> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  final Map<String, int> data = {};

  late String barcodeType;
  late String qrResult;

  //in order to get  hot reload to work we nee to pause the camera if the platform
  //is android, or resumme the camera if teh platform is IOS

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);
    final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
      primary: Colors.grey[600],
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        title: Text('Scan Barcode'),
        elevation: 0,
      ),
      body: Column(
        children: <Widget>[
          Expanded(flex: 3, child: _buildQRView(context)),
          Expanded(
            flex: 1,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  if (result != null)
                    Text('Data: ${result!.code}')
                  else
                    const Text('Data'),
                  if (result != null)

                    //naviigtor.push(context, MaterialPageRoute(builder:(context) => Result: result)),
                    ElevatedButton(
                        style: buttonStyle,
                        child: Text('Show Result'),
                        onPressed: (() async {
                          barcodeType = '${describeEnum(result!.format)}';
                          qrResult = '${result!.code}';

                          if (await qrResult.substring(0, 4) == 'tel:') {
                            await launch(qrResult);
                          } else if (await qrResult.substring(0, 4) == 'sms') {
                            await launch(qrResult);
                          } else if (await qrResult.substring(0, 4) ==
                              'email') {
                            await launch(qrResult);
                          } else {
                            await launch(qrResult);
                          }
                        }))
                  else
                    Text('Scan Your QRCode'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                          margin: EdgeInsets.all(8),
                          child: ElevatedButton(
                            onPressed: () async {
                              await controller?.toggleFlash();
                              setState(() {});
                            },
                            style: buttonStyle,
                            child: FutureBuilder(
                              future: controller?.getFlashStatus(),
                              builder: (context, snapshot) {
                                String stat = '${snapshot.data}';
                                if (stat == 'true') {
                                  return Icon(
                                    Icons.flash_on,
                                    size: 2,
                                  );
                                } else {
                                  return Icon(Icons.flash_off);
                                }
                              },
                            ),
                          )),
                      Container(
                        margin: EdgeInsets.all(8),
                        child: ElevatedButton(
                            onPressed: () async {
                              await controller?.flipCamera();
                              setState(() {});
                            },
                            style: buttonStyle,
                            child: FutureBuilder(
                              future: controller?.getCameraInfo(),
                              builder: (context, sanpshot) {
                                if (sanpshot.data != null) {
                                  return Icon(Icons.flip_camera_ios);
                                } else {
                                  return Text('loading');
                                }
                              },
                            )),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQRView(BuildContext context) {
    //for this example we check how width or tall the device is and change teh scanArea and overlay accordingly

    double scanArea = (MediaQuery.of(context).size.width < 600 ||
            MediaQuery.of(context).size.height < 600)
        ? 2500
        : 500.0;

    //to ensure the scanner view is propely sizes after rotation
    //we need to listen for flutter SizeChanged notification and update controller

    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 35,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        print(scanData.code);
        //SystemNavigator.pop();
      });
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
