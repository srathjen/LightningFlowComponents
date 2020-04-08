global class BatchRelationshipRecUpdate implements Database.Batchable<SObject> {

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator([
				SELECT Id, ContactId
				FROM Case
				WHERE RecordType.Name = :Constant_AC.CASE_RECORD_TYPE_WISH
				AND Status != :Constant_AC.CASE_STATUS_COMPLETED
		]);
	}

	global void execute(Database.BatchableContext BC, List<Case> caseList) {
		Id familyContactRecordTypeId = Constant_AC.WISH_FORM_FAMILY_ID;
		Map<Id, Id> wishFormMap = new Map<Id, Id>();
		Map<Id, Id> caseMap = new Map<Id, Id>();
		List<Wish_Child_Form__c> wishFormList = new List<Wish_Child_Form__c >();

		Set<Id> caseIdSet = new Set<Id>();
		for (Case dbProcess : caseList) {
			caseIdSet.add(dbProcess.Id);
		}

		for (Wish_Child_Form__c dbWishChild : [
				SELECT Id,RecordTypeId,RecordType.Name,Case__c,Contact__c,Case__r.ContactId
				FROM Wish_Child_Form__c
				WHERE RecordType.Name = :Constant_AC.WISH_FORM_FAMILY_LABEL
				AND Contact__c != NULL
				AND Case__c IN:caseIdSet
		]) {
			wishFormMap.put(dbWishChild.Contact__c, dbWishChild.Case__r.ContactId);
			caseMap.put(dbWishChild.Case__r.ContactId, dbWishChild.Case__c);
		}

		for (npe4__Relationship__c currRel : [
				SELECT Id, npe4__RelatedContact__c, Parent_Legal_Guardian__c, Wish_Participant__c,
						npe4__RelatedContact__r.FirstName, npe4__RelatedContact__r.LastName,
						npe4__RelatedContact__r.Email, Hidden_isparentFirst__c,
						npe4__RelatedContact__r.Phone, npe4__RelatedContact__r.Middle_Name__c,
						npe4__RelatedContact__r.MailingCity, npe4__RelatedContact__r.MailingStreet,
						npe4__RelatedContact__r.MailingState, npe4__RelatedContact__r.MailingPostalCode,
						npe4__Type__c, npe4__RelatedContact__r.HomePhone, npe4__RelatedContact__r.npe01__WorkPhone__c,
						npe4__RelatedContact__r.MobilePhone, npe4__RelatedContact__r.Birthdate,
						npe4__RelatedContact__r.T_Shirt_Size__c,npe4__RelatedContact__r.RecordType.Name,
						npe4__Contact__c,npe4__Contact__r.RecordTypeId, npe4__Contact__r.RecordType.Name
				FROM npe4__Relationship__c
				WHERE npe4__Contact__r.RecordType.Name = :Constant_AC.CONTACT_WISH_CHILD_RT_LABEL
				AND npe4__RelatedContact__r.RecordType.Name = :Constant_AC.WISH_FAMILY_RT_LABEL
				AND npe4__Contact__c IN:caseMap.keySet()
		]) {
			if ((!wishFormMap.containsKey(currRel.npe4__RelatedContact__c))
					&& (caseMap.containsKey(currRel.npe4__Contact__c))) {
				Wish_Child_Form__c newWishFormRec = new Wish_Child_Form__c();
				newWishFormRec.FirstName__c = currRel.npe4__RelatedContact__r.FirstName;
				newWishFormRec.Middle_Name__c = currRel.npe4__RelatedContact__r.Middle_Name__c;
				newWishFormRec.LastName__c = currRel.npe4__RelatedContact__r.LastName;
				newWishFormRec.mobilePhone__c = currRel.npe4__RelatedContact__r.MobilePhone;
				newWishFormRec.BirthDate__c = currRel.npe4__RelatedContact__r.Birthdate;
				newWishFormRec.Email__c = currRel.npe4__RelatedContact__r.Email;
				newWishFormRec.City__c = currRel.npe4__RelatedContact__r.MailingCity;
				newWishFormRec.Street__c = currRel.npe4__RelatedContact__r.MailingStreet;
				newWishFormRec.State__c = currRel.npe4__RelatedContact__r.MailingState;
				newWishFormRec.Zip_Code__c = currRel.npe4__RelatedContact__r.MailingPostalCode;
				newWishFormRec.Emergency_Relationship__c = currRel.npe4__Type__c;
				newWishFormRec.Home_Phone__c = currRel.npe4__RelatedContact__r.HomePhone;
				newWishFormRec.TelePhone__c = currRel.npe4__RelatedContact__r.npe01__WorkPhone__c;
				newWishFormRec.T_Shirt_Size__c = currRel.npe4__RelatedContact__r.T_Shirt_Size__c;
				newWishFormRec.Case__c = caseMap.get(currRel.npe4__Contact__c);
				newWishFormRec.RecordTypeId = familyContactRecordTypeId;
				newWishFormRec.Contact__c = currRel.npe4__RelatedContact__c;
				if (currRel.Wish_Participant__c && !currRel.Parent_Legal_Guardian__c) {
					newWishFormRec.IsParticipant__c = true;
				}
				if (currRel.Parent_Legal_Guardian__c && currRel.Wish_Participant__c) {
					newWishFormRec.Hidden_Same_as_Family__c = true;
				}
				wishFormList.add(newWishFormRec);
			}
		}
		insert wishFormList;
	}

	global void finish(Database.BatchableContext BC) {
	}
}
