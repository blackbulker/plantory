import 'package:flutter/material.dart';
import 'package:plantory/views/plant/plant_add_page.dart';
import 'package:plantory/views/plant/plant_detail_page.dart';
import 'package:unicons/unicons.dart';

import '../../../utils/colors.dart';
import '../../data/plant.dart';

class PlantsPage extends StatefulWidget {

  const PlantsPage({Key? key,required this.plantList}) : super(key: key);

  final List<Plant> plantList;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _PlantsPage();
  }
}

class _PlantsPage extends State<PlantsPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffEEF1F1),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: Color(0xffEEF1F1),
        title: const Text(
          "Plants",
          style: TextStyle(color: primaryColor),
        ),
      ),
      body: Column(
        children: [
          Expanded(
              child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  itemCount: widget.plantList.length,
                  itemBuilder: (context, index) =>
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          decoration: BoxDecoration(
                              color: const Color(0xffE5E6E0),
                              borderRadius: BorderRadius.circular(15)),
                          child: ListTile(
                            // mainAxisAlignment: MainAxisAlignment.spaceAround,
                            leading: CircleAvatar(
                              radius: MediaQuery.of(context).size.height * 0.03,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: const Center(
                                    child: Icon(
                                      UniconsLine.flower,
                                      size: 32,
                                    )
                                ),
                              ),
                            ),
                            title: Text("${widget.plantList[index].name}"),
                            onTap: (){
                              Navigator.of(context).push(MaterialPageRoute(builder:
                                  (context) => PlantDetailPage(plant: widget.plantList[index])));
                            },
                          ),
                        ),
                      ))
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: ((context) =>
              PlantAddPage(plantList: widget.plantList))));
        },
        heroTag: null,
        child: Icon(Icons.add, size: 40,),),
    );
  }
}

