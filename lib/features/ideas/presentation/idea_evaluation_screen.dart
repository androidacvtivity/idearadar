import 'package:flutter/material.dart';
import 'package:idearadar/app/localization/app_localization.dart';
import 'package:idearadar/app/localization/idea_localization.dart';
import 'package:idearadar/features/ideas/domain/idea.dart';
import 'package:idearadar/features/ideas/domain/idea_evaluation.dart';

class IdeaEvaluationScreen extends StatefulWidget {
  const IdeaEvaluationScreen({required this.idea, super.key});
  final Idea idea;
  @override State<IdeaEvaluationScreen> createState() => _IdeaEvaluationScreenState();
}

class _IdeaEvaluationScreenState extends State<IdeaEvaluationScreen> {
  final _rationaleController = TextEditingController();
  int _problemScore = 3, _marketScore = 3, _demandScore = 3, _competitionScore = 3, _dataAccessScore = 3, _technicalFeasibilityScore = 3, _monetizationScore = 3, _firstClientScore = 3;
  int get _totalScore => _problemScore + _marketScore + _demandScore + _competitionScore + _dataAccessScore + _technicalFeasibilityScore + _monetizationScore + _firstClientScore;

  @override void initState() {
    super.initState(); final e = widget.idea.evaluation; if (e == null) return;
    _problemScore=e.problemScore; _marketScore=e.marketScore; _demandScore=e.demandScore; _competitionScore=e.competitionScore; _dataAccessScore=e.dataAccessScore; _technicalFeasibilityScore=e.technicalFeasibilityScore; _monetizationScore=e.monetizationScore; _firstClientScore=e.firstClientScore; _rationaleController.text=e.rationale;
  }
  @override void dispose(){_rationaleController.dispose();super.dispose();}
  void _dismissKeyboard()=>FocusManager.instance.primaryFocus?.unfocus();
  void _saveEvaluation(){
    _dismissKeyboard();
    final e=IdeaEvaluation(problemScore:_problemScore,marketScore:_marketScore,demandScore:_demandScore,competitionScore:_competitionScore,dataAccessScore:_dataAccessScore,technicalFeasibilityScore:_technicalFeasibilityScore,monetizationScore:_monetizationScore,firstClientScore:_firstClientScore,rationale:_rationaleController.text.trim());
    Navigator.of(context).pop(widget.idea.copyWith(evaluation:e,updatedAt:DateTime.now()));
  }

  @override Widget build(BuildContext context){
    final isEditing=widget.idea.evaluation!=null; final cs=Theme.of(context).colorScheme;
    return Scaffold(
      appBar:AppBar(title:Text(itx(context,isEditing?'edit_evaluation':'evaluate_idea'))),
      body:GestureDetector(behavior:HitTestBehavior.translucent,onTap:_dismissKeyboard,child:SafeArea(child:ListView(keyboardDismissBehavior:ScrollViewKeyboardDismissBehavior.onDrag,padding:const EdgeInsets.fromLTRB(20,12,20,120),children:[
        Container(key:const Key('evaluation_score_header'),padding:const EdgeInsets.all(24),decoration:BoxDecoration(color:cs.primaryContainer,borderRadius:BorderRadius.circular(24)),child:LayoutBuilder(builder:(context,constraints){
          final stacked=constraints.maxWidth<330||MediaQuery.textScalerOf(context).scale(1)>1.2;
          final score=Text('$_totalScore/40',key:const Key('evaluation_total_score'),style:Theme.of(context).textTheme.headlineSmall?.copyWith(color:cs.onPrimaryContainer,fontWeight:FontWeight.w800));
          final summary=Row(crossAxisAlignment:CrossAxisAlignment.start,children:[Icon(Icons.analytics_outlined,size:36,color:cs.onPrimaryContainer),const SizedBox(width:16),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(tr(context,'opportunity_score'),key:const Key('evaluation_score_title'),style:Theme.of(context).textTheme.titleMedium?.copyWith(color:cs.onPrimaryContainer,fontWeight:FontWeight.w700)),const SizedBox(height:4),Text(itx(context,'adjust_criterion'),key:const Key('evaluation_score_explanation'),style:TextStyle(color:cs.onPrimaryContainer))]))]);
          return stacked?Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[summary,const SizedBox(height:12),Align(alignment:Alignment.centerRight,child:score)]):Row(children:[Expanded(child:summary),const SizedBox(width:16),score]);
        })),
        const SizedBox(height:20),
        _ScoreControl(label:itx(context,'problem_severity'),description:itx(context,'problem_severity_desc'),value:_problemScore,onChanged:(v)=>setState(()=>_problemScore=v)),
        _ScoreControl(label:itx(context,'market_potential'),description:itx(context,'market_potential_desc'),value:_marketScore,onChanged:(v)=>setState(()=>_marketScore=v)),
        _ScoreControl(label:itx(context,'demand_evidence'),description:itx(context,'demand_evidence_desc'),value:_demandScore,onChanged:(v)=>setState(()=>_demandScore=v)),
        _ScoreControl(label:itx(context,'competition_favorability'),description:itx(context,'competition_favorability_desc'),value:_competitionScore,onChanged:(v)=>setState(()=>_competitionScore=v)),
        _ScoreControl(label:itx(context,'data_access'),description:itx(context,'data_access_desc'),value:_dataAccessScore,onChanged:(v)=>setState(()=>_dataAccessScore=v)),
        _ScoreControl(label:itx(context,'technical_feasibility'),description:itx(context,'technical_feasibility_desc'),value:_technicalFeasibilityScore,onChanged:(v)=>setState(()=>_technicalFeasibilityScore=v)),
        _ScoreControl(label:itx(context,'monetization_potential'),description:itx(context,'monetization_potential_desc'),value:_monetizationScore,onChanged:(v)=>setState(()=>_monetizationScore=v)),
        _ScoreControl(label:itx(context,'first_client_access'),description:itx(context,'first_client_access_desc'),value:_firstClientScore,onChanged:(v)=>setState(()=>_firstClientScore=v)),
        const SizedBox(height:8),
        TextField(key:const Key('evaluation_rationale_field'),controller:_rationaleController,minLines:3,maxLines:6,textCapitalization:TextCapitalization.sentences,textInputAction:TextInputAction.done,onSubmitted:(_)=>_dismissKeyboard(),decoration:InputDecoration(labelText:itx(context,'evaluation_rationale'),hintText:itx(context,'evaluation_rationale_hint'),alignLabelWithHint:true,prefixIcon:const Icon(Icons.notes_outlined))),
      ]))),
      bottomNavigationBar:SafeArea(minimum:const EdgeInsets.fromLTRB(20,8,20,16),child:FilledButton.icon(key:const Key('save_evaluation_button'),onPressed:_saveEvaluation,icon:const Icon(Icons.save_outlined),label:Text(itx(context,isEditing?'save_evaluation_changes':'save_evaluation')))),
    );
  }
}

class _ScoreControl extends StatelessWidget{
  const _ScoreControl({required this.label,required this.description,required this.value,required this.onChanged}); final String label,description; final int value; final ValueChanged<int> onChanged;
  @override Widget build(BuildContext context){final cs=Theme.of(context).colorScheme;return Card(margin:const EdgeInsets.only(bottom:12),child:Padding(padding:const EdgeInsets.fromLTRB(18,16,18,8),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(children:[Expanded(child:Text(label,style:Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight:FontWeight.w700))),Container(width:36,height:36,alignment:Alignment.center,decoration:BoxDecoration(color:cs.primaryContainer,shape:BoxShape.circle),child:Text('$value',style:TextStyle(color:cs.onPrimaryContainer,fontWeight:FontWeight.w800)))]),const SizedBox(height:4),Text(description,style:TextStyle(color:cs.onSurfaceVariant)),Slider(value:value.toDouble(),min:1,max:5,divisions:4,label:'$value',onChanged:(v)=>onChanged(v.round()))])));}
}
