/* This WishClearanceSendNow_AC class is used to send the wish clearance form.
This wish clearance form is sent to treating medical contact. This contact is updat information 
about wish child.*/
public class WishClearanceSendNow_AC{
    
    public Case currentParentCase{get;set;}
    
    public WishClearanceSendNow_AC(ApexPages.StandardController controller){
        
        currentParentCase = [SELECT Id,ContactId,Description,Contact.Hidden_Medical_Physician__c,wish_involves_air_travel__c,Contact.Hidden_Medical_Physician_Email__c FROM Case WHERE Id =: ApexPages.currentPage().getParameters().get('id')];
        
    }
    
    public void SendtoDocuSign(){
        
        if(currentParentCase.wish_involves_air_travel__c == Null ||currentParentCase.Description == Null ){
            DisplayErrorMessage();
        }
        else{
           case updatecase = new Case();
           updatecase.Id = currentParentCase.Id;
           updatecase.wish_involves_air_travel__c = currentParentCase.wish_involves_air_travel__c;
           updatecase.Emergency_Number__c = Null;
           updatecase.Appropriate_Comments__c = Null;
           updatecase.Please_Explain__c = Null;
           updatecase.Date_of_last_visit_treatment__c = Null;
           updatecase.Comments__c = Null;
           updatecase.Comment_1__c = Null;
           updatecase.Comment_2__c = Null;
           updatecase.Wish_Clearance_Sent_Date__c = system.today();
           update updatecase;
           CallouttoDocusign(updateCase.Id);
           DisplayMessage();
        }
        // return wrapInst.status;
    }
    
    @future(Callout = true)
    public static void CallouttoDocusign(Id caseId){
       Case currentParentCase = [SELECT Id,ContactId,Contact.Hidden_Medical_Physician__c,wish_involves_air_travel__c,Contact.Hidden_Medical_Physician_Email__c FROM Case WHERE Id =: caseId];
         system.debug('@@@@@@@@@@@@ currentParentCase  @@@@@@@@@@@@@@'+currentParentCase.wish_involves_air_travel__c);
         String account;
            String UserName;
            String Password;
            String IntegratorKey;
            String endPointURL;
            String templateID = label.WishClearence;
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
                ' "emailSubject": "Wish Clearance Form",'+ 
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
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm,'The wish clearence form has been successfully sent.'));
        return null;
    }
    
    public pagereference DisplayErrorMessage(){
        if(currentParentCase.wish_involves_air_travel__c == Null)
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm,'Please Select Wish Involves Air Travel'));
        if(currentParentCase.Description == Null )
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm,'Please give the value to Description'));
        return null;
    }
}