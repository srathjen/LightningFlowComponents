/*************************************************************************************************
Author   : MST Solutions
CreatedBy: Kanagaraj 
CreatedDate : 05/27/2015
Description : This UserTrigger_AT is used to create a public group and public group member when ever a new
              user record is created.
*************************************************************************************************/

trigger UserTrigger_AT on User (after insert,after update,before update) {
    List<User> newUserList = new List<User>();
    Map<Id,User> prospectiveUserMap = new Map<Id,User>();
    
    if(Trigger.isAfter && Trigger.isInsert){
        for(User newUser : Trigger.new){
            if(newUser.State != null){
                newUserList.add(newUser);
            }
          
            if((newUser.ProfileId == label.Prospective_Volunteer) && (newUser.contactId != Null))
            {
              prospectiveUserMap.put(newUser.contactId, newUser);
            }
        }
        UserTriggerHandler userHandlerIns = new UserTriggerHandler();
        if(newUserList.size() > 0)
          //userHandlerIns.createpublicGroup(newUserList);
        if(prospectiveUserMap.size() > 0)
            userHandlerIns.UpdateVolunteerInfo(prospectiveUserMap);
    }
    
    if(Trigger.isAfter && Trigger.isUpdate){
        Set<Id> inActiveUserIdSet = new Set<Id>();
      
         for(User newUser : Trigger.new){
             if(newUser.IsActive == false && trigger.oldMap.get(newUser.Id).IsActive == TRue){
                 inActiveUserIdSet.add(newUser.Id);
             }
         }
        
        if(inActiveUserIdSet.size() > 0)
        UserTriggerHandler.updateUser(inActiveUserIdSet);
         
    }
    
     Set<Id> UserIdSet=new Set<Id>();
     if(Trigger.isbefore && Trigger.isUpdate){
        Set<Id> inActiveCommunityUserIdSet = new Set<Id>();
      
         for(User newUser : Trigger.new){
             if(newUser.IsActive == false && trigger.oldMap.get(newUser.Id).IsActive == TRue ){
                
                newUser.Inactive_Date__c=system.Today();
             }
             if(newUser.IsActive == true && trigger.oldMap.get(newUser.Id).IsActive == False ){
              
                newUser.Inactive_Date__c=null;
             }
            
         }
     }   
}