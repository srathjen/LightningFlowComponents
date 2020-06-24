/**
 * @description An apex page controller that takes the user to the right start page based on credentials or lack thereof
 */
@IsTest
public with sharing class CommunitiesLandingControllerTest {

    @TestSetup
    public static void setUp() {
        trac_TriggerHandlerBase.blockTrigger = true;

        List<User> volunteerUserList = TestDataFactory.createVolunteerUser(2, 'Active Volunteer (Login)', '');
        User activeVolunteerUser = volunteerUserList.get(0);
        activeVolunteerUser.ProfileId = Label.Active_Volunteer_Profile;
        User prosepectiveVolunteerUser = volunteerUserList.get(1);
        prosepectiveVolunteerUser.ProfileId = Label.Prospective_Volunteer_Profile;
        insert volunteerUserList;

        trac_TriggerHandlerBase.blockTrigger = false;
    }

    @IsTest
    public static void ActiveVolunteer() {
        PageReference returnPage;
        User activeVolunteer = getActiveUser(Label.Active_Volunteer_Profile);
        Test.startTest();
        System.runAs(activeVolunteer) {
            CommunitiesLandingController controller = new CommunitiesLandingController();
            returnPage = controller.forwardToStartPage();
        }
        Test.stopTest();
        System.assert(String.valueOf(returnPage).contains('/apex/volunteerlanding_vf'));
    }

    @IsTest
    public static void ActiveVolunteerWithURL() {
        PageReference returnPage;
        User activeVolunteer = getActiveUser(Label.Active_Volunteer_Profile);
        Test.startTest();
        System.runAs(activeVolunteer) {
            String startUrl = 'https://mawa.com';
            ApexPages.currentPage().getParameters().put('startUrl', startUrl);
            CommunitiesLandingController controller = new CommunitiesLandingController();
            returnPage = controller.forwardToStartPage();
        }
        Test.stopTest();
        System.assert(String.valueOf(returnPage).contains('https://mawa.com'));
    }

    @IsTest
    public static void ProspectiveVolunteer() {
        PageReference returnPage;
        User activeVolunteer = getActiveUser(Label.Prospective_Volunteer_Profile);
        Test.startTest();
        System.runAs(activeVolunteer) {
            CommunitiesLandingController controller = new CommunitiesLandingController();
            returnPage = controller.forwardToStartPage();
        }
        Test.stopTest();
        System.assert(String.valueOf(returnPage).contains('/apex/volunteerwelcomepage_vf'));
    }

    @IsTest
    public static void UserLoginWithReturnURL() {
        PageReference returnPage;
        Test.startTest();
        System.runAs(Utils.currentUser) {
            String startUrl = 'https://mawa.com';
            ApexPages.currentPage().getParameters().put('startUrl', startUrl);
            CommunitiesLandingController controller = new CommunitiesLandingController();
            returnPage = controller.forwardToStartPage();
        }
        Test.stopTest();
        System.assert(String.valueOf(returnPage).contains('/apex/communitieslogin'));
    }

    private static User getActiveUser(Id profileId) {
        return [
                SELECT Id
                FROM User
                WHERE ProfileId = :profileId AND IsActive = TRUE
                LIMIT 1
        ];
    }
}