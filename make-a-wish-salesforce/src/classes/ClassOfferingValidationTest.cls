/**
 * @description Utils Test Class
 * @author Gustavo Mayer, Traction on Demand
 * @date 7/15/2019
 */
@IsTest
public class ClassOfferingValidationTest {

    @IsTest
    private static void validateStartTimeAndEndTimeEmpty() {
        Class_Offering__c classOffering = new Class_Offering__c();
        classOffering.Start_Time__c = null;
        classOffering.End_Time__c = null;

        ClassOfferingValidation.validateStartEnd(new List<Class_Offering__c>{
                classOffering
        });

        System.assertEquals(0, ApexPages.getMessages().size());
    }

    @IsTest
    private static void validateEmptyStartTime_WhenEndTimeNotEmpty() {
        Class_Offering__c classOffering = new Class_Offering__c();
        classOffering.Start_Time__c = null;
        classOffering.End_Time__c = '12:00 AM';

        ClassOfferingValidation.validateStartEnd(new List<Class_Offering__c>{
                classOffering
        });

        System.assertEquals('Please enter a valid Start Time', ApexPages.getMessages()[0].getSummary());
    }

    @IsTest
    private static void validateInvalidStartTime() {
        Class_Offering__c classOffering = new Class_Offering__c();
        classOffering.Start_Time__c = '01:30 AM';
        classOffering.End_Time__c = '12:00 AM';

        ClassOfferingValidation.validateStartEnd(new List<Class_Offering__c>{
                classOffering
        });

        System.assertEquals('Please enter a valid Start Time', ApexPages.getMessages()[0].getSummary());
    }

    @IsTest
    private static void validateInvalidEndTime() {
        Class_Offering__c classOffering = new Class_Offering__c();
        classOffering.Start_Time__c = '11:30 AM';
        classOffering.End_Time__c = '01:00 AM';

        ClassOfferingValidation.validateStartEnd(new List<Class_Offering__c>{
                classOffering
        });

        System.assertEquals('Please enter a valid End Time', ApexPages.getMessages()[0].getSummary());
    }

    @IsTest
    private static void validateInvalidStartTimeGreaterThanEndTime() {
        Class_Offering__c classOffering = new Class_Offering__c();
        classOffering.Start_Time__c = '2:00 PM';
        classOffering.End_Time__c = '12:00 PM';

        ClassOfferingValidation.validateStartEnd(new List<Class_Offering__c>{
                classOffering
        });

        System.assertEquals('End Time should be greater than Start time', ApexPages.getMessages()[0].getSummary());
    }
}