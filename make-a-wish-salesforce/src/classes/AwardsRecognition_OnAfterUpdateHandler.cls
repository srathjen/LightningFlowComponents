/***************************************************************************************************
Author      : MST Solutions
Date        : 10/15/2016
Description : AwardsRecognition_OnAfterInsertTriggerHandler is used to call the Helper class when a
              new Awards & Recognitionrecord is created.
              
              Modification Log
              ------------------
              WVC-1887    Pavithra G  07/03/2018
              
*****************************************************************************************************/
Public class AwardsRecognition_OnAfterUpdateHandler{    
    /*******************
       This method is handle all logic for after Update the Awards and Recognition record Event.
       **********************/
    public static void OnAfterUpdate(Map<Id,Awards_Recognition__c> AwardsRecognitionMap,Map<Id,Awards_Recognition__c> awardsRecOldMap){
          Map<Id,Awards_Recognition__c> awardsRecgMap = new Map<Id,Awards_Recognition__c>();
          for(Awards_Recognition__c  currRec :AwardsRecognitionMap.Values()){ 
              If ( currRec.Chapter_Name__C != Null && currRec.Chapter_Name__C != awardsRecOldMap.get(currRec.Id).Chapter_Name__C ){
                  awardsRecgMap.put(currRec.Id,currRec);
                  
              }
          }
          If(awardsRecgMap.Size() > 0 )
              AwardsRecognition_OnAfterInsertHelper.showErrorMismatchedRole(awardsRecgMap);
    }
}