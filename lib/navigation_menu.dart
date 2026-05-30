import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:warrrung_app/providers/location_provider.dart';
import 'package:warrrung_app/location_selection_page.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'menu_page.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());
    return Scaffold(
      bottomNavigationBar: Obx(
        () => NavigationBarTheme(
          data: NavigationBarThemeData(
            indicatorColor: const Color(0xFFFCE4EC),

            labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((
              states,
            ) {
              if (states.contains(WidgetState.selected)) {
                return const TextStyle(color: Color(0xFFC62828), fontSize: 11, fontWeight: FontWeight.w600);
              }

              return const TextStyle(color: Colors.grey, fontSize: 11);
            }),

            iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((
              states,
            ) {
              if (states.contains(WidgetState.selected)) {
                return const IconThemeData(color: Color(0xFFC62828));
              }

              return const IconThemeData(color: Colors.grey);
            }),
          ),

          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,

              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),

              border: Border(
                top: BorderSide(color: Colors.grey.shade100, width: 2),
              ),

              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 0),
                ),
              ],
            ),

            child: NavigationBar(
              backgroundColor: Colors.transparent,

              indicatorColor: const Color(0xFFFCE4EC),

              shadowColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,

              height: 80,
              elevation: 0,

              selectedIndex: controller.selectedIndex.value,

              onDestinationSelected: (index) {
                if (index == 1 && context.read<LocationProvider>().selectedOutlet == null) {
                  controller.selectedIndex.value = index;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LocationSelectionPage(),
                    ),
                  );
                } else {
                  controller.selectedIndex.value = index;
                }
              },

              destinations: const [
                NavigationDestination(
                  icon: Icon(Iconsax.home_2),
                  selectedIcon: Icon(Iconsax.home_2, color: Color(0xFFC62828)),
                  label: 'Beranda',
                ),

                NavigationDestination(
                  icon: Icon(Iconsax.category),
                  selectedIcon: Icon(Iconsax.category, color: Color(0xFFC62828)),
                  label: 'Menu',
                ),

                NavigationDestination(
                  icon: Icon(Iconsax.receipt_disscount),
                  selectedIcon: Icon(Iconsax.receipt_disscount, color: Color(0xFFC62828)),
                  label: 'Pesanan',
                ),

                NavigationDestination(
                  icon: Icon(Iconsax.user),
                  selectedIcon: Icon(Iconsax.user, color: Color(0xFFC62828)),
                  label: 'Saya',
                ),
              ],
            ),
          ),
        ),
      ),
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
    );
  }
}

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;

  final screens = [const HomePage(), const MenuPage(), Container(), const ProfilePage()];
}

// class NavigationMenu extends StatefulWidget {
//   const NavigationMenu({super.key});

//   @override
//   State<NavigationMenu> createState() => _NavigationMenuState();
// }
//
// class NavigationMenu extends StatefulWidget {
//  const super
//
// final screens = [const HomePage()];
//
// @override
// Widget build(BuildContext context) {
// return Scaffold(
// final controller = Get.put(NavigationController());
// body: IndexedStack(index: currentIndex, children: screens),
//
// bottomNavigationBar: NavigationBar(
//
// onDestinationSelected: (index) {
// setState(() {
// currentIndex = index;
// });
// },
// height: 80,
// elevation: 0,
// selectedIndex: controller.sele,
//
//
// destinations: const [
// NavigationDestination(icon: Icon(Iconsax.home), label: 'Home'),
//
// NavigationDestination(icon: Icon(Iconsax.shop), label: 'Shop'),
//
// NavigationDestination(icon: Icon(Iconsax.heart), label: 'Favorite'),
//
// NavigationDestination(icon: Icon(Iconsax.user), label: 'Profile'),
// ],
// ),
// );
// }
// }
//
