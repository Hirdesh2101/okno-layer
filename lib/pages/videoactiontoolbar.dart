import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../models/feedviewmodel.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class ActionToolBar extends StatefulWidget {
  final int index;
  // ignore: use_key_in_widget_constructors
  const ActionToolBar(this.index);

  @override
  _ActionToolBarState createState() => _ActionToolBarState();
}

class _ActionToolBarState extends State<ActionToolBar> {
  final locator = GetIt.instance;
  final feedViewModel = GetIt.instance<FeedViewModel>();
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: OutlinedButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color>(
                (states) => Colors.black.withOpacity(0.5))),
        child: const Text(
          'View Product',
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () {
          feedViewModel.pauseVideo(widget.index);
          sheet();
        },
      ),
    );
  }

  void sheet() {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        elevation: 10,
        builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Center(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 8, 0, 0),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.01,
                    width: MediaQuery.of(context).size.width * 0.10,
                    decoration: const BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                  ),
                ),
              ),
              const Center(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(8, 8, 8, 4),
                  child: Text(
                    'Products',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ),
              Expanded(
                child: AnimationLimiter(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (ctx, ind) {
                      return AnimationConfiguration.staggeredList(
                        position: ind,
                        duration: const Duration(milliseconds: 800),
                        child: SlideAnimation(
                          horizontalOffset:
                              MediaQuery.of(context).size.width / 2,
                          child: FadeInAnimation(
                            child: Column(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(9, 18, 9, 18),
                                  child: Image.network(
                                    feedViewModel.videoSource!
                                        .listVideos[widget.index].product1,
                                    height: MediaQuery.of(context).size.height *
                                        0.2,
                                    width: MediaQuery.of(context).size.height *
                                        0.2,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                Text(feedViewModel.videoSource!
                                    .listVideos[widget.index].p1name),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                    'Price - ₹${feedViewModel.videoSource!.listVideos[widget.index].price}')
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    itemCount: 1,
                  ),
                ),
              ),
              SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                        onPressed: () {}, child: const Text('Visit Store')),
                  )),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: Text(
                    feedViewModel.videoSource!.listVideos[widget.index].seller),
              ),
            ],
          );
        }).whenComplete(() => feedViewModel.playVideo(widget.index));
  }
}
