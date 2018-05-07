/************************************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kanagaraj
Date        : 26/05/2016
Description : Lead_OnBeforeInsertTriggerHandlerHelper is used to invoke populateRegionCode,UpdateChatperfields and updateHiddenchapterName
              methods when the lead record is created.
*************************************************************************************************************************/
Public class Lead_OnBeforeInsertTriggerHandlerHelper{
    
/****************************************************************************
This populateRegionCode() this method is used to populate the region code value
to lead record based on the chapter name.
****************************************************************************/    
    public static void populateRegionCode(Map<Id,Lead> leadMap, Set<Id> leadChapterSet) {
        Set<Id> chapterRegionSet = new Set<Id>();
        Set<Id> defaultchapterRegionSet = new Set<Id>();
        try{
        for(AggregateResult aggr : [SELECT Count(Id) cnt ,Chapter_Name__c cName FROM Regions__c WHERE Chapter_Name__c != null AND Chapter_Name__c IN : leadChapterSet GROUP BY Chapter_Name__c Limit 50000]) {
            chapterRegionSet.add((Id)aggr.get('cName'));
        }
        
        List<Regions__c> regionCodeList = [SELECT Id, Chapter_Name__c FROM Regions__c WHERE Chapter_Name__c = null LIMIT 1];
        
        for(Lead leadUpdate : leadMap.values()) {
            if(!chapterRegionSet.contains(leadUpdate.ChapterName__c)) {
                if(regionCodeList.size() > 0) {
                    leadUpdate.Region_Code__c = regionCodeList.get(0).Id;
                }
            }
         }
        }
        
        catch(Exception ex){
        for(Lead currRec : leadMap.values()){
              ErrorMessage_AC.createdebugRec('Lead_OnBeforeInsertTriggerHandlerHelper',String.valueof(currRec),String.valueOf(ex.getCause()),'populateRegionCode','Null',ex.getStackTraceString(),'Error');
         }
         for(Lead currRec : leadMap.values()){
                  currRec.addError(Label.Debug_log_error_message);
         }
        }
    }
    
    /*****************************************************************************************************
This UpdateChatperfields() method is used to update the chaptername if the zipcode value is updated.
* ***************************************************************************************************/
    public static void UpdateChatperfields(Set<String> postalCodesSet,List<Lead> updateChapterOnLeadList)
    {
        Map<String,String> zipCodeChapterMap = new Map<String,String>();
        Map<String,String> zipCodeReferralMap = new Map<String,String>();
        Map<String,Boolean> chapterActiveMap = new Map<String,Boolean>();
        
        try{       
        for(Zip_Code__c currZipCode :  [SELECT id, Name,Office__r.Chapter__c, Office__r.Referral_Email_Address__c FROM Zip_Code__c WHERE Name IN :postalCodesSet Limit 50000])
        {
            zipCodeChapterMap.put(currZipCode.Name,currZipCode.Office__r.Chapter__c);
            zipCodeReferralMap.put(currZipCode.Name,currZipCode.Office__r.Referral_Email_Address__c);
        }
        
        for(Account accdata: [select Id, Onboarded_on_SF__c,Intake_Manager__r.Email from Account where id in : zipCodeChapterMap.values() Limit 50000]){
            chapterActiveMap.put(accdata.Id, accdata.Onboarded_on_SF__c);
        }
        for(Lead currLead : updateChapterOnLeadList)
        {
            if(zipCodeReferralMap.containsKey(currLead.PostalCode))
            {
                currLead.Office_Referral_Email__c= zipCodeReferralMap.get(currLead.PostalCode);
            }
            else  if(zipCodeReferralMap.containsKey(currLead.Referrer_Zip__c))
            {
                currLead.Office_Referral_Email__c= zipCodeReferralMap.get(currLead.Referrer_Zip__c);
                
            }
            else
            {
                currLead.Office_Referral_Email__c= Null;
            }
            
            if(chapterActiveMap.containsKey(currLead.ChapterName__c)){
                currLead.Is_Chapter_Active__c=chapterActiveMap.get(currLead.ChapterName__c);
            }
        }
       }
       
       catch(Exception ex){
       
        for(Lead currRec : updateChapterOnLeadList){
               ErrorMessage_AC.createdebugRec('Lead_OnBeforeInsertTriggerHandlerHelper',String.valueof(currRec),String.valueOf(ex.getCause()),'UpdateChatperfields','Null',ex.getStackTraceString(),'Error');
         }
        for(Lead currRec : updateChapterOnLeadList){
               currRec.addError(Label.Debug_log_error_message);
         }
        }
    }
    
    /****************************************************************************************
Used to update the hidden chapter name value.
******************************************************************************************/  
    public static void updateHiddenchapterName(Set<id> accountIdSet,List<Lead> leadList){
      
        Map<Id,Account> accountNameMap = new Map<Id,Account>();
        
        try{
        for(Account currAcc  : [SELECT id,Name,Intake_Manager__r.Email,Intake_Manager__c FROM Account WHERE Id IN :accountIdSet Limit 50000]){
            accountNameMap.put(currAcc.Id,currAcc);
        }
        for(Lead currLead :leadList){
            if(accountNameMap.containsKey(currLead.ChapterName__c)){
                currLead.Hidden_Chapter_Name__c = accountNameMap.get(currLead.ChapterName__c).Name;
                
            }
        }
       }
       catch(Exception ex){
          for(Lead currRec : leadList){
                 ErrorMessage_AC.createdebugRec('Lead_OnBeforeInsertTriggerHandlerHelper',String.valueof(currRec),String.valueOf(ex.getCause()),'updateHiddenchapterName','Null',ex.getStackTraceString(),'Error');
             }
             for(Lead currRec : leadList){
                  currRec.addError(Label.Debug_log_error_message);
         }
        }
    }
}