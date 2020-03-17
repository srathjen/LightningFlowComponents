/**************************************************************************
This InkindandReimbursement_AC is used to display the Inkind and Reimbursement page 
and user can download the Inkind and CFSCheck form.  
**************************************************************************/
public class InkindandReimbursement_AC {
    private static final String FILE_DOWNLOAD_URL_BASE = '/servlet/servlet.FileDownload?file=';

    public Case wishChildCase { get; set; }
    public String inKindFormLink  { get; set; }
    public String checkRequestLink  { get; set; }

    public InkindandReimbursement_AC(ApexPages.StandardController controller) {
        wishChildCase = [
            SELECT
                Id,
                ContactId,
                Contact.Wish_Child_Photo__c
            FROM Case
            WHERE Id = :ApexPages.currentPage().getParameters().get('recId')
        ];

        Inkind_Donation_PDFs__c pdfCustomMetadata = Inkind_Donation_PDFs__c.getInstance(UserInfo.getUserId());
        inKindFormLink = FILE_DOWNLOAD_URL_BASE + pdfCustomMetadata.In_Kind_Form_PDF__c;
        checkRequestLink = FILE_DOWNLOAD_URL_BASE + pdfCustomMetadata.Check_Request_PDF__c;
    }


    /*
     * @description     Will fire when the user click Return to wish link in RelationshipViewer page.
     *
     * @return          PageReference
     *
     * @author          MST Solutions
     * @date            unknown
     */
    public PageReference ReturnToWish() {
        PageReference reference = new PageReference('/' + wishChildCase.Id);
        reference.setRedirect(true);

        return reference;
    }
}