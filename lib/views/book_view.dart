import 'package:mvvm_uygulama_mimarisi/models/book_model.dart';
import 'package:mvvm_uygulama_mimarisi/views/books_view_model.dart';
import 'package:mvvm_uygulama_mimarisi/views/borrow_list_view.dart';
import 'package:mvvm_uygulama_mimarisi/views/update_book_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import 'add_book_view.dart';

class BooksView extends StatefulWidget {
  @override
  _BooksViewState createState() => _BooksViewState();
}

class _BooksViewState extends State<BooksView> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BooksViewModel>(
      create: (_) => BooksViewModel(),
      builder: (context, child) => Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          title: const Text('KİTAP LİSTESİ'),
          centerTitle: true,
        ),
        body: Center(
          child: Column(children: [
            StreamBuilder<List<Book>>(
              stream: Provider.of<BooksViewModel>(context, listen: false)
                  .getBookList(),
              builder: (context, asyncSnapshot) {
                if (asyncSnapshot.hasError) {
                  print(asyncSnapshot.error);
                  return const Center(
                      child:
                          Text('Bir Hata Oluştu, daha sonra tekrar deneyiniz'));
                } else {
                  if (!asyncSnapshot.hasData) {
                    return const CircularProgressIndicator();
                  } else {
                    List<Book>? kitapList = asyncSnapshot.data;
                    return BuildListView(
                      kitapList: kitapList!,
                      key: UniqueKey(),
                    );
                  }
                }
              },
            ),
            const Divider(),
          ]),
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const AddBookView()));
            },
            child: const Icon(Icons.add)),
      ),
    );
  }
}

class BuildListView extends StatefulWidget {
  const BuildListView({
    required Key key,
    required this.kitapList,
  }) : super(key: key);

  final List<Book> kitapList;

  @override
  _BuildListViewState createState() => _BuildListViewState();
}

class _BuildListViewState extends State<BuildListView> {
  bool isFiltering = false;
  late List<Book> filteredList;

  @override
  Widget build(BuildContext context) {
    var fullList = widget.kitapList;

    return Flexible(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: TextField(
              decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Arama: Kitap adı',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6.0))),
              onChanged: (query) {
                if (query.isNotEmpty) {
                  isFiltering = true;

                  setState(() {
                    filteredList = fullList
                        .where((book) => book.bookName
                            .toLowerCase()
                            .contains(query.toLowerCase()))
                        .toList();
                  });
                } else {
                  WidgetsBinding.instance!.focusManager.primaryFocus!.unfocus();
                  setState(() {
                    isFiltering = false;
                  });
                }
              },
            ),
          ),
          Flexible(
            child: ListView.builder(
                itemCount: isFiltering ? filteredList.length : fullList.length,
                itemBuilder: (context, index) {
                  var list = isFiltering ? filteredList : fullList;
                  return Slidable(
                    child: Card(
                      child: ListTile(
                        title: Text(list[index].bookName),
                        subtitle: Text(list[index].authorName),
                      ),
                    ),
                    actionPane: const SlidableScrollActionPane(),
                    actionExtentRatio: 0.2,
                    actions: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 1.0),
                        child: IconSlideAction(
                          caption: 'Kayıtlar',
                          color: Colors.greenAccent,
                          icon: Icons.person,
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        BorrowListView(book: list[index])));
                          },
                        ),
                      ),
                    ],
                    secondaryActions: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 1.0),
                        child: IconSlideAction(
                          caption: 'Düzenle',
                          color: Colors.orange,
                          icon: Icons.edit,
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        UpdateBookView(book: list[index])));
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 1.0),
                        child: IconSlideAction(
                          caption: 'Sil',
                          color: Colors.red,
                          icon: Icons.delete,
                          onTap: () async {
                            await Provider.of<BooksViewModel>(context,
                                    listen: false)
                                .deleteBook(list[index]);
                          },
                        ),
                      ),
                    ],
                  );

                  /* return Dismissible(
                    key: UniqueKey(),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                      color: Colors.redAccent,
                    ),
                    onDismissed: (_) async {
                      await Provider.of<BooksViewModel>(context,
                              listen: false)
                          .deleteBook(kitapList[index]);
                      print(kitapList[index].id);
                    },
                    child: Card(
                      child: ListTile(
                        title: Text(kitapList[index].bookName),
                        subtitle: Text(kitapList[index].authorName),
                        trailing: IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        UpdateBookView(
                                            book: kitapList[index])));
                          },
                        ),
                      ),
                    ),
                  );*/
                }),
          ),
        ],
      ),
    );
  }
}
