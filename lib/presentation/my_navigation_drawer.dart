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
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
      
        children: [
          GestureDetector(onTap: ()=> {
            widget.onClickCallBack('Close')
          },child:
        Icon(Icons.close, color: Colors.black, size: 30,))
      ],),
        GestureDetector(onTap: ()=> {
            widget.onClickCallBack('Home')
          },child:SizedBox(child: Text('Home', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 20, color: AppColors.cGreenColor),),)),
      const SizedBox(height: 30,),
        GestureDetector(onTap: ()=> {
            widget.onClickCallBack('Men')
          },child:SizedBox(child: Text('Men', style: GoogleFonts.outfit(fontWeight: FontWeight.w400, fontSize: 20, color: Colors.black),),)),
            const SizedBox(height: 30,),
        GestureDetector(onTap: ()=> {
            widget.onClickCallBack('Women')
          },child:SizedBox(child: Text('Women', style: GoogleFonts.outfit(fontWeight: FontWeight.w400, fontSize: 20, color: Colors.black),),)),
            const SizedBox(height: 30,),
        GestureDetector(onTap: ()=> {
            widget.onClickCallBack('Cart')
          },child:SizedBox(child: Text('Cart', style: GoogleFonts.outfit(fontWeight: FontWeight.w400, fontSize: 20, color: Colors.black),),)),
    ],);
  }
}