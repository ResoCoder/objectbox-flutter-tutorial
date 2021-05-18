import 'package:objectbox/objectbox.dart';

@Entity()
@Sync()
class ShopOrder {
  int id;
  int price;
  final customer = ToOne<Customer>();

  ShopOrder({
    this.id = 0,
    required this.price,
  });
}

@Entity()
@Sync()
class Customer {
  int id;
  String name;
  @Backlink()
  final orders = ToMany<ShopOrder>();

  Customer({
    this.id = 0,
    required this.name,
  });
}
