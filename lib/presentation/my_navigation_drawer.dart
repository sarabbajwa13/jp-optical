import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jp_optical/colors/app_color.dart';

class MyNavigationdrawer extends StatefulWidget {
  final String selectedTab;
  final ValueChanged<String> onClickCallBack;
  const MyNavigationdrawer({super.key, required this.onClickCallBack, required this.selectedTab});

  @override
  State<MyNavigationdrawer> createState() => _NavigationdrawerState();
}

class _NavigationdrawerState extends State<MyNavigationdrawer> {
 

  @override
  Widget build(BuildContext context) {
     final List<Map<String, dynamic>> _navigationItems = [
    {
      'title': "Home",
      'callback': 'Home',
      'fontWeight': widget.selectedTab == "Home" ? FontWeight.bold : null,
      'color': widget.selectedTab == "Home" ? AppColors.cGreenColor :  Colors.black
    },
    {
      'title': "Men's Opticals",
      'callback': 'Men Optical',
      'fontWeight': widget.selectedTab == "Men Optical" ? FontWeight.bold : null,
      'color': widget.selectedTab == "Men Optical" ? AppColors.cGreenColor :  Colors.black
    },
    {
      'title': "Women's Opticals",
      'callback': 'Women Optical',
      'fontWeight': widget.selectedTab == "Women Optical" ? FontWeight.bold : null,
      'color': widget.selectedTab == "Women Optical" ? AppColors.cGreenColor :  Colors.black
    },
    {
      'title': "Men's cloths",
      'callback': 'Men cloths',
      'fontWeight': widget.selectedTab == "Men cloths" ? FontWeight.bold : null,
      'color': widget.selectedTab == "Men cloths" ? AppColors.cGreenColor :  Colors.black
    },
    {
      'title': "Bags - women, men",
      'callback': 'Bags - women, men',
      'fontWeight': widget.selectedTab == "Bag" ? FontWeight.bold : null,
      'color': widget.selectedTab == "Bag" ? AppColors.cGreenColor :  Colors.black
    },
    {
      'title': "Perfumes",
      'callback': 'Perfumes',
      'fontWeight': widget.selectedTab == "Perfumes" ? FontWeight.bold : null,
      'color': widget.selectedTab == "Perfumes" ? AppColors.cGreenColor :  Colors.black
    },
    {
      'title': "Watches - women, men",
      'callback': 'Watches - women, men',
      'fontWeight': widget.selectedTab == "Watch" ? FontWeight.bold : null,
      'color': widget.selectedTab == "Watch" ? AppColors.cGreenColor :  Colors.black
    },
    {
      'title': "Belts",
      'callback': 'Belt',
      'fontWeight': widget.selectedTab == "Belt" ? FontWeight.bold : null,
      'color': widget.selectedTab == "Belt" ? AppColors.cGreenColor :  Colors.black
    },
    {
      'title': "Shoes",
      'callback': 'Shoe',
      'fontWeight': widget.selectedTab == "Shoe" ? FontWeight.bold : null,
      'color': widget.selectedTab == "Shoe" ? AppColors.cGreenColor :  Colors.black
    },
    {
      'title': "Caps",
      'callback': 'Caps',
      'fontWeight': widget.selectedTab == "Caps" ? FontWeight.bold : null,
      'color': widget.selectedTab == "Caps" ? AppColors.cGreenColor :  Colors.black
    },
    {
      'title': "Wallets",
      'callback': 'Wallets',
      'fontWeight': widget.selectedTab == "Wallets" ? FontWeight.bold : null,
      'color': widget.selectedTab == "Wallets" ? AppColors.cGreenColor :  Colors.black
    },
    {
      'title': "Other Accessories",
      'callback': 'Other Accessories',
      'fontWeight': widget.selectedTab == "Other Accessories" ? FontWeight.bold : null,
      'color': widget.selectedTab == "Other Accessories" ? AppColors.cGreenColor :  Colors.black
    },
  ];
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
