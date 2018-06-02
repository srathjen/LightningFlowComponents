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
        
        Role__c  roleName = OrientationandTrainingUtil.createRole();
        Chapter_Role__c  chapterRole = OrientationandTrainingUtil.createChapter(chapterAccount.Id,roleName.id);
        List<Volunteer_Opportunity__c> updateWishVolOppList = new List<Volunteer_Opportunity__c>();
        List<Volunteer_Opportunity__c> wishVolunteerOpportunityList =OrientationandTrainingUtil.NewWishVolunteerOpportunityList(chapterAccount.id,chapterRole.id,parentCase.id,2);
        wishVolunteerOpportunityList[0].Volunteer_Name__c = volunteerCon.Id;
        wishVolunteerOpportunityList[1].Volunteer_Name__c = volunteerConOne.Id;
        update wishVolunteerOpportunityList;
        Chapter_Vs_Role__c alabama = OrientationandTrainingUtil.createAlabamaChapter();
        Chapter_Vs_Role__c america = new Chapter_Vs_Role__c();
        america.name = 'Make-A-Wish Alabama';
        america.Chapter_Name__c='Make-A-Wish Alabama';
        Insert america;
         
         //Creating Queue based on the chapterName.
         Group newGroup = new Group();
         newGroup.Name = 'Make-A-Wish Alabama';
         newGroup.Type =  'Queue';
         insert newGroup; 
        //Submitting for Case Approval
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setComments('Submitting request for approval.');
        req.setObjectId(parentCase.id);
        req.setProcessDefinitionNameOrId('Wish_Child_Form_Approval_Process');
        req.setSkipEntryCriteria(true);
         req.setNextApproverIds(new Id[]{newGroup.Id});
        Approval.ProcessResult result = Approval.process(req);
        
        DelegatedApproverController_AC.getAppList();
        
        
    }
}