import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/customerModel.dart';

class CustomerProvider with ChangeNotifier {
  List<Customer> _customers = [];

  List<Customer> get customers => _customers;
//this function will be used to addnew customer
  Future<void> addCustomer(Customer customer) async {
    _customers.add(customer);
    await _saveCustomers();
    notifyListeners();
  }
//this function will be used to update the customer
  Future<void> updateCustomer(int index, Customer customer) async {
    _customers[index] = customer;
    await _saveCustomers();
    notifyListeners();
  }
// this function will be used to delete the customer
  Future<void> deleteCustomer(int index) async {
    _customers.removeAt(index);
    await _saveCustomers();
    notifyListeners();
  }
//for loading the list of added customer
  Future<void> loadCustomers() async {
    final prefs = await SharedPreferences.getInstance();
    final String? customersJson = prefs.getString('customers');
    if (customersJson != null) {
      final List<dynamic> decodedList = json.decode(customersJson);
      _customers = decodedList.map((item) => Customer.fromJson(item)).toList();
      notifyListeners();
    }
  }
// to save the customer
  Future<void> _saveCustomers() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedList = json.encode(_customers.map((c) => c.toJson()).toList());
    await prefs.setString('customers', encodedList);
  }
}