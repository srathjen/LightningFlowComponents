/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class SDriveTools {
    global SDriveTools() {

    }
    global static void abortMultiPartUpload(String awsLocation, String uploadId) {

    }
    global static List<cg.ResultObject> cancelUpload(List<Id> wipIds, String objectId) {
        return null;
    }
    global static List<cg.ResultObject> cancelUpload(List<Id> wipIds, String objectId, Boolean isDeleteS3Object) {
        return null;
    }
    global static System.HttpResponse completeMultiPartUploadResponse(String awsLocation, String uploadId, List<String> eTagList) {
        return null;
    }
    global static String completeMultiPartUpload(String awsLocation, String uploadId, List<String> eTagList) {
        return null;
    }
    global static List<cg.ResultObject> completeUpload(List<Id> wipIds) {
        return null;
    }
    global static List<cg.ResultObject> completeUpload(List<Id> wipIds, List<String> versionIdList) {
        return null;
    }
    global static String copyPartMultiPartUpload(String awsLocation, String uploadId, Long partNumber) {
        return null;
    }
    global static System.HttpResponse copyPartMultiPartUploadResponse(String awsLocation, String uploadId, Long partNumber) {
        return null;
    }
    global static List<cg.ResultObject> deleteFiles(List<Id> wipIds, String objectId) {
        return null;
    }
    global static List<cg.ResultObject> deleteFiles(List<Id> wipIds, String objectId, Boolean isDeleteS3Object) {
        return null;
    }
    global static void deleteMultiParts(List<String> awsChunkLocationList) {

    }
    global static void deleteMultiParts(List<String> awsChunkLocationList, List<String> versionIdList) {

    }
    global static void deleteS3Files(List<String> awsLocationList, List<String> versionIdList) {

    }
    global static String getAccessKey() {
        return null;
    }
    global static Map<String,String> getAmazonHeaders(String item) {
        return null;
    }
    global static Map<String,String> getAmazonHeaders(String item, String versionId) {
        return null;
    }
    global static String getAttachmentURL(String parentId, String fileObjectId, Long timeValue) {
        return null;
    }
    global static List<String> getAttachmentURLs(List<Id> parentIds, List<Id> fileObjectIds, Long timeValue) {
        return null;
    }
    global static List<String> getAttachmentURLs(List<Id> parentIds, List<Id> fileObjectIds, Long timeValue, List<Map<String,String>> requestParametersList) {
        return null;
    }
    global static List<String> getAttachmentURLs(List<Id> parentIds, List<Id> fileObjectIds, Long timeValue, Map<String,String> requestParameters) {
        return null;
    }
    global static String getBodyHeader(String resBody, String headerName) {
        return null;
    }
    global static String getBucketName() {
        return null;
    }
    global static String getResponseHeader(System.HttpResponse res, String headerName) {
        return null;
    }
    global static String getS3Endpoint() {
        return null;
    }
    global static String getShortenedAttachmentURL(String parentId, String fileObjectId, Long timeValue) {
        return null;
    }
    global static List<String> getShortenedAttachmentURLs(List<Id> parentIds, List<Id> fileObjectIds, Long timeValue, Map<String,String> requestParameters) {
        return null;
    }
    global static String getUserToken() {
        return null;
    }
    global static String id15to18(String inID) {
        return null;
    }
    global static void inheritSharings(List<String> wipIdList, String currentFolderId) {

    }
    global static String initializeMultiPartUpload(String awsLocation) {
        return null;
    }
    global static List<cg.UploadRequestInfo> initializeUpload(String objectId, List<SObject> attachments, List<Map<String,String>> policyMapList) {
        return null;
    }
    global static List<cg.UploadRequestInfo> initializeUpload(String objectId, List<SObject> attachments, List<Map<String,String>> policyMapList, List<String> IdToUploadNewVersionList) {
        return null;
    }
    global static List<cg.UploadRequestInfo> initializeUpload(String objectId, List<SObject> attachments, Map<String,String> policyMap) {
        return null;
    }
}
