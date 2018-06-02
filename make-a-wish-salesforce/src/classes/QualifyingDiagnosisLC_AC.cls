/***************************************************************************************************
Author      : MST Solutions
CreatedBy   : Pradeep Kumar
Date        : 20/03/2018
Description : Class contains AURA enbaled utility methods used by the QualifyingDiagnosis component
*****************************************************************************************************/

public class QualifyingDiagnosisLC_AC {
    
    /********************************************************************************************
Get the neccessary lead information for further process of sending diagnosis verfication    
***********************************************************************************************/
    @AuraEnabled
    public static Case getMedicalInformation(Id caseId){
        Case data = [SELECT Id, 
                     lead__r.PD_Condition_Description__c,
                     lead__r.PD_ICD_Code__r.Name,
                     lead__r.SD1_Condition_Description__c,
                     lead__r.SD1_ICD_Code__r.Name,
                     lead__r.SD2_Condition_Description__c,
                     lead__r.SD2_ICD_Code__r.Name,
                     lead__r.SD3_Condition_Description__c,
                     lead__r.SD3_ICD_Code__r.Name,
                     lead__r.SD4_Condition_Description__c,
                     lead__r.SD4_ICD_Code__r.Name
                     FROM Case WHERE Id = :caseId LIMIT 1];
        
        return data;
    }
    
    /********************************************************************************************
Get the neccessary lead information for further process of sending diagnosis verfication    
***********************************************************************************************/
    @AuraEnabled
    public static String updateQualifyingDiagnosis(String Qualifying_Diagnosis, Id Qualifying_ICD, Id leadId, String mawName){
        String result;
        Lead data = [SELECT Id, 
                     PD_Condition_Description__c,
                     PD_ICD_Code__r.Id,
                     SD1_Condition_Description__c,
                     SD1_ICD_Code__r.Id,
                     SD2_Condition_Description__c,
                     SD2_ICD_Code__r.Id,
                     SD3_Condition_Description__c,
                     SD3_ICD_Code__r.Id,
                     SD4_Condition_Description__c,
                     SD4_ICD_Code__r.Id,
                     Qualifying_Diagnosis__c,
                     Qualifying_ICD__c,
                     PR_Diagnosis__c
                     FROM Lead WHERE Id = :leadId LIMIT 1];
        
        data.Qualifying_Diagnosis__c = Qualifying_Diagnosis;
        data.Qualifying_ICD__c= Qualifying_ICD;
        data.PR_Diagnosis__c = mawName;
        System.debug('Result Data = ' + data);
        update data;
        result = 'UPDATED';
        return result;
    }
    
/********************************************************************************************
Get the neccessary icd code information for further process  
***********************************************************************************************/
    @AuraEnabled
    public static Id getIcdCodeInfo(String icdCodeName){
           return [SELECT Id,Name FROM ICD_Codes__c WHERE Name = :icdCodeName LIMIT 1].Id;
          
    }
    
/********************************************************************************************
Get the neccessary condition description information for further process  
***********************************************************************************************/
    @AuraEnabled
    public static String getConditionDescInfo(String qc_Diagnosis){
        	String mawName;
        	List<Condition_Description__c> descriptionList = [SELECT Id, PR_Diagnosis__c
                                                                          FROM Condition_Description__c WHERE Name = :qc_Diagnosis limit 1];
            mawName = (descriptionList.size() > 0) ? descriptionList[0].PR_Diagnosis__c : '';
           //System.debug('mawName = ' + mawName);
           return mawName;
          
    }
    
}