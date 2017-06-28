public class WishChildSummary_AC{
    
    public Case currentParentCase{get;set;}
    public List<SelectOption> multiPickoptions {get;set;}       
    Public String medicalProfContactName{get;set;}
    Constant_AC  constant = new Constant_AC();
    public Map<String,String> medicalProfConMap; 
    public String email{get;set;}
    public boolean dis{get;set;}
    public boolean displayReturnToWish{get;set;} 
    Public Id MedicalProfContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.MedicalProfessionalRT).getRecordTypeId();
    public WishChildSummary_AC(ApexPages.StandardController controller){
     dis = true;
    currentParentCase = [SELECT Id,ContactId,Description,Contact.Hidden_Medical_Physician__c,Rush__c,IsRushChildSummary__c,Contact.Hidden_Medical_Physician_Email__c,wish_involves_air_travel__c FROM Case WHERE Id =: ApexPages.currentPage().getParameters().get('id')];
     
    }
   
   public List<SelectOption> getMedicalProContact(){
       medicalProfConMap = new Map<String,String>();
       List<SelectOption> options = new List<SelectOption>();
        for(npe4__Relationship__c dbRelationShip  : [Select Id,npe4__Contact__c,npe4__RelatedContact__c,npe4__RelatedContact__r.Name,npe4__RelatedContact__r.Email,
                                                     npe4__RelatedContact__r.RecordTypeId FROM npe4__Relationship__c WHERE npe4__Contact__c =:currentParentCase.ContactId AND npe4__RelatedContact__r.RecordTypeId =:MedicalProfContactRecordTypeId]){
       
           options.add(new SelectOption(dbRelationShip.npe4__RelatedContact__r.Name,dbRelationShip.npe4__RelatedContact__r.Name));
           medicalProfConMap.Put(dbRelationShip.npe4__RelatedContact__r.Name,dbRelationShip.npe4__RelatedContact__r.Email); 
       }
    
     return options;
    }
    
    public void displayEmail(){
        if(medicalProfConMap.get(medicalProfContactName) != Null){
        dis = true;
        email = medicalProfConMap.get(medicalProfContactName);
        }
        
    }
     public void ReturnToWish(){
        displayReturnToWish = true;
    }
    public pageReference ReturnToWishClearanceForm(){
     PageReference reference=new PageReference('/apex/WishChildSummary_VF?id='+currentParentCase.id);
        reference.setRedirect(true);     
        return reference;
    }
    
    public void SendtoDocuSign(){
        
        if(currentParentCase.wish_involves_air_travel__c == Null ||currentParentCase.Description == Null ){
            DisplayErrorMessage();
        }
        
        else if(medicalProfConMap.get(medicalProfContactName) == Null){
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
           updatecase.Child_s_Medical_Summary_sent__c = system.today();
           update updatecase;
           if(!Test.isRunningTest())
           CallouttoDocusign(updateCase.Id,medicalProfContactName,email);
           DisplayMessage();
        }
        // return wrapInst.status;
    }
    
    @future(Callout = true)
    public static void CallouttoDocusign(Id caseId,String conName,String conEmail){
       Case currentParentCase = [SELECT Id,ContactId,Contact.Hidden_Medical_Physician__c,wish_involves_air_travel__c,Contact.Hidden_Medical_Physician_Email__c,Rush__c FROM Case WHERE Id =: caseId];
       
            String account;
            String UserName;
            String Password;
            String IntegratorKey;
            String endPointURL;
            String templateID;
            Map<String,DocuSignCredentialsSetting__c> credentialSetting = DocuSignCredentialsSetting__c.getAll();
            String  name = conName;
            String  email = conEmail;
            String subject;
            for(DocuSignCredentialsSetting__c credentialIns : credentialSetting.values()){
                UserName = credentialIns.name;
                account = credentialIns.account__c;
                Password = credentialIns.Password__c;
                IntegratorKey  = credentialIns.IntegratorKey__c;
                endPointURL = credentialIns.end_Point__c;
            }
            
            if(currentParentCase.Rush__c  != true){
               templateID = label.ChildMedicalSummary;
               subject = 'Wish Child Medical Summary';
           }
            
           if(currentParentCase.Rush__c  == true){
               templateID = label.Rush_Child_Summary;
                subject = 'RUSH Child Medical Summary';
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
                ' "emailSubject": "'+subject+'",'+
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
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm,'The Wish Child Medical Summary form has been sent successfully.'));
        return null;
    }
    
    public pagereference DisplayErrorMessage(){
        if(currentParentCase.wish_involves_air_travel__c == Null)
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please Select Wish Involves Air Travel'));
        if(currentParentCase.Description == Null )
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please add a value to Description on the case page.'));
        if(medicalProfConMap.get(medicalProfContactName) == Null)
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'The selected user does not have email address.'));
        return null;
    }
    
}