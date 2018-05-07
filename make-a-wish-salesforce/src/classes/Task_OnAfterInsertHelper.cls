/*****************************************************************************************************************
Author      : MST Solutions
Date        : 6/1/2016
Description : When new Task is inserted then this Task_OnAfterInsertHelper is called by Task_OnAfterInsertHandler
then it will call the updateVolunteerInterviewDate method based on Task subject.
*******************************************************************************************************************/

Public class Task_OnAfterInsertHelper{
/***************************************************************************************
This method is used to assign the value to InterviewDateSet__c field.
****************************************************************************************/
public static void updateVolunteerInterviewDate(Set<Id> volunteerIdsSet, String action){
        list<Contact> updateVolunteerContactList = new List<Contact>();
        Set<Id> volunteerRoleBaseIdsSet = new Set<Id>();
        if(action == 'insert'){
            for(Contact currentContact:[Select ID from Contact WHERE ID IN:volunteerIdsSet AND RecordType.Name = 'Volunteer Contact']){
                currentContact.InterviewDateSet__c = 'Interview Task Created';
                updateVolunteerContactList.add(currentContact);
            }
        }
        
        if(action == 'update'){
            
            for(Volunteer_Roles__c newVolRole :[Select Id,Volunteer_Name__c FROM Volunteer_Roles__c WHERE Chapter_Role__r.Background_Check_Required__c = true AND Volunteer_Name__c IN:volunteerIdsSet ]){
                volunteerRoleBaseIdsSet.add(newVolRole.Volunteer_Name__c);
            }
            if(volunteerRoleBaseIdsSet.size() > 0 ){
                for(Contact newContact: [Select ID from Contact WHERE ID IN:volunteerRoleBaseIdsSet AND RecordType.Name = 'Volunteer Contact']){
                    newContact.InterviewDateSet__c = 'Interview Task Completed';
                    updateVolunteerContactList.add(newContact);
                }
            }
            
        }
        
        if(updateVolunteerContactList.size() > 0){
            update updateVolunteerContactList;
        }
     }

}