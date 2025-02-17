import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Grocery List App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class GroceryItem {
  String _label;
  bool _isBought;
  String _objectID;

  GroceryItem({required String label, bool isBought = false})
      : _label = label,
        _isBought = isBought,
        _objectID = Uuid().v4(); // Generates a unique ID using UUID

  // Getter for label
  String get label => _label;

  // Setter for label
  set label(String newLabel) {
    _label = newLabel;
  }

  // Getter for isBought
  bool get isBought => _isBought;

  // Setter for isBought
  set isBought(bool status) {
    _isBought = status;
  }

  // Getter for objectID
  String get objectID => _objectID;
}

class MyAppState extends ChangeNotifier {
  final Map<String, GroceryItem> items = {};

  void addItem(String item) {
    GroceryItem newItem = GroceryItem(label: item);
    items[newItem._objectID] = newItem;
    notifyListeners();
  }

  void removeItem(String itemID) {
    items.remove(itemID);
    notifyListeners();
  }

  void toggleBought(String itemID) {
    if (items[itemID]?._isBought == true) {
      items[itemID]?._isBought = false;
    } else {
      items[itemID]?._isBought = true;
    }
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = ListPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= 600,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.list),
                    label: Text('List'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text('Favorites'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class ListPage extends StatefulWidget {
  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  void _addItem(BuildContext context) {
    var appState = context.read<MyAppState>();
    if (_controller.text.isNotEmpty) {
      appState.addItem(_controller.text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    // Filter the Map to only include items where isBought is false
    List<MapEntry<String, GroceryItem>> groceryList =
        appState.items.entries.where((entry) => !entry.value.isBought).toList();

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            key: _listKey,
            itemCount: groceryList.length,
            itemBuilder: (context, index) {
              final item = groceryList[index];
              return ListTile(
                title: Text(item.value._label),
                leading: Checkbox(
                  value: item.value._isBought,
                  onChanged: (_) {
                    appState.toggleBought(item.value._objectID);
                  },
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    appState.removeItem(item.value._objectID);
                  },
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: 'Enter an item',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _addItem(context),
                ),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () => _addItem(context),
                child: Icon(Icons.add),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    // Filter the Map to only include items where isBought is true
    List<MapEntry<String, GroceryItem>> groceryList =
        appState.items.entries.where((entry) => entry.value.isBought).toList();

    if (groceryList.isEmpty) {
      return Center(
        child: Text('No items.'),
      );
    }

    return ListView.builder(
      itemCount: groceryList.length,
      itemBuilder: (context, index) {
        final item = groceryList[index];
        return ListTile(
          title: Text(item.value._label),
          leading: Checkbox(
            value: item.value._isBought,
            onChanged: (_) {
              appState.toggleBought(item.value._objectID);
            },
          ),
          trailing: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              appState.removeItem(item.value._objectID);
            },
          ),
        );
      },
    );
  }
}
