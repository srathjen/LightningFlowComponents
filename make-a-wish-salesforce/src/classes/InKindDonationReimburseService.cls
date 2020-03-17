/**
 * Service layer class for In_Kind_Donation_Reimbursement__c related operations
 *
 * @author Chris Shinnimin, Traction on Demand
 * @date 2020-03-17
 */
public with sharing class InKindDonationReimburseService {

    /*
     * @description     Function to validate chapter role before update.
     *                  Placed in service class as part of Traction code cleanup.
     *
     * @param           List<In_Kind_Donation_Reimbursement__c> newIkdReimbursements
     * @param           Map<Id, In_Kind_Donation_Reimbursement__c> newIkdReimbursementsMap
     *
     * @author          MST Solutions
     * @date            unknown
     */
    public static void validateChapterRole(List<In_Kind_Donation_Reimbursement__c> newIkdReimbursements, Map<Id, In_Kind_Donation_Reimbursement__c> newIkdReimbursementsMap) {
        List<User> currUser = [
            SELECT
                Id,
                UserRole.Name,
                Chapter_Name__c,
                Profile.Name,
                Profile.Id
            FROM User
            WHERE Id = :UserInfo.getUserId()
            LIMIT 1
        ];

        Set<String> chapterNamesSet = new Set<String>();
        Map<Id, String> chapterNameMap = new Map<Id, String>();
        Map<String, String> chapterRoleMap = new Map<String, String>();

        for (In_Kind_Donation_Reimbursement__c currRec : [
            SELECT Id, OwnerId, Wish__c, Owner.UserRole.Name, Wish__r.ChapterName__r.Name
            FROM In_Kind_Donation_Reimbursement__c
            WHERE Id IN :newIkdReimbursementsMap.keySet()
        ]) {
            if (currRec.Wish__c != null) {
                chapterNamesSet.add(currRec.Wish__r.ChapterName__r.Name);
            }

            chapterNameMap.put(currRec.Id, currRec.Wish__r.ChapterName__r.Name);
        }

        if (chapterNamesSet.size() > 0) {
            chapterRoleMap = ChapterStaffRecordSharing_AC.FindChapterRole(chapterNamesSet);

            for (In_Kind_Donation_Reimbursement__c currRec : newIkdReimbursements) {
                if (chapterRoleMap.get(chapterNameMap.get(currRec.Id)) != currUser[0].UserRole.Name && currUser[0].UserRole.Name != 'National Staff' && Bypass_Triggers__c.getValues(userInfo.getUserId()) == null
                    && currUser[0].Profile.Name != 'System Administrator' && currUser[0].Chapter_Name__c != (chapterNameMap.get(currRec.Id)) && currUser[0].Profile.Id != Label.Active_Volunteer_Profile) {
                    currRec.addError(Label.InKind_Insufficient_Privilege);
                }
            }
        }
    }
}