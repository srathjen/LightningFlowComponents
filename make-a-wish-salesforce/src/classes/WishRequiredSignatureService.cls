/**
  * @description Service Class to create Wish Required Signature records when Affiliation/Relationship is updated/created
  * @author      Mitali Nahar, Traction on Demand
  * @createdDate        8/5/2019
  */
public with sharing class WishRequiredSignatureService {

	private final static Date TODAY = Date.today();
	private final static Integer EIGHTEEN = 18;

	/**
	 * Create wish signatures where Type is changed to be Wish Child
	 *
	 * @param newAffiliationsList     List of new Affiliations
	 * @param oldAffiliationsMap      Map of old Affiliations
	 */
	public static void createWishChildSignatures(List<Wish_Affiliation__c> newAffiliationsList, Map<Id, Wish_Affiliation__c> oldAffiliationsMap) {
		List<Wish_Affiliation__c> filteredAffiliations = new List<Wish_Affiliation__c>();
		Set<Id> chapterIdSet = new Set<Id>();
		for (Wish_Affiliation__c objAffiliation : [
				SELECT Wish__r.ChapterName__c,Contact__r.Email
				FROM Wish_Affiliation__c
				WHERE Id IN:newAffiliationsList
				AND Wish_Affiliation_Type__c = :Constant_AC.WISH_AFFILIATION_TYPE_WISH_CHILD
				AND Participant_Turning_18__c <= :TODAY
				AND Wish__r.ChapterName__c != NULL
				AND Wish__r.IsClosed = FALSE
				AND (Wish__r.Start_Date__c = NULL OR Wish__r.Start_Date__c >= TODAY )
		]) {
			if (oldAffiliationsMap != null) {
				if (oldAffiliationsMap.get(objAffiliation.Id).Wish_Affiliation_Type__c != Constant_AC.WISH_AFFILIATION_TYPE_WISH_CHILD) {
					filteredAffiliations.add(objAffiliation);
					chapterIdSet.add(objAffiliation.Wish__r.ChapterName__c);
				}
			} else {
				filteredAffiliations.add(objAffiliation);
				chapterIdSet.add(objAffiliation.Wish__r.ChapterName__c);
			}
		}
		if (filteredAffiliations.isEmpty() || chapterIdSet.isEmpty()) {
			return;
		}
		//Get list of required Forms for a Chapter
		Map<Id, Set<Id>> chapterToChildForms = getChapterToForms(chapterIdSet, false, false, true, false);
		if (chapterToChildForms.isEmpty()) {
			return;
		}
		//From existing Wish Signatures get affiliations to list of forms
		Map<Id, Set<Id>> wishAffiliationToFormIds = getExistingSignatures(filteredAffiliations);

		//Create new Wish Signatures for Forms not already sent to affiliations
		List<Wish_Required_Signature__c> wrsToInsert = new List<Wish_Required_Signature__c>();
		for (Wish_Affiliation__c objWishAff : filteredAffiliations) {
			if (chapterToChildForms.containsKey(objWishAff.Wish__r.ChapterName__c)) {
				for (Id formId : chapterToChildForms.get(objWishAff.Wish__r.ChapterName__c)) {
					if (wishAffiliationToFormIds.isEmpty() || (!wishAffiliationToFormIds.isEmpty() && wishAffiliationToFormIds.containsKey(objWishAff.Id) && !wishAffiliationToFormIds.get(objWishAff.Id).contains(formId))) {
						//Create WRS
						wrsToInsert.add(createWishRequiredSignature(objWishAff, formId));
					}
				}
			}
		}
		insert wrsToInsert;
	}

	/**
	 * Create wish signatures where Relationship is changed or Type is changed to be approved participant
	 *
	 * @param newAffiliationsList     List of new Affiliations
	 * @param oldAffiliationsMap      Map of old Affiliations
	 */
	public static void createWishParticipantSignatures(List<Wish_Affiliation__c> newAffiliationsList, Map<Id, Wish_Affiliation__c> oldAffiliationsMap) {
		List<Wish_Affiliation__c> filteredAffiliations = new List<Wish_Affiliation__c>();
		Set<Id> chapterIdSet = new Set<Id>();
		for (Wish_Affiliation__c objAffiliation : [
				SELECT Wish__r.ChapterName__c,Contact__r.Email,Relationship__c
				FROM Wish_Affiliation__c
				WHERE Id IN :newAffiliationsList
				AND Wish_Affiliation_Type__c = :Constant_AC.WISH_AFFILIATION_TYPE_APPROVED_PARTICIPANT
				AND Participant_Turning_18__c <= :TODAY AND Wish__r.IsClosed = FALSE
				AND Wish__r.ChapterName__c != NULL
				AND (Wish__r.Start_Date__c = NULL OR Wish__r.Start_Date__c >= TODAY )
				AND (Parent_Legal_Guardian__c = FALSE OR Relationship__c = NULL
				OR (Parent_Legal_Guardian__c = TRUE AND Relationship__r.npe4__Contact__r.Current_Age__c > :EIGHTEEN))
		]) {

			if (oldAffiliationsMap != null) {
				if (objAffiliation.Relationship__c != oldAffiliationsMap.get(objAffiliation.Id).Relationship__c
						|| oldAffiliationsMap.get(objAffiliation.Id).Wish_Affiliation_Type__c != Constant_AC.WISH_AFFILIATION_TYPE_APPROVED_PARTICIPANT) {
					filteredAffiliations.add(objAffiliation);
					chapterIdSet.add(objAffiliation.Wish__r.ChapterName__c);
				}
			} else {
				filteredAffiliations.add(objAffiliation);
				chapterIdSet.add(objAffiliation.Wish__r.ChapterName__c);
			}
		}
		if (filteredAffiliations.isEmpty() || chapterIdSet.isEmpty()) {
			return;
		}

		//Get list of required Forms for a Chapter
		Map<Id, Set<Id>> chapterToParticipantForms = getChapterToForms(chapterIdSet, true, false, false, false);
		if (chapterToParticipantForms.isEmpty()) {
			return;
		}

		//From existing Wish Signatures get affiliations to list of forms
		Map<Id, Set<Id>> wishAffiliationToFormIds = getExistingSignatures(filteredAffiliations);

		//Create new Wish Signatures for Forms not already sent to affiliations
		List<Wish_Required_Signature__c> wrsToInsert = new List<Wish_Required_Signature__c>();
		for (Wish_Affiliation__c objWishAff : filteredAffiliations) {
			if (chapterToParticipantForms.containsKey(objWishAff.Wish__r.ChapterName__c)) {
				for (Id formId : chapterToParticipantForms.get(objWishAff.Wish__r.ChapterName__c)) {
					if (wishAffiliationToFormIds.isEmpty() || (!wishAffiliationToFormIds.isEmpty() && wishAffiliationToFormIds.containsKey(objWishAff.Wish__r.ChapterName__c) && !wishAffiliationToFormIds.get(objWishAff.Wish__r.ChapterName__c).contains(formId))) {
						//Create WRS
						wrsToInsert.add(createWishRequiredSignature(objWishAff, formId));
					}
				}
			}
		}
		insert wrsToInsert;
	}

	/**
	* Create wish signatures where Relationship is changed
	*
	* @param newAffiliationsList     List of new Affiliations
	* @param oldAffiliationsMap      Map of old Affiliations
	*/
	public static void createParticipantGuardianSignatures(List<Wish_Affiliation__c> newAffiliationsList, Map<Id, Wish_Affiliation__c> oldAffiliationsMap) {
		Set<Id> newAffiliationsSet = new Set<Id>();
		Set<Id> caseIds = new Set<Id>();
		for (Wish_Affiliation__c objAffiliation : newAffiliationsList) {
			if (oldAffiliationsMap != null) {
				if (objAffiliation.Relationship__c != oldAffiliationsMap.get(objAffiliation.Id).Relationship__c
						&& objAffiliation.Relationship__c != null && objAffiliation.Parent_Legal_Guardian__c) {
					newAffiliationsSet.add(objAffiliation.Id);
					caseIds.add(objAffiliation.Wish__c);
				}
			} else {
				if (objAffiliation.Relationship__c != null && objAffiliation.Parent_Legal_Guardian__c) {
					newAffiliationsSet.add(objAffiliation.Id);
					caseIds.add(objAffiliation.Wish__c);
				}
			}
		}
		if (newAffiliationsSet.isEmpty()) {
			return;
		}

		//Map of Case to Set of affiliation Contacts  under it
		Map<Id, Set<Id>> caseAffiliations = new Map<Id, Set<Id>>();
		for (Wish_Affiliation__c objAffiliation : [
				SELECT Id, Wish__c, Contact__c
				FROM Wish_Affiliation__c
				WHERE Wish__c IN :caseIds
		]) {
			if (!caseAffiliations.containsKey(objAffiliation.Wish__c)) {
				caseAffiliations.put(objAffiliation.Wish__c, new Set<Id>());
			}
			caseAffiliations.get(objAffiliation.Wish__c).add(objAffiliation.Contact__c);

		}

		Set<Id> chapterIdSet = new Set<Id>();
		List<Wish_Affiliation__c> filteredAffiliations = new List<Wish_Affiliation__c>();
		for (Wish_Affiliation__c objAff : [
				SELECT Wish__c,Wish__r.ContactId, Relationship__r.npe4__Contact__c, Wish__r.ChapterName__c, Contact__r.Email
				FROM Wish_Affiliation__c
				WHERE Id IN :newAffiliationsSet
				AND Relationship__r.npe4__Contact__r.Current_Age__c < :EIGHTEEN
				AND Wish__r.IsClosed = FALSE AND Wish__r.ChapterName__c != NULL
				AND (Wish__r.Start_Date__c = NULL OR Wish__r.Start_Date__c >= TODAY )
		]) {
			if (objAff.Wish__r.ContactId != objAff.Relationship__r.npe4__Contact__c &&
					caseAffiliations.get(objAff.Wish__c).contains(objAff.Relationship__r.npe4__Contact__c)) {
				filteredAffiliations.add(objAff);
				chapterIdSet.add(objAff.Wish__r.ChapterName__c);
			}
		}
		if (chapterIdSet.isEmpty()) {
			return;
		}

		//Get list of required Forms for a Chapter
		Map<Id, Set<Id>> chapterToParticipantForms = getChapterToForms(chapterIdSet, false, true, false, false);
		if (chapterToParticipantForms.isEmpty()) {
			return;
		}

		//From existing Wish Signatures get affiliations to list of forms
		Map<Id, Set<Id>> wishAffiliationToFormIds = getExistingSignatures(filteredAffiliations);

		//Create new Wish Signatures for Forms not already sent to affiliations
		Set<Id> caseIdSet = new Set<Id>();
		List<Wish_Required_Signature__c> wrsToInsert = new List<Wish_Required_Signature__c>();
		for (Wish_Affiliation__c objWishAff : filteredAffiliations) {
			if (chapterToParticipantForms.containsKey(objWishAff.Wish__r.ChapterName__c)) {
				for (Id formId : chapterToParticipantForms.get(objWishAff.Wish__r.ChapterName__c)) {
					if (wishAffiliationToFormIds.isEmpty() || (!wishAffiliationToFormIds.isEmpty() && wishAffiliationToFormIds.containsKey(objWishAff.Id) && !wishAffiliationToFormIds.get(objWishAff.Id).contains(formId))) {
						//CREATE WRS
						wrsToInsert.add(createWishRequiredSignature(objWishAff, formId));
						caseIdSet.add(objWishAff.Wish__c);
					}
				}
			}
		}

		if (wrsToInsert.isEmpty()) {
			return;
		}
		insert wrsToInsert;

		//Get Cases with their list of Affiliations
		Map<Id, Set<Wish_Affiliation__c>> caseToAffiliations = getCaseToAffiliations(caseIdSet);

		//Create Guardian Signature records if Signer is the Guardian
		List<Guardian_Signature__c> guardiansToInsert = new List<Guardian_Signature__c>();
		for (Wish_Required_Signature__c wrsObj : [
				SELECT Id, Wish_Affiliation__c, Wish_Case__c, Wish_Affiliation__r.Parent_Legal_Guardian__c,Wish_Affiliation__r.Relationship__r.npe4__Contact__c, Wish_Affiliation__r.Relationship__r.npe4__Contact__r.Current_Age__c
				FROM Wish_Required_Signature__c
				WHERE Id IN :wrsToInsert
		]) {
			if (wrsObj.Wish_Affiliation__r.Parent_Legal_Guardian__c == true && wrsObj.Wish_Affiliation__r.Relationship__r.npe4__Contact__r.Current_Age__c < EIGHTEEN) {
				for (Wish_Affiliation__c objAff : caseToAffiliations.get(wrsObj.Wish_Case__c)) {
					if (objAff.Contact__c == wrsObj.Wish_Affiliation__r.Relationship__r.npe4__Contact__c) {
						guardiansToInsert.add(createGuardianSignature(objAff.Id, wrsObj.Id));
						break;
					}
				}
			}
		}
		insert guardiansToInsert;
	}

	/**
	* Create wish signatures where Relationship is changed
	*
	* @param newAffiliationsList     List of new Affiliations
	* @param oldAffiliationsMap      Map of old Affiliations
	*/
	public static void createWishChildGuardianSignatures(List<Wish_Affiliation__c> newAffiliationsList, Map<Id, Wish_Affiliation__c> oldAffiliationsMap) {
		List<Wish_Affiliation__c> filteredAffiliations = new List<Wish_Affiliation__c>();
		Set<Id> chapterIdSet = new Set<Id>();
		for (Wish_Affiliation__c objAffiliation : [
				SELECT Id,Relationship__c,Relationship__r.npe4__Contact__c,Wish__r.ContactId,Wish__r.ChapterName__c,Contact__r.Email
				FROM Wish_Affiliation__c
				WHERE Id IN :newAffiliationsList
				AND Relationship__c != NULL
				AND Parent_Legal_Guardian__c = TRUE
				AND Wish__r.IsClosed = FALSE
				AND (Wish__r.Start_Date__c = NULL OR Wish__r.Start_Date__c >= TODAY )
				AND Relationship__r.npe4__Contact__r.Current_Age__c < :EIGHTEEN
				AND Wish__r.ChapterName__c != NULL
		]) {
			if (oldAffiliationsMap != null) {
				if (objAffiliation.Relationship__c != oldAffiliationsMap.get(objAffiliation.Id).Relationship__c
						&& objAffiliation.Relationship__r.npe4__Contact__c == objAffiliation.Wish__r.ContactId) {
					filteredAffiliations.add(objAffiliation);
					chapterIdSet.add(objAffiliation.Wish__r.ChapterName__c);
				}
			} else {
				if (objAffiliation.Relationship__r.npe4__Contact__c == objAffiliation.Wish__r.ContactId) {
					filteredAffiliations.add(objAffiliation);
					chapterIdSet.add(objAffiliation.Wish__r.ChapterName__c);
				}

			}
		}
		if (filteredAffiliations.isEmpty() || chapterIdSet.isEmpty()) {
			return;
		}

		//Get list of required Forms for a Chapter
		Map<Id, Set<Id>> chapterToParticipantForms = getChapterToForms(chapterIdSet, false, false, false, true);
		if (chapterToParticipantForms.isEmpty()) {
			return;
		}

		//From existing Wish Signatures get affiliations to list of forms
		Map<Id, Set<Id>> wishAffiliationToFormIds = getExistingSignatures(filteredAffiliations);

		//Create new Wish Signatures for Forms not already sent to affiliations
		Set<Id> caseIds = new Set<Id>();
		List<Wish_Required_Signature__c> wrsToInsert = new List<Wish_Required_Signature__c>();
		for (Wish_Affiliation__c objWishAff : filteredAffiliations) {
			if (chapterToParticipantForms.containsKey(objWishAff.Wish__r.ChapterName__c)) {
				for (Id formId : chapterToParticipantForms.get(objWishAff.Wish__r.ChapterName__c)) {
					if (wishAffiliationToFormIds.isEmpty() || (!wishAffiliationToFormIds.isEmpty() && wishAffiliationToFormIds.containsKey(objWishAff.Id) && !wishAffiliationToFormIds.get(objWishAff.Id).contains(formId))) {
						//Create WRS
						wrsToInsert.add(createWishRequiredSignature(objWishAff, formId));
						caseIds.add(objWishAff.Wish__c);

					}
				}
			}
		}
		if (wrsToInsert.isEmpty()) {
			return;
		}
		insert wrsToInsert;

		Map<Id, Set<Wish_Affiliation__c>> caseToAffiliations = getCaseToAffiliations(caseIds);

		List<Guardian_Signature__c> guardiansToInsert = new List<Guardian_Signature__c>();
		for (Wish_Required_Signature__c wishSig : [
				SELECT Id, Wish_Affiliation__c, Wish_Affiliation__r.Parent_Legal_Guardian__c, Wish_Affiliation__r.Relationship__r.npe4__Contact__r.Current_Age__c, Wish_Case__c
				FROM Wish_Required_Signature__c
				WHERE Id IN :wrsToInsert
		]) {
			if (wishSig.Wish_Affiliation__r.Parent_Legal_Guardian__c && wishSig.Wish_Affiliation__r.Relationship__r.npe4__Contact__r.Current_Age__c < EIGHTEEN) {
				for (Wish_Affiliation__c objAff : caseToAffiliations.get(wishSig.Wish_Case__c)) {
					if (objAff.Contact__c == wishSig.Wish_Affiliation__r.Relationship__r.npe4__Contact__c) {
						//CREATE Guardian Signatures
						guardiansToInsert.add(createGuardianSignature(objAff.Id, wishSig.Id));
						break;
					}
				}
			}
		}
		insert guardiansToInsert;
	}

	/**
   * Create wish signatures where Parent/Guardian CHANGED TO True
   *
   * @param newRelationshipsList     List of new Relationships
   * @param oldRelationshipsMap      Map of old Relationships
   */
	public static void createChildGuardianSignatures(List<npe4__Relationship__c> newRelationshipsList, Map<Id, npe4__Relationship__c> oldRelationshipsMap) {
		List<npe4__Relationship__c> filteredRelations = new List<npe4__Relationship__c>();
		for (npe4__Relationship__c objRelationship : newRelationshipsList) {
			if (objRelationship.Parent_Legal_Guardian__c && !oldRelationshipsMap.get(objRelationship.Id).Parent_Legal_Guardian__c) {
				filteredRelations.add(objRelationship);
			}
		}

		//Get Relationship to its List Of Affiliations
		List<Wish_Affiliation__c> childAffiliations = new List<Wish_Affiliation__c>();
		List<Wish_Affiliation__c> participantAffiliations = new List<Wish_Affiliation__c>();
		Set<Id> chapterIdSet = new Set<Id>();
		for (npe4__Relationship__c objRelationship : [
				SELECT Id,npe4__Contact__c, (
						SELECT Id, Wish__r.ContactId, Wish__r.ChapterName__c, Contact__r.Email
						FROM Wish_Affiliations__r
						WHERE Wish__r.IsClosed = FALSE AND Wish__r.ChapterName__c != NULL
						AND (Wish__r.Start_Date__c = NULL OR Wish__r.Start_Date__c >= TODAY )
				)
				FROM npe4__Relationship__c
				WHERE Id IN :filteredRelations
				AND npe4__Contact__r.Current_Age__c < :EIGHTEEN
		]) {
			for (Wish_Affiliation__c objAff : objRelationship.Wish_Affiliations__r) {
				if (objRelationship.npe4__Contact__c == objAff.Wish__r.ContactId) {
					childAffiliations.add(objAff);
					chapterIdSet.add(objAff.Wish__r.ChapterName__c);

				} else {
					participantAffiliations.add(objAff);
					chapterIdSet.add(objAff.Wish__r.ChapterName__c);
				}
			}
		}
		//Get list of Form Ids to send categorized by chapters
		Map<Id, Set<Id>> chapterToParticipantForms = new Map<Id, Set<Id>>();
		Map<Id, Set<Id>> chapterToChildForms = new Map<Id, Set<Id>>();
		for (Wish_Signature_Chapter_Form__c objForm : [
				SELECT Wish_Signature_Form__c,Chapter_Account__c,Wish_Signature_Form__r.Auto_add_for_Participant_Guardian__c,Wish_Signature_Form__r.Auto_add_for_Wish_Child_Guardian__c
				FROM Wish_Signature_Chapter_Form__c
				WHERE Chapter_Account__c IN :chapterIdSet AND
				(Wish_Signature_Form__r.Auto_add_for_Participant_Guardian__c = TRUE OR Wish_Signature_Form__r.Auto_add_for_Wish_Child_Guardian__c = TRUE)
		]) {
			if (objForm.Wish_Signature_Form__r.Auto_add_for_Participant_Guardian__c == true) {
				if (!chapterToParticipantForms.containsKey(objForm.Chapter_Account__c)) {
					chapterToParticipantForms.put(objForm.Chapter_Account__c, new Set<Id>());
				}
				chapterToParticipantForms.get(objForm.Chapter_Account__c).add(objForm.Wish_Signature_Form__c);
			}
			if (objForm.Wish_Signature_Form__r.Auto_add_for_Wish_Child_Guardian__c == true) {
				if (!chapterToChildForms.containsKey(objForm.Chapter_Account__c)) {
					chapterToChildForms.put(objForm.Chapter_Account__c, new Set<Id>());
				}
				chapterToChildForms.get(objForm.Chapter_Account__c).add(objForm.Wish_Signature_Form__c);
			}

		}

		//From existing Wish Signatures get affiliations to list of forms
		Map<Id, Set<Id>> wishAffiliationToChildFormIds = getExistingSignatures(childAffiliations);
		Map<Id, Set<Id>> wishAffiliationToParticipantFormIds = getExistingSignatures(participantAffiliations);

		Set<Id> caseIds = new Set<Id>();
		List<Wish_Required_Signature__c> wrsToInsert = new List<Wish_Required_Signature__c>();
		for (Wish_Affiliation__c objAff : childAffiliations) {
			if (!chapterToChildForms.isEmpty() && chapterToChildForms.containsKey(objAff.Wish__r.ChapterName__c)) {
				for (Id formId : chapterToChildForms.get(objAff.Wish__r.ChapterName__c)) {
					if (wishAffiliationToChildFormIds.isEmpty() || (!wishAffiliationToChildFormIds.isEmpty() && wishAffiliationToChildFormIds.containsKey(objAff.Id) && !wishAffiliationToChildFormIds.get(objAff.Id).contains(formId))) {
						//CREATE WRS
						wrsToInsert.add(createWishRequiredSignature(objAff, formId));
						caseIds.add(objAff.Wish__c);
					}
				}
			}
		}

		for (Wish_Affiliation__c objAff : participantAffiliations) {
			if (!chapterToParticipantForms.isEmpty() && chapterToParticipantForms.containsKey(objAff.Wish__r.ChapterName__c)) {
				for (Id formId : chapterToParticipantForms.get(objAff.Wish__r.ChapterName__c)) {
					if (wishAffiliationToParticipantFormIds.isEmpty() || (!wishAffiliationToParticipantFormIds.isEmpty() && wishAffiliationToParticipantFormIds.containsKey(objAff.Id) && !wishAffiliationToParticipantFormIds.get(objAff.Id).contains(formId))) {
						//CREATE WRS
						wrsToInsert.add(createWishRequiredSignature(objAff, formId));
						caseIds.add(objAff.Wish__c);
					}
				}
			}
		}
		if (wrsToInsert.isEmpty()) {
			return;
		}
		insert wrsToInsert;

		Map<Id, Set<Wish_Affiliation__c>> caseToAffiliations = getCaseToAffiliations(caseIds);

		List<Guardian_Signature__c> guardiansToInsert = new List<Guardian_Signature__c>();
		for (Wish_Required_Signature__c wishSig : [
				SELECT Id, Wish_Affiliation__c, Wish_Affiliation__r.Parent_Legal_Guardian__c, Wish_Affiliation__r.Relationship__r.npe4__Contact__r.Current_Age__c, Wish_Case__c
				FROM Wish_Required_Signature__c
				WHERE Id IN :wrsToInsert
		]) {
			if (wishSig.Wish_Affiliation__r.Parent_Legal_Guardian__c && wishSig.Wish_Affiliation__r.Relationship__r.npe4__Contact__r.Current_Age__c < EIGHTEEN) {
				for (Wish_Affiliation__c objAff : caseToAffiliations.get(wishSig.Wish_Case__c)) {
					if (objAff.Contact__c == wishSig.Wish_Affiliation__r.Relationship__r.npe4__Contact__c) {
						//CREATE Guardian Signatures
						guardiansToInsert.add(createGuardianSignature(objAff.Id, wishSig.Id));
						break;
					}
				}
			}
		}
		insert guardiansToInsert;
	}

	/**
	 * Create wish Signature for converted leads
	 *
	 * @param newCasesByLeadId      Map of new cases by lead Id
	 * @param convertedLeadsById    Map of all converted leads
	 */
	public static List<Wish_Required_Signature__c> createWishSignaturesForConvertedLeads(Map<Id, Case> newCasesByLeadId, Map<Id, Lead> convertedLeadsById) {
		List<Wish_Required_Signature__c> wrsToInsert = new List<Wish_Required_Signature__c>();
		List<Wish_Signature_Forms__c> wishForms = [
				SELECT Id
				FROM Wish_Signature_Forms__c
				WHERE Diagnosis_Verification_for_Lead_Convert__c = TRUE
				ORDER BY CreatedDate DESC
				LIMIT 1
		];
		if (wishForms.isEmpty()) {
			return wrsToInsert;
		}
		//Get Lead to Docusign Status
		Set<Id> docusignIds = new Set<Id>();
		Map<Id, List<dsfs__DocuSign_Status__c>> leadToDocusignStatus = new Map<Id, List<dsfs__DocuSign_Status__c>>();
		Map<Id, Attachment> docusignToAttachment = new Map<Id, Attachment>();
		for (dsfs__DocuSign_Status__c objDocusign : [
				SELECT Id,dsfs__Lead__c, dsfs__Completed_Date_Time__c
				FROM dsfs__DocuSign_Status__c
				WHERE dsfs__Lead__c IN :convertedLeadsById.keySet()
				AND dsfs__Subject__c = 'Diagnosis Verification Form'
				AND dsfs__Envelope_Status__c = 'Completed'
				ORDER BY CreatedDate DESC
		]) {
			if (!leadToDocusignStatus.containsKey(objDocusign.dsfs__Lead__c)) {
				leadToDocusignStatus.put(objDocusign.dsfs__Lead__c, new List<dsfs__DocuSign_Status__c>());
			}
			leadToDocusignStatus.get(objDocusign.dsfs__Lead__c).add(objDocusign);
			docusignIds.add(objDocusign.Id);
		}
		//Get Docusign to Attachment
		for (Attachment attach : [
				SELECT Id, Body,Name,Description, ParentId
				FROM Attachment
				WHERE ParentId IN :docusignIds
				ORDER BY CreatedDate DESC
				LIMIT 1
		]) {
			if (!docusignToAttachment.containsKey(attach.ParentId)) {
				docusignToAttachment.put(attach.ParentId, attach);
			}
		}
		//Get Lead to DV records
		Map<Id, List<Diagnosis_Verification__c>> leadToDV = new Map<Id, List<Diagnosis_Verification__c>>();
		for (Diagnosis_Verification__c objDocusign : [
				SELECT Id,Lead__c, CreatedDate
				FROM Diagnosis_Verification__c
				WHERE Lead__c IN :convertedLeadsById.keySet()
		]) {
			if (!leadToDV.containsKey(objDocusign.Lead__c)) {
				leadToDV.put(objDocusign.Lead__c, new List<Diagnosis_Verification__c>());
			}
			leadToDV.get(objDocusign.Lead__c).add(objDocusign);
		}
		Map<Id, List<Wish_Affiliation__c>> caseToAffiliations = new Map<Id, List<Wish_Affiliation__c>>();
		Date signedDate ;
		//Get Case tO List of Wish Affiliations
		for (Wish_Affiliation__c objAff : [
				SELECT Id,Wish__c
				FROM Wish_Affiliation__c
				WHERE Wish__c IN :newCasesByLeadId.values()
				AND Qualifying_Medical_Team_Member__c = TRUE
		]) {
			if (!caseToAffiliations.containsKey(objAff.Wish__c)) {
				caseToAffiliations.put(objAff.Wish__c, new List<Wish_Affiliation__c>());
			}
			caseToAffiliations.get(objAff.Wish__c).add(objAff);
		}
		//Get Lead to Docusign Recipient Status
		Map<Id, List<dsfs__DocuSign_Recipient_Status__c>> leadToDocusignRecipientStatus = new Map<Id, List<dsfs__DocuSign_Recipient_Status__c>>();
		for (dsfs__DocuSign_Recipient_Status__c objDocusignRecipient : [
				SELECT Id,dsfs__Lead__c, dsfs__Parent_Status_Record__r.dsfs__Lead__c, dsfs__DocuSign_Recipient_Email__c
				FROM dsfs__DocuSign_Recipient_Status__c
				WHERE dsfs__Parent_Status_Record__r.dsfs__Lead__c IN :convertedLeadsById.keySet()
				AND dsfs__Parent_Status_Record__r.dsfs__Subject__c = 'Diagnosis Verification Form'
				ORDER BY CreatedDate DESC
		]) {
			if (!leadToDocusignRecipientStatus.containsKey(objDocusignRecipient.dsfs__Lead__c)) {
				leadToDocusignRecipientStatus.put(objDocusignRecipient.dsfs__Parent_Status_Record__r.dsfs__Lead__c, new List<dsfs__DocuSign_Recipient_Status__c>());
			}
			leadToDocusignRecipientStatus.get(objDocusignRecipient.dsfs__Parent_Status_Record__r.dsfs__Lead__c).add(objDocusignRecipient);
		}
		//Create WRs for Converted Leads
		for (Lead currentLead : convertedLeadsById.values()) {
			Case currentCase = newCasesByLeadId.get(currentLead.Id);
			Wish_Required_Signature__c wrs = new Wish_Required_Signature__c();
			wrs.Wish_Case__c = currentCase.Id;
			wrs.Wish_Signature_Form__c = wishForms.isEmpty() ? null : wishForms[0].Id;
			wrs.Status__c = 'Completed';
			wrs.Type__c = 'Medical';
			wrs.Wish_Affiliation__c = caseToAffiliations.containsKey(currentCase.Id) ? caseToAffiliations.get(currentCase.Id)[0].Id : null;
			//Get the Signed Date
			if (currentLead.Part_A_Received__c != null) {
				wrs.Signed_Date__c = currentLead.Part_A_Received__c;
				signedDate = currentLead.Part_A_Received__c;
			} else if (leadToDocusignStatus.containsKey(currentLead.Id)) {
				Datetime dt = leadToDocusignStatus.get(currentLead.Id)[0].dsfs__Completed_Date_Time__c;
				wrs.Signed_Date__c = Date.newInstance(dt.year(), dt.month(), dt.day());
				signedDate = Date.newInstance(dt.year(), dt.month(), dt.day());
			} else if (leadToDV.containsKey(currentLead.Id)) {
				Datetime dt = leadToDV.get(currentLead.Id)[0].CreatedDate;
				wrs.Signed_Date__c = Date.newInstance(dt.year(), dt.month(), dt.day());
				signedDate = Date.newInstance(dt.year(), dt.month(), dt.day());
			}
			//Get Email From Docusign Recipient
			if (leadToDocusignRecipientStatus.containsKey(currentLead.Id)) {
				wrs.Sent_to_Email_Address__c = leadToDocusignRecipientStatus.get(currentLead.Id)[0].dsfs__DocuSign_Recipient_Email__c;
			}
			wrs.Sent_Date__c = currentLead.Part_A_Sent__c != null ? currentLead.Part_A_Sent__c : signedDate;
			wrs.Format__c = 'Paper';
			if (leadToDocusignStatus.containsKey(currentLead.Id)) {
				wrs.Format__c = 'E-Signature';
			}
			wrsToInsert.add(wrs);
		}
		if (wrsToInsert.isEmpty()) {
			return wrsToInsert;
		}
		insert wrsToInsert;
		//Get Lead to Attachment
		Map<Id, Attachment> leadToDocusignAttachment = new Map<Id, Attachment>();
		for (dsfs__DocuSign_Status__c objDocusign : [
				SELECT Id,dsfs__Lead__c, dsfs__Completed_Date_Time__c
				FROM dsfs__DocuSign_Status__c
				WHERE Id IN :docusignToAttachment.keySet()
		]) {
			leadToDocusignAttachment.put(objDocusign.dsfs__Lead__c, docusignToAttachment.get(objDocusign.Id));
		}
		List<dsfs__DocuSign_Status__c> updateDocusignStatus = new List<dsfs__DocuSign_Status__c>();
		List<Attachment> attachmentList = new List<Attachment>();
		for (Wish_Required_Signature__c objWrs : [
				SELECT Id, Wish_Case__r.Hidden_Lead_Id__c
				FROM Wish_Required_Signature__c
				WHERE Id IN :wrsToInsert
		]) {
			if (leadToDocusignStatus.containsKey(objWrs.Wish_Case__r.Hidden_Lead_Id__c)) {
				for (dsfs__DocuSign_Status__c objDocusignStatus : leadToDocusignStatus.get(objWrs.Wish_Case__r.Hidden_Lead_Id__c)) {
					objDocusignStatus.dsfs__Case__c = objWrs.Wish_Case__c;
					objDocusignStatus.Wish_Required_Signature__c = objWrs.Id;
					updateDocusignStatus.add(objDocusignStatus);
				}
			}
			if (leadToDocusignAttachment.containsKey(objWrs.Wish_Case__r.Hidden_Lead_Id__c)) {
				Attachment newFile = leadToDocusignAttachment.get(objWrs.Wish_Case__r.Hidden_Lead_Id__c).clone();
				newFile.ParentId = objWrs.Id;
				attachmentList.add(newFile);
			}
		}
		if (!updateDocusignStatus.isEmpty()) {
			update updateDocusignStatus;
		}
		insert attachmentList;
		return wrsToInsert;
	}

	/**
	 * Create wish required signatures records
	 *
	 * @param objWishAff  Wish Affiliation to create Signature for
	 * @param formId      Wish Signature Form Id
	 *
	 * @return           New Wish Required Signature object
	 */
	public static Wish_Required_Signature__c createWishRequiredSignature(Wish_Affiliation__c objWishAff, Id formId) {
		Wish_Required_Signature__c wrs = new Wish_Required_Signature__c();
		wrs.Wish_Case__c = objWishAff.Wish__c;
		wrs.Wish_Signature_Form__c = formId;
		wrs.Status__c = 'Not Sent';
		wrs.Type__c = 'Family';
		wrs.Wish_Affiliation__c = objWishAff.Id;
		wrs.Sent_to_Email_Address__c = objWishAff.Contact__r.Email;
		return wrs;
	}

	/**
	* Create Guardian Signature records
	*
	* @param wishAffId  Wish Affiliation Id
	* @param wrsId      Wish Required Signature Id
	*
	* @return           New Guardian Signature object
	*/
	public static Guardian_Signature__c createGuardianSignature(Id wishAffId, Id wrsId) {
		Guardian_Signature__c objGuard = new Guardian_Signature__c();
		objGuard.Signature__c = wrsId;
		objGuard.Signing_on_Behalf_Of__c = wishAffId;
		return objGuard;
	}

	/**
   * Helper method to get Chapter to all its Wish Signature Form Ids
   *
   * @param wishAffId  Wish Affiliation Id
   * @param wrsId      Wish Required Signature Id
   *
   * @return           Map of Chapter Id to Set of Froms Id
   */
	public static Map<Id, Set<Id>> getChapterToForms(Set<Id> chapterIdSet, Boolean participant, Boolean participantGuardian, Boolean wishChild, Boolean childGuardian) {
		Map<Id, Set<Id>> chapterToForms = new Map<Id, Set<Id>>();
		String query = 'SELECT Wish_Signature_Form__c,Chapter_Account__c' +
				' FROM Wish_Signature_Chapter_Form__c WHERE Chapter_Account__c IN :chapterIdSet' ;

		if (participant) {
			query += ' AND Wish_Signature_Form__r.Auto_add_for_Participant__c = True';
		} else if (participantGuardian) {
			query += ' AND Wish_Signature_Form__r.Auto_add_for_Participant_Guardian__c = True';
		} else if (wishChild) {
			query += ' AND Wish_Signature_Form__r.Auto_add_for_Wish_Child__c = True';
		} else if (childGuardian) {
			query += ' AND Wish_Signature_Form__r.Auto_add_for_Wish_Child_Guardian__c = True';
		}

		for (Wish_Signature_Chapter_Form__c objForm : Database.query(query)) {
			if (!chapterToForms.containsKey(objForm.Chapter_Account__c)) {
				chapterToForms.put(objForm.Chapter_Account__c, new Set<Id>());
			}
			chapterToForms.get(objForm.Chapter_Account__c).add(objForm.Wish_Signature_Form__c);
		}
		return chapterToForms;
	}

	/**
   * Helper method to get Existing Wish Signatures for a list of Affiliations
   *
   * @param newAffiliations  List of Wish Affiliations
   *
   * @return                Map of Wish Affiliation Id to Set of Forms sent to it already
   */
	public static Map<Id, Set<Id>> getExistingSignatures(List<Wish_Affiliation__c> newAffiliations) {
		Map<Id, Set<Id>> wishAffiliationToFormIds = new Map<Id, Set<Id>>();
		for (Wish_Required_Signature__c wrsObj : [
				SELECT Wish_Affiliation__c,Wish_Affiliation__r.Wish_Affiliation_Type__c,Wish_Signature_Form__c
				FROM Wish_Required_Signature__c
				WHERE Wish_Affiliation__c IN :newAffiliations
		]) {
			if (!wishAffiliationToFormIds.containsKey(wrsObj.Wish_Affiliation__c)) {
				wishAffiliationToFormIds.put(wrsObj.Wish_Affiliation__c, new Set<Id>());
			}
			wishAffiliationToFormIds.get(wrsObj.Wish_Affiliation__c).add(wrsObj.Wish_Signature_Form__c);
		}
		return wishAffiliationToFormIds;
	}

	/**
  * Helper method to get Case to its List of Affilaitions
  *
  * @param caseIds  Set of Case Ids
  *
  * @return         Map of Case Id to Set of Wish Affiliations
  */
	public static Map<Id, Set<Wish_Affiliation__c>> getCaseToAffiliations(Set<Id> caseIds) {
		Map<Id, Set<Wish_Affiliation__c>> caseToAffiliations = new Map<Id, Set<Wish_Affiliation__c>>();
		for (Wish_Affiliation__c objAffiliation : [
				SELECT Id, Wish__c, Contact__c
				FROM Wish_Affiliation__c
				WHERE Wish__c IN :caseIds
		]) {
			if (!caseToAffiliations.containsKey(objAffiliation.Wish__c)) {
				caseToAffiliations.put(objAffiliation.Wish__c, new Set<Wish_Affiliation__c>());
			}
			caseToAffiliations.get(objAffiliation.Wish__c).add(objAffiliation);
		}
		return caseToAffiliations;
	}

}