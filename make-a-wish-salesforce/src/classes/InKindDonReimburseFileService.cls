/**
 * @author Steve Doucette, Traction on Demand 
 * @date 3/16/2020
 */
public class InKindDonReimburseFileService {

    /**
     * @param inKindDonReimburseFiles
     */
    public static void updateInKindReimburseFilePath(List<InkindDon_reimburseFile__c> inKindDonReimburseFiles){
        List<Id> drIds = new List<Id>();
        Set<String> inKindIdsSet = new Set<String>();
        Map<Id, String> inKindFileMap = new Map<Id, String>();
        List<In_Kind_Donation_Reimbursement__c> updatedInKindList = new List<In_Kind_Donation_Reimbursement__c>();
        for (InkindDon_reimburseFile__c dr : inKindDonReimburseFiles) {
            drIds.add(dr.Id);
            inKindFileMap.put(dr.Id, String.valueOf(dr));
            if (dr.Parent__c != null) {
                inKindIdsSet.add(dr.Parent__c);
            }
        }

        AWSFilePathService.updateInKindDonReimburseFilePath(drIds, inKindFileMap);
        if (inKindIdsSet.size() > 0) {
            for (In_Kind_Donation_Reimbursement__c currentInkind : [
                    SELECT Id,Documentation__c
                    FROM In_Kind_Donation_Reimbursement__c
                    WHERE Id IN :inKindIdsSet
            ]) {
                currentInkind.Documentation__c = 'Attached';
                updatedInKindList.add(currentInkind);
            }
            update updatedInKindList;
        }
    }

    /**
     * @description Set related parents to "Not Available"
     * @param deletedFiles
     */
    public static void setReimbursementFilesToNotAvailable(List<InkindDon_reimburseFile__c> deletedFiles){
        Set<String> inKindIdsSet = new Set<String>();
        List<In_Kind_Donation_Reimbursement__c> updateList = new List<In_Kind_Donation_Reimbursement__c>();
        for (InkindDon_reimburseFile__c deleteRecord : deletedFiles) {
            if (deleteRecord.Parent__c != null) {
                inKindIdsSet.add(deleteRecord.Parent__c);
            }
        }

        if (inKindIdsSet.size() > 0) {
            Set<String> attachmentExistParentsSet = new Set<String>();
            for (InkindDon_reimburseFile__c checkChild : [
                    SELECT Id, Parent__c
                    FROM InkindDon_reimburseFile__c
                    WHERE Parent__c IN :inKindIdsSet
            ]) {
                attachmentExistParentsSet.add(checkChild.Parent__c);
            }
            List<String> updateIdsSet = new List<String>();
            for (String s : inKindIdsSet) {
                if (!attachmentExistParentsSet.contains(s)) {
                    updateIdsSet.add(s);
                }
            }
            if (updateIdsSet.size() > 0) {
                for (In_Kind_Donation_Reimbursement__c curRecord : [
                        SELECT Id,Documentation__c
                        FROM In_Kind_Donation_Reimbursement__c
                        WHERE Id IN :updateIdsSet
                ]) {
                    curRecord.Documentation__c = Constant_AC.INKIND_REIMBURSEMENT_FILE_DOCUMENTATION;
                    updateList.add(curRecord);
                }
                update updateList;
            }
        }
    }
}