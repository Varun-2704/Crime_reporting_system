
import 'package:cloud_firestore/cloud_firestore.dart';

create(String collectionName,docName,name,animal,int age) async{
  await FirebaseFirestore.instance.collection('pets').doc('tom').set({
    'name':'Tom','animal':'dog','age':12
  });
  print('database updated');
}

update(String collectionName,docName,field,var fieldvalue) async{
  await FirebaseFirestore.instance.collection(collectionName).doc(docName).update({field:fieldvalue});
  print('Update successfull');
}

delete(String collectionName,docName) async{
  await FirebaseFirestore.instance.collection(collectionName).doc(docName).delete();
  print('deleted');
}