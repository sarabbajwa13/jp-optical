import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jp_optical/colors/app_color.dart';

class MyNavigationdrawer extends StatefulWidget {
  final ValueChanged<String> onClickCallBack;
  const MyNavigationdrawer({super.key, required this.onClickCallBack});

  @override
  State<MyNavigationdrawer> createState() => _NavigationdrawerState();
}

class _NavigationdrawerState extends State<MyNavigationdrawer> {
  final List<Map<String, dynamic>> _navigationItems = [
    {
      'title': "Men's Opticals",
      'callback': 'Men Optical',
      'fontWeight': FontWeight.w400,
      'color': Colors.black
    },
    {
      'title': "Women's Opticals",
      'callback': 'Women Optical',
      'fontWeight': FontWeight.w400,
      'color': Colors.black
    },
    {
      'title': "Men's cloths",
      'callback': 'Men cloths',
      'fontWeight': FontWeight.w400,
      'color': Colors.black
    },
    {
      'title': "Bags - women, men",
      'callback': 'Bags - women, men',
      'fontWeight': FontWeight.w400,
      'color': Colors.black
    },
    {
      'title': "Perfumes",
      'callback': 'Perfumes',
      'fontWeight': FontWeight.w400,
      'color': Colors.black
    },
    {
      'title': "Watches - women, men",
      'callback': 'Watches - women, men',
      'fontWeight': FontWeight.w400,
      'color': Colors.black
    },
    {
      'title': "Belts",
      'callback': 'Belt',
      'fontWeight': FontWeight.w400,
      'color': Colors.black
    },
    {
      'title': "Shoes",
      'callback': 'Shoe',
      'fontWeight': FontWeight.w400,
      'color': Colors.black
    },
    {
      'title': "Caps",
      'callback': 'Caps',
      'fontWeight': FontWeight.w400,
      'color': Colors.black
    },
    {
      'title': "Wallets",
      'callback': 'Wallets',
      'fontWeight': FontWeight.w400,
      'color': Colors.black
    },
    {
      'title': "Other Accessories",
      'callback': 'Other Accessories',
      'fontWeight': FontWeight.w400,
      'color': Colors.black
    },
  ];

  @override
Widget build(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
           InkWell(
              onTap: () => widget.onClickCallBack('Close'),
              child: const Icon(
                Icons.close,
                color: Colors.black,
                size: 30,
              ),
            ),
         
        ],
      ),
      const SizedBox(height: 20),
      Expanded(
        child: ListView.builder(
          itemCount: _navigationItems.length,
          itemBuilder: (context, index) {
            final item = _navigationItems[index];
            return InkWell(
              onTap: () => widget.onClickCallBack(item['callback']),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Center(
                      child: Text(
                        item['title'],
                        style: GoogleFonts.outfit(
                          fontWeight: item['fontWeight'],
                          fontSize: 18,
                          color: item['color'],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 0.5,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    ],
  );
}
}
