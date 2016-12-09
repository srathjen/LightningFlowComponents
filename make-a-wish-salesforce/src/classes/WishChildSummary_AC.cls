public class WishChildSummary_AC{
    
    public Case currentParentCase{get;set;}
    
    public WishChildSummary_AC(ApexPages.StandardController controller){
    
    currentParentCase = [SELECT Id,ContactId,Description,Contact.Hidden_Medical_Physician__c,Contact.Hidden_Medical_Physician_Email__c FROM Case WHERE Id =: ApexPages.currentPage().getParameters().get('id')];
     
    }
   
    public void SendtoDocuSign(){
        if(currentParentCase.Description == Null ){
            DisplayErrorMessage();
        }
        else{
        case updatenewCase = new Case();
        updatenewCase.Id = currentParentCase.Id;
        updatenewCase.Child_s_Medical_Summary_sent__c = system.today();
        updatenewCase.Emergency_Number__c = Null;
        updatenewCase.Date_of_last_visit_treatment__c = Null;
        updatenewCase.Child_s_Medical_Summary_received_date__c = Null;
        update updatenewCase;
        CallOuttoDocusign(updatenewCase.Id);
        DisplayMessage();
      }
    }
    @future(Callout=true)
    public static void CallOuttoDocusign(Id caseId){
       case currentParentCase = [SELECT Id,ContactId,Contact.Hidden_Medical_Physician__c,Contact.Hidden_Medical_Physician_Email__c FROM Case WHERE Id =: caseId];
        String account;
        String UserName;
        String Password;
        String IntegratorKey;
        String endPointURL;
        String templateID = label.ChildMedicalSummary;
        system.debug('### templateId #####'+templateID);
        Map<String,DocuSignCredentialsSetting__c> credentialSetting = DocuSignCredentialsSetting__c.getAll();
        String  name = currentParentCase.Contact.Hidden_Medical_Physician__c;
        String email = currentParentCase.Contact.Hidden_Medical_Physician_Email__c;
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
        String json='{'+ 
                ' '+ 
                ' "emailSubject": "Wish Child Summary Form",'+ 
                ' "emailBlurb": "MAKE A WISH AMERICA",'+ 
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
                ' "templateRoles": ['+ 
                '{'+ 
                '"roleName": "Signer 1",'+ 
                '"name": "'+name+'",'+ 
                '"email": "'+email+'",'+ 
                '"recipientId": "1"'+ 
                '}'+ 
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
       
    }
    
       public pageReference cancel(){
          PageReference reference=new PageReference('/'+currentParentCase.Id);
          reference.setRedirect(true);     
          return reference;
    
       }
    
     public pagereference DisplayMessage(){
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm,'The wish child summary form has been successfully sent.'));
        return null;
    }
    
     public pagereference DisplayErrorMessage(){
        if(currentParentCase.Description == Null )
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm,'Please give the value to Description'));
        return null;
    }
    
}