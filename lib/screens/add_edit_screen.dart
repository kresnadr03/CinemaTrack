import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/movie_model.dart';

class AddEditMovieScreen extends StatefulWidget {
  final Movie? movie; // null untuk tambah

  const AddEditMovieScreen({Key? key, this.movie}) : super(key: key);

  @override
  State<AddEditMovieScreen> createState() => _AddEditMovieScreenState();
}

class _AddEditMovieScreenState extends State<AddEditMovieScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _genreController = TextEditingController();
  final _noteController = TextEditingController();
  final _posterUrlController = TextEditingController();

  String _status = 'belum';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final movie = widget.movie;
    if (movie != null) {
      _titleController.text = movie.title;
      _genreController.text = movie.genre;
      _noteController.text = movie.note ?? '';
      _posterUrlController.text = movie.posterUrl ?? '';
      _status = movie.status;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _genreController.dispose();
    _noteController.dispose();
    _posterUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveMovie() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final movieData = {
      'title': _titleController.text.trim(),
      'genre': _genreController.text.trim(),
      'status': _status,
      'note': _noteController.text.trim(),
      'posterUrl': _posterUrlController.text.trim(),
    };

    final watchlistRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('watchlist');

    if (widget.movie == null) {
      // Add new
      await watchlistRef.add(movieData);
    } else {
      // Update
      await watchlistRef.doc(widget.movie!.id).update(movieData);
    }

    Navigator.pop(context); // kembali ke Home
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.movie != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Film" : "Tambah Film"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Judul Film'),
                validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _genreController,
                decoration: const InputDecoration(labelText: 'Genre'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _status,
                items: const [
                  DropdownMenuItem(value: 'belum', child: Text('Belum Ditonton')),
                  DropdownMenuItem(value: 'sudah', child: Text('Sudah Ditonton')),
                ],
                onChanged: (val) => setState(() => _status = val!),
                decoration: const InputDecoration(labelText: 'Status'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(labelText: 'Catatan (opsional)'),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _posterUrlController,
                decoration: const InputDecoration(labelText: 'URL Poster (opsional)'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveMovie,
                child: Text(_isSaving ? "Menyimpan..." : (isEdit ? "Simpan Perubahan" : "Tambah")),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
