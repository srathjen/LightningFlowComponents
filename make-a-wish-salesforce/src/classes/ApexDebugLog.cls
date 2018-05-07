/*
 * Description: This Apex Class exposes method(s) that can be utilized by 
 * other Apex Classes to create Persistent Logs of type Error or
 * Information as opposed to native Debug Logs. 
 * 
 * Created By: MST Solutions.
 * 
 * Created Date: Dec 15, 2017
 * 
*/
global class ApexDebugLog{
    /*
        A Virtual Class that Defines the 
        Structure of a Log
    */
    public virtual class Log{
        public String Type;
        public String ApexClass;
        public String Method;
        public String RecordId;
        public String Message;
        public String StackTrace;
        public string developerMessage;
    }    
    /*
        A Class that Extends the Virtual Class - Log
        to define a log of type - Error
    */
    public class Error extends Log{
        public Error(String cls, String routine, String recId, Exception ex,String devMsg){
            this.Type = 'Error';
            this.ApexClass = cls;
            this.Method = routine;
            this.RecordId = recId;
            this.Message = (ex != Null) ? ex.getMessage() : Null;
            this.StackTrace = (ex != Null) ? ex.getStackTraceString() : Null;
            this.developerMessage = devMsg;
        }
    }

    /*
        A Class that Extends the Virtual Class - Log
        to define a log of type - Information
    */
    public class Information extends Log{
        public Information(String cls, String routine, String recId, String msg,String devMsg){
            this.Type = 'Information';
            this.ApexClass = cls;
            this.Method = routine;
            this.RecordId = recId;
            this.Message = msg;
            this.StackTrace = NULL;
            this.developerMessage = devMsg;
        }
    }

    /*
        A Public Method that can be utilized by
        other Apex Classes to create a record into
        the Apex Debug Log object stating the Error
        or Information.
    */
    public void createLog(Log logToCreate){
        try{
            /*
                Ensure that we're well within the Governor Limits.
                The creation of the Log shouldn't disturb the execution
                of that Apex Class that utilizes this method to
                create a log.
            */
            if(
                (Limits.getDMLRows() < Limits.getLimitDMLRows()) && 
                (Limits.getDMLStatements() < Limits.getLimitDMLStatements())
            )
            {
                Apex_Debug_Log__c apexDebuglog = new Apex_Debug_Log__c(
                    Type__c         = logToCreate.Type,
                    Apex_Class__c   = logToCreate.ApexClass,
                    Method__c       = logToCreate.Method,
                    Record_Id__c    = logToCreate.RecordId,
                    Message__c      = logToCreate.Message,
                    Stack_Trace__c  = logToCreate.StackTrace,
                    Developer_Message__c = logToCreate.developerMessage
                );

               Database.insert(apexDebuglog, FALSE);
               //Insert apexDebuglog;
                system.debug('Record ID**:'+apexDebuglog.Id);
            }
            else{
                System.debug('The Governor Limits have already been exhausted and hence failed to create a Log!');
            }
        }
        catch(DMLException ex){
            System.debug('Something fatal has occurred and hence failed to create a Log! Error:' + ex.getMessage());
        }
    }

    /*
        A Public Method that can be utilized from
        JavaScript to create record(s) [aka Logs] into the
        Custom Object.
    */
    webService
    static void createLog(String log){
        try{
            /*
                Expects a JSON of the form - 
                {
                    "Type"       : "---",
                    "ApexClass"  : "---",
                    "Method"     : "---",
                    "RecordId"   : "---",
                    "Message"    : "---",
                    "StackTrace" : "---",
                    "DeveloperMessage" : "---"
                }
            */

            /*Deserialize the same to create an instance of the virtual class - ApexDebugLog.Log*/
            ApexDebugLog.Log logToCreate = (ApexDebugLog.Log)JSON.deserialize(log, ApexDebugLog.Log.class);
            
            new ApexDebugLog().createLog(logToCreate);
        }
        catch(Exception ex){
            System.debug('Something fatal has occurred and hence failed to create a Log! Error:' + ex.getMessage());
        }
    }
}