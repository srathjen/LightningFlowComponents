public class customLookUpController {
    
    /*
     * update: Mitali Nahar Traction on Demand 2019-06-18 Modified the method to fetch Lookup values for more objects
     */
    @AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName, List<String> additionalAttributes , Id caseId, String formType) {
        
        String searchKey = searchKeyWord + '%';
		List < sObject > returnList = new List < sObject > ();        
        String attributesList = string.join(additionalAttributes,',');
        String sQuery = '';

        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5 
        if(ObjectName == 'Wish_Signature_Forms__c'){
            Case objCase = [Select ChapterName__c FROM Case WHERE Id = : caseId];
            Set<Id> wishSignFormId = new Set<Id>();

            for(Wish_Signature_Chapter_Form__c obj : [SELECT Chapter_Account__c, Wish_Signature_Form__c FROM Wish_Signature_Chapter_Form__c  WHERE Chapter_Account__c =: objCase.ChapterName__c   ] ){
                wishSignFormId.add(obj.Wish_Signature_Form__c);
            }   
            sQuery =  'select id '  + ', Name from ' +ObjectName + ' where Name LIKE: searchKey AND Id In : wishSignFormId AND Active__c = True';
            if(formType.equals('Medical')){
                sQuery += ' AND Form_Type__c =' + '\'Medical\'';
            }else{
                sQuery += ' AND Form_Type__c != '+  '\'Medical\'';
            }
            sQuery += ' order by createdDate DESC';
        }
        else if(ObjectName == 'Contact' && caseId != null){
            if(formType.equals('Medical')){
                sQuery = 'Select Id, Name, Email, (Select Id, Name FROM Wish_Affiliations__r WHERE Wish__c =:caseId AND Wish_Affiliation_Type__c = \'Medical Professional\') From Contact Where Name LIKE: searchKey AND Id In (Select Contact__c FROM Wish_Affiliation__c WHERE Wish__c =:caseId AND Wish_Affiliation_Type__c = \'Medical Professional\')';
            }
            else{
                sQuery = 'Select Id, Name,  Email, (SELECT Id, Name FROM Wish_Affiliations__r WHERE Wish__c =:caseId  AND (Under_18__c = \'No\' OR Under_18__c =  \'No Birthdate Recorded\') AND Wish_Affiliation_Type__c != \'Medical Professional\' ) From Contact Where Name LIKE: searchKey AND Id In (Select Contact__c From Wish_Affiliation__c WHERE Wish__c =:caseId  AND (Under_18__c = \'No\' OR Under_18__c =  \'No Birthdate Recorded\') AND Wish_Affiliation_Type__c != \'Medical Professional\' )'; 
            }
        }
        else if(ObjectName == 'Condition_Description__c') {
            sQuery =  'SELECT Id, ' + attributesList + ', Name FROM ' + ObjectName + ' WHERE Inactive__c = false AND Name LIKE :searchKey ORDER BY CreatedDate DESC'; 
        }
        else if(ObjectName == 'ICD_Codes__c') {
            sQuery =  'SELECT Id, ' + attributesList + ', Name FROM ' + ObjectName + ' WHERE Condition_Description__r.Inactive__c = false AND Name LIKE :searchKey ORDER BY CreatedDate DESC'; 
        }
        else{
            sQuery =  'select id, ' + attributesList + ', Name from ' +ObjectName + ' where Name LIKE: searchKey order by createdDate DESC'; 
        }
        
        List < sObject > lstOfRecords = Database.query(sQuery);
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }
}