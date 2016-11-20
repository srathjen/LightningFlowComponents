/*****************************************************************************************************************
Author      : MST Solutions
Date        : 10/4/2016
Description : This class is used to generate file path for the attachment that stored in SDrive for object
*******************************************************************************************************************/
public class AWSFilePath_AC{
          
     public AWSFilePath_AC(){
     }
     
     @future
     public static void UpdateAccountFilePath(List<Id> fileRecordIds){
                  
         List<String> accountFilePaths;
         List<Id> fileParentIds=new List<Id>();
         List<Map<String,String>> requestParametersList = new  List<Map<String,String>>();
         
         List<cg__AccountFile__c> accountFiles = [Select Id, cg__Account__c, cg__File_Name__c, File_Path__c from cg__AccountFile__c where cg__AccountFile__c.cg__Content_Type__c !='Folder' and  cg__AccountFile__c.Id in: fileRecordIds];
         
          if(accountFiles.size() > 0){
          for(cg__AccountFile__c dbAccountFileRec : accountFiles){
                 fileParentIds.add(dbAccountFileRec.cg__Account__c);
                 requestParametersList.add(new Map<String,String>{'response-content-disposition'=>'attachment;filename=' + dbAccountFileRec.cg__File_Name__c});
             }
         }
         accountFilePaths = cg.SDriveTools.getAttachmentURLs(fileParentIds, fileRecordIds, (365 * 24 * 60 * 60), requestParametersList);
         system.debug('S drive File Paths 1 : '+ accountFilePaths);
         
         for( cg__AccountFile__c accountFileRec : accountFiles){
             for(String str : accountFilePaths){
                 if(str.contains(accountFileRec.Id)){
                     accountFileRec.File_Path__c=str;
                 }
             }
         }
         system.debug('S drive File Paths 2 : '+ accountFiles);
         update accountFiles;
         system.debug('S drive File Paths 3 : '+ accountFiles); 
          
     }
     
     @future
     public static void  UpdateContactFilePath(List<Id> fileRecordIds){
         List<String> contactFilePaths;
         List<Id> fileParentIds=new List<Id>();
         List<Map<String,String>> requestParametersList = new  List<Map<String,String>>();
         
         List<cg__ContactFile__c> contactFiles = [Select Id, cg__Contact__c, cg__File_Name__c, File_Path__c from cg__ContactFile__c where cg__Content_Type__c !='Folder' and  cg__ContactFile__c.Id in: fileRecordIds];
         
          if(contactFiles.size() > 0){
          for(cg__ContactFile__c dbContactFileRec : contactFiles){
                 fileParentIds.add(dbContactFileRec.cg__Contact__c);
                 requestParametersList.add(new Map<String,String>{'response-content-disposition'=>'attachment;filename=' + dbContactFileRec.cg__File_Name__c});
             }
         }
         contactFilePaths = cg.SDriveTools.getAttachmentURLs(fileParentIds, fileRecordIds, (365 * 24 * 60 * 60), requestParametersList);
         system.debug('S drive File Paths 1 : '+ contactFilePaths );
         
         for( cg__ContactFile__c ContactFileRec : contactFiles){
             for(String str : contactFilePaths){
                 if(str.contains(ContactFileRec.Id)){
                     ContactFileRec.File_Path__c=str;
                 }
             }
         }
         system.debug('S drive File Paths 2 : '+ contactFiles);
         update contactFiles;
         system.debug('S drive File Paths 3 : '+ contactFiles); 
         
     }
    
    @future
     public static void  UpdateCaseFilePath(List<Id> fileRecordIds){
         List<String> caseFilePaths;
         List<Id> fileParentIds=new List<Id>();
         List<Map<String,String>> requestParametersList = new  List<Map<String,String>>();
         
         List<cg__CaseFile__c> caseFiles = [Select Id, cg__Case__c, cg__File_Name__c, File_Path__c from cg__CaseFile__c where cg__CaseFile__c.cg__Content_Type__c !='Folder' and  cg__CaseFile__c.Id in: fileRecordIds];
         
          if(caseFiles.size() > 0){
          for(cg__CaseFile__c dbCaseFileRec : caseFiles){
                 fileParentIds.add(dbCaseFileRec.cg__Case__c);
                 requestParametersList.add(new Map<String,String>{'response-content-disposition'=>'attachment;filename=' + dbCaseFileRec.cg__File_Name__c});
             }
         }
         caseFilePaths = cg.SDriveTools.getAttachmentURLs(fileParentIds, fileRecordIds, (365 * 24 * 60 * 60), requestParametersList);
         system.debug('S drive File Paths 1 : '+ caseFilePaths );
         
         for(cg__CaseFile__c caseFileRec : caseFiles){
             for(String str : caseFilePaths){
                 if(str.contains(caseFileRec.Id)){
                     caseFileRec.File_Path__c=str;
                 }
             }
         }
         system.debug('S drive File Paths 2 : '+ caseFiles);
         update caseFiles;
         system.debug('S drive File Paths 3 : '+ caseFiles); 
     }
    
    
     @future
     public static void  UpdateBackgroundCheckFilePath(List<Id> fileRecordIds){
         List<String> bcFilePaths;
         List<Id> fileParentIds=new List<Id>();
         List<Map<String,String>> requestParametersList = new  List<Map<String,String>>();
         
         List<Background_Check_File__c> bcFiles = [Select Id, Parent__c, File_Name__c, File_Path__c from Background_Check_File__c where Background_Check_File__c.Content_Type__c !='Folder' and  Background_Check_File__c.Id in: fileRecordIds];
                  
          if(bcFiles.size() > 0){
          for(Background_Check_File__c dbbcFileRec : bcFiles){
                 fileParentIds.add(dbbcFileRec.Parent__c);
                 requestParametersList.add(new Map<String,String>{'response-content-disposition'=>'attachment;filename=' + dbbcFileRec.File_Name__c});
             }
         }
         bcFilePaths= cg.SDriveTools.getAttachmentURLs(fileParentIds, fileRecordIds, (365 * 24 * 60 * 60), requestParametersList);
         system.debug('S drive File Paths 1 : '+ bcFilePaths );
         
         for(Background_Check_File__c bcFileRec : bcFiles){
             for(String str : bcFilePaths){
                 if(str.contains(bcFileRec.Id)){
                     bcFileRec.File_Path__c=str;
                 }
             }
         }
         system.debug('S drive File Paths 2 : '+ bcFiles);
         update bcFiles;
         system.debug('S drive File Paths 3 : '+ bcFiles); 
     }
    
    /*This method is used to create file path for the attachment that stored to SDrive from the Lead record.
    It will update the file path to lead file record that created during attachment upload*/
    @future
    public static void  generateLeadFilePath(Set<Id> fileIdsSet){
        List<Id> fileIdsList = new List<Id>(fileIdsSet);
        List<String> leadFilePath;
        List<Id> fileParentIdList = new List<Id>();
        List<Map<String,String>> requestParametersList = new  List<Map<String,String>>();
        
        List<Lead_File__c> leadFileList = [Select Id, Parent__c, File_Name__c, File_Path__c from Lead_File__c where Lead_File__c.Content_Type__c !='Folder' and  Lead_File__c.Id in: fileIdsSet];
        if(leadFileList.size() > 0) {
            for(Lead_File__c collectedFileRec : leadFileList){
                fileParentIdList.add(collectedFileRec.Parent__c);
                requestParametersList.add(new Map<String,String>{'response-content-disposition'=>'attachment;filename=' + collectedFileRec.File_Name__c});
            }
        }
        
        if(!Test.isRunningTest())
            //Used to get the file path of the attachment stored in Amazon
            leadFilePath = cg.SDriveTools.getAttachmentURLs(fileParentIdList, fileIdsList, (365 * 24 * 60 * 60), requestParametersList);
        else
            leadfilepath = new List<String>{'https://s3-us-west-2.amazonaws.com/mawafilesfullcopy/00Q5B000001s3bt/a1U5B0000000Df1UAE/MedicalSummaryReport.txt?response-content-disposition=attachment&filename=MedicalSummaryReport.txt&AWSAccessKeyId=AKIAIEYUJRAAMNE7W7NA&Expires=1509032442&Signature=Yx0UX2ADZxo9GbbDFH+q7opBzwU='};
                for(Lead_File__c collectedFileRec : leadFileList){
                    for(String filePath : leadFilePath){
                        if(filePath.contains(collectedFileRec.Id)){
                            collectedFileRec.File_Path__c = filePath;
                        }
                    }
                }
        update leadFileList;
    }
    
    //This method is used to create a task for chapter staff to review attachments whenever file is uploaded by volunter for wish
    public static void  createAttachmentReviewTask(Map<Id, cg__CaseFile__c> caseFileMap){
        
        Constant_AC  constant = new Constant_Ac();    
        Id parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
        Set<Id> caseIdsSet = new Set<Id>();
        Set<Id> caseFileIdSet = new Set<Id>();
        Map<Id,Id> caseOwnerMap = new Map<Id, Id>();
        
        List<cg__CaseFile__c> caseFileList = [SELECT Id,cg__Case__c, cg__Case__r.RecordTypeId FROM cg__CaseFile__c WHERE cg__Case__r.RecordTypeId =: parentWishRecordTypeId AND Id IN : caseFileMap.keySet()];
        
        if(caseFileList.size() > 0) {
            for(cg__CaseFile__c caseFile : caseFileList) {
                caseIdsSet.add(caseFile.cg__Case__c);
                caseFileIdSet.add(caseFile.Id);
            }  
        }
      
        if(caseIdsSet.size() > 0) {
            for(Case caseOwner : [SELECT Id, RecordTypeId, OwnerId FROM Case WHERE RecordTypeId =: parentWishRecordTypeId AND Id IN : caseIdsSet]) {
                caseOwnerMap.put(caseOwner.Id, caseOwner.OwnerId);
            }
        }
        
        Set<Id> reviewPhotosSet = new Set<Id>();
        if(caseIdsSet.size() > 0) {
            for(Task getTask : [SELECT Id, WhatId FROM Task WHERE WhatId IN : caseIdsSet AND Subject = 'Review photos/videos']) {
                reviewPhotosSet.add(getTask.WhatId);
            }
        }
        
        List<Task> reviewTaskList = new List<Task>();
        for(cg__CaseFile__c createTask : caseFileList) {
            if(!reviewPhotosSet.contains(createTask.cg__Case__c)) {
                Task reviewTask = new Task();
                reviewTask.Subject = 'Review photos/videos';
                reviewTask.WhatId = createTask.cg__Case__c;
                reviewTask.ActivityDate = System.today().addDays(10);
                if(caseOwnerMap.containsKey(createTask.cg__Case__c)) {
                    reviewTask.OwnerId = caseOwnerMap.get(createTask.cg__Case__c);
                }
                reviewTaskList.add(reviewTask);
            }
        }
        if(reviewTaskList.size() > 0) {
            insert reviewTaskList;
        }        
    }
    
    //This method is used to populate child related information in case file.
    public static void  populateRelatedInfo(Set<Id> casFileIdSet, List<cg__CaseFile__c> caseFileList){
        System.debug('>>>Function Initiated>>');
        Constant_AC  constant = new Constant_Ac();    
        Id parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
        
        Map<Id,Case> caseInfoMap = new Map<Id, Case>();
        
        for(Case caseInfo : [SELECT Id, Contact.Name, Contact.Gender__c, Contact.Current_Age__c, Wish_Type__c, Start_Date__c, Hidden_Primary_Diagnosis__c FROM Case WHERE Id IN : casFileIdSet AND RecordTypeId =: parentWishRecordTypeId]) {
            caseInfoMap.put(caseInfo.Id, caseInfo);
        }
        System.debug('>>>caseInfoMap>>'+caseInfoMap);
        for(cg__CaseFile__c populateChildInfo : caseFileList) {
            System.debug('RecIt>>>>>>>>');
            if(caseInfoMap.containsKey(populateChildInfo.cg__Case__c)) {
                System.debug('Contains Key>>>>>>>>');
                populateChildInfo.Age__c = String.valueOf(caseInfoMap.get(populateChildInfo.cg__Case__c).Contact.Current_Age__c);
                populateChildInfo.Primary_Diagnosis__c = caseInfoMap.get(populateChildInfo.cg__Case__c).Hidden_Primary_Diagnosis__c;
                populateChildInfo.Gender__c = caseInfoMap.get(populateChildInfo.cg__Case__c).Contact.Gender__c;
                populateChildInfo.Wish_Type__c = caseInfoMap.get(populateChildInfo.cg__Case__c).Wish_Type__c;
                populateChildInfo.Child_Name__c = caseInfoMap.get(populateChildInfo.cg__Case__c).Contact.Name;
                populateChildInfo.Wish_Date__c = String.valueOf(caseInfoMap.get(populateChildInfo.cg__Case__c).Start_Date__c);
            }
            
        }
        
    }
    
}