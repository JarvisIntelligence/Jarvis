import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ReportBug extends StatefulWidget {
  const ReportBug({super.key});

  @override
  State<ReportBug> createState() => _ReportBugState();
}

class _ReportBugState extends State<ReportBug> {
  String? dropDownValue;
  String? reason;

  final List<String> dropdownItems = [
    "Report a bug",
    "Suggest a new feature or update",
  ];

  final List<String> reasonItems = [
    "App Crashes",
    "Incorrect Functionality",
    "UI/UX Issues",
    "Performance Issues",
    "Unexpected Behavior",
    "Compatibility Issues",
    "Other"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 5, top: 50, bottom: 20),
          child: Column(
            children: [
              backHeader(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                margin: const EdgeInsets.only(top: 40, bottom: 10, right: 20, left: 10),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('I would like to', style: TextStyle(
                            color: Theme.of(context).colorScheme.scrim,
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w400
                        ),),
                        const SizedBox(width: 20,),
                        Expanded(
                            child: DropdownButtonFormField(
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(8.32)),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16.34, vertical: 8.32),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.32),
                                  borderSide: BorderSide(
                                    color: Theme.of(context).colorScheme.scrim, // Border color when enabled
                                    width: 1, // Border thickness when enabled
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.32),
                                  borderSide: BorderSide(
                                    color: Theme.of(context).colorScheme.tertiary, // Border color when focused
                                    width: 2.0, // Border thickness when focused
                                  ),
                                ),
                              ),
                              value: dropDownValue,
                              items: dropdownItems.map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                    value: value,
                                    child: Container(
                                      constraints: const BoxConstraints(
                                          maxWidth: 120
                                      ),
                                      child: Text(value,
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.scrim,
                                          fontFamily: 'Inter',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          overflow: dropDownValue == value ? TextOverflow.ellipsis : TextOverflow.visible,
                                        ),),
                                    )
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  dropDownValue = newValue!;
                                });
                              },
                              hint: Text('Select an option', style: TextStyle(
                                  color: Theme.of(context).colorScheme.scrim,
                                  fontFamily: 'Inter',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400
                              ),),
                            )
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Title', style: TextStyle(
                            color: Theme.of(context).colorScheme.scrim,
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.bold
                        ),),
                        const SizedBox(
                          height: 10,
                        ),
                        TextField(
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSecondaryContainer,
                              fontSize: 10,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.normal,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Enter a title',
                              labelStyle: TextStyle(
                                  color: Theme.of(context).colorScheme.onPrimary,
                                  fontFamily: 'Inter',
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16.34, vertical: 8.32),
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(8.32)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.32),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.scrim, // Border color when enabled
                                  width: 1, // Border thickness when enabled
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.32),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.tertiary, // Border color when focused
                                  width: 2.0, // Border thickness when focused
                                ),
                              ),
                            )
                        )
                      ],
                    ),
                    Visibility(
                      visible: dropDownValue == 'Report a bug' ? true : false,
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            Text('Reason for reporting this bug?', style: TextStyle(
                                color: Theme.of(context).colorScheme.scrim,
                                fontFamily: 'Inter',
                                fontSize: 12,
                                fontWeight: FontWeight.bold
                            ),),
                            const SizedBox(
                              height: 10,
                            ),
                            Wrap(
                              spacing: 6,
                              runSpacing: 8,
                              children: reasonItems.map<Widget>((String value) {
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      reason = value;
                                    });
                                  },
                                  child: Container(
                                    constraints: const BoxConstraints(
                                        maxWidth: 135
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 10
                                    ),
                                    decoration: BoxDecoration(
                                        color: (reason == value) ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.secondary,
                                    ),
                                    child: Center(
                                      child: Text(value, textAlign: TextAlign.center, style: TextStyle(
                                          color: Theme.of(context).colorScheme.scrim,
                                          fontFamily: 'Inter',
                                          fontSize: 10,
                                          fontWeight: FontWeight.w400,
                                      ),),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            attachScreenshots(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    bugDescription(),
                    const SizedBox(
                      height: 20,
                    ),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        minimumSize: const Size(double.infinity, 35),
                        padding: EdgeInsets.zero,
                      ),
                      child: Text(
                        'Submit',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.scrim,
                            fontSize: 10,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget backHeader() {
    return Row(
      children: [
        IconButton(
            onPressed: () {
              context.pop();
            },
            icon: Icon(
              Icons.arrow_back,
              size: 20,
              color: Theme.of(context).colorScheme.scrim,
            )),
        Text(
          'Report a bug',
          style: TextStyle(
              fontFamily: 'Inter',
              color: Theme.of(context).colorScheme.scrim,
              fontSize: 14,
              fontWeight: FontWeight.bold),
        )
      ],
    );
  }

  Widget bugDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Please provide more details so we can understand.", style: TextStyle(
            color: Theme.of(context).colorScheme.scrim,
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.bold
        ),),
        const SizedBox(
          height: 10,
        ),
        TextField(
            minLines: 8,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSecondaryContainer,
              fontSize: 10,
              fontFamily: 'Inter',
              fontWeight: FontWeight.normal,
            ),
            decoration: InputDecoration(
              labelText: 'Enter a description',
              labelStyle: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontFamily: 'Inter',
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              alignLabelWithHint: true,
              contentPadding: const EdgeInsets.only(
                  left: 16.34,
                  right: 16.34,
                  top: 16.34,
                  bottom: 8.32
              ),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.32)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.32),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.scrim, // Border color when enabled
                  width: 1, // Border thickness when enabled
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.32),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.tertiary, // Border color when focused
                  width: 2.0, // Border thickness when focused
                ),
              ),
            )
        )
      ],
    );
  }

  Widget attachScreenshots() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Attach Screenshots (Optional)', style: TextStyle(
            color: Theme.of(context).colorScheme.scrim,
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.bold
        ),),
        const SizedBox(
          height: 10,
        ),
        GestureDetector(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(border: Border.all(
                color: Theme.of(context).colorScheme.scrim, // Border color
                width: 1.0, // Border width
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.folder, color: Theme.of(context).colorScheme.scrim, size: 16,),
                const SizedBox(width: 5,),
                Text('Choose a file', style: TextStyle(
                    color: Theme.of(context).colorScheme.scrim,
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.bold
                ),)
              ],
            ),
          ),
        )
      ],
    );
  }
}
