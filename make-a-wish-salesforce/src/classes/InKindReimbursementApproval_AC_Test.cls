/**
 * @description Author      : MST Solutions
 * CreatedBy   : Chandrasekar
 * Date        : 4/10/2016
 * Description : This class is used to make sure the unit test and functionality for the InKindDonationReimbursement_AT
 **/
@IsTest
public class InKindReimbursementApproval_AC_Test {

    private static final Id WISH_RECORD_TYPE_ID = Constant_AC.WISH_RT_ID;
    private static final Id IN_KIND_RECORD_TYPE_ID = Constant_AC.IN_KIND_ID;
    private static final Id REIMBURSEMENT_RECORD_TYPE_ID = Constant_AC.REIMBURSEMENT_ID;

    private static final String IN_KIND_DONATION_RT_LABEL = Constant_AC.IN_KIND_DONATION_RT_LABEL;
    private static final String IN_KIND_REIMBURSEMENT_RT_LABEL = Constant_AC.IN_KIND_REIMBURSEMENT_RT_LABEL;

    @TestSetup
    private static void setup() {
        Account parentAccount = TestDataFactory.createChapterAccount(1)[0];
        insert parentAccount;

        Contact wishChild = TestDataFactory.createContact(1)[0];
        wishChild.RecordTypeId = Constant_AC.CONTACT_WISH_CHILD_RT_ID;
        insert wishChild;

        Case wishCase = TestDataFactory.createCase(1)[0];
        wishCase.RecordTypeId = WISH_RECORD_TYPE_ID;
        wishCase.ChapterName__c = parentAccount.Id;
        wishCase.ContactId = wishChild.Id;
        insert wishCase;
    }

    @IsTest
    static void callInkindApprovalMethods() {
        In_Kind_Donation_Reimbursement__c inKind2 = createInKindDonationReimbursement(getTestCase().Id);
        inKind2.Documentation__c = InKindReimbursementApproval_AC.DOCUMENTATION_NOT_AVAILABLE;
        inKind2.RecordTypeId = IN_KIND_RECORD_TYPE_ID;
        insert inKind2;
        System.assertEquals(IN_KIND_RECORD_TYPE_ID, inKind2.RecordTypeId);
        InKindReimbursementApproval_AC.submitApproval(inKind2.Id, IN_KIND_DONATION_RT_LABEL);
        inKind2.Documentation__c = InKindReimbursementApproval_AC.DOCUMENTATION_WILL_ATTACH;
        InKindReimbursementApproval_AC.submitApproval(inKind2.Id, IN_KIND_DONATION_RT_LABEL);
    }

    @IsTest
    static void callReimbursementApprovalMethods() {
        In_Kind_Donation_Reimbursement__c reimbursement = createInKindDonationReimbursement(getTestCase().Id);
        reimbursement.Documentation__c = InKindReimbursementApproval_AC.DOCUMENTATION_NOT_AVAILABLE;
        reimbursement.RecordTypeId = REIMBURSEMENT_RECORD_TYPE_ID;
        insert reimbursement;
        System.assertEquals(REIMBURSEMENT_RECORD_TYPE_ID, reimbursement.RecordTypeId);
        InKindReimbursementApproval_AC.submitApproval(reimbursement.Id, IN_KIND_REIMBURSEMENT_RT_LABEL);
    }

    @IsTest
    static void callReimbursementApprovalWithoutAttachment() {
        In_Kind_Donation_Reimbursement__c reimbursement = createInKindDonationReimbursement(getTestCase().Id);
        reimbursement.RecordTypeId = REIMBURSEMENT_RECORD_TYPE_ID;
        reimbursement.Documentation__c = InKindReimbursementApproval_AC.DOCUMENTATION_WILL_ATTACH;
        insert reimbursement;
        System.assertEquals(REIMBURSEMENT_RECORD_TYPE_ID, reimbursement.RecordTypeId);
        InKindReimbursementApproval_AC.submitApproval(reimbursement.Id, IN_KIND_REIMBURSEMENT_RT_LABEL);
    }

    private static Case getTestCase() {
        return [
                SELECT Id
                FROM Case
                WHERE RecordTypeId = :WISH_RECORD_TYPE_ID
        ];
    }

    private static In_Kind_Donation_Reimbursement__c createInKindDonationReimbursement(Id wishId) {
        In_Kind_Donation_Reimbursement__c inKind2 = TestDataFactory.createInKindDonationReimbursement(1)[0];
        inKind2.Wish__c = wishId;
        return inKind2;
    }
}