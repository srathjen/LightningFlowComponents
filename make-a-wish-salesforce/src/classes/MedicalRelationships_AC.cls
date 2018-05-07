/*****************************************************************************************************************
Author      : MST Solutions
Date        : 02/15/2018
Description : This form is display the medical professional details in the case page layout.
*******************************************************************************************************************/
Public class MedicalRelationships_AC
{
    Constant_AC  constant = new Constant_AC();
    Id MedicalProfContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.MedicalProfessionalRT).getRecordTypeId();
    Case currCase = new Case();
    public Id caseId{get;set;}
     public MedicalRelationships_AC(Apexpages.standardController controller){         
         currCase = (Case)controller.getRecord();
         currCase = [SELECT id,ContactId FROM Case WHERE Id = :currCase.id limit 1];
         caseId = currCase.Id;
    }
    /***************************************************************
    Get the medical profession contact from the wish child contact.
    ****************************************************************/
    public list<npe4__Relationship__c> getmedicalRelationshipsConList()
    {
        string Logvalue;
        try
        {
            List<npe4__Relationship__c> relationshipList = new List<npe4__Relationship__c>();
            String queryString;     
            queryString = 'SELECT ';
            for(Schema.FieldSetMember medRelationshipField :SObjectType.npe4__Relationship__c.fieldsets.MedicalRelationships.getFields()) {
                queryString += medRelationshipField.getFieldPath()+',';
            }
            queryString = queryString.removeEnd(',');
            Set<Id> caseIdSet = new Set<Id>();
            caseIdSet.add(currCase.ContactId);
            queryString += ' FROM npe4__Relationship__c WHERE npe4__Contact__c =\''+currCase.ContactId+'\'  AND npe4__RelatedContact__r.RecordTypeId =\'' + MedicalProfContactRecordTypeId+ '\'';
            system.debug('queryString Value:'+queryString);
             Logvalue = queryString;
             for(npe4__Relationship__c  currRec: Database.query(queryString) ){
                //rel= new relationshipWrapper(currRec);
                relationshipList.add(currRec);
            }
            return relationshipList; 
        } catch(Exception ex)
        {
            new ApexDebugLog().createLog(new ApexDebugLog.Error('MedicalRelationships_AC','getmedicalRelationshipsConList',Null,ex,Logvalue));
            //ex.setMessage(Label.Debug_log_error_message); 
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
            ApexPages.addMessage(myMsg);
            Return Null;
        }
    }
}