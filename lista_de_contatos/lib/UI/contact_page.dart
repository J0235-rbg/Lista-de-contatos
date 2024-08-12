// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:lista_de_contatos/helpers/contact_helpers.dart';

class ContactPage extends StatefulWidget {
  final Contact? contact;

  const ContactPage({super.key, this.contact});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _nameControler = TextEditingController();
  final _emailControler = TextEditingController();
  final _phoneControler = TextEditingController();

  final nameFocus = FocusNode();
  File? _image;

  bool _userEdited = false;

  Contact? _editedContact;

  @override
  void initState() {
    super.initState();

    if (widget.contact == null) {
      _editedContact = Contact();
    } else {
      _editedContact = Contact.fromMap(widget.contact!.toMap());

      _nameControler.text = _editedContact!.name!;
      _emailControler.text = _editedContact!.email!;
      _phoneControler.text = _editedContact!.phone!;
      if (_editedContact!.img != null){
        _image = File(_editedContact!.img!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _userEdited,
      onPopInvoked: ((didPop) {
        if (!_userEdited) {
          _userEdited = true;
          Navigator.of(context).pop();
        } else if (!didPop) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Tem certeza ?"),
              content: const Text("O contato não será salvo"),
              actions: <Widget>[
                TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text("Não")),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    child: const Text("Sim"))
              ],
            ),
          );
        }
      }),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: Text(_editedContact?.name ?? "Novo Contato"),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (_editedContact!.name != null &&
                _editedContact!.name!.isNotEmpty) {
              Navigator.pop(context, _editedContact);
            } else {
              FocusScope.of(context).requestFocus(nameFocus);
            }
          },
          backgroundColor: Colors.red,
          child: const Icon(Icons.save),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  _pickImageFromGallery(); // chama a função responsavel por pegar a imagem da galeria 
                },
                child: Container(
                  width: 140.0,
                  height: 140.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: (_image != null)
                          ? FileImage(_image!) // insere a imagem como File
                          as ImageProvider<Object>
                          : const AssetImage("images/person.png")
                              as ImageProvider<Object>,
                              fit: BoxFit.cover
                      //  if(_editedContact?.img != null || == 'imgteste'){
                      //    FileImage(File(_editedContact!.img!)) as ImageProvider<Object>
                      // } else {
                      //   const AssetImage("images/person.png") as ImageProvider<Object>
                      // }
                    ),
                  ),
                ),
              ),
              TextField(
                controller: _nameControler,
                focusNode: nameFocus,
                decoration: const InputDecoration(labelText: "Nome"),
                onChanged: (text) {
                  _userEdited = true;
                  setState(() {
                    _editedContact?.name = text;
                  });
                },
              ),
              TextField(
                controller: _emailControler,
                decoration: const InputDecoration(labelText: "Email"),
                onChanged: (text) {
                  _userEdited = true;
                  _editedContact?.email = text;
                },
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _phoneControler,
                decoration: const InputDecoration(labelText: "Phone"),
                onChanged: (text) {
                  _userEdited = true;
                  _editedContact?.phone = text;
                },
                keyboardType: TextInputType.phone,
              )
            ],
          ),
        ),
      ),
    );
  }
  // pega a imagem da galeria 
  Future _pickImageFromGallery() async{
    final  returnedImage = (await ImagePicker().pickImage(source: ImageSource.gallery)) ; // recebe a imagem da galeria como XFile
    
    setState(() {
      _image = File(returnedImage!.path); // transforma a varialvel XFile em File 
       _editedContact!.img = returnedImage.path ; // retorna a imagem já como File
    });
  }
}
