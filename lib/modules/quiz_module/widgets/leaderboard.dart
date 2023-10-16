import 'package:flutter/material.dart';

import '../../../services/responsive.dart';

class QuizLeaderboard extends StatelessWidget {
  const QuizLeaderboard({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool isDesktop =
        Responsive().getDeviceType(context) == ResponsiveDevice.desktop;
    return SingleChildScrollView(
      child: Column(
        children: [
          Text(
            'Leader Board',
            style:
                textTheme.titleLarge?.copyWith(fontSize: isDesktop ? 30 : 20),
          ),
          SizedBox(
            height: isDesktop ? 60 : 20,
          ),
          isDesktop
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(
                    3,
                    (index) => Padding(
                      padding: const EdgeInsets.all(10),
                      child: Container(
                        width: 250,
                        height: index == 1 ? 250 : 200,
                        padding: EdgeInsets.all(isDesktop ? 16 : 12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 0.5,
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ShaderMask(
                                  shaderCallback: (bounds) => LinearGradient(
                                    colors: [
                                      index == 0
                                          ? const Color(0xFF8393B7)
                                          : index == 1
                                              ? const Color(0xFFD2A76B)
                                              : const Color(0xFFA57C69),
                                      Colors.white,
                                      index == 0
                                          ? const Color(0xFF8393B7)
                                          : index == 1
                                              ? const Color(0xFFD2A76B)
                                              : const Color(0xFFA57C69),
                                    ],
                                  ).createShader(bounds),
                                  child: Text('Jacob Samro',
                                      style: textTheme.bodyMedium),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text('60 points', style: textTheme.labelSmall),
                              ],
                            ),
                            Positioned(
                              top: index == 1 ? -130 : -100,
                              child: Image.asset(
                                index == 0
                                    ? 'assets/images/silver_medal.png'
                                    : index == 1
                                        ? 'assets/images/gold_medal.png'
                                        : 'assets/images/bronze_medal.png',
                                width: index == 1 ? 250 : 200,
                                height: index == 1 ? 250 : 200,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox(),
          SizedBox(
            width: 700,
            child: ListView.builder(
                primary: false,
                shrinkWrap: true,
                itemCount: 10,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Container(
                      padding: EdgeInsets.all(isDesktop
                          ? 20
                          : index < 2
                              ? 12
                              : 16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          index == 0
                              ? Image.asset(
                                  !isDesktop
                                      ? 'assets/images/gold_medal.png'
                                      : 'assets/icons/first_place.png',
                                  width: !isDesktop ? 95 : 40,
                                  height: !isDesktop ? 95 : 40,
                                )
                              : index == 1
                                  ? Image.asset(
                                      !isDesktop
                                          ? 'assets/images/silver_medal.png'
                                          : 'assets/icons/second_place.png',
                                      width: !isDesktop ? 80 : 40,
                                      height: !isDesktop ? 80 : 40,
                                    )
                                  : index == 2
                                      ? Image.asset(
                                          !isDesktop
                                              ? 'assets/images/bronze_medal.png'
                                              : 'assets/icons/thrid_place.png',
                                          width: !isDesktop ? 80 : 40,
                                          height: !isDesktop ? 80 : 40,
                                        )
                                      : Container(
                                          width: 32,
                                          height: 32,
                                          // padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.05),
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: Center(
                                              child: Text(
                                            '${index + 1}',
                                            style: textTheme.labelSmall
                                                ?.copyWith(
                                                    color: Colors.white,
                                                    fontSize: 12),
                                          )),
                                        ),
                          const SizedBox(
                            width: 12,
                          ),
                          isDesktop
                              ? Expanded(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Giorgia Meloni',
                                        style: textTheme.bodySmall,
                                      ),
                                      Text(
                                        '60 points',
                                        style: textTheme.labelSmall,
                                      ),
                                    ],
                                  ),
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ShaderMask(
                                      shaderCallback: (bounds) =>
                                          LinearGradient(
                                        colors: [
                                          index == 0
                                              ? const Color(0xFFD2A76B)
                                              : index == 1
                                                  ? const Color(0xFF8393B7)
                                                  : index == 2
                                                      ? const Color(0xFFA57C69)
                                                      : Colors.white,
                                          Colors.white,
                                          index == 0
                                              ? const Color(0xFFD2A76B)
                                              : index == 1
                                                  ? const Color(0xFF8393B7)
                                                  : index == 2
                                                      ? const Color(0xFFA57C69)
                                                      : Colors.white,
                                        ],
                                      ).createShader(bounds),
                                      child: Text(
                                        'Giorgia Meloni',
                                        style: textTheme.bodySmall,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 4,
                                    ),
                                    Text(
                                      '60 points',
                                      style: textTheme.labelSmall?.copyWith(
                                          fontSize: 12,
                                          color: Colors.white.withOpacity(0.8)),
                                    ),
                                  ],
                                ),
                        ],
                      ),
                    ),
                  );
                }),
          )
        ],
      ),
    );
  }
}
