@isTest
public class InkindandReimbursement_Test {

	static testmethod void createRecords() {
		Account chapterAcc = OrientationandTrainingUtil.createchapterAccount();
		insert chapterAcc;
		Contact wishChild = OrientationandTrainingUtil.CreateWishChildwithAcc(chapterAcc.Id);
		insert wishChild;
		Case wish = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
		insert wish;
		Document document;
		document = new Document();
		document.Body = Blob.valueOf('Some Text');
		document.ContentType = 'application/pdf';
		document.DeveloperName = 'InkindPDF';
		document.IsPublic = true;
		document.Name = 'InkindPDF';
		document.FolderId = [
				select id
				from folder
				where name = 'Drawloop Files'
		].id;
		insert document;
		PageReference pageRef = Page.InkindandReimbursement_VF;
		pageRef.getParameters().put('recId', String.valueOf(wish.Id));
		ApexPages.StandardController sc = new ApexPages.StandardController(wish);
		Test.setCurrentPage(pageRef);
		InkindandReimbursement_AC controller = new InkindandReimbursement_AC (sc);
		controller.ReturnToWish();
	}
}