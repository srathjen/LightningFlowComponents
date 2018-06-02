/*****************************************************************************
Author : MST Solutions
CreateDate : 03/25/2016
Description : AbsentForm_AC is used send the Absent Form document to get the signature from parent legal guardian.
******************************************************************************/
public class AbsentParentSingleParentForm_AC{
    
    public Case currentParentCase{get;set;}
    Public Map<Integer,String> parentNameMap = new Map<Integer,String>();
    Public Map<Integer,String> parentEmailMap = new Map<Integer,String>();
    public Integer i;
    public String name{get;set;}
    Public List<String> participantNameList{get;set;}
    public boolean displayReturnToWish{get;set;} 
    public String recpName {get;set;}
    public Map<Id,npe4__Relationship__c> relationShipMap;
    Public String recpEmail {get;set;}
    Public String recpRelType {get;set;}
    public string individualName {get;set;}
    public string individualEmail {get;set;}
    public boolean allowCallout;
    public String participantName;
    public String templateID;
    public String subject;
    Public String pageName;
    
    public AbsentParentSingleParentForm_AC(ApexPages.StandardController controller){
        recpEmail = '';
        recpRelType = '';
        relationShipMap = new Map<Id,npe4__Relationship__c>();
        name = '';
        currentParentCase = [SELECT Id,ContactId,Contact.name,ChapterName__r.Name FROM Case WHERE Id =: ApexPages.currentPage().getParameters().get('id')];
        i = 1;
        pageName = ApexPages.currentPage().getParameters().get('option');
        If(pageName == 'Single_Vf'){
            templateID = label.SingleForm;
            subject = 'Signature Required - Single Parent Form';
        }
        If(pageName == 'Absent_Vf'){
           templateID = label.AbsentForm;
           subject = 'Signature Required - Absent Parent Form';
        }
        
    } 
    
    //Used to retun to wish when "Ruturn to Link" link is clicked
    public void ReturnToWish(){
        displayReturnToWish = true;
    }
    //Redirect to Absent form
    public pageReference ReturnToWishClearanceForm(){
        PageReference reference;
        if(pageName == 'Single_Vf'){
        reference=new PageReference('/apex/SingleForm_VF?id='+currentParentCase.id);
        }
        if(pageName == 'Absent_Vf'){
        reference=new PageReference('/apex/AbsentForm_VF?id='+currentParentCase.id);
        }
        reference.setRedirect(true);     
        return reference;
    }
    
    //Display the list of parent Legal Guardian
    public List<SelectOption> getRecpList() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','Please select an individual'));
        for(npe4__Relationship__c dbParentRec : [SELECT Id,npe4__Contact__c,npe4__RelatedContact__c,npe4__RelatedContact__r.Name,npe4__RelatedContact__r.Email,npe4__Type__c,Under_18__c,Wish_Participant__c,Parent_Legal_Guardian__c  FROM npe4__Relationship__c WHERE npe4__Contact__c =: currentParentCase.ContactId ]){
                                                   system.debug('@@@ dbParentRec @@@'+dbParentRec); 
                                                    if(dbParentRec.Parent_Legal_Guardian__c  == true){
                                                     relationShipMap.put(dbParentRec.Id,dbParentRec);
                                                     options.add(new SelectOption(dbParentRec.Id,dbParentRec.npe4__RelatedContact__r.Name));
                                                  }
                                                  
        }
        
        return options;
    }
    
     //Display the list of minor participant
    public List<SelectOption> getParticipantList() {
        List<SelectOption> participantList = new List<SelectOption>();
        for(npe4__Relationship__c dbParentRec : [SELECT Id,npe4__Contact__c,npe4__RelatedContact__c,npe4__RelatedContact__r.Name,npe4__RelatedContact__r.Email,npe4__Type__c,Under_18__c,Wish_Participant__c,Parent_Legal_Guardian__c FROM npe4__Relationship__c WHERE npe4__Contact__c =: currentParentCase.ContactId]){
                                                 if(dbParentRec.Under_18__c == true && dbParentRec.Wish_Participant__c == true){
                                                      participantList.add(new SelectOption(dbParentRec.npe4__RelatedContact__r.Name,dbParentRec.npe4__RelatedContact__r.Name));
                                                  }
        }
        participantList.add(new SelectOption(currentParentCase.contact.Name,currentParentCase.contact.Name));
        return participantList;
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
        if(((String.isEmpty(recpName) && String.isEmpty(recpEmail)) && (String.isEmpty(individualName) && String.isEmpty(individualEmail)) && String.isEmpty(participantName)) ){
            displayErrorMessage();
        }
        else if((String.isEmpty(recpName) || String.isEmpty(recpEmail)) && (String.isEmpty(individualName) || String.isEmpty(individualEmail))) {
            displayErrorMessage();
        } 
        else if(String.isNotEmpty(recpName) && String.isNotEmpty(recpEmail) && String.isNotEmpty(individualName) && String.isNotEmpty(individualEmail)){
            displayErrorMessage();
        }
        else if(String.isNotEmpty(recpName) && String.isEmpty(recpEmail) && String.isNotEmpty(individualName) && String.isNotEmpty(individualEmail)){
            displayErrorMessage();
        }
        else if(String.isNotEmpty(recpName) && String.isNotEmpty(recpEmail) && String.isEmpty(individualName) && String.isNotEmpty(individualEmail)){
            displayErrorMessage();
        }
        else if(String.isNotEmpty(recpName) && String.isNotEmpty(recpEmail) && String.isNotEmpty(individualName) && String.isEmpty(individualEmail)){
            displayErrorMessage();
        }
        else if(String.isEmpty(participantName)){
             displayErrorMessage();
        }
        else {
            String account;
            String UserName;
            String Password;
            String IntegratorKey;
            String endPointURL;
            String clientUserId;
            Map<String,DocuSignCredentialsSetting__c> credentialSetting = DocuSignCredentialsSetting__c.getAll();
            String Name;
            String Email;
            String emailbody;
            
            if(String.isNotEmpty(recpName) && String.isNotEmpty(recpEmail)){
                Name = relationShipMap.get(recpName).npe4__RelatedContact__r.Name;
                Email =relationShipMap.get(recpName).npe4__RelatedContact__r.Email;
                allowCallout = false;
            }
            else if(String.isNotEmpty(individualName) && String.isNotEmpty(individualEmail)){
               Name = individualName;
               Email = individualEmail;
               checkEmail(Email);
            }
            
          String  Absentemailbody= 'Dear'+' '+Name+'\r\n\r\n'+'All of us at'+' '+currentParentCase.ChapterName__r.Name+' '+'look forward to granting'+' '+currentParentCase.Contact.Name+'’s wish!'+'\r\n\r\n'+
            'As a matter of practice, Make-A-Wish® requires that both parents or legal guardians of all minor children participating in a wish sign the required documents. However, where it is not possible to obtain the signature of one biological parent, we may be able to move forward with your signature only, provided you can truthfully sign the enclosed document.'+'\r\n\r\n'+ 
            'The attached Absent Parent Form is a sworn declaration by you, signed under penalties of perjury, certifying that one of the following statements is true of the biological parent of'+' '+participantName+':'+'\r\n\r\t\n\t'+
            
            '    a) You do not know the whereabouts of the other biological'+'\r\n\t\t'+' parent and have no means of contacting him/her;'+'\r\n\t'+
            '    b) The other biological parent is deceased; or  '+'\r\n\t'+
            '    c) The identity of the child’s biological father is unknown'+'\r\n\r\n'+
    
            'If none of the three circumstances described above accurately describes your situation, do not sign the attached Absent Parent Form; instead, please contact'+' '+currentParentCase.ChapterName__r.Name+' '+'so we can discuss the best way to move forward with your child’s wish.'+'\r\n\r\n'+
            
            'Please feel free to contact our office with any questions. I look forward to working with you to grant'+' '+currentParentCase.Contact.Name+'’s wish.'+'\r\n\r\n'+
            'Thank You,'+'\r\n\r\n'+
            currentParentCase.ChapterName__r.Name;
          
          
          String singleEmailBody = 'Dear'+' '+Name+'\r\n\r\n'+'All of us at'+' '+currentParentCase.ChapterName__r.Name+' '+'look forward to granting'+' '+currentParentCase.Contact.Name+'’s wish!'+'\r\n\r\n'+
            'As a matter of practice, the Make-A-Wish Foundation requires that both parents or legal guardians of all minor children participating in a wish sign the required documents. However, where the custodial parent does not want to involve the other biological parent based on concerns for the child’s well being, as you have stated is the case here, we may be able to move forward with your signature only, provided you can truthfully sign the attached document.'+'\r\n\r\n'+ 
            'The attached Single Parent Form is a sworn declaration by you, signed under penalties of perjury, certifying that all of the following statements are true of the following child(ren):'+' '+participantName+'\r\n\r\t'+
            
            '    a) You have been awarded legal custody of the child;'+'\r\n\t'+
            '    b) You have the legal right to make important decisions about'+'\r\n\t\t'+' the child without consultation with and/or approval from'+'\r\n\t\t'+' the child’s other biological parent; and'+'\r\n\t'+
            '    c) You have requested that the Make-A-Wish Foundation'+'\r\n\t\t'+' make an exception to its standard signature requirements,'+'\r\n\t\t'+' and grant your child’s wish or allow your child to'+'\r\n\t\t'+' participate in a wish without the signature of his/her other'+'\r\n\t\t'+' biological parent based on your concerns for your child’s'+'\r\n\t\t'+' well being.'+'\r\n\r\n'+ 
    
            'If at least one of the statements listed above does not accurately describe your situation, do not sign the attached Single Parent Form; instead, please contact'+' '+currentParentCase.ChapterName__r.Name+' '+'so we can discuss the best way to move forward.'+'\r\n\r\n'+
            
            'Please feel free to contact our office with any questions. I look forward to working with you to grant'+' '+currentParentCase.Contact.Name+'’s wish.'+'\r\n\r\n'+
            'Thank You,'+'\r\n\r\n'+
            currentParentCase.ChapterName__r.Name;
            
            if(subject == 'Signature Required - Absent Parent Form'){
             emailbody = Absentemailbody;
            }
            if( subject == 'Signature Required - Single Parent Form'){
             emailbody = singleEmailBody;
            }
            
            if(allowCallout == false){
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
                '"name": "'+Name+'",'+ 
                '"email": "'+Email+'",'+ 
                '"emailSubject": "'+subject+'",'+
                '"emailBody": "'+Name+emailbody+'",'+ 
                '"supportedLanguage": "en",'+
                '"recipientId": '+i+''+ 
                '}';
            
           recipient = recipient+',';
            
            system.debug('@@@@@@ recipient @@@@@@'+recipient);
            String json='{'+ 
                ' '+ 
                ' "emailSubject": "'+subject+'",'+
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
                '{'+ 
                '    "roleName": "Signer 1",'+ 
                '    "name": "'+name+'",'+ 
                '    "email": "'+email+'",'+
                '    "emailNotification": {'+
                '    "emailSubject": "'+subject+'",'+
              '    "emailBody": "'+emailbody+'",'+
              '    "supportedLanguage": "en"'+
              '},'+
                '},'+ 
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
    
    Public void updateParticipantName(){
        string childsName = '';
        if(participantNameList.size() > 0){
            for(String processName : participantNameList){
                if(childsName == '')
                childsName = processName;
                else
                childsName+=','+' '+processName;
            }
       participantName = childsName;
        }
        
        
        if(participantName != Null){
             Contact dbChildContact = new Contact();
             dbChildContact.Id = currentParentCase.ContactId;
             dbChildContact.Hidden_Participant_Under18__c  = participantName+':';
             update dbChildContact;
        }
    }
    
    //Success message
    public pagereference DisplayMessage(){
        if(pageName == 'Single_Vf'){
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm,'The single parent form has been sent successfully.'));
        }
        if(pageName == 'Absent_Vf'){
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm,'The absent parent form has been sent successfully.'));
        }
        
        
        return null;
    }
    
     public void checkEmail(string email)
    {
        if(!Pattern.matches('[a-zA-Z0-9._-]+@[a-zA-Z]+.[a-zA-Z]{2,4}[.]{0,1}[a-zA-Z]{0,2}', email))
        {   allowCallout = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Please enter a valid email address.')); 
        }
        else{
            allowCallout = false;
        }
    }
    
    //Display error message
    public pagereference displayErrorMessage(){
        
         if(((String.isEmpty(recpName) && String.isEmpty(recpEmail)) && (String.isEmpty(individualName) && String.isEmpty(individualEmail)) && String.isEmpty(participantName)) ){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm,'Please select/enter the parent and child\'s name below.'));
         }
         
        else  if(String.isNotEmpty(recpName) && String.isEmpty(recpEmail) && String.isNotEmpty(individualName) && String.isNotEmpty(individualEmail)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm,'You can either select the parent\'s name from the drop down or enter in the text box.'));
         }
         else if(String.isNotEmpty(recpName) && String.isNotEmpty(recpEmail) && String.isEmpty(individualName) && String.isNotEmpty(individualEmail)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm,'You can either select the parent\'s name from the drop down or enter in the text box.'));
         }
          else if(String.isNotEmpty(recpName) && String.isNotEmpty(recpEmail) && String.isNotEmpty(individualName) && String.isEmpty(individualEmail)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm,'You can either select the parent\'s name from the drop down or enter in the text box.'));
        }  
        else if(String.isEmpty(participantName)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm,'Please select the child\'s name below.'));
        }
        else if((String.isEmpty(recpName) || String.isEmpty(individualName)) && (String.isNotEmpty(recpEmail) || String.isNotEmpty(individualEmail))) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm,'Please enter the parent\'s name below.'));
        }
        else if((String.isEmpty(recpEmail)) && String.isNotEmpty(recpName)) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm,'The contact you have selected has no email address available. Please add email on the contact record and try to send the form again.'));
        }
        else if(String.isEmpty(individualEmail) && String.isNotEmpty(individualName)) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm,'Please enter a email address in email field.'));
        }
        else if((String.isEmpty(recpName) || String.isEmpty(individualName)) && (String.isEmpty(recpEmail) || String.isEmpty(individualEmail)) && String.isNotEmpty(participantName)){
           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm,'Please select/enter the parent\'s name below.'));
        }
        else if((String.isEmpty(recpName) || String.isEmpty(individualName)) && (String.isEmpty(recpEmail) || String.isEmpty(individualEmail))){
           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm,'Please select/enter the parent and child\'s name below.'));
        }
        else if(String.isNotEmpty(recpName) && String.isNotEmpty(recpEmail) && String.isNotEmpty(individualName) && String.isNotEmpty(individualEmail)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm,'You can either select the parent\'s name from the drop down or enter in the text box.'));
        }
        
        return null;
    }
    
}