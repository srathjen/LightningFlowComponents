/**************************************************************************************
Created by: Vennila Paramasivam
Author: MST Solutions
CreatedDate : 06/28/2016
Description: Volunteer can provide their availability time for Interivew via Portal. Based
on the Volunteer Availability time, Chapter staff will confirm their Interview Date and Time.
****************************************************************************************/

public class VolunteerInterview_AC {

	public Task currTask { get; set; }
	public Boolean displayPopUp { get; set; }
	public Boolean isTaskCreated { get; set; }
	public Boolean displayConfirmTask { get; set; }
	User currUser;
//    public List<Task> volTask { get; set; }
	public Id interviewRT;
//    public String taskId;
	public String interviewContent { get; set; }
	public Boolean bgTabPermission { get; set; }
	public Boolean trainingTabVisible { get; set; }
	List<npe5__Affiliation__c> currAffliation { get; set; }

	public VolunteerInterview_AC() {
		List<string> LstLog = new List<string>();
//        string Logvalue;
		// try
		//{
		currTask = new Task();
		displayPopUp = false;
		isTaskCreated = false;
		displayConfirmTask = false;
		interviewRT = Constant_AC.INTERVIEW_RT_ID;
		String chapterId;

		currUser = [
				SELECT id, contactId,contact.OwnerId
				FROM User
				WHERE Id = :userInfo.getUserId()
		];
		LstLog.add(string.valueOf('currUser: ' + currUser));
		currAffliation = [
				SELECT id,npe5__Organization__c,npe5__Organization__r.Volunteer_Manager__c
				FROM npe5__Affiliation__c
				WHERE npe5__Contact__c = :currUser.contactId AND npe5__Primary__c = True
				limit 1
		];

		if (currAffliation.size() > 0) {
			chapterId = currAffliation[0].npe5__Organization__c;
			LstLog.add(string.valueOf('chapterId: ' + chapterId));
		}

		// Based on the parameter value, It would display Background tab.
		if (ApexPages.currentPage().getParameters().get('bgRequired') != Null)
			bgTabPermission = Boolean.valueOf(ApexPages.currentPage().getParameters().get('bgRequired'));
		if (ApexPages.currentPage().getParameters().get('trainingRequired') != Null)
			trainingTabVisible = Boolean.valueOf(ApexPages.currentPage().getParameters().get('trainingRequired'));

		Id nationalRT = Constant_AC.NATIONAL_RT_ID;

		// Dynamic Content for displaying text on Portal.
		for (Dynamic_Content__c currContent : [
				SELECT Id,Interview_Additional_Info__c
				FROM Dynamic_Content__c
				WHERE RecordTypeId = :nationalRT AND Active__c = True
		]) {
			LstLog.add(string.valueOf('currContent: ' + currContent));
			if (currContent.Interview_Additional_Info__c != Null)
				interviewContent = currContent.Interview_Additional_Info__c;
		}
		/**
		 * WLP-434
		 * Deprecating Task from Volunteer Interview and Volunteer Welcome Page
		 */
//             volTask  = new List<Task>();
		/*  volTask = [SELECT id,Available_Date1__c, Available_Date2__c, Available_Date3__c,  Available_Time1__c,venue__c,
							   Available_Time2__c, Available_Time3__c, Chapter_Name__c, Subject, Status,
							   Confirmed_Time__c, Confirmed_Date__c, Availability_Time_Other1__c,Availability_Time_Other2__c,
							   Availability_Time_Other3__c FROM Task
							   WHERE (Status = 'Scheduled') AND Confirmed_Date__c != Null AND Confirmed_Date__c > :Date.Today() AND
							   whoId =:currUser.ContactId AND Subject = 'Interview Task' AND RecordTypeId = :interviewRT  Order by CreatedDate DESC limit 1]; */
//             String jsonbody = VolunteerInterviewTask_AC.getClassOfferingRecList(currUser.ContactId);
//             List<Task> newTask = new List<Task>();
//             List<Task> newTaskList;
//             if(!Test.isRunningTest())
//             newTaskList =  (List<Task>) JSON.deserialize(jsonbody, List<Task>.class);
//             else
//                 newTaskList = new list<task>();
//             for(Task currTask : newTaskList)
//             {
//                if(currTask.Status == 'Scheduled' && currTask.Confirmed_Date__c  != Null && currTask.Confirmed_Date__c >= system.Today())
//                   volTask.add(currTask);
//                else if(currTask.Status == 'Not Started')
//                    newTask.add(currTask);
//             }

		// If Volunteer already registered and Interivew date confirmed by Chapter staff then
		// Confirmation Date and Time would be displayed on the Portal.
//            if(volTask.size() > 0)
//            {
//
//              displayConfirmTask = True;
//              taskId = volTask[0].id;
//            }
		// If volunteer submitted their availability time but interview date not yet confirmed, Acknowlegement would be
		//display on Portal.
//            if(newTask.size() > 0)
//            {
//                isTaskCreated = True;
//            }
		// }
		/* catch(Exception ex)
		 {
			 Logvalue = string.join(LstLog,', ');
			 new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerInterview_AC','VolunteerInterview_AC',Null,ex,Logvalue));
			//ex.setMessage(Label.Debug_log_error_message);
			 ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
			 ApexPages.addMessage(myMsg);
		 }*/
	}

	/**
	 * WLP-434
	 * Deprecating Task from Volunteer Interview and Volunteer Welcome Page
	 */
	public PageReference submit() {
//		List<string> LstLog = new List<string>();
//		String Logvalue;
//		String recId;
//		try {
//			Boolean flag = true;
//			// Each Volunteer should submit two Available Time and Date. Its mandatory for all. Else It will throw an error message to
//			// submit volunteer for two available Date and Time. And also it should not be conflict.
//			if (currTask.Available_Date1__c == Null || currTask.Available_Time1__c == Null || currTask.Available_Time1__c == '') {
//				flag = false;
//				ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter at least 2 available dates and times.');
//				ApexPages.addMessage(myMsg);
//				return null;
//			}
//
//			if (currTask.Available_Date2__c == Null || currTask.Available_Time2__c == Null || currTask.Available_Time2__c == '') {
//				flag = false;
//				ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter at least 2 available dates and times.');
//				ApexPages.addMessage(myMsg);
//				return null;
//			}
//
//			if ((currTask.Available_Date3__c != Null && (currTask.Available_Time3__c == Null || currTask.Available_Time3__c == '')) ||
//					(currTask.Available_Date3__c == Null && currTask.Available_Time3__c != Null)) {
//				flag = false;
//				ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please Enter Available Date and Time3');
//				ApexPages.addMessage(myMsg);
//				return null;
//			}
//
//			if (currTask.Available_Date1__c <= Date.Today() || currTask.Available_Date2__c <= Date.Today() || currTask.Available_Date3__c <= Date.Today()) {
//				flag = false;
//				ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Available date should be greater than today.');
//				ApexPages.addMessage(myMsg);
//				return null;
//			}
//
//			if (((currTask.Available_Date1__c == currTask.Available_Date2__c) && (currTask.Available_Time1__c == currTask.Available_Time2__c)) &&
//					((currTask.Available_Date1__c == currTask.Available_Date3__c) && (currTask.Available_Time1__c == currTask.Available_Time3__c)) &&
//					((currTask.Available_Date2__c == currTask.Available_Date3__c) && (currTask.Available_Time2__c == currTask.Available_Time3__c))) {
//
//				flag = false;
//				ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Available date and time 1, 2 and 3 should not be same.');
//				ApexPages.addMessage(myMsg);
//				return null;
//			}
//
//			if ((currTask.Available_Date1__c == currTask.Available_Date2__c) && (currTask.Available_Time1__c == currTask.Available_Time2__c)) {
//				flag = false;
//				ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Available date and time 1 and 2 should not be same.');
//				ApexPages.addMessage(myMsg);
//				return null;
//
//			}
//			if ((currTask.Available_Date1__c == currTask.Available_Date3__c) && (currTask.Available_Time1__c == currTask.Available_Time3__c)) {
//				ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Available date and time 1 and 3 should not be same.');
//				ApexPages.addMessage(myMsg);
//				return null;
//
//			}
//			if ((currTask.Available_Date2__c == currTask.Available_Date3__c) && (currTask.Available_Time2__c == currTask.Available_Time3__c)) {
//
//				flag = false;
//				ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Available date and time 2 and 3 should not be same.');
//				ApexPages.addMessage(myMsg);
//				return null;
//
//			}
//
//			if ((currTask.Available_Time1__c == 'Other' && (currTask.Availability_Time_Other1__c == '' || currTask.Availability_Time_Other1__c == Null)) ||
//					(currTask.Available_Time2__c == 'Other' && (currTask.Availability_Time_Other2__c == '' || currTask.Availability_Time_Other2__c == Null)) ||
//					(currTask.Available_Time3__c == 'Other' && (currTask.Availability_Time_Other3__c == '' || currTask.Availability_Time_Other3__c == Null))) {
//				flag = false;
//				ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please Enter Other details');
//				ApexPages.addMessage(myMsg);
//				return null;
//			}
//
//			if (flag == True) {
//				currTask.recordTypeId = interviewRT;
//				if (currAffliation.size() > 0) {
//					if (currAffliation[0].npe5__Organization__r.Volunteer_Manager__c != Null)
//						currTask.OwnerId = currAffliation[0].npe5__Organization__r.Volunteer_Manager__c;
//				} else
//						currTask.OwnerId = currUser.contact.OwnerId;
//
//				currTask.whoId = currUser.ContactId;
//				currTask.subject = 'Interview Task';
//				currTask.Priority = 'High';
//				currTask.ActivityDate = system.today() + 3;
//				LstLog.add(string.valueOf('currTask: ' + currTask));
//				recId = currTask.id;
//				upsert currTask; // Creating Interview Task.
//
//				isTaskCreated = True;
//			}
//			// Send the user back to current page.
//			PageReference pageRef = new PageReference(ApexPages.currentPage().getUrl());
//			pageRef.setRedirect(true);
//			return pageRef;
//		} catch (Exception ex) {
//			Logvalue = string.join(LstLog, ', ');
//			new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerInterview_AC', 'submit', recId, ex, Logvalue));
//			//ex.setMessage(Label.Debug_log_error_message);
//			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
//			ApexPages.addMessage(myMsg);
//			return null;
//		}
		return null;
	}

	public void confirmReschedule() {
		displayPopUp = true;
	}

	public void hidePopup() {
		displayPopUp = false;
	}
	// There is an option for Volunteer to reschedule their Available Date and Time. If user submits
	// Reschedule button, Existing Availability would be changed to Rescheduled and New Page would render
	// for capturing new Availability.
	public void Reschedule() {
		/*WLP-467 remove automated task creation */
//        List<string> LstLog = new List<string>();
//        String Logvalue;
//        String recId;
//        try
//        {
//            Task updateTask = new Task();
//            updateTask.id = taskId;
//            updateTask.status = 'Rescheduled';
//            recId = updateTask.id;
//            LstLog.add(string.valueOf('updateTask: '+updateTask));
//            update updateTask;
//            displayConfirmTask = false;
//            isTaskCreated = false;
//            displayPopUp = false;
//        }
//        catch(Exception ex)
//        {
//            Logvalue = string.join(LstLog,', ');
//            new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerInterview_AC','Reschedule',recId,ex,Logvalue));
//            //ex.setMessage(Label.Debug_log_error_message);
//            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
//            ApexPages.addMessage(myMsg);
//        }
	}

	// Retrieving Availability Time value from Field and Display on Portal.
	public List<SelectOption> getTimes() {
		String Logvalue;
		/* try
		 {*/
		List<SelectOption> options = new List<SelectOption>();
		Schema.DescribeFieldResult fieldResult = Task.Available_Time1__c.getDescribe();
		List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
		for (Schema.PicklistEntry currVal : picklistValues) {
			options.add(new SelectOption(currVal.getLabel(), currVal.getValue()));
		}
		return options;
		/*  }
		  catch(Exception ex)
		  {
			  new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerInterview_AC','getTimes',Null,ex,Logvalue));
			  //ex.setMessage(Label.Debug_log_error_message);
			  ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
			  ApexPages.addMessage(myMsg);
			  return null;
		  }  */
	}
}