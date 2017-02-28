global class batch_FillWishPresentationDate  implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
         Constant_AC  constant = new Constant_Ac();  
         Id parentWishRT = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
         Id wishGrantedRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishGrantRT).getRecordTypeId();
               return Database.getQueryLocator([SELECT Id,ownerid,ParentId,Parent.Anticipated_Start_Date__c,Interview_Date_Not_Set__c FROM CASE WHERE Parent.RecordTypeId =: parentWishRT
                                            AND RecordTypeId =: wishGrantedRecordTypeId AND Parent.Anticipated_Start_Date__c != Null AND Presentation_Date__c= null ]);
    }
   
    global void execute(Database.BatchableContext BC, List<Case> scope) 
    {
    System.debug('>>>>>>scope>>>'+scope);
        List<Task> createTaskList = new List<Task>();
      
        Map<Id,Case> updateGrantedCaseMap = new Map<Id,Case>();
        for(Case currCase : scope)
        {
           date wishPresentationDate = currCase.Parent.Anticipated_Start_Date__c-23;
           date wishPresentationTaskDate=currCase.Parent.Anticipated_Start_Date__c + 15;
           if(wishPresentationDate == Date.Today())
           {
              System.debug('>>>>>>>1');
                  Case toUpdate = new Case();
                  toupdate.id = currCase.Id;
                  toUpdate.Interview_Date_Not_Set__c = True;
                  updateGrantedCaseMap.put(toUpdate.Id,toUpdate);
           }
          if(wishPresentationTaskDate == date.Today()){
              System.debug('>>>>>>>2');
             Task newTask=new Task();
               newTask.subject='Wish Presentation not set';
               newTask.ownerid=currCase.ownerid;
               newTask.Whatid=currCase.Parent.id;
               newTask.ActivityDate=Date.Today()+1;
               createTaskList.add(newTask);
               
           }
           
        }
        
        if(updateGrantedCaseMap.size() > 0){
            update updateGrantedCaseMap.values();
        }
        if(createTaskList.size() > 0){
            System.debug('>>>>>>3');
            insert createTaskList;
        }
    }   
    
    global void finish(Database.BatchableContext BC) {
    }
}