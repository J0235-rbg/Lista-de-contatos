import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

const String contactTable = "contactTable";
const String idCollum = "idCollum";
const String nameCollum = "nameCollum";
const String emailCollum = "emailCollum";
const String phoneCollum = "phoneCollum";
const String imgCollum = "img";



class ContactHelper {

  static final ContactHelper _instance = ContactHelper.internal();

  factory ContactHelper() => _instance;

  ContactHelper.internal();

  Database? _db;

  Future<Database?> get db async {
    if (_db != null) {
      return _db;
    }else{
      _db = await initDb();
      return _db;
    }
  }
  Future<Database> initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, "contacs.db");

    return await openDatabase(path, version: 1, onCreate: (Database db, int newerVersion ) async {
      await db.execute(
        "CREATE TABLE $contactTable($idCollum INTEGER PRIMARY KEY, $nameCollum TEXT, $emailCollum TEXT, $phoneCollum TEXT,"
        "$imgCollum BLOB )"
      );
    });//inicia o banco

    
  }

  Future<Contact> saveContact(Contact contact) async{
    Database? dbContact = await db;
    contact.id = await dbContact!.insert(contactTable, contact.toMap());
    return contact;
  }// faz o insert dos contatos no banco

  Future<Contact?> getContact(int id) async {
    Database? dbContact = await db;
    List<Map> maps = await dbContact!.query(contactTable,
    columns: [idCollum, nameCollum, emailCollum, phoneCollum, imgCollum],
    where: "$idCollum = ?",
    whereArgs: [id]);
    if (maps.length > 0) {
      return Contact.fromMap(maps.first);
    } else {
      return null;
    }
  }// retorna a resposta do banco 

  Future<int?> deleteContact(int id) async{
    Database? dbContact = await db;
    return await dbContact!.delete(contactTable, where: "$idCollum = ?", whereArgs: [id]);
  }// deleta o contato do banco

  Future<int?> updateContact(Contact contact) async {
    Database? dbContact = await db;
    return await dbContact!.update(contactTable, contact.toMap(), where: "$idCollum = ?", whereArgs: [contact.id]);
  }// faz o update do banco

  Future<List?> getAllCOntacs() async {
    Database? dbContact = await db;
    List listMap = await dbContact!.rawQuery("SELECT * FROM $contactTable");
    List<Contact> listContact  =  []; //List<Contact>(); forma Correta de criar a lista para colocar os contatos 
    for(Map m in listMap){
      listContact.add(Contact.fromMap(m));
    }
    return listContact;
  } // pega todos os contatos do banco usando uma lista

  Future<int?> getNumber() async{
    Database? dbContact = await db;
    return Sqflite.firstIntValue(await dbContact!.rawQuery("SELECT COUNT(*) FROM $contactTable"));
  }// faz uma consulta para pegar os numeros da tabela 

  Future close() async {
    Database? dbContaact = await db;
    dbContaact!.close();
  }// fecha o banco 
  
  
}// Classe responsavel por fazer a maior parte das consultas no banco de dados e cria funçoes para fazer isso 

class Contact {


  

  int? id;
  String? name;
  String? email;
  String? phone;
  String? img;
  Contact();

 Contact.fromMap(Map map){
   id = map[idCollum];
   name = map[nameCollum];
   email = map[emailCollum];
   phone = map[phoneCollum];
   img = map[imgCollum];
 }

 Map<String, dynamic> toMap(){
  Map<String, dynamic> map = {
    nameCollum: name,
    emailCollum: email,
    phoneCollum: phone,
    imgCollum: img,
  };
  if (id != null) {
    map[idCollum] = id;
  }
  return map;
 }

  @override
  String toString(){
    return "Contact(id: $id, name: $name, email: $email, phone: $phone, img: $img)";
  }

}