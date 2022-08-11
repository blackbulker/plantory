import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/instance_manager.dart';
import 'package:get/route_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:plantory/views/community/community_page.dart';
import 'package:unicons/unicons.dart';
import '../../../data/plant.dart';
import '../../../utils/colors.dart';
import '../../data/person.dart';
import '../calendar/calendar_page.dart';
import '../notification/notification.dart';

class HomePage extends StatefulWidget{

  HomePage({Key? key, required this.person}) : super(key: key);

  final Person person;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _HomePage();
  }

}

class _HomePage extends State<HomePage> with TickerProviderStateMixin{

  PlantNotification plantNotification = PlantNotification();

  final PageController pageController = PageController(initialPage: 0,viewportFraction: 0.85);

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  late AnimationController _controller;

  static const List<IconData> floatingIcons = [ Icons.calendar_month_outlined, Icons.comment ];

  bool isEditable = false;
  bool isNewPlant = false;

  int pageIndex = 0;

  bool isOpen = false;

  final TextEditingController newNameController = TextEditingController();
  final TextEditingController newTypeController = TextEditingController();
  final TextEditingController newDateController = TextEditingController();

  final TextEditingController newWateringStartDateController = TextEditingController();
  final TextEditingController newWateringCycleController = TextEditingController();

  var newImage;

  Map newCycles = {
      Cycles.id.name : 0,
      Cycles.type.name : "물",
      Cycles.cycle.name : 14,
      Cycles.startDate.name : DateFormat('yyyy-MM-dd').format(DateTime.now()),
      Cycles.initDate.name : DateFormat('yyyy-MM-dd').format(DateTime.now()),
    };

  @override
  void initState() {

    newDateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());

    newWateringStartDateController.text = newCycles[Cycles.startDate.name];
    newWateringCycleController.text = newCycles[Cycles.cycle.name].toString();

    newCycles[Cycles.id.name] = generateCycleID(widget.person.plants!);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    if(widget.person.plants!.isEmpty){
      isNewPlant = true;
    }

    return Scaffold(
      backgroundColor: Color(0xffEEF1F1),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          PageView.builder(
              physics: isEditable ? NeverScrollableScrollPhysics() : null,
              itemCount: widget.person.plants!.length +1,
              pageSnapping: true,
              controller: pageController,
              onPageChanged: (index){

                pageIndex = index;
                  if(!isNewPlant && index > widget.person.plants!.indexOf(widget.person.plants!.last)){
                    setState(() {
                      isNewPlant = true;
                    });
                  }else if(isNewPlant){
                    setState(() {
                      isNewPlant = false;
                      FocusScope.of(context).unfocus();
                    });
                  }
              },
              itemBuilder: (context, index) {

                final TextEditingController nameController = TextEditingController();
                final TextEditingController typeController = TextEditingController();
                final TextEditingController dateController = TextEditingController();
                final TextEditingController noteController = TextEditingController();

                final TextEditingController wateringStartDateController = TextEditingController();
                final TextEditingController wateringCycleController = TextEditingController();

                var image;

                late String beforeName;
                late String beforeType;

                if(widget.person.plants!.isNotEmpty && index <= widget.person.plants!.indexOf(widget.person.plants!.last)){

                  beforeName = widget.person.plants![index]!.name!;
                  beforeType = widget.person.plants![index]!.type!;

                  nameController.text = widget.person.plants![index]!.name!;
                  typeController.text = widget.person.plants![index]!.type!;
                  if(widget.person.plants![index]!.note != null) noteController.text = widget.person.plants![index]!.note!;
                  dateController.text = widget.person.plants![index]!.date!;

                  wateringStartDateController.text = widget.person.plants![index]!.watering![Cycles.startDate.name];
                  wateringCycleController.text = widget.person.plants![index]!.watering![Cycles.cycle.name].toString();

                }

                return Container(
                  margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.08,
                      left: 5,right: 5,bottom: MediaQuery.of(context).size.height * 0.1),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.01,
                            bottom: MediaQuery.of(context).size.height * 0.01,
                            left: 18,
                            right: 18,
                        ),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                IntrinsicWidth(
                                  child: widget.person.plants!.isNotEmpty && index <= widget.person.plants!.indexOf(widget.person.plants!.last) ? TextFormField(
                                    autofocus: false,
                                    controller: nameController,
                                    maxLines: 1,
                                    maxLength: 5,
                                    readOnly: !isEditable,
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      border: isEditable ? null : InputBorder.none,
                                      counterText: "",
                                      hintStyle: const  TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
                                      hintText: widget.person.plants![index]!.name!,
                                    ),
                                    onChanged: (value){
                                      if(value != ""){
                                        widget.person.plants![index]!.name = value;
                                      }else{
                                        widget.person.plants![index]!.name = beforeName;
                                      }
                                    },
                                  ) : TextFormField(
                                    autofocus: false,
                                    controller: newNameController,
                                    maxLines: 1,
                                    maxLength: 5,
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      counterText: "",
                                      hintStyle: const  TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
                                      hintText: "이름",
                                    ),
                                  )
                                ),
                                Text(" | "),
                                IntrinsicWidth(
                                  child: widget.person.plants!.isNotEmpty && index <= widget.person.plants!.indexOf(widget.person.plants!.last) ? TextFormField(
                                    autofocus: false,
                                    controller: typeController,
                                    maxLines: 1,
                                    maxLength: 25,
                                    readOnly: !isEditable,
                                    decoration: InputDecoration(
                                        isDense: true,
                                        border: isEditable ? null : InputBorder.none,
                                        counterText: "",
                                        hintText: widget.person.plants![index]!.type!
                                    ),
                                    onChanged: (value){
                                      if(value != ""){
                                        widget.person.plants![index]!.type = value;
                                      }else{
                                        widget.person.plants![index]!.type = beforeType;
                                      }
                                    },
                                  ) : TextFormField(
                                    autofocus: false,
                                    controller: newTypeController,
                                    maxLines: 1,
                                    maxLength: 25,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      counterText: "",
                                      hintText: "식물 종류",
                                    ),
                                  )
                                ),
                              ],
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.05,
                              child: widget.person.plants!.isNotEmpty && index <= widget.person.plants!.indexOf(widget.person.plants!.last) ? Row(
                                children: [
                                  Text("${widget.person.plants![index]!.name!}와 함께한지 ",),
                                  Text("${DateFormat('yyyy-MM-dd')
                                      .parse(DateTime.now().toString()).difference(DateFormat('yyyy-MM-dd')
                                      .parse(widget.person.plants![index]!.date!)).inDays}일이 지났어요!",
                                    style: TextStyle(fontWeight: FontWeight.w500),)
                                ],
                              ) : Container(),
                            ),
                          ],
                        )
                      ),
                     Expanded(
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Stack(
                            children: [
                               Align(
                                alignment: Alignment.center,
                                child: widget.person.plants!.isNotEmpty && index <= widget.person.plants!.indexOf(widget.person.plants!.last) ? Image.asset("assets/images/default_plant6_512.png",
                                  width: MediaQuery.of(context).size.width * 0.4,) : Icon(Icons.add_a_photo_outlined),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height * 0.05,
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 18,left: 18),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          GestureDetector(
                                            onTap: () async{
                                              if(isEditable){
                                                await showCupertinoModalPopup(
                                                    context: context,
                                                    builder: (BuildContext builder) {
                                                      return Container(
                                                        height: MediaQuery.of(context).copyWith().size.height*0.25,
                                                        color: Colors.white,
                                                        child: CupertinoDatePicker(
                                                          initialDateTime: DateFormat('yyyy-MM-dd').parse(dateController.text), //초기값
                                                          maximumDate: DateTime.now(), //마지막일
                                                          mode: CupertinoDatePickerMode.date,
                                                          onDateTimeChanged: (value) {
                                                            if (DateFormat('yyyy-MM-dd').format(value) != dateController.text) {
                                                                setState(() {
                                                                  dateController.text = DateFormat('yyyy-MM-dd').format(value);
                                                                  widget.person.plants![index]!.date = DateFormat('yyyy-MM-dd').format(value);
                                                                });
                                                            }
                                                          },
                                                        ),
                                                      );
                                                    }
                                                ).then((value) {
                                                  setState(() {});
                                                });
                                              }else if(isNewPlant){
                                                await showCupertinoModalPopup(
                                                    context: context,
                                                    builder: (BuildContext builder) {
                                                      return Container(
                                                        height: MediaQuery.of(context).copyWith().size.height*0.25,
                                                        color: Colors.white,
                                                        child: CupertinoDatePicker(
                                                          initialDateTime:  DateFormat('yyyy-MM-dd').parse(newDateController.text),
                                                          maximumDate: DateTime.now(), //마지막일
                                                          mode: CupertinoDatePickerMode.date,
                                                          onDateTimeChanged: (value) {
                                                            if (DateFormat('yyyy-MM-dd').format(value) != newDateController.text) {
                                                              newDateController.text = DateFormat('yyyy-MM-dd').format(value);
                                                            }
                                                          },
                                                        ),
                                                      );
                                                    }
                                                ).then((value) {
                                                  setState(() {});
                                                });
                                              }
                                            },
                                            child: Row(
                                              children: [
                                                isNewPlant ? Text(newDateController.text,
                                                  style: TextStyle(color: Color(0xff404040),fontWeight: FontWeight.bold),)
                                                    : Text(dateController.text != "" ? dateController.text : DateFormat('yyyy-MM-dd').format(DateTime.now()) ,
                                                  style: TextStyle(color: Color(0xff404040),fontWeight: FontWeight.bold),),
                                                isEditable || isNewPlant ? Padding(
                                                  padding: const EdgeInsets.only(right: 8, left: 8),
                                                  child: Icon(
                                                      Icons.edit_note,
                                                      size: MediaQuery.of(context).size.width * 0.05,
                                                      color: Color(0xff404040)),
                                                ) : Container(),
                                              ],
                                            ),
                                          ),
                                          !isEditable && !isNewPlant ? PopupMenuButton<String>(
                                            child: Container(
                                              width: MediaQuery.of(context).size.width * 0.1,
                                              alignment: Alignment.centerRight,
                                              child: Icon(
                                                Icons.more_vert,color: Colors.black54,
                                              ),
                                            ),
                                            onSelected: (value){
                                              switch (value) {
                                                case '수정':
                                                  setState((){
                                                    isEditable = true;
                                                  });
                                                  break;
                                                case '정보':
                                                  break;
                                                case '삭제':
                                                  showDialog(barrierColor: Colors.black54, context: context, builder: (context) {
                                                    return CupertinoAlertDialog(
                                                      title: const Text("식물 삭제"),
                                                      content: Padding(
                                                        padding: const EdgeInsets.only(top: 8),
                                                        child: Text("\"${widget.person.plants![index]!.name}\"를 삭제하시겠습니까?"),
                                                      ),
                                                      actions: [
                                                        CupertinoDialogAction(isDefaultAction: false, child: Text("취소"), onPressed: () {
                                                          Navigator.pop(context);
                                                        }),
                                                        CupertinoDialogAction(isDefaultAction: false, child: const Text("확인",style: TextStyle(color: Colors.red),),
                                                            onPressed: () async {

                                                              plantNotification.cancel(widget.person.plants![index]!.watering![Cycles.id.name]);

                                                              widget.person.plants!.remove(widget.person.plants![index]!);
                                                              var usersCollection = firestore.collection('users');
                                                              await usersCollection.doc(widget.person.uid).update(
                                                                  {
                                                                    "plants": widget.person.plantsToJson(widget.person.plants!)
                                                                  }).then((value) {
                                                               setState(() {});
                                                               pageController.animateToPage(index-1, duration: Duration(milliseconds: 300), curve: Curves.ease);
                                                               Get.back();
                                                              });
                                                            }
                                                        ),
                                                      ],
                                                    );
                                                  });
                                                  break;
                                              }
                                            },
                                            itemBuilder: (context) => [
                                              PopupMenuItem<String>(
                                                height: MediaQuery.of(context).size.height * 0.05,
                                                value: '수정',
                                                child	: Text('수정'),
                                              ),
                                              PopupMenuDivider(),
                                              PopupMenuItem<String>(
                                                height: MediaQuery.of(context).size.height * 0.05,
                                                value: '정보',
                                                child: Text('정보'),
                                              ),
                                              PopupMenuDivider(),
                                              PopupMenuItem<String>(
                                                height: MediaQuery.of(context).size.height * 0.05,
                                                value: '삭제',
                                                child: Text('삭제'),
                                              ),
                                            ],
                                          ) : Container(),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 18,left: 18),
                                      child: GestureDetector(
                                        onTap: (){
                                          if(isEditable || isNewPlant){
                                            var picker = ImagePicker();
                                            showCupertinoModalPopup(
                                              barrierColor: Colors.black54,
                                              context: context,
                                              builder: (BuildContext context) => Padding(
                                                padding: const EdgeInsets.only(left: 16,right: 16),
                                                child: CupertinoActionSheet(
                                                    actions: <Widget>[
                                                      CupertinoActionSheetAction(
                                                        child: const Text('갤러리에서 가져오기'),
                                                        onPressed: () async{
                                                          await picker.pickImage(source: ImageSource.gallery,maxWidth: 1024, maxHeight: 1024)
                                                              .then((value) async{
                                                            image = await value?.readAsBytes();
                                                            setState(() {
                                                              if(isEditable){
                                                                widget.person.plants![index]!.image = base64Encode(image);
                                                              }else if(isNewPlant){
                                                                newImage =  base64Encode(image);
                                                              }
                                                            });
                                                            Get.back();
                                                          });
                                                        },
                                                      ),
                                                      CupertinoActionSheetAction(
                                                        child: const Text('사진 찍기'),
                                                        onPressed: () async{
                                                          await picker.pickImage(source: ImageSource.camera,maxWidth: 1024, maxHeight: 1024)
                                                              .then((value) async{
                                                            image = await value?.readAsBytes();
                                                            setState(() {
                                                              if(isEditable){
                                                                widget.person.plants![index]!.image = base64Encode(image);
                                                              }else if(isNewPlant){
                                                                newImage =  base64Encode(image);
                                                              }
                                                            });
                                                            Get.back();
                                                          });
                                                        },
                                                      )
                                                    ],
                                                    cancelButton: CupertinoActionSheetAction(
                                                      child: const Text('Cancel'),
                                                      isDefaultAction: true,
                                                      onPressed: () {
                                                        Navigator.pop(context, 'Cancel');
                                                      },
                                                    )),
                                              ),
                                            );
                                          }
                                        },
                                        child: widget.person.plants!.isNotEmpty && index <= widget.person.plants!.indexOf(widget.person.plants!.last) && widget.person.plants![index]!.image != null ? ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: Image.memory(base64Decode(widget.person.plants![index]!.image!), fit: BoxFit.cover,gaplessPlayback: true,),
                                        ) : newImage != null ? ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: Image.memory(base64Decode(newImage), fit: BoxFit.cover,gaplessPlayback: true,),
                                        ) : Container(
                                            height: MediaQuery.of(context).size.height,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(Radius.circular(10)),
                                              border: Border.all(color: Colors.black26),
                                            )
                                        )
                                      ),
                                    )
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 18, left: 18),
                                    child: Container(
                                      width: double.infinity,
                                      height: MediaQuery.of(context).size.height * 0.08,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                            bottomLeft:Radius.circular(10),
                                            bottomRight:Radius.circular(10)
                                        ),
                                      ),
                                      child: widget.person.plants!.isNotEmpty && index <= widget.person.plants!.indexOf(widget.person.plants!.last)
                                          ? wateringCycleTile(widget.person.plants![index]!.watering!, widget.person.plants![index]!.name!, wateringStartDateController, wateringCycleController)
                                          : wateringCycleTile(newCycles,nameController.text, newWateringStartDateController, newWateringCycleController),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        ),
                      )
                    ],
                  ),
                );
              }),
          isOpen ? GestureDetector(
              onTap: (){
                setState((){isOpen = !isOpen;});
                if (_controller.isDismissed) {
                  _controller.forward();
                } else {
                  _controller.reverse();
                }
              },
              child: Container(color: Colors.black26,)
          ) : Container()
        ],
      ),
      floatingActionButton: isEditable || isNewPlant ? FloatingActionButton.extended(
        backgroundColor: primaryColor,
        label: Text("완료"),
        icon: Icon(Icons.check),
        onPressed: () async{
          if(isEditable){

            var usersCollection = firestore.collection('users');
            await usersCollection.doc(widget.person.uid).update(
                {
                  "plants": widget.person.plantsToJson(widget.person.plants!)
                }).then((value) {

              plantNotification.zonedMidnightSchedule(widget.person.plants![pageIndex]!.watering![Cycles.id.name], "Plantory 알림",
                  "\"${widget.person.plants![pageIndex]!.name}\"에게 물을 줄 시간입니다!", getFastWateringDate(widget.person.plants![pageIndex]!.watering!));
            });
            setState(() {
              isEditable = false;
            });

          }else if(isNewPlant){

            if(newNameController.text == ""){
              showCupertinoDialog(context: context, builder: (context) {
                return CupertinoAlertDialog(
                  content: Text("식물 이름을 입력해주세요"),
                  actions: [
                    CupertinoDialogAction(isDefaultAction: true, child: Text("확인"), onPressed: () {
                      Navigator.pop(context);
                    })
                  ],
                );
              });
            }else if(newTypeController.text == ""){
              showCupertinoDialog(context: context, builder: (context) {
                return CupertinoAlertDialog(
                  content: Text("식물 종류를 입력해주세요"),
                  actions: [
                    CupertinoDialogAction(isDefaultAction: true, child: Text("확인"), onPressed: () {
                      Navigator.pop(context);
                    })
                  ],
                );
              });
            }else{

              setState(() {
                isNewPlant = false;
                var id = generateID(widget.person.plants!);
                widget.person.plants!.add(
                    Plant(
                      id: id,
                      pinned: false,
                      name: newNameController.text,
                      type: newTypeController.text,
                      date: newDateController.text,
                      note: null,
                      watering: newCycles,
                      image: newImage,
                      timelines: List.empty(growable: true),
                    )
                );
              });

              var usersCollection = firestore.collection('users');
              await usersCollection.doc(widget.person.uid).update(
                  {
                    "plants": widget.person.plantsToJson(widget.person.plants!)
                  }).whenComplete(() => pageController.jumpToPage(pageIndex+1)).then((value) {

                pageController.animateToPage(pageIndex-1, duration: Duration(milliseconds: 500), curve: Curves.ease).whenComplete(() {
                  plantNotification.zonedMidnightSchedule(newCycles[Cycles.id.name], "Plantory 알림",
                      "\"${newNameController.text}\"에게 물을 줄 시간입니다!", getFastWateringDate(widget.person.plants![pageIndex]!.watering!));
                });

                newNameController.text = "";
                newTypeController.text = "";
                newDateController.text = "";
                newImage = null;

                newDateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());

                newCycles = {
                  Cycles.id.name : 0,
                  Cycles.type.name : "물",
                  Cycles.cycle.name : 14,
                  Cycles.startDate.name : DateFormat('yyyy-MM-dd').format(DateTime.now()),
                  Cycles.initDate.name : DateFormat('yyyy-MM-dd').format(DateTime.now()),
                };

                newWateringStartDateController.text = newCycles[Cycles.startDate.name];
                newWateringCycleController.text = newCycles[Cycles.cycle.name].toString();

                newCycles[Cycles.id.name] = generateCycleID(widget.person.plants!);
                newCycles[Cycles.id.name] = generateCycleID(widget.person.plants!)+1;

              });

            }
          }
        },
      ) : Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(floatingIcons.length, (int index) {
          Widget child = Container(
            height: MediaQuery.of(context).size.height * 0.1,
            width: MediaQuery.of(context).size.width * 0.1,
            alignment: FractionalOffset.topCenter,
            child: ScaleTransition(
              scale: CurvedAnimation(
                parent: _controller,
                curve: Interval(
                    0.0, 1.0 - index / floatingIcons.length / 2.0, curve: Curves.easeOut
                ),
              ),
              child: FloatingActionButton(
                heroTag: null,
                backgroundColor: primaryColor,
                mini: true,
                child: Icon(floatingIcons[index],),
                onPressed: () {
                  setState((){
                    isOpen = false;
                    _controller.reverse();
                  });
                  switch(index){
                    case 0 :
                      Get.to(() => CalendarPage(person: widget.person));
                      break;
                    case 1 :
                      Get.to(() => CommunityPage(person: widget.person));
                      break;
                  }
                },
              ),
            ),
          );
          return child;
        }).toList()..add(
          AnimatedBuilder(
            animation: _controller,
            builder: (BuildContext context, Widget? child) {
              return FloatingActionButton.extended(
                backgroundColor: primaryColor,
                label: Text("Menu"),
                icon: Icon(_controller.isDismissed ? Icons.menu : Icons.close),
                heroTag: null,
                onPressed: () {
                  setState(() {
                    isOpen = !isOpen;
                  });
                  if (_controller.isDismissed) {
                    _controller.forward();
                  } else {
                    _controller.reverse();
                  }
                },
              );
            }
          ),
        ),
      ),
    );
  }

  Widget wateringCycleTile(Map cycles,String plantName, TextEditingController startDateController, TextEditingController cycleController){

    return GestureDetector(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.06,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left:8,top: 8,bottom: 8),
              child: Icon(Icons.water_drop,color: Color(0xff404040),)
            ),
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("물주기",style: TextStyle(color: Colors.black87))
            ),
            (isNewPlant || isEditable) ?  Icon(Icons.edit_note)
                : (DateFormat('yyyy-MM-dd').parse(cycles[Cycles.initDate.name]))
                .isBefore(DateFormat('yyyy-MM-dd').parse(DateTime.now().toString())) &&
                getFastWateringDate(cycles) == cycles[Cycles.cycle.name]
          ? Row(
             children: [
              IconButton(
                onPressed: () async{
                  setState((){
                    cycles[Cycles.initDate.name]
                    = DateFormat('yyyy-MM-dd').format(DateTime.now()
                        .add(Duration(days: int.parse(cycles[Cycles.cycle.name].toString()))));
                  });
                  var usersCollection = firestore.collection('users');
                  await usersCollection.doc(widget.person.uid).update(
                      {
                        "plants": widget.person.plantsToJson(widget.person.plants!)
                      });

                  plantNotification.zonedMidnightSchedule(cycles[Cycles.id.name], "Plantory 알림",
                      "\"$plantName\"에게 물을 줄 시간입니다!", getFastWateringDate(cycles));
                  /*
                  plantNotification.zonedMidnightSchedule(cycles[CycleType.repotting.index][Cycles.id.name], "Plantory 알림",
                      "\"$plantName\"의 분갈이 시간입니다!", getFastRepottingDate(cycles));
                   */

                  }, icon: Icon(Icons.check_circle_outline)),
               Text("< 물을 준 후 클릭")
            ],
          )
                : Padding(padding: const EdgeInsets.all(8.0), child: Text("D${-getFastWateringDate(cycles)}",
              style: TextStyle(fontWeight: FontWeight.bold,color: Color(0xff404040)),),
                )
          ],
        ),
      ),
      onTap: () async{
        if(isEditable || isNewPlant){
          await showDialog(context: context, barrierColor: Colors.black54,builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              contentPadding: EdgeInsets.only(right: 18,left: 18,top: 18),
              title: const Text("주기 설정"),
              content: SizedBox(
                height: MediaQuery.of(context).size.height * 0.2,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        readOnly: true,
                        controller: startDateController,
                        decoration: InputDecoration(
                          labelStyle: TextStyle(height:0.1),
                          labelText: "시작일",
                          hintText:  cycles[Cycles.startDate.name],
                        ),
                        onTap: () async{
                          await showCupertinoModalPopup(
                              context: context,
                              builder: (BuildContext builder) {
                                return Container(
                                  height: MediaQuery.of(context).copyWith().size.height*0.25,
                                  color: Colors.white,
                                  child: CupertinoDatePicker(
                                    initialDateTime: DateFormat('yyyy-MM-dd').parse(startDateController.text),
                                    maximumDate: DateTime.now(), //마지막일
                                    mode: CupertinoDatePickerMode.date,
                                    onDateTimeChanged: (value) {
                                      if (DateFormat('yyyy-MM-dd').format(value) != startDateController.text) {
                                        startDateController.text = DateFormat('yyyy-MM-dd').format(value);
                                      }
                                    },
                                  ),
                                );
                              });
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextField(
                        controller: cycleController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelStyle: const TextStyle(height:0.1),
                          labelText: "주기(일)",
                          hintText: cycles[Cycles.cycle.name].toString(),
                        ),
                        onTap: () async{
                          await showCupertinoModalPopup(
                              context: context,
                              builder: (BuildContext builder) {
                            return SizedBox(
                              height: 200,
                              child: Center(
                                child: CupertinoPicker(
                                  scrollController: FixedExtentScrollController(initialItem:  int.parse(cycleController.text)-1),
                                  backgroundColor: Colors.white,
                                  onSelectedItemChanged: (value){
                                    cycleController.text = (value+1).toString();
                                  },
                                  itemExtent: 32,
                                  diameterRatio:1,
                                  children: List.generate(100, (index) => Text("${index+1}일 마다")),
                                ),
                              ),
                            );
                          });
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('취소'),
                  onPressed: () {
                      Get.back();
                    },
                ),
                TextButton(
                  child: const Text('확인',style: TextStyle(color: Colors.red)),
                  onPressed: () async{
                    if(cycleController.text == "0"){
                      await showCupertinoDialog(context: context, builder: (context) {
                        return CupertinoAlertDialog(
                          content: Text("0보다 큰 값을 입력해주세요"),
                          actions: [
                            CupertinoDialogAction(isDefaultAction: true, child: Text("확인"), onPressed: () {
                              Navigator.pop(context);
                            })
                          ],
                        );
                      });
                    }else{
                      setState(() {
                        cycles[Cycles.startDate.name] = startDateController.text;
                        cycles[Cycles.initDate.name] = startDateController.text;
                        cycles[Cycles.cycle.name] = int.parse(cycleController.text);
                      });
                      Get.back();
                    }
                  },
                ),
              ],
            );
          });
        }
      },
    );
  }

}

int getFastWateringDate(Map cycles){
  for(int i = 0; DateFormat('yyyy-MM-dd').parse(cycles[Cycles.startDate.name]).add(Duration(days: i))
      .isBefore(DateTime(DateTime.now().year+1).subtract(Duration(days: 1))); i+= int.parse(cycles[Cycles.cycle.name].toString())){

    if(DateFormat('yyyy-MM-dd').parse(DateTime.now().toString()).isBefore( DateFormat('yyyy-MM-dd')
        .parse(cycles[Cycles.startDate.name]).add(Duration(days: i)))){

      return  DateFormat('yyyy-MM-dd').parse(cycles[Cycles.startDate.name]).add(Duration(days: i))
          .difference(DateFormat('yyyy-MM-dd').parse(DateTime.now().toString())).inDays;

    }

  }
  return 0;
}
