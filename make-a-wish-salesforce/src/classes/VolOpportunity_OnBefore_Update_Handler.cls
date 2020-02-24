/*****************************************************************************************************************
Author      : MST Solutions
Date        : 5/27/2016
Description : When a new Volunteer Opportunity record updated then it will update the values to corresponding fields.
Modification Log: 
04/17/2018 - Kanagaraj - WVC-1885
*******************************************************************************************************************/

public class VolOpportunity_OnBefore_Update_Handler {

	private final static Id registeredWishRecordTypeId = Constant_AC.REGISTERED_WISH_ID;
	private final static Id registeredNonWishRecordTypeId = Constant_AC.REGISTERED_NON_WISH_ID;
	private final static Id wishVolunteerOpportunityRecordTypeId = Constant_AC.WISH_VOLUNTEER_OPPORTUNITY_ID;
	private final static Id nonWishRecordTypeId = Constant_AC.NON_WISH_EVENT_RT_ID;
	private final static Id wishRecordTypeId = Constant_AC.WISH_RT_ID;

	// This method is used to update the record type and vounteer Opportunity status and wish start date values.
	public static void onBeforeUpdate(Map<Id, Volunteer_Opportunity__c> newMap, Map<Id, Volunteer_Opportunity__c> oldMap) {
		Map<Id, String> volunteerContactMap = new Map<Id, String>();
		Set<Id> volunteerContactIdSet = new Set<Id>();
		Set<Id> dbWishSet = new Set<Id>();
		Set<Id> dbCaseSet = new Set<Id>();
		for (Volunteer_Opportunity__c currRec : newMap.values()) {
			if (currRec.Inactive__c == true && oldMap.get(currRec.Id).Inactive__c == false && currRec.Reason_Inactive__c != null) {
				currRec.Status__c = 'Inactive';
				currRec.Inactivated_or_Rejected_Date__c = Date.today();
			}
			if (currRec.Inactive__c == true && currRec.Status__c == 'Inactive' && currRec.Wish__c != null) {
				currRec.Wish_End_Date__c = Date.today();
			}
			if (currRec.Status__c == 'Pending' && currRec.Status__c != oldMap.get(currRec.Id).Status__c) {
				currRec.Inactivated_or_Rejected_Date__c = Date.today();
			}
			if (currRec.Volunteer_Name__c != null && currRec.Volunteer_Name__c != oldMap.get(currRec.Id).Volunteer_Name__c) {
				volunteerContactIdSet.add(currRec.Volunteer_Name__c);
			}
			if (currRec.Reason_Inactive__c != null) {
				currRec.Inactive__c = true;
			}
			if (currRec.RecordTypeId == wishVolunteerOpportunityRecordTypeId && currRec.Status__c == 'Approved'
					&& oldMap.get(currRec.Id).Status__c != currRec.Status__c && currRec.Wish__c != null) {
				currRec.RecordTypeId = registeredWishRecordTypeId;
				dbWishSet.add(currRec.Wish__c);
			}
			if (currRec.RecordTypeId == nonWishRecordTypeId && currRec.Status__c == 'Approved') {
				currRec.RecordTypeId = registeredNonWishRecordTypeId;

			}
			if (currRec.Status__c == 'Approved' && oldMap.get(currRec.Id).Status__c == 'Pending') {
				currRec.Inactivated_or_Rejected_Date__c = null;
			}
		}

		if (volunteerContactIdSet.size() > 0) {
			for (Contact volunteerContact : [
					SELECT Id,Email
					FROM Contact
					WHERE Id IN:volunteerContactIdSet
			]) {
				volunteerContactMap.put(volunteerContact.Id, volunteerContact.Email);
			}
		}
		if (dbWishSet.size() > 0) {
			for (Case dbCase : [
					SELECT Id,Status,RecordTypeId,IsClosed
					FROM Case
					WHERE Status != 'Granted'
					AND RecordTypeId = :wishRecordTypeId
					AND Id IN:dbWishSet
			]) {
				if (dbCase.IsClosed == false) {
					dbCaseSet.add(dbCase.Id);
				}
			}
		}
		if (volunteerContactMap.size() > 0 || dbCaseSet.size() > 0) {
			for (Volunteer_Opportunity__c currRec : newMap.values()) {
				if (currRec.Volunteer_Name__c != null && volunteerContactMap.containsKey(currRec.Volunteer_Name__c)) {
					currRec.Hidden_Volunteer_Contact_Email__c = volunteerContactMap.get(currRec.Volunteer_Name__c);
				}
				if (dbCaseSet.contains(currRec .Wish__c)) {
					currRec.Wish_Start_Date__c = System.today();
				}
			}
		}
	}
}