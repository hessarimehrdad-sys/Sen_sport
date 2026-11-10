import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() => runApp(const SenSportApp());

const navy = Color(0xFF101B35);
const green = Color(0xFF20C997);

class SenSportApp extends StatelessWidget {
  const SenSportApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'SenSport',
    locale: const Locale('fa'),
    supportedLocales: const [Locale('fa'), Locale('en')],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: green), fontFamily: 'Roboto'),
    home: const PlayerHome(),
  );
}

class PlayerHome extends StatelessWidget {
  const PlayerHome({super.key});
  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: navy, foregroundColor: Colors.white,
        title: const Text('SenSport  |  پنل بازیکن', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none))],
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: navy, borderRadius: BorderRadius.circular(22)),
          child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('خوش آمدی بازیکن 👋', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 8), Text('برای پیشرفت، هر روز یک قدم جلوتر', style: TextStyle(color: Colors.white70)),
            SizedBox(height: 18), Row(children: [
              Icon(Icons.sports_soccer, color: green, size: 36),
              SizedBox(width: 10), Text('تمرین کن • پیشرفت کن • بدرخش', style: TextStyle(color: green, fontWeight: FontWeight.bold))
            ])
          ]),
        ),
        const SizedBox(height: 16),
        const Row(children: [Expanded(child: StatCard(title:'حضور در تمرین',value:'—',icon:Icons.check_circle)), SizedBox(width:12), Expanded(child: StatCard(title:'امتیاز عملکرد',value:'—',icon:Icons.trending_up))]),
        const SizedBox(height: 16),
        const Text('امکانات بازیکن', style: TextStyle(fontSize:18,fontWeight:FontWeight.bold)),
        const SizedBox(height: 10),
        GridView.count(shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),crossAxisCount:2,crossAxisSpacing:10,mainAxisSpacing:10,childAspectRatio:1.25,children:const [
          FeatureCard('برنامه تمرین',Icons.calendar_month), FeatureCard('حضور و غیاب',Icons.fact_check),
          FeatureCard('شهریه و رسید',Icons.receipt_long), FeatureCard('گزارش پیشرفت',Icons.insights),
          FeatureCard('پیام به مربی',Icons.chat), FeatureCard('اعلان‌ها',Icons.notifications)
        ]),
        const SizedBox(height:12),
        const Card(child: Padding(padding:EdgeInsets.all(16),child:Text('نسخه آغازین رابط اندروید SenSport — اتصال حساب‌ها و ذخیره‌سازی اطلاعات در مراحل بعدی اضافه می‌شود.')))
      ]),
      bottomNavigationBar: NavigationBar(selectedIndex:0, destinations:const [
        NavigationDestination(icon:Icon(Icons.home_outlined),label:'خانه'),
        NavigationDestination(icon:Icon(Icons.bar_chart),label:'پیشرفت'),
        NavigationDestination(icon:Icon(Icons.calendar_today),label:'تمرین'),
        NavigationDestination(icon:Icon(Icons.person_outline),label:'پروفایل')
      ]),
    ));
}

class StatCard extends StatelessWidget {
  final String title,value; final IconData icon;
  const StatCard({super.key,required this.title,required this.value,required this.icon});
  @override Widget build(BuildContext context)=>Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Icon(icon,color:green),const SizedBox(height:8),Text(title),Text(value,style:const TextStyle(fontSize:22,fontWeight:FontWeight.bold))])));
}
class FeatureCard extends StatelessWidget {
  final String title;final IconData icon;
  const FeatureCard(this.title,this.icon,{super.key});
  @override Widget build(BuildContext context)=>Card(child:InkWell(onTap:(){},borderRadius:BorderRadius.circular(16),child:Padding(padding:const EdgeInsets.all(16),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Icon(icon,size:32,color:green),const SizedBox(height:8),Text(title,style:const TextStyle(fontWeight:FontWeight.bold))]))));
}
