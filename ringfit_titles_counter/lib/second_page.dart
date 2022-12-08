import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:ringfit_titles_counter/ringfit_title.dart';
import 'exercise_count_repository.dart';
import 'main.dart';
import 'skill.dart';
import 'third_page.dart';
import 'title_achievement.dart';

class SecondPage extends StatefulWidget {
  const SecondPage({Key? key, required this.skill}) : super(key: key);

  final Skill skill;
  String get title => HandleSkill.title(skill);

  @override
  State<SecondPage> createState() => _SecondPageState();

}

class _SecondPageState extends State<SecondPage> with RouteAware {

  final _countRepository = ExerciseCountRepository();
  List<RingfitTitle> _listTitle = [];
  List<ExerciseCount> _listCount = [];
  List<TitleAchievement> _listItem = [];
  int _sortMode = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: SafeArea(
          child: FutureBuilder<void>(
              future: _getFutureValue(),
              builder: (context, snapshot) {
                return ListView.builder(
                    itemBuilder: (BuildContext context, int index) {
                      return _card(_listItem[index]);
                    },
                    itemCount: _listItem.length);
              }),
        ),
      floatingActionButton: FloatingActionButton(
          onPressed: () => {
            setState((){
              _sortMode = _sortMode == 0 ? 1 : 0;
            })
          },
          child: const Icon(Icons.sort)),
    );
  }

  Widget _card(TitleAchievement achievement) {
    return InkWell(
      onTap: (){
        Navigator.of(context).push<void>(
            MaterialPageRoute(
                builder: (context) {
                  return ThirdPage(
                      achievement: achievement
                  );
                }
            )
        );
      },
      child: Card(
          child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '${achievement.name} (${achievement.progress} / ${achievement.total})',
                        textAlign: TextAlign.end,
                      )
                  ),
                  RatingBarIndicator(
                    rating: achievement.rating,
                    itemBuilder: (context, index) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    itemCount: 4,
                    itemSize: 24,
                    direction: Axis.horizontal,
                  ),
                ],
              )
          )
      ),
    );
  }

  TitleAchievement _makeTitleAchievement(int id) {
    final count = _listCount.firstWhere((element) => element.id == id);
    final title = _listTitle.firstWhere((element) => element.id == id);
    return TitleAchievement(title, title.name, title.rank4, count.count);
  }

  Future<void> _getFutureValue() async {
    _listTitle = await _loadJson();
    _listCount = await _getExerciseCount();
    _listItem = _listTitle.map<TitleAchievement>(
            (title) => _makeTitleAchievement(title.id)
    ).toList();
    if (_sortMode == 0) {
      _listItem.sort((a, b) => a.rating.compareTo(b.rating));
    } else {
      _listItem.sort((a, b) => -a.rating.compareTo(b.rating));
    }
  }

  Future<List<RingfitTitle>> _loadJson() async {
    final loadString = await rootBundle.loadString('assets/json/ringfit_titles.json');
    final jsonData = json.decode(loadString) as List<dynamic>;
    final titles = jsonData
        .map<RingfitTitle>(
            (dynamic value) => RingfitTitle.fromJson(value as Map<String, dynamic>)
    )
        .toList();
    return titles.where((n) => n.skill == HandleSkill.value(widget.skill)).toList();
  }

  Future<List<ExerciseCount>> _getExerciseCount() async {
    final counts = await _countRepository.fetchAll();
    return counts.where((n) => n.skill == HandleSkill.value(widget.skill)).toList();;
  }
}
