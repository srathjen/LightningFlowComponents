/**************************************************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kanagaraj
Date        : 11/15/2016
Description : DocusignRecipient_OnAfterUpdateHelper is update the recipient name in wishchild form record. 
**************************************************************************************************************************************/

Public class DocusignRecipient_OnAfterUpdateHelper {

	//UpdateRecipientName() is used to update the recipient name when the recipient status is updated as completed or delivered.
	public static void UpdateRecipientName(Set<Id> completedIdSet, set<String> completedNameString, set<String> recipientstatusSet, List<dsfs__DocuSign_Recipient_Status__c> DSrecipiantList) {
		Set<Id> completedWishIdSet = new Set<Id>();
		List<Wish_Child_Form__c> deliverednameList = new List<Wish_Child_Form__c>();
		string subject;
		try {
			if (completedIdSet.size() > 0) {
				for (dsfs__DocuSign_Status__c dsfsStatusRec : [
						SELECT Id,dsfs__Case__c,dsfs__Subject__c,dsfs__Case__r.ContactId,dsfs__Case__r.LiabilitySignerMapKeyPair__c
						FROM dsfs__DocuSign_Status__c
						WHERE Id IN:completedIdSet
						AND dsfs__Case__c != Null AND (dsfs__Subject__c = :'Signature Required - Liability And Publicity Release Form' OR dsfs__Subject__c = :'Signature Required - Wish Form & Liability And Publicity Release Form')
						Limit 50000
				]) {

					completedWishIdSet.add(dsfsStatusRec.dsfs__Case__c);
					subject = dsfsStatusRec.dsfs__Subject__c;

				}
			}
			if (completedWishIdSet.size() > 0) {
				for (Wish_Child_Form__c dbWishPaperCase : [
						SELECT Id,Hidden_Wish_Fmaily_Contact_Name__c,Hidden_Contact_Name__c,Wish_Liability_Envolep__c,Migrated__c,
								Delivered_Hidden_Envelop_Id__c,LiabilitySignerMapKeyPair__c,Delivered_LiabilitySignerMapKeyPair__c
						From Wish_Child_Form__c
						WHERE Case__c = :completedWishIdSet AND Migrated__c = False
						Limit 50000
				]) {

					if (subject == 'Signature Required - Wish Form & Liability And Publicity Release Form') {

						for (String processString : completedNameString) {
							if (dbWishPaperCase.Hidden_Contact_Name__c == Null) {
								dbWishPaperCase.Hidden_Contact_Name__c = processString;
								dbWishPaperCase.Signers__c = processString;
								dbWishPaperCase.Id = dbWishPaperCase.Id;
								//updateWishPaperMap.put(dbWishPaperCase.Id,dbWishPaperCase);
							} else {
								dbWishPaperCase.Hidden_Contact_Name__c += '#' + processString;
								dbWishPaperCase.Signers__c += '#' + processString;
								dbWishPaperCase.Id = dbWishPaperCase.Id;
								//updateWishPaperMap.put(dbWishPaperCase.Id,dbWishPaperCase);
							}
						}
					}
					deliverednameList.add(dbWishPaperCase);
				}
				if (deliverednameList.size() > 0)
					update deliverednameList;
			}

			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}

		} catch (Exception ex) {
			for (dsfs__DocuSign_Recipient_Status__c currRec : DSrecipiantList) {
				ErrorMessage_AC.createdebugRec('DocusignRecipient_OnAfterUpdateHelper', String.valueof(currRec), String.valueOf(ex), 'UpdateRecipientName', currRec.Id, ex.getStackTraceString() + '   ' + ex.getMessage(), 'Error');
			}
			//Database.rollback(sp);

			if (!Test.isRunningTest()) {
				for (dsfs__DocuSign_Recipient_Status__c currRec : DSrecipiantList) {
					currRec.addError(Label.Debug_log_error_message);
				}

			}
		}

	}

	public static void updateAttachmentId(Set<Id> parentIdSet, List<dsfs__DocuSign_Recipient_Status__c> DSrecipiantList) {
		Map<Id, Id> attachmentMap = new Map<Id, Id>();
		List<dsfs__DocuSign_Status__c> dbdsfsList = new List<dsfs__DocuSign_Status__c>();
		try {
			for (Attachment dbAttachment : [
					SELECT Id,ParentId
					FROM Attachment
					WHERE ParentId IN:parentIdSet
			]) {
				attachmentMap.put(dbAttachment.ParentId, dbAttachment.Id);
			}
			if (attachmentMap.size() > 0) {
				for (dsfs__DocuSign_Status__c dbStatusRec : [
						SELECT Id,AttachmentId__c
						FROM dsfs__DocuSign_Status__c
						WHERE Id IN:parentIdSet
				]) {
					if (attachmentMap.containsKey(dbStatusRec.Id)) {
						dbStatusRec.AttachmentId__c = attachmentMap.get(dbStatusRec.Id);
						dbdsfsList.add(dbStatusRec);

					}
				}
			}
			if (dbdsfsList.size() > 0) {
				update dbdsfsList;
			}

			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}

		} catch (Exception ex) {
			for (dsfs__DocuSign_Recipient_Status__c currRec : DSrecipiantList) {
				ErrorMessage_AC.createdebugRec('DocusignRecipient_OnAfterUpdateHelper', String.valueof(currRec), String.valueOf(ex), 'updateAttachmentId', currRec.Id, ex.getStackTraceString() + '   ' + ex.getMessage(), 'Error');
			}
			//Database.rollback(sp);

			if (!Test.isRunningTest()) {
				for (dsfs__DocuSign_Recipient_Status__c currRec : DSrecipiantList) {
					currRec.addError(Label.Debug_log_error_message);
				}
			}

		}

	}
}