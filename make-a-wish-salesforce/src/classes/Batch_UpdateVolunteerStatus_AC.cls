/**
 * @description JIRA: WLP-422
 * Update: Changing the Volunteer_Roles status from 'Trained' to 'Active'
 * @author Gustavo Mayer
 */
global class Batch_UpdateVolunteerStatus_AC implements Database.Batchable<SObject>, Schedulable {

    private final static Id BOARD_MEMBER_RT_ID = Constant_AC.BOARD_MEMBER_RT_ID;
    private final static Id VOLUNTEER_RT_ID = Constant_AC.VOLUNTEER_RT_ID;

    global static List<Contact> start(Database.BatchableContext bc) {
        return [
                SELECT Id, Active_Board_Member__c, Active_Wish_Granter__c,
                        Active_Non_Wish_Granter__c, B_C_Expiration_Date__c,
                        COI_Expiration_Date__c
                FROM Contact
                WHERE RecordTypeId IN (:VOLUNTEER_RT_ID, :BOARD_MEMBER_RT_ID)
        ];
    }

    global static void execute(Database.BatchableContext bc, List<Contact> contactList) {
        /**
        *  WLP-619
        *  Copying the code here to a central Class so it can be reused
        */
        Map<Id, Contact> contactMap = new Map<Id, Contact>(contactList);
        ContactService.setVolunteerContactActive(contactMap);
    }

    global static void finish(Database.BatchableContext bc) {
    }

    global void execute(SchedulableContext sc) {
        Database.executeBatch(new Batch_UpdateVolunteerStatus_AC(), 25);
    }
}