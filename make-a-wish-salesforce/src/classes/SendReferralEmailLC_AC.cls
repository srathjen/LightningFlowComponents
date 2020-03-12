public without sharing class SendReferralEmailLC_AC {

    /*
     * @description     Selector method to return a Lead by Id
     *
     * @param           String leadId
     *
     * @return          Lead
     *
     * @date            unknown
     * @author          MST Solutions
     */
    @AuraEnabled
    public static Lead getLeadInformation(String leadId){
        Lead processLead = [
            SELECT
                Id,
                ChapterName__c,
                Is_Chapter_Active__c
            FROM Lead
            WHERE Id = :leadId
            LIMIT 1
        ];

        return processLead;
    }

    /*
     * @description     Selector method to return a List<Office__c> by chapter Id.
     *
     * @param           String chapterId
     *
     * @return          List<Office__c>
     *
     * @date            unknown
     * @author          MST Solutions
     */
    @AuraEnabled
    public static List<Office__c> getOfficeViaChapter(String chapterId){
        List<Office__c> officeList = [
            SELECT
                Id,
                Name,
                Referral_Email_Address__c,
                Chapter__r.Onboarded_on_SF__c,
                Chapter__c
            FROM Office__c
            WHERE Chapter__c = :chapterId
            LIMIT 50000
        ];

        return officeList;
    }

    /*
     * @description     Selector method to return a List<Office__c> by Lead Id.
     *
     * @param           String leadId
     *
     * @return          List<Office__c>
     *
     * @date            unknown
     * @author          MST Solutions
     */
    @AuraEnabled
    public static List<Office__c> getOfficeViaLead(String leadId){
        Lead processLead = getLeadInformation(leadId);
        return SendReferralEmailLC_AC.getOfficeViaChapter(processLead.ChapterName__c);
    }

    /*
     * @description     Function to update Lead.Office_Referral_Email__c with an emailId for a given Lead by Lead Id.
     *                  Value of Lead.Hidden_Trigger_Referral_Email__c is also inverted.
     *
     * @param           String leadId
     * @param           String emailId
     *
     * @return          String
     *
     * @date            unknown
     * @author          MST Solutions
     */
    @AuraEnabled
    public static String triggerEmail(String leadId, String emailId){
        Lead processLead = [
            SELECT
                Id,
                Office_Referral_Email__c,
                Hidden_Trigger_Referral_Email__c
            FROM Lead
            WHERE Id = :leadId
            LIMIT 1
        ];

        Lead updateLead = new Lead(Id = processLead.Id);

        updateLead.Office_Referral_Email__c = emailId;
        updateLead.Hidden_Trigger_Referral_Email__c  = !processLead.Hidden_Trigger_Referral_Email__c;

        update updateLead;

        return 'success';
    }
}