@IsTest
public class EmailTrigger_AT_Test {
    public testMethod static void createCase(){
        Test.startTest();
        Id diagnosisRecType = Constant_AC.DIAGNOSIS_RT_ID;
        Case currnetCase = new Case();
        currnetCase.Status = 'Qualified';
        currnetCase.Origin = 'Email';
        currnetCase.MAC_Email__c = 'Test@gmail.com';
        currnetCase.RecordTypeId = diagnosisRecType;
        insert currnetCase;
        EmailMessage currnetEmail = new EmailMessage();
        currnetEmail.TextBody = 'Hi Welcome';
        currnetEmail.ParentId = currnetCase.Id;
        currnetEmail.FromAddress = 'Test@gmail.com';
        insert currnetEmail;
        Test.stopTest();
    }
}