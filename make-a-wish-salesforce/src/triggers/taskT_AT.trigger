trigger taskT_AT on Task (before insert,before update) {
  Constant_AC  constant = new Constant_Ac();
    Id wishGrantedRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishGrantRT).getRecordTypeId(); 
    Id parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();

   Map<Id,Id> caseMap=new Map<Id,Id>();
   for(Task currRec:Trigger.new){
        if((currRec.status=='Completed' && currRec.subject=='Wish Presentation not set')|| (currRec.status=='Completed' && currRec.subject=='Wish not closed')){
            caseMap.put(currRec.id,currRec.whatid);
        }
   }
    if(caseMap.size() > 0 || caseMap!=null ){
        map<id,case> caseMapDB=new Map<id,case>([SELECT id, RecordTypeId, Presentation_Date__c,status from case where Id IN:caseMap.values()  and( Presentation_Date__c=:Null or status='closed'  or  RecordTypeId=:parentWishRecordTypeId or RecordTypeId=:wishGrantedRecordTypeId )]);
        for(Task currTask:trigger.new){
            if(caseMapDB.containsKey(currTask.whatid)){
               if(caseMapDB.get(currTask.whatid).Presentation_Date__c==Null && caseMapDB.get(currTask.whatid).RecordTypeId==wishGrantedRecordTypeId){
                   currTask.adderror('Please Enter The Wish Presentation Date');
                }
                if(caseMapDB.get(currTask.whatid).status!='Closed' && caseMapDB.get(currTask.whatid).RecordTypeId==parentWishRecordTypeId){
                   currTask.adderror('Please Close The  Wish');
                }
            }
        }
    }
}