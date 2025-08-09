import 'package:flutter/material.dart';
import 'package:mosque_locator/models/user_model.dart';
import 'package:mosque_locator/providers/user_provider.dart';
import 'package:mosque_locator/utils/app_styles.dart';
import 'package:mosque_locator/widgets/custom_textfield.dart';
import 'package:provider/provider.dart';

class ContributorRegisterForm extends StatefulWidget {
  const ContributorRegisterForm({super.key});

  @override
  State<ContributorRegisterForm> createState() => _ContributorRegisterFormState();
}

class _ContributorRegisterFormState extends State<ContributorRegisterForm> {
   final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final cityController = TextEditingController();
  final areaController = TextEditingController();
  final reasonController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final user_provider =Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Contributor Registration", style: TextStyle(color: Colors.white,fontWeight:FontWeight.bold ),),backgroundColor:AppStyles.primaryGreen),
body:SingleChildScrollView(
  padding: EdgeInsets.all(16),
  child: Column(children: [
                CustomTextfield(controller: nameController, label: "Name"),
              CustomTextfield(controller: emailController, label: "Email", keyboardType: TextInputType.emailAddress),
              CustomTextfield(controller: passwordController, label: "Password", obscureText: true),
              CustomTextfield(controller: phoneController, label: "Phone", keyboardType: TextInputType.phone),
              CustomTextfield(controller: cityController, label: "City"),
              CustomTextfield(controller: areaController, label: "Area"),
              CustomTextfield(controller: reasonController, label: "Reason for Joining"),
  
              SizedBox(height: 20,),
              user_provider.isLoading
                  ? const CircularProgressIndicator():
               ElevatedButton(onPressed: ()async{
  final User=UserModel(name: nameController.text.trim(), email: emailController.text.trim(), password: passwordController.text, phone: phoneController.text.trim(), city: cityController.text.trim(), area: areaController.text.trim(), reason: reasonController.text.trim());
             final success= await user_provider.registerContributor(User);
             if(success&&mounted){
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Registration Successful!")),);
                  Navigator.pop(context);
             }else{
               ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to Register!")),);
             }
               }, child: const Text("Register"), )
  ],),
) ,
    );
  }
}