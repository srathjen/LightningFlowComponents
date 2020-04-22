/**
 * @author Steve Doucette, Traction on Demand
 *
 * @date 4/22/2020
 */
public class VolunteerOTDomain extends trac_TriggerHandlerBase {

    private final static String ACTION_TRAINING = 'Training';
    private final static String ACTION_REGISTERED = 'Registered';
    private final static String ACTION_VOLUNTEER_CANCELLED = 'Volunteer Cancelled';
    private final static String VOLUNTEER_ORIENTATION_TRAINING_TYPE_TRAINING = Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_TYPE_TRAINING;
    private final static String VOLUNTEER_ORIENTATION_TRAINING_TYPE_ORIENTATION = Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_TYPE_ORIENTATION;
    private final static String VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_COMPLETED = Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_COMPLETED;
    private final static String VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_REGISTERED = Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_REGISTERED;
    private final static String VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_VOLUNTEER_CANCELLED = Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_VOLUNTEER_CANCELLED;

    private List<Volunteer_Orientation_Training__c> newList = (List<Volunteer_Orientation_Training__c>) newRecordsList;
    private List<Volunteer_Orientation_Training__c> oldList = (List<Volunteer_Orientation_Training__c>) oldRecordsList;
    private Map<Id, Volunteer_Orientation_Training__c> newMap = (Map<Id, Volunteer_Orientation_Training__c>) newRecordsMap;
    private Map<Id, Volunteer_Orientation_Training__c> oldMap = (Map<Id, Volunteer_Orientation_Training__c>) oldRecordsMap;

    public override void handleBeforeInsert() {
        VolunteerOTService.setVolOTFields(newList);
        VolunteerOTService.updateContactRec(VolunteerOTService.getTrainingVOTRecords(newList));
    }

    public override void handleBeforeUpdate() {
        VolunteerOTService.setVolOTFields(newList, oldMap);
        VolunteerOTService.updateContactRec(VolunteerOTService.getTrainingVOTRecords(newList));
    }

    public override void handleAfterInsert() {
        Set<Id> trainingCompletedVolunteerIdsSet = VolunteerOTService.getTrainingCompletedVolunteerIds(newList);
        VolunteerOTService.updateVolunteerHiddenVolOTStatus(VolunteerOTService.getTrainingRegisteredVolunteerIds(newList), ACTION_TRAINING);
        VolunteerOTService.updateUserVolunteerStatus(VolunteerOTService.getRegisteredOrientationVolunteerIds(newList), ACTION_REGISTERED);
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
                if (newVol.Volunteer_Attendance__c != null && newVol.Volunteer_Attendance__c == VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_COMPLETED && newVol.Type__c == VOLUNTEER_ORIENTATION_TRAINING_TYPE_TRAINING) {
                    volnteerContactIdSet.add(newVol.Volunteer__c);
                }
            }
            Volunteer_Orientation_Training__c oldVol = oldMap.get(newVol.Id);
            if (newVol.Volunteer_Attendance__c == VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_COMPLETED
                    && newVol.Type__c == VOLUNTEER_ORIENTATION_TRAINING_TYPE_ORIENTATION && oldVol.Volunteer_Attendance__c != VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_COMPLETED) {
                completedContactSet.add(newVol.Volunteer__c);
            }
            if (newVol.Volunteer_Attendance__c == VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_REGISTERED
                    && newVol.Type__c == VOLUNTEER_ORIENTATION_TRAINING_TYPE_ORIENTATION && oldVol.Volunteer_Attendance__c != VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_REGISTERED) {
                registeredVolunteerIds.add(newVol.Volunteer__c);
            }

            if (newVol.Volunteer_Attendance__c == VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_VOLUNTEER_CANCELLED && newVol.Type__c == VOLUNTEER_ORIENTATION_TRAINING_TYPE_ORIENTATION && oldVol.Volunteer_Attendance__c != VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_VOLUNTEER_CANCELLED) {
                cancelContactId.add(newVol.Volunteer__c);
            }
        }

        if (!completedContactSet.isEmpty()) {
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

        VolunteerOTService.updateUserVolunteerStatus(registeredVolunteerIds, ACTION_REGISTERED);
        VolunteerOTService.updateAffiliationStatusAsActive(volnteerContactIdSet);

        for (AggregateResult ar : [
                SELECT Volunteer__c cntid, COUNT(Id) cnt
                FROM Volunteer_Orientation_Training__c
                WHERE Volunteer__c IN :cancelContactId AND Volunteer_Attendance__c = :VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_REGISTERED
                GROUP BY Volunteer__c
        ]) {
            registerdCountId.add((Id) ar.get('cntid'));
        }

        for (AggregateResult ar : [
                SELECT Volunteer__c cntid, COUNT(Id) cnt
                FROM Volunteer_Orientation_Training__c
                WHERE Volunteer__c IN :cancelContactId AND Volunteer_Attendance__c = :VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_COMPLETED
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

        if (!contactUpdateContactId.isEmpty()) {
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
        VolunteerOTService.updateUserVolunteerStatus(userUpdateContactId, ACTION_VOLUNTEER_CANCELLED);

        update updateContactList;
        update contactCompletedUpdate;
        VolunteerJourneyService.processVolunteersChapterRequirements(userUpdateContactId);
    }
}