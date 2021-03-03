/**
 * Author :            MST Solutions
 * Description :       This class referred in the LeadSelectMedEmail_VF.Intake form contains
 * both treating medical professional and best contact for physicians
 * Then the user must select who have received DV form.
 * Modification logs:
 * 1. 12/4/2018 Yuvraj IME-77 Line No: 40,117
 * 2. 10/5/2018 Vignesh IME 122
 * 3. 10/05/2018 Yuvraj IME-126 Line No: 113
 * 4. 08/07/2019 - Samer - SIW-274: Update Lead Diagnosis Verification Received with
 * the date DV was signed
 * 5. 09/10/2019 - Manik - WLP-423
 * 6. 1/2/2020 - CSmith - SIW-342 - field name changes reverted
 * 7. 11/9/2020 - Gus - ODP-16
 * 8. 12/30/2020 - Michelle - ODP-176
 * 9. 3-march-2021 - Pramod - DVS-166
 **/
public class LeadSelectMedEmailController_AC {
	public Boolean success { get; set; }
	public Boolean isSend { get; set; }
	public Lead currLead { get; set; }
	public String URLToRedirect { get; set; }
	public List<SendDiagnosisWrapper> contacts { get; set; }
	public String log;
	public String recId;
    	public Boolean doNotContact { get; set; }
	private static final String REFERRING_MEDICAL_PROFESSIONAL = Constant_AC.LEAD_DV_FORM_TYPE_REFERRING_MEDICAL_PROFESSIONAL;
	private static final String TREATING_MEDICAL_PROFESSIONAL = Constant_AC.LEAD_DV_FORM_TYPE_TREATING_MEDICAL_PROFESSIONAL;
	private static final String ALTERNATE_1_MEDICAL_PROFESSIONAL = Constant_AC.LEAD_DV_FORM_TYPE_ALTERNATE_1_MEDICAL_PROFESSIONAL;
	private static final String ALTERNATE_2_MEDICAL_PROFESSIONAL = Constant_AC.LEAD_DV_FORM_TYPE_ALTERNATE_2_MEDICAL_PROFESSIONAL;
	private static final String RELATIONSHIP_MEDICAL_PROFESSIONAL = Constant_AC.LEAD_RELATIONSHIP_TO_CHILD_MEDICAL_PROFESSIONAL;

	public LeadSelectMedEmailController_AC() {
		currLead = findLead(ApexPages.currentPage().getParameters().get('id'));
		contacts = findContacts(currLead);
	}
        
    /**
    * @description Checks if the selected contact is marked Deceased or Do Not Contact
    */
    public void checkContactStatus() {
        doNotContact = false;
        String contactId = ApexPages.currentPage().getParameters().get('contactid');
        List<Contact> mpContact = new List<Contact>([
            SELECT Id, npsp__Do_Not_Contact__c, npsp__Deceased__c 
            FROM Contact 
            WHERE Id = :contactId
        ]);
        if(!mpContact.isEmpty() && (mpContact[0].npsp__Do_Not_Contact__c || mpContact[0].npsp__Deceased__c)) {
            doNotContact = true;
        }
    }

	/**
	 * @description Update Lead medical professional type
	 */
	public void sendDiagnosisVerification() {
		try {
			if (ApexPages.currentPage().getParameters().get('action').equals('returnToLead')) {
				isSend = false;
				success = true;
			} else if (ApexPages.currentPage().getParameters().get('action').equals('sendDv')) {
				isSend = true;
				DiagnosisVerificationService.deleteByLeadId(currLead.Id);
				LeadService.resetLead(currLead);
				URLToRedirect = Endpoints__c.getInstance().Instance_URL__c + '/' + currLead.Id;
				currLead.HiddenMedicalProfessionalEmail__c = ApexPages.currentPage().getParameters().get('email');
				currLead.Hidden_DV_form_Medical_professional_Type__c = ApexPages.currentPage().getParameters().get('type');
				currLead.Sub_Status__c = Constant_AC.LEAD_SUB_STATUS_PENDING_DIAGNOSIS_VERIFICATION;
				currLead.Pending_Diagnosis_Date__c = Date.today();
				if (currLead.Of_Times_Email_Sent__c == null) {
					currLead.Of_Times_Email_Sent__c = 0;
					currLead.First_DV_Sent_Date__c = Date.today();
				} else {
					currLead.Of_Times_Email_Sent__c = currLead.Of_Times_Email_Sent__c + 1;
					currLead.DV_Reminder_Last_Sent_Date__c = null;
					currLead.Last_DV_Save_Date__c = null;
				}
				update currLead;
				DiagnosisVerificationService.processSendDiagnosisVerification(currLead, currLead.HiddenMedicalProfessionalEmail__c);
				success = true;
			}
		} catch (Exception ex) {
			success = false;
			new ApexDebugLog().createLog(new ApexDebugLog.Error(
					'LeadSelectMedEmailController_AC', 'updateLead', currLead.Id, ex, String.valueOf(currLead)));
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
			ApexPages.addMessage(myMsg);
		}
	}

	/**
	 * @description Redirect to Lead detail page.
	 * @return Page Reference
	 */
	public PageReference GoToLeadViewPage() {
		PageReference page = new PageReference('/' + currLead.Id);
		return page;
	}

	private Lead findLead(Id leadId) {
		return [
				SELECT Id, FirstName, ChapterName__c, Part_A_Form_Password__c, Part_A_Sent__c,
						Part_A_Received__c, Using_Paper_Process_For_DV__c, Relationship_to_child__c,
						HiddenMedicalProfessionalEmail__c, Of_Times_Email_Sent__c, Referring_MP__c,
						Referring_MP__r.Name, Referring_MP__r.npe01__WorkEmail__c,
						Referring_MP__r.npe01__AlternateEmail__c, Referring_MP__r.Alternate_Email_2__c,
						Referring_MP_Email__c, Referring_MP__r.Contact_Notes__c, Treating_MP__c, Treating_MP__r.Name,
						Treating_MP__r.npe01__WorkEmail__c, Treating_MP__r.npe01__AlternateEmail__c,
						Treating_MP__r.Alternate_Email_2__c, Treating_Medical_Professional_Email__c,
						Treating_MP__r.Contact_Notes__c, Best_Contact__c, Best_Contact__r.Name,
						Best_Contact__r.npe01__WorkEmail__c, Best_Contact__r.npe01__AlternateEmail__c,
						Best_Contact__r.Alternate_Email_2__c, Best_contact_for_Physician_Email__c, Best_Contact__r.Contact_Notes__c,
						Alt_1_MP__c, Alt_1_MP__r.Name, Alt_1_MP__r.npe01__WorkEmail__c, Alt_1_MP__r.npe01__AlternateEmail__c,
						Alt_1_MP__r.Alternate_Email_2__c, Alt_1_MP__r.Contact_Notes__c, Alt_2_MP__c,
						Alt_2_MP__r.Name, Alt_2_MP__r.npe01__WorkEmail__c, Alt_2_MP__r.npe01__AlternateEmail__c,
						Alt_2_MP__r.Alternate_Email_2__c, Alt_2_MP__r.Contact_Notes__c, Hidden_DV_Form_Name__c,
						Hidden_Potential_Rush__c, Status, Diagnosis_Given_By_Referrer__c, ICD_Given_By_Referrer__c,
						PD_Condition_Description__c, PD_ICD_Code__c,Does_Child_Have_Cognitive_Delays__c,
						Does_Child_Have_Speech_or_Language_Delay__c,Non_Verbal_Communication_Method__c,
						Non_Verbal_Additional_Information__c,Non_Verbal__c,Referring_MP_Last_Name__c,
						Treating_Medical_Professional_Last_Name__c,Best_Contact_for_Physician_Last_Name__c
				FROM Lead
				WHERE Id = :leadId
		];
	}

	private List<SendDiagnosisWrapper> findContacts(Lead lead) {
		contacts = new List<SendDiagnosisWrapper>();
		Boolean displayReferringContactInformation = true;
		if (lead.Referring_MP__c == lead.Treating_MP__c) {
			displayReferringContactInformation = false;
		} else if (lead.Referring_MP__c == lead.Best_Contact__c) {
			displayReferringContactInformation = false;
		}
		if (lead.Referring_MP__c != null && displayReferringContactInformation
				&& (String.isNotEmpty(lead.Referring_MP__r.npe01__WorkEmail__c)
				|| String.isNotEmpty(lead.Referring_MP__r.npe01__AlternateEmail__c)
				|| String.isNotEmpty(lead.Referring_MP__r.Alternate_Email_2__c)
				|| String.isNotEmpty(lead.Referring_MP_Email__c))) {
			SendDiagnosisWrapper referringMp = new SendDiagnosisWrapper();
			referringMp.id = lead.Referring_MP__c;
			referringMp.name = lead.Referring_MP__r.Name;
			referringMp.type = REFERRING_MEDICAL_PROFESSIONAL;
			referringMp.hiddenDvFormMedicalProfessionalType = Constant_AC.LEAD_DV_FORM_TYPE_REFERRING_MEDICAL_PROFESSIONAL;
			if (String.isNotEmpty(lead.Referring_MP__r.npe01__WorkEmail__c)) {
				referringMp.workEmail = lead.Referring_MP__r.npe01__WorkEmail__c;
			}
			if (String.isNotEmpty(lead.Referring_MP__r.npe01__AlternateEmail__c)) {
				referringMp.alternateEmail1 = lead.Referring_MP__r.npe01__AlternateEmail__c;
			}
			if (String.isNotEmpty(lead.Referring_MP__r.Alternate_Email_2__c)) {
				referringMp.alternateEmail2 = lead.Referring_MP__r.Alternate_Email_2__c;
			}
			if (String.isNotEmpty(lead.Referring_MP__r.Contact_Notes__c)) {
				referringMp.contactNotes = lead.Referring_MP__r.Contact_Notes__c;
			}
			if (String.isNotEmpty(lead.Referring_MP_Email__c) && String.isBlank(lead.Referring_MP_Last_Name__c)) {
				referringMp.newEmailProvided = lead.Referring_MP_Email__c;
			}
			referringMp.numProvidedEmails = countNumberOfEmailsProvided(referringMp);
			contacts.add(referringMp);
		}
		if (lead.Treating_MP__c != null && (String.isNotEmpty(lead.Treating_MP__r.npe01__WorkEmail__c)
				|| String.isNotEmpty(lead.Treating_MP__r.npe01__AlternateEmail__c)
				|| String.isNotEmpty(lead.Treating_MP__r.Alternate_Email_2__c)
				|| String.isNotEmpty(lead.Treating_Medical_Professional_Email__c))) {
			SendDiagnosisWrapper treatingMp = new SendDiagnosisWrapper();
			treatingMp.id = lead.Treating_MP__c;
			treatingMp.name = lead.Treating_MP__r.Name;
			treatingMp.type = TREATING_MEDICAL_PROFESSIONAL;
			treatingMp.hiddenDvFormMedicalProfessionalType = Constant_AC.LEAD_DV_FORM_TYPE_TREATING_MEDICAL_PROFESSIONAL;
			if (String.isNotEmpty(lead.Treating_MP__r.npe01__WorkEmail__c)) {
				treatingMp.workEmail = lead.Treating_MP__r.npe01__WorkEmail__c;
			}
			if (String.isNotEmpty(lead.Treating_MP__r.npe01__AlternateEmail__c)) {
				treatingMp.alternateEmail1 = lead.Treating_MP__r.npe01__AlternateEmail__c;
			}
			if (String.isNotEmpty(lead.Treating_MP__r.Alternate_Email_2__c)) {
				treatingMp.alternateEmail2 = lead.Treating_MP__r.Alternate_Email_2__c;
			}
			if (String.isNotEmpty(lead.Treating_MP__r.Contact_Notes__c)) {
				treatingMp.contactNotes = lead.Treating_MP__r.Contact_Notes__c;
			}
			if (String.isNotEmpty(lead.Treating_Medical_Professional_Email__c) && String.isBlank(lead.Treating_Medical_Professional_Last_Name__c)) {
				treatingMp.newEmailProvided = lead.Treating_Medical_Professional_Email__c;
			} else if (lead.Referring_MP__c == lead.Treating_MP__c && String.isNotEmpty(lead.Referring_MP_Email__c) && String.isBlank(lead.Referring_MP_Last_Name__c)) {
				treatingMp.newEmailProvided = lead.Referring_MP_Email__c;
			}
			treatingMp.numProvidedEmails = countNumberOfEmailsProvided(treatingMp);
			contacts.add(treatingMp);
		}
		if (lead.Best_Contact__c != null && (String.isNotEmpty(lead.Best_Contact__r.npe01__WorkEmail__c)
				|| String.isNotEmpty(lead.Best_Contact__r.npe01__AlternateEmail__c)
				|| String.isNotEmpty(lead.Best_Contact__r.Alternate_Email_2__c)
				|| String.isNotEmpty(lead.Best_contact_for_Physician_Email__c))) {
			SendDiagnosisWrapper bestContact = new SendDiagnosisWrapper();
			bestContact.id = lead.Best_Contact__c;
			bestContact.name = lead.Best_Contact__r.Name;
			bestContact.type = System.Label.Wish_Referral_Best_Medical_Contact;
			bestContact.hiddenDvFormMedicalProfessionalType = Constant_AC.LEAD_DV_FORM_TYPE_BEST_CONTACT;
			if (String.isNotEmpty(lead.Best_Contact__r.npe01__WorkEmail__c)) {
				bestContact.workEmail = lead.Best_Contact__r.npe01__WorkEmail__c;
			}
			if (String.isNotEmpty(lead.Best_Contact__r.npe01__AlternateEmail__c)) {
				bestContact.alternateEmail1 = lead.Best_Contact__r.npe01__AlternateEmail__c;
			}
			if (String.isNotEmpty(lead.Best_Contact__r.Alternate_Email_2__c)) {
				bestContact.alternateEmail2 = lead.Best_Contact__r.Alternate_Email_2__c;
			}
			if (String.isNotEmpty(lead.Best_Contact__r.Contact_Notes__c)) {
				bestContact.contactNotes = lead.Best_Contact__r.Contact_Notes__c;
			}
			if (String.isNotEmpty(lead.Best_contact_for_Physician_Email__c) && String.isBlank(lead.Best_Contact_for_Physician_Last_Name__c)) {
				bestContact.newEmailProvided = lead.Best_contact_for_Physician_Email__c;
			} else if (lead.Referring_MP__c == lead.Best_Contact__c && String.isNotEmpty(lead.Referring_MP_Email__c) && String.isBlank(lead.Referring_MP_Last_Name__c)) {
				bestContact.newEmailProvided = lead.Referring_MP_Email__c;
			}
			bestContact.numProvidedEmails = countNumberOfEmailsProvided(bestContact);
			contacts.add(bestContact);
		}
		if (lead.Alt_1_MP__c != null && (String.isNotEmpty(lead.Alt_1_MP__r.npe01__WorkEmail__c)
				|| String.isNotEmpty(lead.Alt_1_MP__r.npe01__AlternateEmail__c)
				|| String.isNotEmpty(lead.Alt_1_MP__r.Alternate_Email_2__c))) {
			SendDiagnosisWrapper alternate1Mp = new SendDiagnosisWrapper();
			alternate1Mp.id = lead.Alt_1_MP__c;
			alternate1Mp.name = lead.Alt_1_MP__r.Name;
			alternate1Mp.type = ALTERNATE_1_MEDICAL_PROFESSIONAL;
			alternate1Mp.hiddenDvFormMedicalProfessionalType = Constant_AC.LEAD_DV_FORM_TYPE_ALTERNATE_1_MEDICAL_PROFESSIONAL;
			if (String.isNotEmpty(lead.Alt_1_MP__r.npe01__WorkEmail__c)) {
				alternate1Mp.workEmail = lead.Alt_1_MP__r.npe01__WorkEmail__c;
			}
			if (String.isNotEmpty(lead.Alt_1_MP__r.npe01__AlternateEmail__c)) {
				alternate1Mp.alternateEmail1 = lead.Alt_1_MP__r.npe01__AlternateEmail__c;
			}
			if (String.isNotEmpty(lead.Alt_1_MP__r.Alternate_Email_2__c)) {
				alternate1Mp.alternateEmail2 = lead.Alt_1_MP__r.Alternate_Email_2__c;
			}
			if (String.isNotEmpty(lead.Alt_1_MP__r.Contact_Notes__c)) {
				alternate1Mp.contactNotes = lead.Alt_1_MP__r.Contact_Notes__c;
			}
			alternate1Mp.numProvidedEmails = countNumberOfEmailsProvided(alternate1Mp);
			contacts.add(alternate1Mp);
		}
		if (lead.Alt_2_MP__c != null && (String.isNotEmpty(lead.Alt_2_MP__r.npe01__WorkEmail__c)
				|| String.isNotEmpty(lead.Alt_2_MP__r.npe01__AlternateEmail__c)
				|| String.isNotEmpty(lead.Alt_2_MP__r.Alternate_Email_2__c))) {
			SendDiagnosisWrapper alternate2Mp = new SendDiagnosisWrapper();
			alternate2Mp.id = lead.Alt_2_MP__c;
			alternate2Mp.name = lead.Alt_2_MP__r.Name;
			alternate2Mp.type = ALTERNATE_2_MEDICAL_PROFESSIONAL;
			alternate2Mp.hiddenDvFormMedicalProfessionalType = Constant_AC.LEAD_DV_FORM_TYPE_ALTERNATE_2_MEDICAL_PROFESSIONAL;
			if (String.isNotEmpty(lead.Alt_2_MP__r.npe01__WorkEmail__c)) {
				alternate2Mp.workEmail = lead.Alt_2_MP__r.npe01__WorkEmail__c;
			}
			if (String.isNotEmpty(lead.Alt_2_MP__r.npe01__AlternateEmail__c)) {
				alternate2Mp.alternateEmail1 = lead.Alt_2_MP__r.npe01__AlternateEmail__c;
			}
			if (String.isNotEmpty(lead.Alt_2_MP__r.Alternate_Email_2__c)) {
				alternate2Mp.alternateEmail2 = lead.Alt_2_MP__r.Alternate_Email_2__c;
			}
			if (String.isNotEmpty(lead.Alt_2_MP__r.Contact_Notes__c)) {
				alternate2Mp.contactNotes = lead.Alt_2_MP__r.Contact_Notes__c;
			}
			alternate2Mp.numProvidedEmails = countNumberOfEmailsProvided(alternate2Mp);
			contacts.add(alternate2Mp);
		}
		return contacts;
	}

	/**
	 * Send Diagnosis Wrapper
    */
	public class SendDiagnosisWrapper {
		public Id id { get; set; }
		public String name { get; set; }
		public String type { get; set; }
		public String hiddenDvFormMedicalProfessionalType { get; set; }
		public String workEmail { get; set; }
		public String alternateEmail1 { get; set; }
		public String alternateEmail2 { get; set; }
		public String newEmailProvided { get; set; }
		public String contactNotes { get; set; }
		public Integer numProvidedEmails { get; set; }
	}

	/**
	 * @description Count the number of provided emails
	 * @param wrapper SendDiagnosisWrapper
	 * @return Integer
	*/
	private static Integer countNumberOfEmailsProvided(SendDiagnosisWrapper wrapper) {
		// Starts with 1 because the Name of the MP counts as a row
		Integer num = 1;
		if (String.isNotEmpty(wrapper.workEmail)) {
			num++;
		}
		if (String.isNotEmpty(wrapper.alternateEmail1)) {
			num++;
		}
		if (String.isNotEmpty(wrapper.alternateEmail2)) {
			num++;
		}
		if (String.isNotEmpty(wrapper.newEmailProvided)) {
			num++;
		}
		return num;
	}
}