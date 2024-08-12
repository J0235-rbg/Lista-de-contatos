// ignore_for_file: avoid_print

import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:lista_de_contatos/UI/contact_page.dart';
// import 'package:flutter/foundation.dart';
import 'package:lista_de_contatos/helpers/contact_helpers.dart';
import 'package:path/path.dart' hide context;

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  ContactHelper helper = ContactHelper();

  List<Contact> contacts = [];

  void _showContactPage({Contact? contact}) async {
    final Contact? recContac = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ContactPage(
                contact: contact,
              )),
    );
    if (recContac != null) {
      if (contact != null) {
        await helper.updateContact(recContac);
      } else {
        await helper.saveContact(recContac);
      }
      _getAllContacs();
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _getAllContacs();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Contatos"),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showContactPage();
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(10.0),
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          return _contactCard(context, index);
        },
      ),
    );
  }

  Widget _contactCard(BuildContext context, int index) {
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: <Widget>[
              Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: contacts[index].img != null
                          ? FileImage(File(contacts[index].img!))
                              // (FileImage(contacts[index].img! as File ) as File)
                              as ImageProvider<Object>
                          : const AssetImage("images/person.png")
                              as ImageProvider<Object>,
                      fit: BoxFit.cover),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      contacts[index].name ?? "",
                      style: const TextStyle(
                          fontSize: 22.0, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      contacts[index].email ?? "",
                      style: const TextStyle(
                        fontSize: 18.0,
                      ),
                    ),
                    Text(
                      contacts[index].phone ?? "",
                      style: const TextStyle(
                        fontSize: 18.0,
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      onTap: () {
        _showoptions(context, index);
      },
    );
  }

  void _showoptions(BuildContext context, int index) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
              onClosing: () {},
              builder: (context) {
                return Container(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                          padding: const EdgeInsets.all(10),
                          child: ElevatedButton(
                            onPressed: () {
                              launchUrl(
                                  Uri.parse("tel:${contacts[index].phone}"));
                              Navigator.pop(context);
                            },
                            child: const Text(
                              "Ligar",
                              style: TextStyle(color: Colors.red, fontSize: 20),
                            ),
                          )),
                      Padding(
                          padding: const EdgeInsets.all(10),
                          child: ElevatedButton(
                            onPressed: () {
                              print('shaolim matador de porco este');
                              Navigator.pop(context);
                              _showContactPage(contact: contacts[index]);
                            },
                            child: const Text(
                              "Editar",
                              style: TextStyle(color: Colors.red, fontSize: 20),
                            ),
                          )),
                      Padding(
                          padding: const EdgeInsets.all(10),
                          child: ElevatedButton(
                            onPressed: () {
                              helper.deleteContact(contacts[index].id!);
                              setState(() {
                                contacts.removeAt(index);
                                Navigator.pop(context);
                              });
                            },
                            child: const Text(
                              "Excluir",
                              style: TextStyle(color: Colors.red, fontSize: 20),
                            ),
                          ))
                    ],
                  ),
                );
              });
        });
  }

  void _getAllContacs() {
    contacts.clear();
    helper.getAllCOntacs().then(
      (list) {
        setState(
          () {
            for (var contact in list!) {
              contacts.add(contact);
              print(contact);
            }
          },
        );
      },
    );
  }
}
