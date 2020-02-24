@IsTest
public class MedicalRelationships_AC_Test {

	@IsTest
	static void createRelationship() {
		Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
		insert chapterAccount;
		Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
		insert wishChild;
		Contact MedicalProf = OrientationandTrainingUtil.CreateMedicalProfContact();
		insert MedicalProf;
		Case wish = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
		insert wish;
		npe4__Relationship__c relationship = OrientationandTrainingUtil.CreateRelationshipRec(wishChild.Id, MedicalProf.Id);
		insert relationship;
		PageReference pageRef = Page.MedicalRelationships_VF;
		Test.setCurrentPage(pageRef);
		ApexPages.StandardController stdController = new ApexPages.StandardController(wish);
		MedicalRelationships_AC medRel = new MedicalRelationships_AC(stdController);
		medRel.getmedicalRelationshipsConList();
	}
}