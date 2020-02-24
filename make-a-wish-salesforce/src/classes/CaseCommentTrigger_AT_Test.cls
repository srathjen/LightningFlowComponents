@isTest
public class CaseCommentTrigger_AT_Test {
    
    public testmethod static void createCase(){
        test.startTest();
        String userId = UserInfo.getUserId();
        Id partARecordTypeId = Constant_AC.DIAGNOSIS_RT_ID;
        Case currnetCase = new Case();
        currnetCase.Status = 'Qualified';
        currnetCase.Origin = 'Email';
        currnetCase.MAC_Email__c = 'Test@gmail.com';
        currnetCase.RecordTypeId = partARecordTypeId;
        insert currnetCase;
        
        CaseComment newCaseComment =  new CaseComment();
        newCaseComment.ParentId = currnetCase.Id;
        newCaseComment.CommentBody = 'Test comment';
        insert newCaseComment;
         System.assertEquals(currnetCase.MAC_Email__c, 'Test@gmail.com', 'The email does not match');
        System.assert(currnetCase.MAC_Email__c ==  'Test@gmail.com', 'The email does not match');
        test.stopTest();
    }

    public testmethod static void createWishCase(){
        test.startTest();
        String userId = UserInfo.getUserId();
//        Id partARecordTypeId = Constant_AC.WISH_ASSIST_RT_ID;
        Id partARecordTypeId = Constant_AC.WISH_RT_ID;
        Case currnetCase = new Case();
        currnetCase.Status = 'Qualified';
        currnetCase.Origin = 'Email';
        currnetCase.MAC_Email__c = 'Test@gmail.com';
        currnetCase.RecordTypeId = partARecordTypeId;
        insert currnetCase;

        CaseComment newCaseComment =  new CaseComment();
        newCaseComment.ParentId = currnetCase.Id;
        newCaseComment.CommentBody = 'Test comment';
        insert newCaseComment;
        System.assertEquals(currnetCase.MAC_Email__c, 'Test@gmail.com', 'The email does not match');
        System.assert(currnetCase.MAC_Email__c ==  'Test@gmail.com', 'The email does not match');
        test.stopTest();
    }

    public testmethod static void updateCaseQualified(){
        test.startTest();
        Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
        insert chapterAccount;
        Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id);
        newLead.Status ='Open';
        insert newLead;

        String userId = UserInfo.getUserId();
        Id partARecordTypeId = Constant_AC.DIAGNOSIS_RT_ID;
        Case currnetCase = new Case();
        currnetCase.Status = 'Qualified';
        currnetCase.Origin = 'Email';
        currnetCase.MAC_Email__c = 'Test@gmail.com';
        currnetCase.RecordTypeId = partARecordTypeId;
        currnetCase.Status = 'Qualified';
        insert currnetCase;
        currnetCase.Lead__c = newLead.id;
//        currnetCase.Status = 'DNQ - National Medical Review';
        currnetCase.Status = 'Open';
        update currnetCase;

        System.assertEquals(currnetCase.MAC_Email__c, 'Test@gmail.com', 'The email does not match');
        System.assert(currnetCase.MAC_Email__c ==  'Test@gmail.com', 'The email does not match');
        test.stopTest();
    }


    public testmethod static void updateCaseDNQ(){
        test.startTest();
        Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
        insert chapterAccount;
        Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id);
        insert newLead;

        String userId = UserInfo.getUserId();
        Id partARecordTypeId = Constant_AC.DIAGNOSIS_RT_ID;
        Case currnetCase = new Case();
        currnetCase.Status = 'Qualified';
        currnetCase.Origin = 'Email';
        currnetCase.MAC_Email__c = 'Test@gmail.com';
        currnetCase.RecordTypeId = partARecordTypeId;
        insert currnetCase;
        currnetCase.Lead__c = newLead.id;
        currnetCase.Status = 'DNQ - National Medical Review';
//        currentCase.Status = 'Qualified';
        update currnetCase;

        System.assertEquals(currnetCase.MAC_Email__c, 'Test@gmail.com', 'The email does not match');
        System.assert(currnetCase.MAC_Email__c ==  'Test@gmail.com', 'The email does not match');
        test.stopTest();
    }

    public testmethod static void updateCase(){
        test.startTest();
        Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
        insert chapterAccount;
        Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id);
        newLead.Qualifying_Diagnosis__c = 'teste';
        newLead.Any_medical_reason_for_moving_quickly__c='Yes';
        newLead.Part_A_Received__c= System.today()-3;
        newLead.I_am_Recognized_To_Practice_As_a__c = 	'Physician';
        newLead.Please_Explain__c = 'test unit';
        newLead.Status = 'Qualified';
        insert newLead;

        String userId = UserInfo.getUserId();
        Id partARecordTypeId = Constant_AC.DIAGNOSIS_RT_ID;
        Case currnetCase = new Case();
        currnetCase.Status = 'Qualified';
        currnetCase.Origin = 'Email';
        currnetCase.MAC_Email__c = 'Test@gmail.com';
        currnetCase.RecordTypeId = partARecordTypeId;
        insert currnetCase;
        currnetCase.Lead__c = newLead.id;
        currnetCase.Status = 'Approved - National Medical Review';
//        currnetCase.RecordTypeId = Constant_AC.DIAGNOSIS_RT_ID;
//        currentCase.Status = 'Qualified';
        update currnetCase;

        System.assertEquals(currnetCase.MAC_Email__c, 'Test@gmail.com', 'The email does not match');
        System.assert(currnetCase.MAC_Email__c ==  'Test@gmail.com', 'The email does not match');
        test.stopTest();
    }
}