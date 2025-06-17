import 'package:flutter/material.dart';
import 'package:notesecure/models/note_model.dart';
import 'package:notesecure/providers/note_provider.dart';
import 'package:provider/provider.dart';

class EditNoteScreen extends StatefulWidget {
  final Note note;
  final String userId;
  const EditNoteScreen({super.key, required this.note, required this.userId});

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  
  
  late String _initialTitle;
  late String _initialContent;

  bool get _hasChanges => 
      _titleController.text != _initialTitle || _contentController.text != _initialContent;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.note.title;
    _contentController.text = widget.note.content;

    _initialTitle = widget.note.title;
    _initialContent = widget.note.content;
  }

  // Fungsi update memanggil provider
  Future<bool> _updateNoteOnPop() async {
    if (!_hasChanges) {
      return true; // Langsung kembali jika tidak ada perubahan
    }

    if (_titleController.text.isEmpty) {
      if(context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Judul tidak boleh kosong.'), backgroundColor: Colors.red),
        );
      }
      return false; // Jangan izinkan kembali
    }

    // Dapatkan provider
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);

    // Panggil fungsi update dari provider
    bool success = await noteProvider.updateNote(
      userId: widget.userId,
      noteId: widget.note.id,
      title: _titleController.text,
      content: _contentController.text,
    );

    // Kembalikan sukses dari provider
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
      onWillPop: _updateNoteOnPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Catatan'),
          actions: [
            // Tambahkan Consumer untuk menampilkan loading indicator
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
                return const SizedBox.shrink(); // Tidak tampilkan apa-apa jika tidak loading
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
                decoration: const InputDecoration(
                  labelText: 'Judul',
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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