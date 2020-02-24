/***************************************************************************************************
Author      : MST Solutions
Date        : 
Description : User_OnBeforeUpdateHandler_AC is used to call the Helper class when the
              new user  record is Updated.
              
              Modification Log
              ------------------
              WVC-1889    Pavithra G 07/31/2018
              
*****************************************************************************************************/
Public class User_OnBeforeUpdateHandler_AC{
    Public static void OnBeforeUpdate(List<User> newUserList,Map<Id,User> oldUserMap){
         for(User newUser : newUserList)
         {
             if(Bypass_Triggers__c.getValues(userInfo.getUserId()) == Null)
             {
                 if(newUser.IsActive == false && oldUserMap.get(newUser.Id).IsActive == True )
                 {
                    
                    newUser.Inactive_Date__c=system.Today();
                 }
                 if(newUser.IsActive == true && oldUserMap.get(newUser.Id).IsActive == False ){
                      newUser.Inactive_Date__c=null;
                 }
                 if(newUser.Email != Null && newUser.Email != oldUserMap.get(newUser.id).Email && newUser.Hidden_Email__c == Null)
                 {
                 
                   newUser.Hidden_Email__c = oldUserMap.get(newUser.id).Email;
                 }
              }
         }
    }
}