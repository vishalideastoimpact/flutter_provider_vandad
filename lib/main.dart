import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (_) => BreadCrumbProvider(),
    child: MaterialApp(
      title: 'Flutter providr practice',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
      routes: {
        '/new': (context) => const NewBreadCrumbWidget(),
      },
    ),
  ));
}

class BreadCrumb {
  bool isActive;
  final String name;
  final String uuid;
  BreadCrumb({required this.isActive, required this.name})
      : uuid = const Uuid().v4();

  @override
  bool operator ==(covariant BreadCrumb other) => uuid == other.uuid;

  @override
  int get hashCode => uuid.hashCode;
  String get title => name + (isActive ? ' >' : '');
  void activate() {
    isActive = true;
  }
}

class BreadCrumbProvider extends ChangeNotifier {
  //_items list that can be change
  final List<BreadCrumb> _items = [];
  //we use outside of provider item list which is unmodifiable so outside of code it wont be modify
  UnmodifiableListView<BreadCrumb> get items => UnmodifiableListView(_items);

  void add(BreadCrumb breadCrumb) {
    print("Inside provider add");
    for (final item in _items) {
      //activate the previous items in list
      item.activate();
    }
    //add new breadCrumb in _items list
    _items.add(breadCrumb);
    //notify others about change
    notifyListeners();
  }

  void reset() {
    print("Inside provider reset");

    _items.clear();
    notifyListeners();
  }
}

class BreadCrumbsWidget extends StatelessWidget {
  final UnmodifiableListView<BreadCrumb> breadCrumbs;
  const BreadCrumbsWidget({Key? key, required this.breadCrumbs})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
        children: breadCrumbs.map((breadCrumb) {
      return Text(breadCrumb.title,
          style: TextStyle(
              color: breadCrumb.isActive ? Colors.lightGreen : Colors.black));
    }).toList());
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HomePage')),
      body: Center(
        child: Column(
          children: [
            //Consumer consume [BreadCrumbProvider] and rebuild the widget [BreadCrumbWidget]
            Consumer<BreadCrumbProvider>(builder: (context, value, child) {
              print("consumer recive data");
              return BreadCrumbsWidget(breadCrumbs: value.items);
            }),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/new');
                  print("navigator");
                },
                child: const Text(
                  "add new bead crumb",
                  style: TextStyle(fontSize: 20),
                )),
            TextButton(
                onPressed: () {
                  print("call reset");
                  //read a context to access provider and provide functionality to its decendants
                  context.read<BreadCrumbProvider>().reset();
                },
                child: const Text("reset", style: TextStyle(fontSize: 20))),
          ],
        ),
      ),
    );
  }
}

class NewBreadCrumbWidget extends StatefulWidget {
  const NewBreadCrumbWidget({Key? key}) : super(key: key);

  @override
  State<NewBreadCrumbWidget> createState() => _NewBreadCrumbWidgetState();
}

class _NewBreadCrumbWidgetState extends State<NewBreadCrumbWidget> {
  late final TextEditingController _controller;
  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add a new breadcrumb"),
      ),
      body: Column(
        children: [
          TextField(
            controller: _controller,
            decoration:
                const InputDecoration(hintText: "Enter a new Bread Crumb here"),
          ),
          TextButton(
              onPressed: () {
                print("add new breadcrumb");
                final text = _controller.text;
                //create a bread crumb
                final breadCrumb = BreadCrumb(isActive: false, name: text);

                //add a breadCrumb in list
                context.read<BreadCrumbProvider>().add(breadCrumb);

                //navigate to previous screen
                Navigator.pop(context);
              },
              child: const Text("Add")),
        ],
      ),
    );
  }
}
