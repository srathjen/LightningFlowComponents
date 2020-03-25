/**
 * @author Steve Doucette, Traction on Demand 
 * @date 3/25/2020
 */
public with sharing class DocusignStatusDomain extends trac_TriggerHandlerBase {

    List<dsfs__DocuSign_Status__c> newList = (List<dsfs__DocuSign_Status__c>) newRecordsList;
    List<dsfs__DocuSign_Status__c> oldList = (List<dsfs__DocuSign_Status__c>) oldRecordsList;
    Map<Id, dsfs__DocuSign_Status__c> newMap = (Map<Id, dsfs__DocuSign_Status__c>) newRecordsMap;
    Map<Id, dsfs__DocuSign_Status__c> oldMap = (Map<Id, dsfs__DocuSign_Status__c>) oldRecordsMap;

    public override void handleAfterInsert() {
        Set<Id> wrsToUpdate = new Set<Id>();
        for (dsfs__DocuSign_Status__c newStatus : newList) {
            if (newStatus.dsfs__Envelope_Status__c == 'Sent' && newStatus.Wish_Required_Signature__c != null)
                wrsToUpdate.add(newStatus.Wish_Required_Signature__c);
        }
        if (wrsToUpdate.isEmpty()) {
            return;
        }
        List<Wish_Required_Signature__c> updateWishSignatures = new List<Wish_Required_Signature__c>();
        for (Wish_Required_Signature__c wrsObj : [
                SELECT Id, Status__c, Wish_Case__c
                FROM Wish_Required_Signature__c
                WHERE Id In :wrsToUpdate
        ]) {
            wrsObj.Status__c = 'Sent';
            wrsObj.Format__c = 'E-Signature';
            wrsObj.Sent_Date__c = System.today();
            updateWishSignatures.add(wrsObj);
        }
        update updateWishSignatures;
    }

    public override void handleBeforeUpdate() {
        if (!RecursiveTriggerHandler.blockBeforeUpdate) {
            /**
             * JIRA: WLP-422
             * Author: Gustavo Mayer
             * Update: Commenting unused variable declaration.
             */
            List<Contact> contactList = new List<Contact>();
            List<Contact> confilictContactList = new List<Contact>();
            List<Conflict_Of_Interest__c> conflictList = new List<Conflict_Of_Interest__c>();
            Set<Id> leadIdSet = new Set<Id>();
            List<Lead> leadList = new List<Lead>();
            Set<Id> volunteercontactIdSet = new Set<Id>();
            Set<Id> parentWishIdSet = new Set<Id>();
            Set<Id> dstsIds = new Set<Id>();
            Set<Id> wishClearenceSetId = new Set<Id>();
            Set<Id> parentIdSet = new Set<Id>();

            /**
             * WLP-526
             * Whenever a DocuSign field is updated it is inserting a Conflict Of Interest,
             * creating a method to find existing Coi by Volunteer Contact Id and Signed Date
             */
            Map<Id, Conflict_Of_Interest__c> existingCoiMap = DocusignStatusService.findExistingCoiBySignedDate(newList, Date.today());
            for (dsfs__DocuSign_Status__c dsts : newList) {
                if (dsts.dsfs__Envelope_Status__c == 'Completed'
                        && oldMap.get(dsts.Id).dsfs__Envelope_Status__c != 'Completed'
                        && dsts.dsfs__Case__c != null) {
                    String subject = dsts.dsfs__Subject__c.trim();
                    if (subject.contains('Signature Required – Make-A-Wish Child' + '\'s'
                            + ' ' + 'Medical Summary Form:')
                            || subject.contains('Signature Required – Make-A-Wish Rush Child' + '\'s'
                            + ' ' + 'Medical Summary Form:')) {
                        parentWishIdSet.add(dsts.dsfs__Case__c);
                    }
                    if (subject.contains('Signature Required – Make-A-Wish Wish Clearance Form')
                            || subject.contains('Signature Required – Make-A-Wish Rush Wish Clearance Form')) {
                        wishClearenceSetId.add(dsts.dsfs__Case__c);
                        parentIdSet.add(dsts.dsfs__Case__c);
                    }
                    /* ****   WVC-2015  ***** */
                    if (subject.contains('Signature Required – Make-A-Wish Wish Clearance No Travel Form')
                            || subject.contains('Signature Required – Make-A-Wish Rush Wish Clearance No Travel Form')) {
                        wishClearenceSetId.add(dsts.dsfs__Case__c);
                        parentIdSet.add(dsts.dsfs__Case__c);
                    }
                    /***** End WVC-2015 ****/
                    if (subject.contains('Signature Required – Make-A-Wish Wish Clearance, Child' + '\'s' + ' ' + 'Medical Summary:')
                            || subject.contains('Signature Required – Make-A-Wish Rush Wish Clearance, Child' + '\'s' + ' ' + 'Medical Summary:')) {
                        parentWishIdSet.add(dsts.dsfs__Case__c);
                        wishClearenceSetId.add(dsts.dsfs__Case__c);
                    }
                }
                if (dsts.dsfs__Envelope_Status__c == 'Completed'
                        && oldMap.get(dsts.Id).dsfs__Envelope_Status__c != 'Completed') {
                    dstsIds.add(dsts.Id);
                }
                if (dsts.dsfs__Envelope_Status__c == 'Completed'
                        && oldMap.get(dsts.Id).dsfs__Envelope_Status__c != 'Completed'
                        && dsts.isConflict__c == true) {
                    Conflict_Of_Interest__c newconflict = new Conflict_Of_Interest__c();
                    newconflict.Volunteer_Contact__c = dsts.Docusign_Hidden_Contact__c ;
                    newconflict.Signed_Date__c = System.today();
                    newconflict.Expiration_Date__c = newconflict.Signed_Date__c.addYears(1);
                    //  newconflict.Active__c = true;
                    conflictList.add(newconflict);
                    volunteercontactIdSet.add(dsts.Docusign_Hidden_Contact__c);
                }
            }
            if (conflictList.size() > 0) {
                insert conflictList;
                for (dsfs__DocuSign_Status__c dsts : newList) {
                    Contact con = new Contact();
                    con.Id = dsts.Docusign_Hidden_Contact__c;
                    con.isApplication__c = false;
                    confilictContactList.add(con);

                    dsts.Conflict_Of_Interest__c = conflictList[0].Id;
                    //dsts.Docusign_Hidden_Contact__c = null;
                }
                update confilictContactList ;
            }

            if (wishClearenceSetId.size() > 0) {
                Map<Id, Case> updatechildSummaryMap = new Map<Id, Case>();
                for (Case dbCase : [
                        SELECT Id,Wish_Clearance_Received_Date__c
                        FROM Case
                        WHERE Id IN:wishClearenceSetId
                ]) {
                    dbCase.Wish_Clearance_Received_Date__c = System.today();
                    updatechildSummaryMap.put(dbCase.Id, dbCase);
                }
                update updatechildSummaryMap.values();
            }

            Map<Id, dsfs__DocuSign_Status__c> dstsStatusRecMap = new Map<Id, dsfs__DocuSign_Status__c>();
            if (dstsIds.size() > 0) {
                dstsStatusRecMap.putAll([
                        SELECT Id, Docusign_Hidden_Contact__c,Docusign_Hidden_Contact__r.Account.Volunteer_Manager__c,
                                Docusign_Hidden_Contact__r.OwnerId,dsfs__Contact__c,dsfs__Contact__r.Account.Volunteer_Manager__c,
                                dsfs__Contact__r.OwnerId
                        FROM dsfs__DocuSign_Status__c
                        WHERE Id IN :dstsIds
                ]);
            }
            for (dsfs__DocuSign_Status__c dsts : newList) {
                if (dsts.dsfs__Envelope_Status__c == 'Completed'
                        && dsts.isConflict__c == false
                        && dsts.dsfs__Lead__c == null
                        && dsts.dsfs__Case__c == null) {
                    if (dsts.Docusign_Hidden_Contact__c != null) {
                        Contact con = new Contact();
                        con.is_Application__c = Constant_AC.CONTACT_APPLICATION_STATUS_APPROVED;
                        con.Id = dsts.Docusign_Hidden_Contact__c ;
                        contactList.add(con);
                    }
                }
            }
            // Creating COI recod once docusign status has been changed to completed.
            if (contactList.size() > 0) {
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
                if (conflictList.size() > 0) {
                    insert conflictList;
                    for (dsfs__DocuSign_Status__c dsts : newList) {
                        dsts.Conflict_Of_Interest__c = conflictList[0].Id;
                    }
                }
                update contactList;
            }
        }
    }

    public override void handleAfterUpdate() {
        if (!RecursiveTriggerHandler.blockAfterUpdate) {
            Map<Id, Id> contactDocusignMap = new Map<Id, Id>(); // Holds Contact and its related Docusign Status record Id
            Set<Id> leadIdSet = new Set<Id>();
            List<Lead> leadList = new List<Lead>();
            Map<Id, Datetime> leadByDocuSignCompletedDateTime = new Map<Id, Datetime>();
            //Used to get Docusign Status record Id and its related Contact
            for (dsfs__DocuSign_Status__c newStatus : newList) {
                if (newStatus.dsfs__Contact__c != null && newStatus.dsfs__Subject__c == 'Diagnosis Verification Form'
                        && newStatus.dsfs__Contact__c != oldMap.get(newStatus.Id).dsfs__Contact__c) {
                    contactDocusignMap.put(newStatus.dsfs__Contact__c, newStatus.Id);
                }
                if ((newStatus.dsfs__Subject__c == 'Signature Required - Wish Form & Liability And Publicity Release Form' ||
                        newStatus.dsfs__Subject__c == 'Signature Required - Liability And Publicity Release Form' ||
                        newStatus.dsfs__Subject__c == 'Signature Required - Absent Parent Form' ||
                        newStatus.dsfs__Subject__c == 'Signature Required - Single Parent Form' ||
                        newStatus.dsfs__Subject__c == 'Signature Required - Combo Family Form & Liability/Publicity Release Form') &&
                        (newStatus .dsfs__Envelope_Status__c == 'Completed' || newStatus.dsfs__Envelope_Status__c != 'Completed')) {
                    if (!Test.isRunningTest()) {
                        //WishFormDashboard_AC wishFormDashBoard = new WishFormDashboard_AC(newStatus.dsfs__Case__c);
                    }
                }
                if (newStatus.dsfs__Envelope_Status__c == 'Completed' && oldMap.get(newStatus.Id).dsfs__Envelope_Status__c != 'Completed' && newStatus.dsfs__Lead__c != null) {
                    leadIdSet.add(newStatus.dsfs__Lead__c);
                    if (newStatus.dsfs__Completed_Date_Time__c != null) {
                        leadByDocuSignCompletedDateTime.put(newStatus.dsfs__Lead__c, newStatus.dsfs__Completed_Date_Time__c);
                    }
                }
            }
            //WLP-523 Moved form Before Update
            if (leadIdSet.size() > 0) {
                for (Lead dbLead : [
                        SELECT Id,isSign__c,Status,RFI_Form_Info_Hidden__c, Auto_Qualified__c, Provider_Signature__c, Part_A_DV_Recipient__c
                        FROM Lead
                        WHERE Id IN:leadIdSet AND Status = :'Referred' AND Sub_Status__c = 'Pending Diagnosis Verification'
                ]) {
                    if (dbLead.RFI_Form_Info_Hidden__c == 'Qualified') {
                        dbLead.Status = 'Qualified';
                        dbLead.Auto_Qualified__c = true; //Added as per IME 18
                        dbLead.Is_Required_Bypass__c = true; //Added as per IME-60
                        System.debug('DEBUGZ ' + dbLead);
                    }
                    if (dbLead.RFI_Form_Info_Hidden__c == 'Not Qualified') {
                        dbLead.Status = 'Eligibility Review';
                        dbLead.Is_Required_Bypass__c = false;//Added as per IME-60
                        System.debug('DEBUGZ ' + dbLead);
                    }

                    dbLead.isSign__c = true;
                    dbLead.Provider_Signature__c = dbLead.Part_A_DV_Recipient__c; // SIW-103

                    // Process Builder
                    if (leadByDocuSignCompletedDateTime.containsKey(dbLead.Id)) {
                        dbLead.Part_A_Received__c = leadByDocuSignCompletedDateTime.get(dbLead.Id).date();
                    }
                    System.debug('DEBUGZ Add' + dbLead);
                    leadList.add(dbLead);
                }
                if (leadList.size() > 0) {
                    System.debug('DEBUGZ Final' + leadList);
                    update leadList;
                }
            }
            if (contactDocusignMap.size() > 0) {
                DocusignStatusTriggerHandler.WishChildDVAttachment(contactDocusignMap);
            }
        }
    }
}