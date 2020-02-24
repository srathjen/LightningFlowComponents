@IsTest
private class LookupSObjectCtrlTest {

    static testMethod void test_lookup() {
        Test.startTest();
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.StageName = 'Prospecting';
        opp.CloseDate = Date.today().addMonths(1);
        insert opp;
        Test.stopTest();

        Test.setFixedSearchResults(new List<Id>{ opp.Id });

        String searchString = 'Test';
        String sObjectName = 'Opportunity';
        String fieldsToReturn = 'Name, StageName';
        String formattedOutput = '{1} - {0}';
        Map<String, Object> filter = new Map<String, Object>();

        String res = LookupSObjectCtlr.lookup(searchString, sObjectName, fieldsToReturn, formattedOutput, filter);

        LookupSObjectCtlr.Result resObj = (LookupSObjectCtlr.Result)
                JSON.deserialize(res.substring(1, res.length() - 1), LookupSObjectCtlr.Result.class);

        System.assertEquals(opp.Id, resObj.Id);
        System.assertEquals(opp.StageName + ' - ' + opp.Name, resObj.Description);

        res = LookupSObjectCtlr.loadObjectDescription(opp.Id, sObjectName, fieldsToReturn, formattedOutput);
        resObj = (LookupSObjectCtlr.Result)JSON.deserialize(res, LookupSObjectCtlr.Result.class);

        System.assertEquals(opp.Id, resObj.Id);
        System.assertEquals(opp.StageName + ' - ' + opp.Name, resObj.Description);
    }
}