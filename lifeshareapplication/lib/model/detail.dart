
class DonorData {
  String? uuid;
  String? name;
  int? age;
  int? weight;
 BigInt? phoneNumber;
  DateTime? dateOfLastDonation;
  String? selectedGender;
  bool isDonating;
   bool isDonatingBlood;
  bool isDonatingOrgans;
  String? selectedBloodGroup;
  String? selectedOrganType;
String? password;
bool hasDonatedBefore;
bool? hasConsent;


  DonorData( {
    this.uuid,
    this.name,
    this.age,
    this.weight,
    this.phoneNumber,
    this.dateOfLastDonation,
    this.selectedGender,
    this.isDonating = true,
    this.isDonatingOrgans = false,
    this.isDonatingBlood = false,
    this.selectedBloodGroup,
    this.selectedOrganType,
 this.hasConsent=false,
    this.password,
    this.hasDonatedBefore=false,
    
  });
   
}

class UserProfileData {
  String? uuid;
  String? name;
  String? password;
  String? country;
  String? city;
  String? state;
  BigInt? phoneNumber;

  UserProfileData({
    this.uuid,
   this.name,
   this.password,
   this.country,
   this.city,
    this.state,
    this.phoneNumber,
  });
}

class RecipientData {
  String? uuid;
  String? patientName;
  BigInt? attendeePhone;
  String? selectedBloodType;
  String? selectedBloodGroup;
  String? selectedUnits;
  DateTime? requiredByDate;
  String? country;
  String? city;
  String? state;
  bool isCritical;
  bool isBloodRecipient;
  bool isOrganRecipient;
  String? selectedOrganType;

  RecipientData({
    this.uuid,
    this.patientName,
    this.attendeePhone,
    this.selectedBloodType,
    this.selectedBloodGroup,
    this.selectedUnits,
    this.requiredByDate,
    this.country,
    this.city,
    this.state,
    this.isCritical = false,
    this.isBloodRecipient = false,
    this.isOrganRecipient = false,
    this.selectedOrganType,
  });
}

class AdminProfileData {
  String? name;
  String? password;
  BigInt? phoneNumber;

  AdminProfileData({
   this.name,
   this.password,
    this.phoneNumber,
  });
}
class Password {
  bool isPasswordValid(String password) {
    // Use a regular expression to validate the password
    RegExp regex = RegExp(
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@!#$%^&*])[a-zA-Z\d@!#$%^&*]{6,}$');
    return regex.hasMatch(password);
  }
}

