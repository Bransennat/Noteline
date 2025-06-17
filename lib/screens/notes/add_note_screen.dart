import 'package:flutter/material.dart';
import 'package:notesecure/providers/note_provider.dart';
import 'package:provider/provider.dart';

class AddNoteScreen extends StatefulWidget {
  final String userId;
  const AddNoteScreen({super.key, required this.userId});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
 

  
  Future<bool> _saveNoteOnPop() async {
    if (_titleController.text.isEmpty && _contentController.text.isEmpty) {
      return true;
    }

    
    if (_titleController.text.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Judul tidak boleh kosong untuk menyimpan.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false; 
    }

    //Dapatkan provider
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);

    //Panggil fungsi addNote dari provider
    bool success = await noteProvider.addNote(
      userId: widget.userId,
      title: _titleController.text,
      content: _contentController.text,
    );

    //Kembalikan status sukses untuk memberi tahu WillPopScope
    return success;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _saveNoteOnPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tambah Catatan Baru'),
          actions: [
            
            Consumer<NoteProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white)),
                  );
                }
                
                return const SizedBox.shrink();
              },
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Judul',
                  border: OutlineInputBorder(),
                ),
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TextField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    labelText: 'Isi Catatan',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}