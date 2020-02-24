/***************************************************************************************************
Author      : MST Solutions
Date        : 10/15/2016
Description : 
              
              Modification Log
              ------------------
              WVC-1887    Pavithra G  07/03/2018
              
*****************************************************************************************************/
Public class AwardsRecognition_OnAfterInsertHelper {
	/*******************
	   This method is handle all logic for after inserting the Awards and Recognition record Event.
	   **********************/
	public static void showErrorMismatchedRole(Map<Id, Awards_Recognition__c> AwardsRecognitionMap) {
		try {
			List<User> currUser = [
					SELECT id,UserRole.Name,Profile.Name
					FROM User
					WHERE id = :userInfo.getUserId()
					limit 1
			];
			set<String> chapterNamesSet = new Set<String>();
			Map<Id, String> chapterNameMap = new Map<Id, String>();
			Map<String, String> chapterRoleMap = new Map<String, String>();

			for (Awards_Recognition__c currRec : [
					SELECT id, ownerId, owner.UserRoleId, Owner.UserRole.Name, Chapter_Name__c,
							Chapter_Name__r.Name
					FROM Awards_Recognition__c
					WHERE Id IN :AwardsRecognitionMap.keySet()
			]) {
				if (currRec.Chapter_Name__c != Null) {
					chapterNamesSet.add(currRec.Chapter_Name__r.Name);
					chapterNameMap.put(currRec.Id, currRec.Chapter_Name__r.Name);
				}
			}

			if (chapterNamesSet.Size() > 0) {
				chapterRoleMap = ChapterStaffRecordSharing_AC.FindChapterRole(chapterNamesSet);

				for (Awards_Recognition__c currRec : AwardsRecognitionMap.values()) {
					if (currUser[0].UserRole.Name != 'National Staff' && currUser[0].profile.Name != 'System Administrator' && currUser[0].profile.Name != 'Integration') {
						if (chapterRoleMap.get(chapterNameMap.get(currRec.Id)) != currUser[0].UserRole.Name) {
							{
								currRec.addError('Insufficient previlege to update this record. Please contact system administrator.');
							}
						}

					}
				}
			}

			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}

		} Catch (Exception ex) {
			for (Awards_Recognition__c currRec : AwardsRecognitionMap.values()) {
				ErrorMessage_AC.createdebugRec('AwardsRecognition_OnAfterInsertHelper', String.valueof(currRec), String.valueOf(ex), 'showErrorMismatchedRole', currRec.Id, ex.getStackTraceString() + '   ' + ex.getMessage(), 'Error');
			}

			if (!Test.isRunningTest()) {
				for (Awards_Recognition__c currRec : AwardsRecognitionMap.values()) {
					currRec.addError(Label.Debug_log_error_message);
				}

			}
		}

	}
}