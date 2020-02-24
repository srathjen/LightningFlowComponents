/***************************************************************************************************
Author      : MST Solutions
Description : This class is used add all links to navigate to the particuar forms
*****************************************************************************************************/
public class WishRelatedLinks_AC {

	public Case currentCaseRec { get; set; }
	public String WishFamilyForm { get; set; }
	public String paperwishformpdf { get; set; }
	public String paperwishformpdfempty { get; set; }
	public String LiabilityFrom { get; set; }
	public String contactInfo { get; set; }
	public String miniorParticipant { get; set; }
	public String absentParentForm { get; set; }
	public String celebrityForm { get; set; }
	public String singleForm { get; set; }
	public String wishClearence { get; set; }
	public String wishClearenceNoTravel { get; set; }
	public String ChildMedicalForm { get; set; }
	public String ComboCMSWC { get; set; }
	public String ShoppingSpree { get; set; }
	public List<Case> querychildCase;
	public List<Wish_Child_Form__c> childFormList;
	public String ddpId { get; set; }
	public String wishReceiptDownloadDDP { get; set; }
	public String wishReceiptSpanishDownloadDDP { get; set; }
	public String wishReceiptDocuSigndDDP { get; set; }
	public String wishReceiptSpanishDocuSigndDDP { get; set; }
	public String dnqLetterDDP { get; set; }
	public String welcomeletterDDP { get; set; }
	public String bioSheetDDP { get; set; }
	public String sneakPeekDDP { get; set; }
	public String dnqLetterSpanishDDP { get; set; }
	public String welcomeLetterSpanishDDP { get; set; }
	public String wishAssistFormDDP { get; set; }
	public String wishAssistForm { get; set; }
	public String wishReceiptSpanishDDP { get; set; }
	public String WishReceipt { get; set; }
	public String welcomeLetter { get; set; }
	public String dnqLetter { get; set; }
	public String bioSheet { get; set; }
	public String sneakPeek { get; set; }
	public String wishReceiptSpanish { get; set; }
	public String dnqLetterSpanish { get; set; }
	public String welcomeLetterSpanish { get; set; }
	public String MergedDocuments { get; set; }
	public String recpCheck { get; set; }
	public Boolean showPopup { get; set; }
	public List<WrapperClass> wrapperList { get; set; }
	public String recipitLink { get; set; }
	public Boolean wraaperSize { get; set; }
	public String WG_FinalStep_FileClosedDDP { get; set; }
	public String WG_FinalStep_FileClosed_SpanishDDP { get; set; }
	public String WG_StepOne_90daysDDP { get; set; }
	public String WG_StepOne_90days_SpanishDDP { get; set; }
	public String WG_StepThree_30daysDDP { get; set; }
	public String WG_StepThree_30days_SpanishDDP { get; set; }
	public String WG_StepTwo_60daysDDP { get; set; }
	public String WG_StepTwo_60days_SpanishDDP { get; set; }
	public String WG_FinalStep_FileClosed { get; set; }
	public String WG_FinalStep_FileClosed_Spanish { get; set; }
	public String WG_StepOne_90days { get; set; }
	public String WG_StepOne_90days_Spanish { get; set; }
	public String WG_StepThree_30days { get; set; }
	public String WG_StepThree_30days_Spanish { get; set; }
	public String WG_StepTwo_60days { get; set; }
	public String WG_StepTwo_60days_Spanish { get; set; }
	public String wishGranting { get; set; }
	public String rushWishLetter { get; set; }
	public String rushWishLetterDDP { get; set; }
	public String familyHoldMessage { get; set; }
	public String familyHoldMessageDDP { get; set; }
	public String salesforceWishAssistFormMessage { get; set; }
	public String salesforceWishAssistFormDDP { get; set; }
	public String absentandsingleForm { get; set; }
	public Boolean formTrackerVal { get; set; }
	public String Combo_Clearance_CMS_faxMessage { get; set; }
	public String Combo_Clearance_CMS_faxMessageDDP { get; set; }
	public String Child_s_Medical_Summary_faxMessage { get; set; }
	public String Child_s_Medical_Summary_faxMessageDDP { get; set; }
	public String Wish_Clearance_faxMessage { get; set; }
	public String Wish_Clearance_faxMessageDDP { get; set; }
	public String Wish_Clearance_no_travel_faxMessage { get; set; }
	public String Wish_Clearance_no_travel_faxMessageDDP { get; set; }
	public Id familyContactRecordTypeId;
	public List<User> userDetailList { get; set; }

	private final static String contactWishChildRecordTypeLabel = Constant_AC.CONTACT_WISH_CHILD_RT_LABEL;

	public WishRelatedLinks_AC(ApexPages.StandardController controller) {
		String pagesName = 'Absent_Vf';
		String page = 'Single_Vf';
		recpCheck = 'Allow';
		wraaperSize = true;
		wrapperList = new List<WrapperClass>();
		familyContactRecordTypeId = Constant_AC.WISH_FORM_FAMILY_ID;
		Id wishRecordTypeId = Constant_AC.WISH_RT_ID;
		querychildCase = new List<Case>();
		currentCaseRec = (Case) controller.getRecord();
		ddpId = Label.Wish_Receipt_DDP;
		welcomeletterDDP = Label.Welcome_Letter_DDP;
		dnqLetterDDP = Label.DNQ_Letter_DDP;
		bioSheetDDP = Label.Bio_Sheet_DDP;
		sneakPeekDDP = Label.Sneak_Peek_DDP;
		wishAssistFormDDP = Label.Wish_Assist_Form_DDP;

		WG_FinalStep_FileClosedDDP = Label.WG_FinalStep_FileClosed;
		WG_FinalStep_FileClosed_SpanishDDP = Label.WG_FinalStep_FileClosed_Spanish;
		WG_StepOne_90daysDDP = Label.WG_StepOne_90days;
		WG_StepOne_90days_SpanishDDP = Label.WG_StepOne_90days_Spanish;
		WG_StepThree_30daysDDP = Label.WG_StepThree_30days;
		WG_StepThree_30days_SpanishDDP = Label.WG_StepThree_30days_Spanish;
		WG_StepTwo_60daysDDP = Label.WG_StepTwo_60days;
		WG_StepTwo_60days_SpanishDDP = Label.WG_StepTwo_60days_Spanish;

		dnqLetterSpanishDDP = Label.DNQ_Letter_Spanish_DDP;
		welcomeLetterSpanishDDP = Label.Welcome_Letter_Spanish_DDP;
		wishReceiptSpanishDDP = Label.Wish_Receipt_Spanish;
		wishReceiptDownloadDDP = Label.WishReceiptDownloadDeliverOption;
		wishReceiptSpanishDownloadDDP = Label.WishReceiptSpanishDownloadDeliverOption;
		wishReceiptDocuSigndDDP = Label.WishReceiptDocusingDeliverOption;
		wishReceiptSpanishDocuSigndDDP = Label.WishReceiptSpanishDocusingDeliverOption;

		rushWishLetterDDP = Label.Rush_Wish_Letter_DDP;
		familyHoldMessageDDP = Label.Family_Hold_Message;
		salesforceWishAssistFormDDP = Label.Salesforce_Wish_Assist_Form;

		Combo_Clearance_CMS_faxMessageDDP = Label.Combo_Clearance_CMS_faxDDP;
		Child_s_Medical_Summary_faxMessageDDP = Label.Child_s_Medical_Summary_faxDDP;
		Wish_Clearance_faxMessageDDP = Label.Wish_Clearance_faxDDP;
		Wish_Clearance_no_travel_faxMessageDDP = Label.Wish_Clearance_no_travel_faxDDP;

		userDetailList = new List<User>();
		Set<Id> teamMemberSet = new Set<Id>();
		for (CaseTeamMember currentMember : [
				SELECT ID,ParentId,TeamRole.Name,Member.Name,MemberId
				FROM CaseTeamMember
				WHERE ParentId = :currentCaseRec.Id AND (TeamRole.Name = :'Wish Granter' OR TeamRole.Name = :'Wish Granter Mentor')
				LIMIT 2
		]) {
			teamMemberSet.add(currentMember.MemberId);
		}

		userDetailList = [
				SELECT Id, Name, ContactId, Contact.MobilePhone, Contact.Name
				FROM User
				WHERE Id IN:teamMemberSet
		];
		List<ProcessInstance> approvalIns = [
				SELECT TargetObjectId,Status,ProcessDefinitionId,ProcessDefinition.Name
				FROM ProcessInstance
				WHERE TargetObjectId = :currentCaseRec.Id AND Status = :'Pending' AND ProcessDefinition.Name = :'Wish Child Form Approval Process'
		];
		List<Wish_Child_Form__c> childFormList = [
				SELECT Id,RecordTypeId,FirstName__c,LastName__c,Middle_Name__c,Migrated__c
				FROM Wish_Child_Form__c
				WHERE Case__c = :currentCaseRec.Id AND RecordTypeId = :familyContactRecordTypeId AND Migrated__c = False
		];
		if (childFormList.size() == 0) {
			showPopup = true;
			formTrackerVal = true;
		}

		if (currentCaseRec.RecordTypeId == wishRecordTypeId) {
			wishGranting = '/apex/wishFormDashboard_VF?id=' + currentCaseRec.Id;
			WishFamilyForm = '/apex/WishChildForm_VF?id=' + currentCaseRec.Id;
			paperwishformpdf = '/apex/WishFormDownloadPDF?id=' + currentCaseRec.Id;
			paperwishformpdfempty = '/apex/WishFormDownloadPDF';
			contactInfo = '/apex/RelationshipsViewer_VF?recId=' + currentCaseRec.Id;
			LiabilityFrom = '/apex/LiabilityForms_VF?id=' + currentCaseRec.Id;
			miniorParticipant = '/apex/WishLiabilityMinorParticipant_VF?id=' + currentCaseRec.Id;
			absentParentForm = '/apex/AbsentForm_VF?id=' + currentCaseRec.Id + '&' + 'option=' + pagesName;
			celebrityForm = '/apex/Entertainment_VF?id=' + currentCaseRec.Id;
			singleForm = '/apex/SingleForm_VF?id=' + currentCaseRec.Id + '&' + 'option=' + page;
			wishClearence = '/apex/WishClearanceSendNow_VF?id=' + currentCaseRec.Id;
			wishClearenceNoTravel = '/apex/WishClearanceNoTravel_VF?id=' + currentCaseRec.Id;
			ChildMedicalForm = '/apex/WishChildSummary_VF?id=' + currentCaseRec.Id;
			ComboCMSWC = '/apex/ComboCMSWC?id=' + currentCaseRec.Id;
			ShoppingSpree = '/apex/Itinerary_VF?id=' + currentCaseRec.Id;
			absentandsingleForm = '/apex/AbsentParentSingleParentForm_VF?id=' + currentCaseRec.Id;
			MergedDocuments = '/apex/MergedDocuments_VF?id=' + currentCaseRec.Id;
			welcomeLetter = '/apex/loop__looplus?eid=' + currentCaseRec.Id + '&hidecontact=' + true + '&hideddp=' + true + '&sidebar=' + false + '&ddpIds=' + welcomeletterDDP;
			dnqLetter = '/apex/loop__looplus?eid=' + currentCaseRec.Id + '&hidecontact=' + true + '&hideddp=' + true + '&sidebar=' + false + '&ddpIds=' + dnqLetterDDP;
			bioSheet = '/apex/loop__looplus?eid=' + currentCaseRec.Id + '&hidecontact=' + true + '&hideddp=' + true + '&sidebar=' + false + '&ddpIds=' + bioSheetDDP;
			sneakPeek = '/apex/loop__looplus?eid=' + currentCaseRec.Id + '&hidecontact=' + true + '&hideddp=' + true + '&sidebar=' + false + '&ddpIds=' + sneakPeekDDP;
			wishReceiptSpanish = '/apex/loop__looplus?eid=' + currentCaseRec.Id + '&hidecontact=' + true + '&hideddp=' + true + '&sidebar=' + false + '&ddpIds=' + wishReceiptSpanishDDP;
			dnqLetterSpanish = '/apex/loop__looplus?eid=' + currentCaseRec.Id + '&hidecontact=' + true + '&hideddp=' + true + '&sidebar=' + false + '&ddpIds=' + dnqLetterSpanishDDP;
			welcomeLetterSpanish = '/apex/loop__looplus?eid=' + currentCaseRec.Id + '&hidecontact=' + true + '&hideddp=' + true + '&sidebar=' + false + '&ddpIds=' + welcomeLetterSpanishDDP;
			wishAssistForm = '/apex/loop__looplus?eid=' + currentCaseRec.Id + '&hidecontact=' + true + '&hideddp=' + true + '&sidebar=' + false + '&ddpIds=' + wishAssistFormDDP;

			WG_FinalStep_FileClosed = '/apex/loop__looplus?eid=' + currentCaseRec.Id + '&hidecontact=' + true + '&hideddp=' + true + '&sidebar=' + false + '&ddpIds=' + WG_FinalStep_FileClosedDDP;
			WG_FinalStep_FileClosed_Spanish = '/apex/loop__looplus?eid=' + currentCaseRec.Id + '&hidecontact=' + true + '&hideddp=' + true + '&sidebar=' + false + '&ddpIds=' + WG_FinalStep_FileClosed_SpanishDDP;
			WG_StepOne_90days = '/apex/loop__looplus?eid=' + currentCaseRec.Id + '&hidecontact=' + true + '&hideddp=' + true + '&sidebar=' + false + '&ddpIds=' + WG_StepOne_90daysDDP;
			WG_StepOne_90days_Spanish = '/apex/loop__looplus?eid=' + currentCaseRec.Id + '&hidecontact=' + true + '&hideddp=' + true + '&sidebar=' + false + '&ddpIds=' + WG_StepOne_90days_SpanishDDP;
			WG_StepThree_30days = '/apex/loop__looplus?eid=' + currentCaseRec.Id + '&hidecontact=' + true + '&hideddp=' + true + '&sidebar=' + false + '&ddpIds=' + WG_StepThree_30daysDDP;
			WG_StepThree_30days_Spanish = '/apex/loop__looplus?eid=' + currentCaseRec.Id + '&hidecontact=' + true + '&hideddp=' + true + '&sidebar=' + false + '&ddpIds=' + WG_StepThree_30days_SpanishDDP;
			WG_StepTwo_60days = '/apex/loop__looplus?eid=' + currentCaseRec.Id + '&hidecontact=' + true + '&hideddp=' + true + '&sidebar=' + false + '&ddpIds=' + WG_StepTwo_60daysDDP;
			WG_StepTwo_60days_Spanish = '/apex/loop__looplus?eid=' + currentCaseRec.Id + '&hidecontact=' + true + '&hideddp=' + true + '&sidebar=' + false + '&ddpIds=' + WG_StepTwo_60days_SpanishDDP;

			rushWishLetter = '/apex/loop__looplus?eid=' + currentCaseRec.Id + '&hidecontact=' + true + '&hideddp=' + true + '&sidebar=' + false + '&ddpIds=' + rushWishLetterDDP;
			familyHoldMessage = '/apex/loop__looplus?eid=' + currentCaseRec.Id + '&hidecontact=' + true + '&hideddp=' + true + '&sidebar=' + false + '&ddpIds=' + familyHoldMessageDDP;
			salesforceWishAssistFormMessage = '/apex/loop__looplus?eid=' + currentCaseRec.Id + '&hidecontact=' + true + '&hideddp=' + true + '&sidebar=' + false + '&ddpIds=' + salesforceWishAssistFormDDP;

			Combo_Clearance_CMS_faxMessage = '/apex/loop__looplus?eid=' + currentCaseRec.Id + '&hidecontact=' + true + '&hideddp=' + true + '&sidebar=' + false + '&ddpIds=' + Combo_Clearance_CMS_faxMessageDDP;
			Child_s_Medical_Summary_faxMessage = '/apex/loop__looplus?eid=' + currentCaseRec.Id + '&hidecontact=' + true + '&hideddp=' + true + '&sidebar=' + false + '&ddpIds=' + Child_s_Medical_Summary_faxMessageDDP;
			Wish_Clearance_faxMessage = '/apex/loop__looplus?eid=' + currentCaseRec.Id + '&hidecontact=' + true + '&hideddp=' + true + '&sidebar=' + false + '&ddpIds=' + Wish_Clearance_faxMessageDDP;
			Wish_Clearance_no_travel_faxMessage = '/apex/loop__looplus?eid=' + currentCaseRec.Id + '&hidecontact=' + true + '&hideddp=' + true + '&sidebar=' + false + '&ddpIds=' + Wish_Clearance_no_travel_faxMessageDDP;
		}
		querychildCase = [
				SELECT Id,CaseNumber,ParentId,Parent.AccountId,Parent.ContactId
				FROM Case
				WHERE ParentId = :currentCaseRec.Id
				AND RecordTypeId = :wishRecordTypeId
				AND ParentId != Null
				LIMIT 1
		];
		if (!querychildCase.isEmpty() && querychildCase[0].Id != Null) {
			WishReceipt = '/apex/loop__looplus?eid=' + querychildCase[0].ParentId + '&accountId=' + querychildCase[0].Parent.AccountId + '&hidecontact=' + true + '&hideddp=' + true + '&sidebar=' + false + '&ddpIds=' + ddpId;
		}
	}

	public pageReference LiabilityFrom() {
		PageReference reference = new PageReference('/apex/WishLiabilityForm_VF?id=' + currentCaseRec.Id);
		reference.setRedirect(true);
		return reference;
	}
	public pageReference DisplayError() {
		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, ' This record is already in approval process'));
		return null;
	}
	//This method is used to get the all related contact from relationship recod and redirect to WishReceipt page.
	public PageReference updateSenderInfo() {
		set<Id> dbWishFamilyIdSet = new set<Id>();
		List<contact> reltaedContactList = new List<contact>();
		List<Case> caseInfo = [
				SELECT Id,ContactId
				FROM Case
				WHERE Id = :currentCaseRec.Id
		];
		for (npe4__Relationship__c relationInfo : [
				SELECT Id, npe4__Contact__c, npe4__RelatedContact__c, npe4__RelatedContact__r.Name,Under_18__c,npe4__RelatedContact__r.Email
				FROM npe4__Relationship__c
				WHERE npe4__Contact__c = :caseInfo[0].ContactId AND Parent_Legal_Guardian__c = true AND npe4__RelatedContact__r.Email != Null AND Under_18__c = false
				LIMIT 50000
		]) {
			dbWishFamilyIdSet.add(relationInfo.npe4__RelatedContact__c);
		}
		for (Contact dbWishChildCon : [
				SELECT Id,Current_Age__c,Name,Email,Relationship_Type__c
				FROM Contact
				WHERE Id = :caseInfo[0].ContactId AND Current_Age__c >= 18 AND Email != Null
				LIMIT 50000
		]) {
			reltaedContactList.add(dbWishChildCon);
			WrapperClass wc = new WrapperClass(dbWishChildCon);
			wrapperList.add(wc);
		}

		for (Contact dbFamilyContact : [
				SELECT Id,Name,Email,Relationship_Type__c
				FROM Contact
				WHERE Id In:dbWishFamilyIdSet
				LIMIT 50000
		]) {
			reltaedContactList.add(dbFamilyContact);
			WrapperClass wc = new WrapperClass(dbFamilyContact);
			wrapperList.add(wc);
		}

		if (reltaedContactList.size() == 0) {
			DisplayErrorMessage();

		} else {
			wraaperSize = false;
		}

		return new PageReference('/apex/WishReceipt');
	}

	public pageReference DisplayErrorMessage() {
		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, ' There is no parent/legal guardian for this wish child'));
		return Null;
	}

	public pageReference DisplayErr() {
		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, ' You can select maximum three recipients below.'));
		return Null;
	}
	public pageReference DisplayErrormsg() {
		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, ' Please select maximum 2 parent/legal guardian and wish child (if 18 years or more).'));
		return Null;
	}

	public class WrapperClass {
		public boolean selected { get; set; }
		public Contact rel { get; set; }

		public WrapperClass(Contact relationShip) {
			rel = relationShip;
			selected = false;
		}
	}
	//This method used to update the selected receipient name and email in whish child contact from the relationship record whenever clicks the link and run the draw loop.
	public PageReference updateWishChildContact() {
		integer i = 0;
		List<contact> updatelist = new List<contact>();
		List<Case> ParentCase = [
				SELECT Id,ContactId,AccountID
				FROM Case
				WHERE Id = :currentCaseRec.Id
		];
		List<Contact> wishChildCon = [
				SELECT Id,Recipient_Email__c,First_Recipient_Name__c,Second_Recipient_Email__c,Second_Recipient_Name__c,
						Relationship_Type__c,Hidden_Third_Recipient_Name__c,Hidden_Third_Recipient_Email__c
				FROM Contact
				WHERE Id = :ParentCase[0].ContactId
				LIMIT 1
		];
		string URL;
		wishChildCon[0].Recipient_Email__c = null;
		wishChildCon[0].First_Recipient_Name__c = null;
		wishChildCon[0].Second_Recipient_Email__c = null;
		wishChildCon[0].Second_Recipient_Name__c = null;
		wishChildCon[0].Hidden_Third_Recipient_Email__c = null;
		wishChildCon[0].Hidden_Third_Recipient_Name__c = null;
		if (recipitLink == 'wishreceipt') {
			URL = '/apex/loop__looplus?eid=' + querychildCase[0].ParentId + '&accountId=' + querychildCase[0].Parent.AccountId + '&hidecontact=' + true + '&hideddp=' + true + '&sidebar=' + false + '&ddpIds=' + ddpId + '&autorun=' + true + '&deploy=' + wishReceiptDocuSigndDDP;
		} else if (recipitLink == 'wishreceiptSpanish') {
			URL = '/apex/loop__looplus?eid=' + currentCaseRec.Id + '&hidecontact=' + true + '&hideddp=' + true + '&sidebar=' + false + '&ddpIds=' + wishReceiptSpanishDDP + '&autorun=' + true + '&deploy=' + wishReceiptSpanishDocuSigndDDP;
		}
		for (wrapperclass wcc : wrapperList) {
			if (wcc.selected == true) {
				if (wcc.rel.Relationship_Type__c == contactWishChildRecordTypeLabel) {
					i = 1;
				}
				updatelist.add(wcc.rel);
				if (wishChildCon[0].Recipient_Email__c == null
						&& wishChildCon[0].First_Recipient_Name__c == null
						&& wcc.rel.Relationship_Type__c != null
						&& wcc.rel.Relationship_Type__c != Constant_AC.CONTACT_WISH_CHILD_RT_LABEL) {
					wishChildCon[0].Recipient_Email__c = wcc.rel.Email;
					wishChildCon[0].First_Recipient_Name__c = wcc.rel.Name;

				}
				if (wcc.rel.Relationship_Type__c != Null
						&& wcc.rel.Relationship_Type__c != Constant_AC.CONTACT_WISH_CHILD_RT_LABEL
						&& wishChildCon[0].Second_Recipient_Email__c == null
						&& wishChildCon[0].Second_Recipient_Name__c == null
						&& ((wishChildCon[0].Recipient_Email__c != wcc.rel.Email)
						|| (wishChildCon[0].First_Recipient_Name__c != wcc.rel.Name))) {
					wishChildCon[0].Second_Recipient_Email__c = wcc.rel.Email;
					wishChildCon[0].Second_Recipient_Name__c = wcc.rel.Name;

				}

				if ((wcc.rel.Relationship_Type__c == Constant_AC.CONTACT_WISH_CHILD_RT_LABEL
						&& wcc.rel.Relationship_Type__c != 'Parent/Legal Guardian'
						&& wishChildCon[0].Hidden_Third_Recipient_Email__c == null
						&& wishChildCon[0].Hidden_Third_Recipient_Name__c == null)) {

					wishChildCon[0].Hidden_Third_Recipient_Email__c = wcc.rel.Email;
					wishChildCon[0].Hidden_Third_Recipient_Name__c = wcc.rel.Name;

				}
			}
		}

		PageReference pageRef;
		if (wishChildCon.size() > 0 && updatelist.size() > 0 && updatelist.size() <= 3 && i == 1) {
			update wishChildCon;
			pageRef = new PageReference(URL);
		} else {
			if (i == 1) {
				DisplayErr();
			}
		}
		if (wishChildCon.size() > 0 && updatelist.size() > 0 && updatelist.size() <= 2 && i == 0) {
			update wishChildCon;
			pageRef = new PageReference(URL);
		} else {
			if (i == 0) {
				DisplayErrormsg();
			}
		}
		return pageRef;
	}

	//This method is used to download the wish receipt document.
	public PageReference downLoadWishReceipt() {
		string dowloadURL;
		if (recipitLink == 'wishreceipt') {
			dowloadURL = '/apex/loop__looplus?eid=' + querychildCase[0].ParentId + '&accountId=' + querychildCase[0].Parent.AccountId + '&hidecontact=' + true + '&hideddp=' + true + '&sidebar=' + false + '&ddpIds=' + ddpId + '&autorun=' + true + '&deploy=' + wishReceiptDownloadDDP;

		} else if (recipitLink == 'wishreceiptSpanish') {
			dowloadURL = '/apex/loop__looplus?eid=' + currentCaseRec.Id + '&hidecontact=' + true + '&hideddp=' + true + '&sidebar=' + false + '&ddpIds=' + wishReceiptSpanishDDP + '&autorun=' + true + '&deploy=' + wishReceiptSpanishDownloadDDP;
		}
		return new PageReference(dowloadURL);
	}

	public void updateCaseTeamMember() {
		List<case> updateCaseList = new List<case>();
		If (userDetailList.SIZE() > 0) {
			Case updCase = new Case(Id = currentCaseRec.Id);
			updCase.Wish_Granter_1__c = Null;
			updCase.Wish_granter_2__c = Null;
			updCase.Wish_Granter_1_Cell__c = Null;
			updCase.Wish_Granter_2_Cell__c = Null;
			if (updCase.Wish_Granter_1__c == NULL) {
				updCase.Wish_Granter_1__c = userDetailList[0].Name;
				updCase.Wish_Granter_1_Cell__c = userDetailList[0].contact.MobilePhone;
			}
			if (userDetailList.size() > 1 && updCase.Wish_Granter_2__c == NULL) {
				updCase.Wish_granter_2__c = userDetailList[1].Name;
				updCase.Wish_Granter_2_Cell__c = userDetailList[1].contact.MobilePhone;
			}
			updateCaseList.add(updCase);
		}
		if (updateCaseList.size() > 0)
			update updateCaseList;
	}
}