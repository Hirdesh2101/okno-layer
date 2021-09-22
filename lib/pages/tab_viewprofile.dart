// import 'package:flutter/material.dart';

// class TabBarControllerWidget extends StatefulWidget {
//   const TabBarControllerWidget({Key? key}) : super(key: key);
//   @override
//   _TabBarControllerWidgetState createState() => _TabBarControllerWidgetState();
// }

// class _TabBarControllerWidgetState extends State<TabBarControllerWidget>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;

//   @override
//   void initState() {
//     _tabController = new TabController(length: 2, vsync: this);
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Container(
//             height: MediaQuery.of(context).size.height * 0.2,
//             child: Center(
//               child: Text(
//                 "Tabbar with out Appbar",
//                 style:
//                     TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//               ),
//             ),
//             color: Colors.blue,
//           ),
//           TabBar(
//             unselectedLabelColor: Colors.black,
//             labelColor: Colors.red,
//             tabs: [
//               Tab(
//                 text: '1st tab',
//               ),
//               Tab(
//                 text: '2 nd tab',
//               )
//             ],
//             controller: _tabController,
//             indicatorSize: TabBarIndicatorSize.tab,
//           ),
//           Expanded(
//             child: TabBarView(
//               children: [
//                 Container(child: Center(child: Text('people'))),
//                 Text('Person')
//               ],
//               controller: _tabController,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
