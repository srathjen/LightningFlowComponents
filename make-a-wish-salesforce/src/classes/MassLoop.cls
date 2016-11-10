public class MassLoop{


    public list<case> newCase{get;set;}
    string caseId{get;set;}
    string variables;
    public MassLoop(ApexPages.StandardController controller) {
        this.caseId=   ApexPages.currentPage().getParameters().get('caseId');
             string wishChildRTId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Wish Child').getRecordTypeId();

             newCase = new list<case>();
             newCase = [SELECT ID,AccountId,ContactId,Contact.First_Recipient_Name__c,Contact.Recipient_Email__c,Contact.Second_Recipient_Name__c,
             Contact.Second_Recipient_Email__c FROM Case WHERE ID =:caseId];

    }

    public PageReference massMerge(){
    System.debug('Inside massmerg function');
    PageReference pageRef = new PageReference('/apex/loop__looplus');    
    pageRef.getParameters().put('accountId', newCase[0].AccountId);
    pageRef.getParameters().put('eid',newCase[0].Id);
    pageRef.getParameters().put('hidecontact','True');
    system.debug('Inside pagref');
    pageRef.getParameters().put('hideddp','True');
    pageRef.getParameters().put('sidebar','False');
     pageRef.getParameters().put('autorun','true');
     //pageRef.getParameters().put('sessionId','GETSESSIONID()');
     pageRef.setRedirect(true);
    system.debug('################URL'+ ApexPages.currentPage().getURL());
     System.debug('End of massmerg function');
    return pageRef ;
      
    }
    }