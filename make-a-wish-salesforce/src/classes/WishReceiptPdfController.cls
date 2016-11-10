public class WishReceiptPdfController{
string caseId;
list<Case> caseList {get;set;}
public case curCase {get;set;}
public WishReceiptPdfController(ApexPages.StandardController controller){
  caseId = System.currentPageReference().getParameters().get('caseId');
  caseList = [SELECT ID,ChapterName__r.Name,Wish_Receipt_Items__c,Contact.Name FROm Case WHERE ID =: caseId];
  if(caseList.size() > 0)
    curCase = caseList[0];
}
}