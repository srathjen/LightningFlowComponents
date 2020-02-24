Public class CaseFileTriggerHandler {
	public static void updateAttachmentPath(List<cg__CaseFile__c> caseFileList) {
		set<Id> caseIdSet = new set<Id>();
		map<String, String> attachMentNameMap = new Map<String, String>();
		List<Minor_Participant__c> updateMinorParticipantList = new List<Minor_Participant__c>();
		for (cg__CaseFile__c dbRec : caseFileList) {
			caseIdSet.add(dbRec.cg__Case__c);
			attachMentNameMap.put(dbRec.cg__File_Name__c, dbRec.File_Path__c);
		}
		for (Minor_Participant__c dbRec : [
				SELECT Id,AttachmentId__c,Case__c,File_Path__c
				FROM Minor_Participant__c
				WHERE Case__c IN:caseIdSet AND AttachmentId__c != Null
		]) {
			if (attachMentNameMap.containsKey(dbRec.AttachmentId__c)) {
				dbRec.File_Path__c = attachMentNameMap.get(dbRec.AttachmentId__c);
				updateMinorParticipantList.add(dbRec);
			}
		}
		if (updateMinorParticipantList.size() > 0)
			update updateMinorParticipantList;
	}

}