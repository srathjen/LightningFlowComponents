Public class  InactiveVolunteerHandler{
@future
    public Static void createTaskforVolunteerManager(Set<Id> userList){
        
        Map<Id,Id> volunteerManagerId = new Map<Id,Id>();
        List<Volunteer_Opportunity__c> VolunteerOpportunityActive=new List<Volunteer_Opportunity__c>([SELECT id,Chapter_Name__r.Volunteer_Manager__c,Volunteer_Name__c  FROM Volunteer_Opportunity__c WHERE Volunteer_Name__c IN: userList AND Inactive__c =False]);
        for(Volunteer_Opportunity__c  currRec:VolunteerOpportunityActive){
               volunteerManagerId.put(currRec.Volunteer_Name__c,currRec.Chapter_Name__r.Volunteer_Manager__c);
               system.debug('*********'+currRec.Volunteer_Name__c+'*****');
        }
        if(volunteerManagerId.size() >0){
            List<Task> ActiveTask=new List<Task>();
            Task newTask;
            for(Id currRec:volunteerManagerId.keyset()){
                    newTask=new Task();
                    newTask.OwnerId=volunteerManagerId.get(currRec);
                    newTask.WhoId=currRec;
                    newTask.Subject='Inactive Volunteer - review volunteer opportunities';
                    ActiveTask.add(newTask);
                    system.debug('@@@@@@@@@@@'+currRec+'*****');     
        }
         Insert ActiveTask;
    }
    
}
}