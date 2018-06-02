/*****************************************************************************************************************
Author      : MST Solutions
Date        : 5/27/2016
Description : When a new volunteer Opportunity record insert then it will call the VolOpportunity_OnAfter_Insert_Helper class based 
on the collection size() > 0.
Modification Log: 
04/17/2018 - Kanagaraj - WVC-1885
*******************************************************************************************************************/

public class VolOpportunity_OnAfter_Insert_Handler{
    
      /***************************************************************************************************************    
This method is used to get the new Volunteer Opportunity record values then it will added into the collections, then
It will call the corresponding methods in VolOpportunity_OnAfter_Insert_Helper calss.
*****************************************************************************************************************/   
    public static void OnAfterInsert(List<Volunteer_Opportunity__c> newVolOpportunityList){
       List<Volunteer_Opportunity__c> volunteerOppList = new List<Volunteer_Opportunity__c>();
        Map<String, List<Volunteer_Opportunity__c >> volunteerOppMap = new Map<String, List<Volunteer_Opportunity__c>>();
        Set<ID> volunteerOppName=new Set<ID>();
        
        for(Volunteer_Opportunity__c currRec : newVolOpportunityList){
            if(currRec.Status__c == 'Approved' && trigger.isinsert && currRec.Migrated_Record__c==false){
                volunteerOppName.add(currRec.Volunteer_Name__c);
            }
            if(currRec.Migrated_Record__c == True && Trigger.isInsert){
                volunteerOppList.add(currRec);
            }
        }
        
         for(Volunteer_Opportunity__c  currRec :[SELECT id, ownerId, owner.UserRoleId, Owner.UserRole.Name, Chapter_Name__c, 
                                                Chapter_Name__r.Name FROM Volunteer_Opportunity__c WHERE Id IN :Trigger.newMap.keySet()]){
            if(currRec.Chapter_Name__c != Null && currRec.Owner.userRole.Name == 'National Staff') 
            {
                if(volunteerOppMap.containsKey(currRec.Chapter_Name__r.Name))
                    volunteerOppMap.get(currRec.Chapter_Name__r.Name).add(currRec);
                else
                    volunteerOppMap.put(currRec.Chapter_Name__r.Name, new List<Volunteer_Opportunity__c>{currRec});
            }
        } 
        if(volunteerOppName.size() > 0){
            VolOpportunity_OnAfter_Insert_Helper.Updatecontacts(volunteerOppName);
        }
        if(volunteerOppMap.size() > 0){
            ChapterStaffRecordSharing_AC.volunteerOpportunitySharing(volunteerOppMap);
        }
    }
}