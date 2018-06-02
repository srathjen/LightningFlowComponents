/*****************************************************************************************************************
Author      : MST Solutions
Date        : 5/27/2016
Description : When a new Volunteer Oppportunity record insert then methods in this class will be invoked based on the condition.
Modification Log: 
04/17/2018 - Kanagaraj - WVC-1885
*******************************************************************************************************************/

public class VolOpportunity_OnAfter_Insert_Helper{
    
    // Update the number of volunteer Opportunity assigned to the volunteer in contact record.
    public static void Updatecontacts(Set <ID> volunteerOppName){
        List<Contact> conList=new List<Contact>();
        try{
        for(Contact  Con:[SELECT Id,Number_of_Assignments__c,Name,(select id,Volunteer_Name__c from Volunteer_Opportunities__r where Volunteer_Name__c IN:volunteerOppName) FROM Contact  WHERE ID IN:volunteerOppName]){
            Contact cont=new Contact();
            cont.Number_of_Assignments__c=Con.Volunteer_Opportunities__r.size();
            cont.id=Con.Id;
            conList.add(cont);
        }
        update conList;
        }
        catch(Exception ex){
           for(Volunteer_Opportunity__c currRec : [SELECT Id,Volunteer_Name__c FROM Volunteer_Opportunity__c WHERE Volunteer_Name__c IN: volunteerOppName]){
                ErrorMessage_AC.createdebugRec('VolOpportunity_OnAfter_Insert_Helper',String.valueof(currRec),String.valueOf(ex.getCause()),'Updatecontacts',currRec.Id,ex.getStackTraceString(),'Error');
            }
            for(Volunteer_Opportunity__c currRec : [SELECT Id,Volunteer_Name__c FROM Volunteer_Opportunity__c WHERE Volunteer_Name__c IN: volunteerOppName]){
                currRec.addError(Label.Debug_log_error_message);
            }
       }
    }
}