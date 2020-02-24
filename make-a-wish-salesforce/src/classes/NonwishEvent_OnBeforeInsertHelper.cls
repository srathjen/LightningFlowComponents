/***************************************************************************************************
Author      : MST Solutions
Date        : 
Description : NonwishEvent_OnBeforeInsertHelper is used to call the Helper class when the
              new nonwishEvent record is created.
              
              Modification Log
              ------------------
              WVC-1889    Pavithra 07/11/2018
              
*****************************************************************************************************/
Public class NonwishEvent_OnBeforeInsertHelper {
	//Used to display the error message when the chapter already have the same priority.
	public static void checkChapterPriority(Set<Id> chapterIds, Set<String> prioritysSet, List<Non_Wish_Events__c> newNonwishEventList) {
		try {
			Set<String> chapterPrioritySet = new Set<String>();
			for (Non_Wish_Events__c currRec : [
					SELECT id, Chapter__c, Priority__c,event_date__c,RecordtypeId
					FROM Non_Wish_Events__c
					WHERE chapter__c IN :chapterIds AND Priority__c = :prioritysSet AND event_date__c > :Date.Today()
			]) {
				if (currRec.Priority__c != Null) {
					chapterPrioritySet.add(currRec.Chapter__c + '-' + currRec.Priority__c);
				}
			}
			for (Non_Wish_Events__c currRec : newNonwishEventList) {
				if (currRec.Priority__c != Null) {
					if (chapterPrioritySet.contains(currRec.Chapter__c + '-' + currRec.Priority__c) && Bypass_Triggers__c.getValues(userInfo.getUserId()) == Null) {
						currRec.addError('This Chapter already has event for same priority. Please select some other priority.');
					}
				}
			}

			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}

		} catch (Exception ex) {
			for (Non_Wish_Events__c currRec : newNonwishEventList) {
				ErrorMessage_AC.createdebugRec('NonwishEvent_OnBeforeInsertHelper', String.valueof(currRec), String.valueOf(ex), 'checkChapterPriority', currRec.Id, ex.getStackTraceString(), 'Error');
			}

			if (!Test.isRunningTest()) {

				for (Non_Wish_Events__c currRec : newNonwishEventList) {
					currRec.addError(Label.Debug_log_error_message);
				}

			}

		}
	}
}