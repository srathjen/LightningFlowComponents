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
}