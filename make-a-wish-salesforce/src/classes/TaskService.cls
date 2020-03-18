/**
 * @description Task Service class
 * @author	Gustavo Mayer, Traction on Demand
 * @createdDate	3-04-2020
 */
public class TaskService {

	private final static Id STAFF_TASK_RECORD_TYPE_ID = Constant_AC.STAFF_TASK_RT_ID;
	private static final String STATUS_COMPLETED = Constant_AC.TASK_STATUS_COMPLETED;
	private static final String STATUS_NOT_STARTED = Constant_AC.TASK_STATUS_NOT_STARTED;
	private static final String STATUS_IN_PROGRESS = Constant_AC.TASK_STATUS_IN_PROGRESS;
	private static final String PRIORITY_NORMAL = Constant_AC.TASK_PRIORITY_NORMAL;
	private static final String DESCRIPTION_RUSH_QUALIFIED = Constant_AC.TASK_DESCRIPTION_RUSH_QUALIFIED;
	private static final String SUBJECT_SEND_WELCOME_LETTER = Constant_AC.TASK_SUBJECT_SEND_WELCOME_LETTER;
	private static final String SUBJECT_RUSH_QUALIFIED = Constant_AC.TASK_SUBJECT_RUSH_QUALIFIED;
	private static final String SUBJECT_RUSH_MODIFIED_NO = Constant_AC.TASK_SUBJECT_RUSH_MODIFIED_NO;

	public static Task buildSendWelcomeLetter(Contact contact) {
		return new Task(
				OwnerId = contact.OwnerId,
				SystemGeneratedTask__c = true,
				Subject = SUBJECT_SEND_WELCOME_LETTER,
				WhoId = contact.Id,
				Description = SUBJECT_SEND_WELCOME_LETTER,
				Status = STATUS_IN_PROGRESS,
				ActivityDate = System.today() + 10,
				RecordTypeId = STAFF_TASK_RECORD_TYPE_ID
		);
	}

	/**
	 * Build Rush Task
	 * @param contact
	 * @return Task
	 */
	public static Task buildRush(Contact contact) {
		return new Task(
				Description = DESCRIPTION_RUSH_QUALIFIED,
				Priority = PRIORITY_NORMAL,
				Status = STATUS_COMPLETED,
				Subject = SUBJECT_RUSH_QUALIFIED,
				OwnerId = Label.Salesforce_Support_User_Id,
				ActivityDate = System.today(),
				WhoId = contact.Id
		);
	}

	/**
	 * Create Rush Task
	 * @param leadList
	 */
	public static void createRushTask(List<Lead> leadList) {
		List<Task> newTaskList = new List<Task>();
		for (Lead processLead : leadList) {
			Task newRushTask = new Task(
					Priority = PRIORITY_NORMAL,
					Status = STATUS_NOT_STARTED,
					Subject = SUBJECT_RUSH_MODIFIED_NO,
					OwnerId = processLead.OwnerId,
					ActivityDate = System.today() + 3,
					SystemGeneratedTask__c = true,
					WhoId = processLead.Id);
			newTaskList.add(newRushTask);
		}
		if (!newTaskList.isEmpty()) {
			insert newTaskList;
		}
	}

	/**
	 * Create Lead Task
	 * @param leadMap
	 * @return Save Result
	 */
	public static List<Database.SaveResult> createLeadTask(Set<Id> leadIds) {
		List<Task> newTaskList = new List<Task>();
		for (Lead newLead : [
				SELECT Id, Migrated_Record__c, OwnerId, Owner.UserRole.Name, Status,
						ChapterName__c,ChapterName__r.Name, PD_Condition_Description__c
				FROM Lead
				WHERE Id IN :leadIds
		]) {
			Task newTask = new Task();
			if (newLead.Status == Constant_AC.LEAD_STATUS_INQUIRY) {
				newTask.Subject = Constant_AC.TASK_SUBJECT_NEW_INQUIRY_SUBMITTED;
				newTask.ActivityDate = Date.today().addDays(30);
			}
			if (newLead.Status == Constant_AC.LEAD_STATUS_REFERRED) {
				newTask.Subject = Constant_AC.TASK_SUBJECT_NEW_REFERRAL_SUBMITTED;
				newTask.ActivityDate = Date.today().addDays(10);
			}
			newTask.OwnerId = newLead.OwnerId;
			newTask.RecordTypeId = Constant_AC.STAFF_TASK_RT_ID;
			newTask.WhoId = newLead.Id;
			newTask.Priority = Constant_AC.TASK_PRIORITY_NORMAL;
			newTask.SystemGeneratedTask__c = true;
			newTaskList.add(newTask);
		}
		if (!newTaskList.isEmpty()) {
			return Database.insert(newTaskList, false);
		}
		return new List<Database.SaveResult>();
	}

	/**
	 * Close Lead Tasks
	 * @param leadIds
	 */
	public static void updateCompleted(Set<Id> leadIds) {
		List<Task> taskList = [
				SELECT Id,Status
				FROM Task
				WHERE WhoId IN :leadIds
				AND Status != :STATUS_COMPLETED
		];
		List<Task> updateTask = new List<Task>();
		for (Task processTask : taskList) {
			processTask.Status = STATUS_COMPLETED;
			updateTask.add(processTask);
		}
		update updateTask;
	}
}