public class ContactInfo_AC {
    public Contact con{get;set;}
    public Task tskIns;

    public ContactInfo_AC(ApexPages.StandardController controller){
    
        tskIns = (Task)controller.getRecord();
        Id updateContactRT = Constant_AC.UPDATE_CONTACT_RT_ID;
        Task tsk = [SELECT Id,WhoId,RecordTypeId FROM Task WHERE RecordTypeId =: updateContactRT AND Id =: tskIns.Id];
        con = [SELECT Id,Old_Update_Contact_Values__c  FROM Contact WHERE Id =: tsk.WhoId ];
    }
}