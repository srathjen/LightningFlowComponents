/**
* @description DV Child Information Controller
* @author Brittany Maclaughlin, Make-A-Wish
* @createdDate 02/09/2021
*/
public class DVChildInfoController {
    
    @AuraEnabled(cacheable=true)
    public static ChildInformationWrapper getLeadChildInformation(String leadId) {
        ChildInformationWrapper dvChildInfoWrapper = new ChildInformationWrapper();
        if (String.isBlank(leadId)){
            return dvChildInfoWrapper;

        } 
     
       Lead dvLead = [
            SELECT Id, Name, Gender__c, DOB_Text__c, Parent_First_Name__c, Parent_Last_Name__c, Referring_MP__r.FirstName, Referring_MP__r.LastName, Referrer_Last_Name__c, Relationship_to_child__c, 
            Diagnosis_Given_By_Referrer__c, ICD_Given_By_Referrer__r.Name
            FROM Lead 
            WHERE Id = :leadId
        ];
        
        
            dvChildInfoWrapper.leadId = dvLead.Id;
            dvChildInfoWrapper.name = dvLead.Name;
            dvChildInfoWrapper.gender = dvLead.Gender__c;
            dvChildInfoWrapper.dob = dvLead.DOB_Text__c;
            dvChildInfoWrapper.parentGuardianName =dvLead.Parent_First_Name__c + ' ' + 
            dvLead.Parent_Last_Name__c;
            dvChildInfoWrapper.referrerName = dvLead.Referring_MP__r.FirstName + ' ' + 
                    dvLead.Referring_MP__r.LastName;
            dvChildInfoWrapper.relationshipToChild = dvLead.Relationship_to_child__c;
            dvChildInfoWrapper.diagnosisGivenByReferrer = dvLead.Diagnosis_Given_By_Referrer__c;
            dvChildInfoWrapper.icdGivenByReferrer = dvLead.ICD_Given_By_Referrer__r.Name;
            
        
        return dvChildInfoWrapper;
    }
    
   
    
    public class ChildInformationWrapper {
        @AuraEnabled
        public Id leadId {get; set;}
        @AuraEnabled
        public String name {get; set;}
        @AuraEnabled
        public String gender {get; set;}
        @AuraEnabled
        public String dob {get; set;}
        @AuraEnabled
        public String parentGuardianName {get; set;}
        @AuraEnabled
        public String referrerName {get; set;}
        @AuraEnabled
        public String relationshipToChild {get; set;}
        @AuraEnabled
        public String diagnosisGivenByReferrer {get; set;}
        @AuraEnabled
        public String icdGivenByReferrer {get; set;}
       
    }
}