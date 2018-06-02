/***************************************************************************************************
Author      : MST Solutions
Date        : 10/15/2016
Description : Contact_OnBeforeUpdateTriggerHelper is used updated the contact records values based on the 
corresponding helper methods.

Modification Log
------------------
WVC-1884    KANAGARAJ  04/04/2018

*****************************************************************************************************/
public class Contact_OnBeforeUpdateTriggerHelper{
    
    static Constant_AC  constant = new Constant_AC();
    static Id familyContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.wishFamilyRT).getRecordTypeId();
    
    // used to update the family contact address information.
    public static void updateFamilyConInfo(set<Id> wishChildIdSet,Map<Id,Contact> ConrelationshipIdMap,set<Id> removePrefIdSet){
        system.debug('-----> Inside updateFamilyConInfo Method----');
        //Set<Id> removePrefIdSet = new Set<Id>();
        List<npe4__Relationship__c> updateRelList = new List<npe4__Relationship__c>();
        Map<Id,Id> relationshipContactIdMap = new Map<Id,Id>();
        Set<Id> wishFamliySet = new Set<Id>();
        Map<Id,Contact> wishFamilyMap = new Map<Id,Contact>();
        Map<Id,Contact> wishChildCaseIdMap = new Map<Id,Contact>();
        Map<Id,Account> houseHoldAccountMap = new Map<Id,Account>();
        String dummyValue = Label.Dummy_Email; 
        try{
            if(wishChildIdSet.size() > 0 && RecursiveTriggerHandler.accountRecursive == true){
                RecursiveTriggerHandler.accountRecursive = false;
                for(npe4__Relationship__c dbRelationShip : [SELECT Id,npe4__Contact__c,npe4__RelatedContact__c,npe4__RelatedContact__r.Name,Hidden_Preferred_Contact__c,npe4__Type__c,npe4__RelatedContact__r.Phone,npe4__RelatedContact__r.HomePhone,npe4__RelatedContact__r.MobilePhone,npe4__RelatedContact__r.npe01__PreferredPhone__c,
                                                            npe4__RelatedContact__r.OtherPhone,npe4__RelatedContact__r.npe01__WorkPhone__c FROM npe4__Relationship__c WHERE (npe4__Contact__c IN: wishChildIdSet OR Id IN:ConrelationshipIdMap.keySet() )AND npe4__RelatedContact__r.RecordTypeId =: familyContactRecordTypeId Limit 50000])
                {
                    If(removePrefIdSet.Contains(dbRelationShip.npe4__Contact__c) && (!ConrelationshipIdMap.ContainsKey(dbRelationShip.Id)) && dbRelationShip.Hidden_Preferred_Contact__c == True){
                        dbRelationShip.Hidden_Preferred_Contact__c = False;
                        updateRelList.add(dbRelationShip);
                    }
                    if(ConrelationshipIdMap.Size() >0){
                        If(ConrelationshipIdMap.ContainsKey(dbRelationShip.Id)){
                            ConrelationshipIdMap.get(dbRelationShip.Id).Preferred_Contact_Name__c = dbRelationShip.npe4__RelatedContact__r.Name;
                            system.debug('ConrelationshipIdMap inside relationship'+ConrelationshipIdMap);//.get(dbRelationShip.Id).Preferred_Contact_Number__c = dbRelationShip.npe4__RelatedContact__r.Phone;
                            relationshipContactIdMap.put(dbRelationShip.npe4__RelatedContact__c,dbRelationShip.Id);
                            ConrelationshipIdMap.get(dbRelationShip.Id).Preferred_Contact_Relationship__c = dbRelationShip.npe4__Type__c;
                            
                            if(dbRelationShip.npe4__RelatedContact__r.npe01__PreferredPhone__c == 'Home' || dbRelationShip.npe4__RelatedContact__r.npe01__PreferredPhone__c !=Null )
                                ConrelationshipIdMap.get(dbRelationShip.Id).Preferred_Contact_Number__c = dbRelationShip.npe4__RelatedContact__r.HomePhone;
                            else  if(dbRelationShip.npe4__RelatedContact__r.npe01__PreferredPhone__c == 'Mobile')
                                ConrelationshipIdMap.get(dbRelationShip.Id).Preferred_Contact_Number__c = dbRelationShip.npe4__RelatedContact__r.MobilePhone;
                            else if(dbRelationShip.npe4__RelatedContact__r.npe01__PreferredPhone__c == 'Other')
                                ConrelationshipIdMap.get(dbRelationShip.Id).Preferred_Contact_Number__c = dbRelationShip.npe4__RelatedContact__r.OtherPhone;
                            else if(dbRelationShip.npe4__RelatedContact__r.npe01__PreferredPhone__c == 'Work')
                                ConrelationshipIdMap.get(dbRelationShip.Id).Preferred_Contact_Number__c = dbRelationShip.npe4__RelatedContact__r.npe01__WorkPhone__c;
                            
                            dbRelationShip.Hidden_Preferred_Contact__c = True;
                            updateRelList.add(dbRelationShip);
                        }
                    }
                    wishFamliySet.add(dbRelationShip.npe4__RelatedContact__c);  
                }
            }
            system.debug('---->wishFamliySet'+wishFamliySet);
            if(wishFamliySet.size() > 0){
                for(Contact dbWishFamily : [SELECT Id,Name,FirstName,LastName,Phone,Homephone,Email,MailingStreet,MailingCity,AccountId,Account.npe01__SYSTEM_AccountType__c,Hidden_Use_as_Household_Address__c,Use_as_Household_Address__c,MailingState,MailingCountry,MailingPostalCode,Hidden_First_Name__c,
                                            Hidden_Last_Name__c,Hidden_Street__c,Hidden_Phone__c ,Hidden_Email__c,Hidden_city__c,npe01__WorkPhone__c,Hidden_Work_Phone__c,npe01__PreferredPhone__c,Hidden_Preferred_Phone_Types__c,
                                            Hidden_State__c,Hidden_Country__c,Hidden_Zip_Code__c,Same_as_Household_Address__c,Hidden_Same_Address__c,OtherPhone,MobilePhone,HiddenMobilePhone__c,HiddenOtherPhone__c From Contact WHERE Id IN: wishFamliySet Limit 50000])
                {
                    
                    if(dbWishFamily.Hidden_First_Name__c != Null){
                        dbWishFamily .FirstName =  dbWishFamily.Hidden_First_Name__c;
                        
                        dbWishFamily.Hidden_First_Name__c = Null;
                        wishFamilyMap.put(dbWishFamily.Id,dbWishFamily);
                    }
                    if(dbWishFamily.Hidden_Last_Name__c != Null){
                        dbWishFamily.LastName  =  dbWishFamily.Hidden_Last_Name__c;
                        dbWishFamily.Hidden_Last_Name__c = Null;
                        wishFamilyMap.put(dbWishFamily.Id,dbWishFamily);
                    }
                    if(dbWishFamily.Hidden_Phone__c != Null && dbWishFamily.Hidden_Phone__c != '9912121313'){
                        dbWishFamily.HomePhone =   dbWishFamily.Hidden_Phone__c; 
                        dbWishFamily.Hidden_Phone__c = Null;
                        wishFamilyMap.put(dbWishFamily.Id,dbWishFamily);
                    }
                    if(dbWishFamily.Hidden_Phone__c == '9912121313'){
                        dbWishFamily.HomePhone =  null;
                        wishFamilyMap.put(dbWishFamily.Id,dbWishFamily);
                    }
                    if(dbWishFamily.HiddenMobilePhone__c != Null && dbWishFamily.HiddenMobilePhone__c != '9912121313'){
                        dbWishFamily.MobilePhone =   dbWishFamily.HiddenMobilePhone__c; 
                        dbWishFamily.HiddenMobilePhone__c = Null;
                        wishFamilyMap.put(dbWishFamily.Id,dbWishFamily);
                    }
                    if(dbWishFamily.HiddenMobilePhone__c == '9912121313'){
                        dbWishFamily.MobilePhone=  null;
                        wishFamilyMap.put(dbWishFamily.Id,dbWishFamily);
                    }
                    if(dbWishFamily.Hidden_Work_Phone__c != Null && dbWishFamily.Hidden_Work_Phone__c != '9912121313'){
                        dbWishFamily.npe01__WorkPhone__c =  dbWishFamily.Hidden_Work_Phone__c; 
                        dbWishFamily.Hidden_Work_Phone__c = Null;
                        wishFamilyMap.put(dbWishFamily.Id,dbWishFamily);
                    }
                    if(dbWishFamily.Hidden_Work_Phone__c == '9912121313'){
                        dbWishFamily.npe01__WorkPhone__c =  null;
                        wishFamilyMap.put(dbWishFamily.Id,dbWishFamily);
                    }
                    if(dbWishFamily.HiddenOtherPhone__c != Null && dbWishFamily.HiddenOtherPhone__c != '9912121313'){
                        dbWishFamily.otherPhone =   dbWishFamily.HiddenOtherPhone__c; 
                        dbWishFamily.HiddenOtherPhone__c = Null;
                        wishFamilyMap.put(dbWishFamily.Id,dbWishFamily);
                    }
                    if(dbWishFamily.HiddenOtherPhone__c == '9912121313'){
                        dbWishFamily.otherPhone =  null;
                        wishFamilyMap.put(dbWishFamily.Id,dbWishFamily);
                    }
                    if(dbWishFamily.Hidden_Email__c != Null && dbWishFamily.Hidden_Email__c != dummyValue){
                        dbWishFamily.Email  =   dbWishFamily.Hidden_Email__c;
                        dbWishFamily.Hidden_Email__c = Null;
                        wishFamilyMap.put(dbWishFamily.Id,dbWishFamily);
                    }
                    if(dbWishFamily.Hidden_Email__c == dummyValue){
                        dbWishFamily.Email =  null;
                        wishFamilyMap.put(dbWishFamily.Id,dbWishFamily);
                    }
                    if(dbWishFamily.Hidden_Preferred_Phone_Types__c != Null && dbWishFamily.Hidden_Preferred_Phone_Types__c != dummyValue){
                        dbWishFamily.npe01__PreferredPhone__c  =   dbWishFamily.Hidden_Preferred_Phone_Types__c;                    
                        dbWishFamily.Hidden_Preferred_Phone_Types__c = Null;
                        wishFamilyMap.put(dbWishFamily.Id,dbWishFamily);
                    }
                    if(dbWishFamily.Hidden_Preferred_Phone_Types__c == dummyValue){
                        dbWishFamily.npe01__PreferredPhone__c =  null;
                        wishFamilyMap.put(dbWishFamily.Id,dbWishFamily);
                    }
                    if(dbWishFamily.Hidden_Street__c != Null && dbWishFamily.Hidden_Street__c != dummyValue){
                        
                        dbWishFamily.MailingStreet =   dbWishFamily.Hidden_Street__c; 
                        dbWishFamily.Hidden_Street__c = Null;
                        wishFamilyMap.put(dbWishFamily.Id,dbWishFamily);
                    }
                    if(dbWishFamily.Hidden_Street__c == dummyValue){
                        dbWishFamily.MailingStreet =  null;
                        wishFamilyMap.put(dbWishFamily.Id,dbWishFamily);
                    }
                    if(relationshipContactIdMap.Size() > 0 && ConrelationshipIdMap.Size() > 0){
                        if(relationshipContactIdMap.containsKey(dbWishFamily.Id)){
                            if(dbWishFamily.npe01__PreferredPhone__c == 'Home')
                                ConrelationshipIdMap.get(relationshipContactIdMap.get(dbWishFamily.Id)).Preferred_Contact_Number__c = dbWishFamily.HomePhone;
                            else  if(dbWishFamily.npe01__PreferredPhone__c == 'Mobile')
                                ConrelationshipIdMap.get(relationshipContactIdMap.get(dbWishFamily.Id)).Preferred_Contact_Number__c = dbWishFamily.MobilePhone;
                            else if(dbWishFamily.npe01__PreferredPhone__c == 'Other')
                                ConrelationshipIdMap.get(relationshipContactIdMap.get(dbWishFamily.Id)).Preferred_Contact_Number__c = dbWishFamily.OtherPhone;
                            else if(dbWishFamily.npe01__PreferredPhone__c == 'Work')
                                ConrelationshipIdMap.get(relationshipContactIdMap.get(dbWishFamily.Id)).Preferred_Contact_Number__c = dbWishFamily.npe01__WorkPhone__c;
                            wishChildCaseIdMap.put(ConrelationshipIdMap.get(relationshipContactIdMap.get(dbWishFamily.Id)).Id,ConrelationshipIdMap.get(relationshipContactIdMap.get(dbWishFamily.Id)));  
                        }
                    }
                    if(dbWishFamily.Hidden_city__c != Null && dbWishFamily.Hidden_city__c != dummyValue){
                        
                        dbWishFamily.MailingCity =   dbWishFamily.Hidden_city__c;
                        dbWishFamily.Hidden_city__c = Null;
                        wishFamilyMap.put(dbWishFamily.Id,dbWishFamily);
                    }
                    if(dbWishFamily.Hidden_city__c == dummyValue){
                        dbWishFamily.MailingCity =  null;
                        wishFamilyMap.put(dbWishFamily.Id,dbWishFamily);
                    }
                    if(dbWishFamily.Hidden_State__c != Null && dbWishFamily.Hidden_State__c != dummyValue){                    
                        dbWishFamily.MailingState =   dbWishFamily.Hidden_State__c; 
                        dbWishFamily.Hidden_State__c = Null;
                        wishFamilyMap.put(dbWishFamily.Id,dbWishFamily);
                    }
                    if(dbWishFamily.Hidden_State__c == dummyValue){
                        dbWishFamily.MailingState =  null;
                        wishFamilyMap.put(dbWishFamily.Id,dbWishFamily);
                    }
                    if(dbWishFamily.Hidden_Country__c != Null && dbWishFamily.Hidden_Country__c != dummyValue){
                        
                        dbWishFamily.MailingCountry =   dbWishFamily.Hidden_Country__c;
                        dbWishFamily.Hidden_Country__c  = Null;
                        wishFamilyMap.put(dbWishFamily.Id,dbWishFamily);
                    }
                    if(dbWishFamily.Hidden_Country__c == dummyValue){
                        dbWishFamily.MailingCountry =  'United States';
                        wishFamilyMap.put(dbWishFamily.Id,dbWishFamily);
                    }
                    if(dbWishFamily.Hidden_Zip_Code__c != Null && dbWishFamily.Hidden_Zip_Code__c != '11111'){
                        system.debug('@@@ Map zip Code @@@'+dbWishFamily.Hidden_Zip_Code__c);
                        dbWishFamily.MailingPostalCode =   dbWishFamily.Hidden_Zip_Code__c; 
                        dbWishFamily.Hidden_Zip_Code__c = Null;
                        wishFamilyMap.put(dbWishFamily.Id,dbWishFamily);
                    }
                    if(dbWishFamily.Hidden_Zip_Code__c == '11111'){
                        
                        dbWishFamily.MailingPostalCode =  null;
                        wishFamilyMap.put(dbWishFamily.Id,dbWishFamily);
                    }
                    
                    if(dbWishFamily.Hidden_Use_as_Household_Address__c == true){
                        system.debug('--->Hidden_Use_as_Household_Address__c'+dbWishFamily.Hidden_Use_as_Household_Address__c);
                        dbWishFamily.Use_as_Household_Address__c = true;
                         Account newAcc = new Account();
                        newAcc.Id = dbWishFamily.AccountId;
                        newAcc.BillingStreet = dbWishFamily.MailingStreet;
                        newAcc.BillingCity = dbWishFamily.MailingCity;
                        newAcc.BillingState = dbWishFamily.MailingState;
                        newAcc.BillingCountry = dbWishFamily.MailingCountry;
                        newAcc.BillingPostalCode = dbWishFamily.MailingPostalCode;
                        houseHoldAccountMap.put(newAcc.Id,newAcc);
                        wishFamilyMap.put(dbWishFamily.Id,dbWishFamily);
                        system.debug('--->wishFamilyMap'+wishFamilyMap);
                         system.debug('--->houseHoldAccountMap'+houseHoldAccountMap);
                    }
                    else if(dbWishFamily.Hidden_Use_as_Household_Address__c == false){
                        dbWishFamily.Use_as_Household_Address__c = false;
                        wishFamilyMap.put(dbWishFamily.Id,dbWishFamily);
                    }
                    
                    if(dbWishFamily.Hidden_Same_Address__c == false){
                        dbWishFamily.Same_as_Household_Address__c  = false;
                        wishFamilyMap.put(dbWishFamily.Id,dbWishFamily);
                    }
                    
                    else if(dbWishFamily.Hidden_Same_Address__c == true){
                        dbWishFamily.Same_as_Household_Address__c  = true;
                       // dbWishFamily.Hidden_Same_Address__c = false; 
                        wishFamilyMap.put(dbWishFamily.Id,dbWishFamily);
                    }
                    
                    
                    
                }
                system.debug('@@@ Map Size @@@'+wishFamilyMap);
                if(wishFamilyMap.size() > 0) {
                    system.debug('@@@ ---> 12');
                    system.debug('Numberof DML Before'+Limits.getDMLStatements());
                    update wishFamilyMap.Values();
                    system.debug('Numberof DML After'+Limits.getDMLStatements());
                    system.debug('@@@ ---> 123');
                }           
                
                system.debug('@@@ Map Size @@@'+wishFamilyMap);
                system.debug('--->houseHoldAccountMap'+houseHoldAccountMap);
                if(houseHoldAccountMap.size() > 0) {
                    system.debug('--->houseHoldAccountMap'+houseHoldAccountMap);
                    update houseHoldAccountMap.Values();
                     system.debug('--->houseHoldAccountMap'+houseHoldAccountMap);
                }               
                
                if(updateRelList.Size() > 0){
                    Update updateRelList;
                }
                
            }
        }
        catch(Exception ex){
            for(Contact currRec : ConrelationshipIdMap.Values()){
                ErrorMessage_AC.createdebugRec('Contact_OnBeforeUpdateTriggerHelper',String.valueof(currRec),String.valueOf(ex.getCause()),'updateFamilyConInfo',currRec.Id,ex.getStackTraceString(),'Error');
            }
            for(Contact currRec : ConrelationshipIdMap.Values()){
                currRec.addError(Label.Debug_log_error_message);
            }
        } 
    }
    
    /* used to recall the approval process when the user update their contact
information from Update contact info page.*/
    public static void recallApproval(set<Id> recallWishIdSet){
        Set<Id> wishFamliySet = new Set<Id>();
        Map<Id,Contact> wishFamilyMap = new Map<Id,Contact>();
        try{
            if(recallWishIdSet.size() > 0){
                for(npe4__Relationship__c dbRelationShip : [SELECT Id,npe4__Contact__c,npe4__RelatedContact__c FROM npe4__Relationship__c WHERE npe4__Contact__c IN: recallWishIdSet AND npe4__RelatedContact__r.RecordTypeId =: familyContactRecordTypeId Limit 50000]){
                    
                    wishFamliySet.add(dbRelationShip.npe4__RelatedContact__c);  
                    
                }
                for(Contact dbWishFamily : [SELECT Id,Name,FirstName,LastName,Phone,Email,MailingStreet,MailingCity,MailingState,MailingCountry,MailingPostalCode,Hidden_First_Name__c,HiddenOtherPhone__c,HiddenMobilePhone__c,Hidden_Use_as_Household_Address__c,                                      
                                            Hidden_Last_Name__c,Hidden_Street__c,Hidden_Phone__c ,Hidden_Email__c ,Hidden_city__c ,Hidden_State__c,Hidden_Country__c,Hidden_Zip_Code__c,Hidden_Work_Phone__c,Hidden_Preferred_Phone_Types__c  From Contact WHERE Id IN: wishFamliySet Limit 50000])
                {
                    if(dbWishFamily.Hidden_First_Name__c != Null || dbWishFamily .Hidden_Last_Name__c != Null ||  dbWishFamily.Hidden_Phone__c != Null|| dbWishFamily.Hidden_Use_as_Household_Address__c == True ||
                       dbWishFamily.Hidden_Email__c != Null || dbWishFamily .Hidden_Street__c != Null ||  dbWishFamily.Hidden_State__c != Null || 
                       dbWishFamily.Hidden_Country__c != Null ||   dbWishFamily .Hidden_Zip_Code__c != Null ||  dbWishFamily.Hidden_city__c != Null || 
                       dbWishFamily.Hidden_Preferred_Phone_Types__c != Null || dbWishFamily.Hidden_Work_Phone__c != Null || dbWishFamily.HiddenMobilePhone__c != Null || dbWishFamily.HiddenOtherPhone__c != Null )
                    { 
                        
                        dbWishFamily.Hidden_First_Name__c = Null;
                        dbWishFamily.Hidden_Last_Name__c = Null;
                        dbWishFamily.Hidden_Phone__c = Null;
                        dbWishFamily.Hidden_Email__c = Null;
                        dbWishFamily.Hidden_Street__c = Null;
                        dbWishFamily.Hidden_State__c = Null;
                        dbWishFamily.Hidden_Country__c  = Null;
                        dbWishFamily.Hidden_Zip_Code__c = Null;
                        dbWishFamily.Hidden_city__c = Null;
                        dbWishFamily.HiddenMobilePhone__c = Null;
                        dbWishFamily.HiddenOtherPhone__c = Null;
                        dbWishFamily.Hidden_Preferred_Phone_Types__c = Null;
                        dbWishFamily.Hidden_Work_Phone__c = Null;
                        dbWishFamily.Hidden_Use_as_Household_Address__c = False;
                        wishFamilyMap.put(dbWishFamily.Id,dbWishFamily);
                        
                    }
                }
            }
            if(wishFamilyMap.size() > 0)
                update wishFamilyMap.Values();
        }
        catch(Exception ex){
            for(Contact currRec : [SELECT Id,Name FROM Contact WHERE Id IN:recallWishIdSet Limit 50000]){
                ErrorMessage_AC.createdebugRec('Contact_OnBeforeUpdateTriggerHelper',String.valueof(currRec),String.valueOf(ex.getCause()),'recallApproval',currRec.Id,ex.getStackTraceString(),'Error');
            }
            for(Contact currRec : [SELECT Id,Name FROM Contact WHERE Id IN:recallWishIdSet Limit 50000]){
                currRec.addError(Label.Debug_log_error_message);
            }
        } 
    }
}