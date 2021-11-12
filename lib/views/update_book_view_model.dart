import 'package:mvvm_uygulama_mimarisi/models/book_model.dart';
import 'package:mvvm_uygulama_mimarisi/services/calculator.dart';
import 'package:mvvm_uygulama_mimarisi/services/database.dart';
import 'package:flutter/material.dart';

class UpdateBookViewModel extends ChangeNotifier {
  Database _database = Database();
  String collectionPath = 'books';

  Future<void> updateBook(
      {required String bookName,
      required String authorName,
      required DateTime publishDate,
      required Book book}) async {
    /// Form alanındaki verileri ile önce bir book objesi oluşturulması
    Book newBook = Book(
        id: book.id,
        bookName: bookName,
        authorName: authorName,
        publishDate: Calculator.datetimeToTimestamp(publishDate),
        borrows: book.borrows);

    /// bu kitap bilgisini database servisi üzerinden Firestore'a yazacak
    await _database.setBookData(
        collectionPath: collectionPath, bookAsMap: newBook.toMap());
  }
}
