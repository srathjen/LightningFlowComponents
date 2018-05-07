/***************************************************************************************************
Author      : MST Solutions
Date        : 10/15/2016
Description : Contact_OnAfterUpdateTriggerHandler is used to call the Helper class when the
              new contact record is updated.
              
              Modification Log
              ------------------
              WVC-1884    KANAGARAJ  04/04/2018
              
*****************************************************************************************************/
public class Contact_OnAfterUpdateTriggerHandler{
    
    static Constant_AC  constant = new Constant_AC();
    static Id volunteerRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.volunteerRT).getRecordTypeId();
    static Id wichChildRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.contactWishChildRT).getRecordTypeId();
    static Id MedicalProfContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.MedicalProfessionalRT).getRecordTypeId();
    static Id familyContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.wishFamilyRT).getRecordTypeId();
    
    /* This method is used to call the corresponding helper class method when the contact record gets 
    updated.*/
    public static void onAfterUpdate(Map<Id,Contact> newContactMap,Map<Id,Contact> oldConatcMap){
        
        List<Contact> conList = new List<Contact>();
        Map<Id, Contact> primaryDiagnosisChangesMap = new Map<Id, Contact>();
        set<Id> volunteercontactSet = new Set<Id>();
        Set<Id> rejectedApplicationIds = new Set<Id>();
        Map<Id, Contact> diagnosisConMap = new map<Id, Contact>();
        Set<Id>  MedicalProfContactSet = new Set<Id>();
        Map<Id,Contact> volunteerContactMap = new Map<Id,Contact>();
        Map<Id,Contact> contactMap = new Map<Id, Contact>();
        Set<String> zipCodesSet = new Set<String>();
        set<string> contactIdsForEmailChange = new set<string>();
        map<string,contact> m1 = new map<string,contact>();
        Set<Id> addressSet = new Set<Id>();
        map<string,Contact> updateUserInfo = new map<string,Contact>();
        Map<Id, Contact> contactOldMap = new Map<Id, Contact>();
        Map<Id,Contact> wishFamilyContacMap = new Map<Id,Contact>();
        Map<String,List<Contact>> contactMapforSharing = new Map<String,List<Contact>>();
        
        for(Contact newContact : newContactMap.Values()){
            if(newContact.recordTypeId == volunteerRecordTypeId && oldConatcMap.get(newContact.Id).recordTypeId != volunteerRecordTypeId){
                conList.add(newContact);    
            }
            if(newContact.Diagnosis__c != oldConatcMap.get(newContact.Id).Diagnosis__c || newContact.FirstName != oldConatcMap.get(newContact.Id).FirstName || newContact.LastName != oldConatcMap.get(newContact.Id).LastName || newContact.Preferred_Name__c != oldConatcMap.get(newContact.Id).Preferred_Name__c || newContact.Middle_Name__c != oldConatcMap.get(newContact.Id).Middle_Name__c || newContact.Gender__c != oldConatcMap.get(newContact.Id).Gender__c || newContact.Birthdate != oldConatcMap.get(newContact.Id).Birthdate || oldConatcMap.get(newContact.id).County__c != newContact.County__c
               || newContact.MobilePhone != oldConatcMap.get(newContact.Id).MobilePhone || newContact.npe01__HomeEmail__c != oldConatcMap.get(newContact.Id).npe01__HomeEmail__c || newContact.mailingstreet != oldConatcMap.get(newContact.Id).mailingstreet || newContact.mailingcity != oldConatcMap.get(newContact.Id).mailingcity || newContact.mailingstate != oldConatcMap.get(newContact.Id).mailingstate || newContact.mailingpostalcode != oldConatcMap.get(newContact.Id).mailingpostalcode || newContact.mailingcountry != oldConatcMap.get(newContact.Id).mailingcountry) {
                   primaryDiagnosisChangesMap.put(newContact.Id, newContact);
               }
            if(newContact.is_Application__c == 'Complete' && newContact.is_Application__c != oldConatcMap.get(newContact.id).is_Application__c){
                volunteercontactSet.add(newContact.Id);
                
            }
            if(newContact.is_Application__c == 'Rejected' && newContact.is_Application__c != oldConatcMap.get(newContact.id).is_Application__c)
            {
                rejectedApplicationIds.add(newContact.id);
            }
            if((newContact.Diagnosis__c != oldConatcMap.get(newContact.Id).Diagnosis__c || newContact.SD1_Condition_Description__c != oldConatcMap.get(newContact.Id).SD1_Condition_Description__c || newContact.SD2_Condition_Description__c != oldConatcMap.get(newContact.Id).SD2_Condition_Description__c
                || newContact.SD3_Condition_Description__c != oldConatcMap.get(newContact.Id).SD3_Condition_Description__c || newContact.SD4_Condition_Description__c != oldConatcMap.get(newContact.Id).SD4_Condition_Description__c) && (newContact.RecordTypeId == wichChildRecordTypeId)) {
                    diagnosisConMap.put(newContact.Id, newContact);
                }
            if(newContact.recordTypeId == MedicalProfContactRecordTypeId  &&(newContact.Name != oldConatcMap.get(newContact.Id).Name||
                                                                             newContact.Email!= oldConatcMap.get(newContact.Id).Email)){
                                                                                 
                                                                                 MedicalProfContactSet.add(newContact.Id);
                                                                             }
            if((newContact.recordTypeId == volunteerRecordTypeId) && newContact.Volunteer_Role__c != Null && (newContact.Volunteer_Role__c != oldConatcMap.get(newContact.id).Volunteer_Role__c))
            {
                volunteerContactMap.put(newContact.id, newContact);
            }
            if(newContact.MailingPostalCode != oldConatcMap.get(newContact.id).MailingPostalCode && newContact.RecordTypeId == volunteerRecordTypeId && newContact.MailingAddressVerified__c == false)
            {
                contactMap.put(newContact.id, newContact);
                if(newContact.MailingPostalCode != null && String.valueOf(newContact.MailingPostalCode).length() > 5 && String.valueOf(newContact.MailingPostalCode).contains('-')) {
                    zipCodesSet.add(String.valueOf(newContact.MailingPostalCode).split('-')[0]);
                } else {
                    zipCodesSet.add(newContact.MailingPostalCode);
                }
            }
            if(newContact.Email != Null && oldConatcMap.get(newContact.id).Email != newContact.Email && oldConatcMap.get(newContact.id).Email != Null){
                
                contactIdsForEmailChange.add(newContact.id);
                string temp,fname,lname;
                fname= oldConatcMap.get(newContact.id).Firstname != null ? oldConatcMap.get(newContact.id).Firstname :'';
                temp= fname+' '+oldConatcMap.get(newContact.id).lastname+'-'+oldConatcMap.get(newContact.id).email;
                m1.put(temp,newContact);                       
            }
            if(newContact.Same_as_Household_Address__c != oldConatcMap.get(newContact.Id).Same_as_Household_Address__c && newContact.Same_as_Household_Address__c == true){
                addressSet.add(newContact.Id);
            }
            if((newContact.RecordTypeId == volunteerRecordTypeId) && ((newContact.FirstName != Null && oldConatcMap.get(newContact.id).FirstName != newContact.FirstName) || (newContact.LastName != Null && oldConatcMap.get(newContact.id).LastName != newContact.LastName) || (newContact.MobilePhone!= Null && oldConatcMap.get(newContact.id).MobilePhone!= newContact.MobilePhone) || (newContact.Email != Null && oldConatcMap.get(newContact.id).Email != newContact.Email) || 
                                                                      (newContact.MailingStreet != Null && oldConatcMap.get(newContact.id).MailingStreet != newContact.MailingStreet) || (newContact.MailingCity!= Null && oldConatcMap.get(newContact.id).MailingCity != newContact.MailingCity) || (newContact.mailingstate != Null && oldConatcMap.get(newContact.id).mailingstate != newContact.mailingstate) || (newContact.mailingpostalcode != Null && oldConatcMap.get(newContact.id).mailingpostalcode != newContact.mailingpostalcode) ||
                                                                      (newContact.County__c != Null && oldConatcMap.get(newContact.id).County__c != newContact.County__c) || (newContact.Fax != Null && oldConatcMap.get(newContact.id).Fax != newContact.Fax ))){
                                                                          
                                                                          updateUserInfo.put(newContact.id,newContact);
                                                                          contactOldMap.put(newContact.id,oldConatcMap.get(newContact.id));
                                                                      }
            if(newContact.RecordTypeId == familyContactRecordTypeId && newContact.Relationship__c != oldConatcMap.get(newContact.id).Relationship__c){
                wishFamilyContacMap.put(newContact.Id,newContact);
            }
         }
         
         for(Contact conCurrRec: [SELECT Id,OwnerId,migrated_record__c, AccountId,RecordTypeId,owner.UserRole.Name,Region_Chapter__c,Hidden_Hospital_Account__c, 
                                 Region_Chapter__r.Name,MailingState FROM Contact WHERE Id IN :Trigger.newMap.keySet() AND owner.UserRole.Name = 'National Staff' Limit 50000]){
                                     
                                     if(conCurrRec.OwnerId != oldConatcMap.get(conCurrRec.id).OwnerId && conCurrRec.Region_Chapter__c != Null && conCurrRec.Region_Chapter__r.Name != 'Make-A-Wish America'){
                                         
                                         if(contactMapforSharing.containsKey(conCurrRec.Region_Chapter__r.Name))
                                             contactMapforSharing.get(conCurrRec.Region_Chapter__r.Name).add(conCurrRec);
                                         else
                                             contactMapforSharing.put(conCurrRec.Region_Chapter__r.Name, new List<contact>{conCurrRec});
                                     }
          } 
          
          if((RecursiveTriggerHandler.isFirstTime || Test.isRunningTest()) && contactIdsForEmailChange.size()>0){
            RecursiveTriggerHandler.isFirstTime = false;
            Contact_OnAfterUpdateTriggerHepler.updateEmailAddress(contactIdsForEmailChange,m1);
          }
          if(contactMapforSharing.size() > 0){
            ChapterStaffRecordSharing_AC.ContactSharing(contactMapforSharing);
          }
          if(primaryDiagnosisChangesMap.size() > 0) {
            Contact_OnAfterUpdateTriggerHepler.updatePrimaryDiagnosis(primaryDiagnosisChangesMap);
          }
          if(volunteercontactSet.size() > 0){
            Contact_OnAfterUpdateTriggerHepler.updateOrgAffiliationStatustopending(volunteercontactSet);
          }
          if(rejectedApplicationIds.size() > 0){
            Contact_OnAfterUpdateTriggerHepler.updateOrgAffiliationStatustoDeclined(rejectedApplicationIds);
          }
          if(volunteerContactMap.size() > 0)
            Contact_OnAfterUpdateTriggerHepler.CreateVolunteerRoles(volunteerContactMap);
         if(zipCodesSet.size() > 0)
            Contact_OnAfterUpdateTriggerHepler.CreateZipcodeUpdateTask(zipCodesSet,contactMap);
         if(MedicalProfContactSet.size() > 0)
            Contact_OnAfterUpdateTriggerHepler.updateMedicalProfConatctInfo(MedicalProfContactSet);
         if(updateUserInfo.size() > 0){
            Contact_OnAfterUpdateTriggerHepler.updateUserDetails(updateUserInfo,contactOldMap);
        }
        if(addressSet.size() > 0){
            Contact_OnAfterUpdateTriggerHepler.updateHouseHoldAddress(addressSet);
        }
        if(wishFamilyContacMap.size() > 0)
            Contact_OnAfterUpdateTriggerHepler.updateRelationship(wishFamilyContacMap);
        if(conList.Size() > 0){
            Contact_OnAfterUpdateTriggerHepler.CreateAffliation(conList);
        }
    }
}