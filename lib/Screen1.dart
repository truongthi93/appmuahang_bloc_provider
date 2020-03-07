import 'package:appmuahang/model/product.dart';
import 'bloc/cart_bloc.dart';
import 'main.dart';
import 'package:flutter/material.dart';
import 'Screen2.dart';
import 'package:bloc_provider/bloc_provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CartBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<CartBloc>(context);
    bloc.getAllProduct();
  }

  _pushToCart(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CardPage()),
    );
  }

  @override
  Widget build(BuildContext homeContext) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Cửa Hàng"),
          actions: <Widget>[
            Container(
                child: Stack(
              children: <Widget>[
                new IconButton(
                  icon: new Icon(
                    Icons.shopping_cart,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    if (bloc.selectedProducts.value.isEmpty) {
                      _showAlertEmptyCart(context);
                    } else {
                      _pushToCart(homeContext);
                    }
                  },
                ),
                new Positioned(
                  child: new StreamBuilder<List<Product>>(
                      stream: bloc.selectedProducts,
                      initialData: bloc.selectedProducts.value,
                      builder: (context, listSnap) => listSnap.data.isEmpty
                          ? new Container()
                          : new Stack(
                              children: <Widget>[
                                new Icon(Icons.brightness_1,
                                    size: 22.0, color: Colors.red),
                                new Positioned(
                                  top: 4.0,
                                  right: 6.0,
                                  child: new Center(
                                    child: Text(
                                      '${listSnap.data.length}',
                                      style: new TextStyle(
                                          color: Colors.white,
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                )
                              ],
                            )),
                )
              ],
            )),
          ],
        ),
        body: SafeArea(
            child: new StreamBuilder<List<Product>>(
          stream: bloc.allProducts,
          initialData: [],
          builder: (context, snap) =>
          snap.data.isEmpty ?
          new Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircularProgressIndicator(),
                  ],
                ),
              ],
            )
          ) :
              new GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.57,
            ),
            itemCount: snap.data.length,
            itemBuilder: (context, index) {
              return productItem(snap.data[index]);
            },
          ),
        )));
  }

  Widget productItem(Product product) {
    String name = product.name;
    String imageName = product.image;
    String price = product.price.toInt().toString();

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black
                .withOpacity(0.2), //                   <--- border color
            width: 1.0,
          ),
          borderRadius: BorderRadius.all(
              Radius.circular(14.0) //         <--- border radius here
              ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              // Max Size
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                height: double.infinity,
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 0, left: 0, right: 0, bottom: 0),
                  child: Image(
                    image: AssetImage('$imageName'),
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      name,
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Text(
                      '\u0024$price',
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 21,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    RaisedButton(
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(15.0),
                          side: BorderSide(
                              color: Colors.black.withOpacity(0.05))),
                      onPressed: () {
                        bloc.checkAddOrRemove(product);
                      },
                      child: StreamBuilder<List<Product>>(
                        stream: bloc.selectedProducts,
                        initialData: bloc.selectedProducts.value,
                        builder: (context, selectedSnap) => Text(
                          selectedSnap.data.contains(product) ? 'xoá' : "Thêm vào ",
                          style: new TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 8.0,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  showAlertDialog(BuildContext context) {
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {},
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("My title"),
      content: Text("This is my message."),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<void> _showAlertEmptyCart(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: Text(
            'Giỏ hàng rỗng'.toUpperCase(),
            style: TextStyle(fontSize: 17.0, color: Colors.blue),
          ),
          content: const Text('Vui lòng thêm sản phẩm vào giỏ.'),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
