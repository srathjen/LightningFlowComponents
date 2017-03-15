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
    // Public 
    Id volunteerOpportunityWishRecTypeId = Schema.SObjectType.Volunteer_Opportunity__c.getRecordTypeInfosByName().get(constant.wishVolunteerOpportunity).getRecordTypeId();
    public Map<string,integer> birthMonthMap = new Map<string,integer>();
    
    
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
    
    public static void CreateAffliation(List<Contact> ContactList)
    {
        RecursiveTriggerHandler.isFirstTime = false;
        Constant_AC  constant = new Constant_AC();
        Id volunteerRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.volunteerRT).getRecordTypeId();
        Id wichChildRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.contactWishChildRT).getRecordTypeId();
        Id familyContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.wishFamilyRT).getRecordTypeId();
        Id MedicalProfContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.MedicalProfessionalRT).getRecordTypeId();
        List<npe5__Affiliation__c> affDbList=new List<npe5__Affiliation__c>();
        List<npe5__Affiliation__c> houseHoldAffList = new List<npe5__Affiliation__c>();
        npe5__Affiliation__c aff; 
        List<npe5__Affiliation__c> UdateAff =new List<npe5__Affiliation__c>();
        set<Id> contactIds =new set<Id>();
        
           for(Contact con:ContactList)
           {
               npe5__Affiliation__c houseHoldAffiliation = new npe5__Affiliation__c();
              
               if((con.RecordTypeId == MedicalProfContactRecordTypeId) || con.RecordTypeId == familyContactRecordTypeId || con.RecordTypeId == wichChildRecordTypeId){
                   aff =new npe5__Affiliation__c();
                 
                 if(con.RecordTypeId != wichChildRecordTypeId)
                 {
                   houseHoldAffiliation.npe5__Organization__c=con.AccountId;
                   houseHoldAffiliation.npe5__Contact__c=con.id;
                   houseHoldAffiliation.npe5__StartDate__c = Date.Today();
                   houseHoldAffiliation.npe5__Status__c = 'Current';
                   houseHoldAffList.add(houseHoldAffiliation);
                   
                   system.debug('@@@@@@ Contact Trigger @@@@@@'+houseHoldAffList);
                 }
                   
                   
                  if(con.Region_Chapter__c != Null)
                  {
                       aff.npe5__Organization__c=con.Region_Chapter__c;
                       aff.npe5__Contact__c=con.id;
                       aff.npe5__StartDate__c = Date.Today();
                       aff.npe5__Status__c = 'Current';
                       if(con.RecordTypeId == familyContactRecordTypeId )
                        {
                           aff.Constituent_Code__c='Wish Family';
                        }
                       else if(con.RecordTypeId == wichChildRecordTypeId)
                       {
                           aff.Constituent_Code__c='Wish Child';
                       }
                       
                       if(con.RecordTypeId == MedicalProfContactRecordTypeId  )
                       {
                           aff.Constituent_Code__c='Medical Professional';
                       }
                       affDbList.add(aff);
                  }
                 
               
               }
               
               if(con.recordtypeid == volunteerRecordTypeId)
               {
                  if(con.Region_Chapter__c == Null && con.AccountId != Null)
                     con.Region_Chapter__c = con.AccountId;
                  if(con.AccountId == Null && con.Region_Chapter__c != Null)
                     con.AccountId = con.Region_Chapter__c;
               }
            }
           
           if(houseHoldAffList.size() > 0)
           {
               insert houseHoldAffList;
           }
           
           if(affDbList.size() > 0)
            {
               Insert affDbList;
            }
       
    }
    
    public static void updateAffiliation(map<id,contact> contactMap){
        npe5__Affiliation__c aff; 
        List<npe5__Affiliation__c> UdateAff =new List<npe5__Affiliation__c>();
        Constant_AC  constant = new Constant_AC();
        Id volunteerRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.volunteerRT).getRecordTypeId();
        Id boardMemberRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.boardMemberRT).getRecordTypeId();
       
        for(npe5__Affiliation__c curraff:[SELECT id,Constituent_Code__c,npe5__Contact__c,npe5__Contact__r.recordtypeid FROM npe5__Affiliation__c  WHERE npe5__Contact__c in:contactMap.keyset()]){
            aff=new npe5__Affiliation__c();
            aff.id=curraff.id;
            if(currAff.npe5__Contact__r.recordtypeid == volunteerRecordTypeId)
                aff.Constituent_Code__c='Volunteer';
            else if(currAff.npe5__Contact__r.recordtypeid == boardMemberRT)
                aff.Constituent_Code__c='Board Member';
            UdateAff.add(aff);
        }
        if(UdateAff.size() > 0){
            update UdateAff;
        }
    }
    
    public static void updateMedicalProfConatctInfo(set<Id> MedicalProfContactSet){
        Map<Id,npe4__Relationship__c > childContactMap = new Map<Id,npe4__Relationship__c >();
        List<Contact> updateChildContactList = new List<Contact>();
        Constant_AC  constant = new Constant_AC();
        Id wichChildRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.contactWishChildRT).getRecordTypeId();
        for(npe4__Relationship__c dbMedicalRelationShipRec : [SELECT Id,npe4__RelatedContact__c,npe4__RelatedContact__r.Name,npe4__RelatedContact__r.Email,npe4__Contact__c,npe4__Type__c,Qualifying_Medical_Professional__c,npe4__Status__c FROM npe4__Relationship__c 
                                                              WHERE npe4__RelatedContact__c IN:MedicalProfContactSet AND Qualifying_Medical_Professional__c =: TRUE AND npe4__Status__c =: 'Active']){
                                                                  
                                                                  childContactMap.put(dbMedicalRelationShipRec.npe4__Contact__c,dbMedicalRelationShipRec);
                                                              }
        
        for(Contact dbChildContact : [SELECT Id,Hidden_Medical_Physician__c,Hidden_Medical_Physician_Email__c,RecordTypeId FROM Contact WHERE Id IN:childContactMap.KeySet() AND RecordTypeId =: wichChildRecordTypeId]){
            if(childContactMap.containsKey(dbChildContact.Id)){
                
                contact updateChildContact = new contact();
                updateChildContact.Id = dbChildContact.Id;
                updateChildContact.Hidden_Medical_Physician__c = childContactMap.get(dbChildContact.Id).npe4__RelatedContact__r.Name;
                updateChildContact.Hidden_Medical_Physician_Email__c = childContactMap.get(dbChildContact.Id).npe4__RelatedContact__r.Email;
                updateChildContactList.add(updateChildContact);
            }
        }
        if(updateChildContactList.size() > 0)
            Update updateChildContactList;
    }
    // Updating User information when volunteer contact details updated.
   
    
    public static void updateUserDetails(map<String,Contact> contactDetails, Map<Id,Contact> oldMap){
        User updateUser;
        List<User> updateUserList=new List<User>();
        for(User currRecUser:[SELECT id,ContactId,FirstName,LastName,Email,Phone FROM User WHERE contactId IN:contactDetails.keyset()]){
            updateUser=new User();
            updateUser.id=currRecUser.id;
            Boolean flag = false;
            if(contactDetails.get(currRecUser.ContactId).FirstName != oldMap.get(currRecUser.ContactId).FirstName && currRecUser.FirstName != contactDetails.get(currRecUser.ContactId).FirstName)
            {
                updateUser.FirstName=contactDetails.get(currRecUser.ContactId).FirstName;
                flag = true;
            }
            if(contactDetails.get(currRecUser.ContactId).LastName != oldMap.get(currRecUser.ContactId).LastName && currRecUser.LastName != contactDetails.get(currRecUser.ContactId).LastName )
            {
                updateUser.LastName=contactDetails.get(currRecUser.ContactId).LastName;
                flag = true;
            }
            if(contactDetails.get(currRecUser.ContactId).Email != oldMap.get(currRecUser.ContactId).Email && currRecUser.Email!= contactDetails.get(currRecUser.ContactId).Email)
            {
                updateUser.Email=contactDetails.get(currRecUser.ContactId).Email;
                flag = true;
            }
            if(contactDetails.get(currRecUser.ContactId).MobilePhone!= oldMap.get(currRecUser.ContactId).MobilePhone && currRecUser.Phone != contactDetails.get(currRecUser.ContactId).MobilePhone)
            {
                updateUser.Phone=contactDetails.get(currRecUser.ContactId).MobilePhone;
                flag = true;
            }
           
          if(flag == true)  
             updateUserList.add(updateUser);
        }
        
        if(updateUserList.size() > 0)
            update updateUserList;
    }
    @future
    public static void updateHouseHoldAddress(Set<Id> addressSet){
        
        Map<Id,Contact> houseHoldContactMap= new Map<Id,Contact>();
        List<Contact> updateFamilyContactList = new List<Contact>();
        Map<Id,Account> houseHoldAccountMap = new Map<Id,Account>();
        
        for(Contact familyContact :[SELECT Id,AccountId,Name,FirstName,LastName,Phone,Email,MailingStreet,MailingCity,MailingState,MailingCountry,MailingPostalCode,Same_as_Household_Address__c From Contact WHERE Id IN: addressSet]){
        if(familyContact.Same_as_Household_Address__c  == true){ 
            houseHoldContactMap.put(familyContact.AccountId,familyContact );
            }
        }
        if(houseHoldContactMap.size() > 0){
            for(Account dbHouseHoldAccount :[SELECT Id,BillingStreet,BillingCity,BillingState,BillingCountry,BillingPostalCode FROM Account WHERE Id IN: houseHoldContactMap.KeySet()]){
                houseHoldAccountMap.put(dbHouseHoldAccount.Id,dbHouseHoldAccount);
            }
          
          for(Contact familyContact : houseHoldContactMap.Values()){
              if(houseHoldAccountMap.containsKey(familyContact.AccountId)){
                  familyContact.MailingStreet = houseHoldAccountMap.get(familyContact.AccountId).BillingStreet;
                  familyContact.MailingCity =  houseHoldAccountMap.get(familyContact.AccountId).BillingCity;
                  familyContact.MailingState =  houseHoldAccountMap.get(familyContact.AccountId).BillingState;
                  familyContact.MailingCountry =  houseHoldAccountMap.get(familyContact.AccountId).BillingCountry;
                  familyContact.MailingPostalCode =  houseHoldAccountMap.get(familyContact.AccountId).BillingPostalCode ;
                  updateFamilyContactList.add(familyContact);
              }
          }  
            
        }
        
        if(updateFamilyContactList.size() > 0)
           update updateFamilyContactList;
    }
    
    public static void updateRelationship(Map<Id,Contact> conMap){
        Map<Id,npe4__Relationship__c> relationShipMap = new Map<Id,npe4__Relationship__c>();
        for(npe4__Relationship__c  dbRelationShip : [SELECT Id,npe4__Contact__c ,npe4__RelatedContact__c,npe4__Type__c  From npe4__Relationship__c  WHERE npe4__RelatedContact__c IN: conMap.KeySet()]){
            
            if(conMap.containsKey(dbRelationShip.npe4__RelatedContact__c)){
                dbRelationShip.npe4__Type__c  = conMap.get(dbRelationShip.npe4__RelatedContact__c).Relationship__c;
                relationShipMap.put(dbRelationShip.Id,dbRelationShip);
            }
        }
        
        if(relationShipMap.size() > 0)
        update relationShipMap.values();
    }
}