import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../engine/design.dart';
import '../../engine/session.dart';

/// Rich authored content uses the original highlighted-word treatment.
class QuestionContent extends StatelessWidget {
 const QuestionContent({super.key,required this.session,required this.parts,required this.size});
 final GameSession session;
 final List<Json> parts;
 final double size;
 @override
 Widget build(BuildContext context){
 final skin=G(object(session.design.root['theme']));
 return Wrap(alignment:WrapAlignment.center,crossAxisAlignment:WrapCrossAlignment.center,children:[
 for(final part in parts)
 if(part['type']=='image')Image.asset(session.design.asset(part['asset']),height:160)
 else Container(padding:EdgeInsets.symmetric(horizontal:part['type']=='highlight'?6:0,vertical:part['type']=='highlight'?2:0),decoration:BoxDecoration(color:part['type']=='highlight'?skin.goldWash:null,borderRadius:BorderRadius.circular(6)),child:Text(session.text(part['text']),style:skin.display(size,color:skin.purpleDark,letterSpacing:.3).copyWith(fontWeight:part['type']=='highlight'?FontWeight.bold:null,decoration:part['type']=='gap'?TextDecoration.underline:null))),
 ]);
 }
}
