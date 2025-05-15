import 'dart:convert';
import 'package:filmu_nams/assets/decorations/background.dart';
import 'package:filmu_nams/assets/dialog/dialog.dart';
import 'package:filmu_nams/controllers/ticket_controller.dart';
import 'package:filmu_nams/providers/style.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerView extends StatefulWidget {
  const QRScannerView({super.key});

  @override
  State<QRScannerView> createState() => _QRScannerViewState();
}

class _QRScannerViewState extends State<QRScannerView> {
  final MobileScannerController _scannerController = MobileScannerController();
  final TicketController _ticketController = TicketController();
  bool _processing = false;
  bool _detected = false;
  String _lastScannedId = '';
  List<String> _scannedTickets = [];

  Style get style => Style.of(context);

  void _onQRCodeDetected(BarcodeCapture capture) async {
    if (_processing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? qrData = barcodes.first.rawValue;
    if (qrData == null) return;

    setState(() {
      _detected = _lastScannedId == qrData;
    });

    if (_lastScannedId == qrData) return;
    _lastScannedId = qrData;

    setState(() {
      _processing = true;
    });

    try {
      final Map<String, dynamic> ticketData = json.decode(qrData);
      final String ticketId = ticketData['ticketId'];

      if (_scannedTickets.contains(ticketId)) {
        StylizedDialog.dialog(
          Icons.info_outline,
          context,
          "Jau skenēts",
          "Šī biļete jau ir skenēta šajā sesijā.",
        );
        setState(() {
          _processing = false;
          _detected = false;
        });
        return;
      }

      final bool success = await _ticketController.updateTicketStatus(
          ticketId,
          TicketStatusEnum.used
      );

      if (success) {
        setState(() {
          _scannedTickets.add(ticketId);
        });

        StylizedDialog.dialog(
          Icons.check_circle_outline,
          context,
          "Biļete apstiprināta",
          "Biļetes statuss ir veiksmīgi atjaunināts uz 'izmantots'.\n\nFilma: ${ticketData['movieTitle']}\nVieta: ${ticketData['seat']}\nZāle: ${ticketData['hall']}",
        );
      } else {
        StylizedDialog.dialog(
          Icons.error_outline,
          context,
          "Kļūda",
          "Neizdevās atjaunināt biļetes statusu. Lūdzu, mēģiniet vēlreiz.",
        );
      }
    } catch (e) {
      debugPrint('Error processing QR code: $e');
      StylizedDialog.dialog(
        Icons.error_outline,
        context,
        "Kļūda",
        "Nederīgs QR kods vai neizdevās to apstrādāt. Lūdzu, mēģiniet vēlreiz.",
      );
    } finally {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _processing = false;
            _detected = false;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        iconTheme: IconThemeData(
          color: style.primary,
        ),
        backgroundColor: Colors.transparent,
        clipBehavior: Clip.none,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 5),
          decoration: style.cardDecoration,
          child: Stack(
            alignment: Alignment.centerLeft,
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: -35,
                child: Icon(
                  Icons.qr_code_scanner,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              Text(
                'Skenēt QR kodu',
                textAlign: TextAlign.center,
                style: style.displaySmall,
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: style.cardDecoration,
              child: IconButton(
                icon: Icon(
                  Icons.flip_camera_ios,
                  color: style.contrast,
                ),
                onPressed: () => _scannerController.switchCamera(),
              ),
            ),
          ),
        ],
      ),
      body: Background(
        child: SafeArea(
          child: Column(
            children: [
              Text(_processing
                  ? "Skenējam..."
                  : _detected
                    ? "Biļete jau bija noskenēta"
                    : "Gatavs skenēšanai",
              ),
              const SizedBox(height: 20),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        MobileScanner(
                          controller: _scannerController,
                          onDetect: _onQRCodeDetected,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: style.primary.withOpacity(0.5),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          width: 250,
                          height: 250,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Novietojiet biļetes QR kodu ierīces kamerai priekšā',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (_processing)
                        CircularProgressIndicator(
                          color: style.primary,
                        )
                      else
                        Text(
                          'Skenētas biļetes: ${_scannedTickets.length}',
                          style: GoogleFonts.poppins(
                            color: style.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}