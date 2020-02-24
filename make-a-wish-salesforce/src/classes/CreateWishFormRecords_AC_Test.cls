@isTest
public class CreateWishFormRecords_AC_Test {
    static testMethod void createInterviewDate() {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        insert chapterAccount;

        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        insert wishChild;

        Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        insert chapterAmericaAccount;

        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        insert parentCase;

        Contact childFamily = OrientationandTrainingUtil.CreateWishFamily();
        insert childFamily;

        npe4__Relationship__c  npcr = OrientationandTrainingUtil.CreateRelationshipRec(wishChild.Id,childFamily.Id);
        insert npcr;

        Wish_Child_Form__c wishForm = [SELECT Id FROM Wish_Child_Form__c WHERE Case__c =: parentCase.Id LIMIT 1];
        delete wishForm;

        Database.executeBatch(new CreateWishFormRecords_AC());
    }
}