/**
 * @author Steve Doucette, Traction on Demand
 *
 * @date 4/22/2020
 */
public class VolunteerOTDomain extends trac_TriggerHandlerBase {

    private List<Volunteer_Orientation_Training__c> newList = (List<Volunteer_Orientation_Training__c>) newRecordsList;
    private List<Volunteer_Orientation_Training__c> oldList = (List<Volunteer_Orientation_Training__c>) oldRecordsList;
    private Map<Id, Volunteer_Orientation_Training__c> newMap = (Map<Id, Volunteer_Orientation_Training__c>) newRecordsMap;
    private Map<Id, Volunteer_Orientation_Training__c> oldMap = (Map<Id, Volunteer_Orientation_Training__c>) oldRecordsMap;

    public override void handleBeforeInsert() {
        Set<String> volOTSet = new Set<String>();
        Set<Id> orientationAndTrainingSet = new Set<Id>();
        Map<Id, Contact> contactInfoMap = new Map<Id, Contact>();
        Set<String> classOfferingIdSet = new Set<String>();
        Map<String, String> orientationIdMap = new Map<String, String>();
        List<Volunteer_Orientation_Training__c> volunteerOrientationTrainingList = new List<Volunteer_Orientation_Training__c>();
        for (Volunteer_Orientation_Training__c currRec : newList) {
            if (!trac_TriggerHandlerBase.blockTrigger) {
                if (currRec.Volunteer__c != null) {
                    volOTSet.add(currRec.Volunteer__c);
                }
                if (currRec.Hidden_O_T_Id__c != null) {
                    orientationAndTrainingSet.add(currRec.Id);
                }

                if (currRec.Volunteer__c != null && currRec.Class_Offering__c != null && (Trigger.isInsert || oldMap.get(currRec.Id).Class_Offering__c != currRec.Class_Offering__c)) {
                    classOfferingIdSet.add(currRec.Class_Offering__c);
                }

                if (currRec.Type__c == 'Training'
                        && (currRec.Volunteer_Attendance__c == 'Registered' || currRec.Volunteer_Attendance__c == 'Completed' || currRec.Volunteer_Attendance__c == 'Volunteer Cancelled')) {
                    volunteerOrientationTrainingList.add(currRec);
                }
            }
        }

        for (Contact getContactInfo : [
                SELECT Id, Name, Account.Name, Account.Phone,Email,Account.Email__c
                FROM Contact
                WHERE Id IN :volOTSet
        ]) {
            if (!contactInfoMap.containsKey(getContactInfo.Id)) {
                contactInfoMap.put(getContactInfo.Id, getContactInfo);
            }
        }

        if (classOfferingIdSet.size() > 0) {
            for (Class_Offering__c currRec : [
                    SELECT Id,Chapter_Role_O_T__r.Orientation_Training__c
                    FROM Class_Offering__c
                    WHERE Id IN :classOfferingIdSet
            ]) {
                orientationIdMap.put(currRec.Id, currRec.Chapter_Role_O_T__r.Orientation_Training__c);
            }
        }

        for (Volunteer_Orientation_Training__c currRec : newList) {
            if (!trac_TriggerHandlerBase.blockTrigger) {
                if (currRec.Volunteer__c != null && contactInfoMap.containsKey(currRec.Volunteer__c)) {
                    currRec.Account_Name__c = contactInfoMap.get(currRec.Volunteer__c).Account.Name;
                    currRec.Account_Phone__c = contactInfoMap.get(currRec.Volunteer__c).Account.Phone;
                    currRec.VolunteerHidden_Email__c = contactInfoMap.get(currRec.Volunteer__c).Email;
                    currRec.Account_Email__c = contactInfoMap.get(currRec.Volunteer__c).Account.Email__c;
                }

                //Update the hidden O&T Id field with the orientation and training Id.
                if (currRec.Class_Offering__c != null && currRec.Class_Offering__c != null && orientationIdMap.containsKey(currRec.Class_Offering__c)) {
                    currRec.Hidden_O_T_Id__c = orientationIdMap.get(currRec.Class_Offering__c);
                }
            }
        }
        VolunteerOTService.updateContactRec(volunteerOrientationTrainingList);
    }

    public override void handleBeforeUpdate() {
        Set<String> volOTSet = new Set<String>();
        Set<Id> orientationAndTrainingSet = new Set<Id>();
        Map<Id, Contact> contactInfoMap = new Map<Id, Contact>();
        Set<String> classOfferingIdSet = new Set<String>();
        Map<String, String> orientationIdMap = new Map<String, String>();
        List<Volunteer_Orientation_Training__c> volunteerOrientationTrainingList = new List<Volunteer_Orientation_Training__c>();
        for (Volunteer_Orientation_Training__c currRec : newList) {
            if (!trac_TriggerHandlerBase.blockTrigger) {
                if (currRec.Volunteer__c != null) {
                    volOTSet.add(currRec.Volunteer__c);
                }
                if (currRec.Hidden_O_T_Id__c != null) {
                    orientationAndTrainingSet.add(currRec.Id);
                }

                if (currRec.Volunteer__c != null && currRec.Class_Offering__c != null && (Trigger.isInsert || oldMap.get(currRec.Id).Class_Offering__c != currRec.Class_Offering__c)) {
                    classOfferingIdSet.add(currRec.Class_Offering__c);
                }

                if (currRec.Type__c == 'Training' && currRec.Volunteer_Attendance__c == 'Registered') {
                    volunteerOrientationTrainingList.add(currRec);
                }

                if (currRec.Type__c == 'Training' && (currRec.Volunteer_Attendance__c == 'Completed' || currRec.Volunteer_Attendance__c == 'Volunteer Cancelled')) {
                    volunteerOrientationTrainingList.add(currRec);
                }
            }
        }

        for (Contact getContactInfo : [
                SELECT Id, Name, Account.Name, Account.Phone,Email,Account.Email__c
                FROM Contact
                WHERE Id IN :volOTSet
        ]) {
            if (!contactInfoMap.containsKey(getContactInfo.Id)) {
                contactInfoMap.put(getContactInfo.Id, getContactInfo);
            }
        }

        if (classOfferingIdSet.size() > 0) {
            for (Class_Offering__c currRec : [
                    SELECT Id,Chapter_Role_O_T__r.Orientation_Training__c
                    FROM Class_Offering__c
                    WHERE Id IN :classOfferingIdSet
            ]) {
                orientationIdMap.put(currRec.Id, currRec.Chapter_Role_O_T__r.Orientation_Training__c);
            }
        }

        for (Volunteer_Orientation_Training__c currRec : newList) {
            if (!trac_TriggerHandlerBase.blockTrigger) {
                if (currRec.Volunteer__c != null && contactInfoMap.containsKey(currRec.Volunteer__c)) {
                    currRec.Account_Name__c = contactInfoMap.get(currRec.Volunteer__c).Account.Name;
                    currRec.Account_Phone__c = contactInfoMap.get(currRec.Volunteer__c).Account.Phone;
                    currRec.VolunteerHidden_Email__c = contactInfoMap.get(currRec.Volunteer__c).Email;
                    currRec.Account_Email__c = contactInfoMap.get(currRec.Volunteer__c).Account.Email__c;
                }

                //Update the hidden O&T Id field with the orientation and training Id.
                if (currRec.Class_Offering__c != null && currRec.Class_Offering__c != null && orientationIdMap.containsKey(currRec.Class_Offering__c)) {
                    currRec.Hidden_O_T_Id__c = orientationIdMap.get(currRec.Class_Offering__c);
                }
            }
        }
        VolunteerOTService.updateContactRec(volunteerOrientationTrainingList);
    }

    public override void handleAfterInsert() {
        Set<Id> contactId = new Set<Id>();
        Set<Id> trainingRegisteredVolIdsSet = new Set<Id>();
        Set<Id> trainingCompletedVolunteerIdsSet = new Set<Id>();
        for (Volunteer_Orientation_Training__c newVolInsert : newList) {
            if (newVolInsert.Type__c == 'Orientation' && newVolInsert.Volunteer_Attendance__c == 'Registered') {
                contactId.add(newVolInsert.Volunteer__c);
            }

            if (newVolInsert.Type__c == 'Training') {
                if(newVolInsert.Volunteer_Attendance__c == 'Registered'){
                    trainingRegisteredVolIdsSet.add(newVolInsert.Volunteer__c);
                } else if (newVolInsert.Volunteer_Attendance__c == 'Completed'){
                    trainingCompletedVolunteerIdsSet.add(newVolInsert.Volunteer__c);
                }
            }
        }
        VolunteerOTService.updateVolunteerHiddenVolOTStatus(trainingRegisteredVolIdsSet, 'training');
        VolunteerOTService.updateUserVolunteerStatus(contactId, 'Registered');
        VolunteerOTService.updateAffiliationStatusAsActive(trainingCompletedVolunteerIdsSet);
        VolunteerJourneyService.processVolunteersChapterRequirements(trainingCompletedVolunteerIdsSet);
    }

    public override void handleAfterUpdate() {
        Set<Id> volnteerContactIdSet = new Set<Id>();
        Set<Id> cancelContactId = new Set<Id>();
        Set<Id> registerdCountId = new Set<Id>();
        Set<Id> userUpdateContactId = new Set<Id>();
        Set<Id> contactUpdateContactId = new Set<Id>();
        Set<Id> completedCountId = new Set<Id>();
        List<Contact> updateContactList = new List<Contact>();
        Set<Id> completedContactSet = new Set<Id>();
        Set<Id> registeredVolunteerIds = new Set<Id>();
        List<Contact> contactCompletedUpdate = new List<Contact>();

        for (Volunteer_Orientation_Training__c newVol : newList) {
            if (!trac_TriggerHandlerBase.blockTrigger) {
                if (newVol.Volunteer_Attendance__c != null && newVol.Volunteer_Attendance__c == 'Completed' && newVol.Type__c == 'Training') {
                    volnteerContactIdSet.add(newVol.Volunteer__c);
                }
            }
            Volunteer_Orientation_Training__c oldVol = oldMap.get(newVol.Id);
            if (newVol.Volunteer_Attendance__c == 'Completed' && newVol.Type__c == 'Orientation' && oldVol.Volunteer_Attendance__c != 'Completed') {
                completedContactSet.add(newVol.Volunteer__c);
            }
            if (newVol.Volunteer_Attendance__c == 'Registered' && newVol.Type__c == 'Orientation' && oldVol.Volunteer_Attendance__c != 'Registered') {
                registeredVolunteerIds.add(newVol.Volunteer__c);
            }

            if (newVol.Volunteer_Attendance__c == 'Volunteer Cancelled' && newVol.Type__c == 'Orientation' && oldVol.Volunteer_Attendance__c != 'Volunteer Cancelled') {
                cancelContactId.add(newVol.Volunteer__c);
            }
        }

        if (completedContactSet.size() > 0) {
            for (Contact contactCompleted : [
                    SELECT Id,Hidden_Volunteer_OT_Status__c
                    FROM Contact
                    WHERE Id IN :completedContactSet
            ]) {
                Contact contactUpdate = new Contact();
                contactUpdate.Id = contactCompleted.Id;
                contactUpdate.Hidden_Volunteer_OT_Status__c = 'Orientation With Completed';
                contactCompletedUpdate.add(contactUpdate);
            }
        }

        VolunteerOTService.updateUserVolunteerStatus(registeredVolunteerIds, 'Registered');
        VolunteerOTService.updateAffiliationStatusAsActive(volnteerContactIdSet);

        for (AggregateResult ar : [
                SELECT Volunteer__c cntid, COUNT(Id) cnt
                FROM Volunteer_Orientation_Training__c
                WHERE Volunteer__c IN :cancelContactId AND Volunteer_Attendance__c = 'Registered'
                GROUP BY Volunteer__c
        ]) {
            registerdCountId.add((Id) ar.get('cntid'));
        }

        for (AggregateResult ar : [
                SELECT Volunteer__c cntid, COUNT(Id) cnt
                FROM Volunteer_Orientation_Training__c
                WHERE Volunteer__c IN :cancelContactId AND Volunteer_Attendance__c = 'Completed'
                GROUP BY Volunteer__c
        ]) {
            completedCountId.add((Id) ar.get('cntid'));
        }
        for (Volunteer_Orientation_Training__c votcancelupdate : newList) {
            if (cancelContactId.contains(votcancelupdate.Volunteer__c) && !registerdCountId.contains(votcancelupdate.Volunteer__c) && !completedCountId.contains(votcancelupdate.Volunteer__c)) {
                userUpdateContactId.add(votcancelupdate.Volunteer__c);
            } else if (cancelContactId.contains(votcancelupdate.Volunteer__c) && registerdCountId.contains(votcancelupdate.Volunteer__c) && !completedCountId.contains(votcancelupdate.Volunteer__c)) {
                contactUpdateContactId.add(votcancelupdate.Volunteer__c);
            }
        }

        if (contactUpdateContactId.size() > 0) {
            for (Contact contactUpdate : [
                    SELECT Id,Hidden_Volunteer_OT_Status__c
                    FROM Contact
                    WHERE Id IN :contactUpdateContactId
            ]) {
                Contact contactUpdation = new Contact();
                contactUpdation.Id = contactUpdate.Id;
                contactUpdation.Hidden_Volunteer_OT_Status__c = 'Orientation Without Completed';
                updateContactList.add(contactUpdation);
            }
        }
        VolunteerOTService.updateUserVolunteerStatus(userUpdateContactId, 'Volunteer Cancelled');

        update updateContactList;
        update contactCompletedUpdate;
        VolunteerJourneyService.processVolunteersChapterRequirements(userUpdateContactId);
    }
}