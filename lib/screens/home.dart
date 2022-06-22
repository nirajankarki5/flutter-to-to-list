import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String title = "";
  String date = "Select Date";
  bool showDatePicker = false;
  bool isEdit = false;
  late String editId;
  TextEditingController controller = TextEditingController();

  List<Map<String, dynamic>> list = [];
  List<Map<String, dynamic>> newList = [];

  handleSubmit() {
    FocusScope.of(context).requestFocus(FocusNode());
    if (isEdit) {
      // EDIT ITEMS IN THE LIST

      print("EDITTTT");
      list.forEach((e) {
        print("list id $editId and e[] ${e["id"]}");
        if (e["id"].toString() == editId) {
          newList.add({"title": title, "date": date, "id": e["id"]});
          return;
        }
        return newList.add(e);
      });
      print("new list is $newList");
      setState(() {
        list = newList;
        var box = Hive.box('myBox');
        box.put('list', list);
        controller.clear();
        title = "";
        date = "Select Date";
      });
    } else if (title == '' || date == "Select Date") {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Title and Date can not be empty'),
      ));
      return;
    } else {
      // ADD NEW LIST
      setState(() {
        list.add(
            {"title": title, "date": date, "id": DateTime.now().microsecond});
        log(list.toString());

        // ADD LIST IN HIVE DATABASE
        var box = Hive.box('myBox');
        box.put('list', list);

        controller.clear();
        title = "";
        date = "Select Date";
      });
    }
  }

  handleEdit(id, text, editDate) {
    //
    setState(() {
      isEdit = true;
      editId = id.toString();
      title = text;
      controller.text = text;
      date = editDate;
    });
  }

  handleDelete(id) {
    //
    print("DELETE FUNCTION");
    var item = list.firstWhere((element) => element["id"] == id);
    setState(() {
      list.remove(item);
      var box = Hive.box('myBox');
      box.put('list', list);
    });
  }

  @override
  void initState() {
    fetch();
    super.initState();
  }

  fetch() async {
    var box = await Hive.openBox("myBox");
    // var box = Hive.box('myBox');
    var myList = box.get('list');
    List<Map<String, dynamic>> newList = [];
    if (myList != null) {
      myList.forEach((each) => newList.add(
          {"id": each["id"], "title": each["title"], "date": each["date"]}));
    }

    setState(() {
      list = newList;
    });
    print("MY LIST ISSSSSSSSSSSS ${list}");
  }

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(5.0),
      borderSide: BorderSide(
        color: Colors.grey.shade600,
        width: 1,
      ),
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "To Do List",
          style: TextStyle(fontSize: 16),
        ),
        toolbarHeight: 50,
        backgroundColor: const Color(0xffa467d9),
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: ListView(
          children: [
            TextFormField(
              onChanged: (e) {
                title = e;
              },
              controller: controller,
              decoration: InputDecoration(
                isDense: true,
                hintText: "Enter your to do",
                fillColor: Colors.white,
                focusedBorder: inputBorder,
                enabledBorder: inputBorder,
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                setState(() {
                  showDatePicker = true;
                });
              },
              child: Container(
                height: 50,
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade600),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(date),
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 20,
                    )
                  ],
                ),
              ),
            ),
            showDatePicker
                ? SfDateRangePicker(
                    initialSelectedDate:
                        isEdit ? DateTime.parse(date) : DateTime(2022),
                    onSubmit: (object) {
                      if (object == null) {
                        _showMyDialog(context);
                      } else {
                        date = object.toString();
                        setState(() {
                          showDatePicker = false;
                        });
                      }
                    },
                    onCancel: () {
                      setState(() {
                        showDatePicker = false;
                      });
                    },
                    view: DateRangePickerView.year,
                    confirmText: "OK",
                    cancelText: "Cancel",
                    showActionButtons: true,
                  )
                : const SizedBox.shrink(),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                handleSubmit();
              },
              style: ButtonStyle(
                  padding: MaterialStateProperty.all(
                      const EdgeInsets.symmetric(horizontal: 20)),
                  backgroundColor:
                      MaterialStateProperty.all(const Color(0xffa467d9))),
              child: Text(
                isEdit ? "Edit" : "Add To Do",
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            list.isEmpty
                ? const Center(child: Text("No to do"))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: list
                        .map((e) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 5),
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 1,
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(e["title"]),
                                    const SizedBox(height: 5),
                                    Text(
                                      e["date"],
                                      style: const TextStyle(
                                          fontSize: 11, color: Colors.grey),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        handleEdit(
                                            e["id"], e["title"], e["date"]);
                                      },
                                      icon: Icon(
                                        Icons.edit_outlined,
                                        color: Colors.amber.shade600,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        handleDelete(e["id"]);
                                      },
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.redAccent,
                                      ),
                                    )
                                  ],
                                )
                              ],
                            )))
                        .toList(),
                  ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showMyDialog(context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Error'),
        content: SingleChildScrollView(
          child: ListBody(
            children: const <Widget>[
              Text('Date can not be empty'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
