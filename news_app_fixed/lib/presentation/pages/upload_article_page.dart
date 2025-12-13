import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UploadArticlePage extends StatefulWidget {
  const UploadArticlePage({super.key});

  @override
  State<UploadArticlePage> createState() => _UploadArticlePageState();
}

class _UploadArticlePageState extends State<UploadArticlePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  File? _thumbnail;
  List<String> _selectedTags = [];
  final List<String> _availableTags = [
    'technology', 'news', 'business', 'sports', 'entertainment', 'health', 'politics'
  ];
  bool _isPublished = true;

  Future<void> _pickThumbnail() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _thumbnail = File(pickedFile.path);
      });
    }
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  void _submitArticle() {
    if (_formKey.currentState!.validate() && _thumbnail != null) {
      // TODO: Conectar con ArticleCubit
      print('📝 Título: ${_titleController.text}');
      print('🏷️ Tags: $_selectedTags');
      print('📄 Contenido: ${_contentController.text}');
      print('🌍 Publicado: $_isPublished');
      print('🖼️ Thumbnail: ${_thumbnail!.path}');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('✅ Artículo creado (mock)'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pop(context);
    } else if (_thumbnail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Por favor selecciona una imagen'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Artículo'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.upload),
            onPressed: _submitArticle,
            tooltip: 'Subir artículo',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TÍTULO
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título *',
                  hintText: 'Escribe un título atractivo',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El título es obligatorio';
                  }
                  if (value.length < 5) {
                    return 'El título debe tener al menos 5 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // THUMBNAIL
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Thumbnail *',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickThumbnail,
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _thumbnail == null ? Colors.grey : Colors.green,
                          width: 2,
                        ),
                      ),
                      child: _thumbnail == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate,
                                  size: 60,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Toca para seleccionar imagen',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Recomendado: 1200×630 px',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(_thumbnail!, fit: BoxFit.cover),
                            ),
                    ),
                  ),
                  if (_thumbnail != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '✅ Imagen seleccionada',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 14,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),

              // ETIQUETAS
              const Text(
                'Etiquetas',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableTags.map((tag) {
                  final isSelected = _selectedTags.contains(tag);
                  return ChoiceChip(
                    label: Text(tag),
                    selected: isSelected,
                    onSelected: (_) => _toggleTag(tag),
                    selectedColor: Colors.orange,
                    backgroundColor: Colors.grey[200],
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // ESTADO (Publicado/Borrador)
              Row(
                children: [
                  const Text(
                    'Estado: ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 10),
                  Switch(
                    value: _isPublished,
                    onChanged: (value) {
                      setState(() {
                        _isPublished = value;
                      });
                    },
                    activeColor: Colors.orange,
                  ),
                  Text(
                    _isPublished ? 'Publicado' : 'Borrador',
                    style: TextStyle(
                      color: _isPublished ? Colors.green : Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // CONTENIDO
              TextFormField(
                controller: _contentController,
                maxLines: 10,
                minLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Contenido *',
                  hintText: 'Escribe tu artículo aquí...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El contenido es obligatorio';
                  }
                  if (value.length < 50) {
                    return 'El contenido debe tener al menos 50 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),

              // BOTÓN ENVIAR
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitArticle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'CREAR ARTÍCULO',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}