/**
 * An apex page controller that exposes the site forgot password functionality
 */
@IsTest 
public with sharing class ForgotPasswordControllerTest {
    
    @TestSetup
    public static void setUp() {
        trac_TriggerHandlerBase.blockTrigger = true;
        
        List<User> volunteerUserList = TestDataFactory.createVolunteerUser(1, 'Active Volunteer (Login)', '');
        User volunteerUserTheresa = volunteerUserList.get(0);
        volunteerUserTheresa.userName = 'Theresa@Mooney.com';
        insert volunteerUserList;
        
        trac_TriggerHandlerBase.blockTrigger = false;
    }
    
    @IsTest
    public static void testForgotPasswordController() {
        Test.startTest();
        User volUser = [
            SELECT Id, Username 
            FROM User 
            WHERE Username = 'Theresa@Mooney.com'
        ];
        
        Test.setCurrentPage(Page.ForgotPassword);
        ForgotPasswordController controller = new ForgotPasswordController();
        controller.username = volUser.Username;
        controller.success = true;
        controller.displayAckMsg = true;
        controller.forgotPassword();
        List<Apexpages.Message> pageMessages = ApexPages.getMessages();
        Test.stopTest();
        
        System.assert(pageMessages.isEmpty());
    }
    
    @IsTest
    public static void InvalidUser() {
        Test.startTest();
        Test.setCurrentPage(Page.ForgotPassword);
        ForgotPasswordController controller = new ForgotPasswordController();
        controller.username = 'Sample@demo.com';
        controller.forgotPassword();
        List<Apexpages.Message> pageMessages = ApexPages.getMessages();
        Test.stopTest();
        
        System.assert(!pageMessages.isEmpty());
    }
}