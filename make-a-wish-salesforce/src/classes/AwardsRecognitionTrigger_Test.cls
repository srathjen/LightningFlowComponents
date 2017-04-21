@isTest
public class AwardsRecognitionTrigger_Test{
    @testSetup
    private static void createUser(){
        User arizonaUser = OrientationandTrainingUtil.createUserWithRole([select Id from UserRole where Name='Arizona - Chapter'].Id);
    }
    private static testmethod void createAwardsRecOtherChapter(){
         
        Chapter_Vs_Role__c arizonaChap = OrientationandTrainingUtil.createArizonaChapter();
        Chapter_Vs_Role__c alabamaChap = OrientationandTrainingUtil.createAlabamaChapter();
        Insert alabamaChap;
        Insert arizonaChap;
         User currUser = [SELECT id from User where id = :Userinfo.getUserId() limit 1]; 
         User nationalStaff;
         System.RunAs(currUser)
         {     
             nationalStaff = [SELECT Id,UserRole.Name FROM USER WHERE UserRole.Name='Arizona - Chapter' AND isActive = true LIMIT 1];        
             nationalStaff.UserRoleId=[select Id from UserRole where Name='National Staff'].Id;
             Update nationalStaff;
         }
         System.runAs(nationalStaff) {
            Awards_Recognition__c newAwards = new Awards_Recognition__c();
            newAwards.Chapter_Name__c = OrientationandTrainingUtil.createchapterAccount().Id;
            Insert  newAwards;
        }
    }
}