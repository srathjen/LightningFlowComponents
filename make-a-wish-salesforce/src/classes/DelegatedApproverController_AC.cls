/**************************************************************************************
Author : MST Solutions
Description : This class referred in the DelegatedApprover_VF. It display the all record approval processes . 
This will allow chapter staff to see visibility into their colleagues approval's needed when they are covering for each other.
****************************************************************************************/
global class DelegatedApproverController_AC {
	/*
     * @description		Used to collect the list of approval process records.
     *
     * @author			MST Solutions
     * @dateCreated		unknown
     */
	@RemoteAction
	@ReadOnly
	public static String getAppList(String toDate1, String fromDate1) {
		Datetime fromDate = Datetime.valueOf(toDate1 + ' 00:00:00');
		Datetime toDate = Datetime.valueOf(fromDate1 + ' 23:59:00');
		Id wishRecordTypeId = Constant_AC.WISH_RT_ID;
		Id volunteerRecordTypeId = Constant_AC.VOLUNTEER_RT_ID;
		Id wishChildRecordTypeId = Constant_AC.CONTACT_WISH_CHILD_RT_ID;
		Id inKindDonorsAccountRecordTypeId = Constant_AC.IN_KIND_ACCOUNT_ID;
		Id boardMemberRT = Constant_AC.BOARD_MEMBER_RT_ID;

		Set<Id> volOppIdSet = new Set<Id>(); // Used to hold Volunteer Opportunity records Ids
		Set<Id> conIdSet = new Set<Id>();  // Used to hold Contact records Ids
		Set<Id> caseIdSet = new Set<Id>();  // Used to hold Case records Ids
		Set<Id> accIdSet = new Set<Id>();  // Used to hold Account records Ids
		Set<Id> inKindSet = new Set<Id>();  // Used to hold Inkind Account records Ids
		Map<Id, String> chapterMap = new Map<Id, String>();
		Map<Id, String> wishChildNameMap = new Map<Id, String>();

		List<ApprovalWrapper> approvalWrapperList = new List<ApprovalWrapper>();
		Map<Id, ApprovalWrapper> approvalWrapperMap = new Map<Id, ApprovalWrapper>();
		for (ProcessInstance process : [
			SELECT Id, Status, ProcessDefinition.Name, TargetObject.Name, TargetObject.Id, SubmittedBy.UserRole.Name,
				TargetObject.Type,CreatedBy.Name,SubmittedBy.Account.Name,SubmittedBy.Name,CompletedDate,CreatedDate
				, (
				SELECT Id,Actor.Name,OriginalActor.Name,ActorId
				FROM StepsAndWorkitems
				ORDER BY Id DESC
				LIMIT 1
			)
			FROM ProcessInstance
			WHERE ProcessDefinition.Name != 'KBWorkflow' AND CreatedDate > :fromDate AND CreatedDate <= :toDate
			ORDER BY CreatedDate DESC
		]) {
			ApprovalWrapper wrap = new ApprovalWrapper();

			wrap.processName = process.ProcessDefinition.Name;
			wrap.targetObjectId = process.TargetObject.Id;
			wrap.recordName = process.TargetObject.Name;
			wrap.status = process.Status;
			wrap.createdBy = process.CreatedBy.Name;
			wrap.submittedBy = process.SubmittedBy.Name;
			wrap.approvedBy = process.StepsAndWorkitems[0].Actor.Name;
			wrap.assignedTo = process.StepsAndWorkitems[0].OriginalActor.Name;
			wrap.submittedDate = String.valueOf(process.CreatedDate.format('MM/dd/yyyy'));

			if (process.CompletedDate != null) {
				wrap.completedDate = String.valueOf(process.CompletedDate.format('MM/dd/yyyy'));
			} else {
				wrap.completedDate = String.valueOf(process.CompletedDate);
			}

			wrap.objectType = process.TargetObject.Type;
			approvalWrapperMap.put(wrap.targetObjectId, wrap);
			approvalWrapperList.add(wrap);

			if (process.TargetObject.Type == 'Volunteer_Opportunity__c') {
				volOppIdSet.add(process.TargetObject.Id);
			}
			if (process.TargetObject.Type == 'Case') {
				caseIdSet.add(process.TargetObject.Id);
			}
			if (process.TargetObject.Type == 'Contact') {
				conIdSet.add(process.TargetObject.Id);
			}
			if (process.TargetObject.Type == 'Account') {
				accIdSet.add(process.TargetObject.Id);
			}
			if (process.TargetObject.Type == 'In_Kind_Donation_Reimbursement__c') {
				inKindSet.add(process.TargetObject.Id);
			}
		}

		// Used to get Wish Child Name and Chapter Name for the the approval records
		for (Contact conInfo : [
			SELECT Id, RecordTypeId, Account.Name, Region_Chapter__r.Name
			FROM Contact
			WHERE Id IN :conIdSet
		]) {
			if (conInfo.RecordTypeId == volunteerRecordTypeId) {
				if (conInfo.Account.Name != null) {
					chapterMap.put(conInfo.Id, conInfo.Account.Name);
				}
			} else if (conInfo.RecordTypeId == wishChildRecordTypeId || conInfo.RecordTypeId == boardMemberRT) {

				if (conInfo.Region_Chapter__r.Name != null) {
					chapterMap.put(conInfo.Id, conInfo.Region_Chapter__r.Name);
				}
			}
		}

		// Used to get the wish child name and Chapter name for the volunteer Opportunity object related records
		for (Volunteer_Opportunity__c volOpp : [
			SELECT Id, Chapter_Name__r.Name,Wish__c,Wish__r.Contact.Name
			FROM Volunteer_Opportunity__c
			WHERE Id IN :volOppIdSet
		]) {

			if (volOpp.Chapter_Name__r.Name != null) {
				chapterMap.put(volOpp.Id, volOpp.Chapter_Name__r.Name);
			}
			if (volOpp.Wish__c != null) {
				wishChildNameMap.put(volOpp.Id, volOpp.Wish__r.Contact.Name);
			}
		}

		// Used to collecct the wish child name and the chapter name form the case object
		for (Case caseInfo : [
			SELECT Id, ChapterName__r.Name, Parent.ChapterName__r.Name,Contact.Name,Parent.Contact.Name,RecordTypeId
			FROM Case
			WHERE Id IN :caseIdSet
		]) {
			if (caseInfo.RecordTypeId == wishRecordTypeId) {
				if (caseInfo.ChapterName__r.Name != null) {
					chapterMap.put(caseInfo.Id, caseInfo.ChapterName__r.Name);
				}
				wishChildNameMap.put(caseInfo.Id, caseInfo.Contact.Name);
			}
		}

		for (Account inkaccinfo : [
			SELECT Id, Chapter_Name__r.Name
			FROM Account
			WHERE Id IN :accIdSet
		]) {
			if (inkaccinfo.Chapter_Name__r.Name != null && inkaccinfo.RecordTypeId == inKindDonorsAccountRecordTypeId) {
				chapterMap.put(inkaccinfo.Id, inkaccinfo.Chapter_Name__r.Name);
			}
		}

		for (In_Kind_Donation_Reimbursement__c ikRemInfo : [
			SELECT Id, Wish__c,Wish__r.Contact.Name, Wish__r.ChapterName__r.Name
			FROM In_Kind_Donation_Reimbursement__c
			WHERE Id IN :inKindSet
		]) {
			if (ikRemInfo.Wish__r.ChapterName__r.Name != null) {
				chapterMap.put(ikRemInfo.Id, ikRemInfo.Wish__r.ChapterName__r.Name);
			}
			if (ikRemInfo.Wish__c != null) {
				wishChildNameMap.put(ikRemInfo.Id, ikRemInfo.Wish__r.Contact.Name);
			}
		}

		for (ApprovalWrapper apprvalWrapper : approvalWrapperMap.values()) {
			if (wishChildNameMap.containsKey(apprvalWrapper.targetObjectId)) {
				approvalWrapperMap.get(apprvalWrapper.targetObjectId).wishChild = wishChildNameMap.get(apprvalWrapper.targetObjectId);
			}
			if (chapterMap.containsKey(apprvalWrapper.targetObjectId)) {
				approvalWrapperMap.get(apprvalWrapper.targetObjectId).chapterName = chapterMap.get(apprvalWrapper.targetObjectId);
			}
		}

		String s = JSON.serialize(approvalWrapperMap.values());
		return s;
	}

	// Wrapper class to hold approval process records
	public class ApprovalWrapper {
		public String processName { get; set; }
		public String targetObjectId { get; set; }
		public String chapterName { get; set; }
		public String recordName { get; set; }
		public String wishChild { get; set; }
		public String status { get; set; }
		public String createdBy { get; set; }
		public String submittedBy { get; set; }
		public String approvedBy { get; set; }
		public String assignedTo { get; set; }
		public String submittedDate { get; set; }
		public String completedDate { get; set; }
		public String objectType { get; set; }
	}
}