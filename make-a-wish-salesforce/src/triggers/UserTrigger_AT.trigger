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
        
           if(newUser.Migrated_User__c == false)
           {
                if(newUser.State != null){
                    newUserList.add(newUser);
                }
              
                system.debug('newUser.ProfileId+++++++++++++++++++++++++++++++++++ ' + newUser.ProfileId);
                system.debug('newUser.Active_Volunteer_Profile+++++++++++++++++++++++++++++++++++ ' + label.Active_Volunteer_Profile);
                
                system.debug('newUser.contactId++++++++++++++++= ' + newUser.contactId);
              
                if((newUser.ProfileId == label.Prospective_Volunteer || newUser.ProfileId == String.valueOf(label.Active_Volunteer_Profile).trim()) && (newUser.contactId != Null))
                {
                  prospectiveUserMap.put(newUser.contactId, newUser);
                  System.debug('Sucesss++++++++++++++++++++++++++ ');
                }
             }
           System.debug('prospectiveUserMap++++++++++++++++++++++++++ '+prospectiveUserMap);
        }
       // UserTriggerHandler userHandlerIns = new UserTriggerHandler();
       // if(newUserList.size() > 0)
          //userHandlerIns.createpublicGroup(newUserList);
        if(prospectiveUserMap.size() > 0)
        {
            UserTriggerHandler.UpdateVolunteerInfo(prospectiveUserMap);
        }
    }
    
    if(Trigger.isAfter && Trigger.isUpdate)
    {
        Set<Id> inActiveUserIdSet = new Set<Id>();
        Set<Id> inactiveUserSet=new Set<Id>();
         for(User newUser : Trigger.new)
         {
             if(newUser.Migrated_User__c == false)
             {
                 if(newUser.IsActive == false && trigger.oldMap.get(newUser.Id).IsActive == TRue){
                     inActiveUserIdSet.add(newUser.Id);
                 }
                  if(newUser .ContactId != Null  && newUser .IsActive  == false && trigger.oldMap.get(newUser .id).IsActive == True){
                    inactiveUserSet.add(newUser .ContactId);
                  } 
             }
          }
         
        
        if(inActiveUserIdSet.size() > 0)
            UserTriggerHandler.updateUser(inActiveUserIdSet);
        
         if(inactiveUserSet.size() > 0 && inactiveUserSet != Null){
            System.Debug('Trigger List @@@@@@@@@@*******');
            InactiveVolunteerHandler.createTaskforVolunteerManager(inactiveUserSet);
         }
         
    }
    
     Set<Id> UserIdSet=new Set<Id>();
     if(Trigger.isbefore && Trigger.isUpdate)
     {
         Set<Id> inActiveCommunityUserIdSet = new Set<Id>();
         for(User newUser : Trigger.new)
         {
             if(newUser.Migrated_User__c == false)
             {
                 if(newUser.IsActive == false && trigger.oldMap.get(newUser.Id).IsActive == True )
                 {
                    
                    newUser.Inactive_Date__c=system.Today();
                 }
                 if(newUser.IsActive == true && trigger.oldMap.get(newUser.Id).IsActive == False ){
                      newUser.Inactive_Date__c=null;
                 }
              }
         }
     }   
}