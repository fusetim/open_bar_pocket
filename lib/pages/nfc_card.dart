import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';
import 'package:open_bar_pocket/utils/hex.dart';

/// Start a NFC session and try to retrieve the card number.
Future<String?> startSession({
  required BuildContext context,
}) async {
  if (!(await NfcManager.instance.isAvailable())) {
    if (!context.mounted) return null;
    showDialog(context: context, builder: (_) => _UnavailableDialog());
    return null;
  }

  if (!context.mounted) return null;
  
  if (Platform.isIOS) {
    showDialog(context: context, builder: (_) => _UnavailableAppleDialog());
    return null;
  }

  if (Platform.isAndroid) {
    return showDialog<String>(
      context: context,
      builder: (_) => const _AndroidSessionDialog(
        'Veuillez scanner votre carte NFC.',
      ),
    );
  }

  throw('unsupported platform: ${Platform.operatingSystem}'); 
}


class _UnavailableDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Erreur'),
      content: const Text('Votre appareil ne supporte pas le protocole NFC ou celui-ci est désactivé.'),
      actions: [
        TextButton(
          child: const Text('OK'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}

class _UnavailableAppleDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Erreur'),
      content: const Text('Votre appareil Apple ne supporte pas le protocole NFC-A. Veuillez utiliser un appareil Android.'),
      actions: [
        TextButton(
          child: const Text('OK'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}

class _AndroidSessionDialog extends StatefulWidget {
  const _AndroidSessionDialog(this.alertMessage);

  final String alertMessage;

  @override
  State<StatefulWidget> createState() => _AndroidSessionDialogState();
}

class _AndroidSessionDialogState extends State<_AndroidSessionDialog> {
  String? _alertMessage;

  String? _errorMessage;

  String? _result;

  @override
  void initState() {
    super.initState();
    NfcManager.instance.startSession(
      onDiscovered: (tag) async {
        try {
          _result = toHex(NfcA.from(tag)!.identifier);
          if (_result == null) return;
          await NfcManager.instance.stopSession();
          setState(() => _alertMessage = "Carte détectée: $_result");
        } catch (e) {
          await NfcManager.instance.stopSession().catchError((_) { /* no op */ });
          setState(() => _errorMessage = '$e');
        }
      },
    ).catchError((e) => setState(() => _errorMessage = '$e'));
  }

  @override
  void dispose() {
    NfcManager.instance.stopSession().catchError((_) { /* no op */ });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        _errorMessage?.isNotEmpty == true ? 'Erreur' :
        _alertMessage?.isNotEmpty == true ? 'Succès' :
        'Prêt à scanner',
      ),
      content: Text(
        _errorMessage?.isNotEmpty == true ? _errorMessage! :
        _alertMessage?.isNotEmpty == true ? _alertMessage! :
        widget.alertMessage,
      ),
      actions: [
        TextButton(
          child: Text(
            (_errorMessage?.isNotEmpty == true || _alertMessage?.isNotEmpty == true) ? 'OK' :
            'Annuler',
          ),
          onPressed: () => Navigator.pop(context, _result),
        ),
      ],
    );
  }
}
