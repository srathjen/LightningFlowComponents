/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class HtmlUploadComponentController {
    @RemoteAction
    global static void abortMultiPartUpload(String awsLocation, String uploadId) {

    }
    @RemoteAction
    global static void cleanupFailedUpload(String fileWipId, String objectIdAT) {

    }
    @RemoteAction
    global static void cleanupFailedUpload2(String fileWipId, String objectIdAT, Boolean isDeleteS3Object) {

    }
    @RemoteAction
    global static String completeMultiPartUpload(String awsLocation, String uploadId, List<String> eTagList) {
        return null;
    }
    @RemoteAction
    global static void completeUpload(String fileWipId) {

    }
    @RemoteAction
    global static void completeUpload2(String fileWipId, String versionId) {

    }
    @RemoteAction
    global static String copyPartMultiPartUpload(String awsLocation, String uploadId, Long partNumber) {
        return null;
    }
    @RemoteAction
    global static List<cg.UploadRequestInfo> createFileObject(String objectIdAT, String fileName, String fileSize, String currentFolderIdAT, String fileNamespacePrefixAT, String customObjectFileNameAT, String relationshipNameAT, String fileWithColumnsString, Boolean isChunked) {
        return null;
    }
    @RemoteAction
    global static void deleteExistingFileForOverWrite(String fileName, String currentFolderIdAT) {

    }
    @RemoteAction
    global static void deleteExistingFileForOverWrite2(String fileName, String currentFolderIdAT) {

    }
    @RemoteAction
    global static void deleteMultiParts2(List<String> awsChunkLocationList, List<String> awsChunkVersionIdList) {

    }
    @RemoteAction
    global static void deleteMultiParts(List<String> awsChunkLocationList) {

    }
    @RemoteAction
    global static String getHeaders(String location) {
        return null;
    }
    @RemoteAction
    global static void inheritSharings(String fileWipId, String currentFolderIdAT) {

    }
    @RemoteAction
    global static String initializeMultiPartUpload(String awsLocation) {
        return null;
    }
    @RemoteAction
    global static List<cg.UploadRequestInfo> initializeUpload(String objectIdAT, String fileName, String fileSize, String currentFolderIdAT, String fileNamespacePrefixAT, String customObjectFileNameAT, String relationshipNameAT, String fileWithColumnsString, Boolean isChunked, Boolean isNewVersionUploadAT, String IdToUploadNewVersionAT) {
        return null;
    }
}
