import 'dart:io';

import 'package:mvvm_uygulama_mimarisi/models/book_model.dart';
import 'package:mvvm_uygulama_mimarisi/models/borrow_info_model.dart';
import 'package:mvvm_uygulama_mimarisi/services/calculator.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'borrow_list_view_model.dart';

class BorrowListView extends StatefulWidget {
  final Book book;
  // ignore: use_key_in_widget_constructors
  const BorrowListView({required this.book});

  @override
  _BorrowListViewState createState() => _BorrowListViewState();
}

class _BorrowListViewState extends State<BorrowListView> {
  @override
  Widget build(BuildContext context) {
    List<BorrowInfo> borrowList = widget.book.borrows;
    return ChangeNotifierProvider<BorrowListViewModel>(
      create: (context) => BorrowListViewModel(),
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          //automaticallyImplyLeading: false,
          title: Text('${widget.book.bookName} Ödünç Kayıtları'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ListView.separated(
                  itemCount: borrowList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundImage:
                            NetworkImage(borrowList[index].photoUrl),
                        /* backgroundImage: NetworkImage(
                            'https://cdn.kidega.com/author/large/carl-sagan-profil-ZB.jpg'),*/
                      ),
                      title: Text(
                          '${borrowList[index].name} ${borrowList[index].surname}'),
                    );
                  },
                  separatorBuilder: (context, _) => const Divider(),
                ),
              ),
              InkWell(
                  onTap: () async {
                    BorrowInfo? newBorrowInfo =
                        await showModalBottomSheet<BorrowInfo>(
                            enableDrag: false,
                            isDismissible: false,
                            builder: (BuildContext context) {
                              return const WillPopScope(child: BorrowForm());
                            },
                            context: context);

                    if (newBorrowInfo != null) {
                      setState(() {
                        borrowList.add(newBorrowInfo);
                      });
                      context.read<BorrowListViewModel>().updateBook(
                          book: widget.book, borrowList: borrowList);
                    }
                  },
                  child: Container(
                      alignment: Alignment.center,
                      height: 80,
                      color: Colors.blue,
                      child: const Text(
                        'YENİ ÖDÜNÇ',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      )))
            ],
          ),
        ),
      ),
    );
  }
}

class BorrowForm extends StatefulWidget {
  const BorrowForm({Key? key}) : super(key: key);

  @override
  _BorrowFormState createState() => _BorrowFormState();
}

class _BorrowFormState extends State<BorrowForm> {
  TextEditingController nameCtr = TextEditingController();
  TextEditingController surnameCtr = TextEditingController();
  TextEditingController borrowDateCtr = TextEditingController();
  TextEditingController returnDateCtr = TextEditingController();
  DateTime? _selectedBorrowDate;
  DateTime? _selectedReturnDate;
  final _formKey = GlobalKey<FormState>();
  String? _photoUrl;
  late File _image;
  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile =
        await picker.pickImage(source: ImageSource.camera, maxHeight: 200);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });

    if (pickedFile != null) {
      _photoUrl = await uploadImageToStorage(_image);
    }
  }

  Future<String> uploadImageToStorage(File imageFile) async {
    /// Storage üzerindeki dosya adını oluştur
    String path = '${DateTime.now().millisecondsSinceEpoch}.jpg';

    /// Dosyayı gönder
    TaskSnapshot uploadTask = await FirebaseStorage.instance
        .ref()
        .child('photos')
        .child(path)
        .putFile(_image);

    String uploadedImageUrl = await uploadTask.ref.getDownloadURL();
    //print('===========> $uploadedImageUrl');
    return uploadedImageUrl;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    nameCtr.dispose();
    surnameCtr.dispose();
    borrowDateCtr.dispose();
    returnDateCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BorrowListViewModel(),
      builder: (context, _) => Container(
        padding: const EdgeInsets.all(10),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Flexible(
                    child: Stack(children: [
                      const CircleAvatar(
                        radius: 40,
                        /* child: (_image == null)
                            ? Image(
                                image: NetworkImage(
                                    'https://cdn.kidega.com/author/large/carl-sagan-profil-ZB.jpg'))
                            : Image.file(_image),*/
                        // backgroundImage: (_image == null)
                        //     ? const NetworkImage(
                        //         'https://cdn.kidega.com/author/large/carl-sagan-profil-ZB.jpg')
                        //     : FileImage(_image),
                      ),
                      Positioned(
                        bottom: -5,
                        right: -10,
                        child: IconButton(
                            onPressed: getImage,
                            icon: Icon(
                              Icons.photo_camera_rounded,
                              color: Colors.grey.shade100,
                              size: 26,
                            )),
                      )
                    ]),
                  ),
                  Flexible(
                    child: Column(
                      children: [
                        TextFormField(
                            controller: nameCtr,
                            decoration: const InputDecoration(
                              hintText: 'Ad',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ad Giriniz';
                              } else {
                                return null;
                              }
                            }),
                        TextFormField(
                            controller: surnameCtr,
                            decoration: const InputDecoration(
                              hintText: 'Soyad',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Soyadı Giriniz';
                              } else {
                                return null;
                              }
                            }),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: TextFormField(
                        onTap: () async {
                          _selectedBorrowDate = (await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now()
                                  .add(const Duration(days: 365))))!;

                          borrowDateCtr.text =
                              Calculator.dateTimeToString(_selectedBorrowDate!);
                        },
                        controller: borrowDateCtr,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.date_range),
                          hintText: 'Alım Tarihi',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen Tarih Seçiniz';
                          } else {
                            return null;
                          }
                        }),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: TextFormField(
                        onTap: () async {
                          _selectedReturnDate = (await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now()
                                  .add(const Duration(days: 365))))!;

                          returnDateCtr.text =
                              Calculator.dateTimeToString(_selectedReturnDate!);
                        },
                        controller: returnDateCtr,
                        decoration: const InputDecoration(
                            hintText: 'İade Tarihi',
                            prefixIcon: Icon(Icons.date_range)),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen Tarih Seçiniz';
                          } else {
                            return null;
                          }
                        }),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          /// kulanıcı bilgileri ile BorrowInfo objesi oluşturacağız
                          BorrowInfo newBorrowInfo = BorrowInfo(
                              name: nameCtr.text,
                              surname: surnameCtr.text,
                              borrowDate: Calculator.datetimeToTimestamp(
                                  _selectedBorrowDate!),
                              returnDate: Calculator.datetimeToTimestamp(
                                  _selectedBorrowDate!),
                              photoUrl: _photoUrl ??
                                  'https://cdn.kidega.com/author/large/carl-sagan-profil-ZB.jpg');

                          /// navigator.pop
                          Navigator.pop(context, newBorrowInfo);
                        }
                      },
                      child: const Text('ÖDÜNÇ KAYIT EKLE')),
                  ElevatedButton(
                      onPressed: () {
                        if (_photoUrl != null) {
                          context
                              .read<BorrowListViewModel>()
                              .deletePhoto(_photoUrl!);
                        }

                        Navigator.pop(context);
                      },
                      child: const Text("İPTAL"))
                ],
              )
            ]),
          ),
        ),
      ),
    );
  }
}
