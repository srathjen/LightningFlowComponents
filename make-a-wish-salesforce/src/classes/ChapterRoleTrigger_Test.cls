/* ---------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------*/
@isTest
public class ChapterRoleTrigger_Test{
    
    //Used to create a Chapter Role record for National Staff as Owner.
    private testmethod static void  createChapterRole(){
        Chapter_Vs_Role__c arizonaChap = TestDataFactory.createChapterVsRole(1, 'Arizona')[0];
        Chapter_Vs_Role__c alabamaChap = TestDataFactory.createChapterVsRole(1, 'Alabama')[0];
        insert new List<Chapter_Vs_Role__c>{
                arizonaChap, alabamaChap
        };
        
        User currUser = [SELECT id from User where id = :Userinfo.getUserId() limit 1]; 
        User nationalStaff;
        System.RunAs(currUser)
        {     
            nationalStaff = OrientationandTrainingUtil.createUserWithRole([select Id from UserRole where Name='National Staff'].Id);
            insert nationalStaff;
        }
        
        System.runAs(nationalStaff) {
            Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
            insert chapterAccount;

            Chapter_Role__c newChapRole = new Chapter_Role__c();
            newChapRole.Chapter_Name__c = chapterAccount.Id;

            Role__c newRole = new Role__c();
            newRole.Name = 'Wish Granter';
            newRole.isWishRole__c = true;
            insert newRole;

            Role__c newRole1 = new Role__c();
            newRole1.Name = 'Wish Granter1';
            newRole1.isWishRole__c = true;
            insert newRole1;
            
            newChapRole.Role_Name__c = newRole.Id;
            newChapRole.OwnerId= nationalStaff.Id;
            insert newChapRole;

            newChapRole.Role_Name__c = newRole1.Id;
            update newChapRole;

            System.assertEquals('National Staff',[SELECT UserRole.Name FROM User WHERE Id =:nationalStaff.Id].userRole.Name);
            System.assertEquals(nationalStaff.Id,[SELECT OwnerId FROM Chapter_Role__c WHERE Id =:newChapRole.Id].OwnerId);
        }
    }   
}