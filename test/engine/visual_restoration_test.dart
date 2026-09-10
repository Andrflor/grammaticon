import 'dart:io';
import 'package:flame/flame.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grammaticon/engine/application.dart';
import 'package:grammaticon/engine/design.dart';
import 'package:grammaticon/engine/session.dart';
import 'package:grammaticon/ui/widgets/roman_widgets.dart';
import 'design_test.dart' show readFile;

void main(){
 for(final width in [1600.0,420.0]){
 testWidgets('original presentation survives JSON binding at $width',(tester)async{
 final previousError=FlutterError.onError;FlutterError.onError=(details){FlutterError.dumpErrorToConsole(details,forceReport:true);previousError?.call(details);};addTearDown(()=>FlutterError.onError=previousError);
 tester.view.physicalSize=Size(width,900);tester.view.devicePixelRatio=1;addTearDown(tester.view.reset);
 for(final family in ['Nunito','Cinzel']){await(FontLoader(family)..addFont(rootBundle.load('assets/fonts/$family.ttf'))).load();}
 await(FontLoader('MaterialIcons')..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
 final d=(await tester.runAsync(()=>GameDesign.load('assets/designs/grammaticon/game.json',readFile)))!;
 final s=GameSession(d,{},(_)async{});s.state['settings']['sound']=false;s.state['settings']['music']=false;s.state['balance']=0;
 final boundary=GlobalKey();
 Future<void> capture(String name)async{
 await tester.runAsync(()async{final context=tester.element(find.byType(Scaffold).last);for(final item in d.resources.values.where((r)=>r['type']=='image')){await precacheImage(AssetImage(item['path']),context);}});
 await tester.pump();await tester.pump(const Duration(milliseconds:200));
 expect(tester.takeException(),isNull);
 await tester.runAsync(()async{final image=await(boundary.currentContext!.findRenderObject() as RenderRepaintBoundary).toImage();final bytes=await image.toByteData(format:ui.ImageByteFormat.png);File('/tmp/restored-$name-${width.toInt()}.png').writeAsBytesSync(bytes!.buffer.asUint8List());image.dispose();});
 }
 await tester.pumpWidget(RepaintBoundary(key:boundary,child:DesignApp(session:s)));await tester.pumpAndSettle();await capture('city');
 await tester.ensureVisible(find.text('Amphitheātrum'));await tester.tap(find.text('Amphitheātrum'));await tester.pumpAndSettle();await capture('selection');
 expect(find.text('Certāmen'),findsWidgets);
 await tester.runAsync(()async{final card=d.cards.values.first;await d.lesson(card);Flame.images.prefix='';for(final id in ['arena_bg','hero_idle','hero_attack','hero_hurt','hero_victory','hero_defeat','enemy_statua','impact','gem']){await Flame.images.load(d.asset(id));}});
 await tester.runAsync(()async{await tester.tap(find.widgetWithText(RomanButton,'Certāmen').first); for(var i=0;s.encounter==null&&i<200;i++){await Future<void>.delayed(const Duration(milliseconds:20));}});await tester.pump();await tester.pump(const Duration(milliseconds:300));
 await tester.runAsync(()async{await d.lesson(d.cards[s.encounter!['card']]!);});await tester.pump();
 await tester.runAsync(()=>Future<void>.delayed(const Duration(milliseconds:100)));await tester.pump();await tester.pump(const Duration(milliseconds:100));await capture('intro');
 expect(find.text('Incipe!'),findsOneWidget);
 await tester.tap(find.text('Incipe!'));await tester.pump();await tester.pump(const Duration(milliseconds:100));await capture('battle');
 final q=s.question!;final wrong=q.choices.firstWhere((c)=>!q.accepted.contains(c['id']));
 await tester.tap(find.widgetWithText(RomanButton,s.text(wrong['text'])));await tester.pump();await tester.pump(const Duration(milliseconds:800));await capture('correction');
 expect(s.encounter!['phase'],'feedback');
 await tester.pumpWidget(const SizedBox());await tester.pump(const Duration(seconds:2));s.dispose();
 });
 }
}
