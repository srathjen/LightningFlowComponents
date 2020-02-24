public class ParentGuardianJSON2Apex{

public String workTelephone;
public String tshirtSize;
public String Street;
public String State;
public Boolean sameParentGuardianFlag;
public String residingWishMedical;
public String relId;
public String relationship;
public String PostalCode;
public String mobileTelephone;
public String MiddleName;
public String medicalNeeds;
public String lastName;
public String isChildParticipants;
public String homeTelephone;
public String firstName;
public String Email;
public String dob;
public String City;

public  List<ParentGuardianJSON2Apex> parse(String parentGuardian) {
return (List<ParentGuardianJSON2Apex>) System.JSON.deserialize(parentGuardian, List<ParentGuardianJSON2Apex>.class);
}
}