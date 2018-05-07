global class Batch_UpdateImportantDate_AC implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id, Referred_Date__c, Inquiry_Date__c,
                                         Eligibility_Review_Date__c, DNQ_Date__c,Qualified_Date__c, Status, Pending_Diagnosis_Date__c
                                         FROM Lead]);
    }
    
    global void execute(Database.BatchableContext BC, List<Lead> leadList) {
        Map<ID, Lead> leadMap = new Map<ID, Lead>();
        Set<Id> LeadIdSet = new Set<Id>();
        Set<Id> leadHisId = new Set<Id>();
        Set<Id> referredLeadSetId = new Set<Id>();
        Set<Id> inquiryLeadSetId = new Set<Id>();
        Set<Id> dnqLeadSetId = new Set<Id>();
        Set<Id> eligibilityLeadSetId = new Set<Id>();
        Set<Id> pendingDVLeadSetId = new Set<Id>();
        Set<Id> qualifiedDateSetId = new Set<Id>();
        
        for(Lead le: leadList)
        {
            leadMap.put(le.ID, le);
            
        }
        
        if(leadMap.size() > 0){
            for(LeadHistory leadHis :  [SELECT newValue, createdDate, OldValue, LeadId
                                        FROM LeadHistory
                                        WHERE LeadId IN : leadMap.keySet()
                                        AND (Field = 'Status' OR Field = 'Sub_Status__c') ORDER By createdDate DESC]){
                                            
                                            leadHisId.add(leadHis.LeadID);
                                            if(leadHis.newValue == 'Referred' && !referredLeadSetId.contains(leadHis.LeadID)){
                                                System.debug('Recent Referred Date: '+leadHis.createdDate.date()+'LeadID: '+leadHis.LeadID);
                                                leadMap.get(leadHis.LeadID).Referred_Date__c = leadHis.createdDate.date();
                                                referredLeadSetId.add(leadHis.LeadID);
                                            }
                                            if(leadHis.newValue == 'Inquiry' && !inquiryLeadSetId.contains(leadHis.LeadID)){
                                                System.debug('Recent Inquiry Date: '+leadHis.createdDate.date()+'LeadID: '+leadHis.LeadID);
                                                leadMap.get(leadHis.LeadID).Inquiry_Date__c = leadHis.createdDate.date();
                                                inquiryLeadSetId.add(leadHis.LeadID);
                                            }
                                            if(leadHis.newValue == 'Eligibility Review' && !EligibilityLeadSetId.contains(leadHis.LeadID)){
                                                System.debug('Recent Eligibility Date: '+leadHis.createdDate.date()+'LeadID: '+leadHis.LeadID);
                                                leadMap.get(leadHis.LeadID).Eligibility_Review_Date__c = leadHis.createdDate.date();
                                                EligibilityLeadSetId.add(leadHis.LeadID);
                                            }
                                            if(leadHis.newValue == 'DNQ' && !dnqLeadSetId.contains(leadHis.LeadID)){
                                                System.debug('Recent DNQ Date: '+leadHis.createdDate.date()+'LeadID: '+leadHis.LeadID);
                                                leadMap.get(leadHis.LeadID).DNQ_Date__c = leadHis.createdDate.date();
                                                dnqLeadSetId.add(leadHis.LeadID);
                                            }
                                            if(leadHis.newValue == 'Qualified' && !qualifiedDateSetId.contains(leadHis.LeadID)){
                                                System.debug('Recent Qualified Date: '+leadHis.createdDate.date()+'LeadID: '+leadHis.LeadID);
                                                leadMap.get(leadHis.LeadID).Qualified_Date__c = leadHis.createdDate.date();
                                                qualifiedDateSetId.add(leadHis.LeadID);
                                            }
                                            if(leadHis.newValue == 'Pending Diagnosis Verification' ||
                                               leadHis.newValue == 'Pending Part A' ||
                                               leadHis.newValue == 'Pending Paper DV' && (!pendingDVLeadSetId.contains(leadHis.LeadID))){
                                                   System.debug('Recent Pending Date: '+leadHis.createdDate.date()+'LeadID: '+leadHis.LeadID);
                                                   leadMap.get(leadHis.LeadID).Pending_Diagnosis_Date__c = leadHis.createdDate.date();
                                                   pendingDVLeadSetId.add(leadHis.LeadID);
                                               }           
                                        }
            
            
            if(leadMap.size() > 0)
                update leadMap.values();           
        }
        
    }                                     
    global void finish(Database.BatchableContext BC) {}
    
}