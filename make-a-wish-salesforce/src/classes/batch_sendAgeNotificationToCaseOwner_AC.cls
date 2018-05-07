/**********************************************************************************************************************************
Author : MST Solutions
Created Date : 03/12/2017
Description : This class is used to update the case HiddenChildAgeEmailNotification__c field when the wishchild age is updated with 18 and 17 years 11 month.
**************************************************************************************************************************************/
global class batch_sendAgeNotificationToCaseOwner_AC  implements Database.Batchable<sObject> {
       global Database.QueryLocator start(Database.BatchableContext BC) 
    {
         Constant_AC  constant = new Constant_Ac();  
         String wishFamilyRecordTypeId = Schema.Sobjecttype.Contact.getRecordTypeInfosByName().get(constant.wishFamilyRT).getRecordTypeId();
         String wishChildRecordTypeId = Schema.Sobjecttype.Contact.getRecordTypeInfosByName().get(constant.contactWishChildRT).getRecordTypeId();
         
         Integer currentMonth =  System.Today().Month();
         Integer beforeMonth =  System.Today().Month()+1;
         Integer todayDate = System.Today().Day();
         return  Database.getQueryLocator([SELECT Id,Birthdate,Current_Age__c,RecordTypeId FROM Contact
                                 WHERE (RecordTypeId =: wishFamilyRecordTypeId OR RecordTypeId =: wishChildRecordTypeId) AND (Current_Age__c = 17 OR Current_Age__c = 18)
                                  AND (CALENDAR_MONTH(Birthdate) =: currentMonth  OR CALENDAR_MONTH(Birthdate) =: beforeMonth) AND 
                                  (DAY_IN_MONTH(Birthdate) =: todayDate OR DAY_IN_MONTH(Birthdate) = 30 OR (DAY_IN_MONTH(Birthdate) = 28 AND CALENDAR_MONTH(Birthdate) = 2))]);    
    }
    global void execute(Database.BatchableContext bc, list<Contact> contactList){
        Constant_AC  constant = new Constant_Ac();  
        String parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
        String wishFamilyRecordTypeId = Schema.Sobjecttype.Contact.getRecordTypeInfosByName().get(constant.wishFamilyRT).getRecordTypeId();
        String wishChildRecordTypeId = Schema.Sobjecttype.Contact.getRecordTypeInfosByName().get(constant.contactWishChildRT).getRecordTypeId();
        
        Integer currentMonth =  System.Today().Month();
        Integer beforeMonth =  System.Today().Month()+1;
        
        Map<Id,Id> caseOwnerIdMap = new Map<Id,Id>();
        Set<Id> inactiveUserId = new Set<Id>();
        List<ErrorMessage__e> errorMsgList = new List<ErrorMessage__e>();
        
        Map<Id,String> familyContactMap = new Map<Id,String>();
        Map<Id,String> wishChildContactMap = new Map<Id,String>();
        Map<Id,String> wishChildFamilMap = new Map<Id,String>();
        Map<Id,Case> updateCaseMap = new Map<Id,Case>();
        List<Case> updateCaseList = new List<case>();
        Case updateCase;
        
        for(Contact con : contactList){
            Integer birthMonth = con.Birthdate.month();  
            
            //This condition is used to update the case when the Participant age 18.           
            if(con.Current_Age__c == 18 && ((con.Birthdate.day() == System.Today().day() && con.Birthdate.month() == System.Today().month()) ||
              (birthMonth == 2 && System.Today().month() == 2 && con.Birthdate.day() == 29 && (!Date.isLeapYear(System.Today().Year())) && System.Today().Day() == 28))){
               // participantsCaseMap.put(participant.npe4__Contact__c,'Participant Age 18');
               If(con.RecordTypeId == wishFamilyRecordTypeId){
                   familyContactMap.put(con.Id,'18 Age');
               }
               else If(con.RecordTypeId == wishChildRecordTypeId){
                   wishChildContactMap.put(con.Id,'18 Age');
               }
            }
            
            //This condition is used to update the case when the wish child age 18 before 1 month.           
            if(((birthMonth-1) == System.Today().Month() && con.Current_Age__c == 17 )&& ((con.Birthdate.day() == System.Today().day()) || 
                (con.Birthdate.day() == 31 && System.Today().Day() == 30 && (  birthMonth == 1 || birthMonth == 3 || birthMonth == 5 || birthMonth == 7 || birthMonth == 8 || birthMonth == 10 || birthMonth == 12) && (currentMonth == 4 || currentMonth == 6 || currentMonth == 9 || currentMonth == 11)) ||
                 (birthMonth == 2 && System.Today().month() == 2 && con.Birthdate.day() == 29 && (! Date.isLeapYear(System.Today().Year())) && System.Today().Day() == 28))){
               // participantsCaseMap.put(con.Id,'Participant before turn 18');
                If(con.RecordTypeId == wishFamilyRecordTypeId){
                   familyContactMap.put(con.Id,'Before Month');
               }
               else If(con.RecordTypeId == wishChildRecordTypeId){
                   wishChildContactMap.put(con.Id,'Before Month');
               }
            }
        }
        
        for(npe4__Relationship__c participant : [SELECT Id,npe4__RelatedContact__c,npe4__Contact__c FROM npe4__Relationship__c WHERE npe4__RelatedContact__c IN : familyContactMap.keyset()]){
           If(familyContactMap.containsKey(participant.npe4__RelatedContact__c))
               If(wishChildFamilMap.ContainsKey(participant.npe4__Contact__c)){
                   If(wishChildFamilMap.get(participant.npe4__Contact__c) != familyContactMap.get(participant.npe4__RelatedContact__c))
                      wishChildFamilMap.put(participant.npe4__Contact__c,'Both'); 
               }
               else{
                   wishChildFamilMap.put(participant.npe4__Contact__c,familyContactMap.get(participant.npe4__RelatedContact__c));
               }
        } 
        for(Case currCase : [SELECT Id,ContactId,ownerId FROM Case WHERE (ContactId IN : wishChildFamilMap.keySet() OR ContactId IN : wishChildContactMap.keySet()) AND RecordTypeId =:parentWishRecordTypeId AND Status != 'DNQ' AND Status != 'Completed' AND Status != 'Closed']){
            updateCase = new Case();
            updateCase.Id = currCase.Id;
            If(wishChildFamilMap.containsKey(currCase.ContactId)){
                If(updateCaseMap.containsKey(currCase.Id)){
                    If(updateCaseMap.get(currCase.Id).HiddenChildAgeEmailNotification__c != wishChildFamilMap.get(currCase.ContactId)){
                        updateCase.HiddenChildAgeEmailNotification__c = 'Both';
                        //updateCaseMap.put(currCase.Id,updateCase);                        
                    }
                    else{
                    updateCase.HiddenChildAgeEmailNotification__c = wishChildFamilMap.get(currCase.ContactId);                    
                }
                }
                else{
                    updateCase.HiddenChildAgeEmailNotification__c = wishChildFamilMap.get(currCase.ContactId);                    
                }
               updateCaseMap.put(currCase.Id,updateCase);     
                
            }
            If(wishChildContactMap.containsKey(currCase.ContactId)){
                If(updateCaseMap.containsKey(currCase.Id)){
                    If(updateCaseMap.get(currCase.Id).HiddenChildAgeEmailNotification__c != wishChildContactMap.get(currCase.ContactId)){
                        updateCase.HiddenChildAgeEmailNotification__c = 'Both';
                        //updateCaseMap.put(currCase.Id,updateCase);                        
                    }
                    else{
                        updateCase.HiddenChildAgeEmailNotification__c = wishChildContactMap.get(currCase.ContactId);
                    } 
                }
                else{
                    updateCase.HiddenChildAgeEmailNotification__c = wishChildContactMap.get(currCase.ContactId);                    
                }
                //updateCase.HiddenChildAgeEmailNotification__c = wishChildContactMap.get(currCase.ContactId);
             updateCaseMap.put(currCase.Id,updateCase);
             caseOwnerIdMap.put(currCase.ownerId,currCase.Id);
            }
           
            //updateCaseList.add(updateCase);
        } 
        String inactiveUserList = '';
        ErrorMessage__e  errorMsg;
        For(User caseOwner : [SELECT Id,isActive,Name FROM User WHERE Id IN :caseOwnerIdMap.keySet()]){
            If(caseOwner.isActive == False){
                updateCaseMap.remove(caseOwnerIdMap.get(caseOwner.Id));
                inactiveUserList += 'Name:'+caseOwner.Name+'\tCase Id:'+caseOwnerIdMap.get(caseOwner.Id)+'\n';
                errorMsg = new ErrorMessage__e();
                errorMsg.Apex_Class__c = 'batch_sendAgeNotificationToCaseOwner_AC';
                errorMsg.Developer_Message__c = inactiveUserList;
                errorMsg.Message__c  = 'Inactive User';
                errorMsg.Method__c  = 'batch_sendAgeNotificationToCaseOwner_AC';
                errorMsg.Record_Id__c = '';
                errorMsg.Stack_Trace__c = '';
                errorMsg.Type__c = 'Information';
                errorMsgList.add(errorMsg);
            }
        }
        If(errorMsgList.size() > 0)
            List<Database.SaveResult> results = EventBus.publish(errorMsgList);
        
          
       /* for(Case currCase : caseList){
            updateCase = new Case();
            Integer birthMonth = currCase.Birthdate__c.month();                    
            
            //This condition is used to update the case when the wish child age 18.           
            if(currCase.Contact.Current_Age__c == 18 && ((currCase.Birthdate__c.day() == System.Today().day() && currCase.Birthdate__c.month() == System.Today().month()) ||
             (birthMonth == 2 && System.Today().month() == 2 && currCase.Birthdate__c.day() == 29 && (!Date.isLeapYear(System.Today().Year())) && System.Today().Day() == 28))){
                updateCase.Id = currCase.Id;               
                updateCase.HiddenChildAgeEmailNotification__c = '18 Age';
                updateCaseList.add(updateCase);
            }
             //This condition is used to update the case when the wish child age 18 before 1 month.           
            if(((birthMonth-1) == System.Today().Month() && currCase.Contact.Current_Age__c == 17 )&& ((currCase.Birthdate__c.day() == System.Today().day()) || 
                (currCase.Birthdate__c.day() == 31 && System.Today().Day() == 30 && (  birthMonth == 1 || birthMonth == 3 || birthMonth == 5 || birthMonth == 7 || birthMonth == 8 || birthMonth == 10 || birthMonth == 12) && (currentMonth == 4 || currentMonth == 6 || currentMonth == 9 || currentMonth == 11)) ||
                 (birthMonth == 2 && System.Today().month() == 2 && currCase.Birthdate__c.day() == 29 && (! Date.isLeapYear(System.Today().Year())) && System.Today().Day() == 28))){
                updateCase.Id = currCase.Id;
                updateCase.HiddenChildAgeEmailNotification__c = 'Before Month';
                updateCaseList.add(updateCase);
            }
        }*/
        If(updateCaseMap.Size() > 0)
           // Update updateCaseMap.Values();
           Database.SaveResult[] SR =   Database.update(updateCaseMap.Values());
       
    }
     global void finish(Database.BatchableContext BC) {
    }
}