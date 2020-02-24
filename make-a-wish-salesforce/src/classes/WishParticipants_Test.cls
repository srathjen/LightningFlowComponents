@isTest
public class WishParticipants_Test{
    @isTest static void createRelationship(){
        Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
        insert chapterAccount;

        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Contact wishFamily = OrientationandTrainingUtil.CreateWishFamily();
        insert new List<Contact>{
                wishChild, wishFamily
        };

        Case wish = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        insert wish;

        npe4__Relationship__c relationship = OrientationandTrainingUtil.CreateRelationshipRec(wishChild.Id,wishFamily.Id);
        relationship.npe4__Type__c = 'Family';
        insert relationship;
        PageReference pageRef = Page.WishParticipants_VF;
        Test.setCurrentPage(pageRef);
         ApexPages.StandardController stdController = new ApexPages.StandardController(wish);
        WishParticipants_AC wishparticipant =  new WishParticipants_AC(stdController);
        wishparticipant.getParticipantsConList();
    }
}