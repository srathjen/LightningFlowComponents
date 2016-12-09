/*****************************************************************************************************************
Author      : MST Solutions
Date        : 11/17/2016
Description : This class is used to send email with medical summary report & medical summary attachment to MAC team
*******************************************************************************************************************/
global class SendEmailToMacTeam_AC {
    

    webservice  static String UpdateEmail(Id chapterAccountId,Id caseId){
        Map<Id,String> accountMap = new Map<Id,String>();
        List<Case> partAcaseList = new List<Case>();
       
        for(Account chapterAccount : [SELECT Id,MAC_Email__c FROM Account WHERE Id =: chapterAccountId AND MAC_Email__c  != Null]){
        accountMap.put(chapterAccount.Id,chapterAccount.MAC_Email__c );
        }
        
        if(accountMap.size() > 0){
            for(Case partACase : [SELECT Id,AccountId,MAC_Email__c FROM Case WHERE Id =: caseId]){
                if(accountMap.containsKey(partACase.AccountId)){
                  case newCase = new Case();
                   newCase.Id = partACase.Id; 
                   newCase.MAC_Email__c = accountMap.get(partACase.AccountId); 
                   partAcaseList.add(newCase);
                }
            }
        }  
        if(partAcaseList.size() > 0)
        update partAcaseList;
        system.debug('####### MAC EMAIL ######'+partAcaseList);
       return partAcaseList[0].MAC_Email__c ;   
    }
    
    webservice static String sendEmailToMac(Id caseOwnerId, Id leadId, Id caseId, String caseStatus, string Email) {
        //Id OrgId = '0D25B00000000cF';
        String organizationWideLabel=System.Label.OrganizationWideEmail;        
        ORGWIDEEMAILADDRESS  OrgId = [SELECT id,Address FROM ORGWIDEEMAILADDRESS WHERE Address =: organizationWideLabel LIMIT 1];       
      
                
        string nationalTeamTemplateID = Label.National_Email_Template_ID;
        string localTeamTemplateId = Label.Local_Email_Template_ID;
        list<String> emailSet = new list<String>();
        emailSet.add(Email);
        string emailTemplateId;
        Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();
        if(caseStatus == 'Local') {
            emailMessage.setTemplateId(localTeamTemplateId); //Replace this using custom setting
        } else if(caseStatus == 'National') {
            emailMessage.setTemplateId(nationalTeamTemplateID); //Replace this using custom setting
            
        }
        emailMessage.setOrgWideEmailAddressId(OrgId.id);
        emailMessage.setTargetObjectId(caseOwnerId);
        emailMessage.setTreatTargetObjectAsRecipient(False);
        emailMessage.setToAddresses(emailSet); 
        emailMessage.setwhatId(caseId);
        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
        // List<Case> caseList = [SELECT Id,Medical_Summary_Attachments__c FROM Case WHERE ID =: caseId];
        List<dsfs__DocuSign_Status__c> docusignStatusObjList = [SELECT Id, dsfs__Envelope_Status__c, dsfs__Lead__c FROM dsfs__DocuSign_Status__c WHERE dsfs__Envelope_Status__c = 'Completed' AND dsfs__Lead__c =: leadId ORDER BY CreatedDate DESC LIMIT 1];

        if(docusignStatusObjList.size() > 0) {
            for (Attachment caseAttachment : [select Name, Body, BodyLength from Attachment where ParentId =: docusignStatusObjList[0].Id]) {
                Messaging.Emailfileattachment emailAttachment = new Messaging.Emailfileattachment();
                emailAttachment.setFileName(caseAttachment.Name);
                emailAttachment.setBody(caseAttachment.Body);
                fileAttachments.add(emailAttachment);
            }
        }
        emailMessage.setFileAttachments(fileAttachments);
        emailMessage.setSaveAsActivity(false);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { emailMessage });
        return 'Sucess';
    }
    
    
    public static void sendEmail (Map<Id,List<Attachment>> docusignAttachmentMap, String sendToTeam, Id targetObjectId, String emailTo, Id caseId) {
       
        //Id OrgId = '0D25B00000000cF';
         String organizationWideLabel=System.Label.OrganizationWideEmail;
         ORGWIDEEMAILADDRESS  OrgId = [SELECT id,Address FROM ORGWIDEEMAILADDRESS WHERE Address =: organizationWideLabel LIMIT 1]; 
         
        string nationalTeamTemplateID = Label.National_Email_Template_ID;
        string localTeamTemplateId = Label.Local_Email_Template_ID;
        list<String> emailSet = new list<String>();
        emailSet.add(emailTo);
        string emailTemplateId;
        Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();
        if(sendToTeam == 'Local') {
            emailMessage.setTemplateId(localTeamTemplateId);
        } else if(sendToTeam == 'National') {
            emailMessage.setTemplateId(nationalTeamTemplateID);
            
        }
        emailMessage.setTargetObjectId(targetObjectId);
        emailMessage.setTreatTargetObjectAsRecipient(False);
        emailMessage.setToAddresses(emailSet);
        emailMessage.setOrgWideEmailAddressId(OrgId.id);
        emailMessage.setwhatId(caseId);
        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
        if(docusignAttachmentMap.containsKey(caseId)) {
            for (Attachment caseAttachment : docusignAttachmentMap.get(caseId)) {
                Messaging.Emailfileattachment emailAttachment = new Messaging.Emailfileattachment();
                emailAttachment.setFileName(caseAttachment.Name);
                emailAttachment.setBody(caseAttachment.Body);
                fileAttachments.add(emailAttachment);
            }
        }
        emailMessage.setFileAttachments(fileAttachments);
        emailMessage.setSaveAsActivity(false);
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { emailMessage });
    }
}