@isTest
public class WishJourneyController_Test {
    public static testMethod void caseCreation() {
        PageReference pageRef = Page.WishJourney;
        Test.setCurrentPage(pageRef);
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Case parentCase = OrientationandTrainingUtil.CreateParentCaseWithoutInterviewDate(wishChild.id);
        WishJourneyController obj = new WishJourneyController(new ApexPages.StandardController(parentCase));
        obj.wishId = 'CaseId';
        obj.anticipationId = 'AnticipationId';
        obj.assitId = 'AssitId';
        obj.effectId = 'EffectId';
        obj.grantId = 'garntId';
        obj.determinationId = 'determinationId';
        obj.inActive = true;
        obj.escalated = false;
        obj.onHold = true;
        obj.granted = true;
        obj.newStatus = true;
        obj.completed = true;
        obj.closed = true;
        obj.readytoAssign = true;
        obj.wishDetermined = true;
        obj.getCases();
    }
    
    public static testMethod void caseWithInactive() {
        String wishRecTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Wish Assist').getRecordTypeId();
        Case currentCase = OrientationandTrainingUtil.createParentCase();
        currentCase.Status = 'Inactive';
        currentCase.Origin = 'Email';
        currentCase.RecordTypeId = wishRecTypeId;
        insert currentCase;
        WishJourneyController obj = new WishJourneyController(new ApexPages.StandardController(currentCase));
        
    }
    
    public static testMethod void caseWithOnhold() {
        String wishRecTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Wish Determination').getRecordTypeId();
        Case currentCase = OrientationandTrainingUtil.createParentCase();
        currentCase.Status = 'On Hold';
        currentCase.Origin = 'Email';
        currentCase.RecordTypeId = wishRecTypeId;
        insert currentCase;
        WishJourneyController obj = new WishJourneyController(new ApexPages.StandardController(currentCase));
        
    }
    
    public static testMethod void caseWitEscalated() {
        Constant_AC newConstant = new Constant_AC();
        String wishRecTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(newConstant.wishEffectRT).getRecordTypeId();
        Case currentCase = OrientationandTrainingUtil.createParentCase();
        currentCase.Status = 'Escalated';
        currentCase.Origin = 'Email';
        insert currentCase;
        WishJourneyController obj = new WishJourneyController(new ApexPages.StandardController(currentCase));
        
    }
    
    public static testMethod void caseWitGranted() {
        Case currentCase = OrientationandTrainingUtil.createParentCase();
        currentCase.Status = 'Granted';
        currentCase.Origin = 'Email';
        insert currentCase;
        WishJourneyController obj = new WishJourneyController(new ApexPages.StandardController(currentCase));
    }
    public static testMethod void caseWitQualified() {
        Case currentCase = OrientationandTrainingUtil.createParentCase();
        currentCase.Status = 'Qualified';
        currentCase.Origin = 'Email';
        insert currentCase;
        WishJourneyController obj = new WishJourneyController(new ApexPages.StandardController(currentCase));
    }
    
    public static testMethod void caseWitReadytoAssign() {
        Case currentCase = OrientationandTrainingUtil.createParentCase();
        currentCase.Status = 'Ready to Assign';
        currentCase.Sub_Status__c = 'Test';
        currentCase.Origin = 'Email';
        insert currentCase;
        WishJourneyController obj = new WishJourneyController(new ApexPages.StandardController(currentCase));
    }
    
    public static testMethod void caseWitWishDetermined() {
        Case currentCase = OrientationandTrainingUtil.createParentCase();
        currentCase.Status = 'Wish Determined';
        currentCase.Origin = 'Email';
        currentCase.Meet_PWL_Criteria__c = 'Test';
        insert currentCase;
        WishJourneyController obj = new WishJourneyController(new ApexPages.StandardController(currentCase));
    }
    
    public static testMethod void caseWitWishNew() {
        Case currentCase = OrientationandTrainingUtil.createParentCase();
        currentCase.Status = 'New';
        currentCase.Origin = 'Email';
        insert currentCase;
        WishJourneyController obj = new WishJourneyController(new ApexPages.StandardController(currentCase));
    }
    
    public static testMethod void caseWitWishCompleted() {
        Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
        Lead currLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id);
        currLead.Part_A_Received__c = Date.today();
        currLead.Referred_Date__c = Date.today();
        insert currLead;
        Case currentCase = OrientationandTrainingUtil.createParentCase();
        currentCase.Status = 'Completed';
        currentCase.Origin = 'Email';
        currentCase.Lead__c = currLead.Id;
        insert currentCase;
        WishJourneyController obj = new WishJourneyController(new ApexPages.StandardController(currentCase));
    }

    
    public static testMethod void caseWitWishClosed() {
        Case currentCase = OrientationandTrainingUtil.createParentCase();
        currentCase.Status = 'Closed';
        currentCase.Origin = 'Email';
        insert currentCase;
        WishJourneyController obj = new WishJourneyController(new ApexPages.StandardController(currentCase));
    }
    
    public static testMethod void caseWitWishChild() {
        Case currentCase = OrientationandTrainingUtil.createParentCase();
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Case parentCase = OrientationandTrainingUtil.CreateParentCaseWithoutInterviewDate(wishChild.id);
        currentCase.Status = 'Closed';
        currentCase.Origin = 'Email';
        currentCase.ParentId = parentCase.Id;
        insert currentCase;
        WishJourneyController obj = new WishJourneyController(new ApexPages.StandardController(currentCase));
    }
    
}