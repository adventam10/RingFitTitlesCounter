import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'exercise_count_repository.dart';
import 'title_achievement.dart';

class ThirdPage extends StatefulWidget {
  const ThirdPage({Key? key, required this.achievement}) : super(key: key);

  final TitleAchievement achievement;

  @override
  State<ThirdPage> createState() => _ThirdPageState();
}

class _ThirdPageState extends State<ThirdPage> {

  final _countRepository = ExerciseCountRepository();
  var _sliderValue = 0.0;
  double get _rating {
    return TitleAchievement(
        widget.achievement.title,
        widget.achievement.name,
        widget.achievement.total,
        _sliderValue.toInt()
    ).rating;
  }

  @override
  void initState() {
    super.initState();
    _sliderValue = widget.achievement.progress.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.achievement.title.name),
        ),
        body: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _ratingBar(_calculateRankRating(
                    widget.achievement.title.rank1,
                    _sliderValue.toInt()
                ), widget.achievement.title.rank1),
                _ratingBar(_calculateRankRating(
                    widget.achievement.title.rank2 - widget.achievement.title.rank1,
                    _sliderValue.toInt() - widget.achievement.title.rank1
                ), widget.achievement.title.rank2),
                _ratingBar(_calculateRankRating(
                    widget.achievement.title.rank3 - widget.achievement.title.rank2,
                    _sliderValue.toInt() - widget.achievement.title.rank2
                ), widget.achievement.title.rank3),
                _ratingBar(_calculateRankRating(
                    widget.achievement.title.rank4 - widget.achievement.title.rank3,
                    _sliderValue.toInt() - widget.achievement.title.rank3
                ), widget.achievement.title.rank4),
                const SizedBox(height: 16),
                Text(
                  '${_sliderValue.toInt()}  回',
                  style: const TextStyle(fontSize: 18),
                ),
                Slider(
                  value: _sliderValue,
                  min: 0,
                  max: widget.achievement.total.toDouble(),
                  divisions: widget.achievement.total,
                  onChanged: (double value) {
                    _updateCount(value.toInt());
                    setState(() {
                      _sliderValue = value.roundToDouble();
                    });
                  },
                ),
                Text(_makeNextRankText()),
                _countButtons(),
              ],
            )
        )
    );
  }

  Widget _ratingBar(double rating, int rank) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RatingBarIndicator(
          rating: rating,
          itemBuilder: (context, index) => const Icon(
            Icons.star,
            color: Colors.amber,
          ),
          itemCount: 1,
          itemSize: 24,
          direction: Axis.horizontal,
        ),
        const SizedBox(width: 8),
        Text(
          '$rank 回',
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _countButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _countButton(-100, '-100'),
        const SizedBox(width: 8),
        _countButton(-10, '-10'),
        const SizedBox(width: 32),
        _countButton(10, '+10'),
        const SizedBox(width: 8),
        _countButton(100, '+100'),
      ],
    );
  }

  Widget _countButton(int count, String text) {
    return ElevatedButton(
      onPressed: () {
        var value = _sliderValue.toInt();
        value += count;
        if (value > widget.achievement.total) {
          value = widget.achievement.total;
        } else if (value < 0) {
          value = 0;
        }
        _updateCount(value);
        setState(() {
          _sliderValue = value.roundToDouble();
        });
      },
      child: Text(text),
    );
  }

  String _makeNextRankText() {
    final value = _sliderValue.toInt();
    final title = widget.achievement.title;
    if (value >= title.rank4) {
      return '全称号獲得済み';
    }
    var nextRank = title.rank1;
    if (value >= title.rank1) {
      nextRank = title.rank2;
      if (value >= title.rank2) {
        nextRank = title.rank3;
        if (value >= title.rank3) {
          nextRank = title.rank4;
        }
      }
    }
    return '次の称号まであと ${nextRank - value} 回';
  }

  double _calculateRankRating(int rankCount, int count) {
    if (rankCount > count) {
      return count/rankCount;
    }
    return 1;
  }

  void _updateCount(int count) {
    _countRepository.update(ExerciseCount(
        widget.achievement.title.id,
        count,
        widget.achievement.title.skill,
        widget.achievement.title.name
    ));
  }
}
