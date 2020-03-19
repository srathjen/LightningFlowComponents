/*****************************************************************************************************************
Author      : MST Solutions
Date        : 01/19/2017
Description : This form is used as IFrame inside the  Diagnosis Verification form to upload medical summary attachment
*******************************************************************************************************************/
public class wifAttachment_AC {

    @TestVisible private static final String URL_PARAMETER_SAVED = 'saved';
    @TestVisible private static final String URL_PARAMETER_DELETED = 'deleted';
    @TestVisible private static final String URL_PARAMETER_ID = 'id';
    @TestVisible private static final String URL_VALUE_TRUE = 'true';

    public Id attachmentId { get; set; }
    public Attachment newAttachment { get; set; }
    public Id recId;
    public Boolean isSaved { get; set; }
    public Boolean isDeleted { get; set; }

    public wifAttachment_AC() {
        newAttachment = new Attachment();
        recId = ApexPages.currentPage().getParameters().get(URL_PARAMETER_ID);
        if (ApexPages.currentPage().getParameters().get(URL_PARAMETER_SAVED) != null && ApexPages.currentPage().getParameters().get(URL_PARAMETER_SAVED) == URL_VALUE_TRUE) {
            isSaved = true;
        }
        if (ApexPages.currentPage().getParameters().get(URL_PARAMETER_DELETED) != null && ApexPages.currentPage().getParameters().get(URL_PARAMETER_DELETED) == URL_VALUE_TRUE) {
            isDeleted = true;
        }
    }

    //Used to display medical summary attachment to diagnosis verification form
    public List<cg__CaseFile__c> getAttachments() {
        Set<Id> folderIdSet = new Set<Id>();
        for (cg__CaseFile__c caseFileFolders : [
                SELECT Id
                FROM cg__CaseFile__c
                WHERE cg__Case__c = :recId AND cg__Content_Type__c = :Constant_AC.FILE_CONTENT_TYPE_FOLDER
                AND (cg__File_Name__c = :Constant_AC.FILE_NAME_STAFF_PRIVATE OR cg__File_Name__c = :Constant_AC.FILE_NAME_FINANCIALS)
        ]) {
            folderIdSet.add(caseFileFolders.Id);
        }
        List<cg__CaseFile__c> attachmentList = [
                SELECT Id, cg__Case__c, File_Path__c, cg__Description__c, cg__File_Name__c
                FROM cg__CaseFile__c
                WHERE cg__Case__c = :recId AND cg__Content_Type__c != :Constant_AC.FILE_CONTENT_TYPE_FOLDER AND cg__Parent_Folder_Id__c NOT IN :folderIdSet
        ];
        return attachmentList;
    }

    //Used to save new attachment that attached from diagnosis verification form
    public PageReference save() {
        if (newAttachment.Body != null) {
            newAttachment.ParentId = recId;
            insert newAttachment;
            newAttachment = new Attachment();
        }
        PageReference redirect = Page.wifAttachment_VF;
        redirect.getParameters().put(URL_PARAMETER_ID, recId);
        redirect.getParameters().put(URL_PARAMETER_SAVED, URL_VALUE_TRUE);
        redirect.setRedirect(true);
        return redirect;
    }

    //Used to delete the attachment from diagnosis verification form
    public PageReference RemoveAttachment() {
        try {
            delete new cg__CaseFile__c(Id = attachmentId);
        } catch (Exception ex) {
            System.debug('Exception ex' + ex.getMessage());
        }
        PageReference redirect = Page.wifAttachment_VF;
        redirect.getParameters().put(URL_PARAMETER_ID, recId);
        redirect.setRedirect(true);
        return redirect;
    }
}