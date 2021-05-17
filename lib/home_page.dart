import 'package:faker/faker.dart';
import 'package:flutter/material.dart';

import 'order_data_table.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final faker = Faker();

  @override
  void initState() {
    super.initState();
    setNewCustomer();
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
      body: OrderDataTable(
        // TODO: Pass in the orders
        onSort: (columnIndex, ascending) {
          // TODO: Query the database and sort the data
        },
      ),
    );
  }

  void setNewCustomer() {
    // TODO: Implement properly
    print('Name: ${faker.person.name()}');
  }

  void addFakeOrderForCurrentCustomer() {
    // TODO: Implement properly
    print('Price: ${faker.randomGenerator.integer(500, min: 10)}');
  }
}
