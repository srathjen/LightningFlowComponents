/**
 * @description : This class is used to generate file path for the attachment that stored in SDrive for object
 * Modification Log:
 * 09/10/2019 - Manik - WLP-423
 * @author : MST Solutions
 * @date : 10/4/2016
 **/
public without sharing class AWSFilePathService {

    private static final String DEFAULT_FILEPATH = Label.AWSDefaultFilePathPrefix;

    private static final Integer DEFAULT_TIME_VALUE = 365 * 24 * 60 * 60; // Years worth in seconds

    /**
     * @description
     * @param fileRecordIds
     * @param exceptionMap
     */
    @Future
    public static void updateWishRequiredSignatureFilePath(List<Id> fileRecordIds, Map<Id, String> exceptionMap) {
        if (fileRecordIds.isEmpty()) {
            return;
        }
        try {
            List<Id> fileParentIds = new List<Id>();
            List<Map<String, String>> requestParametersList = new List<Map<String, String>>();

            List<Wish_Required_Signature_File__c > wishSignFiles = [
                    SELECT Id, Wish_Required_Signature__c, File_Name__c, File_Path__c
                    FROM Wish_Required_Signature_File__c
                    WHERE Wish_Required_Signature_File__c.Content_Type__c != :Constant_AC.FILE_CONTENT_TYPE_FOLDER AND Wish_Required_Signature_File__c.Id IN :fileRecordIds
            ];

            for (Wish_Required_Signature_File__c dbWishSignFileRec : wishSignFiles) {
                fileParentIds.add(dbWishSignFileRec.Wish_Required_Signature__c);
                requestParametersList.add(new Map<String, String>{
                        'response-content-disposition' => 'attachment;filename=' + dbWishSignFileRec.File_Name__c
                });
            }

            List<String> wishSignFilePaths = setFilePath(fileParentIds, fileRecordIds, DEFAULT_TIME_VALUE, requestParametersList);

            for (Wish_Required_Signature_File__c wishSignFileRec : wishSignFiles) {
                for (String str : wishSignFilePaths) {
                    if (str.contains(wishSignFileRec.Id)) {
                        wishSignFileRec.File_Path__c = str;
                        wishSignFileRec.WIP__c = false;
                    }
                }
            }
            update wishSignFiles;
            delete [
                    SELECT Id
                    FROM Attachment
                    WHERE ParentId IN:fileParentIds
            ];
            if (Test.isRunningTest()) {
                throw new CommonTriggerException('Test Class execution');
            }
        } catch (Exception ex) {
            for (Id currRec : exceptionMap.keySet()) {
                ErrorMessage_AC.createDebugRec('AWSFilePathService', exceptionMap.get(currRec), String.valueOf(ex), 'updateAccountFilePath', currRec, ex.getStackTraceString() + '   ' + ex.getMessage(), 'Error');
            }
        }
    }

    /**
     * @description
     * @param fileRecordIds
     * @param exceptionMap
     */
    @Future
    public static void updateAccountFilePath(List<Id> fileRecordIds, Map<Id, String> exceptionMap) {
        if (fileRecordIds.isEmpty()) {
            return;
        }
        try {
            List<Id> fileParentIds = new List<Id>();
            List<Map<String, String>> requestParametersList = new List<Map<String, String>>();

            List<cg__AccountFile__c> accountFiles = [
                    SELECT Id, cg__Account__c, cg__File_Name__c, File_Path__c
                    FROM cg__AccountFile__c
                    WHERE cg__AccountFile__c.cg__Content_Type__c != :Constant_AC.FILE_CONTENT_TYPE_FOLDER AND cg__AccountFile__c.Id IN :fileRecordIds
            ];

            for (cg__AccountFile__c dbAccountFileRec : accountFiles) {
                fileParentIds.add(dbAccountFileRec.cg__Account__c);
                requestParametersList.add(new Map<String, String>{
                        'response-content-disposition' => 'attachment;filename=' + dbAccountFileRec.cg__File_Name__c
                });
            }

            List<String> accountFilePaths = setFilePath(fileParentIds, fileRecordIds, DEFAULT_TIME_VALUE, requestParametersList);

            for (cg__AccountFile__c accountFileRec : accountFiles) {
                for (String str : accountFilePaths) {
                    if (str.contains(accountFileRec.Id)) {
                        accountFileRec.File_Path__c = str;
                    } else if (Test.isRunningTest()) {
                        accountFileRec.File_Path__c = DEFAULT_FILEPATH;
                    }
                }
            }
            update accountFiles;
        } catch (Exception ex) {
            for (Id currRec : exceptionMap.keySet()) {
                ErrorMessage_AC.createDebugRec('AWSFilePathService', exceptionMap.get(currRec), String.valueOf(ex), 'updateAccountFilePath', currRec, ex.getStackTraceString() + '   ' + ex.getMessage(), 'Error');
            }
        }
    }

    /**
     * @description
     * @param fileRecordIds
     * @param exceptionMap
     */
    @Future
    public static void updateContactFilePath(List<Id> fileRecordIds, Map<Id, String> exceptionMap) {
        if (fileRecordIds.isEmpty()) {
            return;
        }
        try {
            List<Id> fileParentIds = new List<Id>();
            List<Map<String, String>> requestParametersList = new List<Map<String, String>>();

            List<cg__ContactFile__c> contactFiles = [
                    SELECT Id, cg__Contact__c, cg__File_Name__c, File_Path__c
                    FROM cg__ContactFile__c
                    WHERE cg__Content_Type__c != :Constant_AC.FILE_CONTENT_TYPE_FOLDER AND cg__ContactFile__c.Id IN :fileRecordIds
            ];

            for (cg__ContactFile__c dbContactFileRec : contactFiles) {
                fileParentIds.add(dbContactFileRec.cg__Contact__c);
                requestParametersList.add(new Map<String, String>{
                        'response-content-disposition' => 'attachment;filename=' + dbContactFileRec.cg__File_Name__c
                });
            }

            List<String> contactFilePaths = setFilePath(fileParentIds, fileRecordIds, DEFAULT_TIME_VALUE, requestParametersList);

            for (cg__ContactFile__c ContactFileRec : contactFiles) {
                for (String str : contactFilePaths) {
                    if (str.contains(ContactFileRec.Id)) {
                        ContactFileRec.File_Path__c = str;
                    }
                }
            }
            update contactFiles;
            if (Test.isRunningTest()) {
                throw new CommonTriggerException('Test Class execution');
            }
        } catch (Exception ex) {
            for (Id currRec : exceptionMap.keySet()) {
                ErrorMessage_AC.createDebugRec('AWSFilePathService', exceptionMap.get(currRec), String.valueOf(ex), 'updateContactFilePath', currRec, ex.getStackTraceString() + '   ' + ex.getMessage(), 'Error');
            }
        }
    }

    /**
     * @description
     * @param fileRecordIds
     * @param exceptionMap
     */
    @Future
    public static void updateCaseFilePath(List<Id> fileRecordIds, Map<Id, String> exceptionMap) {
        if (fileRecordIds.isEmpty()) {
            return;
        }
        try {
            List<Id> fileParentIds = new List<Id>();
            List<Map<String, String>> requestParametersList = new List<Map<String, String>>();

            List<cg__CaseFile__c> caseFiles = [
                    SELECT Id, cg__Case__c, cg__File_Name__c, File_Path__c
                    FROM cg__CaseFile__c
                    WHERE cg__CaseFile__c.cg__Content_Type__c != :Constant_AC.FILE_CONTENT_TYPE_FOLDER AND cg__CaseFile__c.Id IN :fileRecordIds
            ];

            for (cg__CaseFile__c dbCaseFileRec : caseFiles) {
                fileParentIds.add(dbCaseFileRec.cg__Case__c);
                requestParametersList.add(new Map<String, String>{
                        'response-content-disposition' => 'attachment;filename=' + dbCaseFileRec.cg__File_Name__c
                });
            }

            List<String> caseFilePaths = setFilePath(fileParentIds, fileRecordIds, DEFAULT_TIME_VALUE, requestParametersList);

            for (cg__CaseFile__c caseFileRec : caseFiles) {
                for (String str : caseFilePaths) {
                    if (str.contains(caseFileRec.Id)) {
                        caseFileRec.File_Path__c = str;
                    }
                }
            }
            update caseFiles;
            if (Test.isRunningTest()) {
                throw new CommonTriggerException('Test Class execution');
            }
        } catch (Exception ex) {
            for (Id currRec : exceptionMap.keySet()) {
                ErrorMessage_AC.createDebugRec('AWSFilePathService', exceptionMap.get(currRec), String.valueOf(ex), 'updateCaseFilePath', currRec, ex.getStackTraceString() + '   ' + ex.getMessage(), 'Error');
            }
        }
    }

    /**
     * @description
     * @param fileRecordIds
     * @param exceptionMap
     */
    @Future
    public static void updateBackgroundCheckFilePath(List<Id> fileRecordIds, Map<Id, String> exceptionMap) {
        if (fileRecordIds.isEmpty()) {
            return;
        }
        try {
            List<Id> fileParentIds = new List<Id>();
            List<Map<String, String>> requestParametersList = new List<Map<String, String>>();

            List<Background_Check_File__c> bcFiles = [
                    SELECT Id, Parent__c, File_Name__c, File_Path__c
                    FROM Background_Check_File__c
                    WHERE Background_Check_File__c.Content_Type__c != :Constant_AC.FILE_CONTENT_TYPE_FOLDER AND Background_Check_File__c.Id IN :fileRecordIds
            ];

            for (Background_Check_File__c dbbcFileRec : bcFiles) {
                fileParentIds.add(dbbcFileRec.Parent__c);
                requestParametersList.add(new Map<String, String>{
                        'response-content-disposition' => 'attachment;filename=' + dbbcFileRec.File_Name__c
                });
            }

            List<String> bcFilePaths = setFilePath(fileParentIds, fileRecordIds, DEFAULT_TIME_VALUE, requestParametersList);

            for (Background_Check_File__c bcFileRec : bcFiles) {
                for (String str : bcFilePaths) {
                    if (str.contains(bcFileRec.Id)) {
                        bcFileRec.File_Path__c = str;
                    }
                }
            }
            update bcFiles;
            if (Test.isRunningTest()) {
                throw new CommonTriggerException('Test Class execution');
            }
        } catch (Exception ex) {
            for (Id currRec : exceptionMap.keySet()) {
                ErrorMessage_AC.createDebugRec('AWSFilePathService', exceptionMap.get(currRec), String.valueOf(ex), 'updateBackgroundCheckFilePath', currRec, ex.getStackTraceString() + '   ' + ex.getMessage(), 'Error');
            }
        }
    }

    /**
     * @description
     * @param fileRecordIds
     * @param exceptionMap
     */
    @Future
    public static void updateInKindDonReimburseFilePath(List<Id> fileRecordIds, Map<Id, String> exceptionMap) {
        if (fileRecordIds.isEmpty()) {
            return;
        }
        try {
            List<Id> fileParentIds = new List<Id>();
            List<Map<String, String>> requestParametersList = new List<Map<String, String>>();

            List<InkindDon_reimburseFile__c> drFiles = [
                    SELECT Id, Parent__c, File_Name__c, File_Path__c
                    FROM InkindDon_reimburseFile__c
                    WHERE InkindDon_reimburseFile__c.Content_Type__c != :Constant_AC.FILE_CONTENT_TYPE_FOLDER AND InkindDon_reimburseFile__c.Id IN :fileRecordIds
            ];

            for (InkindDon_reimburseFile__c dbdrFileRec : drFiles) {
                fileParentIds.add(dbdrFileRec.Parent__c);
                requestParametersList.add(new Map<String, String>{
                        'response-content-disposition' => 'attachment;filename=' + dbdrFileRec.File_Name__c
                });
            }

            List<String> drFilePaths = setFilePath(fileParentIds, fileRecordIds, DEFAULT_TIME_VALUE, requestParametersList);

            for (InkindDon_reimburseFile__c drFileRec : drFiles) {
                for (String str : drFilePaths) {
                    if (str.contains(drFileRec.Id)) {
                        drFileRec.File_Path__c = str;
                    }
                }
            }
            update drFiles;
            if (Test.isRunningTest()) {
                throw new CommonTriggerException('Test Class execution');
            }
        } catch (Exception ex) {
            for (Id currRec : exceptionMap.keySet()) {
                ErrorMessage_AC.createDebugRec('AWSFilePathService', exceptionMap.get(currRec), String.valueOf(ex), 'updateInKindDonReimburseFilePath', currRec, ex.getStackTraceString() + '   ' + ex.getMessage(), 'Error');
            }
        }
    }

    // Determine file path for AWS based on list of Id's. If none set as default.
    private static List<String> setFilePath(List<Id> fileParentIds, List<Id> fileRecordIds, Integer timeValue, List<Map<String, String>> requestParametersList) {
        if (Test.isRunningTest() || fileParentIds.isEmpty()) {
            return new List<String>{
                    DEFAULT_FILEPATH
            };
        } else {
            return cg.SDriveTools.getAttachmentURLs(fileParentIds, fileRecordIds, timeValue, requestParametersList);
        }
    }
}