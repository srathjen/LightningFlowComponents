//This method is used to verify the fucntionality like unit testing
//This method will create the Affiliation record. 
@isTest
public class AffiliationTrigger_Test {
	static testmethod void affiliationCreation() {
        Id chapterRecordTypeId = Constant_AC.CHAPTER_RT_ID;

        Account newAccount = new Account();
        newAccount.Name = 'Alabama - Chapter';
        newAccount.RecordTypeId = chapterRecordTypeId;
        insert newAccount;
        
        npe5__Affiliation__c newAffiliation = new npe5__Affiliation__c();
        newAffiliation.npe5__Organization__c = newAccount.Id;
    }
}