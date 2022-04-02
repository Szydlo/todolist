import 'dart:io' show File;
import 'dart:convert' show json, jsonEncode;
import 'package:flutter/material.dart'
    show
        AlertDialog,
        AppBar,
        BuildContext,
        Card,
        Checkbox,
        Column,
        CrossAxisAlignment,
        Divider,
        Icon,
        IconButton,
        Icons,
        InputDecoration,
        Key,
        ListTile,
        ListTileTheme,
        ListView,
        MainAxisAlignment,
        MaterialApp,
        MaterialButton,
        Navigator,
        Row,
        Scaffold,
        State,
        StatefulWidget,
        StatelessWidget,
        Text,
        TextEditingController,
        TextField,
        ThemeData,
        ThemeMode,
        Widget,
        runApp,
        showDialog;

void main() => runApp(const TodoList());

class TodoList extends StatelessWidget {
  const TodoList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "TodoList",
      home: const TodoDemo(),
      theme: ThemeData(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
    );
  }
}

class TodoDemo extends StatefulWidget {
  const TodoDemo({Key? key}) : super(key: key);

  @override
  _TodoDemoState createState() => _TodoDemoState();
}

class Task {
  bool isDone = false;
  String title = "";
  String description = "";

  Task(this.isDone, this.title, this.description);

  Map toJson() => {
        'isDone': isDone,
        'title': title,
        'description': description,
      };
}

// ignore: must_be_immutable
class AddTaskAlert extends StatelessWidget {
  TextEditingController titleController = TextEditingController();
  TextEditingController despController = TextEditingController();
  _TodoDemoState state;
  AddTaskAlert(this.state, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Column(
      children: [
        const Text("Dodaj zadanie"),
        const Divider(),
        TextField(
          controller: titleController,
          decoration: const InputDecoration(hintText: "Tytul"),
        ),
        TextField(
          controller: despController,
          maxLines: 4,
          decoration: const InputDecoration(hintText: "Opis"),
        ),
        const Divider(),
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              MaterialButton(
                  child: const Text("Dodaj zadanie"),
                  onPressed: () {
                    // ignore: invalid_use_of_protected_member
                    state.setState(() {
                      state.listTasks.add(Task(
                          false, titleController.text, despController.text));
                      state.saveToJson();
                    });

                    Navigator.of(context, rootNavigator: true).pop();
                  }),
              MaterialButton(
                child: const Text("Zamknij"),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                },
              )
            ])
      ],
    ));
  }
}

class _TodoDemoState extends State<TodoDemo> {
  bool isChecked = false;
  List<Task> listTasks = [];

  _TodoDemoState() {
    final File file = File("data.json");

    String data = file.readAsStringSync();
    var convertedData = json.decode(data);

    for (var item in convertedData) {
      listTasks.add(Task(item["isDone"], item["title"], item["description"]));
    }
  }

  List<Widget> getList() {
    List<Widget> childs = [];

    for (var element in listTasks) {
      childs.add(Card(
        child: Column(children: [
          ListTile(
            leading: Checkbox(
              value: element.isDone,
              onChanged: (bool? value) {
                setState(() {
                  element.isDone = value!;
                });
              },
            ),
            title: Text(element.title),
            subtitle: Text(element.description),
            trailing: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  listTasks
                      .removeWhere((testEl) => testEl.title == element.title);
                  saveToJson();
                });
              },
            ),
          )
        ]),
      ));
    }

    return childs;
  }

  void saveToJson() {
    final File file = File("data.json");
    file.writeAsStringSync(jsonEncode(listTasks));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Todo Lista"),
        leading: IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext dialogContext) {
                  return AddTaskAlert(this);
                });
          },
        ),
      ),
      body: ListTileTheme(
          child: ListView(
        children: getList(),
      )),
    );
  }
}
