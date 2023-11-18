import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final keyApplicationId = 'qdZ2Xhrlum8JgDBXMlHGy01yNkmUZfkXDt3fc9X4';
  final keyClientKey = '4lI1uUf5OXPIJLV0u5hzcOkSzNIdD7AfFDdUGZEX';
  final keyParseServerUrl = 'https://parseapi.back4app.com';

  await Parse().initialize(keyApplicationId, keyParseServerUrl,
      clientKey: keyClientKey, autoSendSessionId: true);
  
  runApp(MaterialApp(
    home: NotesListPage(),
  ));
}

class NotesListPage extends StatefulWidget {
  @override
  NotesListPageState createState() => NotesListPageState();
}

class NotesListPageState extends State<NotesListPage> {
  
  List<ParseObject>? notes = [];

  @override
  void initState() {
    super.initState();
    fetchNotes();
  }

  Future<void> fetchNotes() async {
  final queryBuilder = QueryBuilder(ParseObject('Note'));
  final response = await queryBuilder.query();
  if (response.success && response.results != null) {
    notes = response.results as List<ParseObject>;
  } else {
    // Handle error
    print("No Notes");
  }
}

Future<void> _deleteNote(ParseObject note) async {
    final response = await note.delete();
    if (!response.success) {
      // Handle error
      print('Failed to delete note');
    } else {
      setState(() {
        notes!.remove(note);
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notes')),
      body: notes != null && notes!.isNotEmpty
          ? ListView.builder(
              itemCount: notes!.length,
              itemBuilder: (context, index) {
                final note = notes![index];
                return ListTile(
                  title: Text(note.get('title') ?? ''),
                  subtitle: Text(note.get('updatedAt')?.toString() ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteNote(note),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NoteDetailsPage(note),
                            ),
                          );
                        },
                        child: Text('Read More'),
                      ),
                    ],
                  ),
                );
              },
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditNotePage(),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class NoteDetailsPage extends StatelessWidget {
  final ParseObject note;

  NoteDetailsPage(this.note);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Note Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditNotePage(note: note),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note.get('title') ?? '',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  note.get('content') ?? '',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddEditNotePage extends StatefulWidget {
  final ParseObject? note;

  AddEditNotePage({this.note});

  @override
  _AddEditNotePageState createState() => _AddEditNotePageState();
}

class _AddEditNotePageState extends State<AddEditNotePage> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.get('title') ?? '');
    _contentController = TextEditingController(text: widget.note?.get('content') ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.note == null ? 'Add Note' : 'Edit Note')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Note Title'),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _contentController,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(labelText: 'Note Content'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (widget.note == null) {
                  // Creating a new note
                  _createNewNote();
                } else {
                  // Updating an existing note
                  _updateExistingNote();
                }
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createNewNote() async {
    final newNote = ParseObject('Note')
      ..set<String>('title', _titleController.text)
      ..set<String>('content', _contentController.text);
    final response = await newNote.save();
    if (!response.success) {
      // Handle error
      print('Failed to create new note');
    } else {
      Navigator.pop(context); // Go back to NotesListPage after saving
    }
  }

  Future<void> _updateExistingNote() async {
    if (widget.note != null) {
      widget.note!.set<String>('title', _titleController.text);
      widget.note!.set<String>('content', _contentController.text);
      final response = await widget.note!.save();
      if (!response.success) {
        // Handle error
        print('Failed to update note');
      } else {
        Navigator.pop(context); // Go back to NotesListPage after saving
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}

