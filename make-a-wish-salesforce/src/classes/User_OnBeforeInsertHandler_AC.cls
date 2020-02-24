/***************************************************************************************************
Author      : MST Solutions
Date        : 
Description : User_OnBeforeInsertHandler_ACis used to call the Helper class when the
              new user  record is created.
              
              Modification Log
              ------------------
              WVC-1889    Pavithra G 07/31/2018
              
*****************************************************************************************************/
Public class User_OnBeforeInsertHandler_AC{
    Public static void OnBeforeInsert(List<User> newUserList){
         List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
      String DocuSignUserid = Label.DSProSFUsername;
      for(User newUser : newUserList)
      {
       if(newUser.IsActive == true){
        newUser.dsfs__DSProSFUsername__c = DocuSignUserid;
        }
        
      }    
    }
}