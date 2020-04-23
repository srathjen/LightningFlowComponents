/**
 * @description
 *
 * @author Steve Doucette, Traction on Demand
 *
 * @date 4/22/2020
 */
public class VolunteerOTDomain extends trac_TriggerHandlerBase {

    private final static String ACTION_TRAINING = 'Training';
    private final static String ACTION_REGISTERED = 'Registered';
    private final static String ACTION_VOLUNTEER_CANCELLED = 'Volunteer Cancelled';
    private final static String VOLUNTEER_ORIENTATION_TRAINING_TYPE_ORIENTATION = Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_TYPE_ORIENTATION;
    private final static String VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_COMPLETED = Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_COMPLETED;
    private final static String VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_REGISTERED = Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_REGISTERED;

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
        VolunteerOTService.updateUserVolunteerStatus(VolunteerOTService.getRegisteredOrientationVolunteerIds(newList, oldMap), ACTION_REGISTERED);
        VolunteerOTService.updateAffiliationStatusAsActive(VolunteerOTService.getTrainingCompletedVolunteerIds(newList));

        Set<Id> cancelContactId = VolunteerOTService.getCancelledTrainingVolunteers(newList, oldMap);
        Set<Id> registerdCountId = getAggregateVolunteers(cancelContactId, VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_REGISTERED);
        Set<Id> completedCountId = getAggregateVolunteers(cancelContactId, VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_COMPLETED);


        Set<Id> userUpdateContactId = new Set<Id>();
        Set<Id> contactUpdateContactId = new Set<Id>();
        for (Volunteer_Orientation_Training__c votcancelupdate : newList) {
            if (cancelContactId.contains(votcancelupdate.Volunteer__c) && !completedCountId.contains(votcancelupdate.Volunteer__c)) {
                if (!registerdCountId.contains(votcancelupdate.Volunteer__c)) {
                    userUpdateContactId.add(votcancelupdate.Volunteer__c);
                } else if (registerdCountId.contains(votcancelupdate.Volunteer__c)) {
                    contactUpdateContactId.add(votcancelupdate.Volunteer__c);
                }
            }
        }

        List<Contact> updateContactList = new List<Contact>();
        if (!contactUpdateContactId.isEmpty()) {
            for (Contact contactUpdate : [
                    SELECT Id,Hidden_Volunteer_OT_Status__c
                    FROM Contact
                    WHERE Id IN :contactUpdateContactId OR Id IN :VolunteerOTService.getCompletedOrientationVolunteerIds(newList, oldMap)
            ]) {
                contactUpdate.Hidden_Volunteer_OT_Status__c = Constant_AC.CONTACT_HIDDEN_VOLUNTEER_STATUS_ORIENTATION_WITHOUT_COMPLETED;
                updateContactList.add(contactUpdate);
            }
        }
        update updateContactList;

        VolunteerOTService.updateUserVolunteerStatus(userUpdateContactId, ACTION_VOLUNTEER_CANCELLED);
        VolunteerJourneyService.processVolunteersChapterRequirements(userUpdateContactId);
    }

    private static Set<Id> getAggregateVolunteers(Set<Id> volunteerIds, String volunteerAttendance) {
        Set<Id> ret = new Set<Id>();
        for (AggregateResult ar : [
                SELECT Volunteer__c cntid, COUNT(Id) cnt
                FROM Volunteer_Orientation_Training__c
                WHERE Volunteer__c IN :volunteerIds AND Volunteer_Attendance__c = :volunteerAttendance
                GROUP BY Volunteer__c
        ]) {
            ret.add((Id) ar.get('cntid'));
        }
        return ret;
    }
}