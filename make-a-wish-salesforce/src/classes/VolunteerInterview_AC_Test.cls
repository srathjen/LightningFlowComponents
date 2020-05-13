@IsTest
private class VolunteerInterview_AC_Test {

    private final static Id CHAPTER_RT_ID = Constant_AC.CHAPTER_RT_ID;
    private final static Id NATIONAL_RT_ID = Constant_AC.NATIONAL_RT_ID;

    @TestSetup
    private static void setUp() {
        trac_TriggerHandlerBase.blockTrigger = true;

        User volunteer = [
                SELECT Id, ContactId
                FROM User
                WHERE ContactId != NULL
                AND IsActive = TRUE
                LIMIT 1
        ];

        List<Account> accountList = TestDataFactory.createAccount(1);
        Account accountAzChapter = accountList.get(0);
        accountAzChapter.Name = 'Make-A-Wish Arizona';
        accountAzChapter.RecordTypeId = CHAPTER_RT_ID;
        insert accountList;

        List<Dynamic_Content__c> dynamicContentList = TestDataFactory.createDynamicContent(1);
        Dynamic_Content__c nationalContent = dynamicContentList.get(0);
        nationalContent.Active__c = true;
        nationalContent.RecordTypeId = NATIONAL_RT_ID;
        nationalContent.Interview_Additional_Info__c = 'Please indicate up to three day/time combinations when submitting your interview preferences.';
        insert dynamicContentList;

        List<npe5__Affiliation__c> affiliationList = TestDataFactory.createAffiliation(1);
        npe5__Affiliation__c affiliation = affiliationList.get(0);
        affiliation.npe5__Organization__c = accountAzChapter.Id;
        affiliation.npe5__Primary__c = true;
        affiliation.npe5__Contact__c = volunteer.ContactId;
        insert affiliationList;

        trac_TriggerHandlerBase.blockTrigger = false;
    }

    @IsTest
    private static void validateVolunteerInterviewController() {
        List<npe5__Affiliation__c> affiliationList = [
                SELECT Id, npe5__Contact__c
                FROM npe5__Affiliation__c
                WHERE npe5__Contact__c != NULL
        ];
        User volunteerUser = [
                SELECT Id, ContactId
                FROM User
                WHERE ContactId = :affiliationList[0].npe5__Contact__c
        ];

        ApexPages.currentPage().getParameters().put('bgRequired', 'true');
        ApexPages.currentPage().getParameters().put('trainingRequired', 'true');

        System.runAs(volunteerUser) {
            VolunteerInterview_AC controller = new VolunteerInterview_AC();
            controller.getTimes();
            controller.confirmReschedule();
            controller.hidePopup();
            System.assert(controller.interviewContent == 'Please indicate up to three day/time combinations when submitting your interview preferences.');
        }
    }
}