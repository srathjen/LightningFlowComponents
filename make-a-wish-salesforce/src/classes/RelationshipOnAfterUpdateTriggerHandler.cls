/*****************************************************************************************************************
Author      : MST Solutions
Date        : 5/27/2016
Description : When a new Relationship record is updated then it will call the OnAfterInsertRelationshipTriggerHelper class based 
on the collection size() > 0.
Modification Log: 
04/18/2018 - Kanagaraj - WVC-1885
*******************************************************************************************************************/
Public class RelationshipOnAfterUpdateTriggerHandler {

	/*This method is used to once wishchild form get approved then all the relationship record are created then it will update the
	Update_Wish_Child_Form_Info__c field in case record.*/
	public static void onAfterUpdate(Map<Id, npe4__Relationship__c> newMap, Map<Id, npe4__Relationship__c> oldMap) {

		Set<id> relationshipIdSet = new Set<id>();
		List<npe4__Relationship__c> relationShipList = new List<npe4__Relationship__c>();
		Map<Id, Id> relationShipOldMap = new Map<Id, Id>();
		Map<Id, Id> siblingMap = new Map<Id, Id>();
		Map<Id, npe4__Relationship__c> relationShipNewMap = new Map<Id, npe4__Relationship__c>();
		Map<Id, npe4__Relationship__c > relationShipMap = new Map<Id, npe4__Relationship__c>();
		for (npe4__Relationship__c newRecord : newMap.Values()) {
			if ((newRecord.npe4__Contact__c != Null) && (newRecord.Wish_Participant__c != oldMap.get(newRecord.Id).Wish_Participant__c) ||
					(newRecord.Parent_Legal_Guardian__c != oldMap.get(newRecord.Id).Parent_Legal_Guardian__c) || (newRecord.Under_18__c != oldMap.get(newRecord.Id).Wish_Participant__c) ||
					newRecord.npe4__Type__c != oldMap.get(newRecord.Id).npe4__Type__c) {
				relationshipIdSet.add(newRecord .npe4__Contact__c);
				relationShipList.add(newRecord);
			}

			if (oldMap.get(newRecord.Id).npe4__Type__c == 'Sibling' && newRecord.npe4__Type__c != 'Sibling') {
				siblingMap.put(newRecord.npe4__RelatedContact__c, newRecord.npe4__Contact__c);
			}

			/*if(newRecord.npe4__RelatedContact__c != Null && newRecord.npe4__RelatedContact__c != oldMap.get(newRecord.Id).npe4__RelatedContact__c){
				relationShipOldMap.put(oldMap.get(newRecord.Id).npe4__RelatedContact__c,newRecord.npe4__RelatedContact__c);
				relationShipNewMap.put(newRecord.npe4__RelatedContact__c,newRecord);
			}*/
			/**
			 * JIRA: WLP-291
			 * Author: Gustavo Mayer
			 * Update: Non_Comped, Medical_Needs, Send_Wish_Forms__c and Residing_with_Wish_child__c
			 * to reside on Wish Affiliation object and to be removed from npe4__Relationship__c.
			 */
			if ((newRecord.npe4__Contact__c != null && newRecord.npe4__RelatedContact__c != null)
					|| (newRecord.Wish_Participant__c != oldMap.get(newRecord.Id).Wish_Participant__c)
					|| (newRecord.Parent_Legal_Guardian__c != oldMap.get(newRecord.Id).Parent_Legal_Guardian__c)
//					|| (newRecord.Residing_with_Wish_child__c != oldMap.get(newRecord.Id).Residing_with_Wish_child__c)
					|| (newRecord.npe4__Type__c != oldMap.get(newRecord.Id).npe4__Type__c)) {
				relationShipMap.put(newRecord.npe4__RelatedContact__c, newRecord);
			}

			if (newRecord.npe4__Contact__c != null
					&& newRecord.npe4__RelatedContact__c != null
					&& (oldMap.get(newRecord.Id).Parent_Legal_Guardian__c == false
					&& oldMap.get(newRecord.Id).Wish_Participant__c == false)
					&& (newRecord.Wish_Participant__c == true || newRecord.Parent_Legal_Guardian__c == true)) {
				siblingMap.put(newRecord.npe4__RelatedContact__c, newRecord.npe4__Contact__c);
			}

		}

		if (relationshipIdSet.size() > 0 && RecursiveTriggerHandler.relationShipRecursive == true) {
			RelationshipOnAfterInsertTriggerHelper.updateApprovedCase(relationshipIdSet, relationShipList);
		}
		if (relationShipMap.size() > 0) {
			RelationshipOnAfterUpdateTriggerHelper.updateWishFormRecord(relationShipMap);
		}
		if (relationShipOldMap.size() > 0 && relationShipNewMap.size() > 0) {
			//RelationshipOnAfterUpdateTriggerHelper.updateContactId(relationShipOldMap,relationShipNewMap);
		}
		if (siblingMap.size() > 0) {
			RelationshipOnAfterInsertTriggerHelper.createWishFormRecord(siblingMap);
		}
	}
}