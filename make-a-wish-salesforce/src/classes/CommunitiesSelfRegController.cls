/*****************************************************************************************************************
Enabled By : Vennila Paramasivam.
Description : An apex page controller that supports self registration of volunteers in communities that allow self registration

*****************************************************************************************************************/
public class CommunitiesSelfRegController {
    
    public String firstName {get; set;}
    public String lastName {get; set;}
    public String email{get; set;}
    public String phone{get;set;}
    public String city{get;set;}
    public String state{get;set;}
    public String zipCode{get;set;}
    public String username{get;set;}
    public String password {get; set {password = value == null ? value : value.trim(); } }
    public String confirmPassword {get; set { confirmPassword = value == null ? value : value.trim(); } }
    public Boolean isOver18YearsOld{get;set;}
    public Boolean showErrorMsg {get;set;}
    public String errorMessage {get;set;}
    public String chapterRT;
    public Id nationalRT;
    public String userId;
    public String signUpNotes{get;set;}
    
    public CommunitiesSelfRegController() {
        chapterRT = Constant_AC.CHAPTER_RT_ID;
        nationalRT = Constant_AC.NATIONAL_RT_ID;
        Dynamic_Content__c signUpContent = [
            SELECT Id, Sign_Up_Page__c 
            FROM Dynamic_Content__c 
            WHERE RecordTypeId = :nationalRT
            AND active__c = TRUE 
            LIMIT 1];
        if(signupContent != null) {
            signUpNotes = signUpContent.Sign_Up_Page__c;
        }
    }
    
    /**
    * Create Volunteer Contact and User record based on the Sign up page inputs
    */
    public PageReference registerUser() {    
        if(!isValidPassword()) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.site.passwords_dont_match);
            ApexPages.addMessage(msg);
            return null;
        }    
        if(String.isBlank(lastName) && String.isBlank(email)){
            errorMessage = 'Please enter your last name and email address.';
            showErrorMsg = true;
            return null;
        } else {
            showErrorMsg = false;
        }
        if(String.isBlank(lastName)) {
            errorMessage = 'Please enter your last name.';
            showErrorMsg = true;
            return null;
        }else {
            showErrorMsg = false;
        }
        if(String.isBlank(email) || !validateEmail(email)) {
            errorMessage = 'Please enter a valid email address.';
            showErrorMsg = true;
            return null;
        } else {
            showErrorMsg = false;
        }
        if(String.isBlank(zipcode)) {
            errorMessage = 'Please enter your zip code.';
            showErrorMsg = true;
            return null;
        } else {
            showErrorMsg = false; 
        }
        if(zipcode != null && zipcode.length() != 5) {
            errorMessage = 'Please enter a 5 digit zip code.';
            showErrorMsg = true;
            return null;
        } else {
            showErrorMsg = false; 
        } 
        if(String.isBlank(username) || !validateEmail(username)) {
            errorMessage = 'Please enter a valid username. Username must be in email format (name@domain.com).';
            showErrorMsg = true;
            return null;
        } else {
            showErrorMsg = false;
        }
        if(String.isBlank(password)) {
            errorMessage = 'Please enter a password.';
            showErrorMsg = true;
            return null;
        } else {
            showErrorMsg = false;
        }
        if(String.isBlank(confirmPassword)) {
            errorMessage = 'Please confirm password.';
            showErrorMsg = true;
            return null;
        } else {
            showErrorMsg = false;
        }
        if(isOver18YearsOld == false) {
            errorMessage = 'Thank you for your interest in volunteering with Make-A-Wish. Most volunteer opportunities are '
                +'designed for individuals over the age of 18. If you are under the age of 18,'+
                'please contact your local chapter to discuss what, if any, opportunities we currently have available.';
            showErrorMsg = true;
            return null;
        } else {
            showErrorMsg = false;
        }
        
        String timeZone;
        Map<String,String> timeZoneMap = getTimezoneValues();
        List<Zip_Code__c> getChpaterName = [
            SELECT Office__c, Office__r.Chapter__c 
            FROM Zip_Code__c 
            WHERE Name = :zipcode 
            LIMIT 1];
        String accountId;
        if(!getChpaterName.isEmpty()) {
            List<Account> getAccount = new List<Account>();
            if(getChpaterName[0].Office__c != null) {
                getAccount = [SELECT Id, Name, Timezone__c 
                              FROM Account
                              WHERE Id = :getChpaterName[0].Office__r.Chapter__c 
                              LIMIT 1];
            }
            if(!getAccount.isEmpty()) {
                accountId = getAccount[0].Id;
                timeZone =  getAccount[0].Timezone__c;
            } else {
                List<Account> currAccount = [
                    SELECT Id, TimeZone__c 
                    FROM Account 
                    WHERE Name = 'Make-A-Wish America' 
                    LIMIT 1];
                if(currAccount.isEmpty()) {
                    Account newAccount = new Account();
                    newAccount.Name = 'Make-A-Wish America';
                    newAccount.RecordTypeId = chapterRT;
                    insert newAccount;
                    accountId = newAccount.id;
                } else {
                    accountId = currAccount[0].id;
                    timeZone =  currAccount[0].timeZone__c;
                }
            }
        } else {
            List<Account> currAccount = [
                SELECT Id, Timezone__c 
                FROM Account 
                WHERE Name = 'Make-A-Wish America' 
                LIMIT 1];
            if(currAccount.isEmpty()) {
                Account newAccount = new Account();
                newAccount.Name = 'Make-A-Wish America';
                newAccount.RecordTypeId = chapterRT;
                insert newAccount;
                accountId = newAccount.Id;
            } else {
                accountId = currAccount[0].Id;
                timeZone =  currAccount[0].timeZone__c;
            }
        }
        
        List<User> checkExUser = [
            SELECT Id 
            FROM User 
            WHERE Username = :userName];
        List<Contact> exContacts = [
            SELECT Id 
            FROM Contact 
            WHERE Email = :email 
            AND AccountId = :accountId];
        if(!checkExUser.isEmpty()) {
            errorMessage = 'The username you provided is already in use. Please enter a different username to continue the sign up process. '
                + 'If you have already signed up, please click "Log In" to access the login page.';
            showErrorMsg = true;
            return null;
        } else if(!exContacts.isEmpty()) {
            errorMessage = 'The email you provided is already in use. Please enter a different email address to continue the sign up process. ' 
                + 'If you have already signed up, please click "Log In" to access the login page.';
            showErrorMsg = true;
            return null;
        } else {
            User newUser = new User();
            newUser.Username = userName;
            newUser.Email = email;
            newUser.FirstName = firstName;
            newUser.LastName = lastName;
            newUser.CommunityNickname = userName;
            newUser.Phone = phone;
            newUser.State = state;
            newUser.city = city;
            newUser.postalCode = zipCode;
            newUser.ProfileId = label.Prospective_Volunteer_Profile;
            newUser.I_am_over_18_years_old__c = isOver18YearsOld;
            newUser.created_from_portal__c = true;
            if(timeZoneMap.containsKey(timeZone)) {
                newUser.TimeZoneSidKey = timeZoneMap.get(timeZone);
            } else {
                newUser.TimeZoneSidKey='America/Los_Angeles';
            }
            
            try {
                userId = Site.createExternalUser(newUser, accountId, password);
            } catch(Site.ExternalUserCreateException ex) {
                List<String> errors = ex.getDisplayMessages();
                for(String error : errors) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, error));
                }
            }
        } 
        //If Volunteer is created successfully, then redirect to Volunteer Landing Page
        if(userId != null) { 
            if(password != null && password.length() > 1) {
                return Site.login(userName, password, '/VolunteerWelcomePage_VF');
            } else {
                PageReference page = System.Page.CommunitiesSelfRegConfirm;
                page.setRedirect(true);
                return page;
            }
        }
        return null;
    }
    
    /**
    * Checks that input passwords match
    */
    private boolean isValidPassword() {
        return password == confirmPassword;
    }
    
    /**
    * Checks if email address is valid
    */
    public static boolean validateEmail(string email){
        String emailRegex = '([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})';
        Pattern MyPattern = Pattern.compile(emailRegex);
        Matcher MyMatcher = MyPattern.matcher(email);
        return MyMatcher.matches();
    }
    
    /**
    * Retrieves state picklist values as options
    */
    public List<SelectOption> getStates() {
        return Utils.getPicklistSelectOptions('Lead', 'State_Picklist__c', 'Select an option');
    }
    
    /**
    * Creates map of timezone values
    */
    public Map<String, String> getTimezoneValues() {
        Map<String, String> timezoneMap = new Map<String, String>();
        timeZoneMap.put('(GMT-07:00) Mountain Standard Time (America/Phoenix)','America/Phoenix');
        timeZoneMap.put('(GMT-02:00) Brasilia Summer Time (America/Sao_Paulo)','America/Sao_Paulo');
        timeZoneMap.put('(GMT-03:00) Argentina Time (America/Argentina/Buenos_Aires)','America/Argentina/Buenos_Aires');
        timeZoneMap.put('(GMT-03:00) Chile Summer Time (America/Santiago)','America/Santiago');
        timeZoneMap.put('(GMT-03:30) Newfoundland Standard Time (America/St_Johns)','America/St_Johns');
        timeZoneMap.put('(GMT-04:00) Atlantic Standard Time (America/Halifax)','America/Halifax');
        timeZoneMap.put('(GMT-04:00) Atlantic Standard Time (America/Puerto_Rico)','America/Puerto_Rico');
        timeZoneMap.put('(GMT-04:30) Venezuela Time (America/Caracas)','America/Caracas');
        timeZoneMap.put('(GMT-05:00) Colombia Time (America/Bogota)','America/Bogota');
        timeZoneMap.put('(GMT-05:00) Eastern Standard Time (America/Indiana/Indianapolis)','America/Indiana/Indianapolis');
        timeZoneMap.put('(GMT-05:00) Peru Time (America/Lima)','America/Lima');
        timeZoneMap.put('(GMT-05:00) Eastern Standard Time (America/New_York)','America/New_York');
        timeZoneMap.put('(GMT-05:00) Eastern Standard Time (America/Panama)','America/Panama');
        timeZoneMap.put('(GMT-06:00) Central Standard Time (America/Chicago)','America/Chicago');
        timeZoneMap.put('(GMT-06:00) Central Standard Time (America/El_Salvador)','America/El_Salvador');
        timeZoneMap.put('(GMT-06:00) Central Standard Time (America/Mexico_City)','America/Mexico_City');
        timeZoneMap.put('(GMT-07:00) Mountain Standard Time (America/Denver)','America/Denver');
        timeZoneMap.put('(GMT-07:00) Mountain Standard Time (America/Phoenix)','America/Phoenix');
        timeZoneMap.put('(GMT-08:00) Pacific Standard Time (America/Los_Angeles)','America/Los_Angeles');
        timeZoneMap.put('(GMT-08:00) Pacific Standard Time (America/Tijuana)','America/Tijuana');
        timeZoneMap.put('(GMT-09:00) Alaska Standard Time (America/Anchorage)','America/Anchorage');
        return timezoneMap;
    }
}