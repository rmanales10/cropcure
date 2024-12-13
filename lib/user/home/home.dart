import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tf_app/user/crops/crop.dart';
import 'package:tf_app/user/crops/crop_controller.dart';
import 'package:tf_app/user/profile/profile_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  final _cropController = Get.put(CropController());
  final _profileController = Get.put(ProfileController());

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true); // Repeat animation back and forth
    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.2, 0), // Move slightly to the right
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting Section with Animated Hand Wave
              Padding(
                padding: const EdgeInsets.only(
                  top: 50,
                  left: 30,
                ),
                child: Row(
                  children: [
                    Obx(() {
                      _profileController.fetchUserInfo();
                      final data = _profileController.userInfo;
                      try {
                        Uint8List imageBytes0 =
                            base64Decode(data['base64image']);
                        return ClipOval(
                          child: Image.memory(
                            imageBytes0,
                            height: 70,
                            width: 70,
                            gaplessPlayback: true,
                            fit: BoxFit.cover,
                          ),
                        );
                      } catch (e) {
                        return ClipOval(
                          child: Image.asset(
                            'assets/images/2.jpg',
                            height: 70,
                            width: 70,
                            gaplessPlayback: true,
                            fit: BoxFit.cover,
                          ),
                        );
                      }
                    }),
                    const SizedBox(width: 15),
                    Expanded(
                      // Wrap Column inside Expanded to prevent overflow
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Obx(
                                () => Text(
                                  _profileController.userInfo['fullname'] ??
                                      'Not set',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              SlideTransition(
                                position: _animation,
                                child: const Text(
                                  "👋",
                                  style: TextStyle(fontSize: 22),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            "Welcome to CropCure.",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // GridView Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Obx(() {
                  _cropController.fetchPlantDetails();
                  return GridView.builder(
                    physics:
                        const NeverScrollableScrollPhysics(), // Disable GridView scrolling
                    shrinkWrap: true, // Allow GridView to adjust its height
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Number of columns
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.9, // Adjust for desired card shape
                    ),
                    itemCount: _cropController.plantDetails.length,
                    itemBuilder: (context, index) {
                      final plant = _cropController.plantDetails[index];

                      return GestureDetector(
                        onTap: () => Get.to(() => PlantDiseasePage(
                              docId: plant['id'],
                              imageBytes: base64Decode(plant['image']),
                            )),
                        child: Card(
                          color: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: plant['image'] != null
                                        ? Image.memory(
                                            base64Decode(plant['image']),
                                            height: 100,
                                            fit: BoxFit.cover,
                                            gaplessPlayback: true,
                                          )
                                        : Image.asset(
                                            'assets/images/p3.png',
                                            height: 100,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  plant['name'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
