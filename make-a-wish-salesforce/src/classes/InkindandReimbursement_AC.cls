/**************************************************************************
This InkindandReimbursement_AC is used to display the Inkind and Reimbursement page 
and user can download the Inkind and CFSCheck form.  
**************************************************************************/
public class InkindandReimbursement_AC{
    public case wishChildCase{get;set;}
    Public String inkindFileDownload {get;set;}
    public InkindandReimbursement_AC(ApexPages.StandardController controller) {
    inkindFileDownload = '';
       wishChildCase = [SELECT Id,contactId,contact.Wish_Child_Photo__c  FROM Case WHERE Id =: ApexPages.currentPage().getParameters().get('recId')];
       List<Document> dbDocument = [SELECT Id, Name FROM Document WHERE Name = 'InkindPDF'];
       if(dbDocument.size() > 0) {
           inkindFileDownload = 'https://cs94.salesforce.com/servlet/servlet.FileDownload?file='+dbDocument[0].Id;
       }
       
    }
    
    /******************************************************************************************************
     ReturnToWish() will fire when the user click Return to wish link in RelationshipViewer page.
    ********************************************************************************************************/
    public pageReference ReturnToWish(){
        PageReference reference=new PageReference('/'+wishChildCase.Id);
        reference.setRedirect(true);     
        return reference;
        
    } 
    
}