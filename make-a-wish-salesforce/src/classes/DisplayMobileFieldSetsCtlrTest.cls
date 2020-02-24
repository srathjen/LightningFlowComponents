/**
 * Created by mbuhler on 7/14/2019.
 */
@IsTest
public class DisplayMobileFieldSetsCtlrTest {

    @IsTest
    public static void getFieldSets() {
        Test.startTest();
        List<DisplayMobileFieldSetsCtlr.FieldSetInfo> data = DisplayMobileFieldSetsCtlr.getFieldSets('Case');
        Test.stopTest();

        // Since this depends on existing metadata in the org, not sure what else I can do for assertions
        System.assertNotEquals(null, data);
    }

}