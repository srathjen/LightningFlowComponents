/**
 * @description     This trigger is used to create a debug log record if any error occurred in any trigger or handler.
 * @author          MST Solutions
 * @createdDate     unknown
 */
trigger CloudNewsTrigger on ErrorMessage__e (after insert) {
    try {
        List<Apex_Debug_Log__c> debugLogList = new List<Apex_Debug_Log__c>();

        for (ErrorMessage__e processErrorRec : Trigger.new) {
            Apex_Debug_Log__c newDebugRec = new Apex_Debug_Log__c();
            newDebugRec.Apex_Class__c = processErrorRec.Apex_Class__c;
            newDebugRec.Developer_Message__c = processErrorRec.Developer_Message__c;
            newDebugRec.Message__c = processErrorRec.Message__c;
            newDebugRec.Method__c = processErrorRec.Method__c;
            newDebugRec.Record_Id__c = processErrorRec.Record_Id__c;
            newDebugRec.Stack_Trace__c = processErrorRec.Stack_Trace__c;
            newDebugRec.Type__c = processErrorRec.Type__c;
            debugLogList.add(newDebugRec);
        }

        insert debugLogList;
    } catch (Exception e) {
        System.debug('@@ Exception (CloudNewsTrigger) @@' + e.getMessage());
    }
}