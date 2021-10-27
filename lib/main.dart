import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(mainApp());
}

Widget mainApp() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,

    theme: ThemeData(
      primarySwatch: Colors.red,
      brightness: Brightness.light,
      textTheme: GoogleFonts.sourceSansProTextTheme()
    ),

    home: const WritingScreen(),
    
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



class WritingScreen extends StatefulWidget {
  @override
  WritingScreenState createState() => WritingScreenState();

  const WritingScreen({Key? key}) : super(key: key);
}



Section? possiblyGetSelectedSection(List<Section> s) {
  /// Gets all sections from a list and returns either the selected one or null if there is no section selected.
  if (s.any((element) => element.selected)) return s.firstWhere((element) => element.selected);
  return null;
}

enum PreferredFont {
  serif,       // EB Garamond
  sans_serif,  // Source Sans Pro
  mono         // Fira Mono
}

TextStyle getStyle(PreferredFont f) {
  switch (f) {
    case PreferredFont.sans_serif:
      return GoogleFonts.sourceSansPro();
    case PreferredFont.serif:
      return GoogleFonts.ebGaramond();
    case PreferredFont.mono:
      return GoogleFonts.firaMono();
  }
}


class WritingScreenState extends State<WritingScreen> {
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

    PreferredFont font = PreferredFont.sans_serif;

    void setFont(PreferredFont f) {
      setState(() {
        print("Setting font to $f, was $font");
        font = f;
      });
    }


    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Nonlinear Writing App", 
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24)
        ),
        
        actions: [
          IconButton(
            icon: Icon(Icons.tune),
            tooltip: "Preferences",
            onPressed: () {
              PreferredFont newFontInMain = font;
              showDialog(context: context, builder: (context) {
                return StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    
                    // this function is defined inside of this builder so that
                    // setState has the proper context
                    Container fontSelection(PreferredFont f) {
                      String fontName = "";

                      switch (f) {
                        case PreferredFont.mono:
                          fontName = "Monospace";
                          break;
                        case PreferredFont.sans_serif:
                          fontName = "Sans-serif";
                          break;
                        case PreferredFont.serif:
                          fontName = "Serif";
                          break;
                        default:
                      }
                      
                      return Container(
                        child: Row(
                          children: [
                            Radio<PreferredFont>(
                              groupValue: font,
                              value: f,
                              onChanged: (PreferredFont? newFont) {
                                print(newFont);
                                setState(() {
                                  font = newFont!;
                                  newFontInMain = newFont;
                                });
                              },
                            ),
                            Text(fontName, style: getStyle(f)),
                          ],
                        ),
                      );
                    }

                    return AlertDialog(
                      title: Text("Preferences", style: Theme.of(context).textTheme.headline5),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: 1, width: 180),
                          Text("Font", style: Theme.of(context).textTheme.headline6),
                          fontSelection(PreferredFont.sans_serif),
                          fontSelection(PreferredFont.serif),
                          fontSelection(PreferredFont.mono),
                        ],
                      ),
                      actions: [
                        // TextButton(
                        //   child: Text("CANCEL"),
                        //   onPressed: () {Navigator.pop(context);},
                        // ),
                        ElevatedButton(
                          child: Text("SAVE"),
                          onPressed: () {
                            setFont(newFontInMain);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              new SnackBar(content: Text("Updated your preferences."))
                            );
                          },
                        )
                      ],
                    );
                  },
                );
              });
              // setState(() {
              //   font = newFontInMain;
              //   print("Should have updated the font to $newFontInMain, was $font");
              // });
            }
          ),
          SizedBox(width: 20)
        ],
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

                                      style: getStyle(font),

                                      textAlignVertical: TextAlignVertical.top,

                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.all(8),
                                        fillColor: Colors.white,
                                        filled: true,
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                                        hintText: "Start writing!",
                                        hintStyle: getStyle(font).apply(fontStyle: FontStyle.italic)
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
                                        print(font);
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
