/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class SDriveController {
    @RemoteAction
    global static Boolean copyS3File(String sourceFileId, String destinationFileId) {
        return null;
    }
    @RemoteAction
    global static Boolean copyS3FileForAttach(String sourceFileId, String destinationFileId, String targetNamespacePrefix, String targetObjectFileName, String targetObjectId) {
        return null;
    }
    @RemoteAction
    global static String copySalesforceObject(String fileId, String destinationId, Boolean inheritItemSharings) {
        return null;
    }
    @RemoteAction
    global static String copySalesforceObjectForAttach(String fileId, String targetNamespacePrefix, String targetObjectFileName, String targetObjectId, String targetFolderId, String relationshipName, String privateEnabled) {
        return null;
    }
    @RemoteAction
    global static Boolean createNewFolder(String newFolderName, String folderDescription, String inheritSharingValue, String currentFolderId) {
        return null;
    }
    @RemoteAction
    global static void deleteExistingFile(String idToDelete) {

    }
    @RemoteAction
    global static void deleteExistingFileForAttach(String idToDelete, String objectId, String customObjectFileName, String namespacePrefix) {

    }
    @RemoteAction
    global static void deleteS3File(String sourceFileId, String sourceFileName) {

    }
    @RemoteAction
    global static void finishCutting(String fileId, String destinationId, Boolean inheritItemSharings) {

    }
    @RemoteAction
    global static List<String> loadFoldersTree(String parentId) {
        return null;
    }
    @RemoteAction
    global static Boolean renameS3File(String sourceFileId, String destinationFileName) {
        return null;
    }
    @RemoteAction
    global static void trydeletingExistingFile(String idToDelete) {

    }
}
