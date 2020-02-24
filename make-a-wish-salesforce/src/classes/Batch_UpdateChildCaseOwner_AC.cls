/*This class is used to update the owner of the child cases*/

global class Batch_UpdateChildCaseOwner_AC implements Database.Batchable<SObject> {
	global Database.QueryLocator start(Database.BatchableContext BC) {
		Id wishRecordTypeId = Constant_AC.WISH_RT_ID;
		return Database.getQueryLocator([
				SELECT Id, OwnerId
				FROM Case
				WHERE RecordTypeId = :wishRecordTypeId
		]);
	}

	global void execute(Database.BatchableContext BC, List<Case> parentCase) {
		Map<Id, Id> parentCaseOwnerMap = new Map<Id, Id>();
		for (Case parentCaseOwner : parentCase) {
			parentCaseOwnerMap.put(parentCaseOwner.Id, parentCaseOwner.OwnerId);
		}
		List<Case> caseOwnerUpdateList = new List<Case>();
		for (Case childCase : [
				SELECT Id, ParentId, OwnerId
				FROM Case
				WHERE ParentId IN :parentCaseOwnerMap.keySet()
		]) {
			if (parentCaseOwnerMap.containsKey(childCase.ParentId) && childCase.OwnerId != parentCaseOwnerMap.get(childCase.ParentId)) {
				childCase.OwnerId = parentCaseOwnerMap.get(childCase.ParentId);
				caseOwnerUpdateList.add(childCase);
			}
		}
		if (caseOwnerUpdateList.size() > 0) {
			update caseOwnerUpdateList;
		}
	}

	global void finish(Database.BatchableContext BC) {}
}