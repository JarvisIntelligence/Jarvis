import 'package:flutter/material.dart';

class PasswordStrengthIndicator extends StatefulWidget {
  const PasswordStrengthIndicator({super.key, required this.numberOfIndicator,
    required this.indicatorText, required this.indicatorColor
  });

  final String indicatorText;
  final Color indicatorColor;
  final int numberOfIndicator;

  @override
  State<PasswordStrengthIndicator> createState() => _PasswordStrengthIndicatorState();
}

class _PasswordStrengthIndicatorState extends State<PasswordStrengthIndicator> {

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Visibility(
                visible: (widget.numberOfIndicator >= 1) ? true : false,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.1,
                  height: 2,
                  decoration: BoxDecoration(
                    color: widget.indicatorColor,
                    borderRadius: BorderRadius.circular(20.0), // Adjust the radius as needed
                  ),
                ),
              ),
              const SizedBox(width: 5,),
              Visibility(
                visible: (widget.numberOfIndicator >= 2) ? true : false,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.1,
                  height: 2,
                  decoration: BoxDecoration(
                    color: widget.indicatorColor,
                    borderRadius: BorderRadius.circular(20.0), // Adjust the radius as needed
                  ),
                ),
              ),
              const SizedBox(width: 5,),
              Visibility(
                visible: (widget.numberOfIndicator >= 3) ? true : false,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.1,
                  height: 2,
                  decoration: BoxDecoration(
                    color: widget.indicatorColor,
                    borderRadius: BorderRadius.circular(20.0), // Adjust the radius as needed
                  ),
                ),
              ),
              const SizedBox(width: 5,),
              Visibility(
                visible: (widget.numberOfIndicator >= 4) ? true : false,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.1,
                  height: 2,
                  decoration: BoxDecoration(
                    color: widget.indicatorColor,
                    borderRadius: BorderRadius.circular(20.0), // Adjust the radius as needed
                  ),
                ),
              ),
              const SizedBox(width: 5,),
              Visibility(
                visible: (widget.numberOfIndicator >= 5) ? true : false,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.1,
                  height: 2,
                  decoration: BoxDecoration(
                    color: widget.indicatorColor,
                    borderRadius: BorderRadius.circular(20.0), // Adjust the radius as needed
                  ),
                ),
              ),
            ],
          ),
          Text(widget.indicatorText, style: TextStyle(
              fontSize: 10,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              color: widget.indicatorColor
          ),)
        ],
      ),
    );
  }
}
