@isTest
public class EmailTrigger_AT_Test {
    public testmethod static void createCase(){
         test.startTest();
        Case currnetCase = new Case();
        currnetCase.Status = 'Qualified';
        currnetCase.Origin = 'Email';
        currnetCase.MAC_Email__c = 'Test@gmail.com';
        insert currnetCase;
        EmailMessage currnetEmail = new EmailMessage();
        currnetEmail.TextBody = 'Hi Welcome';
        currnetEmail.ParentId = currnetCase.Id;
        currnetEmail.FromAddress = 'Test@gmail.com';
        insert currnetEmail;
        test.stopTest();
    }

}