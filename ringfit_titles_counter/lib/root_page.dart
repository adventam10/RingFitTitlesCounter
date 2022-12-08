import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:ringfit_titles_counter/ringfit_title.dart';
import 'exercise_count_repository.dart';
import 'main.dart';
import 'second_page.dart';
import 'skill.dart';

class RootPage extends StatefulWidget {
  const RootPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> with RouteAware {

  final _countRepository = ExerciseCountRepository();
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
            actions: [
              PopupMenuButton(
                onSelected: _popupMenuSelected,
                itemBuilder: (BuildContext context) =>
                <PopupMenuEntry<_Menu>>[
                  const PopupMenuItem(
                      value: _Menu.license,
                      child: Text('ライセンス表示')
                  ),
                ],
              ),
            ]
        ),
        body: SafeArea(
          child: FutureBuilder<List<_TotalTitleAchievement>>(
              future: _getFutureValue(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return SingleChildScrollView(
                    child: Column(
                        children: [
                          _card(snapshot.data![0]),
                          _card(snapshot.data![1]),
                          _card(snapshot.data![2]),
                          _card(snapshot.data![3])
                        ]),
                  );
                } else {
                  return const Text('データ取得中');
                }
              }),
        )
    );
  }

  Widget _card(_TotalTitleAchievement achievement) {
    return InkWell(
      onTap: (){
        Navigator.of(context).push<void>(
            MaterialPageRoute(
                builder: (context) {
                  return SecondPage(skill: achievement.skill);
                }
            )
        );
      },
      child: Card(
          child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _cardTitle(
                          '${HandleSkill.title(achievement.skill)} (${achievement.progress} / ${achievement.total})',
                          HandleSkill.color(achievement.skill))
                  ),
                  LinearProgressIndicator(value: achievement.rate),
                ],
              )
          )
      ),
    );
  }

  Widget _cardTitle(String title, Color color) {
    return Row(
      children: [
        Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _circle(color)
        ),
        Text(
          title,
          style: const TextStyle(fontSize: 18),
        ),
      ],
    );
  }

  Widget _circle(Color color) {
    return Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        )
    );
  }

  void _popupMenuSelected(_Menu selectedMenu){
    switch(selectedMenu) {
      case _Menu.license:
        showLicensePage(context: context);
        break;
    }
  }

  Future<List<RingfitTitle>> _loadJson() async {
    final loadString = await rootBundle.loadString('assets/json/ringfit_titles.json');
    final jsonData = json.decode(loadString) as List<dynamic>;
    final titles = jsonData
        .map<RingfitTitle>((dynamic value) => RingfitTitle.fromJson(value as Map<String, dynamic>))
        .toList();
    return titles;
  }

  Future<void> _insertExerciseCounts(List<RingfitTitle> titles) async {
    final counts = await _countRepository.fetchAll();
    if (counts.isNotEmpty) {
      return;
    }
    for (final title in titles) {
      await _countRepository.save(
          ExerciseCount(title.id, 0, title.skill, title.name)
      );
    }
  }

  Future<List<_TotalTitleAchievement>> _getFutureValue() async {
    final titles = await _loadJson();
    await _insertExerciseCounts(titles);
    final counts = await _countRepository.fetchAll();
    return _makeTitleAchievement(titles, counts);
  }

  List<_TotalTitleAchievement> _makeTitleAchievement(
      List<RingfitTitle> titles,
      List<ExerciseCount> counts
      ) {
    final red = _makeAchievement(Skill.arm, titles, counts);
    final yellow = _makeAchievement(Skill.stomach, titles, counts);
    final blue = _makeAchievement(Skill.leg, titles, counts);
    final green = _makeAchievement(Skill.yoga, titles, counts);
    return [red, yellow, blue, green];
  }

  int _calculateCount(int count, RingfitTitle title) {
    final list = [title.rank1, title.rank2, title.rank3, title.rank4, count];
    list.sort((a, b) => a.compareTo(b));
    return list.lastIndexOf(count);
  }

  _TotalTitleAchievement _makeAchievement(
      Skill skill,
      List<RingfitTitle> titles,
      List<ExerciseCount> counts
      ) {
    final targets = titles.where(
            (n) => n.skill == HandleSkill.value(skill)
    ).toList();
    var progress = 0;
    targets.forEach((title) {
      final count = counts.firstWhere((element) => element.id == title.id);
      progress += _calculateCount(count.count, title);
    });
    return _TotalTitleAchievement(skill, targets.length * 4, progress);
  }
}

class _TotalTitleAchievement {
  _TotalTitleAchievement(this.skill, this.total, this.progress);

  Skill skill;
  int total;
  int progress;

  double get rate => progress/total;
}

enum _Menu { license }