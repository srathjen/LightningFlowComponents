/*****************************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kanagaraj
Date        : 8/24/2016
Description : When the wish child replay back to the case comment then it will create aa a new case comment under the 
              corresponding case.
  
*******************************************************************************************************************/

trigger EmailTrigger_AT on EmailMessage (After insert) {
     
     if(trigger.isAfter  && trigger.isInsert){
        List<CaseComment> caseCommentList = new List<CaseComment>();
        Set<Id> ParentIdSet = new Set<Id>();
        Map<Id,Case> caseMap = new Map<Id,Case>();
         for(EmailMessage newMessage : trigger.new){
             if(newMessage.TextBody != null && newMessage.ParentId != null && newMessage.FromAddress != Null){
                
                ParentIdSet.add(newMessage.ParentId);
             }
         }
            
           for(Case dbCase : [SELECT Id,MAC_Email__c,Status FROM Case WHERE Id in: ParentIdSet]){
               caseMap.put(dbCase.Id,dbCase);
           }
            
            for(EmailMessage newMessage : trigger.new){
            System.debug('newMessage.ParentId********'+newMessage.ParentId+'newMessage.FromAddress*****'+newMessage.FromAddress);
             if(caseMap.containsKey(newMessage.ParentId )){
                // if(caseMap.get(newMessage.ParentId).MAC_Email__c == newMessage.FromAddress )
                 {
                     CaseComment newComment = new CaseComment();
                     newComment.CommentBody = newMessage.TextBody;
                     newComment.ParentId = newMessage.ParentId;
                     caseCommentList.add(newComment);
                 }
            }
         }
          
             if(caseCommentList.size() > 0){
                 insert caseCommentList;
             }    
        
     }

}