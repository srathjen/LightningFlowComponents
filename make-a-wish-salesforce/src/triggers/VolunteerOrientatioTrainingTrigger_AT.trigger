/**
 * Author      : MST Solutions
 * CreatedBy   : Kanagaraj
 * Date        : 14/07/2016
 * Description :
 * 1. VolunteerOrientatioTrainingTrigger_AT  is used when the volunteer Attendance is completed then the
 * corresponding volunteer contact status will be Active in the organization affiliation object.
 **/
trigger VolunteerOrientatioTrainingTrigger_AT on Volunteer_Orientation_Training__c (before insert, before update, before delete,
        after insert, after update, after delete, after undelete) {
    trac_TriggerHandlerBase.triggerHandler(new VolunteerOTDomain());
}