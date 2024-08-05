import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:url_launcher/url_launcher.dart';

void redirectUri(String phoneNumber, String action, String itemsJson) async {
  const instagramUsername = 'rjeyes2000?igsh=MTVkajZ2OThydG5zaQ==';
  const facebookProfile = 'profile.php?id=61563036562291';
  const youtubeChannelId = 'username_or_page_id'; 
  const snapchatUsername = 'username_or_page_id';
  Uri url;
  switch (action) {
    case 'orderThroghWhatsApp':
      const thankYouNote =
          'Thank you for contacting us! We will get in touch with you soon.';
      List<dynamic> items = jsonDecode(itemsJson);

      String productDetails = items.map((item) {
        List<String> details = [];
        if (item['productId'] != null && item['productId'] != '') {
          details.add('Product ID: ${item['productId']}');
        }
        if (item['productTitle'] != null) {
          details.add('Product Name: ${item['productTitle']}');
        }
        if (item['quantity'] != null) {
          details.add('Quantity: ${item['quantity']}');
        } else {
          details.add('Quantity: 1');
        }

        if (item['productSize'] != null && item['productSize'] != '') {
          details.add('Size: ${item['productSize']}');
        }
        if (item['selectedSize'] != null) {
          details.add('Size: ${item['selectedSize']}');
        }
        if (item['productImage'] != null) {
          details.add(item['productImage']);
        }

        return details.join('\n');
      }).join('\n\n');

      final fullMessage = '$thankYouNote\n\n$productDetails';

      url = Uri.parse(
          'https://wa.me/${formatPhoneNumber(phoneNumber)}?text=${Uri.encodeComponent(fullMessage)}');
      break;
    case 'normalWhatsAppContact':
      const thankYouNote =
          'Thank you for contacting us! Please let us know how can we help you!';
      url = Uri.parse(
          'https://wa.me/${formatPhoneNumber(phoneNumber)}?text=${Uri.encodeComponent(thankYouNote)}');
      break;
    case 'instagram':
      url = Uri.parse('https://instagram.com/$instagramUsername');
      break;
    case 'facebook':
      url = Uri.parse('https://www.facebook.com/$facebookProfile');
      break;
    case 'youtube':
      url = Uri.parse('https://www.youtube.com/channel/$youtubeChannelId');
      break;
    case 'snapchat':
       url = Uri.parse('https://www.snapchat.com/add/$snapchatUsername');
      break;
    default:
      const thankYouNote =
          'Thank you for contacting us! Please let us know how can we help you!';
      url = Uri.parse(
          'https://wa.me/${formatPhoneNumber(phoneNumber)}?text=${Uri.encodeComponent(thankYouNote)}');
      break;
  }

  try {
    // Check if the URL can be launched
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
      var cartBox = await Hive.openBox('cartBox');
      await cartBox.clear();
    } else {
      // Handle the case where the URL cannot be launched
      debugPrint('Could not launch the URL: $url');
    }
  } catch (e) {
    // Handle any errors that occur during URL launch
    debugPrint('Error launching URL: $e');
  }
}

String formatPhoneNumber(String phoneNumber) {
  final formattedNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
  return formattedNumber;
}
