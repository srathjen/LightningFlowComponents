/***************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kanagaraj
Date        : 02/22/2018
Description : ErrorMessage_AC is invoked when an exception is occured in apex trigger and visualforce page.
*****************************************************************************************************/
Public class ErrorMessage_AC{

    //This method is used to create a record in ErrorMessage__e object when an exception is occured Apex trigger.
    public static void createdebugRec(string className,string devMesg,string msg,string methodName,string recId,string stackTrace,string type){
        
         List<ErrorMessage__e> errorMessageList = new List<ErrorMessage__e>();
             
             ErrorMessage__e  newsEvent = new ErrorMessage__e();
             newsEvent.Apex_Class__c = className;
             newsEvent.Developer_Message__c = devMesg;
             newsEvent.Message__c = msg;
             newsEvent.Method__c  = methodName;
             newsEvent.Record_Id__c = recId;
             newsEvent.Stack_Trace__c = stackTrace;
             newsEvent.Type__c = type;
             errorMessageList.add(newsEvent);
           List<Database.SaveResult> results = EventBus.publish(errorMessageList);
          
          for (Database.SaveResult sr : results) {
                if (sr.isSuccess()) {
                    System.debug('Successfully published event.');
                } else {
                      for(Database.Error err : sr.getErrors()) {
                        System.debug('Error returned: '+err.getStatusCode()+' - ' + err.getMessage());
                       }
                  }       
        }
    }
    
  }