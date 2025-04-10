import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Petslist extends StatefulWidget{
 const Petslist({super.key});
 @override
 _Petslist createState() =>_Petslist();
}
class _Petslist extends State<Petslist>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('data'),
      ),
      body: Container(
        margin: const EdgeInsets.all(10),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('pets').snapshots(), builder:(context,petSnapshots){
          if (petSnapshots.connectionState ==ConnectionState.waiting){
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          else{
            final petDocs= petSnapshots.data!.docs;
            return ListView.builder(
              itemCount: petDocs.length,
              itemBuilder:(context , index){
            return Card(
              child: ListTile(
                title: Text(petDocs[index]['name']),
                subtitle: Text(petDocs[index]['animal']),
              ),
            );
            
            }
            );
          }
         } ),
      ),
    );
    }}