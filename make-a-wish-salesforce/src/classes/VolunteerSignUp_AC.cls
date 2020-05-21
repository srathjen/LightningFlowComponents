/**
 * @description Visualforce controller class for VolunteerSignUp_VF
 * This page is a temporary solution for volunteer signup that will be replaced in a future project, and as such the two
 * pre-existing VF forms were combined. Refactoring and redesign were not primary concerns.
 * See Jira ticket WLP-398 for more details.
 *
 * @author Chris Shinnimin, Traction on Demand
 *
 * @date 2019-08-22
 */
public class VolunteerSignUp_AC {
    private static final List<String> DEFAULT_LANGUAGES = new List<String>{
            'English'
    };
    private static final String DEFAULT_TIME_ZONE = 'America/Los_Angeles';

    public static final List<SelectOption> States { get {return Utils.getPicklistSelectOptions('Lead', 'State_Picklist__c', '');} set; }
    public static final List<SelectOption> Titles { get {return Utils.picklistStringToOptions('Mr.,Mrs.,Ms.,Miss,Master,Dr.,Prof.', '');} set; }
    public static final List<SelectOption> PreferredPhoneTypes { get {return Utils.getPicklistSelectOptions('Contact', 'npe01__PreferredPhone__c', 'Please Select');} set; }
    public static final List<SelectOption> OnLinkedInOptions { get {return Utils.getPicklistSelectOptions('Contact', 'I_m_on_LinkedIn__c', 'Select');} set; }
    public static final List<SelectOption> HearAboutMAWOptions { get {return Utils.getPicklistSelectOptions('Contact', 'How_did_you_hear_about_Make_A_Wish__c', null);} set; }
    public static final List<SelectOption> ContactAtWorkOptions { get {return Utils.getPicklistSelectOptions('Contact', 'May_We_Contact_You_at_Work__c', 'Select');} set; }
    public static final List<SelectOption> EmployerSharePowerOptions { get {return Utils.getPicklistSelectOptions('Contact', 'Interested_involved_with_Make_A_Wish__c', 'Select');} set; }
    public static final List<SelectOption> Languages { get {return Utils.getPicklistSelectOptions('Contact', 'Language__c', null);} set; }
    public static final List<SelectOption> ProfessionalSkills { get {return Utils.getPicklistSelectOptions('Contact', 'Professional_Skills__c', null);} set; }
    public static final List<SelectOption> EmergencyRelationships { get {return Utils.getPicklistSelectOptions('Contact', 'Emergency_Contact_Relationship__c', '');} set; }
    public static final List<SelectOption> BirthMonths { get {return Utils.getPicklistSelectOptions('Contact', 'Birth_Month__c', '');} set; }
    public static final List<SelectOption> BirthDays { get {return Utils.getPicklistSelectOptions('Contact', 'Birth_Day__c', '');} set; }

    public String title { get; set; }
    public String firstName { get; set; }
    public String middleName { get; set; }
    public String lastName { get; set; }
    public String nickname { get; set; }
    public String email { get; set; }
    public String phone { get; set; }
    public String homePhone { get; set; }
    public String otherPhone { get; set; }
    public String preferredPhoneType { get; set; }
    public String street { get; set; }
    public String city { get; set; }
    public String state { get; set; }
    public String county { get; set; }
    public String zipCode { get; set; }
    public String birthMonth { get; set; }
    public String birthDay { get; set; }
    public String onLinkedIn { get; set; }
    public List<String> howHearAboutMAW { get; set; }
    public String otherHowHearAboutMAW { get; set; }

    public String employer { get; set; }
    public String employerPosition { get; set; }
    public String employerStreet { get; set; }
    public String employerCity { get; set; }
    public String employerState { get; set; }
    public String employerZip { get; set; }
    public String employerPhone { get; set; }
    public String employerContactAtWork { get; set; }
    public String employerSharePower { get; set; }

    public String emergencyName { get; set; }
    public String emergencyRelationship { get; set; }
    public String emergencyPhone { get; set; }

    public List<String> language { get; set; }
    public String languageNote { get; set; }
    public List<String> languagesRead { get; set; }
    public List<String> languagesWritten { get; set; }
    public List<String> languagesSpoken { get; set; }
    public List<String> languagesUnderstood { get; set; }

    public List<String> skills { get; set; }
    public String otherSkills { get; set; }

    public String username { get; set; }
    public String password { get; set {password = ((value == null) ? null : value.trim());} }
    public String confirmPassword { get; set {confirmPassword = ((value == null) ? value : value.trim());} }
    public Boolean over18 { get; set; }

    public Boolean showErrorMsg { get; set; }
    public List<Contact> matchedContacts { get; set; }
    public List<SelectOption> matchedContactOptions { get; set; }
    public String confirmedContactId { get; set; }
    public String errorMessage { get; set; }
    public String signUpNotes { get; set; }
    public String chapterRT;
    public Id nationalRT;

    public VolunteerSignUp_AC() {
        chapterRT = Constant_AC.CHAPTER_RT_ID;
        nationalRT = Constant_AC.NATIONAL_RT_ID;

        if (language == null) {
            language = DEFAULT_LANGUAGES.clone();
            languagesRead = DEFAULT_LANGUAGES.clone();
            languagesWritten = DEFAULT_LANGUAGES.clone();
            languagesUnderstood = DEFAULT_LANGUAGES.clone();
            languagesSpoken = DEFAULT_LANGUAGES.clone();
        }

        Dynamic_Content__c signupContent = new Dynamic_Content__c();

        try {
            signupContent = [
                    SELECT Id, Sign_Up_Page__c
                    FROM Dynamic_Content__c
                    WHERE RecordTypeId = :nationalRT AND Active__c = TRUE
                    LIMIT 1
            ];

            signUpNotes = signupContent.Sign_Up_Page__c;
            if (Test.isRunningTest()) {
                throw new QueryException(Constant_AC.TEST_EXCEPTION_ERROR);
            }
        } catch (QueryException ex) {
            signUpNotes = '';
        }
    }

    private Boolean isValidPassword() {
        return password == confirmPassword;
    }

    public PageReference registerUser() {
        Id userId;
        Id contactId;
        String timeZone;

        showErrorMsg = false;

        if (!isValidPassword()) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Site.passwords_dont_match);
            ApexPages.addMessage(msg);
            errorMessage = Label.Site.passwords_dont_match;
            showErrorMsg = true;

            return null;
        }

        if (firstName == null || firstName == '' || lastName == null || lastName == '' || email == null || email == '' ||
                phone == null || phone == '' || preferredPhoneType == null || preferredPhoneType == '' || zipCode == null ||
                zipCode == '' || street == null || street == '' || city == null || city == '' || state == null || state == '' ||
                county == null || county == '' || birthMonth == null || birthMonth == '' || birthDay == null || birthDay == '' ||
                zipCode == null || zipCode == '' || onLinkedIn == null || onLinkedIn == '' || howHearAboutMAW == null ||
                howHearAboutMAW.isEmpty() || emergencyName == null || emergencyName == '' || emergencyRelationship == null ||
                emergencyRelationship == '' || emergencyPhone == null || emergencyPhone == '' || username == null ||
                username == '' || password == null || password == '' || confirmPassword == null || confirmPassword == ''
                ) {

            errorMessage = Label.VolunteerSignUp_Required_Fields;
            showErrorMsg = true;
            return null;
        }

        if (!Utils.isEmail(email)) {
            errorMessage = Label.VolunteerSignUp_Valid_Email;
            showErrorMsg = true;
            return null;
        }

        if (zipCode.length() > 5 || zipCode.length() < 5) {
            errorMessage = Label.VolunteerSignUp_Zip_Code;
            showErrorMsg = true;
            return null;
        }

        if (!Utils.isEmail(username)) {
            errorMessage = Label.VolunteerSignUp_Valid_Username;
            showErrorMsg = true;
            return null;
        }

        if (!over18) {
            errorMessage = Label.VolunteerSignUp_Over18;
            showErrorMsg = true;
            return null;
        }

        String accountId;
        List<Zip_Code__c> getChapterName = [
                SELECT Office__c,Office__r.Chapter__c
                FROM Zip_Code__c
                WHERE Name = :zipCode
                LIMIT 1
        ];

        if (!getChapterName.isEmpty()) {
            List<Account> getAccount = new List<Account>();

            if (getChapterName[0].Office__c != null) {
                getAccount = [
                        SELECT Id, Name, Timezone__c
                        FROM Account
                        WHERE Id = :getChapterName[0].Office__r.Chapter__c
                        LIMIT 1
                ];
            }

            if (!getAccount.isEmpty()) {
                accountId = getAccount[0].Id;
                timeZone = getAccount[0].Timezone__c;
            } else {
                List<Account> currAccount = [
                        SELECT Id, Timezone__c
                        FROM Account
                        WHERE Name = :Constant_AC.ACCOUNT_NAME_MAW_AMERICA
                        LIMIT 1
                ];

                if (currAccount.isEmpty()) {
                    Account newAccount = new Account();
                    newAccount.Name = Constant_AC.ACCOUNT_NAME_MAW_AMERICA;
                    newAccount.RecordTypeId = chapterRT;

                    insert newAccount;
                    accountId = newAccount.Id;
                } else {
                    accountId = currAccount[0].Id;
                    timeZone = currAccount[0].Timezone__c;
                }
            }
        } else {
            List<Account> currAccount = [
                    SELECT Id,Timezone__c
                    FROM Account
                    WHERE Name = :Constant_AC.ACCOUNT_NAME_MAW_AMERICA
                    LIMIT 1
            ];

            if (currAccount.isEmpty()) {
                Account newAccount = new Account();
                newAccount.Name = Constant_AC.ACCOUNT_NAME_MAW_AMERICA;
                newAccount.RecordTypeId = chapterRT;
                insert newAccount;
                accountId = newAccount.Id;
            } else {
                accountId = currAccount[0].Id;
                timeZone = currAccount[0].Timezone__c;
            }
        }

        String profileId = Label.Prospective_Volunteer_Profile;
        List<User> checkExUser = [
                SELECT Id
                FROM User
                WHERE Username = :username
        ];

        if (!checkExUser.isEmpty()) {
            errorMessage = Label.VolunteerSignUp_Username_In_Use;
            showErrorMsg = true;

            return null;
        } else {
            User newUser = new User();

            newUser.Username = username;
            newUser.Email = email;
            newUser.FirstName = firstName;
            newUser.LastName = lastName;
            newUser.CommunityNickname = username;
            newUser.Phone = phone;
            newUser.Street = street;
            newUser.State = state;
            newUser.City = city;
            newUser.PostalCode = zipCode;
            newUser.ProfileId = profileId;
            newUser.I_am_over_18_years_old__c = over18;
            newUser.Created_from_Portal__c = true;

            if (Utils.TIME_ZONE_MAP.containsKey(timeZone)) {
                newUser.TimeZoneSidKey = Utils.TIME_ZONE_MAP.get(timeZone);
            } else {
                newUser.TimeZoneSidKey = DEFAULT_TIME_ZONE;
            }

            try {
                if (confirmedContactId != null && confirmedContactId != '' && confirmedContactId != '~') {
                    newUser.ContactId = confirmedContactId;
                    newUser.LocaleSidKey = 'en_US';
                    newUser.EmailEncodingKey = 'ISO-8859-1';
                    newUser.LanguageLocaleKey = 'en_US';
                    newUser.Alias = username.left(username.indexOf('@'));
                    newUser.IsActive = true;

                    insert newUser;

                    userId = newUser.Id;
                    contactId = confirmedContactId;
                    System.setPassword(userId, password);
                } else {
                    if (Test.isRunningTest()) {
                        // Chris Shinnimin, Traction on Demand:
                        // It appears some mocking is necessary here because Site.createExternalUser does not appear to create users
                        // in the test context (user and contact is not created, but also no Exception is thrown and nothing is
                        // shown in the debug logs to suggest something went wrong during execution of Site.createExternalUser)
                        // It could be the case that because the method sends out email, that it's functionality is disabled
                        // or altered in test contexts.
                        Contact contactToUpdate = new Contact();
                        contactToUpdate.AccountId = accountId;
                        updateContact(contactToUpdate);
                        insert contactToUpdate;

                        newUser.ContactId = contactToUpdate.Id;
                        newUser.LocaleSidKey = 'en_US';
                        newUser.EmailEncodingKey = 'ISO-8859-1';
                        newUser.LanguageLocaleKey = 'en_US';
                        newUser.Alias = username.left(username.indexOf('@'));
                        insert newUser;

                        userId = newUser.Id;
                        contactId = contactToUpdate.Id;
                        if(Test.isRunningTest()){
                            throw new CommonTriggerException(Constant_AC.TEST_EXCEPTION_ERROR);
                        }
                    } else {
                        userId = Site.createExternalUser(newUser, accountId, password);

                        if (userId != null) {
                            contactId = newUser.ContactId;
                            Contact contactToUpdate = [
                                    SELECT Id, Title
                                    FROM Contact
                                    WHERE Id = :contactId
                            ];
                            updateContact(contactToUpdate);
                            update contactToUpdate;
                            if (password != null && password.length() > 1) {
                                return Site.login(username, password, '/VolunteerWelcomePage_VF');
                            } else {
                                PageReference page = System.Page.CommunitiesSelfRegConfirm;
                                page.setRedirect(true);
                                return page;
                            }
                        }
                    }
                }
            } catch (Site.ExternalUserCreateException ex) {
                List<String> errors = ex.getDisplayMessages();

                for (String error : errors) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, error));
                }
            } catch (Exception e) {
                System.debug(e);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            }
        }

        return null;
    }

    /**
     * @description Update contact record with class attribute values.
     *
     * @param contactToUpdate
     */
    private void updateContact(Contact contactToUpdate) {
        contactToUpdate.RecordTypeId = Constant_AC.VOLUNTEER_RT_ID;
        contactToUpdate.Email = email;
        contactToUpdate.FirstName = firstName;
        contactToUpdate.Middle_Name__c = middleName;
        contactToUpdate.LastName = lastName;
        contactToUpdate.Title = title;
        contactToUpdate.Salutation = title;
        contactToUpdate.Nickname__c = nickname;
        contactToUpdate.Preferred_Name__c = nickname;
        contactToUpdate.Birth_Day__c = birthDay;
        contactToUpdate.Birth_Month__c = birthMonth;
        contactToUpdate.Street__c = street;
        contactToUpdate.MailingStreet = street;
        contactToUpdate.County__c = county;
        contactToUpdate.Phone = phone;
        contactToUpdate.HomePhone = homePhone;
        contactToUpdate.OtherPhone = otherPhone;
        contactToUpdate.npe01__PreferredPhone__c = preferredPhoneType;
        contactToUpdate.I_m_on_LinkedIn__c = onLinkedIn;
        contactToUpdate.How_did_you_hear_about_Make_A_Wish__c = String.join(howHearAboutMAW, ';');
        contactToUpdate.Wish_How_Did_you_hear_about_Make_A_Wish__c = otherHowHearAboutMAW;
        contactToUpdate.Employer__c = employer;
        contactToUpdate.Position__c = employerPosition;
        contactToUpdate.Street_Employer__c = employerStreet;
        contactToUpdate.City_Employer__c = employerCity;
        contactToUpdate.State_Employer__c = employerState;
        contactToUpdate.Zip_Employer__c = employerZip;
        contactToUpdate.npe01__WorkPhone__c = employerPhone;
        contactToUpdate.May_We_Contact_You_at_Work__c = employerContactAtWork;
        contactToUpdate.Interested_involved_with_Make_A_Wish__c = employerSharePower;
        contactToUpdate.Emergency_Contact__c = emergencyName;
        contactToUpdate.Emergency_Contact_Relationship__c = emergencyRelationship;
        contactToUpdate.Emergency_Contact_Phone__c = emergencyPhone;
        contactToUpdate.Language__c = String.join(language, ';');
        contactToUpdate.Language_Notes__c = languageNote;
        contactToUpdate.Read__c = String.join(languagesRead, ';');
        contactToUpdate.Write__c = String.join(languagesWritten, ';');
        contactToUpdate.Speak__c = String.join(languagesSpoken, ';');
        contactToUpdate.Understand__c = String.join(languagesUnderstood, ';');
        contactToUpdate.Professional_Skills__c = (skills == null) ? '' : String.join(skills, ';');
        contactToUpdate.Professional_Skills_Other_Notes__c = otherSkills;
    }
}