/**
 * @author Steve Doucette, Traction on Demand 
 * @date 4/6/2020
 */
@IsTest
private class ErrorMessage_AC_Test {

    private static final String TEST_STRING = 'Test';

    @IsTest
    static void testBehavior() {
        ErrorMessage_AC.createDebugRec(TEST_STRING, TEST_STRING, TEST_STRING, TEST_STRING, TEST_STRING, TEST_STRING, TEST_STRING);
    }
}