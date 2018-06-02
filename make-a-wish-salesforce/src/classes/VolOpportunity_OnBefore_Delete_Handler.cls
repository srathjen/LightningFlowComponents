/*****************************************************************************************************************
Author      : MST Solutions
Date        : 5/27/2016
Description : When a Volunteer Opportunity record delete then it will call the VolOpportunity_OnBefore_Delete_Helper class based 
on the collection size() > 0.
Modification Log: 
04/17/2018 - Kanagaraj - WVC-1885
*******************************************************************************************************************/
public class VolOpportunity_OnBefore_Delete_Handler{
     
     // When volunteer Opportunity record gets deleted then it will call the VolOpportunity_OnBefore_Delete_Helper class methods.
     public static void onBeforeDelete(List<Volunteer_Opportunity__c> oldVolOpportunityList){
         
            Set<Id> updateUserSet = new Set<Id>();
            Set<Id> volconId= new Set<Id>();
            for(Volunteer_Opportunity__c oldDbRec : oldVolOpportunityList){
                if(oldDbRec.Volunteer_Name__c != Null){
                    updateUserSet.add(oldDbRec.Id);
                    volconId.add(oldDbRec.Volunteer_Name__c );
                }
            }
            
            if(updateUserSet.size() > 0) {
            VolOpportunity_OnBefore_Delete_Helper.updateUserRoleId(updateUserSet,volconId);
        }
     }    
}