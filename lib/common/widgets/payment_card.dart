import 'package:chitti_meet/modules/chat_module/models/payment_model.dart';
import 'package:flutter/material.dart';
import '../../modules/chat_module/presentation/payment_screen.dart';

class PaymentCard extends StatelessWidget {
  const PaymentCard({super.key, required this.paymentDetails});
  final PaymentModel paymentDetails;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 328,
          height: 190,
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: const ShapeDecoration(
                  color: Color(0x26DF2E38),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                ),
                child: Center(
                  child: Text(
                    '${paymentDetails.topLabel}',
                    style: const TextStyle(
                      color: Color(0xFFDF2E38),
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      height: 1.33,
                      letterSpacing: 0.12,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 14,
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "${paymentDetails.title}",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      height: 1.56,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '${paymentDetails.description}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.8),
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        height: 1.33,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
              GestureDetector(
                onTap: () async {
                  showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) {
                        return SizedBox(
                          height: MediaQuery.of(context).size.height * 0.9,
                          child: PaymentScreeen(
                            url: '${paymentDetails.link}',
                          ),
                        );
                      });
                },
                child: Container(
                  width: double.infinity,
                  height: 56,
                  padding:
                      const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: ShapeDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment(1.00, -0.03),
                        end: Alignment(-1, 0.03),
                        colors: [Colors.black, Color(0xFF2D2D2D)],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        paymentDetails.buttonText.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          height: 1.43,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
