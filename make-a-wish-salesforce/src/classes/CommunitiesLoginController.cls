/**************************************************************************************
Enabled by : Vennila Paramasivam
Description : This community used for capturing Volunteer for Make A Wish. Already signed up user can login using their username and password.
Based on the User Profile, Volunteer will redirect to the portal.
If Volunteer Profile is "Prospective Volunteer", then they will redirect to Prospective Volunteer Portal.
Suppose Volunteer Profile is "Active Volunteer", then they will redirect to Active Volunteer Portal.
****************************************************************************************/
global class CommunitiesLoginController {
    
    global CommunitiesLoginController () {}
    
    global String username {get; set;}
    global String password {get; set;}
    
    global PageReference login() {
        String startUrl = System.currentPageReference().getParameters().get('startURL');
        List<User> getUserDetails = [SELECT Id,Profile.name,Profile.id,ContactId from User WHERE Username = :username limit 1];
        if(getUserDetails.size() > 0){
            // If Prospective Volunteer, then they will be landed to Propective Volunteer Welcome Page.
            if(getUserDetails[0].Profile.id == label.Prospective_Volunteer_Profile) {
                return Site.login(username, password, '/apex/VolunteerWelcomePage_VF');
            }
            else {
                // If Active Volunteer, then they will be landed to Active Volunteer Welcome Page.
                if(getUserDetails.size()>0)  {
                    List<npe5__Affiliation__c> getPrimaryChapter = [SELECT Id, npe5__Organization__r.Name FROM npe5__Affiliation__c WHERE npe5__Contact__c =: getUserDetails.get(0).ContactId AND npe5__Primary__c = true];
                    if(getPrimaryChapter.size()>0)  {
                        // If the volunteer belongs to mulitple chapter then they will redirect to login page, where they finally logout from the chapter. 
                        // Volunteer last login chapter will be stored in HoldCurrentChapter custom settings.
                        // For example, If Volunteer belongs to Alabama and Arizona, if the user logged in Arizona finally, when the login next time, they will redirect to Arizona Chapter.
                        // If Volunteer login first time, then they will redirect to Primary chapter.
                        List<HoldCurrentChapter__c> getChapterValues = [SELECT Name,CurrentChapter__c FROM HoldCurrentChapter__c  WHERE Name =: getUserDetails.get(0).Id LIMIT 1];
                        if(getChapterValues.size()>0) {
                            getChapterValues.get(0).CurrentChapter__c = getPrimaryChapter.get(0).npe5__Organization__r.Name;
                            update getChapterValues;
                        } 
                        else {
                            HoldCurrentChapter__c newHoldChapter = new HoldCurrentChapter__c();
                            newHoldChapter.Name = getUserDetails.get(0).Id;
                            newHoldChapter.CurrentChapter__c = getPrimaryChapter.get(0).npe5__Organization__r.Name;
                            insert newHoldChapter;
                        }
                    }
                }
                if(!String.isEmpty(startUrl)) {
                    Date todayDate = system.today();                   
                    List<Conflict_Of_Interest__c> conflictIns = [SELECT Id,Name,Expiration_Date__c,Signed_Date__c,current__c,Volunteer_Contact__c FROM  Conflict_Of_Interest__c WHERE Volunteer_Contact__c  =: getUserDetails.get(0).ContactId AND Expiration_Date__c != NULL AND current__c = TRUE  AND Expiration_Date__c < TODAY ORDER BY CreatedDate DESC LIMIT 1]; 
                    List<Background_check__c> dbBackGround = [SELECT Id,CreatedDate,Hidden_Display_Popup__c,Volunteer__c,Status__c FROM Background_check__c WHERE Volunteer__c =: getUserDetails.get(0).ContactId AND Date__c < TODAY AND Current__c = True order by createdDate DESC Limit 1];
                    If(conflictIns.Size() > 0 || dbBackGround.Size() > 0)
                        return Site.login(username, password, '/apex/VolunteerLanding_VF');
                     else
                        return Site.login(username, password, startUrl);
                } else {
                    return Site.login(username, password, '/apex/VolunteerLanding_VF');
                }
            }
        }
        else {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Username does not exist.');
            ApexPages.addMessage(msg);
            return null;
        }
        return null;
    }
    
}