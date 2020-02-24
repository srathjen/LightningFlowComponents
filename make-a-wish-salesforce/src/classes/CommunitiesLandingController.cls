/**
* An apex page controller that takes the user to the right start page based on credentials or lack thereof
*/
public with sharing class CommunitiesLandingController {
    
    List<Profile> userProfileName = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
    
    // Code we will invoke on page load.
    public PageReference forwardToStartPage() {
        String startUrl = System.currentPageReference().getParameters().get('startURL');
        
        if(userProfileName.size()>0 && (userProfileName[0].Id == label.Active_Volunteer_Profile)) {
            if(!String.isEmpty(startUrl)) {
                PageReference landingPage = new PageReference(startUrl);
                return landingPage;
            } else {
                return page.VolunteerLanding_VF;
            }
            //return page.VolunteerLanding_VF;
        } else if(userProfileName.size()>0 && (userProfileName[0].Id == label.Prospective_Volunteer_Profile)) {
            return page.VolunteerWelcomePage_VF;
        } else {
            return page.CommunitiesLogin;
        }
    }
    
    public CommunitiesLandingController() {}
}