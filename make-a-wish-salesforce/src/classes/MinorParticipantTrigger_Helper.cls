Public class MinorParticipantTrigger_Helper{
    static Id wishClearenceRecordTypeId= Constant_AC.WISH_CLEARANCE_ATTACHMENT_ID;
    public static void updateAttachmentPath(Map<Id,Minor_Participant__c> minorParticipantMap){
        integer i = 1;
        //List<Case> updateCaseList = new List<Case>();
        Map<Id,Case> updateCaseMap = new Map<Id,Case>();
        case updatecase = new case();
        for(Minor_Participant__c  dbMinor : [SELECT Id,Case__c,File_Path__c,Form_Name__c,AttachmentId__c,RecordTypeId FROM Minor_Participant__c WHERE 
                                             Case__c IN: minorParticipantMap.KeySet() AND RecordTypeId =: wishClearenceRecordTypeId]){
            
            if(minorParticipantMap.containsKey(dbMinor.Case__c)){
                
                updatecase.Id = dbMinor.Case__c;
                if(updatecase.File_Path__c == Null){
                 updatecase.File_Path__c = i +'-'+' '+dbMinor.File_Path__c+'<br><br>';
                 }
                else
                {
                 updatecase.File_Path__c = updatecase.File_Path__c + i +'-'+' '+dbMinor.File_Path__c+'<br><br>';
                 
                }
               i++;
                updateCaseMap.put(updatecase.Id,updatecase);
            }
           
        }
        
        if(updateCaseMap.size() > 0)
        update updateCaseMap.values();
    
    }
    
    /*When the user updates the values Parentgurdian informationfrom combo form then 
it will update the corresponding wish family contact records.*/
    public static void updateWishFamilyContact(Map<String,Minor_Participant__c> comboWishFamilyMap){
        
        List<Contact> updateWishFamilyList = new List<Contact>();
        for(Contact dbFamilyContact : [SELECT Id,FirstName,LastName,Middle_Name__c,Email,MailingStreet,MailingCity,
                                       MailingState,MailingPostalCode,Birthdate,HomePhone,MobilePhone,
                                       Relationship__c,npe01__WorkPhone__c FROM Contact 
                                       WHERE Id IN: comboWishFamilyMap.KeySet()]){
                                           
                                           IF(comboWishFamilyMap.containsKey(dbFamilyContact.Id)){
                                               
                                               dbFamilyContact.FirstName = comboWishFamilyMap.get(dbFamilyContact.Id).Hidden_Combo_FirstName__c; 
                                               dbFamilyContact.LastName = comboWishFamilyMap.get(dbFamilyContact.Id).Hidden_Combo_LastName__c; 
                                               dbFamilyContact.Middle_Name__c = comboWishFamilyMap.get(dbFamilyContact.Id).Hidden_Combo_MiddleName__c; 
                                               dbFamilyContact.Email = comboWishFamilyMap.get(dbFamilyContact.Id).Hidden_Combo_Email__c; 
                                               dbFamilyContact.Birthdate = comboWishFamilyMap.get(dbFamilyContact.Id).Hidden_Combo_DOB__c;
                                               dbFamilyContact.HomePhone = comboWishFamilyMap.get(dbFamilyContact.Id).Hidden_Combo_HomePhone__c; 
                                               dbFamilyContact.MobilePhone = comboWishFamilyMap.get(dbFamilyContact.Id).Hidden_Combo_MobilePhone__c; 
                                               dbFamilyContact.npe01__WorkPhone__c = comboWishFamilyMap.get(dbFamilyContact.Id).Hidden_Combo_TelePhone__c; 
                                               dbFamilyContact.MailingStreet = comboWishFamilyMap.get(dbFamilyContact.Id).Hidden_Combo_Street__c; 
                                               dbFamilyContact.MailingCity = comboWishFamilyMap.get(dbFamilyContact.Id).Hidden_Combo_City__c; 
                                               dbFamilyContact.MailingState = comboWishFamilyMap.get(dbFamilyContact.Id).Hidden_Combo_State__c; 
                                               dbFamilyContact.MailingPostalCode = comboWishFamilyMap.get(dbFamilyContact.Id).Hidden_Combo_Zipcode__c;
                                               dbFamilyContact.Relationship__c= comboWishFamilyMap.get(dbFamilyContact.Id).Hidden_Combo_Relationship__c;
                                               updateWishFamilyList.add(dbFamilyContact);
                                               
                                           }
                                           
                                       }
        if(updateWishFamilyList.size() > 0){
            update updateWishFamilyList;
        }
    } 
    
     public static void updateDocusignRecipientName(Map<String,String> comboEnvelopMap,Set<Id> comboRecIdSet){
        
        List<dsfs__DocuSign_Recipient_Status__c> updateRecipientList = new List<dsfs__DocuSign_Recipient_Status__c>();
        List<dsfs__DocuSign_Status__c> updateStatusRec  = new List<dsfs__DocuSign_Status__c>();
        String name;
       
        for(dsfs__DocuSign_Status__c dbStatusRec : [SELECT Id,Associated_Childeren__c,dsfs__DocuSign_Envelope_ID__c,dsfs__Case__c,(SELECT Id,Name FROM 
                                                                                                                                   R00NS0000000WUO2MAO),Recipient_names__c,Minor_Participant__c FROM dsfs__DocuSign_Status__c WHERE 
                                                    dsfs__DocuSign_Envelope_ID__c =: comboEnvelopMap.KeySet() AND
                                                    Minor_Participant__c IN: comboRecIdSet Limit 1]){
                                                        if(comboEnvelopMap.containsKey(dbStatusRec.dsfs__DocuSign_Envelope_ID__c)){            
                                                            
                                                            for(dsfs__DocuSign_Recipient_Status__c dbRecipient : dbStatusRec.R00NS0000000WUO2MAO){
                                                                dbRecipient.Name = comboEnvelopMap.get(dbStatusRec.dsfs__DocuSign_Envelope_ID__c);
                                                                name = comboEnvelopMap.get(dbStatusRec.dsfs__DocuSign_Envelope_ID__c);
                                                                updateRecipientList.add(dbRecipient);
                                                            }
                                                            dbStatusRec.Recipient_names__c  = name;
                                                            updateStatusRec.add(dbStatusRec);
                                                          
                                                        }
                                                    }
        if(updateRecipientList.size() > 0 && updateStatusRec.size() > 0){
            update updateRecipientList;
            update updateStatusRec;
         }
          
    } 
  }