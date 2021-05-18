import 'dart:io';

import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:objectbox/objectbox.dart';
import 'package:objectbox_tutorial/objectbox.g.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

import 'entities.dart';
import 'order_data_table.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final faker = Faker();

  late Store _store;
  late SyncClient _syncClient;
  bool hasBeenInitialized = false;

  late Customer _customer;

  late Stream<List<ShopOrder>> _stream;

  @override
  void initState() {
    super.initState();
    setNewCustomer();
    getApplicationDocumentsDirectory().then((dir) {
      _store = Store(
        getObjectBoxModel(),
        directory: join(dir.path, 'objectbox'),
      );

      if (Sync.isAvailable()) {
        _syncClient = Sync.client(
          _store,
          Platform.isAndroid ? 'ws://10.0.2.2:9999' : 'ws://127.0.0.1:9999',
          SyncCredentials.none(),
        );
        _syncClient.start();
      }

      setState(() {
        _stream = _store
            .box<ShopOrder>()
            .query()
            .watch(triggerImmediately: true)
            .map((query) => query.find());
        hasBeenInitialized = true;
      });
    });
  }

  @override
  void dispose() {
    _store.close();
    _syncClient.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders App'),
        actions: [
          IconButton(
            icon: Icon(Icons.person_add_alt),
            onPressed: setNewCustomer,
          ),
          IconButton(
            icon: Icon(Icons.attach_money),
            onPressed: addFakeOrderForCurrentCustomer,
          ),
        ],
      ),
      body: !hasBeenInitialized
          ? Center(
              child: CircularProgressIndicator(),
            )
          : StreamBuilder<List<ShopOrder>>(
              stream: _stream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return OrderDataTable(
                  orders: snapshot.data!,
                  onSort: (columnIndex, ascending) {
                    final newQueryBuilder = _store.box<ShopOrder>().query();
                    final sortField =
                        columnIndex == 0 ? ShopOrder_.id : ShopOrder_.price;
                    newQueryBuilder.order(
                      sortField,
                      flags: ascending ? 0 : Order.descending,
                    );

                    setState(() {
                      _stream = newQueryBuilder
                          .watch(triggerImmediately: true)
                          .map((query) => query.find());
                    });
                  },
                  store: _store,
                );
              }),
    );
  }

  void setNewCustomer() {
    _customer = Customer(name: faker.person.name());
  }

  void addFakeOrderForCurrentCustomer() {
    final order = ShopOrder(
      price: faker.randomGenerator.integer(500, min: 10),
    );
    order.customer.target = _customer;
    _store.box<ShopOrder>().put(order);
  }
}
