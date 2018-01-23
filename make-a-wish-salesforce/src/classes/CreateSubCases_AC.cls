/************************************************************************************
Author : Mst Solutions
Description : This class is used to Create Subcases
*************************************************************************************/

public class CreateSubCases_AC {
    
    public static void createChildCases(String parentIdString) {
        Constant_AC  constant = new Constant_Ac(); 
        Id parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
        Id wishDeterminationRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishDeterminationRT).getRecordTypeId();
        Id wishPlanningRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishPlanningAnticipationRT).getRecordTypeId();
        Id wishGrantRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishGrantRT).getRecordTypeId();
        Id wishEffectRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishEffectRT).getRecordTypeId();
        
        List<Case> childCreationWishList  = new List<Case>();
        List<Case> newWishList = new List<Case>();
        Map<Id, String> wishContactMap = new Map<Id, String>();
        
        for(Case caseInfo : [SELECT Id, Contact.Name, Anticipated_Start_Date__c, OwnerId FROM Case WHERE Id =: parentIdString]) {
            wishContactMap.put(caseInfo.Id, caseInfo.Contact.Name);
            childCreationWishList.add(caseInfo);
        }
        
        for(Case wishDetails : childCreationWishList) {
            
            Case newWish = new Case(Wish_Type__c = 'Standard', Subject = 'Wish Determination - '+wishContactMap.get(wishDetails.Id), ParentId = wishDetails.Id, Origin = 'Web',RecordTypeId = wishDeterminationRecordTypeId, OwnerId = wishDetails.OwnerId);
            newWishList.add(newWish);
            Case newPlanningWish = new Case(Wish_Type__c ='Standard', Subject = 'Wish Planning - '+ wishContactMap.get(wishDetails.Id),ParentId = wishDetails.Id,Origin = 'Web',RecordTypeId = wishPlanningRecordTypeId,OwnerId = wishDetails.OwnerId);
            newWishList.add(newPlanningWish);
            Case newGrantingWish = new Case(Wish_Type__c ='Standard', Subject = 'Wish Granting - '+ wishContactMap.get(wishDetails.Id), ParentId = wishDetails.Id, Start_Date__c = wishDetails.Anticipated_Start_Date__c,Origin = 'Web',RecordTypeId = wishGrantRecordTypeId, OwnerId = wishDetails.OwnerId);
            newWishList.add(newGrantingWish);
            Case newImpactWish = new Case(Wish_Type__c ='Standard', Subject = 'Wish Impact - '+ wishContactMap.get(wishDetails.Id), ParentId = wishDetails.Id,Origin = 'Web',RecordTypeId = wishEffectRecordTypeId, OwnerId = wishDetails.OwnerId);
            newWishList.add(newImpactWish);
            
        }
        
        if(newWishList.size()>0) {
            insert newWishList;
        }
    }
    
}