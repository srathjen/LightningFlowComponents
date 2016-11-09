/**
 * An apex page controller that exposes the site forgot password functionality
 */
@IsTest public with sharing class ForgotPasswordControllerTest {
     @IsTest(SeeAllData=true) public static void testForgotPasswordController() {
        // Instantiate a new controller with all parameters in the page
        ForgotPasswordController controller = new ForgotPasswordController();
        controller.username = 'saravanan@vol.com'; 
        System.assertEquals(controller.forgotPassword(),null); 
    }
     @IsTest(SeeAllData=true) public static void InvalidUser() {
        // Instantiate a new controller with all parameters in the page
        ForgotPasswordController controller = new ForgotPasswordController();
        controller.username = 'saravanan_test@vol.com'; 
        controller.success = true;
        System.assertEquals(controller.forgotPassword(),null); 
    }
}