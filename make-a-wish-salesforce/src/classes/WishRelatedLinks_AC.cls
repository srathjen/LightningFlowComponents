public class WishRelatedLinks_AC {

    public Case currentCaseRec{get;set;}
    public String WishFamilyForm{get;set;}
    public String WishReceipt{get;set;}
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
    Public string ddpId{get;set;}
    public string welcomeLetter{get;set;}
    public string welcomeletterDDP{get;set;}
    public string MergedDocuments{get;set;}
    
    public WishRelatedLinks_AC(ApexPages.StandardController controller) {
    
     Constant_AC  constant = new Constant_Ac();    
     String wishDeterminationRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishDeterminationRT).getRecordTypeId();
     String parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
     String wishGrantRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishGrantRT).getRecordTypeId();
     querychildCase = new List<Case>();
     currentCaseRec= (Case)controller.getRecord();
     //ddpId = 'a1k5B000000CgLU';
     ddpId = Label.Wish_Receipt_DDP;
     //welcomeletterDDP = 'a1a7A000000lCR6';
     welcomeletterDDP = Label.Welcome_Letter_DDP;

     List<ProcessInstance> approvalIns =  [SELECT TargetObjectId,Status,ProcessDefinitionId,ProcessDefinition.Name FROM ProcessInstance WHERE TargetObjectId =: currentCaseRec.Id AND Status =: 'Pending' AND ProcessDefinition.Name =: 'Wish Child Form Approval Process']; 
      
        system.debug('@@@@ currentCaseRec @@@@@@@'+currentCaseRec);
        if(currentCaseRec.RecordTypeId == parentWishRecordTypeId ){
       
        
        WishFamilyForm = '/apex/WishChildForm_VF?id='+currentCaseRec.Id;
        
        contactInfo = '/apex/RelationshipsViewer_VF?recId='+currentCaseRec.Id;
        LiabilityFrom = '/apex/WishLiabilityForm_VF?id='+currentCaseRec.Id;
        miniorParticipant = '/apex/WishLiabilityMinorParticipant_VF?id='+currentCaseRec.Id;
        absentParentForm = '/apex/dsfs__DocuSign_CreateEnvelope?DSEID=0&SourceID='+currentCaseRec.Id;
        celebrityForm ='/apex/dsfs__DocuSign_CreateEnvelope?DSEID=0&SourceID='+currentCaseRec.Id;
        singleForm ='/apex/dsfs__DocuSign_CreateEnvelope?DSEID=0&SourceID='+currentCaseRec.Id;
        wishClearence = '/apex/WishClearanceSendNow_VF?id='+currentCaseRec.Id; 
        ChildMedicalForm = '/apex/WishChildSummary_VF?id='+currentCaseRec.Id;
        ShoppingSpree =  '/apex/Itinerary_VF?id='+currentCaseRec.Id;
        MergedDocuments = '/apex/MergedDocuments_VF?id='+currentCaseRec.Id;
        welcomeLetter = '/apex/loop__looplus?eid='+currentCaseRec.Id+'&hidecontact='+true+'&hideddp='+true+'&sidebar='+false+'&ddpIds='+welcomeletterDDP;
        
        }
        
       querychildCase = [SELECT Id,CaseNumber,ParentId,Parent.AccountId,Parent.ContactId FROM Case WHERE ParentId =:currentCaseRec.Id AND RecordTypeId =: wishGrantRecordTypeId AND ParentId != Null limit 1];
        if(!querychildCase.isEmpty() && querychildCase[0].Id != Null){
        WishReceipt = '/apex/loop__looplus?eid='+querychildCase[0].ParentId+'&accountId='+querychildCase[0].Parent.AccountId+'&hidecontact='+true+'&hideddp='+true+'&sidebar='+false+'&ddpIds='+ddpId;
        }
      
  }     
  
    public pageReference DisplayError(){
      ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,' This record is already in approval process'));
      return null;
    }                                                    
}