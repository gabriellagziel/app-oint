import 'dart:js_interop';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:logging/logging.dart';

final _logger = Logger('WebUtils');

@JS('window.google')
external dynamic get google;

@JS('document')
external Document get document;

@JS()
@staticInterop
class Document {
  external Element createElement(String tagName);
  external BodyElement? get body;
  external HeadElement? get head;
}

@JS()
@staticInterop
class Element {
  external void setAttribute(String name, String value);
}

@JS()
@staticInterop
class BodyElement extends Element {
  external void appendChild(Element element);
}

@JS()
@staticInterop
class HeadElement extends Element {
  external void appendChild(Element element);
}

void registerGoogleSignInButtonViewFactory() {
  if (!kIsWeb) return;

  try {
    // Create the Google Sign-In button container
    final button = document.createElement('div');
    button.setAttribute('id', 'g_id_signin');
    button.setAttribute('data-type', 'standard');
    button.setAttribute('data-size', 'large');
    button.setAttribute('data-theme', 'outline');
    button.setAttribute('data-text', 'signin_with');
    button.setAttribute('data-shape', 'rectangular');
    button.setAttribute('data-logo_alignment', 'left');
    button.setAttribute('data-width', '300');
    button.setAttribute('style', 'width: 100%; height: 100%;');

    // Add the button to the document
    document.body?.appendChild(button);
    _logger.info('Successfully registered Google Sign-In button');
  } catch (e) {
    _logger.severe('Error registering Google Sign-In button: $e');
    rethrow;
  }
}

void setupGoogleSignInInterop(Function(dynamic) onCredential) {
  if (!kIsWeb) return;

  try {
    // Add the Google Identity Services script
    final script = document.createElement('script');
    script.setAttribute('src', 'https://accounts.google.com/gsi/client');
    script.setAttribute('async', '');
    script.setAttribute('defer', '');
    document.head?.appendChild(script);

    // Initialize the Google Sign-In button
    google?.identity?.id?.initialize({
      'client_id':
          '370968098826-673idnfkdv8pi0lpg4ufpai22r9gvlf5.apps.googleusercontent.com',
      'callback': (response) {
        if (response.credential != null) {
          onCredential(response.credential);
        }
      },
    });
    _logger.info('Successfully set up Google Sign-In interop');
  } catch (e) {
    _logger.severe('Error setting up Google Sign-In interop: $e');
    rethrow;
  }
}
