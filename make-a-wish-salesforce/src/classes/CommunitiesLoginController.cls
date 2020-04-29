/**************************************************************************************
Enabled by : Vennila Paramasivam
Description : This community used for capturing Volunteer for Make A Wish. Already signed up user can login using their username and password.
Based on the User Profile, Volunteer will redirect to the portal.
If Volunteer Profile is "Prospective Volunteer", then they will redirect to Prospective Volunteer Portal.
Suppose Volunteer Profile is "Active Volunteer", then they will redirect to Active Volunteer Portal.
****************************************************************************************/
global class CommunitiesLoginController {
    
    global String username {get; set;}
    global String password {get; set;}
    
    /**
    * Route users to landing page based on profile upon successful login
    */
    global PageReference login() {
        String startUrl = System.currentPageReference().getParameters().get('startURL');
        User currentUser;
        try {
            currentUser = [
                SELECT Id, Profile.Name, Profile.Id, ContactId 
                FROM User 
                WHERE Username = :username 
                LIMIT 1];
        } catch(Exception ex) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Username does not exist.');
            ApexPages.addMessage(msg);
            return null;
        }
        
        //if Prospective Volunteer they will land on Propective Volunteer Welcome Page
        if(currentUser.Profile.Id == label.Prospective_Volunteer_Profile) {
            return Site.login(username, password, '/apex/VolunteerWelcomePage_VF');
        } else {
            //if Active Volunteer they will land on Active Volunteer Welcome Page
            List<npe5__Affiliation__c> getPrimaryChapter = [
                SELECT Id, npe5__Organization__r.Name 
                FROM npe5__Affiliation__c 
                WHERE npe5__Contact__c = :currentUser.ContactId 
                AND npe5__Primary__c = true];
            if(!getPrimaryChapter.isEmpty()) {
                /*If the volunteer belongs to mulitple chapter then they will redirect to login page, where they finally logout from the chapter. 
                Volunteer last login chapter will be stored in HoldCurrentChapter custom settings.
                For example, If Volunteer belongs to Alabama and Arizona, if the user logged in Arizona finally,
                when the login next time, they will redirect to Arizona Chapter.
                if Volunteer login first time, then they will redirect to Primary chapter.*/
                List<HoldCurrentChapter__c> getChapterValues = [
                    SELECT Name, CurrentChapter__c 
                    FROM HoldCurrentChapter__c  
                    WHERE Name = :currentUser.Id 
                    LIMIT 1];
                if(!getChapterValues.isEmpty()) {
                    getChapterValues.get(0).CurrentChapter__c = getPrimaryChapter.get(0).npe5__Organization__r.Name;
                    update getChapterValues;
                } else {
                    HoldCurrentChapter__c newHoldChapter = new HoldCurrentChapter__c();
                    newHoldChapter.Name = currentUser.Id;
                    newHoldChapter.CurrentChapter__c = getPrimaryChapter.get(0).npe5__Organization__r.Name;
                    insert newHoldChapter;
                }
            }
            if(!String.isEmpty(startUrl)) {
                Date todayDate = System.today();                   
                List<Conflict_Of_Interest__c> conflictIns = [
                    SELECT Id
                    FROM  Conflict_Of_Interest__c 
                    WHERE Volunteer_Contact__c  =:currentUser.ContactId 
                    AND Expiration_Date__c != null 
                    AND current__c = true  
                    AND Expiration_Date__c < :todayDate
                    ORDER BY CreatedDate DESC]; 
                List<Background_check__c> dbBackGround = [
                    SELECT Id
                    FROM Background_check__c 
                    WHERE Volunteer__c = :currentUser.ContactId 
                    AND Date__c < :todayDate 
                    AND Current__c = true 
                    ORDER BY CreatedDate DESC];
                if(!conflictIns.isEmpty() || !dbBackGround.isEmpty()) {
                    return Site.login(username, password, '/apex/VolunteerLanding_VF');
                } else {
                    return Site.login(username, password, startUrl);
                }
            } else {
                return Site.login(username, password, '/apex/VolunteerLanding_VF');
            }
        }
    }
}