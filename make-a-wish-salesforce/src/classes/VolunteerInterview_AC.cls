/**************************************************************************************
Created by: Vennila Paramasivam
Author: MST Solutions
CreatedDate : 06/28/2016
Description: Volunteer can provide their availability time for Interivew via Portal. Based
on the Volunteer Availability time, Chapter staff will confirm their Interview Date and Time.
****************************************************************************************/
public class VolunteerInterview_AC {
    public Id interviewRT;
    public Task currTask { get; set; }
    public Boolean displayPopUp { get; set; }
    public Boolean isTaskCreated { get; set; }
    public Boolean displayConfirmTask { get; set; }
    public String interviewContent { get; set; }
    public Boolean bgTabPermission { get; set; }
    public Boolean trainingTabVisible { get; set; }
    List<npe5__Affiliation__c> currAffliation { get; set; }

    public VolunteerInterview_AC() {
        currTask = new Task();
        displayPopUp = false;
        isTaskCreated = false;
        displayConfirmTask = false;
        interviewRT = Constant_AC.INTERVIEW_RT_ID;
        String chapterId;

        currAffliation = [
            SELECT Id, npe5__Organization__c, npe5__Organization__r.Volunteer_Manager__c
            FROM npe5__Affiliation__c
            WHERE npe5__Contact__c = :Utils.currentUser.ContactId
			AND npe5__Primary__c = TRUE
            LIMIT 1
        ];

        if (currAffliation.size() > 0) {
            chapterId = currAffliation[0].npe5__Organization__c;
        }

        if (ApexPages.currentPage().getParameters().get('bgRequired') != null) {
			bgTabPermission = Boolean.valueOf(ApexPages.currentPage().getParameters().get('bgRequired'));
		}

        if (ApexPages.currentPage().getParameters().get('trainingRequired') != null) {
			trainingTabVisible = Boolean.valueOf(ApexPages.currentPage().getParameters().get('trainingRequired'));
		}

        Id nationalRT = Constant_AC.NATIONAL_RT_ID;

        for (Dynamic_Content__c currContent : [
            SELECT Id,Interview_Additional_Info__c
            FROM Dynamic_Content__c
            WHERE RecordTypeId = :nationalRT
			AND Active__c = TRUE
        ]) {
            if (currContent.Interview_Additional_Info__c != null) {
				interviewContent = currContent.Interview_Additional_Info__c;
			}
        }
    }

    public void confirmReschedule() {
        displayPopUp = true;
    }

    public void hidePopup() {
        displayPopUp = false;
    }

    public List<SelectOption> getTimes() {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Task.Available_Time1__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();

        for (Schema.PicklistEntry currVal : picklistValues) {
            options.add(new SelectOption(currVal.getLabel(), currVal.getValue()));
        }

        return options;
    }
}