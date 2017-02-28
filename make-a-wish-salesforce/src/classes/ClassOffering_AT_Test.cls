@isTest
public class ClassOffering_AT_Test{
// Start Time greater than End Time.
 public static testMethod void createClassOffering(){
 
       Class_Offering__c currOffering = new Class_Offering__c();
       currOffering.Date__c = Date.Today()+3;
       currOffering.Start_Time__c = '9:30:AM';
       currOffering.end_time__c = '9:00:AM';
       Database.SaveResult result = Database.insert(currOffering,false);
       System.assertEquals('End Time should be greater than start time',result.getErrors()[0].getMessage());
 }
 // Entered the Invalid start time.
 public static testMethod void createClassOfferingSameTime(){
 
       Class_Offering__c currOffering = new Class_Offering__c();
       currOffering.Date__c = Date.Today()+3;
       currOffering.Start_Time__c = '7:00:PM';
       currOffering.end_time__c = '10:00:AM';
       Database.SaveResult result = Database.insert(currOffering,false);
       System.assertEquals('Please enter valid Start and End Time',result.getErrors()[0].getMessage());
 }
 // Start Time is blank.
 public static testMethod void startTimeBlank(){
 
       Class_Offering__c currOffering = new Class_Offering__c();
       currOffering.Date__c = Date.Today()+3;
       currOffering.end_time__c = '10:00:AM';
       Database.SaveResult result = Database.insert(currOffering,false);
       System.assertEquals('Please Enter Start Time',result.getErrors()[0].getMessage());
 }
}