/***************************************************************************************************
Author      : MST Solutions
Description : This class is used add all links to navigate to the particuar forms
*****************************************************************************************************/
public class WishRelatedLinks_AC {
    public Case currentCaseRec{get;set;}
    public String WishFamilyForm{get;set;}
    public String LiabilityFrom{get;set;}
    public String contactInfo{get;set;}  
    public String miniorParticipant{get;set;} 
    public String absentParentForm{get;set;}
    public String celebrityForm{get;set;}
    public String singleForm{get;set;} 
    public String wishClearence{get;set;}
    public String ChildMedicalForm{get;set;}
    public String ShoppingSpree{get;set;}
    public List<case> querychildCase; 
    public List<Wish_Child_Form__c> childFormList;
    Public string ddpId{get;set;}
    public string dnqLetterDDP{get;set;}
    public string welcomeletterDDP{get;set;}
    public string bioSheetDDP{get;set;}
    public string sneakPeekDDP{get;set;}
    public string dnqLetterSpanishDDP{get;set;}
    public string welcomeLetterSpanishDDP{get;set;}
    public string wishReceiptSpanishDDP{get;set;}
    public String WishReceipt{get;set;}
    public string welcomeLetter{get;set;}
    public string dnqLetter{get;set;}
    public string bioSheet{get;set;}
    public string sneakPeek{get;set;}
    public string wishReceiptSpanish{get;set;}
    public string dnqLetterSpanish{get;set;}
    public string welcomeLetterSpanish{get;set;}
    public string MergedDocuments{get;set;}
    public String recpCheck {get;set;}
    Public boolean showPopup{get;set;}
    public WishRelatedLinks_AC(ApexPages.StandardController controller) {
        recpCheck = 'Allow';
        Constant_AC  constant = new Constant_Ac(); 
        
        String wishDeterminationRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishDeterminationRT).getRecordTypeId();
        String parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
        String wishGrantRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishGrantRT).getRecordTypeId();
        querychildCase = new List<Case>();
        currentCaseRec= (Case)controller.getRecord();
        ddpId = Label.Wish_Receipt_DDP;
        welcomeletterDDP = Label.Welcome_Letter_DDP;
        dnqLetterDDP = Label.DNQ_Letter_DDP;
        bioSheetDDP = Label.Bio_Sheet_DDP;
        sneakPeekDDP = Label.Sneak_Peek_DDP;
        dnqLetterSpanishDDP = Label.DNQ_Letter_Spanish_DDP;
        welcomeLetterSpanishDDP = Label.Welcome_Letter_Spanish_DDP;
        wishReceiptSpanishDDP = Label.Wish_Receipt_Spanish; 
        List<ProcessInstance> approvalIns =  [SELECT TargetObjectId,Status,ProcessDefinitionId,ProcessDefinition.Name FROM ProcessInstance WHERE TargetObjectId =: currentCaseRec.Id AND Status =: 'Pending' AND ProcessDefinition.Name =: 'Wish Child Form Approval Process']; 
         List<Wish_Child_Form__c> childFormList = [SELECT Id,Hidden_Wish_Fmaily_Contact_Name__c,Case__c,Participant_Name__c,Hidden_Same_as_Family__c,Hidden_Wish_Fmaily_Contact_Email__c,Participant_Details__c,Hidden_Email_List__c,
                     Hidden_Name_List__c FROM Wish_Child_Form__c WHERE Case__c =: currentCaseRec.Id];
        
         if(childFormList.size() > 0){
            if((childFormList[0].Hidden_Wish_Fmaily_Contact_Name__c != Null && (childFormList[0].Participant_Name__c != Null || childFormList[0].Hidden_Same_as_Family__c == true) && childFormList[0].Hidden_Wish_Fmaily_Contact_Email__c != Null)){
            
                
                   showPopup = true;
               
            
            
        }           
       }
       
        if(currentCaseRec.RecordTypeId == parentWishRecordTypeId ){
            WishFamilyForm = '/apex/WishChildForm_VF?id='+currentCaseRec.Id;
            contactInfo = '/apex/RelationshipsViewer_VF?recId='+currentCaseRec.Id;
            LiabilityFrom = '/apex/WishLiabilityForm_VF?id='+currentCaseRec.Id;
            miniorParticipant = '/apex/WishLiabilityMinorParticipant_VF?id='+currentCaseRec.Id;
            absentParentForm = '/apex/AbsentForm_VF?id='+currentCaseRec.Id; 
            celebrityForm ='/apex/dsfs__DocuSign_CreateEnvelope?DSEID=0&SourceID='+currentCaseRec.Id;
            singleForm ='/apex/dsfs__DocuSign_CreateEnvelope?DSEID=0&SourceID='+currentCaseRec.Id;
            wishClearence = '/apex/WishClearanceSendNow_VF?id='+currentCaseRec.Id; 
            ChildMedicalForm = '/apex/WishChildSummary_VF?id='+currentCaseRec.Id;
            ShoppingSpree =  '/apex/Itinerary_VF?id='+currentCaseRec.Id;
            MergedDocuments = '/apex/MergedDocuments_VF?id='+currentCaseRec.Id;
            welcomeLetter = '/apex/loop__looplus?eid='+currentCaseRec.Id+'&hidecontact='+true+'&hideddp='+true+'&sidebar='+false+'&ddpIds='+welcomeletterDDP;
            dnqLetter = '/apex/loop__looplus?eid='+currentCaseRec.Id+'&hidecontact='+true+'&hideddp='+true+'&sidebar='+false+'&ddpIds='+dnqLetterDDP;
            bioSheet = '/apex/loop__looplus?eid='+currentCaseRec.Id+'&hidecontact='+true+'&hideddp='+true+'&sidebar='+false+'&ddpIds='+bioSheetDDP;
            sneakPeek = '/apex/loop__looplus?eid='+currentCaseRec.Id+'&hidecontact='+true+'&hideddp='+true+'&sidebar='+false+'&ddpIds='+sneakPeekDDP;
            wishReceiptSpanish = '/apex/loop__looplus?eid='+currentCaseRec.Id+'&hidecontact='+true+'&hideddp='+true+'&sidebar='+false+'&ddpIds='+wishReceiptSpanishDDP;
            dnqLetterSpanish = '/apex/loop__looplus?eid='+currentCaseRec.Id+'&hidecontact='+true+'&hideddp='+true+'&sidebar='+false+'&ddpIds='+dnqLetterSpanishDDP;
            welcomeLetterSpanish = '/apex/loop__looplus?eid='+currentCaseRec.Id+'&hidecontact='+true+'&hideddp='+true+'&sidebar='+false+'&ddpIds='+welcomeLetterSpanishDDP;
                    }
        
        querychildCase = [SELECT Id,CaseNumber,ParentId,Parent.AccountId,Parent.ContactId FROM Case WHERE ParentId =:currentCaseRec.Id AND RecordTypeId =: wishGrantRecordTypeId AND ParentId != Null limit 1];
        if(!querychildCase.isEmpty() && querychildCase[0].Id != Null){
            WishReceipt = '/apex/loop__looplus?eid='+querychildCase[0].ParentId+'&accountId='+querychildCase[0].Parent.AccountId+'&hidecontact='+true+'&hideddp='+true+'&sidebar='+false+'&ddpIds='+ddpId;
        }
    }
    
    
    public pageReference LiabilityFrom(){
       
        PageReference reference=new PageReference('/apex/WishLiabilityForm_VF?id='+currentCaseRec.Id);
        reference.setRedirect(true);     
        return reference;
        
    }
    public pageReference DisplayError(){
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,' This record is already in approval process'));
        return null;
    }
    //This method is used to update the receipient name and email in whish child contact from the relationship record whenever clicks the link.   
    public void updateSenderInfo() {
        List<Case> caseInfo = [SELECT Id, ContactId FROM Case WHERE Id = : currentCaseRec.Id];
        List<Contact> contactList = [SELECT Id FROM Contact WHERE Id =: caseInfo[0].ContactId LIMIT 1];
        contactList[0].Recipient_Email__c = '';
        contactList[0].First_Recipient_Name__c = '';
        contactList[0].Second_Recipient_Email__c = '';
        contactList[0].Second_Recipient_Name__c = '';
        
        for(npe4__Relationship__c relationInfo : [SELECT Id, npe4__Contact__c, npe4__RelatedContact__c, npe4__RelatedContact__r.Name, npe4__RelatedContact__r.Email  FROM npe4__Relationship__c WHERE npe4__Contact__c =: contactList[0].Id AND Parent_Legal_Guardian__c = true AND npe4__RelatedContact__r.Email != Null]) {
            if(String.isBlank(contactList[0].Recipient_Email__c) && String.isBlank(contactList[0].First_Recipient_Name__c)) {
                contactList[0].Recipient_Email__c = relationInfo.npe4__RelatedContact__r.Email;
                contactList[0].First_Recipient_Name__c = relationInfo.npe4__RelatedContact__r.Name;
                
            } else if ((String.isBlank(contactList[0].Second_Recipient_Email__c) && String.isBlank(contactList[0].Second_Recipient_Name__c))&& ((contactList[0].First_Recipient_Name__c != relationInfo.npe4__RelatedContact__r.Name)||(contactList[0].Recipient_Email__c != relationInfo.npe4__RelatedContact__r.Email))) {
                contactList[0].Second_Recipient_Email__c = relationInfo.npe4__RelatedContact__r.Email;
                contactList[0].Second_Recipient_Name__c = relationInfo.npe4__RelatedContact__r.Name;
            }
        }
        if(contactList.size() > 0) {
            update contactList;
            if((!String.isBlank(contactList[0].Recipient_Email__c) && !String.isBlank(contactList[0].First_Recipient_Name__c)) || (!String.isBlank(contactList[0].Second_Recipient_Email__c) &&  !String.isBlank(contactList[0].Second_Recipient_Name__c))){
                recpCheck = 'Allow';
            }
            else{
                recpCheck = 'Not Allow';
            }
            
        }
    }
}