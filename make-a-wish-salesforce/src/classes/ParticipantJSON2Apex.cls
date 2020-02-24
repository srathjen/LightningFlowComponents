public class ParticipantJSON2Apex{

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

public  List<ParticipantJSON2Apex> parse(String participant) {
return (List<ParticipantJSON2Apex>) System.JSON.deserialize(participant, List<ParticipantJSON2Apex>.class);
}
}