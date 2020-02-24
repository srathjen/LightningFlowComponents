global class BatchRelationshipRecUpdate implements Database.Batchable<SObject> {

	global Database.QueryLocator start(Database.BatchableContext BC) {

		return Database.getQueryLocator([
				SELECT Id, ContactId
				FROM Case
				WHERE RecordType.Name = 'Wish' AND Status != 'Completed'
		]);
	}

	global void execute(Database.BatchableContext BC, List<Case> caseList) {
		Id familyContactRecordTypeId = Constant_AC.WISH_FORM_FAMILY_ID;
		Map<Id, Id> wishFormMap = new Map<Id, Id>();
		Map<Id, Id> caseMap = new Map<Id, Id>();
		List<Wish_Child_Form__c> dbWishChildFormList = new List<Wish_Child_Form__c >();
		Set<Id> caseIdSet = new Set<Id>();
		for (Case dbProcess : caseList) {
			caseIdSet.add(dbProcess.Id);
		}

		for (Wish_Child_Form__c dbWishChild : [
				SELECT Id,RecordTypeId,RecordType.Name,Case__c,Contact__c,Case__r.contactId
				FROM Wish_Child_Form__c
				WHERE RecordType.Name = :'Wish Form Family' AND Contact__c != Null
				AND Case__c IN:caseIdSet
		]) {

			wishFormMap.put(dbWishChild.Contact__c, dbWishChild.Case__r.contactId);
			caseMap.put(dbWishChild.Case__r.contactId, dbWishChild.Case__c);
		}
		/**
		  * JIRA: WLP-291
		  * Author: Gustavo Mayer
		  * Update: Non-Comped, Medical_Needs, Send_Wish_Forms__c and Residing_with_Wish_child__c
		  * to reside on Wish Affiliation object and to be removed from npe4__Relationship__c.
		  */
		for (npe4__Relationship__c currRel : [
				SELECT Id, npe4__RelatedContact__c, Parent_Legal_Guardian__c, Wish_Participant__c, npe4__RelatedContact__r.FirstName,
						npe4__RelatedContact__r.LastName, npe4__RelatedContact__r.Email, Hidden_isparentFirst__c,
						npe4__RelatedContact__r.Phone, npe4__RelatedContact__r.Middle_Name__c,
						npe4__RelatedContact__r.MailingCity, npe4__RelatedContact__r.MailingStreet,
						npe4__RelatedContact__r.MailingState, npe4__RelatedContact__r.MailingPostalCode,
						npe4__Type__c, npe4__RelatedContact__r.HomePhone, npe4__RelatedContact__r.npe01__WorkPhone__c,
						npe4__RelatedContact__r.MobilePhone, npe4__RelatedContact__r.BirthDate,
//						npe4__RelatedContact__r.Residing_with_Wish_child__c,
						npe4__RelatedContact__r.T_Shirt_Size__c,npe4__RelatedContact__r.RecordType.Name,
						npe4__Contact__c,npe4__Contact__r.RecordTypeId, npe4__Contact__r.RecordType.Name
				FROM npe4__Relationship__c
				WHERE npe4__Contact__r.RecordType.Name = :Constant_AC.CONTACT_WISH_CHILD_RT_LABEL AND
				npe4__RelatedContact__r.RecordType.Name = :Constant_AC.WISH_FAMILY_RT_LABEL AND npe4__Contact__c IN:caseMap.KeySet()
		]) {

			if ((!wishFormMap.containsKey(currRel.npe4__RelatedContact__c)) && (caseMap.containsKey(currRel.npe4__Contact__c))) {

				Wish_Child_Form__c newWishFormRec = new Wish_Child_Form__c();
				newWishFormRec.FirstName__c = currRel.npe4__RelatedContact__r.FirstName;
				newWishFormRec.Middle_Name__c = currRel.npe4__RelatedContact__r.Middle_Name__c;
				newWishFormRec.LastName__c = currRel.npe4__RelatedContact__r.LastName;
				newWishFormRec.mobilePhone__c = currRel.npe4__RelatedContact__r.MobilePhone;
				newWishFormRec.BirthDate__c = currRel.npe4__RelatedContact__r.BirthDate;
				newWishFormRec.Email__c = currRel.npe4__RelatedContact__r.Email;
				newWishFormRec.city__c = currRel.npe4__RelatedContact__r.Mailingcity;
				newWishFormRec.Street__c = currRel.npe4__RelatedContact__r.Mailingstreet;
				newWishFormRec.State__c = currRel.npe4__RelatedContact__r.MailingState;
				newWishFormRec.Zip_code__c = currRel.npe4__RelatedContact__r.MailingPostalCode;
				newWishFormRec.Emergency_Relationship__c = currRel.npe4__Type__c;
				newWishFormRec.Home_Phone__c = currRel.npe4__RelatedContact__r.HomePhone;
				newWishFormRec.TelePhone__c = currRel.npe4__RelatedContact__r.npe01__WorkPhone__c;
				newWishFormRec.T_Shirt_Size__c = currRel.npe4__RelatedContact__r.T_Shirt_Size__c;
				newWishFormRec.Case__c = caseMap.get(currRel.npe4__Contact__c);
				newWishFormRec.RecordTypeId = familyContactRecordTypeId;
				newWishFormRec.Contact__c = currRel.npe4__RelatedContact__c;
				if (currRel.Wish_Participant__c == true && currRel.Parent_Legal_Guardian__c == false)
					newWishFormRec.IsParticipant__c = true;
				if (currRel.Parent_Legal_Guardian__c == true && currRel.Wish_Participant__c == true)
					newWishFormRec.Hidden_Same_as_Family__c = true;
//				newWishFormRec.Residing_With_Wish_Child__c = currRel.npe4__RelatedContact__r.Residing_with_Wish_child__c;
				dbWishChildFormList.add(newWishFormRec);
			}

		}

		if (dbWishChildFormList.size() > 0)
			insert dbWishChildFormList;
	}

	global void finish(Database.BatchableContext BC) {

	}
}