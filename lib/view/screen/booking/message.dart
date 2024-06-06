
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MessageScreen extends StatelessWidget {
  const MessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10,vertical: 40),
            child: Row(
              children: [
                InkWell(
                  onTap: (){Navigator.pop(context);},
                  child: Row(
                    children: [
                      IconButton(onPressed: (){
                        Navigator.pop(context);
                      }, icon: Icon(Icons.arrow_back_ios,color: Colors.black,)),
                      Text("ត្រឡប់ក្រោយ", style: TextStyle(color: Colors.black,fontSize: 16),),
                    ],
                  ),
                ),
                SizedBox(width: 50,),
                Text("Chat",style: TextStyle(color: Colors.black,fontSize: 20, fontWeight: FontWeight.bold),)
              ],
            ),
          ),
          Spacer(),
          _buildInput(),
        ],
      ),
    );
  }
  Widget _buildInput(){
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'សរសេរសាររបស់អ្នក',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.mic),
              onPressed: () {
                // Handle microphone button press
              },
            ),
            IconButton(
              icon: Icon(Icons.send),
              onPressed: () {
                // Handle send button press
              },
            ),
          ],
        ),
      );

  }
}
