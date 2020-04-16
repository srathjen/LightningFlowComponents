/**
* @description      Controller to route users to the correct staring page.
*/
public with sharing class CommunitiesLandingController {
    /*
     * @description     Code to route users to appropriate page based on user profile after login.
     *
     * @author          MST Solutions
     * @createdDate     unknknown
     */
    public PageReference forwardToStartPage() {
        String startUrl = System.currentPageReference().getParameters().get('startURL');

        if (Utils.currentUser.ProfileId == Label.Active_Volunteer_Profile) {
            if (!String.isEmpty(startUrl)) {
                PageReference landingPage = new PageReference(startUrl);

                return landingPage;
            } else {
                return Page.VolunteerLanding_VF;
            }
        } else if (Utils.currentUser.ProfileId == Label.Prospective_Volunteer_Profile) {
            return Page.VolunteerWelcomePage_VF;
        } else {
            return Page.CommunitiesLogin;
        }
    }

    public CommunitiesLandingController() {}
}