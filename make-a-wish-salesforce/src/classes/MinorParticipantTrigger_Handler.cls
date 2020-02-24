Public class MinorParticipantTrigger_Handler{
    static Id wishClearenceRecordTypeId= Constant_AC.WISH_CLEARANCE_ATTACHMENT_ID;
    static Id comboRecordTypeId = Constant_AC.COMBO_RECORD_ID;
    public static void OnAfterUpdate(Map<Id,Minor_Participant__c> newMap,Map<Id,Minor_Participant__c> oldMap){
        Map<String,Minor_Participant__c> comboWishFamilyMap = new Map<String,Minor_Participant__c>();
        Map<Id,Minor_Participant__c> minorParticipantMap = new Map<Id,Minor_Participant__c>();
        Map<String,String> comboEnvelopMap = new Map<String,String>();
        set<Id> comboWishChildIdSet = new Set<Id>();
        for(Minor_Participant__c newMinorParticipant : newMap.values()){
            if(newMinorParticipant.RecordTypeId == wishClearenceRecordTypeId){
                minorParticipantMap.put(newMinorParticipant.Case__c,newMinorParticipant);
            }
            
            if(newMinorParticipant.RecordTypeId == comboRecordTypeId && (newMinorParticipant.Hidden_Combo_FirstName__c != oldMap.get(newMinorParticipant.Id).Hidden_Combo_FirstName__c) || 
              (newMinorParticipant.Hidden_Combo_MiddleName__c != oldMap.get(newMinorParticipant.Id).Hidden_Combo_MiddleName__c) || (newMinorParticipant.Hidden_Combo_LastName__c != oldMap.get(newMinorParticipant.Id).Hidden_Combo_LastName__c)
              || (newMinorParticipant.Hidden_Combo_Relationship__c != oldMap.get(newMinorParticipant.Id).Hidden_Combo_Relationship__c) || (newMinorParticipant.Hidden_Combo_DOB__c != oldMap.get(newMinorParticipant.Id).Hidden_Combo_DOB__c) || 
              (newMinorParticipant.Hidden_Combo_Street__c != oldMap.get(newMinorParticipant.Id).Hidden_Combo_Street__c) || (newMinorParticipant.Hidden_Combo_City__c != oldMap.get(newMinorParticipant.Id).Hidden_Combo_City__c) || 
              (newMinorParticipant.Hidden_Combo_State__c != oldMap.get(newMinorParticipant.Id).Hidden_Combo_State__c) || (newMinorParticipant.Hidden_Combo_HomePhone__c != oldMap.get(newMinorParticipant.Id).Hidden_Combo_HomePhone__c) || 
              (newMinorParticipant.Hidden_Combo_MobilePhone__c != oldMap.get(newMinorParticipant.Id).Hidden_Combo_MobilePhone__c) || (newMinorParticipant.Hidden_Combo_TelePhone__c != oldMap.get(newMinorParticipant.Id).Hidden_Combo_TelePhone__c) || 
              (newMinorParticipant.Hidden_Combo_Email__c != oldMap.get(newMinorParticipant.Id).Hidden_Combo_Email__c) || (newMinorParticipant.Hidden_Combo_Zipcode__c != oldMap.get(newMinorParticipant.Id).Hidden_Combo_Zipcode__c)){
                
                comboWishFamilyMap.put(newMinorParticipant.Hidden_Combo_ContactId__c,newMinorParticipant);  
            }
            
              if(newMinorParticipant.RecordTypeId == comboRecordTypeId && (newMinorParticipant.Hidden_Combo_FirstName__c != oldMap.get(newMinorParticipant.Id).Hidden_Combo_FirstName__c)  
               || (newMinorParticipant.Hidden_Combo_LastName__c != oldMap.get(newMinorParticipant.Id).Hidden_Combo_LastName__c)){
                    string name = newMinorParticipant.Hidden_Combo_FirstName__c+' '+newMinorParticipant.Hidden_Combo_LastName__c; 
                    comboEnvelopMap.put(newMinorParticipant.Hidden_Combo_Envelop_Id__c,name);
                    comboWishChildIdSet.add(newMinorParticipant.Id);
            }
        }
        if(minorParticipantMap.size() > 0){
            MinorParticipantTrigger_Helper.updateAttachmentPath(minorParticipantMap);
        }
        if(comboWishFamilyMap.size() > 0){
            MinorParticipantTrigger_Helper.updateWishFamilyContact(comboWishFamilyMap);
        }
        if(comboEnvelopMap.size() > 0){
             MinorParticipantTrigger_Helper.updateDocusignRecipientName(comboEnvelopMap,comboWishChildIdSet);
        } 
    }
}