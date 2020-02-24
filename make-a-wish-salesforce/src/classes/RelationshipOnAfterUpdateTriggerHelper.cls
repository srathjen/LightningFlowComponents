/*****************************************************************************************************************
Author      : MST Solutions
Date        : 5/27/2016
Description : When a relationship record gets updated then it should update on wish form record also.
Modification Log: 
07/09/2018 - Kanagaraj - WVC-2082
*******************************************************************************************************************/

public class RelationshipOnAfterUpdateTriggerHelper {

	private final static Id wishFormRecordTypeId = Constant_AC.WISH_FORM_FAMILY_ID;

	public static void updateWishFormRecord(Map<Id, npe4__Relationship__c> relationShipMap) {
		List<Wish_Child_Form__c> updateWishFormRec = new List<Wish_Child_Form__c >();
		List<Wish_Child_Form__c> deleteWishFormList = new List<Wish_Child_Form__c>();
		if (relationShipMap.size() > 0) {
			for (Wish_Child_Form__c dbWishFormRec : [
					SELECT Id,Contact__c,Emergency_Relationship__c,Residing_With_Wish_Child__c,
							RecordTypeId,Hidden_Same_as_Family__c,Migrated__c,IsParticipant__c
					FROM Wish_Child_Form__c
					WHERE Contact__c IN:relationShipMap.keySet() AND
					RecordTypeId = :wishFormRecordTypeId AND Migrated__c = FALSE
			]) {

				if (relationShipMap.containsKey(dbWishFormRec.Contact__c)) {

					dbWishFormRec.Id = dbWishFormRec.Id;
					dbWishFormRec.Emergency_Relationship__c = relationShipMap.get(dbWishFormRec.Contact__c).npe4__Type__c;
					/**
					 * WLP-388 Deprecate Residing_with_Wish_child__c field on Relationship 
					 */
//					dbWishFormRec.Residing_With_Wish_Child__c = relationShipMap.get(dbWishFormRec.Contact__c).Residing_with_Wish_child__c;
					if (relationShipMap.get(dbWishFormRec.Contact__c).Parent_Legal_Guardian__c == true
							&& relationShipMap.get(dbWishFormRec.Contact__c).Wish_Participant__c == true) {
						dbWishFormRec.Hidden_Same_as_Family__c = true;
						dbWishFormRec.IsParticipant__c = false;
					} else if (relationShipMap.get(dbWishFormRec.Contact__c).Parent_Legal_Guardian__c == true
							&& relationShipMap.get(dbWishFormRec.Contact__c).Wish_Participant__c == false) {
						dbWishFormRec.Hidden_Same_as_Family__c = false;
						dbWishFormRec.IsParticipant__c = false;
					}

					else if (relationShipMap.get(dbWishFormRec.Contact__c).Parent_Legal_Guardian__c == false
							&& relationShipMap.get(dbWishFormRec.Contact__c).Wish_Participant__c == true) {
						dbWishFormRec.Hidden_Same_as_Family__c = false;
						dbWishFormRec.IsParticipant__c = true;
					}

					else if (relationShipMap.get(dbWishFormRec.Contact__c).Parent_Legal_Guardian__c == false
							&& relationShipMap.get(dbWishFormRec.Contact__c).Wish_Participant__c == false) {
						deleteWishFormList.add(dbWishFormRec);
					}

					updateWishFormRec.add(dbWishFormRec);
				}
			}
		}
		if (updateWishFormRec.size() > 0) {
			update updateWishFormRec;
		}
		if (deleteWishFormList.size() > 0) {
			delete deleteWishFormList;
		}
	}
	/* Functionality commented
	public static void updateContactId(Map<Id,Id> oldRelationShipMap,Map<Id,npe4__Relationship__c> newRelationShipMap){
		Set<Id> newRelatedContactIdSet = new Set<Id>();
		Map<Id,Contact> newContactMap = new Map<Id,Contact>();
		List<Wish_Child_Form__c> wishFormList = new List<Wish_Child_Form__c>();
		List<Contact> contactList = new List<Contact>();
		Map<Id,Wish_Child_Form__c> wishFormMap = new Map<Id,Wish_Child_Form__c>();
		if(oldRelationShipMap.size() > 0 && newRelationShipMap.size() > 0){

			 for(Contact dbNewContact : [SELECT Id,FirstName,LastName,Middle_Name__c,MobilePhone,Email,Mailingcity,MailingStreet,MailingState,MailingPostalCode,
										HomePhone,npe01__WorkPhone__c,T_Shirt_Size__c,Relationship__c,Hidden_Wish_Form_Id__c FROM Contact WHERE Id In: oldRelationShipMap.Values()]){
				 newContactMap.put(dbNewContact.Id,dbNewContact);
			 }

			for(Wish_Child_Form__c newFamilyCon : [SELECT Id,Contact__c,Case__c,Emergency_Relationship__c,Residing_With_Wish_Child__c,RecordTypeId,Hidden_Same_as_Family__c,
													IsParticipant__c  FROM Wish_Child_Form__c  WHERE Contact__c IN: oldRelationShipMap.keySet() AND RecordTypeId =: wishFormRecordTypeId])
			{
			   if(oldRelationShipMap.containsKey(newFamilyCon.Contact__c)){
				   newFamilyCon.Contact__c = oldRelationShipMap.get(newFamilyCon.Contact__c);
				   newFamilyCon.FirstName__c = newContactMap.get(newFamilyCon .Contact__c).FirstName;
				   newFamilyCon.Middle_Name__c = newContactMap.get(newFamilyCon .Contact__c).Middle_Name__c;
				   newFamilyCon.LastName__c  = newContactMap.get(newFamilyCon .Contact__c).LastName;
				   newFamilyCon.mobilePhone__c = newContactMap.get(newFamilyCon .Contact__c).MobilePhone;
				   newFamilyCon.Email__c =  newContactMap.get(newFamilyCon .Contact__c).Email;
				   newFamilyCon.city__c  = newContactMap.get(newFamilyCon .Contact__c).Mailingcity;
				   newFamilyCon.Street__c = newContactMap.get(newFamilyCon .Contact__c).MailingStreet;
				   newFamilyCon.State__c = newContactMap.get(newFamilyCon .Contact__c).MailingState;
				   newFamilyCon.Zip_code__c = newContactMap.get(newFamilyCon .Contact__c).MailingPostalCode;
				   newFamilyCon.Home_Phone__c =  newContactMap.get(newFamilyCon .Contact__c).HomePhone;
				   newFamilyCon.TelePhone__c =  newContactMap.get(newFamilyCon .Contact__c).npe01__WorkPhone__c;
				   newFamilyCon.T_Shirt_Size__c = newContactMap.get(newFamilyCon .Contact__c).T_Shirt_Size__c;
				   newFamilyCon.RecordTypeId = wishFormRecordTypeId;

				   newFamilyCon.Case__c = newFamilyCon.Case__c ;
				   if(newRelationShipMap.containsKey(newFamilyCon.Contact__c)){
					   newFamilyCon.Emergency_Relationship__c = newRelationShipMap.get(newFamilyCon.Contact__c).npe4__Type__c;
					   newFamilyCon.Residing_With_Wish_Child__c = newRelationShipMap.get(newFamilyCon.Contact__c).Residing_With_Wish_Child__c;
					   if(newRelationShipMap.get(newFamilyCon.Contact__c).Parent_Legal_Guardian__c == true && newRelationShipMap.get(newFamilyCon.Contact__c).Wish_Participant__c == true){
					   newFamilyCon.IsParticipant__c = false;
					   newFamilyCon.Hidden_Same_as_Family__c = true;
					   }
					   else if(newRelationShipMap.get(newFamilyCon.Contact__c).Parent_Legal_Guardian__c == true && newRelationShipMap.get(newFamilyCon.Contact__c).Wish_Participant__c == false){
					   newFamilyCon.IsParticipant__c = false;
					   newFamilyCon.Hidden_Same_as_Family__c = false;
					   }
					   else if(newRelationShipMap.get(newFamilyCon.Contact__c).Parent_Legal_Guardian__c == false && newRelationShipMap.get(newFamilyCon.Contact__c).Wish_Participant__c == true){
					   newFamilyCon.IsParticipant__c = true;
					   newFamilyCon.Hidden_Same_as_Family__c = false;
					   }
			   }
			 }
			 wishFormList.add(newFamilyCon);
			 wishFormMap.put(newFamilyCon.Contact__c,newFamilyCon);
			}
			for(Contact dbContact : newContactMap.Values()){
				if(wishFormMap.containsKey(dbContact.Id)){
					dbContact.Hidden_Wish_Form_Id__c = wishFormMap.get(dbContact.Id).Id;
					dbContact.Relationship__c =  wishFormMap.get(dbContact.Id).Emergency_Relationship__c;
					dbContact.Residing_with_Wish_child__c =  wishFormMap.get(dbContact.Id).Residing_With_Wish_Child__c;
					contactList.add(dbContact);
				}
			}
			for(Contact dbOldContact : [SELECT Id,Hidden_Wish_Form_Id__c From Contact WHERE Id IN: oldRelationShipMap.KeySet()]){
				if(oldRelationShipMap.containsKey(dbOldContact.Id)){
					dbOldContact .Hidden_Wish_Form_Id__c = null;
					 contactList.add(dbOldContact );
				}
			}
			if(wishFormList.size() > 0)
			update wishFormList;
			if(contactList.size() > 0)
			update contactList;
		}
	}
	*/
}