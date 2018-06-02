/*********************************************************
Test class for batch_CaseTeamMemberUpdate
********************************************************/

@isTest
Public class batch_CaseTeamMemberUpdateTest
{
    @testSetup static void methodName() {
        User sysAdminUser = OrientationandTrainingUtil.createrSystemAdminUserwithMgr();
        PermissionSet permissionSetUser = [SELECT id, Name FROM PermissionSet where Name = 'Program_Supervisor'];
        PermissionSetAssignment psa = new PermissionSetAssignment (AssigneeId = sysAdminUser.Id,PermissionSetId = permissionSetUser.Id);
        insert psa;
        
    }
    
    static testmethod void CreateRecords()
    {
        
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        
        Case parentCase = OrientationandTrainingUtil.CreateParentCaseWithStatus();
        parentCase.ContactId = wishChild.Id;
        parentCase.AccountId = chapterAccount.Id;
        parentCase.Start_Date__c = System.today();
        parentCase.Status = 'Qualified';
        parentCase.Migrated_Record__c = True;
        insert parentCase;
         
        CaseTeamRole wishGranter= [SELECT Id FROM CaseTeamRole WHERE Name = 'Wish Granter' limit 1];  
        User currUser = [Select id from User WHERE isActive=True AND email = 'testmawa@gmail.com' limit 1]; 
        
        CaseTeamMember caseTeamMeber = OrientationandTrainingUtil.createCaseTeamMember(parentCase.id,currUser.id,wishGranter.id);
        System.RunAs(currUser)
        {
            Case updateParentCase = new Case();
            updateParentCase.Id = parentCase.Id;
            updateParentCase.Sub_Status__c = 'Abandoned';
            updateParentCase.Completed_Date__c = System.today()+5;
            updateParentCase.Closed_Date__c = System.today()+5;
            updateParentCase.Status = 'Closed';
            update updateParentCase;
        }
        Test.startTest();
        DataBase.executeBatch(new batch_CaseTeamMemberUpdate() );
        Test.stopTest();
        
    }
    
    
}