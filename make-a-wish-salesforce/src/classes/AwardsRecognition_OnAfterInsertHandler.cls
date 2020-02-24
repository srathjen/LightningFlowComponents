/***************************************************************************************************
Author      : MST Solutions
Date        : 10/15/2016
Description : AwardsRecognition_OnAfterInsertTriggerHandler is used to call the Helper class when a
              new Awards & Recognitionrecord is created.
              
              Modification Log
              ------------------
              WVC-1887    Pavithra G  07/03/2018
              
*****************************************************************************************************/
Public class AwardsRecognition_OnAfterInsertHandler{    
    /*******************
       This method is handle all logic for after inserting the Awards and Recognition record Event.
       **********************/
    public static void OnAfterInsert(List<Awards_Recognition__c> AwardsRecognitionList){
          Map<Id,Awards_Recognition__c> awardsRecgMap = new Map<Id,Awards_Recognition__c>();
          for(Awards_Recognition__c  currRec :AwardsRecognitionList){ 
              If ( currRec.Chapter_Name__C != Null){
                  awardsRecgMap.put(currRec.Id,currRec);
                  
              }
          }
          If(awardsRecgMap.Size() > 0 )
              AwardsRecognition_OnAfterInsertHelper.showErrorMismatchedRole(awardsRecgMap);
    }
}