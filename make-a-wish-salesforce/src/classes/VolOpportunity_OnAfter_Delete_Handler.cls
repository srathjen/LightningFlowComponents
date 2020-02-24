/*****************************************************************************************************************
Author      : MST Solutions
Date        : 5/27/2016
Description : When a Volunteer Opportunity record delete then it will call the VolOpportunity_OnBefore_Delete_Helper class based 
on the collection size() > 0.
Modification Log: 
04/17/2018 - Kanagaraj - WVC-1885
*******************************************************************************************************************/

Public class VolOpportunity_OnAfter_Delete_Handler{
    
    // When volunteer Opportunity record gets deleted then it will call the VolOpportunity_OnAfter_Delete_Hepler class methods.
    public static void onAfterDelete(List<Volunteer_Opportunity__c> oldVolOppList){
      List<Volunteer_Opportunity__c> nonWishListtoupdatecount = new List<Volunteer_Opportunity__c>();
      List<Volunteer_Opportunity__c> nonwishListRegisteredList = new List<Volunteer_Opportunity__c>();
      Set<id> nonWishRegisteredUpdateSet = new Set<id>();
      Set<Id> wishIdSet = new Set<Id>();
      Map<Id,Volunteer_Opportunity__c> deletedVolunteerOpportunityMap = new Map<Id,Volunteer_Opportunity__c>();
      boolean isdelete;  
         for(Volunteer_Opportunity__c oldDbRec : oldVolOppList){
            
            if((oldDbRec.Volunteer_Name__c != Null && oldDbRec .Non_Wish_Event__c != Null && oldDbRec.Status__c == 'Approved' && oldDbRec.Reason_Inactive__c == Null && oldDbRec.Hidden_VolunteerCount_Desc__c != NULL) || (oldDbRec.Volunteer_Name__c != Null && oldDbRec .Non_Wish_Event__c != Null && oldDbRec.Status__c == 'Pending') || (oldDbRec.Volunteer_Name__c == Null && oldDbRec.Reason_Inactive__c == Null && oldDbRec .Non_Wish_Event__c != Null )){
                nonWishListtoupdatecount.add(oldDbRec);
                isdelete = true;
            }
            
            if((oldDbRec.Volunteer_Name__c != Null && oldDbRec .Non_Wish_Event__c != Null && oldDbRec.Status__c == 'Approved' && oldDbRec.Hidden_VolunteerCount_Desc__c != NULL) || (oldDbRec.Volunteer_Name__c != Null && oldDbRec .Non_Wish_Event__c != Null && oldDbRec.Status__c == 'Pending' && oldDbRec.Hidden_VolunteerCount_Desc__c != NULL)){
                
                nonwishListRegisteredList.add(oldDbRec);
                nonWishRegisteredUpdateSet.add(oldDbRec.id);
                isdelete = true;
            }
            /** WVC-2052  ***/
           /*  If(((oldDbRec.Volunteer_Name__c != Null && oldDbRec.Wish__c != Null && (oldDbRec.Status__c == 'Approved' || oldDbRec.Status__c == 'Pending'  || (oldDbRec.Status__c == 'Inactive' && oldDbRec.Reason_Inactive__c == 'Not Approved' && oldDbRec.Inactive__c == True ))) || (oldDbRec.Volunteer_Name__c == Null && oldDbRec.Wish__c != Null)) &&
             (oldDbRec.Role__c == 'Wish Granter' || oldDbRec.Role__c == 'Wish Granter Mentor' ||  oldDbRec.Role__c == 'Temporary Wish Granter')){
               wishIdSet.add(oldDbRec.Wish__c);  
               deletedVolunteerOpportunityMap .put(oldDbRec.Id,oldDbRec);           
            }*/
        }
        
        if(nonWishListtoupdatecount.Size() > 0){
            VolOpportunity_OnAfter_Delete_Hepler.updatevolunteerNeededCount(nonWishListtoupdatecount);
        }
        if(nonwishListRegisteredList.size() > 0){
            VolOpportunity_OnAfter_Delete_Hepler.updateVolunteerRegisterdCount(nonwishListRegisteredList,nonWishRegisteredUpdateSet,isdelete);
        }
        /*** WVC-2052 ***/
      /*  If(deletedVolunteerOpportunityMap.Size() > 0){
            VolOpportunity_OnAfter_Update_Helper.updateWishVolunteerWaiting(deletedVolunteerOpportunityMap,wishIdSet);
        }*/
    }
}