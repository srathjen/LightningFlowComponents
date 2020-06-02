@IsTest
public class batch_changeVolunOppSatus_Test {
    
    @TestSetup
    static void setUp() {
        trac_TriggerHandlerBase.blockTrigger = true;
        
        Non_Wish_Events__c event = TestDataFactory.createNonwishEvent(1)[0];
        event.Event_Name__c = 'Monthly Team Meeting';
        event.Event_Text__c = 'Monthly touchpoint for the Arizona volunteer team.';
        event.Event_Date__c = Date.today().addDays(-1);
        insert event;
        
        List<Volunteer_Opportunity__c> volOppList = TestDataFactory.createVolunteerOpportunity(25);
        for(integer i = 0; i < volOppList.size(); i++) {
            volOppList[i].Non_Wish_Event__c = event.Id;
            volOppList[i].Status__c = Constant_AC.VOLUNTEER_OPPORTUNITY_STATUS_PENDING;
            volOppList[i].RecordTypeId = Constant_AC.NON_WISH_EVENT_RT_ID;
        }
        insert volOppList;
        
        trac_TriggerHandlerBase.blockTrigger = false;
    }
    
    @IsTest
    static void testchangeVolunOppStatusCompleted() {
        String cron = '0 0 1 * * ? *';
        Test.startTest();
        String jobId = System.schedule('batch_changeVolunOppSatus_Test', cron, new batch_changeVolunOppSatus());
        Test.stopTest();
        CronTrigger ct = [
            SELECT Id, CronExpression, TimesTriggered, NextFireTime
            FROM CronTrigger
            WHERE Id = :jobId
        ];
        System.assertEquals(cron, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
    }
}