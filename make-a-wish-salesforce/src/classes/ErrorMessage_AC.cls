public class ErrorMessage_AC {
    /**
     * This method is used to create a record in ErrorMessage__e object when an exception occurs in Apex
     *
     * @param className
     * @param devMesg
     * @param msg
     * @param methodName
     * @param recId
     * @param stackTrace
     * @param type
     */
    public static void createDebugRec(String className, String devMesg, String msg, String methodName, String recId, String stackTrace, String type) {
        ErrorMessage__e newsEvent = new ErrorMessage__e();
        newsEvent.Apex_Class__c = className;
        newsEvent.Developer_Message__c = devMesg;
        newsEvent.Message__c = msg;
        newsEvent.Method__c = methodName;
        newsEvent.Record_Id__c = recId;
        newsEvent.Stack_Trace__c = stackTrace;
        newsEvent.Type__c = type;
        Database.SaveResult result = EventBus.publish(newsEvent);

        if (result.isSuccess()) {
            System.debug('Successfully published event.');
        } else {
            for (Database.Error err : result.getErrors()) {
                System.debug('Error returned: ' + err.getStatusCode() + ' - ' + err.getMessage());
            }
        }
    }
}