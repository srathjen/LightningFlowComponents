/*************************************************************************************************
Author   : MST Solutions
CreatedBy: Kanagaraj 
CreatedDate : 05/27/2015
Description : This UserTrigger_AT is used to create a public group and public group member when ever a new
              user record is created.
*************************************************************************************************/

trigger UserTrigger_AT on User (after insert,after update) {
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
}