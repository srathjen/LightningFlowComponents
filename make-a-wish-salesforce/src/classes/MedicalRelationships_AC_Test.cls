@isTest
public class MedicalRelationships_AC_Test{
    @isTest static void createRelationship(){
        Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        contact MedicalProf = OrientationandTrainingUtil.CreateMedicalProfContact();
        Case wish = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        npe4__Relationship__c relationship = OrientationandTrainingUtil.CreateRelationshipRec(wishChild.Id,MedicalProf.Id);        
        PageReference pageRef = Page.MedicalRelationships_VF;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController stdController = new ApexPages.StandardController(wish);
        MedicalRelationships_AC medRel =  new MedicalRelationships_AC(stdController);
        medRel.getmedicalRelationshipsConList();
    }
}