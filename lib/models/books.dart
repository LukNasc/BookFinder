class Book {
  String error;
  String total;
  String page;
  List<dynamic> books;

  Book({this.error, this.total, this.page, this.books});

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
        error: json['error'],
        total: json['total'],
        page: json['page'],
        books: json['books']);
  }
}
