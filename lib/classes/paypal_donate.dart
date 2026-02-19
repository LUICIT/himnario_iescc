import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class PaypalDonate {
  /// Works for Android/iOS/Web and in GitHub Actions builds.
  static const String paypalUrl = String.fromEnvironment(
    'PAYPAL_DONATE_URL',
    defaultValue: '',
  );

  static Future<void> openDonateLink() async {
    if (paypalUrl.trim().isEmpty) {
      throw Exception('PAYPAL_DONATE_URL no está configurada."');
    }

    final uri = Uri.parse(paypalUrl);

    final bool ok;

    if (kIsWeb) {
      ok = await launchUrl(uri, webOnlyWindowName: '_blank');
    } else {
      ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    }

    if (!ok) {
      throw Exception('No se pudo abrir el enlace de PayPal');
    }
  }
}
