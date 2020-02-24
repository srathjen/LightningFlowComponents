/***************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kesavakumar Murugesan
Date        : 12/21/2016
Description : Used to pull DV_Form attachment from Docusign Status to Wish Child Contact
*****************************************************************************************************/
public class DocusignStatusTriggerHandler {

    //Used to get Medical Professional signed DV_Form from Docusign Status record and to store that under related Wish Child
    public static void WishChildDVAttachment(Map<Id, Id> contactDocusignMap) {

        Id wichChildRecordTypeId = Constant_AC.CONTACT_WISH_CHILD_RT_ID;
        
        List<Attachment> newDVAttachmentList = new List<Attachment>(); //Holds DV_Form which is signed by Medical Professional
        Map<Id, Attachment> docusignAttachmentMap = new Map<Id, Attachment>(); //Holds Docusign Status record attachments
        Set<Id> newWishChildContactSet = new Set<Id>(); // Hold Wish Child contacts Id
        
        //Used to check whether Docusign Status is related to Wish Child Contact
        for(Contact checkWishChildContact : [SELECT Id FROM Contact WHERE Id IN : contactDocusignMap.keySet() AND RecordTypeId =: wichChildRecordTypeId]) {
            newWishChildContactSet.add(checkWishChildContact.Id);
        }
        
        if(newWishChildContactSet.size() > 0) {
            
            //Get all Attachment form Docusign Status Record
            for(Attachment dvAttachment : [SELECT Id,Name,body,ParentId FROM Attachment WHERE ParentId IN : contactDocusignMap.values()]) {
                docusignAttachmentMap.put(dvAttachment.ParentId, dvAttachment);
            } 
            
            //Insert 'DV_Form' attachment under Wish Child Record whish is signed by Medical Professional
            for(Id insertAttachment : newWishChildContactSet) { 
                if(contactDocusignMap.containsKey(insertAttachment)) {
                    if(docusignAttachmentMap.containsKey(contactDocusignMap.get(insertAttachment))) {
                        Attachment newDVAttachment = new Attachment();
                        newDVAttachment.Name = 'DV_Form.pdf';
                        newDVAttachment.Body = docusignAttachmentMap.get(contactDocusignMap.get(insertAttachment)).Body;
                        newDVAttachment.ParentId = insertAttachment;
                        newDVAttachmentList.add(newDVAttachment);
                    }
                }
            }  
            if(newDVAttachmentList.size() > 0) {
                insert newDVAttachmentList; // To insert 'DV_Form' under Wish Child Contact
            }
        }
    }
}