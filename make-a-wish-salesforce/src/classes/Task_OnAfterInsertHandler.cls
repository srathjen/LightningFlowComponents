/*****************************************************************************************************************
Author      : MST Solutions
Date        : 6/1/2016
Description : When new Task is inserted then this Task_OnAfterInsertHandler is called by before event in task trigger
then it will call the updateVolunteerInterviewDate method in Task_OnAfterInsertHelper based on Task subject.
*******************************************************************************************************************/
public class Task_OnAfterInsertHandler {
	/**
	 * WLP-434
	 * Deprecate Interview Fields on Contact
	 */
//	static Id interviewTaskRTId = Constant_AC.INTERVIEW_RT_ID;
//	public static void OnAfterInsert(List<Task> newTaskList) {
//		Set<Id> volunteerIdsSet = new Set<Id>();
//		for (Task newTask : newTaskList) {
//			if (newTask.Subject == 'Interview Task' && newTask.WhoId != Null && newTask.RecordTypeId == interviewTaskRTId) {
//				volunteerIdsSet.add(newTask.WhoId);
//			}
//		}
//		if (volunteerIdsSet.size() > 0) {
//			Task_OnAfterInsertHelper.updateVolunteerInterviewDate(volunteerIdsSet, 'insert');
//		}
//	}
}