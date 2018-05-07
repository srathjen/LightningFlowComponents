/***************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kanagaraj
Date        : 26/05/2016
Description : Lead_OnAfterUpdateTriggerHandler is Invoked when the Lead record is update from LeadTrigger_AT

Modification Log:
1. 06/04/2018 - Vignesh SM - IME 9 - Line No. 44-53, 64-66
*****************************************************************************************************/
Public class Lead_OnAfterUpdateTriggerHandler{
    
    /*******************************************************************************************
When the Lead status is updated as 'Qualified' then it will call the leadConvertion(). And if 
the lead status is updated as 'DNQ' then the Task will created under the lead.
IME- 69 -->Lead will not convert for the specific chapterName.
********************************************************************************************/
    public static void onAfterUpdate(Map<Id,Lead> newLeadMap,Map<Id,Lead> oldLeadMap){
        Map<Id,Lead> qualifiedLeadMap = new Map<Id,Lead>();
        List<Lead> newLeadList = new List<Lead>();
        List<Lead> approvalList = new List<Lead>();
        //IME-69
        Set<String> chapterSet = new Set<String>();
        Map<Id,Boolean> rushLeadMap = new Map<Id,Boolean>(); //IME 9
        
        for(Chapter_Name_Settings__c chapter : Chapter_Name_Settings__c.getAll().Values()){
            chapterSet.add(chapter.Name);
        }
        Map<Id,Account> chapterAccountMap = new Map<Id,Account>([SELECT ID FROM Account WHERE Name IN :chapterSet LIMIT 50000]);
        
        //Map<Lead,Id> lead_IntakUserIdMap = new Map<Lead,Id>(); //Commented for IME-2
        if(RecursiveTriggerHandler.isFirstTime == true)
        { 
            for(Lead newLead : newLeadMap.values()){
                //Commented for IME-2
                /*if(newLead.Status == 'DNQ' && oldLeadMap.get(newLead.Id).Status != newLead.Status && newLead.ChapterName__c != Null){
lead_IntakUserIdMap.put(newLead,newLead.ChapterName__c);
}*/
                //IME- 69 - added chapter name check criteria
                if(!newLead.isConverted && newLead.Status == 'Qualified' && oldLeadMap.get(newLead.id).Status != 'Qualified' && (!chapterAccountMap.containsKey(newLead.ChapterName__c))){
                    qualifiedLeadMap.put(newLead.id,newLead);
                }
                
                //IME 9
                String medicalReason = newLead.Any_medical_reason_for_moving_quickly__c;
                String oldMedicalReason = oldLeadMap.get(newLead.id).Any_medical_reason_for_moving_quickly__c;
                if(medicalReason != null && newLead.Status == 'Eligibility Review'){                                                            
                    if(medicalReason.contains('Yes') && (oldMedicalReason == null || !oldMedicalReason.contains('Yes'))){
                        rushLeadMap.put(newLead.Id, true);
                    }else if(!medicalReason.contains('Yes') && (oldMedicalReason == null || oldMedicalReason.contains('Yes'))){
                        rushLeadMap.put(newLead.Id, false);
                    }
                }
                
            }   
            
        }
        
        if(qualifiedLeadMap.size() > 0)
        {
            Lead_OnAfterUpdateTriggerHandlerHelper leadAfterUpdate = new Lead_OnAfterUpdateTriggerHandlerHelper();
            Lead_OnAfterUpdateTriggerHandlerHelper.leadConvertion(qualifiedLeadMap);
        }
        if(rushLeadMap.size() > 0){
            Lead_OnAfterUpdateTriggerHandlerHelper.updateRushInDVCase(rushLeadMap);
        }
        //Commented for IME-2
        /*if(lead_IntakUserIdMap.Size() > 0)
Lead_OnAfterUpdateTriggerHandlerHelper.createTaskforDNQLeads(lead_IntakUserIdMap);
*/
    }
}