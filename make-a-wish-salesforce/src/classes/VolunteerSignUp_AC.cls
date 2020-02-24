/**
 * Visualforce controller class for VolunteerSignUp_VF
 *
 * This page is a temporary solution for volunteer signup that will be replaced in a future project, and as such the two
 * pre-existing VF forms were combined. Refactoring and redesign were not primary concerns.
 *
 * See Jira ticket WLP-398 for more details.
 *
 * @author Chris Shinnimin, Traction on Demand
 * @date 2019-08-22
 */
public class VolunteerSignUp_AC {

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
			language = new List<String>{
					'English'
			};
			languagesRead = new List<String>{
					'English'
			};
			languagesWritten = new List<String>{
					'English'
			};
			languagesUnderstood = new List<String>{
					'English'
			};
			languagesSpoken = new List<String>{
					'English'
			};
		}

		Dynamic_Content__c signUpContent = new Dynamic_Content__c();
		try {
			signupContent = [
					SELECT Id, Sign_Up_Page__c
					FROM Dynamic_Content__c
					WHERE RecordTypeId = :nationalRT AND active__c = TRUE
					LIMIT 1
			];
			signUpNotes = signUpContent.Sign_Up_Page__c;
		} catch (QueryException ex) {
			signUpNotes = '';
		}
	}

	private boolean isValidPassword() {
		return password == confirmPassword;
	}

	public PageReference registerUser() {
		Id userId;
		Id contactId;

		// TimeZone Map
		String timeZone;
		Map<String, String> timeZoneMap = new Map<String, String>();
		timeZoneMap.put('(GMT-07:00) Mountain Standard Time (America/Phoenix)', 'America/Phoenix');
		timeZoneMap.put('(GMT-02:00) Brasilia Summer Time (America/Sao_Paulo)', 'America/Sao_Paulo');
		timeZoneMap.put('(GMT-03:00) Argentina Time (America/Argentina/Buenos_Aires)', 'America/Argentina/Buenos_Aires');
		timeZoneMap.put('(GMT-03:00) Chile Summer Time (America/Santiago)', 'America/Santiago');
		timeZoneMap.put('(GMT-03:30) Newfoundland Standard Time (America/St_Johns)', 'America/St_Johns');
		timeZoneMap.put('(GMT-04:00) Atlantic Standard Time (America/Halifax)', 'America/Halifax');
		timeZoneMap.put('(GMT-04:00) Atlantic Standard Time (America/Puerto_Rico)', 'America/Puerto_Rico');
		timeZoneMap.put('(GMT-04:30) Venezuela Time (America/Caracas)', 'America/Caracas');
		timeZoneMap.put('(GMT-05:00) Colombia Time (America/Bogota)', 'America/Bogota');
		timeZoneMap.put('(GMT-05:00) Eastern Standard Time (America/Indiana/Indianapolis)', 'America/Indiana/Indianapolis');
		timeZoneMap.put('(GMT-05:00) Peru Time (America/Lima)', 'America/Lima');
		timeZoneMap.put('(GMT-05:00) Eastern Standard Time (America/New_York)', 'America/New_York');
		timeZoneMap.put('(GMT-05:00) Eastern Standard Time (America/Panama)', 'America/Panama');
		timeZoneMap.put('(GMT-06:00) Central Standard Time (America/Chicago)', 'America/Chicago');
		timeZoneMap.put('(GMT-06:00) Central Standard Time (America/El_Salvador)', 'America/El_Salvador');
		timeZoneMap.put('(GMT-06:00) Central Standard Time (America/Mexico_City)', 'America/Mexico_City');
		timeZoneMap.put('(GMT-07:00) Mountain Standard Time (America/Denver)', 'America/Denver');
		timeZoneMap.put('(GMT-07:00) Mountain Standard Time (America/Phoenix)', 'America/Phoenix');
		timeZoneMap.put('(GMT-08:00) Pacific Standard Time (America/Los_Angeles)', 'America/Los_Angeles');
		timeZoneMap.put('(GMT-08:00) Pacific Standard Time (America/Tijuana)', 'America/Tijuana');
		timeZoneMap.put('(GMT-09:00) Alaska Standard Time (America/Anchorage)', 'America/Anchorage');

		showErrorMsg = false;

		if (!isValidPassword()) {
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.site.passwords_dont_match);
			ApexPages.addMessage(msg);
			errorMessage = Label.site.passwords_dont_match;
			showErrorMsg = true;
			return null;
		}

		if (firstName == null || firstName == '' || lastName == null || lastName == '' || email == null || email == '' ||
				phone == NULL || phone == '' || preferredPhoneType == null || preferredPhoneType == '' || zipcode == null ||
				zipcode == '' || street == null || street == '' || city == null || city == '' || state == null || state == '' ||
				county == null || county == '' || birthMonth == null || birthMonth == '' || birthDay == null || birthDay == '' ||
				zipcode == null || zipcode == '' || onLinkedIn == null || onLinkedIn == '' || howHearAboutMAW == null ||
				howHearAboutMAW.isEmpty() || emergencyName == null || emergencyName == '' || emergencyRelationship == null ||
				emergencyRelationship == '' || emergencyPhone == null || emergencyPhone == '' || username == null ||
				username == '' || password == null || password == '' || confirmPassword == null || confirmPassword == ''

				) {
			errorMessage = 'Please fill out all required fields.';
			showErrorMsg = true;
			return null;
		}

		if (!validateEmail(email)) {
			errorMessage = 'Please enter a valid email address.';
			showErrorMsg = true;
			return null;
		}

		if (zipcode.length() > 5 || zipcode.length() < 5) {
			errorMessage = 'Please enter a 5 digit zip code.';
			showErrorMsg = true;
			return null;
		}

		if (!validateEmail(username)) {
			errorMessage = 'Please enter a valid username. Username must be in email format (name@domain.com).';
			showErrorMsg = true;
			return null;
		}

		if (!over18) {
			errorMessage = 'Thank you for your interest in volunteering with Make-A-Wish. Most volunteer opportunities are '
					+ 'designed for individuals over the age of 18. If you are under the age of 18,' +
					'please contact your local chapter to discuss what, if any, opportunities we currently have available.';
			showErrorMsg = true;
			return null;
		}

		/* Chris Shinnimin, Traction on Demand:
		 *
		 * This block of code is commented out because we have decided to handle contact duplicate detection during the
		 * volunteer signup process at a later date.
		 *
		 * See Jira ticket WLP-3 for more details.
		 *
		if (confirmedContactId == null || confirmedContactId == '') {
			matchedContacts = [SELECT FirstName, LastName FROM Contact WHERE email = :email];
			if (!matchedContacts.isEmpty()) {
				Integer countMatches = 0;
				matchedContactOptions = new List<SelectOption>();
				for (Contact matchedContact : matchedContacts) {
					countMatches++;
					if (countMatches > 5) break;
					matchedContactOptions.add(new SelectOption(matchedContact.Id, matchedContact.FirstName + ' ' + matchedContact.LastName));
				}
				matchedContactOptions.add(new SelectOption('~', 'None of these contacts are me'));
				confirmedContactId = '~';
				return null;
			}
		}
		*
		*
		*/

		String accountId;
		List<Zip_Code__c> getChapterName = [
				SELECT Office__c,Office__r.Chapter__c
				FROM Zip_Code__c
				WHERE Name = :zipcode
				LIMIT 1
		];

		if (getChapterName.size() > 0) {
			List<Account> getAccount = new List<Account>();
			if (getChapterName[0].Office__c != Null)
				getAccount = [
						SELECT id, Name, Timezone__c
						FROM Account
						WHERE Id = :getChapterName[0].Office__r.Chapter__c
						LIMIT 1
				];
			if (getAccount.size() > 0) {
				accountId = getAccount[0].id;
				timeZone = getAccount[0].timeZone__c;
			} else {
				List<Account> currAccount = [
						SELECT id, TimeZone__c
						FROM Account
						Where Name = 'Make-A-Wish America'
						LIMIT 1
				];

				if (!(currAccount.size() > 0)) {
					Account newAccount = new Account();
					newAccount.Name = 'Make-A-Wish America';
					newAccount.RecordTypeId = chapterRT;
					insert newAccount;
					accountId = newAccount.id;
				} else {
					accountId = currAccount[0].id;
					timeZone = currAccount[0].timeZone__c;
				}
			}
		} else {
			List<Account> currAccount = [
					SELECT id,timeZone__c
					FROM Account
					Where Name = 'Make-A-Wish America'
					LIMIT 1
			];

			if (!(currAccount.size() > 0)) {
				Account newAccount = new Account();
				newAccount.Name = 'Make-A-Wish America';
				newAccount.RecordTypeId = chapterRT;
				insert newAccount;
				accountId = newAccount.id;
			} else {
				accountId = currAccount[0].id;
				timeZone = currAccount[0].timeZone__c;
			}
		}

		String profileId = label.Prospective_Volunteer_Profile;
		List<User> checkExUser = [
				SELECT id
				FROM User
				WHERE Username = :username
		];
		if (checkExUser.size() > 0) {
			errorMessage = 'The username you provided is already in use. Please enter a different username to continue the sign up process. If you have already signed up, please click "Log In" to access the login page.';
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
			newUser.city = city;
			newUser.postalCode = zipCode;
			newUser.ProfileId = profileId;
			newUser.I_am_over_18_years_old__c = over18;
			newUser.created_from_portal__c = true;

			if (timeZoneMap.containsKey(timeZone)) {
				newUser.TimeZoneSidKey = timeZoneMap.get(timeZone);
			} else {
				newUser.TimeZoneSidKey = 'America/Los_Angeles';
			}

			try {
				if (confirmedContactId != null && confirmedContactId != '' && confirmedContactId != '~') {
					newUser.ContactId = confirmedContactId;
					newUser.LocaleSidKey = 'en_US';
					newUser.EmailEncodingKey = 'ISO-8859-1';
					newUser.LanguageLocaleKey = 'en_US';
					newUser.Alias = username.left(username.indexOf('@'));
					newUser.isActive = true;
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
								return Site.login(userName, password, '/VolunteerWelcomePage_VF');
							} else {
								PageReference page = System.Page.CommunitiesSelfRegConfirm;
								page.setRedirect(true);
								return page;
							}
						}
					}
				}
			} catch (Site.ExternalUserCreateException ex) {
				System.debug(ex);
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

	public static boolean validateEmail(string email) {
		String emailRegex = '([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})';
		Pattern MyPattern = Pattern.compile(emailRegex);
		Matcher MyMatcher = MyPattern.matcher(email);
		return MyMatcher.matches();
	}

	public List<SelectOption> getStates() {
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('', ''));
		Schema.DescribeFieldResult fieldResult = Lead.State_Picklist__c.getDescribe();
		List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
		for (Schema.PicklistEntry currVal : picklistValues) {
			options.add(new SelectOption(currVal.getLabel(), currVal.getValue()));
		}
		return options;
	}

	public List<SelectOption> getTitles() {
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('', ''));
		options.add(new SelectOption('Mr.', 'Mr.'));
		options.add(new SelectOption('Mrs.', 'Mrs.'));
		options.add(new SelectOption('Ms.', 'Ms.'));
		options.add(new SelectOption('Miss', 'Miss'));
		options.add(new SelectOption('Master', 'Master'));
		options.add(new SelectOption('Dr.', 'Dr.'));
		options.add(new SelectOption('Prof.', 'Prof.'));
		return options;
	}

	public List<SelectOption> getPreferredPhoneTypes() {
		List<SelectOption> options = new List<SelectOption>();
		Schema.DescribeFieldResult fieldResult = Contact.npe01__PreferredPhone__c.getDescribe();
		List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
		options.add(new SelectOption('', 'Select Type'));
		for (Schema.PicklistEntry currVal : picklistValues) {
			options.add(new SelectOption(currVal.getLabel(), currVal.getValue()));
		}
		return options;
	}

	public List<SelectOption> getOnLinkedInOptions() {
		List<SelectOption> options = new List<SelectOption>();
		Schema.DescribeFieldResult fieldResult = Contact.I_m_on_LinkedIn__c.getDescribe();
		List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
		options.add(new SelectOption('', 'Select'));
		for (Schema.PicklistEntry currVal : picklistValues) {
			options.add(new SelectOption(currVal.getLabel(), currVal.getValue()));
		}
		return options;
	}

	public List<SelectOption> getHearAboutMAWOptions() {
		List<SelectOption> options = new List<SelectOption>();
		Schema.DescribeFieldResult fieldResult = Contact.How_did_you_hear_about_Make_A_Wish__c.getDescribe();
		List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
		for (Schema.PicklistEntry currVal : picklistValues) {
			options.add(new SelectOption(currVal.getLabel(), currVal.getValue()));

		}
		return options;
	}

	public List<SelectOption> getContactAtWorkOptions() {
		List<SelectOption> options = new List<SelectOption>();
		Schema.DescribeFieldResult fieldResult = Contact.May_We_Contact_You_at_Work__c.getDescribe();
		List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
		options.add(new SelectOption('', 'Select'));
		for (Schema.PicklistEntry currVal : picklistValues) {
			options.add(new SelectOption(currVal.getLabel(), currVal.getValue()));
		}
		return options;
	}

	public List<SelectOption> getEmployerSharePowerOptions() {
		List<SelectOption> options = new List<SelectOption>();
		Schema.DescribeFieldResult fieldResult = Contact.Interested_involved_with_Make_A_Wish__c.getDescribe();
		List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
		options.add(new SelectOption('', 'Select'));
		for (Schema.PicklistEntry currVal : picklistValues) {
			options.add(new SelectOption(currVal.getLabel(), currVal.getValue()));
		}
		return options;
	}

	public List<SelectOption> getLanguages() {
		List<SelectOption> options = new List<SelectOption>();
		Schema.DescribeFieldResult fieldResult = Contact.Language__c.getDescribe();
		List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
		for (Schema.PicklistEntry currVal : picklistValues) {
			options.add(new SelectOption(currVal.getLabel(), currVal.getValue()));
		}
		return options;
	}

	public List<SelectOption> getProfessionalSkills() {
		List<SelectOption> options = new List<SelectOption>();
		Schema.DescribeFieldResult fieldResult = Contact.Professional_Skills__c.getDescribe();
		List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
		for (Schema.PicklistEntry currVal : picklistValues) {
			options.add(new SelectOption(currVal.getLabel(), currVal.getValue()));
		}
		return options;
	}

	public List<SelectOption> getEmergencyRelationships() {
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('', ''));
		Schema.DescribeFieldResult fieldResult = Contact.Emergency_Contact_Relationship__c.getDescribe();
		List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
		for (Schema.PicklistEntry currVal : picklistValues) {
			options.add(new SelectOption(currVal.getLabel(), currVal.getValue()));
		}
		return options;
	}

	public List<SelectOption> getBirthMonths() {
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('', ''));
		Schema.DescribeFieldResult fieldResult = Contact.Birth_Month__c.getDescribe();
		List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
		for (Schema.PicklistEntry currVal : picklistValues) {
			options.add(new SelectOption(currVal.getLabel(), currVal.getValue()));
		}
		return options;
	}

	public List<SelectOption> getBirthDays() {
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('', ''));
		Schema.DescribeFieldResult fieldResult = Contact.Birth_Day__c.getDescribe();
		List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
		for (Schema.PicklistEntry currVal : picklistValues) {
			options.add(new SelectOption(currVal.getLabel(), currVal.getValue()));
		}
		return options;
	}
}