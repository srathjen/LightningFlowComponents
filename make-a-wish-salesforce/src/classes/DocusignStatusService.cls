/**
 * @author Steve Doucette, Traction on Demand 
 * @date 3/25/2020
 */
public class DocusignStatusService {
    private static final String ATTACHMENT_NAME = 'DV_Form.pdf';
    private static final String DOCUSIGN_ENVELOPE_STATUS_COMPLETED = Constant_AC.DOCUSIGN_ENVELOPE_STATUS_COMPLETED;

    /**
    * @param newList
    */
    public static void updateWishSignatures(List<dsfs__DocuSign_Status__c> newList) {
        Set<Id> wrsToUpdate = new Set<Id>();
        for (dsfs__DocuSign_Status__c newStatus : newList) {
            if (newStatus.dsfs__Envelope_Status__c == Constant_AC.DOCUSIGN_STATUS_ENVELOPE_STATUS_SENT
                    && newStatus.Wish_Required_Signature__c != null) {
                wrsToUpdate.add(newStatus.Wish_Required_Signature__c);
            }
        }
        if (wrsToUpdate.isEmpty()) {
            return;
        }

        List<Wish_Required_Signature__c> updateWishSignatures = new List<Wish_Required_Signature__c>();
        for (Wish_Required_Signature__c wrsObj : [
                SELECT Id, Status__c, Wish_Case__c
                FROM Wish_Required_Signature__c
                WHERE Id IN :wrsToUpdate
        ]) {
            wrsObj.Status__c = Constant_AC.WISH_REQUIRED_SIGNATURE_STATUS_SENT;
            wrsObj.Format__c = Constant_AC.WISH_REQUIRED_SIGNATURE_FORMAT_ESIGNATURE;
            wrsObj.Sent_Date__c = System.today();
            updateWishSignatures.add(wrsObj);
        }
        update updateWishSignatures;
    }

    /**
    * @param newList
    * @param oldMap
    * @param signedDate
    */
    public static void updateRelatedParentRecords(List<dsfs__DocuSign_Status__c> newList, Map<Id, dsfs__DocuSign_Status__c> oldMap, Date signedDate) {
        Map<Id, Conflict_Of_Interest__c> existingCoiMap = new Map<Id, Conflict_Of_Interest__c>();
        Set<Id> contactIds = new Set<Id>();
        for (dsfs__DocuSign_Status__c docuSignStatus : newList) {
            contactIds.add(docuSignStatus.Docusign_Hidden_Contact__c);
        }
        for (Conflict_Of_Interest__c coi : [
                SELECT Volunteer_Contact__c, Signed_Date__c, Expiration_Date__c
                FROM Conflict_Of_Interest__c
                WHERE Volunteer_Contact__c IN :contactIds
                AND Signed_Date__c = :signedDate
        ]) {
            existingCoiMap.put(coi.Volunteer_Contact__c, coi);
        }

        /**
         * WLP-526
         * Whenever a DocuSign field is updated it is inserting a Conflict Of Interest,
         * creating a method to find existing Coi by Volunteer Contact Id and Signed Date
         */
        List<Conflict_Of_Interest__c> conflictList = new List<Conflict_Of_Interest__c>();
        Set<Id> dstsIds = new Set<Id>();
        Set<Id> wishClearanceSetId = new Set<Id>();
        Set<String> validDocusignStatusSubjects = new Set<String>{
                Constant_AC.DOCUSIGN_STATUS_SUBJECT_SIGNATURE_REQUIRED_WISH_CLEARANCE_FORM,
                Constant_AC.DOCUSIGN_STATUS_SUBJECT_SIGNATURE_REQUIRED_RUSH_WISH_CLEARANCE_FORM,
                Constant_AC.DOCUSIGN_STATUS_SUBJECT_SIGNATURE_REQUIRED_WISH_CLEARANCE_NO_TRAVEL_FORM,
                Constant_AC.DOCUSIGN_STATUS_SUBJECT_SIGNATURE_REQUIRED_RUSH_WISH_CLEARANCE_NO_TRAVEL_FORM,
                Constant_AC.DOCUSIGN_STATUS_SUBJECT_SIGNATURE_REQUIRED_WISH_CLEARANCE_CHILD_MEDICAL_FORM,
                Constant_AC.DOCUSIGN_STATUS_SUBJECT_SIGNATURE_REQUIRED_RUSH_WISH_CLEARANCE_CHILD_MEDICAL_FORM
        };
        for (dsfs__DocuSign_Status__c dsts : newList) {
            if (dsts.dsfs__Envelope_Status__c == Constant_AC.DOCUSIGN_ENVELOPE_STATUS_COMPLETED
                    && oldMap.get(dsts.Id).dsfs__Envelope_Status__c != Constant_AC.DOCUSIGN_ENVELOPE_STATUS_COMPLETED
                    && dsts.dsfs__Case__c != null) {
                String subject = dsts.dsfs__Subject__c.trim();
                if(validDocusignStatusSubjects.contains(subject)){
                    wishClearanceSetId.add(dsts.dsfs__Case__c);
                }
            }
            if (dsts.dsfs__Envelope_Status__c == Constant_AC.DOCUSIGN_ENVELOPE_STATUS_COMPLETED
                    && oldMap.get(dsts.Id).dsfs__Envelope_Status__c != Constant_AC.DOCUSIGN_ENVELOPE_STATUS_COMPLETED) {
                dstsIds.add(dsts.Id);
            }
            if (dsts.dsfs__Envelope_Status__c == Constant_AC.DOCUSIGN_ENVELOPE_STATUS_COMPLETED
                    && oldMap.get(dsts.Id).dsfs__Envelope_Status__c != Constant_AC.DOCUSIGN_ENVELOPE_STATUS_COMPLETED
                    && dsts.isConflict__c == true) {
                Conflict_Of_Interest__c newconflict = new Conflict_Of_Interest__c();
                newconflict.Volunteer_Contact__c = dsts.Docusign_Hidden_Contact__c ;
                newconflict.Signed_Date__c = System.today();
                newconflict.Expiration_Date__c = newconflict.Signed_Date__c.addYears(1);
                conflictList.add(newconflict);
            }
        }

        Map<Id, Contact> conflictContactMap = new Map<Id, Contact>();
        if (!conflictList.isEmpty()) {
            insert conflictList;
            for (dsfs__DocuSign_Status__c dsts : newList) {
                Contact con = new Contact();
                con.Id = dsts.Docusign_Hidden_Contact__c;
                con.isApplication__c = false;
                conflictContactMap.put(con.Id, con);
                dsts.Conflict_Of_Interest__c = conflictList[0].Id;
            }
            update conflictContactMap.values();
        }

        if (!wishClearanceSetId.isEmpty()) {
            Map<Id, Case> updateChildSummaryMap = new Map<Id, Case>();
            for (Case dbCase : [
                    SELECT Id,Wish_Clearance_Received_Date__c
                    FROM Case
                    WHERE Id IN:wishClearanceSetId
            ]) {
                dbCase.Wish_Clearance_Received_Date__c = System.today();
                updateChildSummaryMap.put(dbCase.Id, dbCase);
            }
            update updateChildSummaryMap.values();
        }

        Map<Id, dsfs__DocuSign_Status__c> dstsStatusRecMap = new Map<Id, dsfs__DocuSign_Status__c>();
        if (!dstsIds.isEmpty()) {
            dstsStatusRecMap.putAll([
                    SELECT Id, Docusign_Hidden_Contact__c,Docusign_Hidden_Contact__r.Account.Volunteer_Manager__c,
                            Docusign_Hidden_Contact__r.OwnerId,dsfs__Contact__c,dsfs__Contact__r.Account.Volunteer_Manager__c,
                            dsfs__Contact__r.OwnerId
                    FROM dsfs__DocuSign_Status__c
                    WHERE Id IN :dstsIds
            ]);
        }

        List<Contact> contactList = new List<Contact>();
        for (dsfs__DocuSign_Status__c dsts : newList) {
            if (dsts.dsfs__Envelope_Status__c == Constant_AC.DOCUSIGN_ENVELOPE_STATUS_COMPLETED
                    && !dsts.isConflict__c
                    && dsts.dsfs__Lead__c == null
                    && dsts.dsfs__Case__c == null
                    && dsts.Docusign_Hidden_Contact__c != null) {
                Contact con = new Contact();
                con.is_Application__c = Constant_AC.CONTACT_APPLICATION_STATUS_APPROVED;
                con.Id = dsts.Docusign_Hidden_Contact__c ;
                contactList.add(con);
            }
        }
        // Creating COI record once docusign status has been changed to completed.
        if (!contactList.isEmpty()) {
            Set<Id>volunteercontactSet = new Set<Id>();
            for (Contact cons : contactList) {
                /**
                 * WLP-526
                 * Whenever a DocuSign field is updated it is inserting a Conflict Of Interest,
                 * creating a method to find existing Coi by Volunteer Contact Id and Signed Date
                 */
                if (existingCoiMap.get(cons.Id) == null) {
                    Conflict_Of_Interest__c newconflict = new Conflict_Of_Interest__c();
                    newconflict.Volunteer_Contact__c = cons.Id;
                    newconflict.Signed_Date__c = System.today();
                    newconflict.Expiration_Date__c = newconflict.Signed_Date__c.addYears(1);
                    conflictList.add(newconflict);
                }
                volunteercontactSet.add(cons.Id);
            }
            if (!conflictList.isEmpty()) {
                insert conflictList;
                for (dsfs__DocuSign_Status__c dsts : newList) {
                    dsts.Conflict_Of_Interest__c = conflictList[0].Id;
                }
            }
            update contactList;
        }
    }

    /**
    * @param newList
    * @param oldMap
    */
    public static void updateLeads(List<dsfs__DocuSign_Status__c> newList, Map<Id, dsfs__DocuSign_Status__c> oldMap) {
        Map<Id, Id> contactDocusignMap = new Map<Id, Id>(); // Holds Contact and its related Docusign Status record Id
        Set<Id> leadIdSet = new Set<Id>();
        Map<Id, Datetime> leadByDocuSignCompletedDateTime = new Map<Id, Datetime>();

        //Used to get Docusign Status record Id and its related Contact
        for (dsfs__DocuSign_Status__c newStatus : newList) {
            if (newStatus.dsfs__Contact__c != null && newStatus.dsfs__Contact__c != oldMap.get(newStatus.Id).dsfs__Contact__c
                    && newStatus.dsfs__Subject__c == Constant_AC.DOCUSIGN_SUBJECT_DIAGNOSIS_VERIFICATION_FORM) {
                contactDocusignMap.put(newStatus.dsfs__Contact__c, newStatus.Id);
            }
            if (newStatus.dsfs__Envelope_Status__c == DOCUSIGN_ENVELOPE_STATUS_COMPLETED && oldMap.get(newStatus.Id).dsfs__Envelope_Status__c != DOCUSIGN_ENVELOPE_STATUS_COMPLETED
                    && newStatus.dsfs__Lead__c != null) {
                leadIdSet.add(newStatus.dsfs__Lead__c);
                if (newStatus.dsfs__Completed_Date_Time__c != null) {
                    leadByDocuSignCompletedDateTime.put(newStatus.dsfs__Lead__c, newStatus.dsfs__Completed_Date_Time__c);
                }
            }
        }
        //WLP-523 Moved form Before Update
        List<Lead> leadList = new List<Lead>();
        if (!leadIdSet.isEmpty()) {
            for (Lead dbLead : [
                    SELECT Id,isSign__c,Status,RFI_Form_Info_Hidden__c, Auto_Qualified__c, Provider_Signature__c, Part_A_DV_Recipient__c
                    FROM Lead
                    WHERE Id IN:leadIdSet AND Status = :Constant_AC.LEAD_STATUS_REFERRED AND Sub_Status__c = :Constant_AC.LEAD_SUB_STATUS_PENDING_DIAGNOSIS_VERIFICATION
            ]) {
                if (dbLead.RFI_Form_Info_Hidden__c == Constant_AC.LEAD_RFI_FORM_INFO_QUALIFIED) {
                    dbLead.Status = Constant_AC.LEAD_STATUS_QUALIFIED;
                    dbLead.Auto_Qualified__c = true; //Added as per IME 18
                    dbLead.Is_Required_Bypass__c = true; //Added as per IME-60
                }
                if (dbLead.RFI_Form_Info_Hidden__c == Constant_AC.LEAD_RFI_FORM_INFO_NOT_QUALIFIED) {
                    dbLead.Status = Constant_AC.LEAD_STATUS_ELIGIBILITY_REVIEW;
                    dbLead.Is_Required_Bypass__c = false;//Added as per IME-60
                }
                dbLead.isSign__c = true;
                dbLead.Provider_Signature__c = dbLead.Part_A_DV_Recipient__c; // SIW-103

                // Process Builder
                if (leadByDocuSignCompletedDateTime.containsKey(dbLead.Id)) {
                    dbLead.Part_A_Received__c = leadByDocuSignCompletedDateTime.get(dbLead.Id).date();
                }
                leadList.add(dbLead);
            }
            update leadList;
        }
        DocusignStatusService.wishChildDVAttachment(contactDocusignMap);
    }

    /**
    * @description Used to get Medical Professional signed DV_Form from Docusign Status record and to store that under related Wish Child
    * @param contactDocusignMap
    */
    public static void wishChildDVAttachment(Map<Id, Id> contactDocusignMap) {
        if (contactDocusignMap.isEmpty()) {
            return;
        }

        //Used to check whether Docusign Status is related to Wish Child Contact
        Set<Id> newWishChildContactSet = new Set<Id>(); // Hold Wish Child contacts Id
        for (Contact checkWishChildContact : [
                SELECT Id
                FROM Contact
                WHERE Id IN :contactDocusignMap.keySet() AND RecordTypeId = :Constant_AC.CONTACT_WISH_CHILD_RT_ID
        ]) {
            newWishChildContactSet.add(checkWishChildContact.Id);
        }

        Map<Id, Attachment> docusignAttachmentMap = new Map<Id, Attachment>(); //Holds Docusign Status record attachments
        if (!newWishChildContactSet.isEmpty()) {
            //Get all Attachment form Docusign Status Record
            for (Attachment dvAttachment : [
                    SELECT Id, Name, Body, ParentId
                    FROM Attachment
                    WHERE ParentId IN :contactDocusignMap.values()
            ]) {
                docusignAttachmentMap.put(dvAttachment.ParentId, dvAttachment);
            }

            //Insert 'DV_Form' attachment under Wish Child Record whish is signed by Medical Professional
            List<Attachment> newDVAttachmentList = new List<Attachment>(); //Holds DV_Form which is signed by Medical Professional
            for (Id insertAttachment : newWishChildContactSet) {
                if (contactDocusignMap.containsKey(insertAttachment) && docusignAttachmentMap.containsKey(contactDocusignMap.get(insertAttachment))) {
                    Attachment newDVAttachment = new Attachment();
                    newDVAttachment.Name = ATTACHMENT_NAME;
                    newDVAttachment.Body = docusignAttachmentMap.get(contactDocusignMap.get(insertAttachment)).Body;
                    newDVAttachment.ParentId = insertAttachment;
                    newDVAttachmentList.add(newDVAttachment);
                }
            }
            insert newDVAttachmentList;
        }
    }
}