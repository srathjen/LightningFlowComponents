global class CreateNewWish_AC {
    /*
     * @description     When User clicks [Create New Wish] button on Parent Wish, it will create new wish for
     *                  the child and assign two wish granters from the current wish and also it will create a
     *                  task for Volunteer Manager for reviewing previous case.
     *
     * @param           Id caseId
     *
     * @return          String
     *
     * @author          MST Solutions
     * @createdDate     unknown
     */
    webService static String createCase(Id caseId) {
        Case currCase = [
            SELECT Id, Subject, Description, Priority, AccountId, RecordTypeId,
                ChapterName__r.Volunteer_Manager__c, ContactId, ContactMobile,
                ContactPhone, Type, ChapterName__c, Case.OwnerId
            FROM Case
            WHERE Id = :caseId
        ];

        Map<Id, Case> newCaseMap = new Map<Id, Case>();
        Case newCase = new Case();
        newCase = currCase.clone();
        newCase.Status = Constant_AC.CASE_STATUS_READY_TO_ASSIGN;
        newCase.Sub_Status__c = Constant_AC.CASE_SUB_STATUS_NON_VIEWABLE;
        newCase.RecordTypeId = currCase.RecordTypeId;

        if (currCase.ChapterName__c != null && currCase.ChapterName__r.Volunteer_Manager__c != null) {
            newCase.OwnerId = currCase.ChapterName__r.Volunteer_Manager__c;
        }

        insert newCase;

        if (newCase.Id != null) {
            newCaseMap.put(newCase.Id, newCase);

            Set<Id> accountIds = new Set<Id>();
            accountIds.add(currCase.ChapterName__c);
            CaseService.createVolunteerOpportunity(newCaseMap, accountIds);
        }

        return newCase.Id;
    }
}