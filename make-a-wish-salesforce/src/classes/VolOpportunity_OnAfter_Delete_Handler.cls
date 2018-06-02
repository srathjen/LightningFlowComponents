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
        }
        
        if(nonWishListtoupdatecount.Size() > 0){
            VolOpportunity_OnAfter_Delete_Hepler.updatevolunteerNeededCount(nonWishListtoupdatecount);
        }
        if(nonwishListRegisteredList.size() > 0){
            VolOpportunity_OnAfter_Delete_Hepler.updateVolunteerRegisterdCount(nonwishListRegisteredList,nonWishRegisteredUpdateSet,isdelete);
        }
    }
}