import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:noteapp/services/firestoreservice.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // get the text that user has been typed
  final _notecontroller = TextEditingController();
  final items = List<String>.generate(10, (i) => 'Item ${i + 1}');
  final _firestoreservice = Firestoreservice();
  // dailog Box
  void openBox({String? docID}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(docID == null ? "Add a Note" : "Update Note",
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold)),
              const Divider(),
              TextField(
                controller: _notecontroller,
                decoration: const InputDecoration(
                    hintText: "Type the note text here...",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5)))),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
                style: const ButtonStyle(
                    shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5)))),
                    backgroundColor: WidgetStatePropertyAll(
                        Color.fromRGBO(22, 138, 253, 1))),
                onPressed: () {
                  if (docID == null) {
                    // create note
                    _firestoreservice.addNote(_notecontroller.text);
                  } else {
                    _firestoreservice.updateNote(docID, _notecontroller.text);
                  }

                  // clear the textfield
                  _notecontroller.clear();

                  // dismiss the modal
                  Navigator.pop(context);
                },
                child: Text(
                  docID == null ? "Add" : "Update",
                  style: const TextStyle(color: Colors.white),
                ))
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Note App",
          style: TextStyle(
            fontSize: 25,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openBox(),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestoreservice.getNotes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            // change the returned data into list so we can access it in listview
            List notes = snapshot.data!.docs;

            return ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                // get each indivitual doc
                DocumentSnapshot document = notes[index];
                String docID = document.id;

                // get Note from Each document
                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                String note = data['note'];

                return Container(
                  margin: const EdgeInsets.all(10),
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(
                      230,
                      239,
                      236,
                      1,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        offset: Offset(1.0, 1.0), // Use finite values here
                        blurRadius:
                            3.0, // Optional: set blur radius for the shadow
                        color:
                            Colors.black, // Optional: set color for the shadow
                      )
                    ],
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: ListTile(
                    title: Text(
                      note,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            onPressed: () => openBox(docID: docID),
                            icon: const Icon(Icons.update)),
                        IconButton(
                            onPressed: () =>
                                _firestoreservice.deleteNote(docID),
                            icon: const Icon(Icons.delete)),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text("There is no Data"));
          }
        },
      ),
    );
  }
}
