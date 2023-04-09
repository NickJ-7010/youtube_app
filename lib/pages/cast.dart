import 'package:flutter/material.dart';

class CastModelContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1000,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 40, 40, 40),
        body: Column(
          children: [
            const SizedBox(
              height: 50,
              child: Text(
                'Connect to a device:',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      'Device: ${index + 1}?',
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
