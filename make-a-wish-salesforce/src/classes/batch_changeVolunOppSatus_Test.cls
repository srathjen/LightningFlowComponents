@IsTest
public class batch_changeVolunOppSatus_Test {

	@IsTest
	static void testchangeVolunOppStatusCompleted() {
		String cron = '0 0 1 * * ? *';
		Test.startTest();
		String jobId = System.schedule('batch_changeVolunOppSatus_Test', cron, new batch_changeVolunOppSatusSchedule_AC());
		CronTrigger ct = [
				SELECT Id, CronExpression, TimesTriggered, NextFireTime
				FROM CronTrigger
				WHERE Id = :jobId
		];
		System.assertEquals(cron, ct.CronExpression);
		System.assertEquals(0, ct.TimesTriggered);
		Test.stopTest();
	}
}