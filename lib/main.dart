import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:insights_app/insights_cubit.dart';
import 'package:insights_app/models.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (context) => InsightCubit(AllUsersInsights(userInsights: {})),
        child: const MyHomePage(
          title: 'Insights App',
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        appBar: AppBar(
          // TRY THIS: Try changing the color here to a specific color (to
          // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
          // change color while the other colors stay the same.
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        body: InsightsPage()
// This trailing comma makes auto-formatting nicer for build methods.
        );
  }
}

class InsightsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Insights App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: InsightsPage(),
    );
  }
}

class InsightsPage extends StatefulWidget {
  @override
  _InsightsPageState createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Insights App"),
      ),
      body: BlocBuilder<InsightCubit, AllUsersInsights>(
        builder: (context, state) {
          return ListView(
            padding: EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _controller,
                maxLines: 10,
                decoration: InputDecoration(
                  hintText: 'Paste your JSON here',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadJson,
                child: Text("Load JSON"),
              ),
              SizedBox(height: 16),
              if (state.userInsights.isNotEmpty) ...[
                for (var userId in state.userInsights.keys) ...[
                  Text("User: $userId"),
                  for (var insight in state.userInsights[userId]!.insights) ...[
                    ListTile(
                      title: Text(insight.title),
                      subtitle: Text(insight.insight),
                    ),
                    DropdownButton<int>(
                      value: insight.rating,
                      onChanged: (int? newValue) {
                        if (newValue != null) {
                          context
                              .read<InsightCubit>()
                              .setRating(userId, insight, newValue);
                        }
                      },
                      items: <int>[1, 2, 3, 4, 5]
                          .map<DropdownMenuItem<int>>((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text(value.toString()),
                        );
                      }).toList(),
                      hint: Text('Rate this insight'),
                    ),
                    TextField(
                      onChanged: (value) {
                        context
                            .read<InsightCubit>()
                            .setFeedback(userId, insight, value);
                      },
                      decoration: InputDecoration(
                        labelText: 'Feedback',
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Handle saving the rating and feedback
                      },
                      child: Text("Save"),
                    ),
                    Text("Source Functions:"),
                    for (var sourceFunction in insight.sourceFunctions) ...[
                      ListTile(
                        title: Text(sourceFunction.name),
                        // Add code here for Step 2
                      ),
                      DataTable(
                        columns: _generateColumns(sourceFunction.sourceData),
                        rows: _generateRows(sourceFunction.sourceData),
                      )
                    ],
                  ]
                ]
              ]
            ],
          );
        },
      ),
    );
  }

  List<DataColumn> _generateColumns(Map<String, dynamic> sourceData) {
    // Assuming that the first entry in the map has all the columns.
    var firstEntry = sourceData.entries.first.value as Map<String, dynamic>;
    return firstEntry.keys.map((key) => DataColumn(label: Text(key))).toList();
  }

  List<DataRow> _generateRows(Map<String, dynamic> sourceData) {
    return sourceData.entries.map((entry) {
      var rowValues = entry.value as Map<String, dynamic>;
      return DataRow(
          cells: rowValues.values
              .map((value) => DataCell(Text(value.toString())))
              .toList());
    }).toList();
  }

  void _loadJson() {
    final jsonStr = _controller.text;
    final jsonData = json.decode(jsonStr) as Map<String, dynamic>;

    final newInsights = AllUsersInsights.fromJson(jsonData);

    // Emit the new insights data to the InsightCubit
    context.read<InsightCubit>().emit(newInsights);
  }
}
