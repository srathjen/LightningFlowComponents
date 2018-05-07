/***************************************************************************************************
Author      : MST Solutions
Date        : 10/15/2016
Description : Contact_OnAfterInsertTriggerHandler is used to call the Helper class when the
              new contact record is created.
              
              Modification Log
              ------------------
              WVC-1884    KANAGARAJ  04/04/2018
              
*****************************************************************************************************/

public class Contact_OnAfterInsertTriggerHandler{
    // This method is used to call ContactSharing and CreateAffliation methods when the contact record is created.
    public static void OnAfterInsert(List<Contact> newContactList){
        Constant_AC constant = new Constant_AC();
        Id volunteerRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.volunteerRT).getRecordTypeId();
        Set<id> conId=new Set<Id>();
        List<Contact> conList = new List<Contact>();
        Map<Id,Contact> contactAccountIdMap = new Map<Id,Contact>();
        Map<String,List<Contact>> contactMapforSharing = new Map<String,List<Contact>>();
        
         for(Contact conCurrRec: newContactList){
            if(Bypass_Triggers__c.getValues(userInfo.getUserId()) == Null){
                conList.Add(conCurrRec);
            }
            if(conCurrRec.Region_Chapter__c!= Null && conCurrRec.Region_Chapter__r.Name != 'Make-A-Wish America')
            {   system.debug('currentContact------>'+conCurrRec);
             if(contactMapforSharing.containsKey(conCurrRec.Region_Chapter__r.Name))
                 contactMapforSharing.get(conCurrRec.Region_Chapter__r.Name).add(conCurrRec);
             else
                 contactMapforSharing.put(conCurrRec.Region_Chapter__r.Name, new List<contact>{conCurrRec});
            }
            if(conCurrRec.recordTypeid == volunteerRecordTypeId && conCurrRec.Do_Not_Create_User__c==False && conCurrRec.Migrated_Record__c == True)
             {
                 conId.add(conCurrRec.id);   
             }
         }
        if(contactMapforSharing.size() > 0){
            ChapterStaffRecordSharing_AC.ContactSharing(contactMapforSharing);
        }
        if(conList.size() > 0){
            Contact_OnAfterInsertTriggerHelper.CreateAffliation(conList);
        }
        if(conId.size()>0){
        VolunteerContactHandler.createUser(conId);
       }
       } 
    }