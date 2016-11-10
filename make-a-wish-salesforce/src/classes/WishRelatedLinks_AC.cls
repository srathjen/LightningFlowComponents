public class WishRelatedLinks_AC {

    public Case currentCaseRec{get;set;}
    public String WishFamilyForm{get;set;}
    public String WishReceipt{get;set;}
    public String LiabilityFrom{get;set;}
    public String contactInfo{get;set;}     
    public WishRelatedLinks_AC(ApexPages.StandardController controller) {
    
     Constant_AC  constant = new Constant_Ac();    
     String wishDeterminationRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishDeterminationRT).getRecordTypeId();
     String parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
     String wishGrantRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishGrantRT).getRecordTypeId();
     
   
        
        currentCaseRec= (Case)controller.getRecord();
      
      
        system.debug('@@@@ currentCaseRec @@@@@@@'+currentCaseRec);
        if(currentCaseRec.RecordTypeId == parentWishRecordTypeId ){
        WishFamilyForm = '/apex/WishChildForm_VF?id='+currentCaseRec.Id;
        contactInfo = '/apex/RelationshipsViewer_VF?recId='+currentCaseRec.Id;
        LiabilityFrom = '/apex/WishLiabilityForm_VF?id='+currentCaseRec.Id;
        }
        
        Case querychildCase = [SELECT Id,CaseNumber,ParentId FROM Case WHERE ParentId =:currentCaseRec.Id AND RecordTypeId =: wishGrantRecordTypeId AND ParentId != Null limit 1];
        if(querychildCase.Id != Null){
        WishReceipt = '/apex/DDP_VF_Copy?caseId='+querychildCase.Id;
        }
        
        
        
        
  }
}