import 'package:flutter/material.dart';
import 'package:lifeshareapplication/tabbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecipientFilterDrawer extends StatefulWidget {
  final void Function(String?, String?) onFilterChanged;

  const RecipientFilterDrawer({super.key, required this.onFilterChanged});

  @override
  State<RecipientFilterDrawer> createState() => _RecipientFilterDrawerState();
}

Color divide = const Color.fromARGB(255, 1, 46, 69);
TextStyle textDesign = const TextStyle(
    color: Color.fromARGB(255, 1, 46, 69),
    fontSize: 17,
    fontWeight: FontWeight.w700);
TextStyle color = const TextStyle(
    color: Color.fromARGB(255, 1, 46, 69), fontWeight: FontWeight.w500);

class _RecipientFilterDrawerState extends State<RecipientFilterDrawer> {
  late SharedPreferences _prefs;
  String? selectedBloodGroup;
  String? selectedOrganType;

  @override
  void initState() {
    super.initState();
    loadFilterPreferencesRecipient();
  }

  Future<void> loadFilterPreferencesRecipient() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedBloodGroup = _prefs.getString('recipientSelectedBloodGroup');
      selectedOrganType = _prefs.getString('recipientSelectedOrganType');
    });
  }

  void _savePreferences() async {
    await _prefs.setString(
        'recipientSelectedBloodGroup', selectedBloodGroup ?? '');
    await _prefs.setString(
        'recipientSelectedOrganType', selectedOrganType ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.6,
      backgroundColor: const Color.fromARGB(255, 228, 247, 253),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 60, 5, 10),
              child: Container(
                height: 150.0,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 2, 105, 112),
                  image: DecorationImage(
                    image: AssetImage('assets/mainpage.jpeg'),
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(50.0),
                    bottomRight: Radius.circular(50.0),
                  ),
                ),
              ),
            ),
            Container(
              alignment: Alignment
                  .center, // Align the content of the container to the center
              decoration: BoxDecoration(
                color: Colors.grey
                    .withOpacity(0.1), // Background color when tapped
              ),
              child: ListTile(
                trailing: Icon(Icons.home_rounded, size: 40, color: divide),
                title: Text(
                  'Home',
                  style: textDesign,
                ),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const MyTabbar()));
                },
              ),
            ),
            Divider(
              height: 20, // Adjust the height of the divider
              thickness: 2, // Adjust the thickness of the divider line
              color: divide, // Set the color of the divider line
              indent: 20, // Set the left indent of the divider line
              endIndent: 20,
            ),
            ListTile(
              title: Text(
                'Blood Group',
                style: textDesign,
              ),
              dense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final bloodGroup in [
                  'A+',
                  'A-',
                  'B+',
                  'B-',
                  'AB+',
                  'AB-',
                  'O+',
                  'O-'
                ])
                  FilterSwitch(
                    label: bloodGroup,
                    isSelected: selectedBloodGroup == bloodGroup,
                    onChanged: (value) {
                      setState(() {
                        selectedBloodGroup = value ? bloodGroup : null;
                        _savePreferences();
                        widget.onFilterChanged(
                            selectedBloodGroup, selectedOrganType);
                      });
                    },
                  ),
              ],
            ),
            Divider(
              height: 20, // Adjust the height of the divider
              thickness: 2, // Adjust the thickness of the divider line
              color: divide, // Set the color of the divider line
              indent: 20, // Set the left indent of the divider line
              endIndent: 20,
            ),
            Center(
              child: ListTile(
                title: Text(
                  'Organ Type',
                  style: textDesign,
                ),
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final organType in ['Liver', 'Kidney', 'Intestine'])
                  FilterSwitch(
                    label: organType,
                    isSelected: selectedOrganType == organType,
                    onChanged: (value) {
                      setState(() {
                        selectedOrganType = value ? organType : null;
                        _savePreferences();
                        widget.onFilterChanged(
                            selectedBloodGroup, selectedOrganType);
                      });
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FilterSwitch extends StatelessWidget {
  final String label;
  final bool isSelected;
  final ValueChanged<bool> onChanged;

  const FilterSwitch({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          label,
          style: textDesign,
        ),
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Switch(
            value: isSelected,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
