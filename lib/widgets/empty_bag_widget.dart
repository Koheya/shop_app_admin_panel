import 'package:admin_app/widgets/sub_title_text.dart';
import 'package:admin_app/widgets/title_text.dart';

import 'package:flutter/material.dart';

class EmptyBagWidget extends StatelessWidget {
  const EmptyBagWidget({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subTitle,
    required this.buttonText,
  });

  final String imagePath, title, subTitle, buttonText;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Image(
              image: AssetImage(imagePath),
              height: size.height * 0.3,
              width: double.infinity,
            ),
            const SizedBox(height: 20),
            const TitleTextWidget(
              label: "Whoops!",
              fontSize: 30,
              color: Colors.red,
            ),
            const SizedBox(height: 20),
            SubTitleTextWidget(
              label: title,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SubTitleTextWidget(
                label: subTitle,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
