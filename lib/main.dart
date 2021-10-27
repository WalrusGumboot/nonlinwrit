import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(mainApp());
}

Widget mainApp() {
  return MaterialApp(
    theme: ThemeData(
      primarySwatch: Colors.red,
      brightness: Brightness.light,
      textTheme: GoogleFonts.sourceSansProTextTheme()
    ),

    home: const HomeScreen(),
  );
}

class Section {
  String title    = "New Section";
  String desc     = "A newly created section which doesn't yet contain anything.";
  String content  = "";
  bool   selected = false;
  
  late Key key;

  Section({required this.key, required this.title, required this.desc, this.selected = false});

  void select()   {selected = true;}
  void deselect() {selected = false;}
}



class HomeScreen extends StatefulWidget {
  @override
  HomeScreenState createState() => HomeScreenState();

  const HomeScreen({Key? key}) : super(key: key);
}



Section? possiblyGetSelectedSection(List<Section> s) {
  /// Gets all sections from a list and returns either the selected one or null if there is no section selected.
  if (s.any((element) => element.selected)) return s.firstWhere((element) => element.selected);
  return null;
}


class HomeScreenState extends State<HomeScreen> {
  late List<Section> sections;

  @override
  void initState() {
    super.initState();
    sections = [
      // Section(
      //   key: const ValueKey("test_section"),
      //   title: "Test section", 
      //   desc: "This section is here to test out functionality.",
      //   //selected: true
      // ),
      // Section(
      //   key: const ValueKey("test_section_2"),
      //   title: "Test section 2", 
      //   desc: "This section is here to test out functionality too."
      // ),
      // Section(
      //   key: const ValueKey("test_section_3"),
      //   title: "Test section 3", 
      //   desc: "This section is here to test out functionality as well, how lovely!",
      // ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    Section? selectedSection = possiblyGetSelectedSection(sections); //this might be null

    TextEditingController editSectionTitleCtrl = TextEditingController();
    TextEditingController editSectionDescCtrl  = TextEditingController();
    TextEditingController writtenTextCtrl      = TextEditingController();


    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Nonlinear Writing App", 
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24)),
      ),
      body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Row(
              children: [
                //list with sections
                Flexible(
                  flex: 1,
                  child: ReorderableListView(
                    buildDefaultDragHandles: false,
                    children: List.generate(sections.length, (index) {
                      Section el = sections[index];
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 12.0),
                        key: el.key,
                        child: ReorderableDragStartListener(
                          index: index,
                          child: InkWell(
                            onTap: () {
                              List<Section> newSections = sections;
                              
                              if (el.selected) {
                                newSections[index].deselect();
                              } else {
                                for (Section s in newSections) {
                                  if (s.key != el.key) {s.deselect();}
                                }
                                newSections[index].select();
                              }

                              
                              setState(() {
                                sections = newSections;
                              });
                            },
                            child: Container(
                          
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(color: Theme.of(context).primaryColor),
                                color: el.selected ? 
                                  Theme.of(context).primaryColor :
                                  Theme.of(context).primaryColorLight,
                              ),
                          
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(12.0, 0.0, 0.0, 0.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        el.title, 
                                        style: Theme.of(context).textTheme.headline6!.apply(
                                          color: el.selected ? Colors.white : Colors.black,
                                          fontWeightDelta: el.selected ? 500 : 0
                                        ),
                                        overflow: TextOverflow.fade,
                                      ),
                                    ),
                                    Flexible(
                                      child: Text(
                                        el.desc, 
                                        style: TextStyle(color: el.selected ? Colors.white : Colors.black),
                                        overflow: TextOverflow.fade
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ),
                          ),
                        ),
                      );
                    })..add(
                      InkWell(
                        key: UniqueKey(),
                        onTap: () {setState(() {
                          sections.add(Section(
                            title: "New Section", 
                            desc: "A new section, full of potential.",
                            key: UniqueKey()));
                        });},
                        child: Container(
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: Theme.of(context).primaryColor),
                            //color: Theme.of(context).primaryColorLight,
                            color: Colors.white
                          ),
                          child: Center(child: Icon(
                            Icons.add, 
                            color: Theme.of(context).primaryColor,
                            size: 40.0,
                          )),
                        ),
                      )
                    ), 
                    onReorder: (int oldIndex, int newIndex) {
                      setState(() {
                        if (oldIndex < newIndex) {
                          newIndex -= 1;
                        }
                        final Section item = sections.removeAt(oldIndex);
                        sections.insert(newIndex, item);
                      });
                    }
                  ),
                ),

                const VerticalDivider(color: Colors.grey),

                //editing area
                Flexible(
                  flex: 2,
                  child: Container(
                    child: Center(
                      child: Builder( builder: (BuildContext context) {
                        if (selectedSection != null) {
                            writtenTextCtrl.text      = selectedSection.content;

                            editSectionTitleCtrl.text = selectedSection.title;
                            editSectionDescCtrl.text  = selectedSection.desc;

                            return Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          selectedSection.title, 
                                          style: Theme.of(context).textTheme.headline5,
                                          overflow: TextOverflow.ellipsis
                                        )
                                      ),
                                      ElevatedButton(
                                        child: Text("EDIT SECTION"),
                                        onPressed: () {
                                          showDialog(
                                            context: context, 
                                            builder: (context) {
                                              return AlertDialog(
                                                title: Text("Edit Section Info"),
                                                content: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    TextField(
                                                      decoration: InputDecoration(
                                                        hintText: "Title",
                                                        border: OutlineInputBorder()
                                                      ),
                                                      controller: editSectionTitleCtrl
                                                    ),
                                                    SizedBox(height: 8),
                                                    TextField(
                                                      decoration: InputDecoration(
                                                        hintText: "Description",
                                                        border: OutlineInputBorder()
                                                      ),
                                                      controller: editSectionDescCtrl
                                                    )
                                                  ],
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context), 
                                                    child: Text("CANCEL")
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        List<Section> newSections = sections;
                                                        Section newElement = newSections.firstWhere((element) => element.selected);

                                                        newElement.title = editSectionTitleCtrl.text;
                                                        newElement.desc  = editSectionDescCtrl.text;

                                                        sections = newSections;
                                                      });



                                                      Navigator.pop(context);

                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        new SnackBar(content: Text("Updated the section information."))
                                                      );
                                                    }, 
                                                    child: Text("SAVE")
                                                  )
                                                ],
                                              );
                                            });
                                        },
                                      )
                                    ],
                                  ),
                                  Divider(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  Expanded(
                                    child: TextField(
                                      controller: writtenTextCtrl,

                                      minLines: null,
                                      maxLines: null,
                                      expands: true,

                                      textAlignVertical: TextAlignVertical.top,

                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.all(8),
                                        fillColor: Colors.white,
                                        filled: true,
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                                        hintText: "Start writing!"
                                      )
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        List<Section> newSections = sections;
                                        Section newElement = newSections.firstWhere((element) => element.selected);

                                        newElement.content = writtenTextCtrl.text;

                                        sections = newSections;

                                        ScaffoldMessenger.of(context).showSnackBar(
                                          new SnackBar(content: Text("Saved your precious work!"))
                                        );
                                      });
                                    }, 
                                    icon: Icon(Icons.save), 
                                    label: Text("SAVE")
                                  )
                                ],
                              ),
                            );
                          } else {
                            return Text("Select a section to start writing!");
                          }
                      })
                    ),
                    color: Theme.of(context).primaryColorLight,
                  ),
                )
              ],
            ),
          ),
        
      ),
    );
  }
}
