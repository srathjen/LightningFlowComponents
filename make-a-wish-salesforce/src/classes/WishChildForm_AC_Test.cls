/*****************************************************************************
Author : MST Solutions
CreateDate : 14/11/2016
Description : WishChildForm_AC_Test is used to increase the code coverage for WishChildForm_AC.
******************************************************************************/


@isTest
    public class WishChildForm_AC_Test{
    
    /* This CalltheConstructor Method is used to cover the codecoverage for constructor.*/
     static testMethod void CalltheConstructorMethod(){ 
      Account chapterAcc = OrientationandTrainingUtil.createchapterAccount();
      Contact wishChild =  OrientationandTrainingUtil.CreateWishChild();
      case wish = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
      wish.Hidden_Email_List__c = 'Chandru,Kesav,Mariyappan';
      update wish;
      Wish_Child_Form__c wishChildFormIns = OrientationandTrainingUtil.createWishChildForm(wish.Id);
     Insert  wishChildFormIns;
        ApexPages.StandardController sc = new ApexPages.StandardController(wish);
        PageReference pageRef = Page.WishChildForm_VF;
        pageRef.getParameters().put('id', String.valueOf(wish.Id));
        Test.setCurrentPage(pageRef);
        
        WishChildForm_AC wishChildIns = new WishChildForm_AC(sc);
        WishChildFormUtil util = new WishChildFormUtil();
        wishChildIns.saveContact();
        
       // wishChildIns.removeFamily();
         wishChildIns.SaveandwishFamilyExit();
         wishChildIns.SaveandwishChildExit();
         wishChildIns.exitWithOutSave();
         wishChildIns.displayError();
         wishChildIns.WishInfoWithSave();
        wishChildIns.SavewithExit();
        wishChildIns.WishInfoSave();
        wishChildIns.WCFNext();
        wishChildIns.WFFNext();
        wishChildIns.BackToWCF();
        wishChildIns.addFamily();
        wishChildIns.addDriver();
        wishChildIns.addParticipants();
        wishChildIns.BackToWFF();
        wishChildIns.cancelfunction();
       // wishChildIns.downLoadAsPdf();
        util.getMonths();
        wishChildIns.CancelFunction();
        util.getYear();
        util.getWishChildFields();
        util.getRelationships();
        wishChildIns.generatePDF();
        util.getStates();
        wishChildIns.forceDownloadPDF();
        wishChildIns.submitforApproval();
        System.AssertEquals(wish.Id,wishChildFormIns.Case__c);
     }   
     
    /* This DocusignSignNow Method is used to cover the codecoverage SignNowmultiEmail() and SubmitAndSign().*/
     static testMethod void DocusignSignNow(){ 
     
          Account chapterAcc = OrientationandTrainingUtil.createchapterAccount();
          Contact wishChild =  OrientationandTrainingUtil.CreateWishChild();
          case wish = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
          wish.Hidden_Email_List__c = 'Chandru,Kesav,Mariyappan';
          update wish;
          Wish_Child_Form__c wishChildFormIns = OrientationandTrainingUtil.createWishChildForm(wish.Id);
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
          System.AssertEquals(wish.Id,wishChildFormIns.Case__c);
          
     }
      /* This DocusignSendEmail Method is used to cover the codecoverage sendpdftoEmail() and callouttoDocusing().*/
      static testMethod void DocusignSendEmail(){ 
     
          Account chapterAcc = OrientationandTrainingUtil.createchapterAccount();
          Contact wishChild =  OrientationandTrainingUtil.CreateWishChild();
          case wish = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
          wish.Hidden_Email_List__c = 'Chandru,Kesav,Mariyappan';
          update wish;
          Wish_Child_Form__c wishChildFormIns = OrientationandTrainingUtil.createWishChildForm(wish.Id);
          Insert  wishChildFormIns;
          OrientationandTrainingUtil.insertDocusignSetting();
          ApexPages.StandardController sc = new ApexPages.StandardController(wish);
          PageReference pageRef = Page.WishChildForm_VF;
          pageRef.getParameters().put('id', String.valueOf(wish.Id));
          Test.setCurrentPage(pageRef);
          WishChildForm_AC wishChildIns = new WishChildForm_AC(sc);
          WishChildFormUtil util = new WishChildFormUtil();
          util.emailList.add('Vennila Paramasivam');
          
          wishChildIns.multiEmail();
          wishChildIns.sendpdftoEmail();
          Map<String,String> sendEmailMap = new Map<String,String>();
          sendEmailMap.put('Vennila Paramasivam', 'vennila@mstsolutions.com');
          Test.StartTest();
          Test.setMock(HttpCalloutMock.class, new Mock_ResponseGenerator()); 
          WishChildForm_AC.callouttoDocusing(sendEmailMap,wish.Id,wishChild.Id);
          Test.StopTest();
          System.AssertEquals(wish.Id,wishChildFormIns.Case__c);
       }
       
        static testMethod void wishChildisEmpty(){
            
          Account chapterAcc = OrientationandTrainingUtil.createchapterAccount();
          Contact wishChild =  OrientationandTrainingUtil.CreateWishChild();
          case wish = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
          wish.Hidden_Email_List__c = 'Chandru,Kesav,Mariyappan';
          update wish;
          ApexPages.StandardController sc = new ApexPages.StandardController(wish);
          PageReference pageRef = Page.WishChildForm_VF;
          pageRef.getParameters().put('id', String.valueOf(wish.Id));
          Test.setCurrentPage(pageRef);
          WishChildForm_AC wishChildIns = new WishChildForm_AC(sc);
        }
     
   }