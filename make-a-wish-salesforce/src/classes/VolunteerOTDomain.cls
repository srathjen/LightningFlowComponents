/**
 * @description
 * @author Steve Doucette, Traction on Demand
 * @date 4/22/2020
 */
public class VolunteerOTDomain extends trac_TriggerHandlerBase {

    private final static String ACTION_TRAINING = 'Training';
    private final static String ACTION_REGISTERED = 'Registered';
    private final static String ACTION_VOLUNTEER_CANCELLED = 'Volunteer Cancelled';
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
        Set<Id> registerdCountId = VolunteerOTService.getAggregateVolunteers(cancelContactId, VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_REGISTERED);
        Set<Id> completedCountId = VolunteerOTService.getAggregateVolunteers(cancelContactId, VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_COMPLETED);

        VolunteerOTService.CancelledIdsWrapper cancelledIds
                = VolunteerOTService.cancelledIdsParser(newList, cancelContactId, registerdCountId, completedCountId);
        Set<Id> contactUpdateContactId = cancelledIds.contactUpdateContactIds;
        contactUpdateContactId.addAll(VolunteerOTService.getCompletedOrientationVolunteerIds(newList, oldMap));
        List<Contact> updateContactList = VolunteerOTService.updateContactsHiddenVolOTStatus(contactUpdateContactId);
        update updateContactList;

        Set<Id> userUpdateContactId = cancelledIds.userUpdateContactIds;
        VolunteerOTService.updateUserVolunteerStatus(userUpdateContactId, ACTION_VOLUNTEER_CANCELLED);
        VolunteerJourneyService.processVolunteersChapterRequirements(userUpdateContactId);
    }
}