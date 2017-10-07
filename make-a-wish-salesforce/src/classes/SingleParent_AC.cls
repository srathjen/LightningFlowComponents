public class SingleParent_AC{
    
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
    public SingleParent_AC(ApexPages.StandardController controller){
        i = 1;
        recpEmail = '';
        recpRelType = '';
        relationShipMap = new Map<Id,npe4__Relationship__c>();
        name = '';
        currentParentCase = [SELECT Id,ContactId FROM Case WHERE Id =: ApexPages.currentPage().getParameters().get('id')];
    }
    
    //Display the list of parent Legal Guardian
    public List<SelectOption> getRecpList() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','Please select an individual'));
        for(npe4__Relationship__c dbParentRec : [SELECT Id,npe4__Contact__c,npe4__RelatedContact__c,npe4__RelatedContact__r.Name,npe4__RelatedContact__r.Email,npe4__Type__c FROM npe4__Relationship__c WHERE npe4__Contact__c =: currentParentCase.ContactId
                                                 AND (npe4__Type__c = 'Father' OR npe4__Type__c = 'Mother' OR npe4__Type__c = 'Legal Guardian')]){
                                                     relationShipMap.put(dbParentRec.Id, dbParentRec);
                                                     options.add(new SelectOption(dbParentRec.Id,dbParentRec.npe4__RelatedContact__r.Name));
                                                 }
        
        
        return options;
    }
    
    //Used to retun to wish when "Ruturn to Link" link is clicked
    public void ReturnToWish(){
        displayReturnToWish = true;
    }
    
    //Used to redirect to Single Parent Form
    public pageReference ReturnToSingleForm(){
        PageReference reference=new PageReference('/apex/SingleForm_VF?id='+currentParentCase.id);
        reference.setRedirect(true);     
        return reference;
    }
    
    //Used to update recepient name in the related contact
    public void updateRelatedContact() {
        if(String.isEmpty(recpName)) {
            displayErrorMessage();
        } else  {
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
            String templateID = label.SingleForm;
            Integer i = 1;
            String emailbody = relationShipMap.get(recpName).npe4__RelatedContact__r.Name;
            emailbody= emailbody+'\n\n Please sign the attached Single Parent Forms \r\n\n Thank You, \n\n Wish & Volunteer Center';
            Map<String,DocuSignCredentialsSetting__c> credentialSetting = DocuSignCredentialsSetting__c.getAll();
            for(DocuSignCredentialsSetting__c credentialIns : credentialSetting.values()){
                UserName = credentialIns.name;
                account = credentialIns.account__c;
                Password = credentialIns.Password__c;
                IntegratorKey  = credentialIns.IntegratorKey__c;
                endPointURL = credentialIns.end_Point__c;
            }
            
            String endpoint = endPointURL+'/accounts/'+account+'/envelopes';
            system.debug('### endpoint #####'+endpoint );
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
                '"emailSubject": "Signature Required - Single Parent Form",'+
                '"emailBody": "'+relationShipMap.get(recpName).npe4__RelatedContact__r.Name+emailbody+'",'+
                '"supportedLanguage": "en",'+
                '"recipientId": '+i+''+ 
                '}';
            
            recipient = recipient+',';
            system.debug('@@@@@@ recipient @@@@@@'+recipient);
            String json='{'+ 
                ' '+ 
                ' "emailSubject": "Signature Required - Single Parent Form",'+
                '"emailBody": "'+emailbody+'",'+
                ' "emailBlurb": "'+emailbody+'",'+ 
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
            system.debug('@@@@@@ json @@@@@@'+json);
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
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm,'The single parent form has been sent successfully.'));
        return null;
    }
    
    //Display error message
    public pagereference displayErrorMessage(){
        if(String.isEmpty(recpName)) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm,'Recepient cannot be null.'));
        } else if(String.isEmpty(recpEmail)) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm,'The selected user does not have an email address.'));
        }
        return null;
    }
    
}