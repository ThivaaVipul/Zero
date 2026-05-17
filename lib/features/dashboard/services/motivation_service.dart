import 'dart:math';
import 'package:flutter/material.dart';

class MotivationMessage {
  final String text;
  final String author;
  final IconData icon;

  MotivationMessage({required this.text, required this.author, required this.icon});
}

class MotivationService {
  static final List<MotivationMessage> _messages = [
    MotivationMessage(
      text: "Discipline is choosing between what you want now and what you want most.",
      author: "Abraham Lincoln",
      icon: Icons.self_improvement,
    ),
    MotivationMessage(
      text: "Fasting is the first principle of medicine.",
      author: "Rumi",
      icon: Icons.favorite_border,
    ),
    MotivationMessage(
      text: "Focus on the clarity that fasting brings, not the hunger.",
      author: "Mindful Living",
      icon: Icons.wb_sunny_outlined,
    ),
    MotivationMessage(
      text: "Your body is a temple, but only if you treat it as one.",
      author: "Ancient Wisdom",
      icon: Icons.account_balance_outlined,
    ),
    MotivationMessage(
      text: "The hunger is a sign that your body is switching to its clean fuel.",
      author: "Zero Science",
      icon: Icons.bolt,
    ),
    MotivationMessage(
      text: "Patience is the companion of wisdom.",
      author: "Saint Augustine",
      icon: Icons.hourglass_empty,
    ),
    MotivationMessage(
      text: "Consistency is the mother of mastery.",
      author: "Robin Sharma",
      icon: Icons.auto_awesome,
    ),
  ];

  static MotivationMessage getRandomMessage() {
    return _messages[Random().nextInt(_messages.length)];
  }

  static String getProgressEncouragement(double progress) {
    if (progress < 0.25) return "A great journey begins with a single step.";
    if (progress < 0.5) return "You're approaching the halfway mark. Stay steady.";
    if (progress < 0.75) return "The hardest part is behind you. Keep pushing!";
    if (progress < 1.0) return "Almost there! Your body is in peak autophagy mode.";
    return "Goal reached! Take a moment to appreciate your discipline.";
  }
}
