import 'package:flutter/material.dart';

class AdditionalCards extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const AdditionalCards({
    super.key, required this.icon, required this.label, required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon,size: 40,),
        SizedBox(height: 12,),
        Text(label),
        SizedBox(height: 12,),
        Text(value,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
      ],
    );
  }
}


/// This is my approach for additional cards


//
// @override
// Widget build(BuildContext context) {
//   return Padding(
//     padding: const EdgeInsets.all(18.0),
//     child: Column(
//       children: [
//         Icon(Icons.water_drop,size: 40,),
//         SizedBox(height: 12,),
//         Text('Humidity'),
//         SizedBox(height: 12,),
//         Text('94',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
//       ],
//     ),
//   );