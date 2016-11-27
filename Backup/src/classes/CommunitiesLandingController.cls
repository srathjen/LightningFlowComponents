/**
 * An apex page controller that takes the user to the right start page based on credentials or lack thereof
 */
public with sharing class CommunitiesLandingController {
    
    List<Profile> userProfileName = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
    
    // Code we will invoke on page load.
    public PageReference forwardToStartPage() {
        System.debug('UserProfileName>>>>>>>>'+userProfileName);
        if(userProfileName.size()>0 && userProfileName[0].Name == 'Active Volunteer') {
            return page.VolunteerLanding_VF;
        } else if(userProfileName.size()>0 && userProfileName[0].Name == 'Prospective Volunteer') {
            return page.VolunteerWelcomePage_VF;
        } else {
            return page.CommunitiesLogin;
        }
    }
    
    public CommunitiesLandingController() {}
}