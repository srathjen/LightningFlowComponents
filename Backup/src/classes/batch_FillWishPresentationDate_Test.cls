/***************************************************************************************************
Author      : MST Solutions
Description : batch_FillWishPresentationDate_Test class used make sure the unit test of the batch_FillWishPresentationDate class.
*****************************************************************************************************/
@isTest
public class batch_FillWishPresentationDate_Test {
    
    static testmethod void testPresentationDateScheduleClassSendEmail() {
         String CRON_EXP = '0 0 1 * * ? *';
         Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
         Constant_AC  constant = new Constant_Ac();    
       // Constant_AC  constant = new Constant_Ac();    
        Id parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
        Case newParentWish = new Case();
        newParentWish.RecordTypeId = parentWishRecordTypeId;
        newParentWish.ChapterName__c = OrientationandTrainingUtil.CreateAlabamaAccount();
        newParentWish.Subject = 'Parent Wish';
        newParentWish.Interview_date__c = System.today();
        newParentWish.Anticipated_Start_Date__c = System.today()-15;
        newParentWish.Wish_Type__c = 'Disney World';
        newParentWish.ContactId = wishChild.Id;
        insert newParentWish;
        
         Id grantWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishGrantRT).getRecordTypeId();
        
        Case newGrantWish = new Case();
        newGrantWish.RecordTypeId = grantWishRecordTypeId;
        newGrantWish.ChapterName__c = OrientationandTrainingUtil.CreateAlabamaAccount();
        newGrantWish.Subject = 'Wish Grant';
        newGrantWish.ContactId = wishChild.Id;
        newGrantWish.Parentid = newParentWish.id;
        insert newGrantWish;
        
//        Case parentCase = OrientationandTrainingUtil.CreateParentCaseWithAnticipatedStartDate(wishChild.id);
        list<Case> wishGranting = new list<Case>();
      //  wishGranting.add( OrientationandTrainingUtil.createWishGrantCase(wishChild.id,parentCase.Id));
        Test.startTest();
        // Schedule the test job        
        String jobId = System.schedule('batch_FillWishPresentationDate_Test',CRON_EXP, new batch_FillPresentationDateSchedule_AC());
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        // Verify the expressions are the same
        System.assertEquals(CRON_EXP, ct.CronExpression);
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        Test.stopTest();
    }
     static testmethod void testPresentationDateScheduleClassCreateTask() {
         String CRON_EXP = '0 0 1 * * ? *';
         Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
         Constant_AC  constant = new Constant_Ac();    
       // Constant_AC  constant = new Constant_Ac();    
        Id parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
        Case newParentWish = new Case();
        newParentWish.RecordTypeId = parentWishRecordTypeId;
        newParentWish.ChapterName__c = OrientationandTrainingUtil.CreateAlabamaAccount();
        newParentWish.Subject = 'Parent Wish';
        newParentWish.Interview_date__c = System.today();
        newParentWish.Anticipated_Start_Date__c = System.today()+23;
        newParentWish.Wish_Type__c = 'Disney World';
        newParentWish.ContactId = wishChild.Id;
        insert newParentWish;
        
         Id grantWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishGrantRT).getRecordTypeId();
        
        Case newGrantWish = new Case();
        newGrantWish.RecordTypeId = grantWishRecordTypeId;
        newGrantWish.ChapterName__c = OrientationandTrainingUtil.CreateAlabamaAccount();
        newGrantWish.Subject = 'Wish Grant';
        newGrantWish.ContactId = wishChild.Id;
        newGrantWish.Parentid = newParentWish.id;
        insert newGrantWish;
        
//        Case parentCase = OrientationandTrainingUtil.CreateParentCaseWithAnticipatedStartDate(wishChild.id);
        list<Case> wishGranting = new list<Case>();
      //  wishGranting.add( OrientationandTrainingUtil.createWishGrantCase(wishChild.id,parentCase.Id));
        Test.startTest();
        // Schedule the test job        
        String jobId = System.schedule('batch_FillWishPresentationDate_Test',CRON_EXP, new batch_FillPresentationDateSchedule_AC());
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        // Verify the expressions are the same
        System.assertEquals(CRON_EXP, ct.CronExpression);
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        Test.stopTest();
    }
         
}