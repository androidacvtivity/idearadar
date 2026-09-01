import 'package:flutter/material.dart';
import 'package:idearadar/app/localization/app_localization.dart';
import 'package:idearadar/app/localization/idea_localization.dart';
import 'package:idearadar/features/ideas/data/idea_repository.dart';
import 'package:idearadar/features/ideas/domain/idea.dart';
import 'package:idearadar/features/ideas/presentation/idea_details_result.dart';
import 'package:idearadar/features/ideas/presentation/idea_details_screen.dart';

class ArchivedIdeasScreen extends StatefulWidget {
  const ArchivedIdeasScreen({required this.repository, super.key});
  final IdeaRepository repository;
  @override State<ArchivedIdeasScreen> createState()=>_ArchivedIdeasScreenState();
}

class _ArchivedIdeasScreenState extends State<ArchivedIdeasScreen>{
  final List<Idea> _ideas=[];bool _isLoading=true;String? _error;
  @override void initState(){super.initState();_loadIdeas();}
  Future<void> _loadIdeas() async{try{final ideas=await widget.repository.getIdeas();final archived=ideas.where((e)=>e.isArchived).toList()..sort((a,b)=>b.archivedAt!.compareTo(a.archivedAt!));if(!mounted)return;setState((){_ideas..clear()..addAll(archived);_isLoading=false;_error=null;});}catch(_){if(!mounted)return;setState((){_isLoading=false;_error=itx(context,'archive_load_error');});}}
  Future<void> _openIdea(Idea idea) async{final result=await Navigator.of(context).push<IdeaDetailsResult>(MaterialPageRoute(builder:(_)=>IdeaDetailsScreen(idea:idea,repository:widget.repository)));if(!mounted||result==null)return;try{switch(result){case IdeaUpdatedResult(:final idea):await widget.repository.updateIdea(idea);if(!mounted)return;setState((){final i=_ideas.indexWhere((e)=>e.id==idea.id);if(!idea.isArchived){_ideas.removeWhere((e)=>e.id==idea.id);}else if(i!=-1){_ideas[i]=idea;}});case IdeaDeletedResult(:final ideaId):await widget.repository.deleteIdea(ideaId);if(!mounted)return;setState(()=>_ideas.removeWhere((e)=>e.id==ideaId));}}catch(_){if(!mounted)return;ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(itx(context,'archive_update_error'))));}}
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:Text(tr(context,'archived_ideas'))),body:SafeArea(child:_isLoading?const Center(child:CircularProgressIndicator()):_error!=null?_ArchiveError(message:_error!,onRetry:_loadIdeas):_ideas.isEmpty?const _EmptyArchive():ListView.builder(padding:const EdgeInsets.fromLTRB(20,12,20,32),itemCount:_ideas.length,itemBuilder:(context,index){final idea=_ideas[index];return Card(margin:const EdgeInsets.only(bottom:12),child:ListTile(onTap:()=>_openIdea(idea),contentPadding:const EdgeInsets.symmetric(horizontal:18,vertical:8),leading:const CircleAvatar(child:Icon(Icons.archive_outlined)),title:Text(idea.title,style:const TextStyle(fontWeight:FontWeight.w700)),subtitle:Text('${idea.domain} · ${itx(context,'archived')} ${_formatDate(idea.archivedAt!)}'),trailing:const Icon(Icons.chevron_right)));})));
  static String _formatDate(DateTime d)=>'${d.day.toString().padLeft(2,'0')}.${d.month.toString().padLeft(2,'0')}.${d.year}';
}
class _EmptyArchive extends StatelessWidget{const _EmptyArchive();@override Widget build(BuildContext context)=>Center(child:Padding(padding:const EdgeInsets.all(32),child:Column(mainAxisSize:MainAxisSize.min,children:[Icon(Icons.inventory_2_outlined,size:52,color:Theme.of(context).colorScheme.primary),const SizedBox(height:16),Text(itx(context,'no_archived_ideas'),style:Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight:FontWeight.w700)),const SizedBox(height:8),Text(itx(context,'no_archived_ideas_desc'),textAlign:TextAlign.center)])));}
class _ArchiveError extends StatelessWidget{const _ArchiveError({required this.message,required this.onRetry});final String message;final VoidCallback onRetry;@override Widget build(BuildContext context)=>Center(child:Column(mainAxisSize:MainAxisSize.min,children:[Text(message),const SizedBox(height:12),OutlinedButton.icon(onPressed:onRetry,icon:const Icon(Icons.refresh),label:Text(itx(context,'try_again')))]));}
