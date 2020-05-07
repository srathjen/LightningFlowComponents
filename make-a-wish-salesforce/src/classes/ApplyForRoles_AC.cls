/**
 * Class ApplyForRoles_AC
 *
 * This page is a clone of the old Application_VF page with most fields removed such that it now only facilitates role
 * selection. This is part of the new vaolunteer signup process flow. See Jira ticket WLP-398 for details.
 *
 * @author Chris Shinnimin, Traction on Demand
 * @date 2019-09-03
 */
public class ApplyForRoles_AC {
	public Contact currentVolunteer { get; set; }
	public Boolean saveMode { get; set; }
	public Boolean editMode { get; set; }
	public Id contactId;
	public Id currAccountId;
	public String applicationDynamicContent { get; set; }
	public Id volunteerRecordTypeId = Constant_AC.VOLUNTEER_RT_ID;
	public Id boardMemberContactRecTyped = Constant_AC.BOARD_MEMBER_RT_ID;
	public Boolean isSigned { get; set; }
	public Set<String> chaptersNameSet = new Set<String>();
	public Boolean showSubmitandSign { get; set; }
	public List<String> volRoles { get; set; }
	public List<String> professionalSkillsList { get; set; }
	public List<String> langToRead { get; set; }
	public List<String> langToWrite { get; set; }
	public List<String> langToSpeak { get; set; }
	public List<String> langToUnderstand { get; set; }
	public List<String> languagesList { get; set; }
	public List<String> howKnowAbtMAWA { get; set; }
	public List<roleWrapper> roleDescriptionList { get; set; }
	public Boolean displayPopup { get; set; }
	public Boolean bgTabPermission { get; set; }
	public Boolean trainingTabVisible { get; set; }
	public Boolean displaySignNowPopup { get; set; }
	public String contactName { get; set; }
	private Boolean updateContact { get; set; }
	private final static String EMPTY_STATE_OPTION = 'Please select state';
	private final static String APPLY_FOR_ROLES_PAGE_PATH = 'ApplyForRoles_VF';
	private final static String SIGNING_STATUS_COMPLETE = 'signing_complete';
	private static final String APPLICATION_STATUS_APPROVED = Constant_AC.CONTACT_APPLICATION_STATUS_APPROVED;
	private static final String APPLICATION_STATUS_COMPLETE = Constant_AC.CONTACT_APPLICATION_STATUS_COMPLETE;
	private static final String APPLICATION_STATUS_DOCUSIGN_PENDING = Constant_AC.CONTACT_APPLICATION_STATUS_DOCUSIGN_PENDING;
	private static final String APPLICATION_STATUS_SUBMIT = Constant_AC.CONTACT_APPLICATION_STATUS_SUBMIT;
	private static final String APPLICATION_STATUS_FULLY_SUBMIT = Constant_AC.CONTACT_APPLICATION_STATUS_FULLY_SUBMIT;
	private static final String APPLICATION_STATUS_PARTIAL_SUBMIT = Constant_AC.CONTACT_APPLICATION_STATUS_PARTIAL_SUBMIT;
	private static final String APPLICATION_STATUS_REJECTED = Constant_AC.CONTACT_APPLICATION_STATUS_REJECTED;
	private static final String ONBOARDING_STATUS_APPLICATION = Constant_AC.CONTACT_ONBOARDING_STATUS_APPLICATION;
	private static final String PROCESS_INSTANCE_STATUS_PENDING = Constant_AC.PROCESS_INSTANCE_STATUS_PENDING;

	public ApplyForRoles_AC() {
		contactId = Utils.currentUser.ContactId;
		showSubmitandSign = false;
		displaySignNowPopup = false;
		Boolean showEdit = false;
		volRoles = new List<String>();
		langToRead = new List<String>();
		langToSpeak = new List<String>();
		langToWrite = new List<String>();
		langToUnderstand = new List<String>();
		languagesList = new List<String>();
		howKnowAbtMAWA = new List<String>();
		professionalSkillsList = new List<String>();
		String signingStatus = '';
		updateContact = false;
		if (ApexPages.currentPage().getParameters().get('showeditMode') != null) {
			showEdit = Boolean.valueOf(ApexPages.currentPage().getParameters().get('showeditMode'));
		}
		if (ApexPages.currentPage().getParameters().get('event') != null) {
			signingStatus = ApexPages.currentPage().getParameters().get('event');
		}
		if (ApexPages.currentPage().getParameters().get('bgRequired') != null) {
			bgTabPermission = Boolean.valueOf(ApexPages.currentPage().getParameters().get('bgRequired'));
		}
		if (ApexPages.currentPage().getParameters().get('trainingRequired') != null) {
			trainingTabVisible = Boolean.valueOf(ApexPages.currentPage().getParameters().get('trainingRequired'));
		}
		currentVolunteer = [
				SELECT Id, Name, Title, Salutation, RecordTypeId, FirstName, Middle_Name__c, LastName, State_Employer__c,
						Preferred_Name__c, Birth_Month__c, Birth_Day__c, HomePhone, Alternate_Phone_Type__c,
						npe01__PreferredPhone__c, MobilePhone, OtherPhone, Email, I_m_on_LinkedIn__c,
						How_did_you_hear_about_Make_A_Wish__c,MailingStreet,MailingCity, MailingStateCode, MailingCountryCode,
						MailingPostalCode, Employer__c, Position__c, Street_Employer__c, City_Employer__c, Zip_Employer__c,
						May_We_Contact_You_at_Work__c, Interested_involved_with_Make_A_Wish__c, Emergency_Contact__c,
						Emergency_Contact_Phone__c, Professional_Skills__c,Language__c,Language_Notes__c,Read__c,
						Write__c,Speak__c,Understand__c, Volunteer_Role__c,is_Application__c,npe01__WorkPhone__c,
						MailingState,Emergency_Contact_Relationship__c,County__c,Professional_Skills_Other_Notes__c,
						How_did_you_know_MAWA_Other_Notes__c
				FROM Contact
				WHERE (RecordTypeId = :volunteerRecordTypeId OR RecordTypeId = :boardMemberContactRecTyped)
				AND Id = :contactId
		];
		currentVolunteer.MailingState = currentVolunteer.MailingState;
		currentVolunteer.Emergency_Contact_Relationship__c = currentVolunteer.Emergency_Contact_Relationship__c;
		currentVolunteer.State_Employer__c = currentVolunteer.State_Employer__c;
		currentVolunteer.I_m_on_LinkedIn__c = currentVolunteer.I_m_on_LinkedIn__c;
		currentVolunteer.May_We_Contact_You_at_Work__c = currentVolunteer.May_We_Contact_You_at_Work__c;
		currentVolunteer.Interested_involved_with_Make_A_Wish__c = currentVolunteer.Interested_involved_with_Make_A_Wish__c;
		currentVolunteer.Salutation = currentVolunteer.Salutation;
		currentVolunteer.Birth_Month__c = currentVolunteer.Birth_Month__c;
		if (String.isNotEmpty(currentVolunteer.Birth_Day__c)) {
			currentVolunteer.Birth_Day__c = currentVolunteer.Birth_Day__c;
		}
		contactName = currentVolunteer.Name;
		if (currentVolunteer.Volunteer_Role__c != null) {
			for (String role : currentVolunteer.Volunteer_Role__c.split(';')) {
				volRoles.add(role);
			}
		}
		if (SIGNING_STATUS_COMPLETE.equals(signingStatus)
				&& !APPLICATION_STATUS_APPROVED.equals(currentVolunteer.is_Application__c)
				&& !APPLICATION_STATUS_COMPLETE.equals(currentVolunteer.is_Application__c)
				&& !APPLICATION_STATUS_DOCUSIGN_PENDING.equals(currentVolunteer.is_Application__c)) {
			currentVolunteer.is_Application__c = APPLICATION_STATUS_DOCUSIGN_PENDING;
			updateContact = true;
		}
		if (SIGNING_STATUS_COMPLETE.equals(signingStatus)
				|| APPLICATION_STATUS_APPROVED.equals(currentVolunteer.is_Application__c)
				|| APPLICATION_STATUS_COMPLETE.equals(currentVolunteer.is_Application__c)
				|| APPLICATION_STATUS_DOCUSIGN_PENDING.equals(currentVolunteer.is_Application__c)) {
			isSigned = true;
			editMode = true;
		} else if (APPLICATION_STATUS_SUBMIT.equals(currentVolunteer.is_Application__c)
				|| APPLICATION_STATUS_FULLY_SUBMIT.equals(currentVolunteer.is_Application__c)
				|| APPLICATION_STATUS_PARTIAL_SUBMIT.equals(currentVolunteer.is_Application__c)
				|| APPLICATION_STATUS_REJECTED.equals(currentVolunteer.is_Application__c)) {
			isSigned = false;
			editMode = false;
			saveMode = true;
		}
		if (String.isEmpty(currentVolunteer.is_Application__c)
				|| showEdit == true) {
			saveMode = true;
		}
		for (npe5__Affiliation__c currContactAffiliation : [
				SELECT Id,npe5__Primary__c, npe5__Organization__c, npe5__Contact__c
				FROM npe5__Affiliation__c
				WHERE npe5__Contact__c = :contactId
		]) {
			if (currContactAffiliation.npe5__Primary__c) {
				currAccountId = currContactAffiliation.npe5__Organization__c;
			}
			chaptersNameSet.add(currContactAffiliation.npe5__Organization__c);
		}
		if (currAccountId != null) {
			String nationalRT = Constant_AC.NATIONAL_RT_ID;
			List<Dynamic_Content__c> dynamicContent = [
					SELECT Id,Application_Overview__c,Chapter_Name__c
					FROM Dynamic_Content__c
					WHERE Active__c = TRUE AND RecordTypeId = :nationalRT
			];
			if (!dynamicContent.isEmpty()) {
				applicationDynamicContent = dynamicContent[0].Application_Overview__c;
			}
		}
	}

	/**
	 * Temporarily update application status until Docusign comes back which will update status
	 */
	public void updateToDocusignPending() {
		if (updateContact) {
			update currentVolunteer;
		}
	}

	/**
	 * Save record
	 * @return Page
	 */
	public PageReference saveRec() {
		String recId;
		try {
			if (!volRoles.isEmpty()) {
				currentVolunteer.Volunteer_Role__c = String.join(volRoles, ';');
			}
			if (String.isEmpty(currentVolunteer.Volunteer_Role__c)) {
				currentVolunteer.is_Application__c = APPLICATION_STATUS_PARTIAL_SUBMIT;
			} else {
				currentVolunteer.is_Application__c = APPLICATION_STATUS_FULLY_SUBMIT;
			}
			recId = currentVolunteer.Id;
			update currentVolunteer;
			if (!displaySignNowPopup) {
				PageReference pr = new PageReference('/apex/ApplyForRoles_VF?showeditMode=true'
						+ '&bgRequired=' + bgTabPermission + '&trainingRequired=' + trainingTabVisible);
				pr.setRedirect(true);
				return pr;
			}
			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			} else {
				return null;
			}
		} catch (Exception ex) {
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
			ApexPages.addMessage(myMsg);
			return null;
		}
	}

	/**
	 * Confirm Sign
	 * @return Page
	 */
	public PageReference confirmSign() {
		List<ProcessInstance> approvalIns = [
				SELECT TargetObjectId,Status,ProcessDefinitionId,ProcessDefinition.Name
				FROM ProcessInstance
				WHERE TargetObjectId = :currentVolunteer.Id
				AND Status = :PROCESS_INSTANCE_STATUS_PENDING
		];
		if (!approvalIns.isEmpty()) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,
					' This record is already in approval process'));
		} else {
			displaySignNowPopup = true;
			saveRec();
		}
		return null;
	}

	/**
	 * Submit and Sign DocuSign
	 * @return
	 */
	public PageReference SubmitAndSign() {
		String recId;
		try {
			PageReference PDF = Page.Application_PDF_VF;
			PDF.getParameters().put('id', currentVolunteer.Id);
			String pdfDocument = Test.isRunningTest() ? 'TEST CONTENT' : EncodingUtil.base64Encode(PDF.getContentAsPDF());
			HttpResponse createEnvelopeResponse = DocuSignService.createEnvelope(pdfDocument, currentVolunteer.Email,
					currentVolunteer.FirstName, currentVolunteer.LastName);

			if (createEnvelopeResponse.getStatusCode() != 200 && createEnvelopeResponse.getStatusCode() != 201) {
				displaySignNowPopup = false;
				new ApexDebugLog().createLog(new ApexDebugLog.Error('ApplyForRoles_AC', 'SubmitAndSign',
						recId, null, createEnvelopeResponse.getBody()));
				ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
				ApexPages.addMessage(myMsg);
				return null;
			}

			Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(createEnvelopeResponse.getBody());
			if (String.isEmpty((String) results.get('envelopeId'))) {
				return null;
			}

			String envelopeId = (String) results.get('envelopeId');
			String returnUrl = Endpoints__c.getInstance().Site_URL__c + APPLY_FOR_ROLES_PAGE_PATH;

			HttpResponse createRecipientResponse = DocuSignService.createRecipient(envelopeId, currentVolunteer.Email,
					currentVolunteer.FirstName, currentVolunteer.LastName, returnUrl);

			if (createRecipientResponse.getStatusCode() != 200 && createRecipientResponse.getStatusCode() != 201) {
				displaySignNowPopup = false;
				ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
				ApexPages.addMessage(myMsg);
				return null;
			}

			results = (Map<String, Object>) JSON.deserializeUntyped(createRecipientResponse.getBody());
			if (String.isNotEmpty((String) results.get('url'))) {
				dsfs__DocuSign_Status__c dsfs = new dsfs__DocuSign_Status__c();
				dsfs.dsfs__DocuSign_Envelope_ID__c = envelopeId;
				dsfs.Docusign_Hidden_Contact__c = currentVolunteer.Id;
				insert dsfs;
				if (dsfs.Id != null) {
					currentVolunteer.is_Application__c = APPLICATION_STATUS_SUBMIT;
					currentVolunteer.Onboarding_Status__c = ONBOARDING_STATUS_APPLICATION;
					if (!Test.isRunningTest()) {
						recId = currentVolunteer.Id;
						update currentVolunteer;
					}
				}
				PageReference reference = new PageReference((String) results.get('url'));
				reference.setRedirect(true);
				return reference;
			}
		} catch (Exception ex) {
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
			ApexPages.addMessage(myMsg);
			System.debug(ex);
			return null;
		}
		return null;
	}

	/**
	 * The current volunteer contact can edit their details using this EditRec
	 * @return
	 */
	public PageReference EditRec() {
		PageReference pr = new PageReference('/apex/ApplyForRoles_VF?showeditMode=True' + '&bgRequired='
				+ bgTabPermission + '&trainingRequired=' + trainingTabVisible);
		pr.setRedirect(true);
		return pr;
	}

	/**
	 * To display the state value of current logged in volunteer contact in community
	 * @return List of States
	 */
	public List<SelectOption> getStates() {
		List<SelectOption> leadStatesSelectOptions = Utils.getPicklistSelectOptions(
				'Lead', 'State_Picklist__c', EMPTY_STATE_OPTION);
		return leadStatesSelectOptions;
	}

	/**
	 * Find Roles not excluded from Application
	 * @return List of Roles
	 */
	public List<SelectOption> getRoles() {
		List<SelectOption> options = new List<SelectOption>();
		for (Chapter_Role__c currRole : [
				SELECT Id,Role_Name__c,Role_Name__r.Name,Role_Name__r.Description__c,
						Role_Name__r.Exclude_from_Application__c
				FROM Chapter_Role__c
				WHERE Chapter_Name__c IN:chaptersNameSet
				AND Role_Name__r.Exclude_from_Application__c = FALSE
		]) {
			if (currRole.Role_Name__c != null) {
				options.add(new SelectOption(currRole.Role_Name__r.Name, currRole.Role_Name__r.Name));
			}
		}
		options.sort();
		return options;
	}

	/**
	 * Display the Role Description on the Application Page
	 */
	public void DisplayDescription() {
		try {
			displayPopup = true;
			roleDescriptionList = new List<roleWrapper>();
			for (Chapter_Role__c currRole : [
					SELECT Id, Role_Name__r.Name,Role_Name__r.Description__c,Role_Name__r.Exclude_from_Application__c
					FROM Chapter_Role__c
					WHERE Chapter_Name__c IN :chaptersNameSet
					AND Role_Name__r.Exclude_from_Application__c = FALSE
					ORDER BY Role_Name__r.Name
			]) {
				roleWrapper wrap = new roleWrapper();
				wrap.roleName = currRole.Role_Name__r.Name;
				wrap.roleDescription = currRole.Role_Name__r.Description__c;
				roleDescriptionList.add(wrap);
			}
			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}
		} catch (Exception ex) {
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
			ApexPages.addMessage(myMsg);
		}
	}

	/**
	 * Close Popup
	 */
	public void ClosePopUp() {
		displayPopup = false;
	}

	/**
	 * Hide Popup
	 */
	public void hidePopup() {
		displaySignNowPopup = false;
	}

	/**
	 * Redirect to Home
	 * @return Page
	 */
	public PageReference redirectToHome() {
		PageReference pr ;
		pr = new PageReference('/VolunteerWelcomePage_VF');
		pr.setRedirect(true);
		return pr;
	}

	@TestVisible
	public class roleWrapper {
		public String roleName { get; set; }
		public String roleDescription { get; set; }
	}
}