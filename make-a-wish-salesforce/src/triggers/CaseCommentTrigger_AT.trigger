/*****************************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kanagaraj
Date        : 8/24/2016
Description : 
When new case comment is created then it will send the email to the corresponding contact Mac team. 
*******************************************************************************************************************/



trigger CaseCommentTrigger_AT on CaseComment (After insert) {
Constant_AC  constant = new Constant_AC();
public Id partARecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(constant.partARecordTypeId).getRecordTypeId();
    if(Trigger.isAfter && Trigger.isInsert){
       List<Case> caseList = new List<Case>();
        Map<Id,CaseComment > caseCommentMap = new Map<Id,CaseComment >();
        for(CaseComment newComment : trigger.new){
            if(newComment.createdById== UserInfo.getUserId()){
              caseCommentMap.put(newComment.ParentId,newComment);  
            }    
        }
        
        for(Case dbCase : [SELECT Id,CaseNumber,Case_Comment__c,MAC_Email__c,RecordTypeId from Case WHERE Id IN:caseCommentMap.KeySet() AND RecordTypeId =: partARecordTypeId]){
           if(caseCommentMap.containsKey(dbCase.Id)){
                 dbCase.Case_Comment__c  = caseCommentMap.get(dbCase.Id).Commentbody;
                caseList.add(dbCase);
        }
    }
        if(caseList.size() > 0)
        update caseList;
   }
}