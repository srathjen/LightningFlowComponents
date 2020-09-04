@IsTest
private class LookupSObjectCtrlTest {

	@IsTest
	static void test_lookup_Opportunity() {
		Test.startTest();
		Opportunity opp = new Opportunity();
		opp.Name = 'Test Opportunity';
		opp.StageName = 'Prospecting';
		opp.CloseDate = Date.today().addMonths(1);
		insert opp;
		Test.stopTest();

		Test.setFixedSearchResults(new List<Id>{
				opp.Id
		});

		String searchString = 'Test';
		String sObjectName = 'Opportunity';
		String fieldsToReturn = 'Name, StageName';
		String formattedOutput = '{1} - {0}';
		Map<String, Object> filter = new Map<String, Object>();

		String res = LookupSObjectCtlr.lookup(searchString, sObjectName, fieldsToReturn, formattedOutput, filter, false);

		LookupSObjectCtlr.Result resObj = (LookupSObjectCtlr.Result)
				JSON.deserialize(res.substring(1, res.length() - 1), LookupSObjectCtlr.Result.class);

		System.assertEquals(opp.Id, resObj.Id);
		System.assertEquals(opp.StageName + ' - ' + opp.Name, resObj.Description);

		res = LookupSObjectCtlr.loadObjectDescription(opp.Id, sObjectName, fieldsToReturn, formattedOutput);
		resObj = (LookupSObjectCtlr.Result) JSON.deserialize(res, LookupSObjectCtlr.Result.class);

		System.assertEquals(opp.Id, resObj.Id);
		System.assertEquals(opp.StageName + ' - ' + opp.Name, resObj.Description);
	}

	@IsTest
	static void test_lookup_External_Contact() {
		Test.startTest();
		Contact ctc = new Contact();
		ctc.FirstName = 'Bob';
		ctc.LastName = 'Doe';
		ctc.RecordTypeId = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;
		insert ctc;
		Test.stopTest();

		Test.setFixedSearchResults(new List<Id>{
				ctc.Id
		});

		String searchString = 'Bob';
		String sObjectName = 'Contact';
		String fieldsToReturn = 'Name';
		String formattedOutput = '{0}';
		Map<String, Object> filter = new Map<String, Object>();

		String res = LookupSObjectCtlr.lookup(searchString, sObjectName, fieldsToReturn, formattedOutput, filter, true);

		LookupSObjectCtlr.Result resObj = (LookupSObjectCtlr.Result)
				JSON.deserialize(res.substring(1, res.length() - 1), LookupSObjectCtlr.Result.class);

		String expectedName = ctc.FirstName + ' ' + ctc.LastName;
		System.assertEquals(ctc.Id, resObj.Id);
		System.assertEquals(expectedName, resObj.Description);
		res = LookupSObjectCtlr.loadObjectDescription(ctc.Id, sObjectName, fieldsToReturn, formattedOutput);
		resObj = (LookupSObjectCtlr.Result) JSON.deserialize(res, LookupSObjectCtlr.Result.class);
		System.assertEquals(ctc.Id, resObj.Id);
		System.assertEquals(expectedName, resObj.Description);
	}

	@IsTest
	static void test_lookup_External_Account() {
		Test.startTest();
		Account acc = new Account();
		acc.Name = 'United Health';
		acc.RecordTypeId = Constant_AC.HOSPITAL_TREATMENT_ID;
		insert acc;
		Test.stopTest();

		Test.setFixedSearchResults(new List<Id>{
				acc.Id
		});

		String searchString = 'United';
		String sObjectName = 'Account';
		String fieldsToReturn = 'Name';
		String formattedOutput = '{0}';
		Map<String, Object> filter = new Map<String, Object>();

		String res = LookupSObjectCtlr.lookup(searchString, sObjectName, fieldsToReturn, formattedOutput, filter, true);

		LookupSObjectCtlr.Result resObj = (LookupSObjectCtlr.Result)
				JSON.deserialize(res.substring(1, res.length() - 1), LookupSObjectCtlr.Result.class);

		System.assertEquals(acc.Id, resObj.Id);
		System.assertEquals(acc.Name, resObj.Description);
		res = LookupSObjectCtlr.loadObjectDescription(acc.Id, sObjectName, fieldsToReturn, formattedOutput);
		resObj = (LookupSObjectCtlr.Result) JSON.deserialize(res, LookupSObjectCtlr.Result.class);
		System.assertEquals(acc.Id, resObj.Id);
		System.assertEquals(acc.Name, resObj.Description);
	}
}