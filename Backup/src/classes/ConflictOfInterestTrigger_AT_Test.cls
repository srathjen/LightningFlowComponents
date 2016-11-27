@isTest
public class ConflictOfInterestTrigger_AT_Test{
  // Mapping fields.
  public static testMethod void createConflictOfInterest(){
        Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
        Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
         Conflict_Of_Interest__c  coiRec = OrientationandTrainingUtil.createCOI(volunteerContact.Id);
        }
 
   public static testMethod void updateConflictOfInterest(){
        Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
        Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
         Conflict_Of_Interest__c  coiRec = OrientationandTrainingUtil.createCOI(volunteerContact.Id);
         coiRec.Expiration_Date__c = Date.Today().addYears(1);
         update coiRec;
        }
}