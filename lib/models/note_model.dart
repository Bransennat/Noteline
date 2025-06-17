import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  // Properti catatan
  final String id;
  final String title;
  final String content;
  final Timestamp createdAt;

  // Constructor membuat objek Note
  const Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  // Method ubah objek Note jadi format JSON
  // untuk menyimpan data ke Cloud Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt,
    };
  }

  // Factory constructor untuk buat objek Note dari data JSON
  // untuk mengambil data dari Cloud Firestore
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      createdAt: json['createdAt'] as Timestamp,
    );
  }
}