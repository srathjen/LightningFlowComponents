public class PARTAPDF {
    public Id leadId {get;set;}
    public lead currLead {get;set;}
    public String currentCondition {get;set;}
    public List<Diagnosis_Verification__c> diagnosisVerificationList {get;set;}
    public Map<Id, String> medicalQuestionMap {get;set;}
    public List<Diagnosis_Verification__c> questionList {get;set;}
   
    public PARTAPDF () {
        leadId = ApexPages.currentPage().getParameters().get('leadId');
        questionList = new List<Diagnosis_Verification__c>(); 
        diagnosisVerificationList = new List<Diagnosis_Verification__c>();
        medicalQuestionMap = new Map<Id, String>();
        loadData();
    }
    public void loadData() {
        
        String  query = 'SELECT FirstName, RFI_Form_Info_Hidden__c, Override_Dupe_Check__c, isConverted, Please_Explain_Deteriorate__c, LastName ,Email, Phone, Name, id, ';
        for(Schema.FieldSetMember currField :getPartAFields()) {
            query+=currField.getFieldPath()+',';
        }
        query=query.removeEnd(',');
        query+=' FROM Lead WHERE Id =:leadId';
        currLead = Database.query(query); 
        diagnosisVerificationList = [SELECT id,ICD_Code__c,Lead__c,Primary_Diagnosis__c,PCD_ICD__c,Order__c,Short_Description__c,Condition_Description__r.Name,isEligible__c,(SELECT Medical_Question__c,Epilepsy_Value__c,Medical_Question_Answer__c,isEligible__c,Comment__c FROM DiagnosisMedicalQuestions__r) FROM Diagnosis_Verification__c WHERE Lead__c = :leadId order by Order__c ];
        System.debug('>>>>>>>>diagnosisVerificationList>>>>>>'+diagnosisVerificationList);
        if((!String.isEmpty(currLead.Current_Condition_Label__c)) && currLead.Current_Condition_Label__c.contains(';')) {
            Integer i = 0;
            currentCondition = '';
            for(String currentSplitString : currLead.Current_Condition_Label__c.split(';')) {
                if(!String.isEmpty(currentSplitString)) {
                    currentCondition += i+1 +'. '+ currentSplitString + '\n';
                    i++;
                }
            }
        }
        
        for(Medical_Questions__c medicalQuestions : [SELECT ID,Condition_Description__c,Condition_Description__r.Name,Current_Condition__c,Data_Type__c,Epilepsy_picklist__c,Picklist_values__c,Question__c,Recommendation_to_Chapter__c,Sort_Order__c,Wrapper_Variable__c FROM Medical_Questions__c order by Sort_Order__c]){
            if(medicalQuestions.Question__c != null) {
                medicalQuestions.Question__c = medicalQuestions.Question__c.replace('[child\'s name]', ' ' +currLead.FirstName+ ' ' +currLead.LastName).replace(' (child\'s name) ', currLead.FirstName+' '+currLead.LastName).replace('[Insert child\'s name]', currLead.FirstName+' '+currLead.LastName);
                medicalQuestionMap.put(medicalQuestions.Id, medicalQuestions.Question__c);
            }
        } 
        
        
    }
    //Self Fieldset, it holds the mandatory fields of Self relationship.
    public List<Schema.FieldSetMember> getPartAFields() {
        return SObjectType.Lead.FieldSets.Diagnosis_Verfication_Fieldset.getFields();
    }
    
   
}