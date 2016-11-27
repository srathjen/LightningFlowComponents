/*****************************************************************************************************************
Author      : MST Solutions
Date        : 11/17/2016
Description : This class is used to send email with medical summary report & medical summary attachment to MAC team
*******************************************************************************************************************/
global class SendEmailToMacTeam_AC {
    
    
    webservice static String sendEmailToMac(Id caseOwnerId, Id leadId, Id caseId, String caseStatus, string Email) {
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
        if(!Test.isRunningTest())
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { emailMessage });
        return 'Sucess';
    }
    
    
    public static void sendEmail (Map<Id,List<Attachment>> docusignAttachmentMap, String sendToTeam, Id targetObjectId, String emailTo, Id caseId) {
        System.debug('>>>>>>docusignAttachmentMap>>>>>>'+docusignAttachmentMap);
        System.debug('>>>>>>sendToTeam>>>>>>'+sendToTeam);
        System.debug('>>>>>>targetObjectId>>>>>>'+targetObjectId);
        System.debug('>>>>>>emailTo>>>>>>'+emailTo);
        System.debug('>>>>>>caseId>>>>>>'+caseId);
        
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
        if(!Test.isRunningTest())
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { emailMessage });
    }
}