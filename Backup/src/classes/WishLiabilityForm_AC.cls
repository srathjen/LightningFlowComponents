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
    public list<npe4__Relationship__c> relationShipList{get;set;}
    public list<string> contactEmailList{get;set;}
    public Map<String,String> emailMap{get;set;}
    public boolean displayPopup{get;set;}
    public List<SelectOption> multiPickoptions {get;set;}
    public List<String> emailList{get;set;}
    public String querySignature;
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
    
    public WishLiabilityForm_AC(ApexPages.StandardController controller) {
        relationShipList = new list<npe4__Relationship__c>();
        contactEmailList = new List<String>();
        emailMap = new Map<String,String>();
        sendEmailMap = new Map<String,String>();
        caseId = Apexpages.currentPage().getParameters().get('Id');
        typeString = new List<String>();
        receipent = new List<String>();
        SignNowList = new List<String>();
        envelopeId = '';
        signersKeyPairMap = new Map<String,String>();
        currentCase = [SELECT ID,ContactID,Contact.Name,Contact.Publicity_OK__c,Hidden_Email_List__c,Hidden_Name_List__c,ChapterName__c,ChapterName__r.Name  FROM Case WHERE ID =:caseId];
        WishChildId = currentCase.ContactId; 
        relationShipList  = [SELECT ID,npe4__Contact__c,npe4__RelatedContact__c,npe4__RelatedContact__r.Name,npe4__RelatedContact__r.Email,npe4__RelatedContact__r.IsParentGuardian__c,npe4__RelatedContact__r.Wish_Liability_IsSigned__c,npe4__RelatedContact__r.IsFirstParentGuardian__c  FROM npe4__Relationship__c WHERE 
        npe4__Contact__c =: currentCase.ContactID AND npe4__RelatedContact__r.IsParentGuardian__c != Null];
          if(currentCase .Hidden_Email_List__c != Null){
             listofSenderName = new List<String>();
             listofSenderName = currentCase .Hidden_Email_List__c.split(',');
             
          }
          
        if(currentCase.Hidden_Name_List__c != Null){
           List<String> emailSetString = new List<String>();
            SenderEmailList = new List<String>();
            WishTypeList = new List<String>();
            SenderEmailList = currentCase.Hidden_Name_List__c.split(',');
            for(String processList :listofSenderName){
                 processList=processList.trim();
                emailSetString.add(processList); 
            }
         }
        
        for(npe4__Relationship__c currentRelation : relationShipList ){
             if(Name == Null){
                 Name = currentRelation.npe4__RelatedContact__r.Name;
             }
             
            else{
                Name +=+','+ '  '+currentRelation.npe4__RelatedContact__r.Name;
            }
            
            If(currentRelation.npe4__RelatedContact__r.IsParentGuardian__c == 'ParentGuardian' && currentRelation .npe4__RelatedContact__r.Wish_Liability_IsSigned__c == false ){
           
            contactEmailList.add(currentRelation.npe4__RelatedContact__r.Email);
            if(emailMap.containsKey(currentRelation.npe4__RelatedContact__r.Name)){
                String name = currentRelation.npe4__RelatedContact__r.Name+' ';
                emailMap.put(name,currentRelation.npe4__RelatedContact__r.Email);
            }
            else
                emailMap.put(currentRelation.npe4__RelatedContact__r.Name,currentRelation.npe4__RelatedContact__r.Email);
            
            if(currentRelation.npe4__RelatedContact__r.IsFirstParentGuardian__c == false)
                isFirstParentSendEmail = true;    
            }
            if(currentRelation.npe4__RelatedContact__r.IsParentGuardian__c == 'Participant' && currentRelation .npe4__RelatedContact__r.Wish_Liability_IsSigned__c == false ){
            
            contactEmailList.add(currentRelation.npe4__RelatedContact__r.Email);
             if(emailMap.containsKey(currentRelation.npe4__RelatedContact__r.Name)){
                String name = currentRelation.npe4__RelatedContact__r.Name+' ';
                emailMap.put(name,currentRelation.npe4__RelatedContact__r.Email);
            }
            else
                emailMap.put(currentRelation.npe4__RelatedContact__r.Name,currentRelation.npe4__RelatedContact__r.Email);
            
            }
            
            SignNowList.add(currentRelation.npe4__RelatedContact__r.Name);
       }
   }
   /*This method is used to fetch the multiple email address to send the liability form.*/
    public pageReference multiEmail(){
    if(emailMap.size()> 0 ){
        displayPopup = true;
        multiPickoptions = new List<SelectOption>();
            for(String currString : emailMap.keySet()){
                system.debug('@@@@ currString @@@@@'+currString);
                multiPickoptions.add(new SelectOption(currString,currString ));
            }
        }
        
       else{
         displayError = true;
         ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Already an email sent to specified address click [OK].'));
         }
     return null;
     }
     
     /*This method is used to fetch the multiple email address to send the liability form.*/
    public pagereference sendpdftoEmail (){
        displayPopup = false;
        String queryName;
        Set<String> senderNameSet = new Set<String>();
          for(String processEmailList :emailList ){
                 if(senderNameSet.contains(processEmailList )){
                     processEmailList = processEmailList+' ';
                     senderNameSet.add(processEmailList);
                  }
                 else
                     senderNameSet.add(processEmailList);
                 
           }
           system.debug('####senderNameSet####'+senderNameSet);
           for(String currString : emailMap.keySet()){
                if(senderNameset.Contains(currString)){
                sendEmailMap.put(currString,emailMap.get(currString));
                 
               }
            }
           
           if((!sendEmailMap.isEmpty()) && sendEmailMap.size() > 0 ){
                 for(String currString : sendEmailMap.KeySet()){
                   if(querySignature==null)
                      querySignature = currString;
                   else
                      querySignature = querySignature + ',' +currString;
                }
                
                for(String currString : sendEmailMap.Values())
                {
                     if(queryName ==  Null){
                     queryName = currString;
                     }
                     else
                     queryName +=+ ', '+currString;
                }
            }
            
            for(Case dbCase : [SELECT Id,Hidden_Email_List__c,Hidden_Name_List__c From Case WHERE Id =:caseId]){
                
                case newCase = new case();
                newCase.Id = dbCase.Id;
                newCase.Hidden_Email_List__c  = querySignature;
                newCase.Hidden_Name_List__c = queryName;
                try{
                update newCase;
                }
                    catch(Exception e){
             }
              
            }
            system.debug('querySignature value'+querySignature);
            CallOuttoDocusign(sendEmailMap,caseId,WishChildId,isFirstParentSendEmail);
          
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
     public Static void CallOuttoDocusign(Map<String,String>emailMap,String caseId,Id WishChildId,boolean isParent){
     
         List<Contact> contactList = new List<Contact>(); 
         
         Map<String,npe4__Relationship__c> recipientMap = new Map<String,npe4__Relationship__c>();
         for(npe4__Relationship__c dbRelationShip : [SELECT ID,npe4__Contact__c,npe4__RelatedContact__c,npe4__RelatedContact__r.Name,npe4__RelatedContact__r.Email,npe4__RelatedContact__r.IsParentGuardian__c FROM npe4__Relationship__c WHERE 
              npe4__RelatedContact__r.Name IN:emailMap.keySet() AND npe4__Contact__c =: WishChildId AND npe4__RelatedContact__r.IsParentGuardian__c != Null])
           {
               if(emailMap.containsKey(dbRelationShip.npe4__RelatedContact__r.Name) && emailMap.get(dbRelationShip.npe4__RelatedContact__r.Name) == dbRelationShip.npe4__RelatedContact__r.Email){
                   if(recipientMap.containsKey(dbRelationShip.npe4__RelatedContact__r.Name)){
                       String name = dbRelationShip.npe4__RelatedContact__r.Name+' ';
                       recipientMap.put(name,dbRelationShip);
                   }
                   else
                   recipientMap.put(dbRelationShip.npe4__RelatedContact__r.Name,dbRelationShip);
                   
                }
           }
           
          Pagereference PDF = Page.WishLiabilitySignNow;
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
              
                List<contact> finalList = new List<contact>();
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
                    for (npe4__Relationship__c currString: recipientMap.Values()) {
                            if (currString.npe4__RelatedContact__r.IsParentGuardian__c == 'ParentGuardian' && isParent == true) {
                            String Name = currString.npe4__RelatedContact__r.Name;
                            email = currString.npe4__RelatedContact__r.Email;
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
                        '                    "required": "false",'+
                        '                    "selected": "false",'+
                        '                     "value": "one1Radio",'+
                        '                    "xPosition": "300",'+
                        '                    "yPosition": "75"},{'+
                        '                    "anchorString": "~secondRadio",'+
                        '                    "anchorXOffset": "0",'+
                        '                    "anchorYOffset": "0",'+
                        '                    "anchorIgnoreIfNotPresent": "false",' +
                        '                    "anchorUnits": "inches",'+
                        '                    "required": "false",'+
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
                                       String Name = currString.npe4__RelatedContact__r.Name;
                                       email = currString.npe4__RelatedContact__r.Email;
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
                        '  "emailSubject": "Test Email Subject",'+
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
                        
                        for(npe4__Relationship__c processMap : recipientMap.Values()){
                            
                            Contact updateSignedCon = new Contact();
                            updateSignedCon.Id = processMap.npe4__RelatedContact__c;
                            if(isParent == true)
                            updateSignedCon.IsFirstParentGuardian__c = true;
                            updateSignedCon.Wish_Liability_IsSigned__c = true;
                            finalList.add(updateSignedCon);
                            
                        }
                       update finalList ;
                    }catch(Exception e){
                        
                       
                    }
               }
               
      
      /*This method is used to Identify the users who are all going to sign the document*/
       public pageReference SignNowmultiEmail(){
         if(emailMap.Size() > 0){
             displaySignNowPopup = true;
             multiPickoptions = new List<SelectOption>();
            for(String currString : emailMap.keySet()){
                multiPickoptions.add(new SelectOption(currString,currString ));
            }
         }
         
       else{
         displayError = true;
         ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'There is no user to sign click [OK].'));
         }
         
         if(emailMap.size() > 0){
            
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
                
                 Map<String,npe4__Relationship__c> recipientMap = new Map<String,npe4__Relationship__c>();
                 for(npe4__Relationship__c dbRelationShip : [SELECT ID,npe4__Contact__c,npe4__RelatedContact__c,npe4__RelatedContact__r.Name,npe4__RelatedContact__r.Email,npe4__RelatedContact__r.IsParentGuardian__c,npe4__RelatedContact__r.Wish_Liability_IsSigned__c,npe4__RelatedContact__r.IsFirstParentGuardian__c  FROM npe4__Relationship__c WHERE 
                                                              npe4__Contact__c =: currentCase.ContactID AND npe4__RelatedContact__r.IsParentGuardian__c != Null ])
                {
                      
                      if(dbRelationShip.npe4__RelatedContact__r.IsParentGuardian__c == 'ParentGuardian' && dbRelationShip.npe4__RelatedContact__r.IsFirstParentGuardian__c == false )
                          isFirstParent = true;
                    
                       recipientMap.put(dbRelationShip.npe4__RelatedContact__r.Name,dbRelationShip);
                      
                      system.debug('@@@@@@@@@@ recipientMap @@@@@@@@@@@@'+recipientMap);
                       
               }
                
              case dbcase = [SELECT Id,Wish_Liability_Envolep__c,LiabilitySignerMapKeyPair__c FROM Case WHERE Id =:caseId];
              if(dbcase.Wish_Liability_Envolep__c == Null){
              
                for(npe4__Relationship__c  currString : recipientMap.Values()){
                
                        String Name = currString.npe4__RelatedContact__r.Name;
                       
                    if(currString.npe4__RelatedContact__r.IsParentGuardian__c == 'ParentGuardian' &&  isFirstParent == true){
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
                    else if(currString.npe4__RelatedContact__r.IsParentGuardian__c == 'ParentGuardian' && isFirstParent == false){
                    
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
                    '  "emailBlurb":"Test Email Body",'+
                    '  "emailSubject": "Test Email Subject",'+
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