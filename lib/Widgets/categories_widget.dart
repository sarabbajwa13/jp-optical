import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jp_optical/models/item_model.dart';

class CategoriesWidget extends StatefulWidget {
  final Item categoryList;
  final ValueChanged<String> onClickCallBack;

  const CategoriesWidget({Key? key, required this.categoryList, required this.onClickCallBack})
      : super(key: key);

  @override
  State<CategoriesWidget> createState() => _CategoriesWidgetState();
}

class _CategoriesWidgetState extends State<CategoriesWidget> {
  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var tabletView = screenSize.width > 600;
    return Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          InkWell(
                onTap: () => widget.onClickCallBack(widget.categoryList.callback),
                child:
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.all(10),
            child: 
          Column(
            children: [
              ClipRRect(
                
                child:
                Image.asset(widget.categoryList.imageUrl,
                fit: BoxFit.fill,
                width: tabletView ? null : 50,
                height: tabletView ? null : 50,
              )),
               const SizedBox(height: 5,),
              Text(widget.categoryList.title, textAlign: TextAlign.center, style: GoogleFonts.outfit(color: Colors.black, fontSize: tabletView ? 15 : 12, ),)
            ],
          )))
        ]);
  }
}
