import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../ providers/customerProvider.dart';
import 'customerForm.dart';


class CustomerList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer List'),
      ),
      body: Consumer<CustomerProvider>(
        builder: (context, customerProvider, child) {
          if (customerProvider.customers.isEmpty) {
            return Center(child: Text('No customers added yet.'));
          }
          return Container(
            // margin: EdgeInsets.all(8),
            padding: EdgeInsets.all(3),
            decoration: BoxDecoration(
                color: Colors.blueAccent,
                border: Border.all(color: Colors.brown, width: 0.3, style: BorderStyle.solid),
                borderRadius: BorderRadius.all(
                  Radius.circular(20),
                )
            ),
            child: ListView.builder(
              itemCount: customerProvider.customers.length,
              itemBuilder: (context, index) {
                final customer = customerProvider.customers[index];
                return Container(
                  // color: Colors.cyan,
                  // padding: EdgeInsets.only(top:6),
                  margin: EdgeInsets.only(top:3),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.brown, width: 0.3, style: BorderStyle.solid),
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      )
                  ),
                  child: ListTile(
                    title: Text(customer.fullName),
                    subtitle: Text(customer.email),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit,color: Colors.black87,),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CustomerFormScreen(customer: customer, index: index),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.black87,),
                          onPressed: () {
                            customerProvider.deleteCustomer(index);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CustomerFormScreen()),
          );
        },
        backgroundColor: Colors.blueGrey,
        child: Icon(Icons.add),
      ),
    );
  }
}