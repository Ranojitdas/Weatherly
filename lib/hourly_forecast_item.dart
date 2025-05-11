import 'package:flutter/material.dart';

class HourlyForecastCards extends StatelessWidget {
  final String time;
  final IconData icon;
  final String temp;

  const HourlyForecastCards({
    super.key, required this.time, required this.temp, required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black54,
        elevation: 6,
        child:
        Container(
          width: 100,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(temp,style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),maxLines: 1,overflow: TextOverflow.ellipsis,),
              SizedBox(height: 12,),
              Icon(icon,size: 40,),
              SizedBox(height: 12,),
              Text(time,style: TextStyle(fontSize: 16),maxLines: 1,overflow: TextOverflow.ellipsis,),

            ],
          ),
        )
    );
  }
}
