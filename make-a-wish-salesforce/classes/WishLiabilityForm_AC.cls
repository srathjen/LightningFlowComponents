/*****************************************************************************
Created by: Kanagaraj
Author : MST Solutions
CreateDate : 10/05/2016
Description : WishLiabilityForm_AC is used to send the WishLiability Form for Users to sign that liability form.
******************************************************************************/


public class WishLiabilityForm_AC
{
    public Id caseId;
    public Case currentCase{get;set;}
    public Wish_Child_Form__c childForm{get;set;}
    public Map<String,String> emailSignatureMap{get;set;}
    public list<string> contactEmailList{get;set;}
    public Map<String,String> signNowemailMap{get;set;}
    public boolean displayPopup{get;set;}
    public List<SelectOption> multiPickoptions {get;set;}
    public List<String> emailList{get;set;}
    public  Map<String,String> sendEmailMap {get;set;}
    public List<String> listofSenderName{get;set;}
    public boolean isRedriect{get;set;}
    Public String Name{get;set;}
    PUBLIC String WishChildId{get;set;}
    Public List<String> typeString{get;set;}
    public List<String> SenderEmailList{get;set;}
    public List<String> WishTypeList{get;set;}
    public Set<String> emailSetString{get;set;}
    public List<String> receipent{get;set;}
    public boolean displaySignNowPopup{get;set;} 
    public String SingerName{get;set;}
    public boolean isFirstParent {get;set;}
    public boolean displayError{get;set;}
    public String documentPDF;
    public String envelopeId;
    public Map<String,String> signersKeyPairMap{get;set;}
    public List<String> SignNowList{get;set;}
    public boolean isFirstParentSendEmail{get;set;}
    public boolean SignNowdisplayError{get;set;}
    public Set<String> holdEmailNameSet;
    public WishLiabilityForm_AC(ApexPages.StandardController controller) {
        
        
        contactEmailList = new List<String>();
        signNowemailMap = new Map<String,String>();
        emailSignatureMap = new Map<String,String>();
        sendEmailMap = new Map<String,String>();
        caseId = Apexpages.currentPage().getParameters().get('Id');
        typeString = new List<String>();
        receipent = new List<String>();
        SignNowList = new List<String>();
        holdEmailNameSet = new Set<String>();
        envelopeId = '';
        signersKeyPairMap = new Map<String,String>();
        currentCase = [SELECT ID,ContactID,Contact.Name,Contact.Publicity_OK__c,LiabilitySignerMapKeyPair__c,Hidden_Email_List__c,Hidden_Name_List__c,ChapterName__c,ChapterName__r.Name  FROM Case WHERE ID =:caseId];
        WishChildId = currentCase.ContactId; 
        childForm = [SELECT Id,Hidden_Wish_Fmaily_Contact_Name__c,Case__c,Participant_Name__c,Hidden_Wish_Fmaily_Contact_Email__c,Participant_Details__c FROM Wish_Child_Form__c WHERE Case__c =: currentCase.Id];
        
        if(currentCase .Hidden_Email_List__c != Null){
            listofSenderName = new List<String>();
            
            listofSenderName = currentCase .Hidden_Email_List__c.split(',');
           
            
            for(String emailSenderName : currentCase.Hidden_Email_List__c.split(',')){
                emailSenderName = emailSenderName.trim();
                holdEmailNameSet.add(emailSenderName);
            }
            
             
        }
        if(childForm .Hidden_Wish_Fmaily_Contact_Name__c != Null || childForm.Participant_Name__c != Null){
            SignNowList = new List<String>();
            if(childForm.Hidden_Wish_Fmaily_Contact_Name__c != Null){
                 
                for(String processSignNowList : childForm.Hidden_Wish_Fmaily_Contact_Name__c.split(',')){
                   if(Name == Null || Name == '')
                    Name = processSignNowList;
                    else
                    Name+=','+' '+processSignNowList;
                   
                    if(!holdEmailNameSet.contains(processSignNowList )){
                      
                           signNowemailMap.put(processSignNowList,'abc@gmail.com');
                           
                           system.debug('@@@@@@  signNowemailMap @@@@@@@@'+ signNowemailMap);
                       }
                }
            }
            
            if(childForm.Participant_Name__c != Null){
                
                for(String processSignNowList : childForm.Participant_Name__c.split(',')){
                       String displayname = processSignNowList.split('-')[0];
                       String age = processSignNowList.split('-')[1];
                       
                       if(Name == Null || Name == '')
                        Name = displayname;
                        else
                        Name+=','+' '+displayname;
                        
                    if(!holdEmailNameSet.contains(displayname)){ 
                       if(Integer.valueof(age) >= 18)
                          signNowemailMap.put(displayname,'abc@gmail.com');
                          
                    }
                
               }
            
            }
            system.debug('@@@@@@  signNowemailMap @@@@@@@@'+ signNowemailMap.size());
            system.debug('@@@@@@  signNowemailMap @@@@@@@@'+ signNowemailMap);
                for(String processEmailMap : signNowemailMap.Keyset()){
                    SignNowList.add(processEmailMap);
                }
              system.debug('@@@@@@  SignNowList@@@@@@@@'+ SignNowList);
              system.debug('@@@@@@  SignNowList@@@@@@@@'+ SignNowList.size());
            
        }
        
        if(childForm.Hidden_Wish_Fmaily_Contact_Email__c != Null || childForm.Participant_Details__c != Null){
            if(childForm.Hidden_Wish_Fmaily_Contact_Email__c != Null){
                for(String key : childForm.Hidden_Wish_Fmaily_Contact_Email__c.split(',')){
                    String keys = key.split('-')[0];
                    String value = key.split('-')[1];
                    
                    if(!holdEmailNameSet.contains(keys)){
                        
                        emailSignatureMap.put(keys.trim(),value.trim());
                    }
                } 
            }
            
            if(childForm.Participant_Details__c != Null){
                for(String key : childForm.Participant_Details__c.split(',')){
                    String keys = key.split('-')[0];
                    String value = key.split('-')[1];
                    String age = key.split('-')[2];
                    system.debug('@@@@@@  age  @@@@@@@@'+ age  );
                    if(!holdEmailNameSet.contains(keys)){
                        if(Integer.valueof(age) >= 18)
                        emailSignatureMap.put(keys.trim(),value.trim());
                    }
                } 
            }
            
        }
    
    }
    /*This method is used to fetch the multiple email address to send the liability form.*/
    public pageReference multiEmail(){
        if(emailSignatureMap.size()> 0 ){
            displayPopup = true;
            multiPickoptions = new List<SelectOption>();
            for(String currString : emailSignatureMap.keySet()){
                   if(currString != Null){
                system.debug('@@@@ currString @@@@@'+currString);
                multiPickoptions.add(new SelectOption(currString,currString ));}
            }
        }
        
        else{
            displayError = true;
            
        }
        return null;
    }
    
    /*This method is used to fetch the multiple email address to send the liability form.*/
    public pagereference sendpdftoEmail (){
        displayPopup = false;
        String queryName = '';
        String querySignature = '' ;
        Set<String> senderNameSet = new Set<String>();
        for(String processEmailList :emailList ){
            if(processEmailList != Null){
            processEmailList = processEmailList.trim();
            senderNameSet.add(processEmailList);
            }
        }
        system.debug('####senderNameSet####'+senderNameSet);
        for(String currString : emailSignatureMap.keySet()){
            if(senderNameset.Contains(currString)){
                 if(currString != Null)
                sendEmailMap.put(currString.trim(),emailSignatureMap.get(currString).trim());
                
            }
            
            system.debug('####SendEmailMap####'+sendEmailMap);
        }
        
        if((!sendEmailMap.isEmpty()) && sendEmailMap.size() > 0 ){
        system.debug('####SendEmailMap####'+sendEmailMap);
        system.debug('querySignature b4' + querySignature);
            for(String currString : sendEmailMap.KeySet()){
                    currString = currString.trim();
                    system.debug('++++ cur +++' + currString);
                    if(querySignature == '' || querySignature == Null){
                    querySignature = currString;
                    
                    }
                    else{ 
                    querySignature +=',' +currString;
                    }
            }
            
            system.debug('querySignature at' + querySignature);
            
            for(String currString : sendEmailMap.Values())
            {
                 if(String.isBlank(queryName)){
                 queryName = currString;
                 }
                 else {
                 queryName += ', '+currString;
                 }
            }
        }
        
        for(Case dbCase : [SELECT Id,Hidden_Email_List__c,Hidden_Name_List__c From Case WHERE Id =:caseId]){
            
            case newCase = new case();
            newCase.Id = dbCase.Id;
            newCase.Hidden_Email_List__c = querySignature;
            newCase.Hidden_Name_List__c = queryName;
            try{
                update newCase;
            }
            catch(Exception e){
            }
            
        }
        system.debug('querySignature value'+querySignature);
        CallOuttoDocusign(sendEmailMap,caseId);
         system.debug('####method calling ####'+sendEmailMap);
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm,'An email has been sent successfully'));
        isRedriect = true;
        return null;
    }
    public pageReference redirect(){
        
        PageReference acctPage = new PageReference ('/'+caseId);
        acctPage.setRedirect(true);
        return acctPage;
    }
    /*This method is used to send the document to the selected email address*/
    @future(Callout = true)   
    public Static void CallOuttoDocusign(Map<String,String>emailMap,String caseId){
    system.debug('####Future Method ####'+emailMap);
        boolean isParent;
        List<Contact> contactList = new List<Contact>(); 
        Wish_Child_Form__c  childFormInstance;
        Map<String,npe4__Relationship__c> recipientMap = new Map<String,npe4__Relationship__c>();
        Set<String> parentGardienSet = new Set<String>();
        childFormInstance = [SELECT Id,Hidden_Wish_Fmaily_Contact_Name__c,Hidden_Wish_Fmaily_Contact_Email__c,Case__c,Participant_Name__c FROM Wish_Child_Form__c WHERE Case__c =: caseId];
        
        for(String key : childFormInstance.Hidden_Wish_Fmaily_Contact_Email__c.split(',')){
            String keys = key.split('-')[0];
            String value = key.split('-')[1];
            isParent = true;
            parentGardienSet.add(keys); 
        } 
        
        Pagereference PDF = Page.WishLiabilitySendPDF;
        String documentPDF;
        PDF.setRedirect(false);
        PDF.getParameters().put('Id',caseId);
        if(!Test.isRunningTest())
            documentPDF = EncodingUtil.base64Encode(PDF.getContentAsPDF());
        system.debug(PDF+'base64 value '+documentPDF);
        String recipients = '';
        Integer i = 1;
        String status;
        String boundary = 'AAA';
        String initial = '';
        String account;
        String UserName;
        String Password;
        String IntegratorKey;
        String endPointURL;
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
        String clientUserId = '';
        String email;
        
        //Fetching related contacts that has email address and forming recipients with signature location.
        
        String recipientsParticipants = '';
        for (String currString: emailMap.KeySet()) {
            if (parentGardienSet.Contains(currString) && isParent == true) {
                String Name = currString;
                email = emailMap.get(Name);
                clientUserId = '';
                
                if (recipientsParticipants != '')
                    recipientsParticipants = recipientsParticipants + ',';
                recipientsParticipants = recipientsParticipants + '{' +
                    '      "email": "' + email + '",' +
                    '      "name": "' + Name + '",' +
                    '     "roleName": "Signer ' + i + '",' +
                    '     "routingOrder": "'+i+'",'+
                    '      "recipientId":"' + i + '",' + clientUserId +
                    '      "tabs": {'+
                    '                "signHereTabs": [{'+
                    '                     "anchorString":"~s'+i+'",'+
                    '                    "anchorXOffset": "0",'+
                    '     "anchorYOffset": "0",'+
                    '                    "anchorIgnoreIfNotPresent": "false",'+
                    '                    "anchorUnits": "inches"'+
                    '                }],'+
                    '     "radioGroupTabs": [{'+
                    '                    "groupName": "Radio Group 1",'+
                    '                    "required": "true",'+
                    '                    "radios": [{'+
                    '                    "anchorString": "~FirstRadio",'+
                    '                    "anchorXOffset": "0",'+
                    '                    "anchorYOffset": "0",'+
                    '                    "anchorIgnoreIfNotPresent": "false",' +
                    '                    "anchorUnits": "inches",'+
                    '                    "required": "true",'+
                    '                    "selected": "false",'+
                    '                     "value": "one1Radio",'+
                    '                    "xPosition": "300",'+
                    '                    "yPosition": "75"},{'+
                    '                    "anchorString": "~secondRadio",'+
                    '                    "anchorXOffset": "0",'+
                    '                    "anchorYOffset": "0",'+
                    '                    "anchorIgnoreIfNotPresent": "false",' +
                    '                    "anchorUnits": "inches",'+
                    '                    "required": "true",'+
                    '                    "selected": "false",'+
                    '                     "value": "twoRadio",'+
                    '                    "xPosition": "350",'+
                    '                    "yPosition": "75"'+
                    '                    }]'+
                    '                   }],'+
                    '                "initialHereTabs": [{' +
                    '                    "anchorString": "~123abcinitial",' +
                    '                    "conditionalParentLabel":"Radio Group 1",'+
                    '                    "conditionalParentValue" :"one1Radio",'+
                    '                    "optional"    :  "false",' +
                    '                    "anchorXOffset": "0",' +
                    '                    "anchorYOffset": "0.2",' +
                    '                    "name"       : "FirstInitial",'+
                    '                    "mergeField" : {"configurationType":"Salesforce","path":"case.Option1__c","writeBack":"true","allowSenderToEdit":"true"},'+
                    '                    "anchorIgnoreIfNotPresent": "false",' +
                    '                    "anchorUnits": "inches"},{'+
                    '                    "anchorString": "~initial2",' +
                    '                    "optional"    :  "false",' +
                    '                    "conditionalParentLabel":"Radio Group 1",'+
                    '                    "conditionalParentValue" :"twoRadio",'+
                    '                    "name"       : "SecondInitial",'+
                    '                    "mergeField" : {"configurationType":"Salesforce","path":"case.Option2__c","writeBack":"true","allowSenderToEdit":"true"},'+
                    '                    "anchorXOffset": "0",' +
                    '                    "anchorYOffset": "0.2",' +
                    '                    "anchorIgnoreIfNotPresent": "false",' +
                    '                    "anchorUnits": "inches"'+
                    '                }],' +
                    '                "dateSignedTabs": [{'+
                    '                      "anchorString": "~date'+i+'",'+
                    '                       "anchorXOffset": "0",'+
                    '                       "fontSize":      "Size14",'+
                    '                       "fontColor":     "Black",'+
                    '                        "anchorYOffset": "0",'+
                    '                        "anchorIgnoreIfNotPresent": "false",'+
                    '                        "xPosition": "100",'+
                    '                        "yPosition": "72",'+
                    '                        "anchorUnits": "inches"'+
                    '                    }]'+
                    '            }'+
                    '    }';
                isParent = false;
            }      
            else  {
                String Name = currString;
                email = emailMap.get(Name);
                clientUserId = '';
                if (recipients != '')
                    recipients = recipients + ',';
                recipients = recipients + '{' +
                    '      "email": "' + email + '",' +
                    '      "name": "' + Name + '",' +
                    '     "roleName": "Signer ' + i + '",' +
                    '     "routingOrder": "'+i+'",'+
                    '      "recipientId":"' + i + '",' + clientUserId +
                    '      "tabs": {' +
                    '                "signHereTabs": [{' +
                    '                     "anchorString":"~s' + i + '",' +
                    '                    "anchorXOffset": "0",' +
                    '     "anchorYOffset": "0",' +
                    '                    "anchorIgnoreIfNotPresent": "false",' +
                    '                    "anchorUnits": "inches"' +
                    '                }],' +
                    '                "dateSignedTabs": [{'+
                    '                      "anchorString": "~date'+i+'",'+
                    '                       "anchorXOffset": "0",'+
                    '                       "fontSize":      "Size14",'+
                    '                       "fontColor":     "Black",'+
                    '                        "anchorYOffset": "0",'+
                    '                        "anchorIgnoreIfNotPresent": "false",'+
                    '                        "xPosition": "100",'+
                    '                        "yPosition": "72",'+
                    '                        "anchorUnits": "inches"'+
                    '                    }]'+
                    '            }' +
                    '    }';
                
            }
            i++;
        }
        if(recipientsParticipants != '')
            recipients = recipientsParticipants +','+ recipients; 
        
        
        //forming payload with the document and recipients.
        String body =  '{'+
            '  "status":"sent",'+
            '  "enableWetSign": "false",'+
            '  "emailBlurb":"Test Email Body",'+
            '  "emailSubject": "Liability And Publicity Release Form",'+
            '  "enforceSignerVisibility":"True",'+
            '  "documents": [{'+
            '      "name": "document.pdf",'+
            '      "documentId":"1",'+
            '      "order":"1",'+
            '      "documentBase64":"'+documentPDF+'"'+
            '  }],'+
            '"recipients": {'+
            '    "signers" : ['+recipients+']'+
            '  },'+
            '}';
        String viewBody = '{'+
            '"returnUrl": "https://www.docusign.com/devcenter"'+
            '}';
        String header = '--'+boundary+'\nContent-Type: application/json\nContent-Disposition: form-data';
        String jsonBody = header +'\n\n'+body+'\n\n--'+boundary+'--';
        system.debug('@@@@@JSONBODY@@@@@'+jsonBody);
        //Callout to Docusign.
        HttpRequest req = new HttpRequest();
        req.setHeader('X-DocuSign-Authentication', authorizationHeader);
        req.setHeader('Accept','application/json');
        req.setHeader('Host','demo.docusign.net');
        req.setHeader('Content-Length','162100');
        req.setHeader('Content-Type','multipart/form-data; boundary='+boundary);
        req.setEndpoint(endpoint);
        req.setMethod('POST'); 
        req.setBody(jsonBody);
        Http http = new Http();
        HTTPResponse res;
        try{
            if(recipients != ''){
                res = http.send(req);
                system.debug(res.getBody());
                //Docusign status record creation.
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                
                if((String) results.get('status') == 'Sent'){
                    status = 'Agreement sent to email.';
                    dsfs__DocuSign_Status__c dsfs= NEW dsfs__DocuSign_Status__c();
                    dsfs.dsfs__DocuSign_Envelope_ID__c = (String) results.get('envelopeId');
                    dsfs.dsfs__Case__c= caseId;
                    Insert dsfs;
                }else
                    status = (String) results.get('errorCode');
                
            }
            
            
        }catch(Exception e){
            
            
        }
    }
    
    
    /*This method is used to Identify the users who are all going to sign the document*/
    public pageReference SignNowmultiEmail(){
        if(signNowemailMap.Size() > 0){
            displaySignNowPopup = true;
            multiPickoptions = new List<SelectOption>();
            for(String currString : signNowemailMap.keySet()){
                multiPickoptions.add(new SelectOption(currString,currString ));
            }
        }
        
        else{
            SignNowdisplayError = true;
        }
        
        if(signNowemailMap.size() > 0){
            system.debug('@@@@@@ rrrrrrrrrrrrrr @@@@@@@@'+ signNowemailMap);
            String account;
            String UserName;
            String Password;
            String IntegratorKey;
            String endPointURL;
            String initial = '';
            boolean isParent;
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
            String status;
            String email;
            String recipients = '';
            Integer i = 1;
            String boundary = 'AAA';
            
            Pagereference PDF = Page.WishLiabilitySignNow;
            PDF.getParameters().put('Id',caseId);
            try {
                documentPDF = EncodingUtil.base64Encode(PDF.getContentAsPDF());
                
            }catch(Exception e) {
            }
            Map<String,String> recipientMap = new Map<String,String>();
            
            for(Wish_Child_Form__c wishChildForm : [SELECT Id,Name,Case__c,Participant_Name__c,Hidden_Wish_Fmaily_Contact_Name__c FROM Wish_Child_Form__c WHERE
                                                    Case__c =: caseId]){
                                                        if(wishChildForm.Hidden_Wish_Fmaily_Contact_Name__c != Null) {                                     
                                                            for(String keys : wishChildForm.Hidden_Wish_Fmaily_Contact_Name__c .split(',')){
                                                                recipientMap.put(keys.trim(),'PARENT/LEGAL GUARDIAN');
                                                                isFirstParent = true;
                                                            } 
                                                            
                                                        }
                                                        
                                                        if(wishChildForm.Participant_Name__c!= Null){
                                                            for(String keys : wishChildForm.Participant_Name__c.split(',')){
                                                                 String key = keys.split('-')[0];
                                                                 String values = keys.split('-')[0];
                                                                recipientMap.put(key.trim(),'Participant');
                                                                
                                                            } 
                                                        }
                                                    }
            case dbcase = [SELECT Id,Wish_Liability_Envolep__c,LiabilitySignerMapKeyPair__c FROM Case WHERE Id =:caseId];
             system.debug('@@@@@@ dddddddddddd @@@@@@@@'+ recipientMap);
            if(dbcase.Wish_Liability_Envolep__c == Null){
                
                for(String currString : recipientMap.Keyset()){
                    String Name = currString;
                    if(recipientMap.get(Name) == 'PARENT/LEGAL GUARDIAN' && isFirstParent == true){
                        system.debug('@@@@@@@@@@@ isFirstParent @@@@@@@@@@@'+isFirstParent);
                        if(recipients != '')
                            recipients = recipients + ',';
                        recipients = recipients + '{'+
                            '      "email": "kanagaraj@mstsolutions.com",'+
                            '      "name": "'+Name +'",'+
                            '      "recipientId":"'+i+'",'+
                            '      "clientUserId":"'+i+'",'+
                            '      "tabs": {'+
                            '                "signHereTabs": [{'+
                            '                     "anchorString":"~s'+i+'",'+
                            '                    "anchorXOffset": "0",'+
                            '     "anchorYOffset": "0",'+
                            '                    "anchorIgnoreIfNotPresent": "false",'+
                            '                    "anchorUnits": "inches"'+
                            '                }],'+
                            '     "radioGroupTabs": [{'+
                            '                    "groupName": "Radio Group 1",'+
                            '                    "required": "true",'+
                            '                    "radios": [{'+
                            '                    "anchorString": "~FirstRadio",'+
                            '                    "anchorXOffset": "0",'+
                            '                    "anchorYOffset": "0",'+
                            '                    "anchorIgnoreIfNotPresent": "false",' +
                            '                    "anchorUnits": "inches",'+
                            '                    "optional"   :"false",'+
                            '                    "selected": "false",'+
                            '                     "value": "one1Radio",'+
                            '                    "xPosition": "7200",'+
                            '                    "yPosition": "19020"},{'+
                            '                    "anchorString": "~secondRadio",'+
                            '                    "anchorXOffset": "0",'+
                            '                    "anchorYOffset": "0",'+
                            '                    "optional"   :"false",'+
                            '                    "anchorIgnoreIfNotPresent": "false",' +
                            '                    "anchorUnits": "inches",'+
                            '                    "selected": "false",'+
                            '                     "value": "twoRadio",'+
                            '                    "xPosition": "7200",'+
                            '                    "yPosition": "19020"'+
                            '                    }]'+
                            '                   }],'+
                            '                "initialHereTabs": [{' +
                            '                    "anchorString": "~123abcinitial",' +
                            '                    "conditionalParentLabel":"Radio Group 1",'+
                            '                    "conditionalParentValue" :"one1Radio",'+
                            '                    "optional"    :  "false",' +
                            '                    "anchorXOffset": "0",' +
                            '                    "anchorYOffset": "0.2",' +
                            '                    "name"       : "FirstInitial",'+
                            '                    "mergeField" : {"configurationType":"Salesforce","path":"case.Option1__c","writeBack":"true","allowSenderToEdit":"true"},'+
                            '                    "anchorIgnoreIfNotPresent": "false",' +
                            '                    "anchorUnits": "inches"},{'+
                            '                    "anchorString": "~initial2",' +
                            '                    "optional"    :  "false",' +
                            '                    "conditionalParentLabel":"Radio Group 1",'+
                            '                    "mergeField" : {"configurationType":"Salesforce","path":"case.Option2__c","writeBack":"true","allowSenderToEdit":"true"},'+
                            '                    "conditionalParentValue" :"twoRadio",'+
                            '                    "name"       : "SecondInitial",'+
                            '                    "anchorXOffset": "0",' +
                            '                    "anchorYOffset": "0.2",' +
                            '                    "anchorIgnoreIfNotPresent": "false",' +
                            '                    "anchorUnits": "inches"'+
                            '                }],' +
                            '                "dateSignedTabs": [{'+
                            '                      "anchorString": "~date'+i+'",'+
                            '                       "anchorXOffset": "0",'+
                            '                       "fontSize":      "Size14",'+
                            '                       "fontColor":     "Black",'+
                            '                        "anchorYOffset": "0",'+
                            '                        "anchorIgnoreIfNotPresent": "false",'+
                            '                        "xPosition": "100",'+
                            '                        "yPosition": "72",'+
                            '                        "anchorUnits": "inches"'+
                            '                    }]'+
                            '            }'+
                            '    }';
                        
                        if(!signersKeyPairMap.containsKey(Name))
                            signersKeyPairMap.put(Name,String.valueof(i));
                        system.debug('@@@@@@@@ MAP SIGNER @@@@@@@'+signersKeyPairMap);
                        isFirstParent = false;
                    }
                    else if(recipientMap.get(Name) == 'PARENT/LEGAL GUARDIAN' && isFirstParent == false){
                        
                        if(recipients != '')
                            recipients = recipients + ',';
                        recipients = recipients + '{'+
                            '      "email": "kanagaraj@mstsolutions.com",'+
                            '      "name": "'+Name +'",'+
                            '      "recipientId":"'+i+'",'+
                            '      "clientUserId":"'+i+'",'+
                            '      "tabs": {'+
                            '                "signHereTabs": [{'+
                            '                     "anchorString":"~s'+i+'",'+
                            '                    "anchorXOffset": "0",'+
                            '     "anchorYOffset": "0",'+
                            '                    "anchorIgnoreIfNotPresent": "false",'+
                            '                    "anchorUnits": "inches"'+
                            '                }],'+
                            '                "dateSignedTabs": [{'+
                            '                      "anchorString": "~date'+i+'",'+
                            '                       "anchorXOffset": "0",'+
                            '                       "fontSize":      "Size14",'+
                            '                       "fontColor":     "Black",'+
                            '                        "anchorYOffset": "0",'+
                            '                        "anchorIgnoreIfNotPresent": "false",'+
                            '                        "xPosition": "100",'+
                            '                        "yPosition": "72",'+
                            '                        "anchorUnits": "inches"'+
                            '                    }]'+
                            '            }'+
                            '    }';
                        
                        if(!signersKeyPairMap.containsKey(Name))
                            signersKeyPairMap.put(Name,String.valueof(i));
                    }
                    else{
                        
                        if(recipients != '')
                            recipients = recipients + ',';
                        recipients = recipients + '{'+
                            '      "email": "kanagaraj@mstsolutions.com",'+
                            '      "name": "'+Name +'",'+
                            '      "recipientId":"'+i+'",'+
                            '      "clientUserId":"'+i+'",'+
                            '      "tabs": {'+
                            '                "signHereTabs": [{'+
                            '                     "anchorString":"~s'+i+'",'+
                            '                    "anchorXOffset": "0",'+
                            '     "anchorYOffset": "0",'+
                            '                    "anchorIgnoreIfNotPresent": "false",'+
                            '                    "anchorUnits": "inches"'+
                            '                }],'+
                            '                "dateSignedTabs": [{'+
                            '                      "anchorString": "~date'+i+'",'+
                            '                       "anchorXOffset": "0",'+
                            '                       "fontSize":      "Size14",'+
                            '                       "fontColor":     "Black",'+
                            '                        "anchorYOffset": "0",'+
                            '                        "anchorIgnoreIfNotPresent": "false",'+
                            '                        "xPosition": "662",'+
                            '                        "yPosition": "895",'+
                            '                        "anchorUnits": "inches"'+
                            '                    }]'+
                            '            }'+
                            '    }';
                        
                        if(!signersKeyPairMap.containsKey(Name))
                            signersKeyPairMap.put(Name,String.valueof(i));
                    }
                    i++;
                }
                //forming payload with the document and recipients.
                String body =  '{'+
                    '  "status":"sent",'+
                    '  "enableWetSign": "false",'+
                    '  "emailBlurb":"",'+
                    '  "emailSubject": "Liability And Publicity Release Form",'+
                    '  "enforceSignerVisibility":"True",'+
                    '  "documents": [{'+
                    '      "name": "document.pdf",'+
                    '      "documentId":"1",'+
                    '      "order":"1",'+
                    '      "documentBase64":"'+documentPDF+'"'+
                    '  }],'+
                    '"recipients": {'+
                    '    "signers" : ['+recipients+']'+
                    '  }'+
                    '}';
                String viewBody = '{'+
                    '"returnUrl": "https://www.docusign.com/devcenter"'+
                    '}';
                String header = '--'+boundary+'\nContent-Type: application/json\nContent-Disposition: form-data';
                String jsonBody = header +'\n\n'+body+'\n\n--'+boundary+'--';
                system.debug('@@@@@JSONBODY@@@@@'+jsonBody);
                //Callout to Docusign.
                HttpRequest req = new HttpRequest();
                req.setHeader('X-DocuSign-Authentication', authorizationHeader);
                req.setHeader('Accept','application/json');
                req.setHeader('Host','demo.docusign.net');
                req.setHeader('Content-Length','162100');
                req.setHeader('Content-Type','multipart/form-data; boundary='+boundary);
                req.setEndpoint(endpoint);
                req.setMethod('POST'); 
                req.setBody(jsonBody);
                Http http = new Http();
                HTTPResponse res;
                try{
                    if(recipients != ''){
                        res = http.send(req);
                        system.debug('response 1'+res.getBody());
                        //Docusign status record creation.
                        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                        if((String) results.get('envelopeId') != '')
                            envelopeId = (String) results.get('envelopeId');
                        if((String) results.get('status') == 'Sent'){
                            status = 'Agreement sent to email.';
                            dsfs__DocuSign_Status__c dsfs= NEW dsfs__DocuSign_Status__c();
                            dsfs.dsfs__DocuSign_Envelope_ID__c = (String) results.get('envelopeId');
                            dsfs.dsfs__Case__c= caseId;
                            Insert dsfs;
                        }else
                            status = (String) results.get('errorCode');
                        
                    }
                }catch(Exception e){
                    
                }
                system.debug('%%%%%%%% envelopeId value %%%%%%%%%'+envelopeId);
            }
            else
            {
                envelopeId = dbcase.Wish_Liability_Envolep__c;
                for(String key : dbcase.LiabilitySignerMapKeyPair__c.split(',')){
                    String keys = key.split('-')[0];
                    String value = key.split('-')[1];
                    signersKeyPairMap.put(keys.trim(),value.trim());
                } 
                system.debug('%%%%%%%% ENTER INTO ELSE signersKeyPairMap %%%%%%%%%'+signersKeyPairMap);
            }
        }
        return null;
    }          
    /*This method is used Sign the document by the selected user. */
    public Pagereference SubmitAndSign(){
        String account;
        String UserName;
        String Password;
        String IntegratorKey;
        String endPointURL;
        List<Contact> relationShipList = new List<Contact>();
        Map<String,DocuSignCredentialsSetting__c> credentialSetting = DocuSignCredentialsSetting__c.getAll();
        
        for(DocuSignCredentialsSetting__c credentialIns : credentialSetting.values()){
            UserName = credentialIns.name;
            account  = credentialIns.account__c;
            Password = credentialIns.Password__c;
            IntegratorKey  = credentialIns.IntegratorKey__c;
            endPointURL = credentialIns.end_Point__c;
        }
        string endpoint = endPointURL+'/accounts/'+account+'/envelopes';
        String authorizationHeader = '<DocuSignCredentials><Username>'+UserName+'</Username><Password>'+Password+'</Password><IntegratorKey>'+IntegratorKey+'</IntegratorKey></DocuSignCredentials>';
        string endpoint2 = endPointURL+'/accounts/'+account+'/envelopes/'+envelopeId+'/views/recipient';
        
        HttpRequest request = new HttpRequest();
        request.setHeader('X-DocuSign-Authentication', authorizationHeader);
        request.setHeader('Accept','application/json');
        request.setHeader('Host','demo.docusign.net');
        request.setHeader('Content-Length','162100');
        request.setHeader('Content-Type','application/json');
        request.setMethod('POST'); 
        Http httprequest = new Http();
        HTTPResponse response;
        request.setEndpoint(endpoint2);
        string jsonPayload;
        system.debug('URL.getSalesforceBaseUrl().toExternalForm()'+URL.getSalesforceBaseUrl().toExternalForm());
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        system.debug('@@@@@@@@@@@@@@@ signersKeyPairMap @@@@@@@@@@@@'+signersKeyPairMap); 
        system.debug('@@@@@@@@@@@@@@@ signersKeyPairMap @@@@@@@@@@@@'+SingerName); 
        jsonPayload = '{'+
            '    "userName": "'+SingerName+'",'+
            '    "email": "kanagaraj@mstsolutions.com",'+
            '    "recipientId": "'+signersKeyPairMap.get(SingerName)+'",'+
            '    "clientUserId": "'+signersKeyPairMap.get(SingerName)+'",'+
            '    "authenticationMethod": "None",'+
            '   "returnUrl": "'+baseUrl +'/apex/WishLiabilityForm_VF?Id='+CaseId+'"'+   
            '}'; 
        
        system.debug('@@@@@@@@@@@@@@@ jsonPayload @@@@@@@@@@@@'+jsonPayload ); 
        request.setBody(jsonPayload);
        response = httprequest.send(request);  
        system.debug('@@@@@@@@@@@@@@@ response @@@@@@@@@@@@'+response);
        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        //signersKeyPairMap.remove(SingerName);
        String sign;
        for(String name : signersKeyPairMap.KeySet()){
            if(sign == '' || sign == Null)
                sign= name +' - '+ signersKeyPairMap.get(name);
            else
                sign = sign +','+ name + '- '+ signersKeyPairMap.get(name);
        }
        case newCase = new case();
        newCase.Id = caseId;
        newCase.LiabilitySignerMapKeyPair__c = sign;
        newCase.Wish_Liability_Envolep__c = envelopeId;
        update newCase;
        
        PageReference reference=new PageReference((String) results.get('url'));
        reference.setRedirect(true);
        return reference;
    }
}