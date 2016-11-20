/***************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kanagaraj
Date        : 26/05/2016
Description : LeadTrigger_AT is used to assign the case owner dynamically based on the lead state. And also it is used
to call the approval process automatically when the record is created. And also convert the lead automatically when approver 
approve the record.
*****************************************************************************************************/

trigger LeadTrigger_AT on Lead (Before insert,Before Update,After insert,After Update,Before delete) 
{
    
    /*Assign the case owner dynamically based on the lead state.*/
    if(Trigger.isBefore && Trigger.isInsert)
    {
        List<Lead> newLeadList = new List<Lead>();
        LeadTriggerHandler handlerIns = new LeadTriggerHandler();
        for(Lead newLead : Trigger.new){
            newLead.Part_A_Form_Password__c= handlerIns.getRandom();
           if(newLead.Status == 'Inquiry')
          { 
               boolean referred = true;
               newLead.Inquiry_Date__c = Date.Today();
              
               if(newLead.City == Null || newLead.StateCode == Null || newLead.PostalCode == Null || newLead.Street == Null)
                  referred = false;
               for(Schema.FieldSetMember f : getNonMedicalReqFields())
               {
                
                 if(newLead.get(f.getFieldPath()) == Null)
                 {
                   referred = false;
                 
                 }
                 
               }
               
               if(referred == true)
               {
                
                 newLead.Status = 'Referred';
               }
           }
           
           if(newLead.RFI_Form_Info_Hidden__c==Null && newLead.Override_Dupe_Check__c == false && (newLead.Status == 'Inquiry' || newLead.Status == 'Referred')){
                newLeadList.add(newLead);
            }
            
            if(newLead.Status == 'Referred')
            {
                newLead.Inquiry_Date__c = Date.Today();
                newLead.Referred_Date__c= Date.Today();
            }
         
        }
        
       
        if(newLeadList.size() > 0){
           LeadTriggerHandler.findDuplicateRecords(newLeadList);
        }
    }
    
    /*Initiate Approver process When the Lead record is created.*/
    if(Trigger.isBefore && Trigger.isUpdate)
    {
        List<Lead> newLeadList = new List<Lead>();
        List<Lead> newUpdateLeadList = new List<Lead>();
        List<Lead> leadList = new List<Lead>();
        List<Lead> updateLeadOwnerList = new List<Lead>();
        Set<String> postalCodesSet = new Set<String>();
        List<Lead> updateChapterOnLeadList = new List<Lead>();
        Set<String> icdCodesSet = new Set<String>();
        Set<String> conditionDescriptionsSet = new Set<String>();
        List<Lead>  leadUpdateToMedicalInfoList = new List<Lead>();
        List<Lead> findduplicateList = new List<Lead>();
        List<Lead> leadQuestionList= new List<Lead>();
        
        Boolean flag;
        for(Lead newLead : Trigger.new){
            if(newLead.Status == 'Referred' && Trigger.oldMap.get(newLead.id).status == 'Inquiry'){
                newLead.Referred_Date__c = Date.today();
            }
            
            if((newLead.Sub_Status__c == 'Pending Diagnosis Verification') && trigger.oldMap.get(newLead.id).Sub_Status__c != 'Pending Diagnosis Verification'){
                newLead.Part_A_Sent__c = Date.today();
            }
            
          
            if((newLead.Status == 'Eligibility Review') || (newLead.Status == 'Qualified') && trigger.oldMap.get(newLead.id).Status == 'Referred'){
                newLead.Part_A_Received__c = Date.today();
            }
            
            
            if(newLead.Treating_Medical_Professional_Email__c != trigger.oldmap.get(newLead.id).Treating_Medical_Professional_Email__c)
            {
                 LeadTriggerHandler handlerIns = new LeadTriggerHandler();
                 newLead.Of_Times_Email_Sent__c = 0;
                 newLead.Part_A_Form_Password__c = handlerIns.getRandom();
    
            }
             if(newLead.Medical_Questions__c != trigger.oldMap.get(newLead.id).Medical_Questions__c && newLead.Medical_Questions__c  != Null ){
                leadQuestionList.add(newLead);
            }
                     
            if((newLead.Status == 'Referred')
              && newLead.Override_Dupe_Check__c == false)
            {
                findduplicateList.add(newLead);
            }
          
            if(newLead.LastName != trigger.oldmap.get(newLead.id).LastName || newLead.DOB__c  != Trigger.oldMap.get(newLead.id).DOB__c 
               || newLead.Parent_First_Name__c != trigger.oldMap.get(newLead.id).Parent_First_Name__c && newLead.Override_Dupe_Check__c == False)
               {
                   flag = False;
                   newUpdateLeadList.add(newLead);
               }
            
            if(newLead.PostalCode != Null && newLead.PostalCode != Trigger.oldMap.get(newLead.Id).postalCode)
            {
               postalCodesSet.add(newLead.PostalCode);
               updateChapterOnLeadList.add(newLead);
            }
          
           if(newLead.ICD_10_Code__c != Null && newLead.ICD_10_Code__c != Trigger.oldMap.get(newLead.id).ICD_10_Code__C)
           {
               icdCodesSet.add(newLead.ICD_10_Code__c);
               leadUpdateToMedicalInfoList.add(newLead);
               
           }
           else if(newLead.ICD_10_Code__C == Null)
           {
              newLead.Short_Description__c = '';
              newLead.Long_Description__c = '';
              newLead.Group_1__c = false;
              newLead.MAW_Name__c = '';
           }
           
           if(newLead.Primary_Diagnosis__c != Null && newLead.Primary_Diagnosis__c != Trigger.oldMap.get(newLead.id).Primary_Diagnosis__c)
           {
               conditionDescriptionsSet.add(newLead.Primary_Diagnosis__c);
               leadUpdateToMedicalInfoList.add(newLead);
               
           }
           else if(newLead.Primary_Diagnosis__c == Null && newLead.Primary_Diagnosis__c != Trigger.oldMap.get(newLead.id).Primary_Diagnosis__c)
           {
             newLead.MAW_Name__c = '';
           }
           
           if(newLead.Status == 'Eligibility Review' && trigger.oldMap.get(newLead.Id).Status != 'Eligibility Review'){
               leadList.add(newLead);
           }
            
        }
        if(leadQuestionList.size() > 0){
            LeadTriggerHandler handlerIns = new LeadTriggerHandler();
           //handlerIns.updateLeadStatus(leadQuestionList);
        }
       
        if(newUpdateLeadList.size() > 0){
        
            LeadTriggerHandler handlerIns = new LeadTriggerHandler();
           
        }
        
        if(postalCodesSet.size() > 0)
        {
            LeadTriggerHandler.UpdateChatperName(postalCodesSet,updateChapterOnLeadList);
        }
        
        if(leadUpdateToMedicalInfoList.size() > 0)
        {
          LeadTriggerHandler.ToUpdateMedicalInfo(conditionDescriptionsSet,icdCodesSet,leadUpdateToMedicalInfoList);
        }
        if(leadList.size() > 0){
            
            LeadTriggerHandler handlerIns = new LeadTriggerHandler();
            handlerIns.CreateNewCase(leadList);
        }
        
        if(findduplicateList.size() > 0)
        {
        
           LeadTriggerHandler.findDuplicateRecords(findduplicateList);
        }
        
        
}
    
    /*Convert the lead records when it is approved.*/
    if(Trigger.isAfter && Trigger.isUpdate){
        List<Lead> newLeadList = new List<Lead>();
        List<Lead> approvalList = new List<Lead>();
        
       for(Lead newLead : Trigger.new){
            if(!newLead .isConverted && newLead.Status == 'Qualified' && Trigger.oldmap.get(newLead.id).Status != 'Qualified'){
                newLeadList.add(newLead);
            }
            
        }
        if(newLeadList.size() > 0)
        {
            LeadTriggerHandler handlerIns = new LeadTriggerHandler();
            handlerIns.onAfterUpdate(newLeadList);
        }
    } 
    
   if(Trigger.isAfter && Trigger.isInsert)
   {
       List<Task> newTaskList = new List<Task>();
       for(Lead newLead : Trigger.new)
       {
           Task newTask = new Task();
           if(newLead.status == 'Inquiry') {
               newTask.subject = 'New Inquiry Submitted';
               newTask.ActivityDate = Date.Today().addDays(30);
           }
           if(newLead.status == 'Referred') {
               newTask.subject = 'New Referral Submitted';
               newTask.ActivityDate = Date.Today().addDays(10);
           }
           newTask.ownerId = newLead.OwnerId;
           newTask.whoId = newLead.id;
           newTask.priority = 'Normal';
           newTaskList.add(newTask);
       }
      
       if(newTaskList.size() > 0)
       {
           insert newTaskList;
       }
        
      
   }
    
    
       // Medical Referral Field set contains the mandatory fields of Medical Professional.
    public List<Schema.FieldSetMember> getNonMedicalReqFields() {
        return SObjectType.Lead.FieldSets.Non_Medical_Referral_Required_Fields.getFields();
    }
    
     // Before delete Event.
    If(Trigger.isBefore && Trigger.isDelete)
    {
        List<Id> ids = new List<Id>();
        for(Lead obj : Trigger.old)
        {            
            ids.add(obj.Id);     
        }             
        Integer tempCount = [Select count() from Lead_File__c where Lead_File__c.WIP__c = false and Lead_File__c.Parent__c in:ids];
        if(tempCount > 0)     
        {          
            Trigger.old[0].addError('There are files attached to object. You need to first delete files manually and then delete the object!');
        }
     }   
}