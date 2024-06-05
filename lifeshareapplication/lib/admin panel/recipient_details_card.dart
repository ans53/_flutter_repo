import 'package:flutter/material.dart';

class RecipientDetailsCard extends StatefulWidget {
  final String name;
  final String phone;
  final bool isOrganRequired;
  final String bloodGroup;
  final String bloodType;
  final String quantity;
  final String organType;
  final String requiredByDate;
  final String id;
  final String city;
  final String state;
  final String country;
  final Function(String, BuildContext) onDelete;
  const RecipientDetailsCard({
    super.key,
    required this.name,
    required this.phone,
    required this.bloodGroup,
    required this.bloodType,
    required this.isOrganRequired,
    required this.requiredByDate,
    required this.quantity,
    required this.organType,
    required this.id,
    required this.city,
    required this.state,
    required this.country,
    required this.onDelete,
  });

  @override
  State<RecipientDetailsCard> createState() => _RecipientDetailsCardState();
}

class _RecipientDetailsCardState extends State<RecipientDetailsCard> {
  bool isVisible = true;

  @override
  Widget build(BuildContext context) {
    TextStyle txt = const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
        fontSize: 12,
        letterSpacing: 2);
    Widget bloodisRequired() {
      return Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Quantity",
              style: txt,
            ),
            Text(widget.quantity, style: txt),
          ],
        ),
      );
    }

    Widget organisRequired() {
      return Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Ogan Type",
              style: txt,
            ),
            Text(widget.organType, style: txt),
          ],
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      height: isVisible ? 330.0 : 0.0,
      child: Card(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        shadowColor: const Color.fromARGB(255, 9, 100, 148),
        elevation: 20,
        color: const Color.fromARGB(255, 1, 46, 69),
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Recipient Name",
                        style: txt,
                      ),
                      Text(widget.name, style: txt),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Mobile Number",
                        style: txt,
                      ),
                      Text(widget.phone, style: txt),
                    ],
                  ),
                ),
                if (widget.isOrganRequired)
                  organisRequired()
                else
                  bloodisRequired(),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Blood Group",
                        style: txt,
                      ),
                      Text(widget.bloodGroup, style: txt),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Location",
                        style: txt,
                      ),
                      Text(
                        '${widget.country} ${widget.state} \n ${widget.city} ',
                        style: txt,
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Required by Date",
                        style: txt,
                      ),
                      Text(widget.requiredByDate.split('')[0], style: txt),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Remove Request: ${widget.id}",
                        style: txt,
                      ),
                      Visibility(
                        visible: isVisible,
                        child: IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.amber,
                            size: 25,
                          ),
                          onPressed: () {
                            _showConfirmationDialog();
                            setState(() {
                              isVisible = !isVisible;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
        ),
      ),
    );
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          content: const Text('Do you want to Delete this request?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onDelete(widget.id, context);
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }
}
