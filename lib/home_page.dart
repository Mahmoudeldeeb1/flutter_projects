import 'package:flutter/material.dart';
import 'task_page.dart';
import 'database_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> tasks = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _refreshTasks();
  }

  Future<void> _refreshTasks() async {
    final data = await DatabaseHelper.instance.getTasks();
    setState(() {
      tasks = data;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Taskify',
          style: TextStyle(
            fontFamily: 'RobotoSlab',
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple, Colors.teal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Colors.deepPurple, Colors.teal],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    spreadRadius: 4,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add,
                size: 35,
                color: Colors.white,
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TaskPage(
                    onSave: (task, dueDate) async {
                      await DatabaseHelper.instance.insertTask({
                        'task': task,
                        'dueDate': dueDate.toString().split(' ')[0],
                      });
                      _refreshTasks();
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal, Colors.purpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _selectedIndex == 0
            ? tasks.isEmpty
                ? const Center(
                    child: Text(
                      'No tasks yet, add a new one!',
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'RobotoSlab',
                        color: Colors.white70,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                          borderRadius: BorderRadius.circular(15),
                          gradient: const LinearGradient(
                            colors: [Colors.white, Colors.blueAccent],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: ListTile(
                          leading: const Icon(
                            Icons.task,
                            color: Colors.deepPurple,
                            size: 35,
                          ),
                          title: Text(
                            tasks[index]['task'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontFamily: 'RobotoSlab',
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          subtitle: Text(
                            'Due: ${tasks[index]['dueDate']}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit,
                                    color: Colors.orange),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TaskPage(
                                        initialTask: tasks[index]['task'],
                                        initialDate: DateTime.parse(
                                            tasks[index]['dueDate']),
                                        onSave: (editedTask, editedDate) async {
                                          await DatabaseHelper.instance
                                              .updateTask({
                                            'id': tasks[index]['id'],
                                            'task': editedTask,
                                            'dueDate': editedDate
                                                .toString()
                                                .split(' ')[0],
                                          });
                                          _refreshTasks();
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  await DatabaseHelper.instance
                                      .deleteTask(tasks[index]['id']);
                                  _refreshTasks();
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
            : const Center(
                child: Text(
                  'Settings (Coming Soon)',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list, color: Colors.white),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings, color: Colors.white),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,
        backgroundColor: Colors.black87,
        onTap: _onItemTapped,
      ),
    );
  }
}
