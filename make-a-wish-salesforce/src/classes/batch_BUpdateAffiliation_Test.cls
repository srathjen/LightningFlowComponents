/*************************************************************************************************************************************************
Created by: Pavithra
Author : MST Solutions
CreateDate : 10/05/2016
Description :batch_BUpdateAffiliation_Test is used to increase the code coverage for Batch_UpdateVolunteerStatus_AC class.
*************************************************************************************************************************************************/

@IsTest
public class batch_BUpdateAffiliation_Test {
    @IsTest
    static void updateVolunteerAffStatus() {
        Account chapterAc = OrientationandTrainingUtil.createchapterAccount();
        insert chapterAc;

        Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAc.Id);
        insert volunteerContact;

        npe5__Affiliation__c affiliation = OrientationandTrainingUtil.CreateAffiliation(volunteerContact.Id);
        insert affiliation;

        affiliation.npe5__Status__c = 'Out of Compliance';
        update affiliation;

        Role__c wishGranterRole = OrientationandTrainingUtil.createRole();
        insert wishGranterRole;

        Chapter_Role__c wishGranterChapterRole = OrientationandTrainingUtil.createChapter(chapterAc.Id, wishGranterRole.Id);
        insert wishGranterChapterRole;

        Volunteer_Roles__c wishGranterVolRole = OrientationandTrainingUtil.createVolRole(volunteerContact.Id, wishGranterChapterRole.Id);
        insert wishGranterVolRole;

        Database.executeBatch(new batch_BUpdateAffiliation_AC());
    }
}