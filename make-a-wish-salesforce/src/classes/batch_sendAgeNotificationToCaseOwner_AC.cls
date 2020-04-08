/**********************************************************************************************************************************
Author : MST Solutions
Created Date : 03/12/2017
Description : This class is used to update the case HiddenChildAgeEmailNotification__c field when the wish child age is updated with 18 and 17 years 11 month.
**************************************************************************************************************************************/
global class batch_sendAgeNotificationToCaseOwner_AC implements Database.Batchable<SObject>, Schedulable {

    private static final String CASE_STATUS_CLOSED = Constant_AC.CASE_STATUS_CLOSED;
    private static final String CASE_STATUS_COMPLETED = Constant_AC.CASE_STATUS_COMPLETED;
	private static final String CHILD_AGE_EMAIL_NOTIFICATION_BOTH = 'Both';
	private static final String CONTACT_AGE_18 = '18 Age';
	private static final String BIRTHDATE_BEFORE_MONTH = 'Before Month';

	private static final Id WISH_FAMILY_RT_ID = Constant_AC.WISH_FAMILY_RT_ID;
	private static final Id CONTACT_WISH_CHILD_RT_ID = Constant_AC.CONTACT_WISH_CHILD_RT_ID;
	private static final Id WISH_RT_ID = Constant_AC.WISH_RT_ID;

    global void execute(SchedulableContext SC) {
        Database.executeBatch(new batch_sendAgeNotificationToCaseOwner_AC(), 200);
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        Integer currentMonth = System.today().month();
        Integer beforeMonth = System.today().month() + 1;
        Integer todayDate = System.today().day();
        return Database.getQueryLocator([
                SELECT Id,Birthdate,Current_Age__c,RecordTypeId
                FROM Contact
                WHERE (RecordTypeId = :WISH_FAMILY_RT_ID OR RecordTypeId = :CONTACT_WISH_CHILD_RT_ID)
                AND (Current_Age__c = 17 OR Current_Age__c = 18)
                AND (CALENDAR_MONTH(Birthdate) = :currentMonth OR CALENDAR_MONTH(Birthdate) = :beforeMonth)
                AND (DAY_IN_MONTH(Birthdate) = :todayDate OR DAY_IN_MONTH(Birthdate) = 30
                OR (DAY_IN_MONTH(Birthdate) = 28 AND CALENDAR_MONTH(Birthdate) = 2))
        ]);
    }

    global void execute(Database.BatchableContext bc, List<Contact> contactList) {
        Integer currentMonth = System.today().month();

        Map<Id, String> familyContactMap = new Map<Id, String>();
        Map<Id, String> wishChildContactMap = new Map<Id, String>();
        for (Contact con : contactList) {
            Integer birthMonth = con.Birthdate.month();

            //This condition is used to update the case when the Participant age 18.
            if (con.Current_Age__c == 18 && ((con.Birthdate.day() == System.today().day()
                    && con.Birthdate.month() == System.today().month()) ||
                    (birthMonth == 2 && System.today().month() == 2 && con.Birthdate.day() == 29
                            && (!Date.isLeapYear(System.today().year())) && System.today().day() == 28))) {
                if (con.RecordTypeId == WISH_FAMILY_RT_ID) {
                    familyContactMap.put(con.Id, CONTACT_AGE_18);
                } else if (con.RecordTypeId == CONTACT_WISH_CHILD_RT_ID) {
                    wishChildContactMap.put(con.Id, CONTACT_AGE_18);
                }
            }

            //This condition is used to update the case when the wish child age 18 before 1 month.
            if (((birthMonth - 1) == System.today().month() && con.Current_Age__c == 17)
                    && ((con.Birthdate.day() == System.today().day()) ||
                    (con.Birthdate.day() == 31 && System.today().day() == 30
							&& (birthMonth == 1 || birthMonth == 3 || birthMonth == 5 || birthMonth == 7 || birthMonth == 8
                            || birthMonth == 10 || birthMonth == 12) && (currentMonth == 4 || currentMonth == 6 || currentMonth == 9
							|| currentMonth == 11))
					|| (birthMonth == 2 && System.today().month() == 2 && con.Birthdate.day() == 29
                            && (!Date.isLeapYear(System.today().year())) && System.today().day() == 28))) {
                if (con.RecordTypeId == WISH_FAMILY_RT_ID) {
                    familyContactMap.put(con.Id, BIRTHDATE_BEFORE_MONTH);
                } else if (con.RecordTypeId == CONTACT_WISH_CHILD_RT_ID) {
                    wishChildContactMap.put(con.Id, BIRTHDATE_BEFORE_MONTH);
                }
            }
        }

		Map<Id, String> wishChildFamilyMap = new Map<Id, String>();
        for (npe4__Relationship__c participant : [
                SELECT Id, npe4__RelatedContact__c, npe4__Contact__c
                FROM npe4__Relationship__c
                WHERE npe4__RelatedContact__c IN :familyContactMap.keySet()
        ]) {
            if (familyContactMap.containsKey(participant.npe4__RelatedContact__c)) {
                if (wishChildFamilyMap.containsKey(participant.npe4__Contact__c)) {
                    if (wishChildFamilyMap.get(participant.npe4__Contact__c) != familyContactMap.get(participant.npe4__RelatedContact__c)) {
                        wishChildFamilyMap.put(participant.npe4__Contact__c, CHILD_AGE_EMAIL_NOTIFICATION_BOTH);
                    }
                } else {
                    wishChildFamilyMap.put(participant.npe4__Contact__c, familyContactMap.get(participant.npe4__RelatedContact__c));
                }
            }
        }

        /**
         * WLP-428
         * Deprecating DNQ, replacing with Closed
         */
		Map<Id, Id> caseOwnerIdMap = new Map<Id, Id>();
		Map<Id, Case> updateCaseMap = new Map<Id, Case>();
        for (Case currCase : [
                SELECT Id, ContactId, OwnerId, HiddenChildAgeEmailNotification__c
                FROM Case
                WHERE (ContactId IN :wishChildFamilyMap.keySet()
                OR ContactId IN :wishChildContactMap.keySet())
                AND RecordTypeId = :WISH_RT_ID
                AND Status != :CASE_STATUS_COMPLETED
                AND Status != :CASE_STATUS_CLOSED
        ]) {
            if (wishChildFamilyMap.containsKey(currCase.ContactId)) {
                if (updateCaseMap.containsKey(currCase.Id)) {
                    if (updateCaseMap.get(currCase.Id).HiddenChildAgeEmailNotification__c != wishChildFamilyMap.get(currCase.ContactId)) {
                        currCase.HiddenChildAgeEmailNotification__c = CHILD_AGE_EMAIL_NOTIFICATION_BOTH;
                    } else {
                        currCase.HiddenChildAgeEmailNotification__c = wishChildFamilyMap.get(currCase.ContactId);
                    }
                } else {
                    currCase.HiddenChildAgeEmailNotification__c = wishChildFamilyMap.get(currCase.ContactId);
                }
                updateCaseMap.put(currCase.Id, currCase);
            }
            if (wishChildContactMap.containsKey(currCase.ContactId)) {
                if (updateCaseMap.containsKey(currCase.Id)) {
                    if (updateCaseMap.get(currCase.Id).HiddenChildAgeEmailNotification__c != wishChildContactMap.get(currCase.ContactId)) {
                        currCase.HiddenChildAgeEmailNotification__c = CHILD_AGE_EMAIL_NOTIFICATION_BOTH;
                    } else {
                        currCase.HiddenChildAgeEmailNotification__c = wishChildContactMap.get(currCase.ContactId);
                    }
                } else {
                    currCase.HiddenChildAgeEmailNotification__c = wishChildContactMap.get(currCase.ContactId);
                }
                updateCaseMap.put(currCase.Id, currCase);
                caseOwnerIdMap.put(currCase.OwnerId, currCase.Id);
            }
        }
        String inactiveUserList = '';
		List<ErrorMessage__e> errorMsgList = new List<ErrorMessage__e>();
        ErrorMessage__e errorMsg;
        for (User caseOwner : [
                SELECT Id, IsActive, Name
                FROM User
                WHERE Id IN :caseOwnerIdMap.keySet()
        ]) {
            if (!caseOwner.IsActive) {
                updateCaseMap.remove(caseOwnerIdMap.get(caseOwner.Id));
                inactiveUserList += 'Name:' + caseOwner.Name + '\tCase Id:' + caseOwnerIdMap.get(caseOwner.Id) + '\n';
                errorMsg = new ErrorMessage__e();
                errorMsg.Apex_Class__c = 'batch_sendAgeNotificationToCaseOwner_AC';
                errorMsg.Developer_Message__c = inactiveUserList;
                errorMsg.Message__c = 'Inactive User';
                errorMsg.Method__c = 'batch_sendAgeNotificationToCaseOwner_AC';
                errorMsg.Record_Id__c = '';
                errorMsg.Stack_Trace__c = '';
                errorMsg.Type__c = 'Information';
                errorMsgList.add(errorMsg);
            }
        }
        if (!errorMsgList.isEmpty()) {
            EventBus.publish(errorMsgList);
        }
        update updateCaseMap.values();
    }
    global void finish(Database.BatchableContext BC) {
    }
}