/*****************************************************************************************************************
Author      : MST Solutions
Date        : 11/17/2016
Description : This class is used to send email with medical summary report & medical summary attachment to MAC team
*******************************************************************************************************************/
global class SendEmailToMacTeam_AC {
    
    webservice static String sendEmailToMac(Id caseOwnerId, Id leadId, Id caseId, String caseStatus) {
        Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();
        if(caseStatus == 'Local') {
            //emailMessage.setTemplateId('00X5B000000De50');
            //Replace the above using custom setting
        } else if(caseStatus == 'National') {
            //emailMessage.setTemplateId('00X5B000000De4z');
            ////Replace the above using custom setting
        }
        emailMessage.setTargetObjectId(caseOwnerId);
        emailMessage.setwhatId(caseId);
        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
        List<dsfs__DocuSign_Status__c> docusignStatusObjList = [SELECT Id, dsfs__Envelope_Status__c, dsfs__Lead__c FROM dsfs__DocuSign_Status__c WHERE dsfs__Envelope_Status__c = 'Completed' AND dsfs__Lead__c =: leadId ORDER BY CreatedDate DESC LIMIT 1];
        //Used to get medical summary and medical report attachment
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
}