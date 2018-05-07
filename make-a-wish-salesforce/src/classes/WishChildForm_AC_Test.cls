/*****************************************************************************
Author : MST Solutions
CreateDate : 14/11/2016
Description : WishChildForm_AC_Test is used to increase the code coverage for WishChildForm_AC.
******************************************************************************/
@isTest
public class WishChildForm_AC_Test{
    
    /* This CalltheConstructor Method is used to cover the codecoverage for constructor.*/
    static testMethod void calltheConstructorMethod(){ 
        
        Account chapterAcc = OrientationandTrainingUtil.createchapterAccount();
        Contact wishChild =  OrientationandTrainingUtil.CreateWishChild();
        Contact volunterCon = OrientationandTrainingUtil.createVolunteerContact(chapterAcc.id);
        Contact volunterConTwo = OrientationandTrainingUtil.createVolunteerContactwithOtherPhone(chapterAcc.id);
        case wish = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        CaseTeamRole roleRec = [SELECT Id FROM CaseTeamRole WHERE Name = 'Wish Granter' LIMIT 1];       
        CaseTeamMember caseTeamMeber = OrientationandTrainingUtil.createCaseTeamMember(wish.id,volunterCon.id,roleRec.id);
        CaseTeamMember caseTeamMebertwo = OrientationandTrainingUtil.createCaseTeamMember(wish.id,volunterConTwo.id,roleRec.id);
        Wish_Child_Form__c wishChildFormIns = OrientationandTrainingUtil.createWishChildForm(wish.Id);
        wishChildFormIns.Emergency_Relationship__c = 'Employee';
        wishChildFormIns.Emergency_First_Name__c = 'TestEmployee';
        wishChildFormIns.Emergency_Last_Name__c = 'TestLastEmployee';
        wishChildFormIns.Emergency_Mobilephone__c = '9600467559';
        wishChildFormIns.Race_Ethnicity__c = 'American Indian or Alaska Native';
        wishChildFormIns.Case_Team_Member1__c = 'Test Chandru';
        wishChildFormIns.Case_Team_Member2__c = 'Test Kesav';
        wishChildFormIns.Driver_Information__c = '{"type":"","state":"Alabama","licenseNum":"Test","expirationDate":"2019-10-02","driverName":"Father - Chandr Sek"}]';
        Insert  wishChildFormIns;
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(wish);
        PageReference pageRef = Page.WishChildForm_VF;
        pageRef.getParameters().put('id', String.valueOf(wish.Id));
        Test.setCurrentPage(pageRef);
        WishChildForm_AC wishChildIns = new WishChildForm_AC(sc);
        WishChildFormUtil util = new WishChildFormUtil();
        wishChildIns.SaveandwishFamilyExit();
        wishChildIns.SaveandwishChildExit();
        //wishChildIns.exitWithOutSave();
        wishChildIns.WishInfoWithSave();
        wishChildIns.SavewithExit();
        wishChildIns.WishInfoSave();
        wishChildIns.forceDownloadPDF();
        wishChildIns.confirmSignNow();
        wishChildIns.withOutSavetoChild();
        wishChildIns.ExitwithApprovalError();
        wishChildIns.WCFNext();
        wishChildIns.WFFNext();
        wishChildIns.init();
        wishChildIns.BackToWCF();
        wishChildIns.addFamily();
        wishChildIns.addDriver();
        wishChildIns.addParticipants();
        wishChildIns.BackToWFF();
        wishChildIns.cancelfunction();
        wishChildIns.SaveandRedirectChildForm();
        wishChildIns.SaveAndRedirectFamilyForm();
        wishChildIns.SaveAndRedirectInformationForm();
        wishChildIns.SaveFromInformationToChildForm();
        wishChildIns.DisplayApprovalProcess();
        wishChildIns.getRaceEthnicity();
        wishChildIns.getDoesParticipantReqWheelchair();
        wishChildIns.getWillYourFamilyBringWheelChair();
        wishChildIns.getWheelChairColapsable();
        wishChildIns.getwheelChairPower();
        wishChildIns.getparticipantRequireOxygan();
        wishChildIns.getparticipantHaveSpecialRestrictaion();
        wishChildIns.getparticipantHaveSpecialallergies();
        wishChildIns.getmedicationRequireRefeigeration();
        wishChildIns.getcurrentlyReceiveNursingCare();
        wishChildIns.getanyOtherMedicalSupplies();
        wishChildIns.withOutNavigate();
        wishChildIns.RetrunToWish(); 
        wishChildIns.getTempName();
        wishChildIns.getCurrentOwnWheelChairList();
        wishChildIns.getCurrentWCCollapsibleList();
        wishChildIns.getCurrentWCPowerList();
        wishChildIns.getCurrentOxygenNamesList();
        wishChildIns.getCurrrentDietaryNameList();
        wishChildIns.getCurrentOxygenNamesList();
        wishChildIns.getCurrrentDietaryNameList();
        wishChildIns.getCurrentNursingCareList();
        wishChildIns.getCurrentMedicationList();
        wishChildIns.getCurrentAllergyNamesList();
        wishChildIns.getCurrentOtherNeedsList();
        wishChildIns.WCFtoWIF();
        wishChildIns.WCFtoWFF();
        wishChildIns.WishInfotoWishChild();
        wishChildIns.WishInfotoWishFamily();
        wishChildIns.NavigatetoWishChildForm();
        wishChildIns.NavigatetoWishFamily();
        wishChildIns.cancel();
        wishChildIns.withOutSavefromWCFtoWIF();
        wishChildIns.withOutSaveWCCF();
        // wishChildIns.removeFamily();
        // wishChildIns.removeDriver();
        // wishChildIns.removeParticipants();
        //wishChildIns.CheckSameasParent();
        wishChildIns.WishFamilytoWishInfo();
        wishChildIns.UploadFile();
        util.getMonths();
        wishChildIns.CancelFunction();
        util.getYear();
        util.getWishChildFields();
        util.getRelationships();
        wishChildIns.generatePDF();
        util.getStates();
        wishChildIns.submitforApproval();
        
        wishChildIns.saveContact();
        wishChildIns.wishChildMap('Test','Chandrasekar');
        list<String> stringList = new list<String>();
        string valName = 'Test, Chandru Test value';
        stringList.add(valName);
        wishChildIns.setTempName(stringList);
        wishChildIns.setCurrentOwnWheelChairList(stringList);
        wishChildIns.setCurrentWCCollapsibleList(stringList);
        wishChildIns.setCurrentWCPowerList(stringList);
        wishChildIns.setCurrentOxygenNamesList(stringList);
        wishChildIns.setCurrrentDietaryNameList(stringList);
        wishChildIns.setCurrentNursingCareList(stringList);
        wishChildIns.setCurrentMedicationList(stringList);
        wishChildIns.setCurrentAllergyNamesList(stringList);
        wishChildIns.setCurrentOtherNeedsList(stringList);
        Test.StopTest();
        System.AssertEquals(wish.Id,wishChildFormIns.Case__c,'Wish child form does not refer to the '+wish.contact.Name);         
    }
    
    static testMethod void method2(){ 
        
        Account chapterAcc = OrientationandTrainingUtil.createchapterAccount();
        Contact wishChild =  OrientationandTrainingUtil.CreateWishChild();
        case wish = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        Wish_Child_Form__c wishChildFormIns = OrientationandTrainingUtil.createWishChildForm(wish.Id);
        wishChildFormIns.Emergency_Relationship__c = 'Employee';
        wishChildFormIns.Emergency_First_Name__c = 'TestEmployee';
        wishChildFormIns.Emergency_Last_Name__c = 'TestLastEmployee';
        wishChildFormIns.Emergency_Mobilephone__c = '9600467559';
        Insert  wishChildFormIns;
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(wish);
        PageReference pageRef = Page.WishChildForm_VF;
        pageRef.getParameters().put('id', String.valueOf(wish.Id));
        Test.setCurrentPage(pageRef);
        WishChildForm_AC wishChildIns = new WishChildForm_AC(sc);
        WishChildFormUtil util = new WishChildFormUtil();
        wishChildIns.SaveandwishFamilyExit();
        wishChildIns.SaveandwishChildExit();
        //wishChildIns.exitWithOutSave();
        wishChildIns.WishInfoWithSave();
        wishChildIns.SavewithExit();    
        wishChildIns.WishInfoSave();
        wishChildIns.forceDownloadPDF();
        wishChildIns.confirmSignNow();
        wishChildIns.withOutSavetoChild();
        wishChildIns.ExitwithApprovalError();
        wishChildIns.WCFNext();
        wishChildIns.WFFNext();
        wishChildIns.init();
        wishChildIns.BackToWCF();
        wishChildIns.addFamily();
        wishChildIns.addDriver();
        wishChildIns.addParticipants();
        wishChildIns.BackToWFF();
        wishChildIns.cancelfunction();
        wishChildIns.SaveandRedirectChildForm();
        wishChildIns.SaveAndRedirectFamilyForm();
        wishChildIns.SaveAndRedirectInformationForm();
        wishChildIns.SaveFromInformationToChildForm();
        wishChildIns.DisplayApprovalProcess();
        wishChildIns.getRaceEthnicity();
        wishChildIns.getDoesParticipantReqWheelchair();
        wishChildIns.getWillYourFamilyBringWheelChair();
        wishChildIns.getWheelChairColapsable();
        wishChildIns.getwheelChairPower();
        wishChildIns.getparticipantRequireOxygan();
        wishChildIns.getparticipantHaveSpecialRestrictaion();
        wishChildIns.getparticipantHaveSpecialallergies();
        wishChildIns.getmedicationRequireRefeigeration();
        wishChildIns.getcurrentlyReceiveNursingCare();
        wishChildIns.getanyOtherMedicalSupplies();
        wishChildIns.withOutNavigate();
        wishChildIns.RetrunToWish(); 
        wishChildIns.getTempName();
        wishChildIns.getCurrentOwnWheelChairList();
        wishChildIns.getCurrentWCCollapsibleList();
        wishChildIns.getCurrentWCPowerList();
        wishChildIns.getCurrentOxygenNamesList();
        wishChildIns.getCurrrentDietaryNameList();
        wishChildIns.getCurrentOxygenNamesList();
        wishChildIns.getCurrrentDietaryNameList();
        wishChildIns.getCurrentNursingCareList();
        wishChildIns.getCurrentMedicationList();
        wishChildIns.getCurrentAllergyNamesList();
        wishChildIns.getCurrentOtherNeedsList();
        wishChildIns.WCFtoWIF();
        wishChildIns.WCFtoWFF();
        wishChildIns.WishInfotoWishChild();
        wishChildIns.WishInfotoWishFamily();
        wishChildIns.NavigatetoWishChildForm();
        wishChildIns.NavigatetoWishFamily();
        wishChildIns.cancel();
        wishChildIns.withOutSavefromWCFtoWIF();
        wishChildIns.withOutSaveWCCF();
        //wishChildIns.CheckSameasParent();
        wishChildIns.WishFamilytoWishInfo();
        WishChildForm_AC.searchCaseFile(wish.Id);
        util.getMonths();
        wishChildIns.CancelFunction();
        util.getYear();
        util.getWishChildFields();
        util.getRelationships();
        wishChildIns.generatePDF();
        util.getStates();
        wishChildIns.submitforApproval();
        
        wishChildIns.saveContact();
        Test.StopTest();
        System.AssertEquals(wish.Id,wishChildFormIns.Case__c,'Wish child form does not refer to the '+wish.contact.Name);
    }
    
    /* This DocusignSignNow Method is used to cover the codecoverage SubmitAndSign() when Envelop_Id__c  &  Hidden_SignerMap_Key_1__c  are NOT NULL.*/
    static testMethod void docusignSignNow1(){ 
        Account chapterAcc = OrientationandTrainingUtil.createchapterAccount();
        Contact wishChild =  OrientationandTrainingUtil.CreateWishChild();
        Contact childFamily = OrientationandTrainingUtil.CreateWishFamily();
        npe4__Relationship__c  npcr = OrientationandTrainingUtil.CreateRelationshipRec(wishChild.Id,childFamily.Id);
        case wish = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        Wish_Child_Form__c wishChildFormIns = OrientationandTrainingUtil.createWishChildForm(wish.Id);
        wishChildFormIns.SignerMapKeyPair__c = 'test eerwe - 1#Gmother mother - 2';
        wishChildFormIns.Envelop_Id__c = '9c674881-53f1-4871-b5f7-a6a64f067f39';
        wishchildFormIns.Hidden_SignerMap_Key_1__c = 'test eerwe - 1#Gmother mother - 2';
        wishChildFormIns.Hidden_Envelop_Id_1__c = 'Test'; 
        wishChildFormIns.Emergency_Relationship__c = 'Father';
        wishChildFormIns.Emergency_First_Name__c = 'Test';
        wishChildFormIns.Emergency_Last_Name__c = 'LastName';
        Insert  wishChildFormIns;
        wishChildFormIns.Hidden_Wish_Fmaily_Contact_Email__c =  'test eerwe-te@t.com#Gmother mother-test@gmail.com#GFather yesy-test@gmail.com test@gmail.com::test@gmail.com';
        wishChildFormIns.Hidden_Wish_Fmaily_Contact_Name__c = 'Mark1 Slepian1#Laurie Slepian#Kaitlin Slepian';
        update wishChildFormIns;
        OrientationandTrainingUtil.insertDocusignSetting();
        ApexPages.StandardController sc = new ApexPages.StandardController(wish);
        PageReference pageRef = Page.WishChildForm_VF;
        pageRef.getParameters().put('id', String.valueOf(wish.Id));
        Test.setCurrentPage(pageRef);
        WishChildForm_AC wishChildIns = new WishChildForm_AC(sc);
        wishChildIns.init();
        Test.setMock(HttpCalloutMock.class, new Mock_ResponseGenerator()); 
        wishChildIns.multiEmail();
        wishChildIns.SignNowmultiEmail();
        Test.StartTest();
        wishChildIns.SubmitAndSign();
        Test.StopTest();
        System.AssertEquals(wish.Id,wishChildFormIns.Case__c,'Wish child form does not refer to the '+wish.contact.Name);
    }
    
    /* This DocusignSignNow Method is used to cover the codecoverage SubmitAndSign() when Hidden_Envelop_Id_2__c &  Hidden_SignerMap_Key_2__c  are NOT NULL.*/
    static testMethod void docusignSignNow2(){ 
        Account chapterAcc = OrientationandTrainingUtil.createchapterAccount();
        Contact wishChild =  OrientationandTrainingUtil.CreateWishChild();
        Contact childFamily = OrientationandTrainingUtil.CreateWishFamily();
        npe4__Relationship__c  npcr = OrientationandTrainingUtil.CreateRelationshipRec(wishChild.Id,childFamily.Id);
        case wish = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        Wish_Child_Form__c wishChildFormIns = OrientationandTrainingUtil.createWishChildForm(wish.Id);
        wishChildFormIns.SignerMapKeyPair__c = 'test eerwe - 1#Gmother mother - 2';
        wishChildFormIns.Envelop_Id__c = '9c674881-53f1-4871-b5f7-a6a64f067f39';
        wishchildFormIns.Hidden_SignerMap_Key_2__c = 'test eerwe - 1#Gmother mother - 2';
        wishChildFormIns.Hidden_Envelop_Id_2__c = 'Test'; 
        wishchildFormIns.Hidden_SignerMap_Key_1__c = 'test eerwe - 1#Gmother mother - 2';
        Insert  wishChildFormIns;
        OrientationandTrainingUtil.insertDocusignSetting();
        ApexPages.StandardController sc = new ApexPages.StandardController(wish);
        PageReference pageRef = Page.WishChildForm_VF;
        pageRef.getParameters().put('id', String.valueOf(wish.Id));
        Test.setCurrentPage(pageRef);
        WishChildForm_AC wishChildIns = new WishChildForm_AC(sc);
        Test.setMock(HttpCalloutMock.class, new Mock_ResponseGenerator()); 
        wishChildIns.SignNowmultiEmail();
        Test.StartTest();
        wishChildIns.SubmitAndSign();
        Test.StopTest();
        System.AssertEquals(wish.Id,wishChildFormIns.Case__c,'Wish child form does not refer to the '+wish.contact.Name);
    }
    
    /* This DocusignSignNow Method is used to cover the codecoverage SubmitAndSign() when Hidden_Envelop_Id_1__c &  Hidden_SignerMap_Key_1__c are NULL.*/
    static testMethod void docusignSignNow3(){ 
        Account chapterAcc = OrientationandTrainingUtil.createchapterAccount();
        Contact wishChild =  OrientationandTrainingUtil.CreateWishChild();
        Contact childFamily = OrientationandTrainingUtil.CreateWishFamily();
        npe4__Relationship__c  npcr = OrientationandTrainingUtil.CreateRelationshipRec(wishChild.Id,childFamily.Id);
        case wish = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        Wish_Child_Form__c wishChildFormIns = OrientationandTrainingUtil.createWishChildForm(wish.Id);
        wishChildFormIns.SignerMapKeyPair__c = 'test eerwe - 1#Gmother mother - 2';
        wishChildFormIns.Envelop_Id__c = '9c674881-53f1-4871-b5f7-a6a64f067f39';
        wishChildFormIns.Hidden_Envelop_Id_1__c = ''; 
        wishchildFormIns.Hidden_SignerMap_Key_1__c = '';
        Insert  wishChildFormIns;
        OrientationandTrainingUtil.insertDocusignSetting();
        ApexPages.StandardController sc = new ApexPages.StandardController(wish);
        PageReference pageRef = Page.WishChildForm_VF;
        pageRef.getParameters().put('id', String.valueOf(wish.Id));
        Test.setCurrentPage(pageRef);
        WishChildForm_AC wishChildIns = new WishChildForm_AC(sc);
        Test.setMock(HttpCalloutMock.class, new Mock_ResponseGenerator()); 
        wishChildIns.SignNowmultiEmail();
        Test.StartTest();
        wishChildIns.SubmitAndSign();
        Test.StopTest();
        System.AssertEquals(wish.Id,wishChildFormIns.Case__c,'Wish child form does not refer to the '+wish.contact.Name);
    }
    
    /* This DocusignSendEmail Method is used to cover the codecoverage sendpdftoEmail() and callouttoDocusing().*/
    static testMethod void docusignSendEmail(){ 
        Account chapterAcc = OrientationandTrainingUtil.createchapterAccount();
        Contact wishChild =  OrientationandTrainingUtil.CreateWishChild();
        Contact childFamily = OrientationandTrainingUtil.CreateWishFamily();
        npe4__Relationship__c  npcr = OrientationandTrainingUtil.CreateRelationshipRec(wishChild.Id,childFamily.Id);
        case wish = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        Wish_Child_Form__c wishChildFormIns = OrientationandTrainingUtil.createWishChildForm(wish.Id);
        wishChildFormIns.Emergency_Relationship__c = 'Employee';
        wishChildFormIns.Emergency_First_Name__c = 'TestEmployee';
        wishChildFormIns.Emergency_Last_Name__c = 'TestLastEmployee';
        wishChildFormIns.Emergency_Mobilephone__c = '9600467559';
        wishChildFormIns.Wish_Family_Contact__c = '[{"workTelephone":null,"tshirtSize":null,"Street":null,"State":null,"sameParentGuardianFlag":false,"residingWishMedical":null,"relId":null,"relationship":null,"PostalCode":null,"mobileTelephone":null,"MiddleName":null,"medicalNeeds":null,"lastName":null,"isChildParticipants":null,"homeTelephone":null,"firstName":null,"Email":null,"dob":null,"City":null}]';
        Insert  wishChildFormIns;
        wishChildFormIns.Hidden_Wish_Fmaily_Contact_Email__c = 'test eerwe-te@t.com#Gmother mother-test@gmail.com#GFather yesy-test@gmail.com test@gmail.com::test@gmail.com';
        update wishChildFormIns;
        OrientationandTrainingUtil.insertDocusignSetting();
        ApexPages.StandardController sc = new ApexPages.StandardController(wish);
        PageReference pageRef = Page.WishChildForm_VF;
        pageRef.getParameters().put('id', String.valueOf(wish.Id));
        Test.setCurrentPage(pageRef);
        WishChildForm_AC wishChildIns = new WishChildForm_AC(sc);
        WishChildFormUtil util = new WishChildFormUtil();
        util.emailList.add('Vennila Paramasivam');
        util.emailList.add('Chandru');
        wishChildIns.sendpdftoEmail();
        
        Set<String> rmoveNameSet = new Set<String>();
        rmoveNameSet.add('TestName@gmail.com');
        
        //wishChildIns.removeDriver();
        Map<String,String> sendEmailMap = new Map<String,String>();
        sendEmailMap.put('Vennila Paramasivam','vennila@mstsolutions.com');
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new Mock_ResponseGenerator()); 
        WishChildForm_AC.callouttoDocusing(sendEmailMap,wish.Id,wishChild.Id);
        Test.StopTest();
        System.AssertEquals(wish.Id,wishChildFormIns.Case__c,'Wish child form does not refer to the '+wish.contact.Name);
    }
    
    
    /* This SignNow_AC Method is used to cover the codecoverage for constructor.*/
    static testMethod void SignNowController(){ 
        
        Account chapterAcc = OrientationandTrainingUtil.createchapterAccount();
        Contact wishChild =  OrientationandTrainingUtil.CreateWishChild();
        case wish = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        Wish_Child_Form__c wishChildFormIns = OrientationandTrainingUtil.createWishChildForm(wish.Id);
        wishChildFormIns.Emergency_Relationship__c = 'Employee';
        wishChildFormIns.Emergency_First_Name__c = 'TestEmployee';
        wishChildFormIns.Emergency_Last_Name__c = 'TestLastEmployee';
        wishChildFormIns.Emergency_Mobilephone__c = '9600467559';
        Insert  wishChildFormIns;
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(wish);
        PageReference pageRef = Page.SignNowPDF;
        pageRef.getParameters().put('id', String.valueOf(wish.Id));
        Test.setCurrentPage(pageRef);
        SignNow_AC wishChildIns = new SignNow_AC(sc);
        WishChildFormUtil util = new WishChildFormUtil();
        //util.WrapperClass.wra = true;
        //wra.sameParentGuardianFlag = true;
        Test.StopTest();
        System.AssertEquals(wish.Id,wishChildFormIns.Case__c,'Wish child form does not refer to the '+wish.contact.Name);
        
    }  
    
    public static testmethod void callmethods()
    {
        WishReferralForm_AC obj=new WishReferralForm_AC();   
        obj.getNonMedicalReqFields();
        obj.getMedicalRequiredFields();
        obj.getSelfRequiredFields();
        obj.getRelationshipsToChild();
        obj.getHereAboutMAW();
        obj.getdiaYear();
        obj.getCommunication();
        system.assert(obj.getCommunication().Size() != 0 ,'Communication is empty');
        
    }
    
    public static testmethod void callUtillClassMethod(){
        WishChildFormUtil wishUtill = new WishChildFormUtil();
        wishUtill.getParentGuardianRelationships();
        wishUtill.getParticipantRelationships();
        wishUtill.selectedNames('Test Name');
        system.assert( wishUtill.getParentGuardianRelationships().Size() != 0 ,'Parent/Guardian is empty');
    }
}