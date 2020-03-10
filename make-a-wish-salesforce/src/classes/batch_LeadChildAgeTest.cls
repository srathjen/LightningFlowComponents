/******************************************************************************************
Author : MAWA
Created Date: 4/25/2019
Modification: 07/09/2019 - Samer - SIW-246
              Modified code for childDOB and childDOB2 to fix date calculation error.
*******************************************************************************************/
@IsTest
public class batch_LeadChildAgeTest {

	@TestSetup
	static void setup() {
		trac_TriggerHandlerBase.blockTrigger = true;
		Account chapterAccount = OrientationandTrainingUtil.CreateAmericaAccount();
		insert chapterAccount;

		Condition_Description__c descrip = OrientationandTrainingUtil.createConditionDesCription();
		insert descrip;

		ICD_Codes__c icdCode = OrientationandTrainingUtil.createICDCode(descrip.Id);
		insert icdCode;

		Date runDate = Date.today();
		Date childDOB = runDate.addYears(-1).addMonths(-6);      // age 1.5
		Date childDOB2 = runDate.addYears(-2).addMonths(-6);     // age 2.5
		List<Lead> leadList = new List<Lead>();
		List<Lead> leadListNeg = new List<Lead>();

		//insert wish child leads where child age is 2.5 years old today and the field for Age Requirement should update
		for (Integer i = 0; i < 10; i++) {
			leadList.add(new Lead(FirstName = 'Walter' + i, LastName = 'LastName' + i, Child_Age__c = 'Under 2.5',
					DOB__c = childDOB2, Gender__c = 'Male', Company = 'MAWA', is_Family_Aware_of_Referral__c = 'Yes',
					Phone = '9600467559', Email = 'testmawa' + i + '@gmail.com', State = 'Arizona',
					Treating_Medical_Professional_First_Name__c = 'Steve' + i,
					Treating_Medical_Professional_Last_Name__c = 'Waugh',
					Treating_Medical_Professional_Email__c = 'testmawa2' + i + '@gmail.com',
					Hospital_Treatment_Facility_Treating__c = 'Steve Smith AC',
					Treating_Medical_Professional_Phone__c = '9990467555', Parent_First_Name__c = 'Parent' + i,
					Parent_Last_Name__c = 'LastName' + i, Referrer_FirstName__c = 'Referrer' + i,
					Referrer_Last_Name__c = 'TestRef' + i, Referrer_Phone__c = '8880467556',
					Referrer_Email__c = 'referrer' + i + '@gmail.com', Referrer_City__c = 'Phoenix',
					Referrer_Zip__c = '85016', Status = 'Inquiry', PD_ICD_Code__c = icdCode.Id,
					ICD_Given_By_Referrer__c = icdCode.Id, Diagnosis_Given_By_Referrer__c = 'Test',
					ChapterName__c = chapterAccount.Id, Street = '12' + i + 'Market St', PostalCode = '85016',
					City = 'Phoenix', Age_Requirement_Met__c = false));
		}

		// Insert wish child leads where child age is 1.5 years old and the field for Age Requirement should not update
		for (Integer i = 0; i < 10; i++) {
			leadListNeg.add(new Lead(
					FirstName = 'NFirstName' + i, LastName = 'NLastName' + i, Child_Age__c = 'Under 2.5',
					DOB__c = childDOB, Gender__c = 'Male', Company = 'MAWA', is_Family_Aware_of_Referral__c = 'Yes',
					Phone = '9611467559', Email = 'Ntestmawa' + i + '@gmail.com', State = 'Arizona',
					Treating_Medical_Professional_First_Name__c = 'Chris' + i,
					Treating_Medical_Professional_Last_Name__c = 'Waugh',
					Treating_Medical_Professional_Email__c = 'Ntestmawa2' + i + '@gmail.com',
					Hospital_Treatment_Facility_Treating__c = 'Steve Smith AC',
					Treating_Medical_Professional_Phone__c = '9990498555', Parent_First_Name__c = 'Parent' + i,
					Parent_Last_Name__c = 'LastName' + i, Referrer_FirstName__c = 'NReferrer' + i,
					Referrer_Last_Name__c = 'NTestRef' + i, Referrer_Phone__c = '8818467556',
					Referrer_Email__c = 'Nreferrer' + i + '@gmail.com', Referrer_City__c = 'Phoenix',
					Referrer_Zip__c = '85016', Status = 'Inquiry', PD_ICD_Code__c = icdCode.Id,
					ICD_Given_By_Referrer__c = icdCode.Id, Diagnosis_Given_By_Referrer__c = 'Test',
					ChapterName__c = chapterAccount.Id, Street = '125' + i + 'N Market St', PostalCode = '85016',
					City = 'Phoenix', Age_Requirement_Met__c = false));
		}
		leadList.addAll(leadListNeg);
		insert leadList;
		trac_TriggerHandlerBase.blockTrigger = false;
	}

	@IsTest
	static void testBatchLeadChildAgeWhenRunDateIsToday() {
		Test.startTest();

		// Verify none of the leads entering the batch have the Age requirement field marked as true
		Lead[] leadsBeforeUpdateList = [
				SELECT Id, Age_Requirement_Met__c
				FROM Lead
				WHERE Age_Requirement_Met__c = TRUE
		];
		System.assertEquals(0, leadsBeforeUpdateList.size());
		batch_leadChildAge reminder = new batch_leadChildAge();
		Database.executeBatch(reminder);
		Test.stopTest();
		Lead[] leadsUpdatedList = [
				SELECT Id, Age_Requirement_Met__c
				FROM Lead
				WHERE Age_Requirement_Met__c = TRUE
		];

		//Assert that number of the leads that should have been updated have been updated
		System.assertEquals(true, leadsUpdatedList[0].Age_Requirement_Met__c);
		System.assertEquals(10, leadsUpdatedList.size());
	}

	@IsTest
	static void testBatchLeadChildAgeWhenRunDateLastDayOfMonth() {
		Test.startTest();

		// Verify none of the leads entering the batch have the Age requirement field marked as true
		Lead[] leadsBeforeUpdateList = [
				SELECT Id, Age_Requirement_Met__c
				FROM Lead
				WHERE Age_Requirement_Met__c = TRUE
		];
		System.assertEquals(0, leadsBeforeUpdateList.size());
		batch_leadChildAge reminder = new batch_leadChildAge();
		reminder.runDate = Date.parse('06/30/2019');
		Database.executeBatch(reminder);
		Test.stopTest();
		Lead[] leadsUpdatedList = [
				SELECT Id, Age_Requirement_Met__c
				FROM Lead
				WHERE Age_Requirement_Met__c = TRUE
		];

		//Assert that number of the leads that should have been updated have been updated
		System.assertEquals(0, leadsUpdatedList.size());
	}

	@IsTest
	static void testBatchScheduler() {
		Test.startTest();

		// Cron Expression setting at 13:00:00 every day
		String cronExpression = '0 0 13 * * ?';
		batch_LeadChildAgeSchedule reminder = new batch_LeadChildAgeSchedule();
		String jobId = System.schedule('Lead Child Age Req', cronExpression, reminder);
		CronTrigger ct = [
				SELECT Id, CronExpression, TimesTriggered, NextFireTime
				FROM CronTrigger
				WHERE Id = :jobId
		];
		
		System.assertEquals(cronExpression, ct.CronExpression);
		System.assertEquals(0, ct.TimesTriggered);
		Test.stopTest();
	}
}