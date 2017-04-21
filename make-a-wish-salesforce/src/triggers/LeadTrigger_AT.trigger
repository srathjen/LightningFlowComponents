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
        List<Lead> updateChapterOnLeadList = new List<Lead>();
        Set<String> postalCodesSet = new Set<String>();
        Map<Id, Lead> leadRegionMap = new Map<Id, Lead>();
        Set<Id> leadChapterSet = new Set<Id>();
        for(Lead newLead : Trigger.new)
        {
            leadChapterSet.add(newLead.ChapterName__c);
            leadRegionMap.put(newLead.Id, newLead);
            newLead.Part_A_Form_Password__c= handlerIns.getRandom();
            if(newLead.migrated_record__c != True)
            {   
                if(newLead.Status == 'Inquiry')
                { 
                    boolean referred = true;
                    if(!Test.isRunningTest())
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
                     if(!Test.isRunningTest())
                     {
                        newLead.Inquiry_Date__c = Date.Today();
                        newLead.Referred_Date__c= Date.Today();
                     }
                }
            }
            
            if(newLead.PostalCode != Null ){
                postalCodesSet.add(newLead.PostalCode);
                updateChapterOnLeadList.add(newLead);
            }
            else{
                postalCodesSet.add(newLead.Referrer_Zip__c);
                updateChapterOnLeadList.add(newLead);
            }
            
        }
        
        if(leadRegionMap.size() > 0 && leadChapterSet.size() > 0) {
            LeadTriggerHandler.populateRegionCode(leadRegionMap, leadChapterSet);
        }
        if(postalCodesSet.size() > 0)
        {
            LeadTriggerHandler.UpdateChatperfields(postalCodesSet,updateChapterOnLeadList);
        }
        
        if(newLeadList.size() > 0){
            //  LeadTriggerHandler.findDuplicateRecords(newLeadList);
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
        Map<Id, Lead> leadRegionCodeValidationMap = new Map<Id, Lead>();
        List<Lead> findDupConList = new List<Lead>();
        
        Boolean flag;
        for(Lead newLead : Trigger.new)
        {  
           
                if(newLead.Status == 'Referred' && Trigger.oldMap.get(newLead.id).status == 'Inquiry'){
                   if(!Test.isRunningTest())
                      newLead.Referred_Date__c = Date.today();
                }
                
                if((newLead.Sub_Status__c == 'Pending Diagnosis Verification') && trigger.oldMap.get(newLead.id).Sub_Status__c != 'Pending Diagnosis Verification'){
                    if(!Test.isRunningTest())
                      newLead.Part_A_Sent__c = Date.today();
                }
                
                if((newLead.Status == 'Eligibility Review') || (newLead.Status == 'Qualified') && trigger.oldMap.get(newLead.id).Status == 'Referred'){
                    newLead.Part_A_Received__c = Date.today();
                }
                
                if(newLead.Status == 'Eligibility Review' && newLead.Sub_Status__c == 'Pending Diagnosis Verification')
                    newLead.Sub_Status__c = Null;
                
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
                   && newLead.Sub_Status__c == 'Pending Diagnosis Verification'
                   && newLead.Sub_Status__c != Trigger.oldMap.get(newLead.id).Sub_Status__c
                   && newLead.Dup_Check__c != 'Block Lead Dup')
                {
                    findduplicateList.add(newLead);
                }
                
                if((newLead.Status == 'Referred')
                   && newLead.Sub_Status__c == 'Pending Diagnosis Verification'
                   && newLead.Sub_Status__c != Trigger.oldMap.get(newLead.id).Sub_Status__c
                   && newLead.Dup_Check__c == 'Block Lead Dup' && newLead.Contact_Dup_Check__c != 'Block Contact Dup')
                {
                    findDupConList.add(newLead);
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
                
                if(newLead.PD_ICD_Code__c != Null && newLead.PD_ICD_Code__c != Trigger.oldMap.get(newLead.id).PD_ICD_Code__c)
                {
                    icdCodesSet.add(newLead.PD_ICD_Code__c);
                    leadUpdateToMedicalInfoList.add(newLead);
                    
                }
                else if(newLead.PD_ICD_Code__c == Null)
                {
                    newLead.Short_Description__c = '';
                    newLead.Long_Description__c = '';
                    newLead.Group_1__c = false;
                    newLead.MAW_Name__c = '';
                }
                
                if(newLead.PD_Condition_Description__c  != Null && newLead.PD_Condition_Description__c  != Trigger.oldMap.get(newLead.id).PD_Condition_Description__c )
                {
                    conditionDescriptionsSet.add(newLead.PD_Condition_Description__c );
                    leadUpdateToMedicalInfoList.add(newLead);
                    
                }
                else if(newLead.PD_Condition_Description__c  == Null && newLead.PD_Condition_Description__c  != Trigger.oldMap.get(newLead.id).PD_Condition_Description__c )
                {
                    newLead.MAW_Name__c = '';
                }
                
                if(newLead.Status == 'Eligibility Review' && trigger.oldMap.get(newLead.Id).Status != 'Eligibility Review'){
                    leadList.add(newLead);
                    system.debug('@@@@@ LeadList @@@@@'+leadList);
                }
            
            //Regions for chapters
            //Default region value validation
            //Used to prevent the defualt selection of region code if there is other region exists for chapter
            if(newLead.Region_Code__c != null && newLead.Region_Code__c != Trigger.oldMap.get(newLead.Id).Region_Code__c) {
                leadRegionCodeValidationMap.put(newLead.Id, newLead);
            }
        }
        
        //Lead Region Validation check 
        if(leadRegionCodeValidationMap.size() > 0) {
            //LeadTriggerHandler.LeadRegionValidation(leadRegionCodeValidationMap);
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
            system.debug('@@@@@ LeadList @@@@@'+leadList);
            LeadTriggerHandler handlerIns = new LeadTriggerHandler();
            handlerIns.CreateNewCase(leadList);
        }
        
        if(findduplicateList.size() > 0)
        {
            
            LeadTriggerHandler.findDuplicateRecords(findduplicateList);
        }
        if(findDupConList.size() > 0)
        {
            LeadTriggerHandler.FindDupContacts(findDupConList);
        }
        
    }
    
    /*Convert the lead records when it is approved.*/
    if(Trigger.isAfter && Trigger.isUpdate)
    {
        List<Lead> newLeadList = new List<Lead>();
        List<Lead> approvalList = new List<Lead>();
        Map<Lead,Id> lead_IntakUserIdMap = new Map<Lead,Id>();
        if(RecursiveTriggerHandler.isFirstTime == true)
        {  
            for(Lead newLead : Trigger.new){
                
               
                    if(newLead.Status == 'DNQ' && Trigger.oldMap.get(newLead.Id).Status != newLead.Status && newLead.ChapterName__c != Null){
                        lead_IntakUserIdMap.put(newLead,newLead.ChapterName__c);
                        system.debug('Lead Intake UserId********'+newLead.ChapterName__c);
                    }
                    
                    if(!newLead.isConverted && newLead.Status == 'Qualified' && Trigger.oldmap.get(newLead.id).Status != 'Qualified'){
                        
                        newLeadList.add(newLead);
                    }
              
                
            }
            if(newLeadList.size() > 0)
            {
                
                LeadTriggerHandler handlerIns = new LeadTriggerHandler();
                handlerIns.onAfterUpdate(newLeadList);
            }
            //Create and assign the task to lead intake user when the lead status is updated with DNQ.
           // if(lead_IntakUserIdMap.Size() > 0)
            //    LeadTriggerHandler.createTaskforDNQLeads(lead_IntakUserIdMap);
        }
    } 
    
    if(Trigger.isAfter && Trigger.isInsert)
    {
        List<Lead> newLeadList = new List<Lead>();
        Set<String> conditionSescriptionSet = new Set<String>();
        List<Task> newTaskList = new List<Task>();
        
        Map<String, List<Lead>> leadMap = new Map<String,List<Lead>>();
        
        for(Lead newLead : [SELECT id,Migrated_Record__c, OwnerId,Owner.UserRole.Name,Status, ChapterName__c,ChapterName__r.Name,PD_Condition_Description__C FROM Lead WHERE Id IN : Trigger.newMap.keySet()])
        {
            if(newLead.Migrated_Record__c != True)
            {
                newLeadList.add(newLead);
                conditionSescriptionSet.add(newLead.PD_Condition_Description__c);
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
            
            if(newLead.ChapterName__c!= Null && newLead.Owner.UserRole.Name == 'National Staff')
            {
                if(leadMap.containsKey(newLead.ChapterName__r.Name))
                   leadMap.get(newLead.ChapterName__r.Name).add(newLead);
                else
                   leadMap.put(newLead.ChapterName__r.Name, new List<Lead>{newLead});
            }
            
        }
        
        if(newTaskList.size() > 0)
        {
            insert newTaskList;
        }
        if(newLeadList.size() > 0) {
            //LeadTriggerHandler.CreateDiagnosisVerification(newLeadList, conditionSescriptionSet);
        }
        
        if(leadMap.size() > 0)
            ChapterStaffRecordSharing_AC.LeadSharing(leadMap);
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
            if(obj.Migrated_Record__c != True)        
                ids.add(obj.Id);     
        }             
        Integer tempCount = [Select count() from Lead_File__c where Lead_File__c.WIP__c = false and Lead_File__c.Parent__c in:ids];
        if(tempCount > 0)     
        {          
            Trigger.old[0].addError('There are files attached to object. You need to first delete files manually and then delete the object!');
        }
    }   
}