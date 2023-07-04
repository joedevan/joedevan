import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _showSplashScreen = true;

  @override
  void initState() {
    super.initState();
    _loadSplashScreen();
  }

  Future<void> _loadSplashScreen() async {
    await Future.delayed(const Duration(seconds: 5));

    setState(() {
      _showSplashScreen = false;
    });
  }

  void _navigateToHomeScreen() {
    setState(() {
      _showSplashScreen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _showSplashScreen
          ? SplashScreen(nextCallback: _navigateToHomeScreen)
          : const HomeScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  final VoidCallback nextCallback;

  const SplashScreen({Key? key, required this.nextCallback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/claudio-claudin.gif',
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: nextCallback,
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Folder> folders = [];
  TextEditingController folderNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? folderList = prefs.getStringList('folders');

    if (folderList != null) {
      setState(() {
        folders = folderList.map((folderStr) {
          Map<String, dynamic> folderMap = jsonDecode(folderStr);
          return Folder.fromJson(folderMap);
        }).toList();
      });
    }
  }

  Future<void> _saveFolders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> folderList =
        folders.map((folder) => jsonEncode(folder.toJson())).toList();
    await prefs.setStringList('folders', folderList);
  }

  Future<void> _createNewFolder() async {
    folderNameController.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create New Folder'),
          content: TextField(
            controller: folderNameController,
            decoration: const InputDecoration(
              hintText: 'Folder Name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                String folderName = folderNameController.text;

                if (folderName.isNotEmpty) {
                  setState(() {
                    Folder newFolder = Folder(
                      name: folderName,
                      notes: [],
                    );

                    folders.add(newFolder);
                    _saveFolders();
                  });

                  Navigator.pop(context);
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showFolderOptions(Folder folder) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Folder Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Name'),
                onTap: () {
                  Navigator.pop(context);
                  _editFolderName(folder);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete'),
                onTap: () {
                  Navigator.pop(context);
                  _deleteFolder(folder);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _editFolderName(Folder folder) async {
    TextEditingController folderNameController =
        TextEditingController(text: folder.name);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Folder Name'),
          content: TextField(
            controller: folderNameController,
            decoration: const InputDecoration(
              hintText: 'Folder Name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                String newFolderName = folderNameController.text;

                if (newFolderName.isNotEmpty) {
                  setState(() {
                    folder.name = newFolderName;
                    _saveFolders();
                  });
                }

                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteFolder(Folder folder) {
    setState(() {
      folders.remove(folder);
      _saveFolders();
    });
  }

  Future<void> _showNoteOptions(Note note) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Note Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  _editNoteContent(note);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete'),
                onTap: () {
                  Navigator.pop(context);
                  _deleteNote(note);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _editNoteContent(Note note) async {
    TextEditingController noteContentController =
        TextEditingController(text: note.content);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Note'),
          content: TextField(
            controller: noteContentController,
            decoration: const InputDecoration(
              hintText: 'Note Content',
            ),
            maxLines: null,
          ),
          actions: [
            TextButton(
              onPressed: () {
                String newNoteContent = noteContentController.text;

                setState(() {
                  note.content = newNoteContent;
                  _saveFolders();
                });

                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteNote(Note note) {
    setState(() {
      Folder parentFolder = folders.firstWhere(
        (folder) => folder.notes.contains(note),
      );
      parentFolder.notes.remove(note);
      _saveFolders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My App'),
      ),
      body: ListView.builder(
        itemCount: folders.length,
        itemBuilder: (BuildContext context, int index) {
          Folder folder = folders[index];
          String folderName = folder.name;
          List<Note> notes = folder.notes;

          return GestureDetector(
            onLongPress: () {
              _showFolderOptions(folder);
            },
            child: ExpansionTile(
              leading: const Icon(Icons.folder),
              title: Text(folderName),
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: notes.length,
                  itemBuilder: (BuildContext context, int index) {
                    Note note = notes[index];
                    String noteTitle = note.title;

                    return GestureDetector(
                      onLongPress: () {
                        _showNoteOptions(note);
                      },
                      child: ListTile(
                        leading: const Icon(Icons.note),
                        title: Text(noteTitle),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  NoteDetailScreen(note: note),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text('Add Note'),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        TextEditingController noteTitleController =
                            TextEditingController();
                        TextEditingController noteContentController =
                            TextEditingController();

                        return AlertDialog(
                          title: const Text('Create New Note'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: noteTitleController,
                                decoration: const InputDecoration(
                                  hintText: 'Note Title',
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: noteContentController,
                                decoration: const InputDecoration(
                                  hintText: 'Note Content',
                                ),
                                maxLines: null,
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                String noteTitle = noteTitleController.text;
                                String noteContent = noteContentController.text;

                                if (noteTitle.isNotEmpty) {
                                  setState(() {
                                    Note newNote = Note(
                                      title: noteTitle,
                                      content: noteContent,
                                    );

                                    notes.add(newNote);
                                    _saveFolders();
                                  });
                                }

                                Navigator.pop(context);
                              },
                              child: const Text('Create'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewFolder,
        child: const Icon(Icons.create_new_folder),
      ),
    );
  }
}

class Folder {
  String name;
  List<Note> notes;

  Folder({
    required this.name,
    required this.notes,
  });

  factory Folder.fromJson(Map<String, dynamic> json) {
    List<dynamic> noteList = json['notes'];
    List<Note> notes = noteList.map((note) => Note.fromJson(note)).toList();

    return Folder(
      name: json['name'],
      notes: notes,
    );
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> noteList =
        notes.map((note) => note.toJson()).toList();

    return {
      'name': name,
      'notes': noteList,
    };
  }
}

class NoteDetailScreen extends StatefulWidget {
  final Note note;

  const NoteDetailScreen({Key? key, required this.note}) : super(key: key);

  @override
  _NoteDetailScreenState createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  bool isEditMode = false;
  bool isLocked = false;
  String password = '';

  void _showPasswordInputDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Set Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  password = value;
                },
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
              ),
              ElevatedButton(
                child: const Text('Generate'),
                onPressed: () {
                  // Tambahkan logika untuk menghasilkan password otomatis di sini
                },
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              child: const Text('OK'),
              onPressed: () {
                setState(() {
                  isLocked = true;
                  isEditMode = false;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showPasswordConfirmDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String confirmPassword = '';
        return AlertDialog(
          title: const Text('Confirm Password'),
          content: TextField(
            onChanged: (value) {
              confirmPassword = value;
            },
            keyboardType: TextInputType.number,
            maxLength: 4,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Confirm Password',
            ),
          ),
          actions: [
            ElevatedButton(
              child: const Text('Confirm'),
              onPressed: () {
                if (confirmPassword == password) {
                  setState(() {
                    isLocked = true;
                    isEditMode = false;
                  });
                  Navigator.of(context).pop();
                } else {
                  // Tambahkan logika jika password tidak cocok
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          if (isEditMode || isLocked)
            IconButton(
              icon: const Icon(Icons.lock),
              onPressed: () {
                if (isEditMode) {
                  _showPasswordInputDialog();
                } else {
                  _showPasswordConfirmDialog();
                }
              },
            ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              // Tambahkan logika untuk aksi tombol tempat sampah di sini
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              setState(() {
                isEditMode = !isEditMode;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.star),
            onPressed: () {
              // Tambahkan logika untuk aksi tombol bintang di sini
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isEditMode)
              TextFormField(
                initialValue: widget.note.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                decoration: const InputDecoration(
                  labelText: 'Title',
                ),
                onChanged: (value) {
                  widget.note.title = value;
                },
              )
            else
              Text(
                widget.note.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 8),
            if (isEditMode)
              TextFormField(
                initialValue: widget.note.content,
                style: const TextStyle(fontSize: 18),
                decoration: const InputDecoration(
                  labelText: 'Content',
                ),
                onChanged: (value) {
                  widget.note.content = value;
                },
              )
            else
              Text(
                widget.note.content,
                style: const TextStyle(fontSize: 18),
              ),
          ],
        ),
      ),
    );
  }
}

class Note {
  String title;
  String content;

  Note({
    required this.title,
    required this.content,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      title: json['title'],
      content: json['content'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
    };
  }
}
