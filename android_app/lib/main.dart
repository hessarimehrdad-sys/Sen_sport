import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

const navy = Color(0xFF101B35);
const green = Color(0xFF20C997);

void main() => runApp(const SenSportApp());

class SenSportApp extends StatelessWidget {
  const SenSportApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false, title: 'SenSport',
    locale: const Locale('fa'), supportedLocales: const [Locale('fa'), Locale('en')],
    localizationsDelegates: const [GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
    theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: green), fontFamily: 'Roboto'),
    home: const Directionality(textDirection: TextDirection.rtl, child: LoginPage()),
  );
}

class LocalData {
  static final Map<String,List<String>> data = {
    'تمرین‌ها':['تمرین تاکتیکی • دوشنبه ۱۸:۰۰','تمرین بدنسازی • چهارشنبه ۱۷:۳۰'],
    'حضور و غیاب':[], 'شهریه و رسید':[], 'پیام‌ها':[], 'پیشرفت':[], 'پرونده بازیکنان':[]
  };
  static Future<void> load() async {
    final p=await SharedPreferences.getInstance();
    for(final k in data.keys){data[k]=p.getStringList(k)??data[k]!;}
  }
  static Future<void> save(String key) async {
    final p=await SharedPreferences.getInstance(); await p.setStringList(key,data[key]!);
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override State<LoginPage> createState()=>_LoginPageState();
}
class _LoginPageState extends State<LoginPage>{
  final name=TextEditingController(); bool coach=false,loading=false;
  Future<void> enter() async {
    setState(()=>loading=true); await LocalData.load(); if(!mounted)return;
    Navigator.pushReplacement(context,MaterialPageRoute(builder:(_)=>AppHome(name:name.text.trim().isEmpty?(coach?'مربی':'بازیکن'):name.text.trim(),coach:coach)));
  }
  @override Widget build(BuildContext context)=>Scaffold(backgroundColor:navy,body:Center(child:SingleChildScrollView(padding:const EdgeInsets.all(24),child:Card(child:Padding(padding:const EdgeInsets.all(24),child:Column(mainAxisSize:MainAxisSize.min,children:[
    const Icon(Icons.sports_soccer,color:green,size:64),const Text('SenSport',style:TextStyle(fontSize:30,fontWeight:FontWeight.bold,color:navy)),const Text('سامانه مدیریت ورزش و تمرین'),const SizedBox(height:22),
    TextField(controller:name,decoration:const InputDecoration(labelText:'نام شما',prefixIcon:Icon(Icons.person))),const SizedBox(height:16),
    SegmentedButton<bool>(segments:const[ButtonSegment(value:false,label:Text('بازیکن'),icon:Icon(Icons.person)),ButtonSegment(value:true,label:Text('مربی'),icon:Icon(Icons.sports))],selected:{coach},onSelectionChanged:(s)=>setState(()=>coach=s.first)),
    const SizedBox(height:22),SizedBox(width:double.infinity,child:FilledButton(onPressed:loading?null:enter,child:Text(loading?'لطفاً صبر کنید':'ورود به برنامه')))
  ]))))));
}
class AppHome extends StatefulWidget {
 final String name;final bool coach;const AppHome({super.key,required this.name,required this.coach});
 @override State<AppHome> createState()=>_AppHomeState();
}
class _AppHomeState extends State<AppHome>{
 int selected=0;
 final keys=['خانه','تمرین‌ها','حضور و غیاب','شهریه و رسید','پیام‌ها','پیشرفت','پرونده بازیکنان'];
 final icons=[Icons.home,Icons.calendar_month,Icons.fact_check,Icons.receipt_long,Icons.chat,Icons.insights,Icons.folder];
 Future<void> addItem(String key)async{
  final ctrl=TextEditingController();
  await showDialog(context:context,builder:(ctx)=>AlertDialog(title:Text('ثبت در $key'),content:TextField(controller:ctrl,autofocus:true,maxLines:3,decoration:const InputDecoration(hintText:'عنوان یا توضیحات...')),actions:[TextButton(onPressed:()=>Navigator.pop(ctx),child:const Text('لغو')),FilledButton(onPressed:(){final v=ctrl.text.trim();if(v.isNotEmpty){setState(()=>LocalData.data[key]!.insert(0,v));LocalData.save(key);}Navigator.pop(ctx);},child:const Text('ذخیره'))]));
 }
 Widget dashboard()=>ListView(padding:const EdgeInsets.all(16),children:[
  Container(padding:const EdgeInsets.all(20),decoration:BoxDecoration(color:navy,borderRadius:BorderRadius.circular(20)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('سلام ${widget.name} 👋',style:const TextStyle(color:Colors.white,fontSize:24,fontWeight:FontWeight.bold)),const SizedBox(height:8),Text(widget.coach?'پنل مربی':'پنل بازیکن',style:const TextStyle(color:green,fontSize:16)),const SizedBox(height:14),Text('تمرین‌ها: ${LocalData.data['تمرین‌ها']!.length}  |  پیام‌ها: ${LocalData.data['پیام‌ها']!.length}',style:const TextStyle(color:Colors.white))]),
  const SizedBox(height:18),GridView.count(shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),crossAxisCount:2,crossAxisSpacing:10,mainAxisSpacing:10,childAspectRatio:1.25,children:List.generate(6,(i)=>Card(child:InkWell(borderRadius:BorderRadius.circular(16),onTap:()=>setState(()=>selected=i+1),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Icon(icons[i+1],color:green,size:32),const SizedBox(height:8),Text(keys[i+1],style:const TextStyle(fontWeight:FontWeight.bold))]))))),
  const SizedBox(height:12),const Card(child:Padding(padding:EdgeInsets.all(16),child:Text('نسخه محلی: داده‌ها روی همین دستگاه ذخیره می‌شوند. برای استفاده چندنفره و آنلاین باید سرور متصل شود.')))
 ]);
 Widget module(String key)=>Column(children:[
  Padding(padding:const EdgeInsets.symmetric(horizontal:16,vertical:12),child:Row(children:[Expanded(child:Text(key,style:const TextStyle(fontSize:20,fontWeight:FontWeight.bold))),FilledButton.icon(onPressed:()=>addItem(key),icon:const Icon(Icons.add),label:const Text('ثبت جدید'))])),
  Expanded(child:LocalData.data[key]!.isEmpty?const Center(child:Text('هنوز اطلاعاتی ثبت نشده؛ دکمه ثبت جدید را بزنید.')):ListView.builder(itemCount:LocalData.data[key]!.length,itemBuilder:(ctx,i)=>Card(child:ListTile(leading:Icon(icons[keys.indexOf(key)],color:green),title:Text(LocalData.data[key]![i]),trailing:PopupMenuButton<String>(onSelected:(v){if(v=='del'){setState(()=>LocalData.data[key]!.removeAt(i));LocalData.save(key);}else addItem(key);},itemBuilder:(_)=>const[PopupMenuItem(value:'edit',child:Text('افزودن مورد')),PopupMenuItem(value:'del',child:Text('حذف'))])))))
 ]);
 @override Widget build(BuildContext context){
  final body=selected==0?dashboard():module(keys[selected]);
  return Directionality(textDirection:TextDirection.rtl,child:Scaffold(appBar:AppBar(backgroundColor:navy,foregroundColor:Colors.white,title:Text('SenSport • ${widget.coach?'مربی':'بازیکن'}'),actions:[IconButton(tooltip:'خروج',onPressed:()=>Navigator.pushReplacement(context,MaterialPageRoute(builder:(_)=>const LoginPage())),icon:const Icon(Icons.logout))]),body:body,bottomNavigationBar:NavigationBar(selectedIndex:selected<4?selected:0,onDestinationSelected:(v)=>setState(()=>selected=v),destinations:const[NavigationDestination(icon:Icon(Icons.home),label:'خانه'),NavigationDestination(icon:Icon(Icons.calendar_month),label:'تمرین'),NavigationDestination(icon:Icon(Icons.fact_check),label:'حضور'),NavigationDestination(icon:Icon(Icons.receipt),label:'مالی')]));
 }
}
