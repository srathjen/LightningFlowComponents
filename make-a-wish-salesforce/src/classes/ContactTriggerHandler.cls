/***************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kanagaraj
Date        : 28/06/2016
Description : 1. ContactTriggerHandler is used to assign the account Name for Volunteer contact,based on the current logged in user role.
2. Its updating the Affiliation Record status based on the Application approved/Rejected/Declined.
3. Adding community user to chapter group.
*****************************************************************************************************/
public class ContactTriggerHandler{
    Constant_AC  constant = new Constant_AC();
    Id ChapterRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(constant.chapterRT).getRecordTypeId();
    Id WishRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
    Id volunteerOpportunityWishRecTypeId = Schema.SObjectType.Volunteer_Opportunity__c.getRecordTypeInfosByName().get(constant.wishVolunteerOpportunity).getRecordTypeId();
    public Map<string,integer> birthMonthMap = new Map<string,integer>();
   
    // Updating contact's account Id based on the current logged in user role.
    public void updateAccountName(List<Contact> contactList){
        
        Set<String> chapterNameSet = new Set<String>();
        Id ProfileId = System.Label.Prospective_Volunteer_Profile ;
         
        for( user  dbUser : [SELECT ID,Name,UserRoleId,UserRole.Name,ProfileId,Profile.Name FROM User WHERE Id =: UserInfo.getUserId() AND ProfileId !=: ProfileId AND Profile.Name !=: 'System Administrator' Limit 1]){
            chapterNameSet.add(dbUser.UserRole.Name);
        } 
         
        if(chapterNameSet.size() > 0){
            List<Account> accList =  [SELECT Id,Name,OwnerId,RecordTypeId FROM Account WHERE Name IN :chapterNameSet AND RecordTypeId =: ChapterRecordTypeId  Limit 1];
            
            for(Contact newContact : contactList){
                
                if(accList.isEmpty()){
                    newContact.addError('The current Logged in user does not have the user role.');
                }
                else{
                    newContact.AccountId = accList[0].Id;
                }
                
            }
        }
        
    }
    
  
   
    /*This method is used to update Affiliation object status to 'Pending'.*/
    public static void UpdateOrgAffiliationStatusToPending(set<ID> volunteercontactSet)
    {
        List<npe5__Affiliation__c> affiliationList = new List<npe5__Affiliation__c>();
        for(npe5__Affiliation__c dbAffiliationRec : [SELECT Id,npe5__Contact__c,npe5__Primary__c,npe5__Status__c,npe5__Organization__c FROM npe5__Affiliation__c WHERE npe5__Contact__c IN :volunteercontactSet AND npe5__Status__c != 'Active']){
                npe5__Affiliation__c  updateAffiliation = new npe5__Affiliation__c();
                updateAffiliation.id = dbAffiliationRec.id;
                updateAffiliation.npe5__Status__c = 'Pending';
                affiliationList.add(updateAffiliation);
         }
        if(affiliationList.size() > 0){
             update affiliationList;
        }
    }
    
    /*This method is used to update Affiliation object status to 'Declined'.*/
    public static void updateOrgAffiliationStatustoDeclined(set<ID> volunteercontactSet)
    {
        List<npe5__Affiliation__c> affiliationList = new List<npe5__Affiliation__c>();
        for(npe5__Affiliation__c dbAffiliationRec : [SELECT Id,npe5__Contact__c,npe5__Primary__c,npe5__Status__c,npe5__Organization__c FROM npe5__Affiliation__c WHERE npe5__Contact__c IN :volunteercontactSet AND npe5__Status__c != 'Active']){
                npe5__Affiliation__c  updateAffiliation = new npe5__Affiliation__c();
                updateAffiliation.id = dbAffiliationRec.id;
                updateAffiliation.npe5__Status__c = 'Declined';
                affiliationList.add(updateAffiliation);
         }
        if(affiliationList.size() > 0){
             update affiliationList;
        }
    }
    
    // Whenever Volunteer Role field is updating on Volunteer Contact, based on the field value, Volunteer Roles will create and delete.
    public static void CreateVolunteerRoles(Map<Id,Contact> volunteerContactMap)
    {
       Map<Id,Id> volunterChapterMap = new Map<Id,Id>();
       Map<Id, Set<string>> volunteerRolesMap = new Map<Id, Set<String>>();
       Set<String> allVolunteerRoles = new Set<String>();
       Map<String, Id> RoleIdsMap = new Map<String, Id>();
       
       for(npe5__Affiliation__c currRec : [SELECT Id,npe5__Contact__c, npe5__Organization__c,npe5__Contact__r.Volunteer_Role__c  FROM npe5__Affiliation__c WHERE npe5__Contact__c IN :volunteerContactMap.keySet() AND npe5__Primary__c = True])
       {
         volunterChapterMap.put(currRec.npe5__Contact__c, currRec.npe5__Organization__c);
         if(currRec.npe5__Contact__r.Volunteer_Role__c != Null)
         {
             Set<String> volunteerRoles = new Set<String>();
             for(String currRole : (currRec.npe5__Contact__r.Volunteer_Role__c.split(';')))
             {
                volunteerRoles.add(currRole);
                allVolunteerRoles.add(currRole);
             }
             
             volunteerRolesMap.put(currRec.npe5__Contact__c, volunteerRoles);
         }
       }
       
       // Deleting Volunteer Role record if the role is removed from the field.
       if(volunterChapterMap.keySet().size() > 0)
           Delete [SELECT Id from Volunteer_Roles__c WHERE Volunteer_Name__c  IN :volunterChapterMap.keySet()];
       
       List<Volunteer_Roles__c> volunteerRoleList = new List<Volunteer_Roles__c>();
       
       for(Chapter_Role__c currRec : [SELECT id, Chapter_Name__c, Role_Name__c,Role_Name__r.Name FROM Chapter_Role__c  WHERE Role_Name__r.Name IN :allVolunteerRoles AND Chapter_Name__c IN :volunterChapterMap.values()] )
       {
           for(Id currContact : volunterChapterMap.keySet())
           {
              if((volunterChapterMap.get(currContact)== (currRec.Chapter_Name__c)) && ((volunteerRolesMap.get(currContact)).contains(currRec.Role_Name__r.Name)))
              {
                  Volunteer_Roles__c newVolRole = new Volunteer_Roles__c();
                  newVolRole.Chapter_Role__c = currRec.id;
                  newVolRole.Volunteer_Name__c = currContact;
                  volunteerRoleList.add(newVolRole);
              }
           }
       }
       
       if(volunteerRoleList.size() > 0)
       {
           insert volunteerRoleList;
       }
    }
    
 
  // If volunteer updates the zipcode that belongs to outside of the chapter, then it would create task for Volunteer Manager.
   public static void CreateZipcodeUpdateTask(Set<String> zipCodesSet, Map<Id,Contact> contactMap)
   {
     Map<String, String> zipCodeChapterMap = new Map<String, String>();
     List<Task> newTaskList = new List<Task>();
     Constant_AC constant = new Constant_AC();
     Id taskRT = Schema.SObjectType.Task.getRecordTypeInfosByName().get(constant.taskRT).getRecordTypeId();
     
     for(Zip_Code__c currZip : [SELECT Id, Name, Office__c, Office__r.Chapter__c FROM Zip_Code__c WHERE Name IN :zipCodesSet])
     {
         if(currZip.Office__c != Null)
             zipCodeChapterMap.put(currZip.Name, currZip.Office__r.Chapter__c);
     }
     for(npe5__Affiliation__c  currAffiliation : [SELECT Id,npe5__Contact__c, npe5__Contact__r.MailingPostalcode, npe5__Organization__c,npe5__Contact__r.Volunteer_Role__c  FROM npe5__Affiliation__c WHERE npe5__Contact__c IN :contactMap.keySet() AND npe5__Primary__c = True])
     {
        if(zipCodeChapterMap.containsKey(currAffiliation.npe5__Contact__r.MailingPostalcode))
        {
           if(currAffiliation.npe5__Organization__c != zipCodeChapterMap.get(currAffiliation.npe5__Contact__r.MailingPostalcode))
           {
              Task newTask = new Task();
              newTask.Subject = 'Volunteer Address Change';
              newTask.whoId = currAffiliation.npe5__Contact__c;
              newTask.OwnerId = UserInfo.getUserId();
              newTask.Status = 'Not Started';
              newTask.activityDate = Date.Today() + 5;
              newTask.whatId = zipCodeChapterMap.get(currAffiliation.npe5__Contact__r.MailingPostalcode);
              newTask.RecordTypeId = taskRT;
              newTaskList.add(newTask);
              
           }
        
        }
     }
     
     if(newTaskList.size() > 0)
         insert newTaskList;
   }

}