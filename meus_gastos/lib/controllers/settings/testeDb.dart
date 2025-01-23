import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';

class Testedb extends StatefulWidget {
  @override
  _TestDb createState() => _TestDb();
}

class _TestDb extends State<Testedb> {
  TextEditingController textControler = TextEditingController();
  @override
  Widget build(BuildContext context) {
    
    // TODO: implement build
    return Container(
      decoration: BoxDecoration(color: AppColors.background1),
      child: Column(
        children: [
          CupertinoTextField(
            controller: textControler,
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.button,
                      border: Border.all(
                        width: 0
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text("Edit"),
                  ),
                ),
              ),
              
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.button,
                      border: Border.all(
                        width: 0
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    
                    child: Text("Add"),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.button,
                      border: Border.all(
                        width: 0
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text("Delete"),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
