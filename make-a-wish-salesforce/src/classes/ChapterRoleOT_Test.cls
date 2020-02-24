@isTest
Public class ChapterRoleOT_Test{
    //Create a chapterroleO&T record owner as National staff
    private static testmethod void createChapterRoleOT(){
        Chapter_Vs_Role__c arizonaChap = OrientationandTrainingUtil.createArizonaChapter();
        Chapter_Vs_Role__c alabamaChap = OrientationandTrainingUtil.createAlabamaChapter();
        insert alabamaChap;
        insert arizonaChap;
        User currUser = [SELECT id from User where id = :Userinfo.getUserId() limit 1];
        User nationalStaff;
        System.RunAs(currUser)
        {   
            nationalStaff = OrientationandTrainingUtil.createUserWithRole([select Id from UserRole where Name='National Staff'].Id);
            insert nationalStaff;
        }
        
        System.runAs(nationalStaff) {
            Chapter_Role__c newChapterRole =OrientationandTrainingUtil.createChapter(OrientationandTrainingUtil.createchapterAccount().Id,OrientationandTrainingUtil.createRole().Id);
            insert newChapterRole;

            OrientationandTrainingUtil.createChapterOandT(newChapterRole.Id,OrientationandTrainingUtil.CreateVolunteerOrientationRecord().Id);
        }
    }
    
    //Update Owner
    private static testmethod void ownerUpdate(){
        Chapter_Vs_Role__c arizonaChap = OrientationandTrainingUtil.createArizonaChapter();
        Chapter_Vs_Role__c alabamaChap = OrientationandTrainingUtil.createAlabamaChapter();
        Insert alabamaChap;
        Insert arizonaChap;
        User currUser = [SELECT id from User where id = :Userinfo.getUserId() limit 1];
        User nationalStaff;
        System.RunAs(currUser)
        {   
            nationalStaff = OrientationandTrainingUtil.createUserWithRole([select Id from UserRole where Name='National Staff'].Id);
            insert nationalStaff;
        }
        
        System.runAs(nationalStaff) {
            Chapter_Role__c newChapterRole =OrientationandTrainingUtil.createChapter(OrientationandTrainingUtil.createchapterAccount().Id,OrientationandTrainingUtil.createRole().Id);
            insert newChapterRole;

            OrientationandTrainingUtil.createChapterOandT(newChapterRole.Id,OrientationandTrainingUtil.CreateVolunteerOrientationRecord().Id);
            List<Chapter_Role_O_T__c> chapterRoleOt = [SELECT Id, OwnerId FROM Chapter_Role_O_T__c LIMIT 1];
            if(chapterRoleOt.Size() > 0) {
                Chapter_Role_O_T__c cOT = new Chapter_Role_O_T__c();
                cOT.Id = chapterRoleOt[0].Id;
                cOT.OwnerId = currUser.Id;
                update cOT;
            }
        }
    }
}