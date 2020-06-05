/**
 * @description 1.This testClass is used to Relationship_AT for Relationship Contact.
 * 2.Create Record for child wishes.
 * 3.Submits parent wish for approval once the required number of volunteers added to the parent wish team.
 * 4.Add parent wish team members to child wish team.
 * @author Mariyappan Sivathanu, MST Solutions
 * @date 11/14/2016
 **/
@IsTest
public class DocusignRecipientTrigger_AT_Test {

    @TestSetup
    public static void setUp() {
        trac_TriggerHandlerBase.blockTrigger = true;

        Account accountAzChapter = TestDataFactory.createChapterAccount(1)[0];
        accountAzChapter.Name = 'Make-A-Wish Arizona';
        insert accountAzChapter;

        List<Contact> contactList = TestDataFactory.createContact(2);
        Contact volunteerHector = contactList.get(0);
        volunteerHector.RecordTypeId = Constant_AC.VOLUNTEER_RT_ID;
        volunteerHector.AccountId = accountAzChapter.Id;
        volunteerHector.FirstName = 'Hector';
        volunteerHector.LastName = 'Sol';
        volunteerHector.Email = 'h.sol@email.com';
        Contact wishChildAnthony = contactList.get(1);
        wishChildAnthony.FirstName = 'Anthony';
        wishChildAnthony.LastName = 'Edwards';
        wishChildAnthony.Parent_Guardian_Name__c = 'Jonathan Edwards';
        wishChildAnthony.RecordTypeId = Constant_AC.CONTACT_WISH_CHILD_RT_ID;
        wishChildAnthony.Birthdate = Date.today().addDays(+21);
        wishChildAnthony.Birthdate = wishChildAnthony.Birthdate.addYears(-5);
        wishChildAnthony.MailingPostalCode = '94105-5188';
        wishChildAnthony.MailingStreet = '7540 E Gold Dust Ave';
        wishChildAnthony.MailingCountry = 'United States';
        wishChildAnthony.MailingState = 'Arizona';
        wishChildAnthony.MailingCity = 'Scottsdale';
        wishChildAnthony.MailingLatitude = -24.355798;
        wishChildAnthony.MailingLongitude = 69.830469;
        insert contactList;

        Case wishChildCase = TestDataFactory.createCase(1)[0];
        wishChildCase.RecordTypeId = Constant_AC.WISH_RT_ID;
        wishChildCase.ChapterName__c = accountAzChapter.Id;
        wishChildCase.Subject = 'Parent Wish';
        wishChildCase.Interview_date__c = System.today();
        wishChildCase.Wish_Type__c = 'Disney World';
        wishChildCase.Start_Date__c = System.today();
        wishChildCase.End_Date__c = System.today();
        wishChildCase.ContactId = wishChildAnthony.Id;
        wishChildCase.Status = 'New';
        wishChildCase.Start_Date__c = System.today();
        wishChildCase.LiabilitySignerMapKeyPair__c = 'Anthony Edwards';
        wishChildCase.Budget_Submitted_Date__c = System.today();
        wishChildCase.Budget_Approved_Date__c = System.today();
        insert wishChildCase;

        dsfs__DocuSign_Status__c dsfsCase = TestDataFactory.createDocusignStatuswithCase(wishChildCase.Id);
        dsfsCase.Recipient_names__c = 'Anthony Edwards';
        insert dsfsCase;

        dsfs__DocuSign_Status__c dsfsCaseDupe = TestDataFactory.createDocusignStatuswithCase(wishChildCase.Id);
        dsfsCaseDupe.Recipient_names__c = 'Candace Edwards';
        insert dsfsCaseDupe;

        dsfs__DocuSign_Recipient_Status__c recipientStatusCompleted = TestDataFactory.createDocusignRecipientStatus(dsfsCaseDupe.Id);
        recipientStatusCompleted.Name = 'Delivered to Candace Edwards';
        recipientStatusCompleted.dsfs__Recipient_Status__c = 'Delivered';
        insert recipientStatusCompleted;

        Attachment attachment = TestDataFactory.createAttachments(1, dsfsCaseDupe.Id)[0];
        insert attachment;

        trac_TriggerHandlerBase.blockTrigger = false;
    }

    @IsTest
    public static void insertCompletedStatus() {
        Test.startTest();
        dsfs__DocuSign_Status__c docusignStatus = [
                SELECT Id, Recipient_names__c
                FROM dsfs__DocuSign_Status__c
                WHERE Recipient_names__c = 'Anthony Edwards'
        ];
        dsfs__DocuSign_Recipient_Status__c recipientStatusCompleted = TestDataFactory.createDocusignRecipientStatus(docusignStatus.Id);
        recipientStatusCompleted.Name = 'Test Insert';
        recipientStatusCompleted.dsfs__Recipient_Status__c = Constant_AC.DOCUSIGN_RECIPIENT_STATUS_COMPLETED;
        insert recipientStatusCompleted;
        Test.stopTest();
    }

    @IsTest
    public static void insertDeliveredStatus() {
        Test.startTest();
        dsfs__DocuSign_Status__c docusignStatus = [
                SELECT Id, Recipient_names__c
                FROM dsfs__DocuSign_Status__c
                WHERE Recipient_names__c = 'Anthony Edwards'
        ];
        dsfs__DocuSign_Recipient_Status__c recipientStatusCompleted = TestDataFactory.createDocusignRecipientStatus(docusignStatus.Id);
        recipientStatusCompleted.Name = 'Test Insert';
        recipientStatusCompleted.dsfs__Recipient_Status__c = Constant_AC.DOCUSIGN_RECIPIENT_STATUS_DELIVERED;
        insert recipientStatusCompleted;
        Test.stopTest();
    }

    @IsTest
    public static void updateStatusCompleted() {
        Test.startTest();
        dsfs__DocuSign_Recipient_Status__c recStatus = [
                SELECT Id, dsfs__Parent_Status_Record__c
                FROM dsfs__DocuSign_Recipient_Status__c
                WHERE Name = 'Delivered to Candace Edwards'
        ];
        recStatus.dsfs__Recipient_Status__c = 'Completed';
        update recStatus;
        Test.stopTest();
        dsfs__DocuSign_Recipient_Status__c parentRecordUpdate = [
                SELECT Id, dsfs__Parent_Status_Record__r.AttachmentId__c
                FROM dsfs__DocuSign_Recipient_Status__c
                WHERE Id = :recStatus.Id
        ];
        Attachment attach = [
                SELECT Id
                FROM Attachment
                WHERE ParentId = :recStatus.dsfs__Parent_Status_Record__c
        ];
        System.assert(parentRecordUpdate.dsfs__Parent_Status_Record__r.AttachmentId__c == attach.Id);
    }
}