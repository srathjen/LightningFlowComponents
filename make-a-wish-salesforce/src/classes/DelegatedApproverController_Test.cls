@isTest
//This class is used to improve the code coverage of delegated approval process.
public class DelegatedApproverController_Test {

    //This method is query the all record in the approval process.
    public testmethod static void queryapprovalRecord() {
        trac_TriggerHandlerBase.blockTrigger = true;
        insert new Bypass_Triggers__c(SetupOwnerId = UserInfo.getUserId());

        Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
        insert chapterAccount;

        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Contact volunteerCon = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.id);
        Contact volunteerConOne = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.id);
        insert new List<Contact>{
                wishChild, volunteerCon, volunteerConOne
        };

        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        insert parentCase;

        Role__c roleName = OrientationandTrainingUtil.createRole();
        Chapter_Role__c chapterRole = OrientationandTrainingUtil.createChapter(chapterAccount.Id, roleName.id);
        List<Volunteer_Opportunity__c> wishVolunteerOpportunityList = OrientationandTrainingUtil.NewWishVolunteerOpportunityList(chapterAccount.id, chapterRole.id, parentCase.id, 2);
        wishVolunteerOpportunityList[0].Volunteer_Name__c = volunteerCon.Id;
        wishVolunteerOpportunityList[1].Volunteer_Name__c = volunteerConOne.Id;
        insert wishVolunteerOpportunityList;

        Chapter_Vs_Role__c alabama = TestDataFactory.createChapterVsRole(1, 'Alabama')[0];
        insert alabama;

        In_Kind_Donation_Reimbursement__c inKindDonationReimbursement = new In_Kind_Donation_Reimbursement__c();
        inKindDonationReimbursement.Wish__c = parentCase.Id;
        insert inKindDonationReimbursement;

        //Creating Queue based on the chapterName.
        Group newGroup = new Group();
        newGroup.Name = 'Make-A-Wish Alabama';
        newGroup.Type = 'Queue';
        insert newGroup;

        //Submitting for Case Approval
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setComments('Submitting request for approval.');
        req.setObjectId(parentCase.id);
        req.setProcessDefinitionNameOrId('Wish_Child_Form_Approval_Process');
        req.setSkipEntryCriteria(true);
        req.setNextApproverIds(new Id[]{
                newGroup.Id
        });

        //Submitting for Contact Approval
        Approval.ProcessSubmitRequest contactRequest = new Approval.ProcessSubmitRequest();
        contactRequest.setComments('Submitting request for approval.');
        contactRequest.setObjectId(wishChild.id);
        contactRequest.setSkipEntryCriteria(true);
        contactRequest.setNextApproverIds(new Id[]{
                newGroup.Id
        });

        //Submitting for Account Approval
        Approval.ProcessSubmitRequest accountRequest = new Approval.ProcessSubmitRequest();
        accountRequest.setComments('Submitting request for approval.');
        accountRequest.setObjectId(chapterAccount.id);
        accountRequest.setSkipEntryCriteria(true);
        accountRequest.setNextApproverIds(new Id[]{
                newGroup.Id
        });

        //Submitting for Vol Opp Approval
        Approval.ProcessSubmitRequest volOppRequest = new Approval.ProcessSubmitRequest();
        volOppRequest.setComments('Submitting request for approval.');
        volOppRequest.setObjectId(wishVolunteerOpportunityList[0].id);
        volOppRequest.setSkipEntryCriteria(true);
        volOppRequest.setNextApproverIds(new Id[]{
                newGroup.Id
        });

        //Submitting for In Kind Approval
        Approval.ProcessSubmitRequest inKindRequest = new Approval.ProcessSubmitRequest();
        inKindRequest.setComments('Submitting request for approval.');
        inKindRequest.setObjectId(inKindDonationReimbursement.id);
        inKindRequest.setSkipEntryCriteria(true);
        inKindRequest.setNextApproverIds(new Id[]{
                newGroup.Id
        });

        Approval.ProcessResult result = Approval.process(req);
        //Approval.ProcessResult result2 = Approval.process(contactRequest);
//		Approval.ProcessResult result3 = Approval.process(accountRequest);
        Approval.ProcessResult result4 = Approval.process(volOppRequest);
        Approval.ProcessResult result5 = Approval.process(inKindRequest);
        DelegatedApproverController_AC.getAppList(String.valueOf(Date.today()), String.valueOf(Date.today()));
    }
}