import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_apis/functions/databaseFunctions.dart';
import 'package:flutter_apis/pages/pets.dart';

class DatabaseOptions extends StatefulWidget{
 const DatabaseOptions({super.key});
 @override
 _DatabaseOptionsState createState() =>_DatabaseOptionsState();
  
}
class _DatabaseOptionsState extends State<DatabaseOptions>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("database options"),
      actions: [
        IconButton(onPressed:() async{
          await FirebaseAuth.instance.signOut();
        }, icon: const Icon(Icons.logout))
      ],
      ),
      body: Center(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: (){
                create('','','','',5);
              }, child: const Text("create")),
              
              const SizedBox(
                height: 10,
              ),

              ElevatedButton(onPressed: (){
                update('pets','Tom','age',14);
              }, child: const Text("update")),
              const SizedBox(
                height: 10,
              ),
                ElevatedButton(onPressed: (){	
                Navigator.push(context, MaterialPageRoute(builder: (context) => const Petslist())); 
              }, child: const Text("view")),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(onPressed: (){
                delete('pets','Tom');
              }, child: const Text("delete")),
            ],
          ),
        ),
      ),
    
    );
  }

}