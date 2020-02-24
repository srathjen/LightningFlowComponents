/**
 * @description Wish Signature Controller, exposes methods for the front end components.
 * @author Mitali Nahar, Traction on Demand
 * @createdDate 6/18/2019
 */
public without sharing class WishSignatureController {

	/**
	 * Find Wish Signature Forms
	 * @param caseId
	 * @param formType
	 * @return List of Wish Signature Forms
	 */
	@AuraEnabled
	public static List<Wish_Signature_Forms__c> getWishSignatureForms(Id caseId, String formType) {
		Case objCase = [
				SELECT ChapterName__c
				FROM Case
				WHERE Id = :caseId
		];
		Set<Id> wishSignFormId = new Set<Id>();
		//Get Wish Signature Chapter forms for a Case
		for (Wish_Signature_Chapter_Form__c obj : [
				SELECT Chapter_Account__c, Wish_Signature_Form__c
				FROM Wish_Signature_Chapter_Form__c
				WHERE Chapter_Account__c = :objCase.ChapterName__c
		]) {
			wishSignFormId.add(obj.Wish_Signature_Form__c);
		}
		//Get Medical and Non-Medical Wish Signature Forms belonging to a Chapter
		String sQuery = '';
		sQuery = 'select id ' + ', Name from Wish_Signature_Forms__c where Id In : wishSignFormId AND Active__c = True';
		if (formType.equals('Medical')) {
			sQuery += ' AND Form_Type__c =' + '\'Medical\'';
		} else {
			sQuery += ' AND Form_Type__c != ' + '\'Medical\'';
		}
		sQuery += ' order by Name';
		List <SObject> lstOfRecords = Database.query(sQuery);
		return (List<Wish_Signature_Forms__c>) lstOfRecords;
	}

	/**
	 * Find Wish Affiliations(except Medical) for a Case
	 * @param caseId
	 * @return List of wrapper class
	 */
	@AuraEnabled
	public static List<childWrapper> getWishAffiliations(Id caseId) {
		try {
			if (caseId != null) {
				List<childWrapper> wrapperList = new List<childWrapper>();
				List<childWrapper> minorsList = new List<childWrapper>();
				//Get a List of all adults and minors related to the case and put in WrapperList
				for (Wish_Affiliation__c obj : [
						SELECT Id,Under_18__c,Contact__c,Contact__r.LastName,Contact__r.FirstName,Related_To__c,Relationship__r.npe4__Contact__r.FirstName,
								Relationship__r.npe4__Contact__r.LastName,Parent_Legal_Guardian__c,Relationship_Type__c,Wish_Affiliation_Type__c,Send_Clearance_Forms_To__c,Best_Medical_Contact__c
						FROM Wish_Affiliation__c
						WHERE Wish__c = :caseId AND Wish_Affiliation_Type__c != :Constant_AC.WISH_AFFILIATION_TYPE_MEDICAL_PROFESSIONAL
				]) {
					childWrapper objChild = new childWrapper();
					objChild.wishAff = obj;
					objChild.con = new Contact(Id = obj.Contact__c, LastName = obj.Contact__r.LastName, FirstName = obj.Contact__r.FirstName);
					if (obj.Under_18__c == 'No' || obj.Under_18__c == 'No Birthdate Recorded') {
						wrapperList.add(objChild);
					} else if (obj.Under_18__c == 'Yes') {
						minorsList.add(objChild);
					}
				}
				for (childWrapper obj : wrapperList) {
					obj.lstMinors = minorsList;
				}
				return wrapperList;
			}
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
		return null;
	}

	/**
	 * Find Medical Wish Affiliations ofr a Case
	 * @param caseId
	 * @return List of wrapper class
	 */
	@AuraEnabled
	public static List<childWrapper> getWishAffiliationsMedical(Id caseId) {
		try {
			if (caseId != null) {
				List<childWrapper> wrapperList = new List<childWrapper>();
				//Get a List of all medical professionals related to the case and put in WrapperList
				for (Wish_Affiliation__c obj : [
						SELECT Id,Medical_Professional_Status__c,Contact__c,Contact__r.LastName,Contact__r.FirstName,Best_Medical_Contact__c, Send_Clearance_Forms_To__c
						FROM Wish_Affiliation__c
						WHERE Wish__c = :caseId AND Wish_Affiliation_Type__c = :Constant_AC.WISH_AFFILIATION_TYPE_MEDICAL_PROFESSIONAL
				]) {
					childWrapper objChild = new childWrapper();
					objChild.wishAff = obj;
					objChild.con = new Contact(Id = obj.Contact__c, LastName = obj.Contact__r.LastName, FirstName = obj.Contact__r.FirstName);
					wrapperList.add(objChild);
				}
				return wrapperList;
			}
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
		return null;
	}

	/**
	 * Save Medical Wish Signatures
	 * @param adultsIdList
	 * @param caseId
	 * @param formId
	 */
	@AuraEnabled
	public static void saveMedicalWishSignatures(String adultsIdList, String caseId, String formId) {
		try {
			List<AdultWrapData> objAdultDataList = (List<AdultWrapData>) JSON.deserialize(adultsIdList, List<AdultWrapData>.class);
			Set<Id> wishAffIdSet = new Set<Id>();
			List<Wish_Required_Signature__c> wrsToInsert = new List<Wish_Required_Signature__c>();
			//Create Wish Required Signature records and Insert them
			if (objAdultDataList != null && !objAdultDataList.isEmpty()) {
				for (AdultWrapData obj : objAdultDataList) {
					wishAffIdSet.add(obj.wishAff);
				}
			}
			List<Wish_Affiliation__c> wishAffiliations = [
					SELECT Id, Contact__r.Email
					FROM Wish_Affiliation__c
					WHERE Id In:wishAffIdSet
			];
			wrsToInsert = createWRSRecord('Medical', wishAffiliations, caseId, formId);
			if (!wrsToInsert.isEmpty()) {
				insert wrsToInsert;
			}
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * Build new Wish Signatures records
	 * @param type
	 * @param wishAffiliations
	 * @param caseId
	 * @param formId
	 * @return List of Wish Required Signature to be inserted
	 */
	private static List<Wish_Required_Signature__c> createWRSRecord(String type, List<Wish_Affiliation__c> wishAffiliations, Id caseId, Id formId) {
		Wish_Signature_Forms__c wishForm = [
				SELECT Days_From_Signature_to_Expiry__c
				FROM Wish_Signature_Forms__c
				WHERE Id = :formId
		];
		List<Wish_Required_Signature__c> wrsToInsert = new List<Wish_Required_Signature__c>();
		for (Wish_Affiliation__c wishAff : wishAffiliations) {
			Wish_Required_Signature__c wrs = new Wish_Required_Signature__c();
			wrs.Wish_Case__c = caseId;
			wrs.Wish_Signature_Form__c = formId;
			wrs.Status__c = 'Not Sent';
			wrs.Days_From_Signature_to_Expiry__c = wishForm.Days_From_Signature_to_Expiry__c;
			wrs.Type__c = type;
			wrs.Wish_Affiliation__c = wishAff.Id;
			wrs.Sent_to_Email_Address__c = wishAff.Contact__r.Email;
			wrsToInsert.add(wrs);
		}
		return wrsToInsert;
	}

	/**
	 * Save Wish Family Wish Signatures
	 * @param adultsIdList
	 * @param adultsToChildIds
	 * @param caseId
	 * @param formId
	 */
	@AuraEnabled
	public static void saveFamilyWishSignatures(String adultsIdList, String adultsToChildIds, String caseId, String formId) {
		try {
			Set<Id> adultsIds = new Set<Id>();
			Map<Id, Wish_Affiliation__c> adultToWishAff = new Map<Id, Wish_Affiliation__c>();
			//Parse the list of adults and minors
			List<AdultWrapData> adultDataList = (List<AdultWrapData>) JSON.deserialize(adultsIdList, List<AdultWrapData>.class);
			List<AdultMinorWrapData> adultMinorDataList = (List<AdultMinorWrapData>) JSON.deserialize(adultsToChildIds, List<AdultMinorWrapData>.class);

			//Get a list of adults Ids selected via Self/Minors
			if (adultDataList != null && !adultDataList.isEmpty()) {
				for (AdultWrapData obj : adultDataList) {
					adultsIds.add(obj.adult);
				}
			}
			if (adultMinorDataList != null && !adultMinorDataList.isEmpty()) {
				for (AdultMinorWrapData obj : adultMinorDataList) {
					adultsIds.add(obj.adult);
				}
			}
			//Get Wish Affiliations of selected adults
			for (Wish_Affiliation__c wishAffiliation : [
					SELECT Id, Contact__c, Contact__r.Email
					FROM Wish_Affiliation__c
					WHERE Contact__c In :adultsIds
			]) {
				adultToWishAff.put(wishAffiliation.Contact__c, wishAffiliation);
			}
			//Create Wish Required Signature records and Insert them
			Map<Id, Id> mapWishAffToWRS = new Map<Id, Id>();
			Set<Id> wishAffIdSet = new Set<Id>();
			List<Wish_Required_Signature__c> wrsToInsert = new List<Wish_Required_Signature__c>();
			wrsToInsert = createWRSRecord('Family', adultToWishAff.values(), caseId, formId);
			if (!wrsToInsert.isEmpty()) {
				insert wrsToInsert;
			}
			if (!wrsToInsert.isEmpty()) {
				//Get Ids of WRSs just created to created corresponding Guardian records
				for (Wish_Required_Signature__c wishReqSigns : [
						SELECT Id,Wish_Affiliation__c,Wish_Affiliation__r.Contact__c
						FROM Wish_Required_Signature__c
						WHERE Id In :wrsToInsert
				]) {
					mapWishAffToWRS.put(wishReqSigns.Wish_Affiliation__r.Contact__c, wishReqSigns.Id);
				}
				//Create junction Guardian Signature records and insert them
				List<Guardian_Signature__c> guardiansToInsert = new List<Guardian_Signature__c>();
				if (adultMinorDataList != null && !adultMinorDataList.isEmpty()) {
					for (AdultMinorWrapData obj : adultMinorDataList) {
						if (!mapWishAffToWRS.isEmpty() && mapWishAffToWRS.containsKey(obj.adult)) {
							Guardian_Signature__c gs = new Guardian_Signature__c();
							gs.Signature__c = mapWishAffToWRS.get(obj.adult);
							gs.Signing_on_Behalf_Of__c = obj.wishAffMinor;
							guardiansToInsert.add(gs);
						}
					}
				}
				if (!guardiansToInsert.isEmpty()) {
					insert guardiansToInsert;
				}
			}
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	//Wrapper class to hold response of Adults and their related minors - This response is used in the lightning:accordion component
	public class childWrapper {
		@AuraEnabled
		public Boolean isSelected { get; set; }
		@AuraEnabled
		public Contact con { get; set; }
		@AuraEnabled
		public Wish_Affiliation__c wishAff { get; set; }
		@AuraEnabled
		public List<childWrapper> lstMinors { get; set; }

		public childWrapper() {
			this.isSelected = false;
			this.con = new Contact();
			this.wishAff = new Wish_Affiliation__c();
			this.lstMinors = new List<childWrapper>();
		}
	}

	//Wrapper class to hold Adult and its Wish Affiliation Id
	public class AdultWrapData {
		public String adult;
		public String wishAff;
	}

	//Wrapper class to hold response of Adult, Minor and its Wish Affiliation Id
	public class AdultMinorWrapData {
		public String adult;
		public String minor;
		public String wishAffMinor;
	}

	//Wrapper class to hold Signature Forms data
	public class FormOptionsData {
		public String label;
		public Id value;
	}
}