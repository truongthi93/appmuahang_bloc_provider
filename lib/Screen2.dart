import 'dart:ffi';

import 'package:appmuahang/bloc/cart_bloc.dart';
import 'package:bloc_provider/bloc_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'model/product.dart';

enum ConfirmAction { CANCEL, ACCEPT }

class CardPage extends StatefulWidget {
  @override
  _CardPageState createState() => _CardPageState();
}

class _CardPageState extends State<CardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Giỏ Hàng"),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back, // add custom icons also
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        child: _productListView(context),
      ),
    );
  }

  Widget _productListView(BuildContext context) {
    final CartBloc _bloc = BlocProvider.of<CartBloc>(context);
    return new StreamBuilder<List<Product>>(
      stream: _bloc.selectedProducts,
      initialData: _bloc.selectedProducts.value,
      builder: (context, listSnap) =>
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: listSnap.data.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                        trailing: GestureDetector(
                          onTap: () {
                            _deleteItem(listSnap.data[index], _bloc, index);
                          },
                          child: Icon(
                            Icons.delete,
                            size: 25,
                            color: Colors.red,
                          ),
                        ),
                        leading: Image(
                          image: AssetImage(_bloc.selectedProducts.value[index].image),
                          fit: BoxFit.fitWidth,
                        ),
                        title: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('${_bloc.selectedProducts.value[index].name}'),
                              SizedBox(height: 5,),
                              Text('\u0024${_bloc.selectedProducts.value[index].price.toInt()}'),
                            ],
                          ),
                        )
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("Tổng:", style: TextStyle(color: Colors.black, fontSize: 17),),
                    SizedBox(width: 20,),
                    Text("\u0024${_getCountPrice(listSnap.data)}", style: TextStyle(color: Colors.red, fontSize: 20),)
                  ],
                ),
              ),
            ],
          ),
    );
  }

  int _getCountPrice(List<Product> listProduct) {
    double start = 0;
    listProduct.forEach((element) {
      start += element.price;
    });
    return start.toInt();
  }

  Future<void> _deleteItem(Product product, CartBloc blocProduct, int index) async {
    var action = await _asyncConfirmDialog(context, "Thông Báo", "Bạn có muống xoá ${product.name} giá \u0024${product.price.toInt()} ra khỏi giỏ hàng?");
    if (action == ConfirmAction.ACCEPT) {
      blocProduct.checkAddOrRemove(blocProduct.selectedProducts.value[index]);
      if (blocProduct.selectedProducts.value.isEmpty) {
        Navigator.pop(context);
      }
    }
  }

  Future<ConfirmAction> _asyncConfirmDialog(BuildContext context, String title, String subTitle,) async {
    return showDialog<ConfirmAction>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: Text(title),
          content: Text(subTitle),
          actions: <Widget>[
            FlatButton(
              child: const Text('Bỏ Qua'),
              onPressed: () {
                Navigator.of(context).pop(ConfirmAction.CANCEL);
              },
            ),
            FlatButton(
              child: const Text('Đồng Ý'),
              onPressed: () {
                Navigator.of(context).pop(ConfirmAction.ACCEPT);
              },
            )
          ],
        );
      },
    );
  }
}