import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To-Do App',
      color: Colors.redAccent,
      home: TodoList(),
    );
  }
}

class TodoList extends StatefulWidget {
  const TodoList({super.key});

  @override
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  List<String> _todoItems = []; // List of To-Do tasks

  @override
  void initState() {
    super.initState();
    _loadTodoItems(); // Load previously saved tasks when the app starts
  }

  // Load saved tasks from SharedPreferences
  void _loadTodoItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? todoString = prefs.getString('todo_list');
    if (todoString != null) {
      setState(() {
        _todoItems = List<String>.from(jsonDecode(todoString));
      });
    }
  }

  // Save the tasks to SharedPreferences
  void _saveTodoItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('todo_list', jsonEncode(_todoItems));
  }

  // Add a new task
  void _addTodoItem(String task) {
    if (task.isNotEmpty) {
      setState(() {
        _todoItems.add(task);
        _saveTodoItems(); // Save task list
      });
    }
  }

  // Remove a task
  void _removeTodoItem(int index) {
    setState(() {
      _todoItems.removeAt(index);
      _saveTodoItems(); // Save updated task list
    });
  }

  // Display the dialog for adding new tasks
  void _showAddTaskDialog() {
    TextEditingController taskController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Add New Task",
            style: TextStyle(color: Colors.amber, fontSize: 25),
          ),
          content: TextField(
            controller: taskController,
            autofocus: true,
            decoration: const InputDecoration(
                hintText: "Enter your task here",
                hintStyle: TextStyle(color: Colors.lightBlue, fontSize: 15),
                isCollapsed: true,
                labelStyle: TextStyle(color: Colors.lightBlue, fontSize: 15),
                isDense: true),
          ),
          actions: [
            TextButton(
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.amber, fontSize: 15),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                "Add",
                style: TextStyle(color: Colors.amber, fontSize: 15),
              ),
              onPressed: () {
                _addTodoItem(taskController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Build each To-Do item
  Widget _buildTodoItem(String taskText, int index) {
    return ListTile(
      title: Text(taskText),
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () {
          _removeTodoItem(index);
        },
      ),
    );
  }

  // Build the list of To-Do items
  Widget _buildTodoList() {
    return ListView.builder(
      itemCount: _todoItems.length,
      itemBuilder: (context, index) {
        return _buildTodoItem(_todoItems[index], index);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber,
      drawer: const Drawer(),
      appBar: AppBar(
        title: const Text(
          'TO-DO',
          style: TextStyle(
            fontSize: 25,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.amber,
        centerTitle: true,
        toolbarHeight: 80,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
        ],
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.amber, width: 1.5),
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: _buildTodoList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        backgroundColor: Colors.amber,
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
        elevation: 10,
      ),
    );
  }
}
