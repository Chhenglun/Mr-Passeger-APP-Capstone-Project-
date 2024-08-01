import 'package:flutter/material.dart';

class PremiumPlanPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Premium Plan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Upgrade to Premium',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Enjoy these features with a premium subscription:',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            FeatureList(),
            Spacer(),
            PurchaseButton(),
          ],
        ),
      ),
    );
  }
}

class FeatureList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ListTile(
          leading: Icon(Icons.check),
          title: Text('Ad-free experience'),
        ),
        ListTile(
          leading: Icon(Icons.check),
          title: Text('Exclusive content'),
        ),
        ListTile(
          leading: Icon(Icons.check),
          title: Text('Priority support'),
        ),
        // Add more features as needed
      ],
    );
  }
}

class PurchaseButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Trigger the purchase process
        // This is where you integrate with a payment gateway or in-app purchase
      },
      child: Text('Go Premium'),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        textStyle: TextStyle(fontSize: 18),
      ),
    );
  }
}
