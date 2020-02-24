@isTest
Public class batch_UpdateVolunteerLastEngageTest
{

    static testmethod void CreateVolunteerOpportunity()
    {
        String CRON_EXP = '0 0 1 * * ? *';
        Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
        insert chapterAccount;
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        insert wishChild;
        Contact VolunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.id);
        insert VolunteerContact;
        Case parentCase = OrientationandTrainingUtil.ParentCasetoAddCaseMember(wishChild.Id);
        insert parentCase;
        Role__c  roleName = OrientationandTrainingUtil.createRole();
        insert roleName;
        Chapter_Role__c  chapterRole = OrientationandTrainingUtil.createChapter(chapterAccount.Id,roleName.id);
        insert chapterRole;
        Non_Wish_Events__c nonWishEvent = OrientationandTrainingUtil.CreateEventRec(chapterRole.Id,chapterAccount.Id);
        insert nonWishEvent;
        nonWishEvent.Event_Date__c = Date.Today().addDays(-5);
        update nonWishEvent;
        
        Volunteer_Opportunity__c newOpp = new Volunteer_Opportunity__c();
        newOpp.Volunteer_Name__c = volunteerContact.id;
        newOpp.Non_Wish_Event__c = nonWishEvent.id;
        newOpp.wish__c = parentCase.id;
        insert newOpp;
        
         Test.startTest();
          
            String jobId = System.schedule('lastEngagementBatch',CRON_EXP, new batch_UpdateLastEngageSchedule_AC());
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            System.assertEquals(CRON_EXP, ct.CronExpression);
            System.assertEquals(0, ct.TimesTriggered);
        Test.stopTest();
        
        
    
    
    }


}