import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../ providers/customerProvider.dart';
import '../models/customerModel.dart';
import '../services/apiService.dart';

// this is the form screen, all the fields will have validation logic wherever
//required


class CustomerFormScreen extends StatefulWidget {
  final Customer? customer;
  final int? index;

  CustomerFormScreen({this.customer, this.index});

  @override
  _CustomerFormScreenState createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String _pan = '';
  String _fullName = '';
  String _email = '';
  String _mobileNumber = '';
  List<Address> _addresses = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    //setting variable or methods required at the start od the application
    if (widget.customer != null) {
      _pan = widget.customer!.pan;
      _fullName = widget.customer!.fullName;
      _email = widget.customer!.email;
      _mobileNumber = widget.customer!.mobileNumber;
      _addresses = List.from(widget.customer!.addresses);
    } else {
      _addresses.add(Address(addressLine1: '', postcode: '', state: '', city: ''));
    }
  }
//function to verify the pan number
  Future<void> _verifyPAN(String pan) async {
    setState(() => _isLoading = true);
    try {
      final result = await APIService.verifyPAN(pan);
      if (result['isValid'] == true) {
        setState(() => _fullName = result['fullName']);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to verify PAN')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
  //function to get the postalcode details

  Future<void> _getPostcodeDetails(String postcode, int index) async {
    setState(() => _isLoading = true);
    try {
      final result = await APIService.getPostcodeDetails(postcode);
      setState(() {
        _addresses[index].state = result['state'][0]['name'];
        _addresses[index].city = result['city'][0]['name'];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get postcode details')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
//checking address
  void _addAddress() {
    if (_addresses.length < 10) {
      setState(() {
        _addresses.add(Address(addressLine1: '', postcode: '', state: '', city: ''));
      });
    }
  }
  //removing the address

  void _removeAddress(int index) {
    setState(() {
      _addresses.removeAt(index);
    });
  }
//form submission logic
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final customer = Customer(
        pan: _pan,
        fullName: _fullName,
        email: _email,
        mobileNumber: _mobileNumber,
        addresses: _addresses,
      );

      final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
      if (widget.index != null) {
        customerProvider.updateCustomer(widget.index!, customer);
      } else {
        customerProvider.addCustomer(customer);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 69,
        backgroundColor: Colors.white,
        elevation: 0,
        //automaticallyImplyLeading: false,
        titleSpacing: 10,
        title: Text(widget.customer != null ? 'Edit Customer' : 'Add Customer'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          height: (screenHeight) * 0.80,


          child: Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.all(14.0),
              children: [
                Container(
                  margin: EdgeInsets.only(left:0, right:0, bottom: 5, top: 5),
                  child: TextFormField(
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                        borderRadius: BorderRadius.circular(5.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                        borderRadius: BorderRadius.circular(5.5),
                      ),
                      hintText: "Enter your PAN number",
                      prefixIcon: Icon(Icons.add_card),
                      hintStyle: TextStyle(color: Colors.blue),
                      filled: true,
                      fillColor: Colors.blue[50],
                    ),
                    initialValue: _pan,
                    //decoration: InputDecoration(labelText: 'PAN'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter PAN';
                      }
                      if (value.length != 10) {
                        return 'PAN must be 10 characters long';
                      }
                      // Add more PAN validation logic here
                      return null;
                    },
                    onSaved: (value) => _pan = value!,
                    onChanged: (value) {
                      if (value.length == 10) {
                        _verifyPAN(value);
                      }
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left:0, right:0, bottom: 5, top: 5),

                  child: TextFormField(
                    initialValue: _fullName,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                        borderRadius: BorderRadius.circular(5.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                        borderRadius: BorderRadius.circular(5.5),
                      ),
                      hintText: "Enter your Name",
                      prefixIcon: Icon(Icons.person),
                      hintStyle: TextStyle(color: Colors.blue),
                      filled: true,
                      fillColor: Colors.blue[50],
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter full name';
                      }
                      if (value.length > 140) {
                        return 'Full name must be at most 140 characters long';
                      }
                      return null;
                    },
                    onSaved: (value) => _fullName = value!,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left:0, right:0, bottom: 5, top: 5),

                  child: TextFormField(
                    initialValue: _email,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                        borderRadius: BorderRadius.circular(5.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                        borderRadius: BorderRadius.circular(5.5),
                      ),
                      hintText: "Enter your Email",
                      hintStyle: TextStyle(color: Colors.blue),
                      prefixIcon: Icon(Icons.email),
                      filled: true,
                      fillColor: Colors.blue[50],
                    ),
                    validator: validateEmail,

                    onSaved: (value) => _email = value!,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left:0, right:0, bottom: 5, top: 5),

                  child: TextFormField(
                    initialValue: _mobileNumber,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                        borderRadius: BorderRadius.circular(5.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                        borderRadius: BorderRadius.circular(5.5),
                      ),
                      hintText: "Enter your Mobile Number",
                      hintStyle: TextStyle(color: Colors.blue),
                      filled: true,
                      prefixText: "+91 ",
                      prefixIcon: Icon(Icons.phone),
                      fillColor: Colors.blue[50],
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter mobile number';
                      }
                      if (value.length != 10) {
                        return 'Mobile number must be 10 digits long';
                      }
                      // Add more mobile number validation logic here
                      return null;
                    },
                    onSaved: (value) => _mobileNumber = value!,
                  ),
                ),
                SizedBox(height: 16),
                Container(
                    margin: EdgeInsets.only(left:0, right:0, bottom: 5, top: 5),

                    child: Text('Addresses', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold))),
                ..._addresses.asMap().entries.map((entry) {
                  final index = entry.key;
                  final address = entry.value;
                  return Container(
                    margin: EdgeInsets.only(left:8, right:8, bottom: 5, top: 5),

                    child: Column(
                      children: [
                        Container(
                          margin:EdgeInsets.only(top:5, bottom:5),
                          child: TextFormField(
                            initialValue: address.addressLine1,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.transparent),
                                borderRadius: BorderRadius.circular(5.5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.transparent),
                                borderRadius: BorderRadius.circular(5.5),
                              ),
                              hintText: "Address Line 1",
                              hintStyle: TextStyle(color: Colors.blue),
                              filled: true,
                              fillColor: Colors.blue[50],
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter address line 1';
                              }
                              return null;
                            },
                            onSaved: (value) => address.addressLine1 = value!,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top:5, bottom:5),
                          child: TextFormField(
                            initialValue: address.addressLine2,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.transparent),
                                borderRadius: BorderRadius.circular(5.5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.transparent),
                                borderRadius: BorderRadius.circular(5.5),
                              ),
                              hintText: "Address Line 2",
                              hintStyle: TextStyle(color: Colors.blue),
                              filled: true,
                              fillColor: Colors.blue[50],
                            ),
                            onSaved: (value) => address.addressLine2 = value,
                          ),
                        ),
                        Container(
                          margin:EdgeInsets.only(top:5, bottom: 5),
                          child: TextFormField(
                            initialValue: address.postcode,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.transparent),
                                borderRadius: BorderRadius.circular(5.5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.transparent),
                                borderRadius: BorderRadius.circular(5.5),
                              ),
                              hintText: "Postal Code",
                              hintStyle: TextStyle(color: Colors.blue),
                              filled: true,
                              fillColor: Colors.blue[50],
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter postcode';
                              }
                              if (value.length != 6) {
                                return 'Postcode must be 6 digits long';
                              }
                              return null;
                            },
                            onSaved: (value) => address.postcode = value!,
                            onChanged: (value) {
                              if (value.length == 6) {
                                _getPostcodeDetails(value, index);
                              }
                            },
                          ),
                        ),
                        Container(
                          margin:EdgeInsets.only(top:5, bottom:5),
                          child: TextFormField(
                            initialValue: address.state,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.transparent),
                                borderRadius: BorderRadius.circular(5.5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.transparent),
                                borderRadius: BorderRadius.circular(5.5),
                              ),
                              hintText: "State",
                              hintStyle: TextStyle(color: Colors.blue),
                              filled: true,
                              fillColor: Colors.blue[50],
                            ),
                            readOnly: true,// as this is filled with the api call
                          ),
                        ),
                        Container(
                          margin:EdgeInsets.only(top:5, bottom:5),
                          child: TextFormField(
                            initialValue: address.city,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.transparent),
                                borderRadius: BorderRadius.circular(5.5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.transparent),
                                borderRadius: BorderRadius.circular(5.5),
                              ),
                              hintText: "City",
                              hintStyle: TextStyle(color: Colors.blue),
                              filled: true,
                              fillColor: Colors.blue[50],
                            ),
                            readOnly: true,
                          ),
                        ),
                        if (_addresses.length > 1)
                          Center(
                            child: Container(
                              width: 160,
                              margin:EdgeInsets.only(top:5, bottom:5),

                              child: ElevatedButton(
                                onPressed: () => _removeAddress(index),
                                child: Text('Remove Address', style: TextStyle(color: Colors.black),),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.lightBlue,
                                    elevation: 0,
                                  )
                              ),
                            ),
                          ),
                        Divider(),
                      ],
                    ),
                  );
                }).toList(),
                if (_addresses.length < 10)
                  Center(
                    child: Container(
                      width: 150,
                      child: ElevatedButton(
                        onPressed: _addAddress,
                        child: Text('Add Address', style: TextStyle(color:Colors.black),),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightBlue,
                            elevation: 0,
                          )
                      ),
                    ),
                  ),
                SizedBox(height: 16),
                Center(
                  child: Container(
                    width: 150,
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      child: Text('Save Customer', style: TextStyle(color: Colors.black),),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue,
                        elevation: 0,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16,)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
String? validateEmail(String? value) {
  final String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  final RegExp emailRegExp = RegExp(emailPattern);

  if (value == null || value.isEmpty) {
    return 'Email is required';
  } else if (!emailRegExp.hasMatch(value)) {
    return 'Enter a valid email';
  }
  return null;
}