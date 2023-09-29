import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

var checked_ = false;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://naldpmdkzdqtqbawaddf.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5hbGRwbWRremRxdHFiYXdhZGRmIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTU5NjIzMzEsImV4cCI6MjAxMTUzODMzMX0.eINagiA4yi1KzIKLMIhKYbuwzYZNoZBWykitfLbg6xc',//SUPABASE_ANON_KEY,
  );
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title:'Tareas',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State <MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
{
  final _tareasStream=Supabase.instance.client.from('tareas').stream(primaryKey: ['id']);
  var newTitle, newName;
  bool isChecked = false;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _titleController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.task),
            Text('TAREAS'),
          ],
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _tareasStream, 
        builder: (context, snapshot) {
          if(!snapshot.hasData){
            return const Center(child: CircularProgressIndicator());
          }
          final tareas = snapshot.data!;
          print(tareas);
          return ListView.separated(
            itemCount: tareas.length,
            itemBuilder: (context, index){
              return Container(
                height: 150,
                padding: EdgeInsets.all(16.0),
                child:Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 50,
                      child: Text(tareas[index]['id']),
                    ),
                    Container(
                      width: 150,
                      child: Text(tareas[index]['titulo']),
                    ),
                    Container(
                      width: 150,
                      child: Text(tareas[index]['descripcion']),
                    ),
                    Container(
                      width: 40,
                      child: Text(tareas[index]['completada'].toString()),
                    ),
                    IconButton(onPressed: (){
                      _nameController.text=tareas[index]['descripcion'];
                      _titleController.text=tareas[index]['titulo'];
                      checked_=tareas[index]['completada'];
                      newTitle=tareas[index]['titulo'];
                      newName=tareas[index]['descripcion'];
                      showDialog(
                        context: context,
                        builder: ((context) {
                          return SimpleDialog(
                            title: const Text('Editar tarea'),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                            children: [
                              TextFormField(
                                controller: _titleController,
                                decoration: InputDecoration(
                                  labelText: 'Título',
                                ),
                                onChanged: (value) async {
                                  newTitle=value;
                                },
                              ),
                              TextFormField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  labelText: 'Descripcion',
                                ),
                                onChanged: (value) async {
                                  newName=value;
                                },
                              ),
                              Row(
                                children: [
                                  CheckboxExample(),
                                  Text('Completada'),
                                ],
                              ),
                              FloatingActionButton(onPressed: (){
                              var response = Supabase.instance.client
                                                  .from('tareas')
                                                  .update({'titulo':newTitle, 'descripcion':newName, 'completada':checked_})
                                                  .eq('id',tareas[index]['id'])
                                                  .execute();
                                setState(() {
                                  
                                });
                              },child:Icon(Icons.done),),
                            ],
                          );
                        }),
                      );
                      setState(() {
                        
                      });
                    }, icon: Icon(Icons.update)),
                    IconButton(onPressed: (){
                      
                      var response = Supabase.instance.client
                                          .from('tareas')
                                          .delete()
                                          .eq('id',tareas[index]['id'])
                                          .execute();
                      print(response);
                      setState(() {
                        
                      });
                    }, icon: Icon(Icons.delete)),
                  ],
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) => const Divider(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: ((context) {
              return SimpleDialog(
                title: const Text('Añadir tarea'),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Título',
                    ),
                    onChanged: (value) async {
                      newTitle=value;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'descripcion',
                    ),
                    onChanged: (value) async {
                      newName=value;
                    },
                  ),
                  FloatingActionButton(onPressed: (){
                    addData(newName, newTitle);
                    setState(() {
                      
                    });
                  },child:Icon(Icons.add),),
                ],
              );
            }),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  addData(String name, String title) {
    var response = Supabase.instance.client
                        .from('tareas')
                        .insert({'titulo':title, 'descripcion':name})
                        .execute();
    print(response);
  }

  readData() async {
    var response = await Supabase.instance.client
                        .from('tareas')
                        .select()
                        .order('id', ascending: true)
                        .execute();
    print(response);
    final dataList = response.data as List;
    return dataList;
  }


}

class CheckboxExample extends StatefulWidget {
  const CheckboxExample({super.key});

  @override
  State<CheckboxExample> createState() => _CheckboxExampleState();
}
class _CheckboxExampleState extends State<CheckboxExample> {

  bool isChecked = checked_;
  @override
  Widget build(BuildContext context) {
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.blue;
      }
      return Colors.red;
    }

    return Checkbox(
        checkColor: Colors.white,
        value: isChecked,
        onChanged: (value) {
          setState(() {
            isChecked = value!;
            checked_=isChecked!;
            print({'checked: ', checked_});
          });
        },
    );
  }
}