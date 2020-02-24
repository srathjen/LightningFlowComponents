/*****************************************************************************
Author : MST Solutions
CreateDate : 05/5/2017
Description : This WishPaperPacket_AT is used to update the Hidden object fields as "null" 
in Wish Information page if you select "No" for medical information section question.
******************************************************************************/

trigger WishPaperPacket_AT on Wish_Child_Form__c (Before insert,Before update, After update,After insert,Before delete) {
    Id familyContactRecordTypeId = Constant_AC.WISH_FORM_FAMILY_ID;
    Id wichChildRecordTypeId = Constant_AC.WISH_FORM_CHILD_ID;
    
    if(Trigger.isBefore && Trigger.isInsert){
        for(Wish_Child_Form__c dbWishchildForm : trigger.new){
            if(dbWishchildForm.Availability_Time_Period_1__c == 'null/null')
                dbWishchildForm.Availability_Time_Period_1__c = '';
            
            if(dbWishchildForm.Availability_Time_Period_2__c == 'null/null')
                dbWishchildForm.Availability_Time_Period_2__c = '';
            
            if(dbWishchildForm.Availability_Time_Period_3__c == 'null/null')
                dbWishchildForm.Availability_Time_Period_3__c = '';
        }
    }
    
    if(Trigger.isBefore && Trigger.isUpdate){
        for(Wish_Child_Form__c dbWishchildForm : trigger.new){
            if(dbWishchildForm.Participant_require_a_wheelchair__c == 'No')
                dbWishchildForm.Requested_Participant_Name_forWheelchair__c = null;
            
            if(dbWishchildForm.Will_your_family_bring_wheelchair__c == 'No')
                dbWishchildForm.Bringing_Own_Wheel_Chair__c = null;
            
            if(dbWishchildForm.Is_the_wheelchair_collapsible__c == 'No')
                dbWishchildForm.Name_of_wheelchair_collapsible__c = null;
            
            if(dbWishchildForm.Is_the_wheelchair_power__c == 'No')
                dbWishchildForm.Pariticipant_name_havingWheelchair_Power__c = null;
            
            if(dbWishchildForm.Participant_require_oxygen_how_often__c == 'No')
                dbWishchildForm.Requested_Participant_Name_for_Oxygen__c = null;
            
            if(dbWishchildForm.Participant_dietary_restrictions__c == 'No')
                dbWishchildForm.Participant_Name_for_Dietary_Restriction__c = null;
            
            if(dbWishchildForm.Participant_have_allergies_to_food__c == 'No')
                dbWishchildForm.Participant_have_allergies_to_food_Note__c= null;
            
            if(dbWishchildForm.Medication_require_refrigeration__c == 'No')
                dbWishchildForm.Medication_require_refrigeration_name__c = null;
            
            if(dbWishchildForm.Wish_child_receive_nursing_care__c == 'No')
                dbWishchildForm.Wish_child_receive_nursing_care_Note__c= null;
            
            if(dbWishchildForm.Participant_require_medical_supplies__c == 'No')
                dbWishchildForm.Requested_Participant_Name_for_OtherNeed__c  = null;
            
            if(dbWishchildForm.Availability_Time_Period_1__c == 'null/null')
                dbWishchildForm.Availability_Time_Period_1__c = '';
            
            if(dbWishchildForm.Availability_Time_Period_2__c == 'null/null')
                dbWishchildForm.Availability_Time_Period_2__c = '';
            
            if(dbWishchildForm.Availability_Time_Period_3__c == 'null/null')
                dbWishchildForm.Availability_Time_Period_3__c = '';
        }
    }
    
    if(Trigger.isAfter && Trigger.isInsert){
        Map<Id,Id> wishChildForm = new Map<Id,Id>();
        List<Contact> ContactList = new List<Contact>();
        for(Wish_Child_Form__c dbWishchildForm : trigger.new){
            if((dbWishchildForm.RecordTypeId == familyContactRecordTypeId || dbWishchildForm.RecordTypeId == wichChildRecordTypeId) && 
            dbWishchildForm.Contact__c != Null && dbWishchildForm.Migrated__c == false  ){
                wishChildForm.put(dbWishchildForm.Contact__c,dbWishchildForm.Id);
            }    
        }
        
        if(wishChildForm.size() > 0){
            for(Contact dbContact : [SELECT Id,Hidden_Wish_Form_Id__c FROM contact WHERE Id IN: wishChildForm.KeySet()]){
                if(wishChildForm.containsKey(dbContact.Id)){
                    dbContact.Hidden_Wish_Form_Id__c = wishChildForm.get(dbContact.Id);
                    ContactList.add(dbContact);
                }
            }
        }
        if(ContactList.size () > 0){
            update ContactList;
        }
    }
    
    if(Trigger.isAfter && Trigger.isUpdate){
        Map<String,String> envelopMap = new Map<String,String>();
        set<Id> conIdSet = new set<Id>();
        for(Wish_Child_Form__c dbWishchildForm : trigger.new){
            if(dbWishchildForm.FirstName__c != trigger.oldmap.get(dbWishchildForm.Id).FirstName__c  && 
               dbWishchildForm.LastName__c != trigger.oldMap.get(dbWishchildForm.Id).LastName__c && 
               dbWishchildForm.Middle_Name__c != trigger.oldMap.get(dbWishchildForm.Id).Middle_Name__c &&
               dbWishchildForm.Contact__c != Null && dbWishchildForm.Hidden_Combo_Envelop_Id__c != Null &&
               dbWishchildForm.Migrated__c == False){
                   string name =  dbWishchildForm.FirstName__c+' '+dbWishchildForm.LastName__c;
                   envelopMap.put(dbWishchildForm.Hidden_Combo_Envelop_Id__c,name);
                   conIdSet.add(dbWishchildForm.Contact__c);
               }
        }
        
        if(envelopMap.size() > 0){
            List<dsfs__DocuSign_Recipient_Status__c> updateRecipientList = new List<dsfs__DocuSign_Recipient_Status__c>();
            List<dsfs__DocuSign_Status__c> updateStatusRec  = new List<dsfs__DocuSign_Status__c>();
            String name;
            for(dsfs__DocuSign_Status__c dbStatusRec : [SELECT Id,Associated_Childeren__c,dsfs__DocuSign_Envelope_ID__c,
                                                        dsfs__Case__c,(SELECT Id,Name FROM R00NS0000000WUO2MAO),Recipient_names__c,dsfs__Case__r.contactId
                                                        FROM dsfs__DocuSign_Status__c
                                                        WHERE dsfs__DocuSign_Envelope_ID__c =: envelopMap.KeySet() Limit 1]){
                                                            if(envelopMap.containsKey(dbStatusRec.dsfs__DocuSign_Envelope_ID__c) &&
                                                               conIdSet.contains(dbStatusRec.dsfs__Case__r.contactId)){            
                                                                for(dsfs__DocuSign_Recipient_Status__c dbRecipient : dbStatusRec.R00NS0000000WUO2MAO){
                                                                    dbRecipient.Name = envelopMap.get(dbStatusRec.dsfs__DocuSign_Envelope_ID__c);
                                                                    name = envelopMap.get(dbStatusRec.dsfs__DocuSign_Envelope_ID__c);
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
}