import 'package:flutter/material.dart';

enum Skill {
  arm,
  stomach,
  leg,
  yoga,
}

mixin HandleSkill {
  static String title(Skill skill) {
    switch (skill) {
      case Skill.arm:
        return 'うで';
      case Skill.stomach:
        return 'はら';
      case Skill.leg:
        return 'あし';
      case Skill.yoga:
        return 'ヨガ';
    }
  }

  static int value(Skill skill) {
    switch (skill) {
      case Skill.arm:
        return 1;
      case Skill.stomach:
        return 2;
      case Skill.leg:
        return 3;
      case Skill.yoga:
        return 4;
    }
  }

  static Color color(Skill skill) {
    switch (skill) {
      case Skill.arm:
        return Color(int.parse('0xffd22216'));
      case Skill.stomach:
        return Color(int.parse('0xfff4d909'));
      case Skill.leg:
        return Color(int.parse('0xff4c00dc'));
      case Skill.yoga:
        return Color(int.parse('0xff29c37e'));
    }
  }

  static Skill makeFromInt(int skill) {
    switch (skill) {
      case 1:
        return Skill.arm;
      case 2:
        return Skill.stomach;
      case 3:
        return Skill.leg;
      case 4:
        return Skill.yoga;
      default:
        return Skill.arm;
    }
  }
}