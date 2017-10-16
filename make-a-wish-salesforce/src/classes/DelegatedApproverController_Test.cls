@isTest
//This class is used to improve the code coverage of delegated approval process.
public class DelegatedApproverController_Test{
    //This method is query the all record in the approval process.
    public  testmethod static void queryapprovalRecord(){
        Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();   
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild(); 
        Contact volunteerCon = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.id);
        Contact volunteerConOne = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.id);
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setComments('Approve.');
        req.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        req.setObjectId(parentCase.Id);
        //Submit the approval request
        Approval.ProcessResult result = Approval.process(req);
        
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Approve.');
        req1.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        req1.setObjectId(volunteerCon.Id);
        //Submit the approval request
        Approval.ProcessResult result1 = Approval.process(req1);
        
        Role__c  roleName = OrientationandTrainingUtil.createRole();
        Chapter_Role__c  chapterRole = OrientationandTrainingUtil.createChapter(chapterAccount.Id,roleName.id);
        List<Volunteer_Opportunity__c> updateWishVolOppList = new List<Volunteer_Opportunity__c>();
        List<Volunteer_Opportunity__c> wishVolunteerOpportunityList =OrientationandTrainingUtil.NewWishVolunteerOpportunityList(chapterAccount.id,chapterRole.id,parentCase.id,2);
        wishVolunteerOpportunityList[0].Volunteer_Name__c = volunteerCon.Id;
        wishVolunteerOpportunityList[1].Volunteer_Name__c = volunteerConOne.Id;
        update wishVolunteerOpportunityList;
        Chapter_Vs_Role__c alabama = OrientationandTrainingUtil.createAlabamaChapter();
        Chapter_Vs_Role__c america = new Chapter_Vs_Role__c();
        america.name = 'Make-A-Wish America';
        america.Chapter_Name__c='Make-A-Wish America';
        Insert america;
        
        
        
        Chapter_Vs_Role__c arizona = OrientationandTrainingUtil.createArizonaChapter();
        DelegatedApproverController_AC newdelegatedApprovalReq = new DelegatedApproverController_AC();
        newdelegatedApprovalReq.viewProcess();
        newdelegatedApprovalReq.selectedprocessName = '';
        newdelegatedApprovalReq.selectedChapter = '';
        newdelegatedApprovalReq.selectedCompltedBy='';
        newdelegatedApprovalReq.selectedApprover ='';
        newdelegatedApprovalReq.selectedStatus='';
        
    }
}