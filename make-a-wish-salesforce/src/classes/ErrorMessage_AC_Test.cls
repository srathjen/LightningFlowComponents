/**
 * @author Steve Doucette, Traction on Demand
 *
 * @date 4/6/2020
 */
@IsTest
private class ErrorMessage_AC_Test {

    private static final String TEST_STRING = 'Error';

    @IsTest
    static void testBehavior() {
        Test.startTest();
        ErrorMessage_AC.createDebugRec(TEST_STRING, TEST_STRING, TEST_STRING, TEST_STRING, TEST_STRING, TEST_STRING, TEST_STRING);
        Test.stopTest();
        System.assertEquals(1, [
                SELECT Id
                FROM Apex_Debug_Log__c
        ].size());
    }

    @IsTest
    static void testBehavior2() {
        Test.startTest();
        Contact contact = new Contact();
        ErrorMessage_AC.createDebugRec(new List<SObject>{contact}, TEST_STRING, TEST_STRING, TEST_STRING, TEST_STRING, TEST_STRING);
        Test.stopTest();
        System.assertEquals(1, [
                SELECT Id
                FROM Apex_Debug_Log__c
        ].size());
    }
}