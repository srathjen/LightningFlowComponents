/**
 * @author Steve Doucette, Traction on Demand 
 * @date 3/16/2020
 */
public class CaseFileService {

    private static final String HTML_DOUBLE_BREAK_LINE = '<br><br>';

    /**
     * @param newCaseFiles
     */
    public static void updateCaseFileFolderId(List<cg__CaseFile__c> newCaseFiles) {
        Map<Id, cg__CaseFile__c > newFileMap = new Map<Id, cg__CaseFile__c >();
        Map<Id, Id> caseFileMap = new Map<Id, Id>();
        Set<Id> caseId = new Set<Id>();
        Map<Id, cg__CaseFile__c> folderIdsMap = new Map<Id, cg__CaseFile__c>();

        for (cg__CaseFile__c cseFile : newCaseFiles) {
            newFileMap.put(cseFile.Id, cseFile);
            caseId.add(cseFile.cg__Case__c);
        }

        if (caseId.size() > 0) {
            for (cg__CaseFile__c caseFile : [
                    SELECT Id, cg__Content_Type__c, cg__File_Name__c, cg__Case__c, cg__Case__r.CaseNumber, cg__Parent_Folder_Id__c
                    FROM cg__CaseFile__c
                    WHERE cg__Case__c IN :caseId AND cg__Content_Type__c = :Constant_AC.FILE_CONTENT_TYPE_FOLDER
            ]) {
                if (caseFile.cg__File_Name__c == Constant_AC.FILE_NAME_DOCUMENTS) {
                    caseFileMap.put(caseFile.cg__Case__c, caseFile.Id);
                }
                folderIdsMap.put(caseFile.Id, caseFile);
            }
            for (cg__CaseFile__c cseFile1 : newCaseFiles) {
                if (folderIdsMap.containsKey(cseFile1.cg__Parent_Folder_Id__c)) {
                    cseFile1.Parent_Folder_Name__c = folderIdsMap.get(cseFile1.cg__Parent_Folder_Id__c).cg__File_Name__c;
                }
            }
            if (caseFileMap.size() > 0) {
                List<cg__CaseFile__c> updateCaseFileList = new List<cg__CaseFile__c>();
                for (cg__CaseFile__c newCaseFile : newFileMap.values()) {
                    if (caseFileMap.containsKey(newCaseFile.cg__Case__c)) {
                        if (newCaseFile.cg__Content_Type__c != Constant_AC.FILE_CONTENT_TYPE_FOLDER) {
                            newCaseFile.cg__Parent_Folder_Id__c = caseFileMap.get(newCaseFile.cg__Case__c);
                            updateCaseFileList.add(newCaseFile);
                        }
                    }
                }
            }
        }
    }

    /**
     * @param caseFileList
     */
    public static void updateAttachmentPath(List<cg__CaseFile__c> caseFileList) {
        if (caseFileList.isEmpty()) {
            return;
        }
        Set<Id> caseIdSet = new Set<Id>();
        Map<String, String> attachmentNameMap = new Map<String, String>();
        List<Minor_Participant__c> updateMinorParticipantList = new List<Minor_Participant__c>();
        for (cg__CaseFile__c dbRec : caseFileList) {
            caseIdSet.add(dbRec.cg__Case__c);
            attachmentNameMap.put(dbRec.cg__File_Name__c, dbRec.File_Path__c);
        }
        for (Minor_Participant__c dbRec : [
                SELECT Id,AttachmentId__c,Case__c,File_Path__c
                FROM Minor_Participant__c
                WHERE Case__c IN:caseIdSet AND AttachmentId__c != NULL
        ]) {
            if (attachmentNameMap.containsKey(dbRec.AttachmentId__c)) {
                dbRec.File_Path__c = attachmentNameMap.get(dbRec.AttachmentId__c);
                updateMinorParticipantList.add(dbRec);
            }
        }
        if (updateMinorParticipantList.size() > 0) {
            update updateMinorParticipantList;
        }
    }

    /**
     * @param fileRecordIds
     * @param exceptionMap
     */
    public static void updateCaseFilePath(Map<Id, cg__CaseFile__c> newCaseFilesMap) {
        Map<Id, String> caseFileMap = new Map<Id, String>();
        for (cg__CaseFile__c cf : newCaseFilesMap.values()) {
            caseFileMap.put(cf.Id, String.valueOf(cf));
        }
        AWSFilePathService.updateCaseFilePath(new List<Id>(newCaseFilesMap.keySet()), caseFileMap);
    }

    /**
     * @param caseIdSet
     * @param caseFileMap
     */
    public static void updateCaseFilePath(Map<Id, cg__CaseFile__c> newCaseFileMap, Map<Id, cg__CaseFile__c> oldcaseFileMap) {
        Set<Id> caseIdSet = new Set<Id>();
        Map<String, String> caseFileMap = new Map<String, String>();

        for (cg__CaseFile__c newCaseFile : newCaseFileMap.values()) {
            if (newCaseFile.File_Path__c != null) {
                caseIdSet.add(newCaseFile.cg__Case__c);
                caseFileMap.put(newCaseFile.cg__File_Name__c, newCaseFile.File_Path__c);
            }
        }

        if (caseFileMap.size() > 0) {
            List<Minor_Participant__c> minorParticipantList = new List<Minor_Participant__c>();
            for (Minor_Participant__c dbMinorParticipantRec : [
                    SELECT Id,Case__c,File_Path__c,Form_Name__c,AttachmentId__c,
                            RecordTypeId
                    FROM Minor_Participant__c
                    WHERE Case__c IN :caseIdSet
            ]) {
                if (caseIdSet.contains(dbMinorParticipantRec.Case__c)) {
                    if (caseFileMap.containsKey(dbMinorParticipantRec.AttachmentId__c)) {
                        dbMinorParticipantRec.File_Path__c = caseFileMap.get(dbMinorParticipantRec.AttachmentId__c);
                        minorParticipantList.add(dbMinorParticipantRec);
                    }
                }
            }
            update minorParticipantList;
        }
    }

    /**
     * @param oldCaseFileList
     */
    public static void updateCaseFilePathOnDelete(List<cg__CaseFile__c> oldCaseFileList) {
        Map<Id, String> filePathMap = new Map<Id, String>();
        for (cg__CaseFile__c oldCaseFile : oldCaseFileList) {
            if (oldCaseFile.File_Path__c != null) {
                filePathMap.put(oldCaseFile.cg__Case__c, oldCaseFile.File_Path__c);
            }
        }
        if (!filePathMap.isEmpty()) {
            List<Minor_Participant__c> deleteMinorParticipantList = new List<Minor_Participant__c>();
            List<Minor_Participant__c> updateMinorParticipantList = new List<Minor_Participant__c>();
            Case updateCase = new Case();
            Set<Id> caseIdSet = new Set<Id>();
            for (Minor_Participant__c dbMinorParticipant : [
                    SELECT Id,AttachmentId__c,File_Path__c,Case__c
                    FROM Minor_Participant__c
                    WHERE Case__c IN :filePathMap.keySet()
            ]) {
                if (filePathMap.containsKey(dbMinorParticipant.Case__c)) {
                    if (filePathMap.get(dbMinorParticipant.Case__c) == dbMinorParticipant.File_Path__c) {
                        deleteMinorParticipantList.add(dbMinorParticipant);
                        caseIdSet.add(dbMinorParticipant.Case__c);
                    } else {
                        updateMinorParticipantList.add(dbMinorParticipant);
                    }
                }
            }

            Integer i = 1;
            Map<Id, Case> updateCaseMap = new Map<Id, Case>();
            if (updateMinorParticipantList.size() > 0) {
                for (Minor_Participant__c processminorRec : updateMinorParticipantList) {
                    if (filePathMap.containsKey(processminorRec.Case__c)) {
                        updateCase.Id = processminorRec.Case__c;
                        if (updateCase.File_Path__c == null) {
                            updateCase.File_Path__c = i + '-' + ' ' + processminorRec.File_Path__c + HTML_DOUBLE_BREAK_LINE;
                        } else {
                            updateCase.File_Path__c = updateCase.File_Path__c + i + '-' + ' ' + processminorRec.File_Path__c + HTML_DOUBLE_BREAK_LINE;
                        }
                        i++;
                        updateCaseMap.put(updateCase.Id, updateCase);
                    }
                }
            } else {
                for (Case c : [
                        SELECT Id, File_Path__c
                        FROM Case
                        WHERE Id IN :caseIdSet
                ]) {
                    c.File_Path__c = null;
                    updateCaseMap.put(c.Id, c);
                }
            }
            update updateCaseMap.values();
            delete deleteMinorParticipantList;
        }
    }
}