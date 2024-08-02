import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DeveloperScreen extends StatelessWidget {
  final List<Member> members = [
    Member(name: 'Bou Taihor', role: 'Software Engineering', imageUrl: 'assets/me.jpg'),
    Member(name: 'Choub Chhenglun', role: 'Software Engineering', imageUrl: 'assets/chhenglun.jpg'),
    Member(name: 'Sot Sopheaktra', role: 'Software Engineering', imageUrl: 'assets/sopheaktra.jpg'),
    Member(name: 'Leang Menghang', role: 'Software Engineering', imageUrl: 'assets/menghang.jpg'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About Us', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Center(
        child: SizedBox(
          height: 450,
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
            ),
            itemCount: members.length,
            itemBuilder: (context, index) {
              return MemberCard(member: members[index]);
            },
          ),
        ),
      ),
    );
  }
}

class Member {
  final String name;
  final String role;
  final String imageUrl;

  Member({
    required this.name,
    required this.role,
    required this.imageUrl,
  });
}

class MemberCard extends StatefulWidget {
  final Member member;

  MemberCard({required this.member});

  @override
  State<MemberCard> createState() => _MemberCardState();
}

class _MemberCardState extends State<MemberCard> {
  bool clickedHeart = false;

  void _showMemberDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CircleAvatar(
                radius: 90,
                backgroundImage: AssetImage(widget.member.imageUrl),
              ),
              SizedBox(height: 20),
              Text(
                widget.member.name,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          actions: <Widget>[
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      clickedHeart = !clickedHeart;
                    });
                  },
                  icon: Icon(
                    clickedHeart ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                  ),
                  color: clickedHeart ? Colors.red : Colors.black,
                ),
                Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Close'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      child: InkWell(
        onTap: () {
          _showMemberDetails(context);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage(widget.member.imageUrl),
            ),
            SizedBox(height: 10),
            Text(
              widget.member.name,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 5),
            Text(widget.member.role, style: TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
