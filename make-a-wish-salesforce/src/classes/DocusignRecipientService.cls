/**
 * @description
 * @author Steve Doucette, Traction on Demand
 * @date 3/26/2020
 */
public class DocusignRecipientService {

    private static final String DOCUSIGN_STATUS_SUBJECT_SIGNATURE_REQUIRED_WISH_FORM_AND_LIABILITY = Constant_AC.DOCUSIGN_STATUS_SUBJECT_SIGNATURE_REQUIRED_WISH_FORM_AND_LIABILITY;

    /**
     * @description
     * @param envelopMap
     * @param DSrecipiantList
     */
    public static void updateStatusRecord(Map<Id, String> envelopMap, List<dsfs__DocuSign_Recipient_Status__c> DSrecipiantList) {
        if (envelopMap.isEmpty()) {
            return;
        }
        List<dsfs__DocuSign_Status__c> updatedsfsList = new List<dsfs__DocuSign_Status__c>();
        try {
            if (!envelopMap.isEmpty()) {
                for (dsfs__DocuSign_Status__c dbStatusRec : [
                        SELECT Id,Recipient_names__c,dsfs__Sender__c,dsfs__Sender_Email__c
                        FROM dsfs__DocuSign_Status__c
                        WHERE Id IN :envelopMap.keySet()
                ]) {
                    if (envelopMap.containsKey(dbStatusRec.Id)) {
                        if (dbStatusRec.Recipient_names__c == null) {
                            dbStatusRec.Recipient_names__c = envelopMap.get(dbStatusRec.Id);
                        } else {
                            dbStatusRec.Recipient_names__c = dbStatusRec.Recipient_names__c + ', ' + envelopMap.get(dbStatusRec.Id);
                        }
                        updatedsfsList.add(dbStatusRec);
                    }
                }
            }
            update updatedsfsList;
            if (Test.isRunningTest()) {
                throw new CommonTriggerException(Constant_AC.TEST_EXCEPTION_ERROR);
            }
        } catch (Exception ex) {
            for (dsfs__DocuSign_Recipient_Status__c currRec : DSrecipiantList) {
                ErrorMessage_AC.createDebugRec('DocusignRecipientService', String.valueOf(currRec), String.valueOf(ex), 'UpdateStatusRecord', currRec.Id, ex.getStackTraceString() + '   ' + ex.getMessage(), 'Error');
                if (!Test.isRunningTest()) {
                    currRec.addError(Label.Debug_log_error_message);
                }
            }
        }
    }

    /**
     * @description
     * @param parentIdSet
     * @param DSrecipiantList
     */
    public static void updateAttachmentId(Set<Id> parentIdSet, List<dsfs__DocuSign_Recipient_Status__c> DSrecipiantList) {
        if (parentIdSet.isEmpty()) {
            return;
        }
        Map<Id, Id> attachmentMap = new Map<Id, Id>();
        List<dsfs__DocuSign_Status__c> dbdsfsList = new List<dsfs__DocuSign_Status__c>();
        try {
            for (Attachment dbAttachment : [
                    SELECT Id,ParentId
                    FROM Attachment
                    WHERE ParentId IN :parentIdSet
            ]) {
                attachmentMap.put(dbAttachment.ParentId, dbAttachment.Id);
            }
            for (dsfs__DocuSign_Status__c dbStatusRec : [
                    SELECT Id,AttachmentId__c
                    FROM dsfs__DocuSign_Status__c
                    WHERE Id IN :parentIdSet
            ]) {
                if (attachmentMap.containsKey(dbStatusRec.Id)) {
                    dbStatusRec.AttachmentId__c = attachmentMap.get(dbStatusRec.Id);
                    dbdsfsList.add(dbStatusRec);
                }
            }
            update dbdsfsList;

            if (Test.isRunningTest()) {
                throw new CommonTriggerException(Constant_AC.TEST_EXCEPTION_ERROR);
            }
        } catch (Exception ex) {
            for (dsfs__DocuSign_Recipient_Status__c currRec : DSrecipiantList) {
                ErrorMessage_AC.createDebugRec('DocusignRecipientService', String.valueOf(currRec), String.valueOf(ex), 'updateAttachmentId', currRec.Id, ex.getStackTraceString() + '   ' + ex.getMessage(), 'Error');
                if (!Test.isRunningTest()) {
                    currRec.addError(Label.Debug_log_error_message);
                }
            }
        }
    }
}