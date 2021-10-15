import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:ionicons/ionicons.dart';
import 'package:oknoapp/pages/brand/brand_details.dart';

class BrandPage extends StatefulWidget {
  static const routeName = '/brandspage';
  const BrandPage({Key? key}) : super(key: key);

  @override
  _BrandPageState createState() => _BrandPageState();
}

class _BrandPageState extends State<BrandPage> {
  final TextEditingController _textEditingController = TextEditingController();
  var _switchval = false;
  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!.uid;

    final _firebase =
        FirebaseFirestore.instance.collection("UsersData").doc(user).get();

    return FutureBuilder(
        future: _firebase,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          dynamic data = snapshot.data;
          var check = data!['BrandEnabled'];
          return Scaffold(
            appBar: AppBar(
              actions: [
                if (check)
                  CupertinoSwitch(
                    // title: const Text('View All'),
                    value: _switchval,
                    onChanged: (value) {
                      setState(() {
                        _switchval = value;
                      });
                      //Navigator.of(context).pop();
                    },
                  )
                // IconButton(
                //     onPressed: () {
                //       showDialog(
                //           context: context,
                //           builder: (context) {
                //             return StatefulBuilder(
                //                 builder: (context, setState) {
                //               return AlertDialog(
                //                 title: const Text('Apply Filters'),
                //                 content: Column(
                //                   mainAxisSize: MainAxisSize.min,
                //                   children: [
                //                     Row(
                //                       mainAxisAlignment:
                //                           MainAxisAlignment.spaceEvenly,
                //                       children: [
                //                         const Text(
                //                             "View records of one month: "),

                //                       ],
                //                     )
                //                   ],
                //                 ),
                //               );
                //             });
                //           });
                //     },
                //     icon: const Icon(Ionicons.filter_outline))
              ],
            ),
            body: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: (check)
                    ? BrandDetails(_switchval)
                    : Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text('You are not associated with any brand!!'),
                            // TextButton(
                            //     onPressed: () {
                            //       showDialog(
                            //           context: context,
                            //           builder: (context) {
                            //             return AlertDialog(
                            //               title: const Text('Join Brand'),
                            //               content: Column(
                            //                 mainAxisSize: MainAxisSize.min,
                            //                 children: [
                            //                   Container(
                            //                       decoration: BoxDecoration(
                            //                           border: Border.all(
                            //                               //color: Colors.white24
                            //                               )),
                            //                       child: Padding(
                            //                         padding:
                            //                             const EdgeInsets.all(
                            //                                 8.0),
                            //                         child: TextFormField(
                            //                           controller:
                            //                               _textEditingController,
                            //                           decoration:
                            //                               const InputDecoration(
                            //                             labelText: 'Brand Name',
                            //                             enabledBorder:
                            //                                 UnderlineInputBorder(
                            //                                     borderSide: BorderSide(
                            //                                         color: Colors
                            //                                             .grey)),
                            //                             focusedBorder:
                            //                                 UnderlineInputBorder(
                            //                                     borderSide: BorderSide(
                            //                                         color: Colors
                            //                                             .grey)),
                            //                           ),
                            //                         ),
                            //                       )),
                            //                   Row(
                            //                     mainAxisAlignment:
                            //                         MainAxisAlignment.end,
                            //                     children: [
                            //                       TextButton(
                            //                         onPressed: () =>
                            //                             Navigator.of(context)
                            //                                 .pop(),
                            //                         child: const Text('Cancel'),
                            //                       ),
                            //                       TextButton(
                            //                           child:
                            //                               const Text('Submit'),
                            //                           onPressed: () async {
                            //                             var snapsot =
                            //                                 await FirebaseFirestore
                            //                                     .instance
                            //                                     .collection(
                            //                                         'Requests')
                            //                                     .doc(user)
                            //                                     .get();
                            //                             if (snapsot.exists) {
                            //                               FirebaseFirestore
                            //                                   .instance
                            //                                   .collection(
                            //                                       'Requests')
                            //                                   .doc(user)
                            //                                   .update({
                            //                                 'Brand': FieldValue
                            //                                     .arrayUnion([
                            //                                   _textEditingController
                            //                                       .text
                            //                                       .trim()
                            //                                 ])
                            //                               }).whenComplete(() {
                            //                                 _textEditingController
                            //                                     .clear();
                            //                                 ScaffoldMessenger
                            //                                         .of(context)
                            //                                     .showSnackBar(
                            //                                         const SnackBar(
                            //                                   content: Text(
                            //                                       'Your request has been successfully submitted. Please wait for the approval'),
                            //                                   backgroundColor:
                            //                                       Colors
                            //                                           .greenAccent,
                            //                                 ));
                            //                               });
                            //                             } else {
                            //                               FirebaseFirestore
                            //                                   .instance
                            //                                   .collection(
                            //                                       'Requests')
                            //                                   .doc(user)
                            //                                   .set({
                            //                                 'Brand': FieldValue
                            //                                     .arrayUnion([
                            //                                   _textEditingController
                            //                                       .text
                            //                                       .trim()
                            //                                 ])
                            //                               }).whenComplete(() {
                            //                                 _textEditingController
                            //                                     .clear();
                            //                                 ScaffoldMessenger
                            //                                         .of(context)
                            //                                     .showSnackBar(
                            //                                         const SnackBar(
                            //                                   content: Text(
                            //                                       'Your request has been successfully submitted. Please wait for the approval'),
                            //                                   backgroundColor:
                            //                                       Colors
                            //                                           .greenAccent,
                            //                                 ));
                            //                               });
                            //                             }

                            //                             Navigator.of(context)
                            //                                 .pop();
                            //                           }),
                            //                     ],
                            //                   ),
                            //                 ],
                            //               ),
                            //             );
                            //           });
                            //     },
                            //     child: const Text('Join Brand'))
                          ],
                        ),
                      )),
          );
        });
  }
}
