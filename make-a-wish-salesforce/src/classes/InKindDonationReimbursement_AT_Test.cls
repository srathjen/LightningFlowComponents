@isTest
public class InKindDonationReimbursement_AT_Test {
    @testSetup static void methodName() {
        Account voluntterAccount = OrientationandTrainingUtil.createVolunteerAccount();
        Contact volunterrContct = OrientationandTrainingUtil.createVolunteerContact(voluntterAccount.id);
        OrientationandTrainingUtil.CreateActiveVolunteerUser(volunterrContct.id);
        
    }
    static testMethod void createInkindRecord(){
        User dbUser = [SELECT Id,UserRoleId,UserName,ProfileId,Email,FirstName,LastName,isActive From User WHERE FirstName =: 'Jonathan' Limit 1];
        system.RunAs(dbUser){
            Test.StartTest();
            OrientationandTrainingUtil.CreateInkindRecord();
            
            Test.StopTest();
        }
    }
        
        static testMethod void createReimbursementRecord(){
            User dbUser = [SELECT Id,UserRoleId,UserName,ProfileId,Email,FirstName,LastName,isActive From User WHERE FirstName =: 'Jonathan' Limit 1];
            system.RunAs(dbUser){
                Test.StartTest();
                OrientationandTrainingUtil.createReImbursementRecord();
                Test.StopTest();
            }
            
        }
        
    }