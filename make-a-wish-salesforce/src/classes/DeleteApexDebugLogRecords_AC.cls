/*
* Description: This Batch Class will delete the records in the ApexDebugLog Object based on the Custum setting. 
* 
* Created By: MST Solutions.
* 
* Created Date: Dec 28, 2017
* 
*/
global class DeleteApexDebugLogRecords_AC implements Database.Batchable<sObject>{  
    public String query; 
    public String queryWhere;
    public Integer maxRecordCount = 0;
    public Datetime dt;
    
    public DeleteApexDebugLogRecords_AC(){
        query = 'SELECT Id,CreatedDate FROM Apex_Debug_Log__c';
        Map<String, ApexDebugLogSetting__c> apexDebugLogSetting = ApexDebugLogSetting__c.getAll();       
        if(apexDebugLogSetting.size() > 0){
            List<ApexDebugLogSetting__c> apexDebugLogSettingList = apexDebugLogSetting.values();
            ApexDebugLogSetting__c currApexDebugLog = apexDebugLogSettingList[0]; 
            if(currApexDebugLog.Number_of_records_needs_to_preserve__c != Null ){
                Apex_Debug_Log__c thresholdRecord = Database.query(query + ' ORDER BY CreatedDate DESC LIMIT 1 OFFSET '+ math.round(currApexDebugLog.Number_of_records_needs_to_preserve__c));
                System.debug('thresholdRecord: '+thresholdRecord);
                dt = thresholdRecord.CreatedDate;
                queryWhere = ' WHERE CreatedDate <=: dt';
            }
            else if(currApexDebugLog.Number_of_records_needs_to_preserve__c == Null && currApexDebugLog.Interval_to_clear_the_debug_log__c != Null){
                queryWhere = ' WHERE CreatedDate != LAST_N_DAYS: '+ math.round(currApexDebugLog.Interval_to_clear_the_debug_log__c);			        
            }            
        }       
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        if(queryWhere == null){
            Date todayDate = Date.today();
            queryWhere = ' WHERE CreatedDate >: todayDate';
        }
        query = query + queryWhere;
        System.debug('query++++'+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC,List<sObject> scope){
        try{
            System.debug('scope'+scope);
            Delete scope;            
        }Catch(Exception exp){
            try{
                new ApexDebugLog().createLog( new ApexDebugLog.Error(
                    'DeleteApexDebugLogRecords_AC',
                    'execute',
                    NULL,
                    exp,
                    'Error Happend in the Batch Class'
                ));
                
            }catch(Exception ex){}
        }
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
    
}