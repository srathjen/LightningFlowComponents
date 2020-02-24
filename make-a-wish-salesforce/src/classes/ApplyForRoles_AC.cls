/**
 * Class ApplyForRoles_AC
 *
 * This page is a clone of the old Application_VF page with most fields removed such that it now only facilitates role
 * selection. This is part of the new vaolunteer signup process flow. See Jira ticket WLP-398 for details.
 *
 * @author Chris Shinnimin, Traction on Demand
 * @date 2019-09-03
 */
/*****************************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kanagaraj & Vennila
Date        : 5/23/2016
Location    : This class referred in the Application_VF page.
Description : This Application VF and Controller used to capture the volunteer details from the portal and Update
their corresponding volunteer details inside the salesforce.
In this page, volunteer role is displaying the values based on the  volunteer chapter roles. If the volunteer selects
the roles and hit [Save] button, It would update the value in Volunteer Role field as well as creating
Volunteer Role custom record.
If the user enters all the mandatory fields on the form and hit [Save] button, It will display [Submit & Sign] button
on the detailed mode. else [Submit & Sign] won't display.
If the user hits [Submit & Sign] button, It will redirect user to docusign page for capturing volunteer sign. Once sign completed,
It will create Conflict of Interst and Docusign status record with atttachment.
*******************************************************************************************************************/

public class ApplyForRoles_AC {
	Public contact currentVolunteer { get; set; }
	public boolean saveMode { get; set; }
	public boolean editMode { get; set; }
	public Id contactId;
	public Id currAccountId;
	public String applicationDynamicContent { get; set; }
	public Id volunteerRecordTypeId = Constant_AC.VOLUNTEER_RT_ID;
	public Id boardMemberContactRecTyped = Constant_AC.BOARD_MEMBER_RT_ID;
	public boolean isSigned { get; set; }
	public set<String> chaptersNameSet = new Set<String>();
	public boolean showSubmitandSign { get; set; }
	public list<string> volRoles { get; set; }
	public list<String> professionalSkillsList { get; set; }
	public list<String> langToRead { get; set; }
	public list<String> langToWrite { get; set; }
	public list<String> langToSpeak { get; set; }
	public list<String> langToUnderstand { get; set; }
	public list<String> languagesList { get; set; }
	public list<String> howKnowAbtMAWA { get; set; }
	public List<roleWrapper> roleDescriptionList { get; set; }
	public boolean displayPopup { get; set; }
	public boolean bgTabPermission { get; set; }
	public boolean trainingTabVisible { get; set; }
	public Boolean displaySignNowPopup { get; set; }
	public String contactName { get; set; }
	private Boolean updateContact { get; set; }

	public ApplyForRoles_AC() {
		List<string> LstLog = new List<string>();
		List<User> userIns = [
				SELECT Id, ContactId
				FROM User
				WHERE Id = :userInfo.getUserId()
		];
		contactId = userIns[0].contactId;
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
				SELECT id, Name, Title, Salutation,RecordTypeId,FirstName,Middle_Name__c,LastName,State_Employer__c,Preferred_Name__c,Birth_Month__c,Birth_Day__c,HomePhone,Alternate_Phone_Type__c,npe01__PreferredPhone__c,MobilePhone,
						OtherPhone,Email,I_m_on_LinkedIn__c,How_did_you_hear_about_Make_A_Wish__c,MailingStreet,MailingCity,mailingstatecode,MailingCountrycode,MailingPostalCode,
						Employer__c,Position__c,Street_Employer__c,City_Employer__c,Zip_Employer__c,May_We_Contact_You_at_Work__c,Interested_involved_with_Make_A_Wish__c,
						Emergency_Contact__c,Emergency_Contact_Phone__c,Professional_Skills__c,Language__c,Language_Notes__c,Read__c,Write__c,Speak__c,Understand__c,
						Volunteer_Role__c,is_Application__c,npe01__WorkPhone__c,MailingState,Emergency_Contact_Relationship__c,county__c,Professional_Skills_Other_Notes__c,
						How_did_you_know_MAWA_Other_Notes__c
				FROM Contact
				WHERE (RecordTypeId = :volunteerRecordTypeId OR RecordTypeId = :boardMemberContactRecTyped) AND Id = :contactId
		];

		currentVolunteer.mailingState = currentVolunteer.MailingState;
		currentVolunteer.Emergency_Contact_Relationship__c = currentVolunteer.Emergency_Contact_Relationship__c;
		currentVolunteer.State_Employer__c = currentVolunteer.State_Employer__c;
		currentVolunteer.I_m_on_LinkedIn__c = currentVolunteer.I_m_on_LinkedIn__c;
		currentVolunteer.May_We_Contact_You_at_Work__c = currentVolunteer.May_We_Contact_You_at_Work__c;
		currentVolunteer.Interested_involved_with_Make_A_Wish__c = currentVolunteer.Interested_involved_with_Make_A_Wish__c;
		currentVolunteer.Salutation = currentVolunteer.Salutation;
		currentVolunteer.Birth_Month__c = currentVolunteer.Birth_Month__c;
		if (currentVolunteer.Birth_Day__c != Null) {
			currentVolunteer.Birth_Day__c = currentVolunteer.Birth_Day__c;
		}
		contactName = currentVolunteer.Name;

		if (currentVolunteer.Volunteer_Role__c != null) {
			for (String role : currentVolunteer.Volunteer_Role__c.split(';')) {
				volRoles.add(role);
			}
		}

		if (ApexPages.currentPage().getParameters().get('event') == 'signing_complete' && currentVolunteer.Is_Application__c != 'Approved'
				&& currentVolunteer.Is_Application__c != 'Complete' && currentVolunteer.Is_Application__c != 'DocuSign Pending') {
			currentVolunteer.Is_Application__c = 'DocuSign Pending';
			updateContact = true;
		}

		if (signingStatus == 'signing_complete' || currentVolunteer.is_Application__c == 'DocuSign Pending'
				|| currentVolunteer.is_Application__c == 'Complete' || currentVolunteer.is_Application__c == 'Approved') {
			isSigned = true;
			editMode = true;
		} else if (currentVolunteer.is_Application__c == 'Submit' || currentVolunteer.is_Application__c == 'Fully Submit'
				|| currentVolunteer.is_Application__c == 'Partial Submit' || currentVolunteer.is_Application__c == 'Rejected') {
			isSigned = false;
			editMode = false;
			saveMode = true;
		}

		if (currentVolunteer.is_Application__c == '' || currentVolunteer.is_Application__c == null || showEdit == true) {
			saveMode = true;
		}

		for (npe5__Affiliation__c currContactAffiliation : [
				SELECT Id,npe5__Primary__c, npe5__Organization__c, npe5__Contact__c
				FROM npe5__Affiliation__c
				WHERE npe5__Contact__c = :contactId
		]) {
			if (currContactAffiliation.npe5__Primary__c == true) {
				currAccountId = currContactAffiliation.npe5__Organization__c;
			}
			chaptersNameSet.add(currContactAffiliation.npe5__Organization__c);
		}

		if (currAccountId != null) {
			String nationalRT = Constant_AC.NATIONAL_RT_ID;
			List<Dynamic_Content__c> dynamicContent = [
					SELECT Id,Application_Overview__c,Chapter_Name__c
					FROM Dynamic_Content__c
					WHERE Active__c = True AND RecordTypeId = :nationalRT
			];
			if (dynamicContent.size() > 0) {
				applicationDynamicContent = dynamicContent[0].Application_Overview__c;
			}
		}
	}

	// Temporary application status update until docusign comes back which will update status in a trigger
	public void updateToDocusignPending() {
		if (updateContact) {
			update currentVolunteer;
		}
	}

	public PageReference saveRec() {
		string Logvalue;
		string recId;
		try {
			if (volRoles != Null) {
				String roles = '';
				for (String s : (volRoles)) {
					roles += s + ';';
				}
				currentVolunteer.volunteer_role__c = roles.removeEnd(';');
			}

			PageReference pr;

			if (currentVolunteer.Volunteer_Role__c == null) {
				currentVolunteer.is_Application__c = 'Partial Submit';
			} else {
				currentVolunteer.is_Application__c = 'Fully Submit';
			}
			recId = currentVolunteer.id;
			update currentVolunteer;

			if (!displaySignNowPopup) {
				pr = new PageReference('/apex/ApplyForRoles_VF?showeditMode=true' + '&bgRequired=' + bgTabPermission + '&trainingRequired=' + trainingTabVisible);
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

	public pageReference confirmSign() {
		List<ProcessInstance> approvalIns = [
				SELECT TargetObjectId,Status,ProcessDefinitionId,ProcessDefinition.Name
				FROM ProcessInstance
				WHERE TargetObjectId = :currentVolunteer.Id AND Status = :'Pending'
		];
		if (approvalIns.size() > 0) {
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, ' This record is already in approval process'));
		} else {
			displaySignNowPopup = true;
			saveRec();
		}
		return null;
	}

	public Pagereference SubmitAndSign() {
		String account;
		String IntegratorKey;
		Map<String, DocuSignCredentialsSetting__c> credentialSetting = DocuSignCredentialsSetting__c.getAll();
		List<string> LstLog = new List<string>();
		String Logvalue;
		String recId;
		try {
			for (DocuSignCredentialsSetting__c credentialIns : credentialSetting.values()) {
				account = credentialIns.account__c;
				IntegratorKey = credentialIns.IntegratorKey__c;
			}

			String authorizationHeader = '<DocuSignCredentials><Username>{!$Credential.Username}</Username><Password>{!$Credential.Password}</Password><IntegratorKey>' + IntegratorKey + '</IntegratorKey></DocuSignCredentials>';
			String boundary = 'AAA';

			Pagereference PDF = Page.Application_PDF_VF;
			PDF.getParameters().put('id', currentVolunteer.id);

			String documentPDF = Test.IsRunningTest() ? 'TEST CONTENT' : EncodingUtil.base64Encode(PDF.getContentAsPDF());

			String body = '{' +
					'  "status":"sent",' +
					'  "enableWetSign": "false",' +
					'  "emailBlurb":"Volunteer Application Form",' +
					'  "emailSubject": "Volunteer Application Form",' +
					'  "enforceSignerVisibility":"True",' +
					'  "documents": [{' +
					'      "name": "document.pdf",' +
					'      "documentId":"1",' +
					'      "order":"1",' +
					'      "documentBase64":"' + documentPDF + '"' +
					'  }],' +
					'"recipients": {' +
					'    "signers" : [{' +
					'      "email": "' + currentVolunteer.email + '",' +
					'      "name": "' + currentVolunteer.FirstName + ' ' + currentVolunteer.LastName + '",' +
					'      "recipientId":"1",' +
					'      "clientUserId":"1",' +
					'      "tabs": {' +
					'                "signHereTabs": [{' +
					'                    "anchorString": "~s1",' +
					'                    "anchorXOffset": "0.1",' +
					'                    "anchorYOffset": "0.1",' +
					'                    "anchorIgnoreIfNotPresent": "false",' +
					'                    "anchorUnits": "inches"' +
					'                }],' +
					'                "dateSignedTabs": [{' +
					'                      "anchorString": "~date",' +
					'                       "anchorXOffset": "0",' +
					'                       "fontSize":      "Size14",' +
					'                       "fontColor":     "Black",' +
					'                       "fonttype":     "Helvetica",' +
					'                        "anchorYOffset": "0",' +
					'                        "anchorIgnoreIfNotPresent": "false",' +
					'                        "xPosition": "100",' +
					'                        "yPosition": "72",' +
					'                        "anchorUnits": "inches"' +
					'                    }]' +
					'            }' +
					'    }]' +
					'  }' +
					'}';

			String header = '--' + boundary + '\nContent-Type: application/json\nContent-Disposition: form-data';
			String jsonBody = header + '\n\n' + body + '\n\n--' + boundary + '--';
			//Callout to Docusign.
			HttpRequest req = new HttpRequest();
			req.setHeader('X-DocuSign-Authentication', authorizationHeader);
			req.setHeader('Accept', 'application/json');
			req.setHeader('Host', 'demo.docusign.net');
			req.setHeader('Content-Length', '162100');
			req.setHeader('Content-Type', 'multipart/form-data; boundary=' + boundary);
			req.setEndpoint('Callout:Docusign_Credential/accounts/' + account + '/envelopes');
			req.setMethod('POST');
			req.setBody(jsonBody);
			Http http = new Http();
			HTTPResponse res;

			res = http.send(req);
			if (res.getstatusCode() != 200 && res.getstatusCode() != 201) {
				displaySignNowPopup = false;
				new ApexDebugLog().createLog(new ApexDebugLog.Error('Application_AC', 'SubmitAndSign', recId, null, res.getBody()));
				ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
				ApexPages.addMessage(myMsg);
				return null;
			} else {
				Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
				if ((String) results.get('envelopeId') != '') {
					String env = (String) results.get('envelopeId');
					HttpRequest request = new HttpRequest();
					request.setHeader('X-DocuSign-Authentication', authorizationHeader);
					request.setHeader('Accept', 'application/json');
					request.setHeader('Host', 'demo.docusign.net');
					request.setHeader('Content-Length', '162100');
					request.setHeader('Content-Type', 'application/json');
					request.setMethod('POST');
					Http httprequest = new Http();
					HTTPResponse response;
					request.setEndpoint('Callout:Docusign_Credential/accounts/' + account + '/envelopes/' + env + '/views/recipient');
					string jsonPayload;
					jsonPayload = '{' +
							'    "userName": "' + currentVolunteer.FirstName + ' ' + currentVolunteer.LastName + '",' +
							'    "email": "' + currentVolunteer.email + '",' +
							'    "recipientId": "1",' +
							'    "clientUserId": "1",' +
							'    "authenticationMethod": "None",' +
							'    "returnUrl": "' + label.Site_Url + '/ApplyForRoles_VF"' +
							'}';
					request.setBody(jsonPayload);
					response = httprequest.send(request);
					if (response.getstatusCode() != 200 && response.getstatusCode() != 201) {
						displaySignNowPopup = false;
						ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
						ApexPages.addMessage(myMsg);
						return null;
					} else {
						results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
						if ((String) results.get('url') != '' || (String) results.get('url') != null) {
							dsfs__DocuSign_Status__c dsfs = NEW dsfs__DocuSign_Status__c();
							dsfs.dsfs__DocuSign_Envelope_ID__c = env;
							dsfs.Docusign_Hidden_Contact__c = currentVolunteer.id;
							Insert dsfs;

							if (dsfs.id != null) {
								currentVolunteer.is_Application__c = 'Submit';
								currentVolunteer.Onboarding_Status__c = 'Application';
								if (!Test.isRunningTest()) {
									recId = currentVolunteer.Id;
									update currentVolunteer;
								}
							}

							PageReference reference = new PageReference((String) results.get('url'));
							reference.setRedirect(true);
							return reference;
						}
					}
				}
			}
		} catch (Exception ex) {
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
			ApexPages.addMessage(myMsg);
			System.debug(ex);
			return null;
		}
		return null;
	}

	/*The current volunteer contact can edit their details using this EditRec().*/
	public PageReference EditRec() {
		PageReference pr ;
		pr = new PageReference('/apex/ApplyForRoles_VF?showeditMode=True' + '&bgRequired=' + bgTabPermission + '&trainingRequired=' + trainingTabVisible);
		pr.setRedirect(true);
		return pr;
	}

	/*To display the state value of current logged in volunteer contact in community.*/
	public List<SelectOption> getStates() {
		List<SelectOption> options = new List<SelectOption>();
		Schema.DescribeFieldResult fieldResult = Lead.State_Picklist__c.getDescribe();
		List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
		options.add(new SelectOption('', 'Please select state'));
		for (Schema.PicklistEntry currVal : picklistValues) {
			options.add(new SelectOption(currVal.getLabel(), currVal.getValue()));
		}
		return options;
	}

	public List<SelectOption> getRoles() {
		List<SelectOption> options = new List<SelectOption>();
		for (Chapter_Role__c currRole : [
				SELECT ID,Role_Name__c,Role_Name__r.Name,Role_Name__r.Description__c,Role_Name__r.Exclude_from_Application__c
				FROM Chapter_Role__c
				WHERE Chapter_name__c IN:chaptersNameSet AND Role_Name__r.Exclude_from_Application__c = False
		]) {
			if (currRole.Role_Name__c != Null) {
				options.add(new SelectOption(currRole.Role_Name__r.name, currRole.Role_Name__r.name));
			}
		}
		options.sort();
		return options;
	}

	// Displaying the Role Description on the Application Page.
	public void DisplayDescription() {
		try {
			displayPopup = true;
			roleDescriptionList = new List<roleWrapper>();
			for (Chapter_Role__c currRole : [
					SELECT ID, Role_Name__r.Name,Role_Name__r.Description__c,Role_Name__r.Exclude_from_Application__c
					FROM Chapter_Role__c
					WHERE Chapter_name__c IN :chaptersNameSet AND Role_Name__r.Exclude_from_Application__c = False
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

	public void ClosePopUp() {
		displayPopup = false;
	}

	@testVisible
	public class roleWrapper {
		public string roleName { get; set; }
		public string roleDescription { get; set; }
	}

	public void hidePopup() {
		displaySignNowPopup = false;
	}

	public PageReference redirectToHome() {
		PageReference pr ;
		pr = new PageReference('/VolunteerWelcomePage_VF');
		pr.setRedirect(true);
		return pr;
	}
}