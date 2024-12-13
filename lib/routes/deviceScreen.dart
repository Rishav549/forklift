import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:forklift/routes/forktracker.dart';
//import 'package:monitorapp/routes/analyticsScreen.dart';

class DeviceDetailsScreen extends StatefulWidget {
  final BluetoothDevice device;
  const DeviceDetailsScreen({super.key,required this.device});

  @override
  State<DeviceDetailsScreen> createState() => _DeviceDetailsScreenState();
}

class _DeviceDetailsScreenState extends State<DeviceDetailsScreen> {
  String command="";

  final TextEditingController _referNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(widget.device.platformName),
      ),
      body: StreamBuilder(
        stream: widget.device.connectionState,
        builder: (context,snapshot){
        if(snapshot.data == BluetoothConnectionState.disconnected){
          return Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              const Text("Your Device is Disconnected. Please connect again"),
              const SizedBox(height: 20,),
              ElevatedButton(onPressed: (){
                widget.device.connect();
              }, child: const Text("Connect"))
            ],)
            );
        }
        if(snapshot.data == BluetoothConnectionState.connected){
              return FutureBuilder<List<BluetoothService>>(
                future: widget.device.discoverServices(),
                builder: ((context, snapshot){
                  if(snapshot.connectionState == ConnectionState.waiting){
                    return Container(alignment: Alignment.center,child: const CircularProgressIndicator(),);
                  }
                  if(snapshot.hasData){
                    return ListView(
                      children: [
                        ...snapshot.data!.where((element) => element.uuid.str.contains("ff") || element.uuid.str.length>4).map((e) => ExpansionTile(
                          initiallyExpanded: true,
                          title: const Text("Characteristics",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.greenAccent),),
                        children: [
                          ...e.characteristics.map((e){
                             return ListTile(
                                  title: Text(e.properties.notify?"See Graph":e.properties.read?"Read":e.properties.write?"Set Command":"",style: TextStyle(color: e.properties.notify?Colors.green:e.properties.read?Colors.blue:e.properties.write?Colors.white:Colors.grey)),
                                onTap: ()async{
                                  if(e.properties.write){
                                    setCommand(context,e);
                                  }
                                  else{

                                    await showDialog(context: context, builder:(context){
                                      return AlertDialog(
                                        title: const Text("Set Name for Signature"),

                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [

                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 20),
                                              child: TextFormField(
                                                controller: _referNameController,
                                                decoration: const InputDecoration(
                                                    hintText: "Enter Reference Name",
                                                    border: OutlineInputBorder()
                                                ),
                                              ),
                                            ),

                                            const SizedBox(height: 20,),

                                            ElevatedButton(onPressed: ()async {
                                              if(_referNameController.text.isEmpty){
                                                Fluttertoast.showToast(msg: "Please Enter Reference Name");
                                              }
                                              else{
                                                //await Navigator.push(context, MaterialPageRoute(builder: (context)=>AnalyticsScreen(characteristic: e,device: widget.device,referName: _referNameController.text,)));
                                                await Navigator.push(context, MaterialPageRoute(builder: (context){
                                                  return ForkTracker(characteristic: e, device: widget.device);
                                                }));
                                                if(context.mounted) {
                                                  Navigator.pop(context);
                                                }

                                              }
                                            }, child: const Text("Set"))

                                          ],
                                        ),

                                      );
                                    });


                                  }
                                    
                                },
                              );
                
                          })
                        ],
                        ))
                      ],
                    );
                  }
                  return Container(
                    alignment: Alignment.center,
                    child: const Text("No Services available"),
                  );

              }));
            
            }
        return Container(alignment: Alignment.center,child: const CircularProgressIndicator(),);
          
        }
      ),
    );
  }

  
  void setCommand(BuildContext context,BluetoothCharacteristic e){
                          showDialog(context: context, builder: (context){
                                      return StatefulBuilder(
                                        builder: (context,setState) {
                                          return Dialog(
                                          child: SingleChildScrollView(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                              const SizedBox(height: 20,),
                                              const Text("Select Command",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                                              const SizedBox(height: 20,),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  ElevatedButton(
                                                    style: ElevatedButton.styleFrom(backgroundColor:command!="1"?Colors.white:Theme.of(context).primaryColor,elevation: 0),
                                                    onPressed: (){
                                                    setState((){
                                                        command = "1";
                                                    });
                                                  }, child: Text("2G",style: TextStyle(color: command!="1"?Colors.black:Colors.white),)),
                                                  const SizedBox(width: 20,),
                                                  ElevatedButton(
                                                    style: ElevatedButton.styleFrom(backgroundColor:command!="2"?Colors.white:Theme.of(context).primaryColor,elevation: 0),
                                                    onPressed: (){
                                                    setState((){
                                                        command = "2";
                                                    });
                                          
                                                  }, child:Text("4G",style: TextStyle(color: command!="2"?Colors.black:Colors.white),)),
                                                ],
                                              ),
                                              const SizedBox(height: 20,),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  ElevatedButton(
                                                    style: ElevatedButton.styleFrom(backgroundColor:command!="3"?Colors.white:Theme.of(context).primaryColor,elevation: 0),
                                                    
                                                    onPressed: (){
                                                    setState((){
                                                        command = "3";
                                                    });
                                          
                                                  }, child: Text("8G",style: TextStyle(color: command!="3"?Colors.black:Colors.white),)),
                                                  const SizedBox(width: 20,),
                                                  ElevatedButton(
                                                    style: ElevatedButton.styleFrom(backgroundColor:command!="4"?Colors.white:Theme.of(context).primaryColor,elevation: 0),
                                                    onPressed: (){
                                                    setState((){
                                                        command = "4";
                                                    });
                                                  }, child: Text("16G",style: TextStyle(color: command!="4"?Colors.black:Colors.white),)),
                                                ],
                                              ),
                                              const SizedBox(height: 20,),
                                              ElevatedButton(
                                                
                                                style: ElevatedButton.styleFrom(backgroundColor:command!="0"?Colors.white:Theme.of(context).primaryColor,elevation: 0),
                                                onPressed: (){
                                                setState((){
                                                    command = "0";
                                                });
                                              }, child: Text("STOP",style: TextStyle(color: command!='0'?Colors.black:Colors.white),)),
                                              const SizedBox(height: 20,),
                                              const Text("Custom Command",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
                                              const SizedBox(height: 20,),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                                child: TextFormField(
                                                  decoration: const InputDecoration(
                                                    hintText: "Enter Command",
                                                    border: OutlineInputBorder()
                                                  ),
                                                  onChanged: (value){
                                                    setState((){
                                                      command = value;
                                                    });
                                                  },
                                                  ),
                                              ),

                                                const SizedBox(height: 20,),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: ElevatedButton(
                                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                                                        onPressed: ()async{
                                                        if(command.isEmpty){
                                                          Fluttertoast.showToast(msg: "Please Enter Command");
                                                        }
                                                        else{
                                                          await e.write(command.codeUnits);//[1]
                                                          if(context.mounted)Navigator.pop(context);
                                                        }
                                                      }, child: const Text("Send",style: TextStyle(color: Colors.white),)),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 20,),
                                                                
                                          
                                            ]),
                                          ),

                                          );
                                        }
                                      );
                                    });
                                  }
}