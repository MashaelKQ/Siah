import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/weekly_quest_service.dart';
import '../theme/app_text_styles.dart';
import '../utils/snackbar_helper.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  bool _isRedeeming = false;

  final List<_RewardItem> rewards = const [
    _RewardItem(
      id: 'healthy_meal',
      title: 'Healthy Meal',
      subtitle: '15% discount',
      points: 20,
      icon: Icons.restaurant_outlined,
    ),
    _RewardItem(
      id: 'spa',
      title: 'Spa Treatment',
      subtitle: '15% discount',
      points: 30,
      icon: Icons.spa_outlined,
    ),
    _RewardItem(
      id: 'gym',
      title: 'Gym Pass',
      subtitle: '15% discount',
      points: 25,
      icon: Icons.fitness_center,
    ),
    _RewardItem(
      id: 'cafe',
      title: 'Cafe Voucher',
      subtitle: '15% discount',
      points: 15,
      icon: Icons.local_cafe_outlined,
    ),
  ];

  Future<void> _redeemReward(
    _RewardItem reward,
  ) async {
    if (_isRedeeming) return;

    final user = AuthService.currentUser;

    if (user == null) {
      SnackbarHelper.show(
        context,
        'Please sign in to redeem rewards.',
      );
      return;
    }

    setState(() {
      _isRedeeming = true;
    });

    try {
      final success = await WeeklyQuestService.redeemReward(
        userId: user.uid,
        rewardId: reward.id,
        rewardTitle: reward.title,
        pointsRequired: reward.points,
      );

      if (!mounted) return;

      if (success) {
        SnackbarHelper.show(
          context,
          '${reward.title} redeemed successfully.',
        );
      } else {
        SnackbarHelper.show(
          context,
          'You do not have enough Wellness Points.',
        );
      }
    } catch (error) {
      if (!mounted) return;

      SnackbarHelper.show(
        context,
        'Unable to redeem reward.',
      );

      debugPrint(
        'Reward redemption error: $error',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isRedeeming = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Rewards',
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: user == null
            ? const Center(
                child: Text(
                  'Please sign in to view rewards.',
                ),
              )
            : StreamBuilder<int>(
                stream: WeeklyQuestService.wellnessPointsStream(
                  user.uid,
                ),
                builder: (
                  context,
                  snapshot,
                ) {
                  final points = snapshot.data ?? 0;

                  return Padding(
                    padding: const EdgeInsets.all(
                      16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // =============================================
                        // Balance Card
                        // =============================================
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(
                              18,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.stars_rounded,
                                size: 28,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Available Balance',
                                      style: AppTextStyles.caption,
                                    ),
                                    const SizedBox(
                                      height: 2,
                                    ),
                                    Text(
                                      '$points Wellness Points',
                                      style: AppTextStyles.heading2.copyWith(
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(
                          height: 18,
                        ),

                        const Text(
                          'Rewards & Vouchers',
                          style: AppTextStyles.heading2,
                        ),

                        const SizedBox(
                          height: 4,
                        ),

                        const Text(
                          'Redeem your points for available rewards.',
                          style: AppTextStyles.caption,
                        ),

                        const SizedBox(
                          height: 14,
                        ),

                        // =============================================
                        // Rewards Grid
                        // =============================================
                        Expanded(
                          child: GridView.builder(
                            itemCount: rewards.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,

                              // More vertical space for each card
                              childAspectRatio: 0.78,
                            ),
                            itemBuilder: (
                              context,
                              index,
                            ) {
                              final reward = rewards[index];

                              return _RewardCard(
                                reward: reward,
                                canRedeem: points >= reward.points,
                                isRedeeming: _isRedeeming,
                                onRedeem: () => _redeemReward(
                                  reward,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}

// =====================================================================
// Reward Card
// =====================================================================
class _RewardCard extends StatelessWidget {
  const _RewardCard({
    required this.reward,
    required this.canRedeem,
    required this.isRedeeming,
    required this.onRedeem,
  });

  final _RewardItem reward;
  final bool canRedeem;
  final bool isRedeeming;
  final VoidCallback onRedeem;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(
          12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =============================================
            // Reward Icon
            // =============================================
            Container(
              height: 52,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(
                  12,
                ),
              ),
              child: Icon(
                reward.icon,
                size: 29,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            // =============================================
            // Reward Title
            // =============================================
            Text(
              reward.title,
              style: AppTextStyles.title.copyWith(
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(
              height: 3,
            ),

            // =============================================
            // Discount
            // =============================================
            Text(
              reward.subtitle,
              style: AppTextStyles.caption.copyWith(
                fontSize: 12,
              ),
            ),

            const SizedBox(
              height: 3,
            ),

            // =============================================
            // Points
            // =============================================
            Text(
              '${reward.points} points',
              style: AppTextStyles.caption.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),

            const Spacer(),

            // =============================================
            // Redeem Button
            // =============================================
            SizedBox(
              width: double.infinity,
              height: 36,
              child: FilledButton(
                onPressed: canRedeem && !isRedeeming ? onRedeem : null,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                  ),
                  minimumSize: const Size(
                    0,
                    36,
                  ),
                ),
                child: Text(
                  canRedeem ? 'Redeem' : 'Need ${reward.points} pts',
                  style: const TextStyle(
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================================
// Reward Model
// =====================================================================
class _RewardItem {
  const _RewardItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.points,
    required this.icon,
  });

  final String id;
  final String title;
  final String subtitle;
  final int points;
  final IconData icon;
}
