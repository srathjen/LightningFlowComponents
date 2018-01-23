/*****************************************************************************
Author : MST Solutions
CreateDate : 09/27/2017
Description : Entertainment_AC is used send the document to get the signature from parent legal guardian.
******************************************************************************/
public class Entertainment_AC{
    
    public Case currentParentCase{get;set;}
    Public Map<Integer,String> parentNameMap = new Map<Integer,String>();
    Public Map<Integer,String> parentEmailMap = new Map<Integer,String>();
    public Integer i;
    public String name{get;set;}
    public boolean displayReturnToWish{get;set;} 
    public String recpName {get;set;}
    public Map<Id,npe4__Relationship__c> relationShipMap;
    Public String recpEmail {get;set;}
    Public String recpRelType {get;set;}
    public Entertainment_AC(ApexPages.StandardController controller){
        recpEmail = '';
        recpRelType = '';
        relationShipMap = new Map<Id,npe4__Relationship__c>();
        name = '';
        currentParentCase = [SELECT Id,ContactId FROM Case WHERE Id =: ApexPages.currentPage().getParameters().get('id')];
        i = 1;
        
    }
    
    //Used to retun to wish when "Ruturn to Link" link is clicked
    public void ReturnToWish(){
        displayReturnToWish = true;
    }
    //Redirect to Absent form
    public pageReference ReturnToWishClearanceForm(){
        PageReference reference=new PageReference('/apex/Entertainment_VF?id='+currentParentCase.id);
        reference.setRedirect(true);     
        return reference;
    }
    
    //Display the list of parent Legal Guardian
    public List<SelectOption> getRecpList() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','Please select an individual'));
        for(npe4__Relationship__c dbParentRec : [SELECT Id,npe4__Contact__c,npe4__RelatedContact__c,npe4__RelatedContact__r.Name,npe4__RelatedContact__r.Email,npe4__Type__c,Parent_Legal_Guardian__c FROM npe4__Relationship__c WHERE npe4__Contact__c =: currentParentCase.ContactId
                                                 AND Parent_Legal_Guardian__c =: true]){
                                                     relationShipMap.put(dbParentRec.Id, dbParentRec);
                                                     options.add(new SelectOption(dbParentRec.Id,dbParentRec.npe4__RelatedContact__r.Name));
                                                 }
        
        
        return options;
    }
    
    //Used to update recepient name in the related contact
    public void updateRelatedContact() {
        if(String.isEmpty(recpName)) {
            displayErrorMessage();
        } else {
            List<Contact> wishChildContact = [SELECT Id, RelatedContacts__c FROM Contact WHERE Id =: currentParentCase.ContactId];
            if(wishChildContact.size() > 0) {
                wishChildContact[0].RelatedContacts__c = relationShipMap.get(recpName).npe4__RelatedContact__r.Name;
                update wishChildContact;
            }
        }
    }
    
    //Docusign callout
    public  void CallouttoDocusign(){
        if(String.isEmpty(recpName) || String.isEmpty(recpEmail)) {
            displayErrorMessage();
        } else {
            String account;
            String UserName;
            String Password;
            String IntegratorKey;
            String endPointURL;
            String templateID = label.Celebritywish;
            String clientUserId;
            String  emailbody='\n\n Please sign the attached Entertainment And Sports Wish LOU form\r\n\n\n Thank You,\n Wish & Volunteer Center';
            
            Map<String,DocuSignCredentialsSetting__c> credentialSetting = DocuSignCredentialsSetting__c.getAll();
            for(DocuSignCredentialsSetting__c credentialIns : credentialSetting.values()){
                UserName = credentialIns.name;
                account = credentialIns.account__c;
                Password = credentialIns.Password__c;
                IntegratorKey  = credentialIns.IntegratorKey__c;
                endPointURL = credentialIns.end_Point__c;
            }
            
            String endpoint = endPointURL+'/accounts/'+account+'/envelopes';
            
            String authorizationHeader = '<DocuSignCredentials><Username>'+UserName+'</Username><Password>'+Password+'</Password><IntegratorKey>'+IntegratorKey+'</IntegratorKey></DocuSignCredentials>';
            HttpRequest req = new HttpRequest(); 
            req.setEndpoint(endPoint); 
            req.setMethod('POST'); 
            req.setHeader('X-DocuSign-Authentication', authorizationHeader); 
            req.setHeader('Accept','application/json'); 
            req.setHeader('Content-Length','162100'); 
            req.setHeader('Content-Type','application/json'); 
            req.setHeader('Content-Disposition','form-data'); 
            String recipient = '';
            
            recipient = recipient + '{'+ 
                '"roleName": "'+'Signer'+i+'",'+ 
                '"name": "'+relationShipMap.get(recpName).npe4__RelatedContact__r.Name+'",'+ 
                '"email": "'+relationShipMap.get(recpName).npe4__RelatedContact__r.Email+'",'+ 
                '"emailSubject": "Signature Required - Entertainment And Sports Wish LOU Form",'+
                '"emailBody": "'+relationShipMap.get(recpName).npe4__RelatedContact__r.Name+emailbody+'",'+ 
                '"supportedLanguage": "en",'+
                '"recipientId": '+i+''+ 
                '}';
            
            recipient = recipient+',';
            
            system.debug('@@@@@@ recipient @@@@@@'+recipient);
            String json='{'+ 
                ' '+ 
                ' "emailSubject": "Signature Required - Entertainment And Sports Wish LOU",'+
                '"emailBody": "'+emailbody+'",'+
                ' "templateId": "'+templateID+'",'+ 
                ' "envelopeIdStamping": "false",'+ 
                ' "customFields":{'+
                '    "textCustomFields":['+
                '      {'+
                '        "name":"##SFCase",'+
                '        "required":"true",'+
                '        "show":"false",'+
                '        "value":"'+currentParentCase.Id+'"'+
                '      }'+
                '    ]'+
                '  },'+
                ' "templateRoles": ['+ recipient+
                ' ],'+ 
                ' "status": "sent"'+ 
                '}'; 
            
            req.setBody(json); 
            Http http = new Http(); 
            HTTPResponse res; 
            try{ 
                
                res = http.send(req); 
                system.debug('DocuSign Response'+ res.getBody()); 
            } 
            catch(Exception e){ 
                ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.FATAL, e.getMessage())); 
            } 
            WrapperDocuSign wrapInst = WrapperDocuSign.parse(res.getBody()); 
            
            DisplayMessage();
        }
        
    }
    
    //Skip send for signature
    public pageReference cancel(){
        PageReference reference=new PageReference('/'+currentParentCase.Id);
        reference.setRedirect(true);     
        return reference;
        
    }
    
    //Display related contact info in the page
    public void displayRelatedInfo() {
        if(relationShipMap.containsKey(recpName)) {
            recpRelType = relationShipMap.get(recpName).npe4__Type__c;
            recpEmail = relationShipMap.get(recpName).npe4__RelatedContact__r.Email;
        } else {
            recpRelType = '';
            recpEmail = '';
        }
    }
    
    //Success message
    public pagereference DisplayMessage(){
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm,'The Entertainment And Sports Wish LOU form has been sent successfully.'));
        return null;
    }
    
    //Display error message
    public pagereference displayErrorMessage(){
        if(String.isEmpty(recpName)) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm,'Recepient cannot be null.'));
        } else if(String.isEmpty(recpEmail)) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm,'The contact you have selected has no email address available. Please add email on the contact record and try to send the form again.'));
        }
        return null;
    }
    
}