@isTest
//This class is used to improve the code coverage of delegated approval process.
public class DelegatedApproverController_Test {
    
    @TestSetup
    public static void setup() {
        trac_TriggerHandlerBase.blockTrigger = true;
        
        Account accountAzChapter = TestDataFactory.createAccount(1)[0];
        accountAzChapter.Name = 'Make-A-Wish Arizona';
        accountAzChapter.RecordTypeId = Constant_AC.CHAPTER_RT_ID;
        insert accountAzChapter;
        
        List<Contact> contactList = TestDataFactory.createContact(2);
        Contact volunteerJessica = contactList.get(0);
        volunteerJessica.FirstName = 'Jessica';
        volunteerJessica.LastName = 'Sailor';
        volunteerJessica.Email = 'Test.Mawa@gmail.com';
        volunteerJessica.RecordTypeId = Constant_AC.VOLUNTEER_RT_ID;
        volunteerJessica.AccountId = accountAzChapter.Id;
        volunteerJessica.Region_Chapter__c = accountAzChapter.Id;
        Contact wishChildVictoria = contactList.get(1);
        wishChildVictoria.FirstName = 'Victoria';
        wishChildVictoria.LastName = 'McQueen';
        wishChildVictoria.RecordTypeId = Constant_AC.CONTACT_WISH_CHILD_RT_ID;
        wishChildVictoria.AccountId = accountAzChapter.Id;
        wishChildVictoria.Region_Chapter__c = accountAzChapter.Id;
        wishChildVictoria.Birthdate = Date.today().addYears(-13);        
        insert contactList;
        
        List<Case> caseList = TestDataFactory.createCase(1);
        Case wishCaseMcQueen = caseList.get(0);
        wishCaseMcQueen.RecordTypeId = Constant_AC.WISH_RT_ID;
        wishCaseMcQueen.ChapterName__c = accountAzChapter.Id;
        wishCaseMcQueen.Subject = 'Victori McQueen Wish';
        wishCaseMcQueen.Interview_date__c = System.today();
        wishCaseMcQueen.Wish_Type__c = 'Disney World';
        wishCaseMcQueen.Start_Date__c = System.today();
        wishCaseMcQueen.ContactId = wishChildVictoria.Id;
        wishCaseMcQueen.Status = 'New';
        insert caseList;
        
        List<Role__c> roleList = TestDataFactory.createRole(1, true);
        Role__c wishRole = roleList.get(0);
        wishRole.Name = 'Wish Granter';
        insert roleList;
        
        List<Chapter_Role__c> chapterRoleList = TestDataFactory.createChapterRole(1);
        Chapter_Role__c wishGranterChapterRole = chapterRoleList.get(0);
        wishGranterChapterRole.Chapter_Name__c = accountAzChapter.Id;
        wishGranterChapterRole.Role_Name__c = wishRole.Id;
        wishGranterChapterRole.Background_Check_Required__c = true;
        insert chapterRoleList;
        
        List<Volunteer_Opportunity__c> volOppsList = TestDataFactory.createVolunteerOpportunity(1);
        Volunteer_Opportunity__c volOppWishJessica = volOppsList.get(0);
        volOppWishJessica.RecordTypeId =  Constant_AC.WISH_VOLUNTEER_OPPORTUNITY_ID;
        volOppWishJessica.Volunteer_Name__c = volunteerJessica.Id;
        volOppWishJessica.Chapter_Role_Opportunity__c = wishGranterChapterRole.Id;
        volOppWishJessica.Wish__c = wishCaseMcQueen.Id;
        volOppWishJessica.Chapter_Name__c = accountAzChapter.Id;
        insert volOppsList;
        
        List<In_Kind_Donation_Reimbursement__c> inKindDonationList = TestDataFactory.createInKindDonationReimbursement(1);
        In_Kind_Donation_Reimbursement__c reimbursement = inKindDonationList.get(0);
        reimbursement.Wish__c = wishCaseMcQueen.Id;
        insert inKindDonationList;
        
        List<Group> groupList = TestDataFactory.createGroup(1);
        Group azGroup = groupList.get(0);
        azGroup.Name = 'Make-A-Wish Arizona';
        azGroup.Type = 'Queue';
        insert groupList;
        
        List<Id> approverIdList = new List<Id>{azGroup.Id};
            
        List<Approval.ProcessSubmitRequest> requestList = TestDataFactory.createApporvalProcessRequest(3);
        Approval.ProcessSubmitRequest caseRequest = requestList.get(0);
        caseRequest.setComments('Submitting request for approval.');
        caseRequest.setObjectId(wishCaseMcQueen.id);
        caseRequest.setProcessDefinitionNameOrId('Wish_Child_Form_Approval_Process');
        caseRequest.setSkipEntryCriteria(true);
        caseRequest.setNextApproverIds(approverIdList);
        Approval.ProcessSubmitRequest volOppRequest = requestList.get(1);
        volOppRequest.setComments('Submitting request for approval.');
        volOppRequest.setObjectId(volOppWishJessica.Id);
        volOppRequest.setSkipEntryCriteria(true);
        volOppRequest.setNextApproverIds(approverIdList);
        Approval.ProcessSubmitRequest inKindRequest = requestList.get(2);
        inKindRequest.setComments('Submitting request for approval.');
        inKindRequest.setObjectId(reimbursement.Id);
        inKindRequest.setSkipEntryCriteria(true);
        inKindRequest.setNextApproverIds(approverIdList);
        Approval.process(requestList);
        
        trac_TriggerHandlerBase.blockTrigger = false;
    }
    
    @isTest
    public static void queryapprovalRecord() {
        String approvalProcessSerialized = '';
        Test.startTest();
        approvalProcessSerialized = DelegatedApproverController_AC.getAppList(String.valueOf(Date.today()), String.valueOf(Date.today()));
        Test.stopTest();
        System.assert(approvalProcessSerialized.contains('"wishChild":"Victoria McQueen"'));
    }
}