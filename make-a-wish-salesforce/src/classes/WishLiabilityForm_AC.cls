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
    public List<Wish_Child_Form__c> childForm{get;set;}
    public Map<String,String> emailSignatureMap{get;set;}
    public List<string> contactEmailList{get;set;}
    public Map<String,String> signNowemailMap{get;set;}
    public Boolean displayPopup{get;set;}
    public List<SelectOption> multiPickoptions {get;set;}
    public List<String> emailList{get;set;}
    public Map<String,String> sendEmailMap {get;set;}
    public List<String> listofSenderName{get;set;}
    public Boolean isRedriect{get;set;}
    Public String Name{get;set;}
    PUBLIC String WishChildId{get;set;}
    Public List<String> typeString{get;set;}
    public List<String> receipent{get;set;}
    public Boolean displaySignNowPopup{get;set;}
    public Boolean displayReturnToWish{get;set;} 
    public String SingerName{get;set;}
    public Boolean isFirstParent {get;set;}
    public Boolean displayError{get;set;}
    public Boolean displayAlert{get;set;}
    public String documentPDF;
    public String envelopeId;
    public Map<String,String> signersKeyPairMap{get;set;}
    public List<String> SignNowList{get;set;}
    public Boolean isFirstParentSendEmail{get;set;}
    public Boolean SignNowdisplayError{get;set;}
    public Set<String> holdEmailNameSet;
    public String participantsName{get;set;}
    public Integer j = 0;
    public Integer k = 0;
    public boolean displaypopwindow{get;set;}
    public Map<String,String> participantEmailMap{get;set;}
    Public boolean showButton{get;set;}
    Public set<String> parentLegalSet{get;set;}
    public boolean displaymsgPop{get;set;}
    public boolean isEmpty{get;set;}
    public WishLiabilityForm_AC(ApexPages.StandardController controller) {
        contactEmailList = new List<String>();
        signNowemailMap = new Map<String,String>();
        emailSignatureMap = new Map<String,String>();
        sendEmailMap = new Map<String,String>();
        participantEmailMap = new Map<String,String>();
        parentLegalSet = new Set<String>();
        listofSenderName = new List<String>();
        caseId = Apexpages.currentPage().getParameters().get('Id');
        if(Apexpages.currentPage().getParameters().get('option') == 'Three' || Apexpages.currentPage().getParameters().get('event') == 'signing_complete'){
            showButton = true;
        }
        typeString = new List<String>();
        receipent = new List<String>();
        signNowList = new List<String>();
        holdEmailNameSet = new Set<String>();
        envelopeId = '';
        signersKeyPairMap = new Map<String,String>();
        displaypopwindow = false;
        currentCase = [SELECT ID,ContactID,Contact.Name,Contact.Publicity_OK__c,LiabilitySignerMapKeyPair__c,Hidden_Email_List__c,Hidden_Name_List__c,ChapterName__c,ChapterName__r.Name  FROM Case WHERE ID =:caseId LIMIT 1];
        WishChildId = currentCase.ContactId; 
        childForm = [SELECT Id,Parent_Gurdian_above_18__c,Case__c,Hidden_Contact_Name__c,ParentsParticipantsName__c,Participant_Name__c,Participant_Names__c,Parent_Gurdian_above_18_Email__c,Participant_Details__c,Hidden_Email_List__c,
                     Hidden_Name_List__c FROM Wish_Child_Form__c WHERE Case__c =: currentCase.Id LIMIT 1];
        
        if(childForm.size()>0){
            displayAlert = true;
            if(childForm[0].Hidden_Name_List__c != Null || childForm[0].Hidden_Contact_Name__c != Null){
                
                if(childForm[0].Hidden_Name_List__c != Null){
                    
                    for(String emailSenderName : childForm[0].Hidden_Name_List__c.split('#')){
                        holdEmailNameSet.add(emailSenderName.trim());
                    }
                }
                
            }
            
            if(childForm[0].ParentsParticipantsName__c != Null){
                participantsName = childForm[0].ParentsParticipantsName__c;
                if(childForm[0].ParentsParticipantsName__c.startsWith(',')){
                    participantsName = childForm[0].ParentsParticipantsName__c.removeStart(',');
                }
                
                if(childForm[0].ParentsParticipantsName__c.startsWith('null')){
                    participantsName = childForm[0].ParentsParticipantsName__c.removeStartIgnoreCase('null');
                }
            }
            if(childForm[0].Parent_Gurdian_above_18__c != Null || childForm[0].Participant_Name__c != Null){
                signNowList = new List<String>();
                
                if(childForm[0].Parent_Gurdian_above_18__c != Null){
                    
                    for(String processSignNowList : childForm[0].Parent_Gurdian_above_18__c.split('#')){
                        String signname = processSignNowList.split('::')[0];
                        // String email = processSignNowList.split('-')[1]; 
                        if(Name == Null || Name == '')
                            Name = signname;
                        else
                            Name+=','+' '+signname;
                        if(!holdEmailNameSet.contains(signname)){
                            signNowemailMap.put(signname,'abc@gmail.com');
                        }
                        signNowList.add(signname);
                    }
                }
                if(childForm[0].Participant_Name__c != Null){
                    for(String processSignNowList : childForm[0].Participant_Name__c.split('#')){
                        String displayname = processSignNowList.trim().split('::')[0];
                        system.debug('---->Age'+processSignNowList.trim().split('::')[1]);
                        String age = processSignNowList.trim().split('::')[1];
                        
                        if(Name == Null || Name == '')
                            Name = displayname;
                        else
                            Name+=','+' '+displayname;
                        if(!holdEmailNameSet.contains(displayname.trim())){ 
                            if(Integer.valueof(age) >= 18)
                                signNowemailMap.put(displayname.trim(),'abc@gmail.com');
                            
                        }
                        signNowList.add(displayname);
                    }
                }
            }
            List<String> holdRecVal = new List<String>();
            if(childForm[0].Parent_Gurdian_above_18_Email__c != Null || childForm[0].Participant_Details__c != Null){
                if(childForm[0].Parent_Gurdian_above_18_Email__c != Null){
                    for(String key : childForm[0].Parent_Gurdian_above_18_Email__c.split('#')){
                        String keys;
                        String value;
                        if(!String.isEmpty(key) && key.contains('::')) {
                            holdRecVal = key.split('::');
                            if(holdRecVal.size() == 1) {
                                keys = key.split('::')[0];
                                value = '';
                            } else if(holdRecVal.size() == 2 && key.contains('::')) {
                                keys = key.split('::')[0];
                                value = key.split('::')[1];
                            }
                            
                        }
                        
                        if(!holdEmailNameSet.contains(keys)){
                            if(!String.IsEmpty(keys)){
                                emailSignatureMap.put(keys.trim(),value.trim());
                                holdRecVal.clear();
                            }
                        } 
                    }
                }
                if(childForm[0].Participant_Details__c != Null){
                    List<String> proceessList = new List<String>();
                    for(String key : childForm[0].Participant_Details__c.split('#')){
                        proceessList.clear();
                        if(key.contains('::')){
                            for(String sla : key.split('::')) {
                                proceessList.add(sla);
                            }
                            if(proceessList.size() == 3 && key.contains('::')) {
                                String keys = key.split('::')[0];
                                String value = key.split('::')[1];
                                String age = key.split('::')[2];
                                if(!holdEmailNameSet.contains(keys)){
                                    if(Integer.valueof(age) >= 18 && proceessList.size() == 3)
                                        emailSignatureMap.put(keys.trim(),value.trim());
                                }
                                if(!parentLegalSet.contains(keys)&& Integer.valueof(age) >= 18)
                                    participantEmailMap.put(keys.trim(),value.trim());
                                
                            } 
                            
                        } 
                    }
                }
            }
        }
        
    }
    
    /*This method will take you back to the Case page */
    public pageReference cancel(){
        displayAlert = false;
        PageReference reference=new PageReference('/'+currentCase.Id);
        reference.setRedirect(true);     
        return reference;
    }
    
    /*This method will take you back to Liabilityform*/
    public pageReference returnToLiabilityForm(){
        isRedriect = false;
        string currPage = Apexpages.currentPage().getParameters().get('option'); 
        PageReference reference = new PageReference('/apex/WishLiabilityForm_VF?id='+currentCase.id+'&option='+currPage);
        reference.setRedirect(true);     
        return reference;
    }
    
    /*This method will return back to wish*/
    public void returnToWish(){
        displayReturnToWish = true;
    }
    
    /*This method is used to fetch the multiple email address to send the liability form.*/
    public pageReference multiEmail(){
        if((Apexpages.currentPage().getParameters().get('option') == 'Three') || (Apexpages.currentPage().getParameters().get('event') == 'signing_complete')){
            if(emailSignatureMap.size()> 0 ){
                displayPopup = true;
                multiPickoptions = new List<SelectOption>();
                for(String currString : emailSignatureMap.keySet()){
                    if(currString != Null){
                        if(!holdEmailNameSet.contains(currString.trim())){
                            multiPickoptions.add(new SelectOption(currString.trim(),currString.trim()));}}
                }
                
            }
            else{
                
                displayError = true;
                
            }
        }
        else{
            if(emailSignatureMap.size()> 0 ){
                displayPopup = true;
                multiPickoptions = new List<SelectOption>();
                for(String currString : emailSignatureMap.keySet()){
                    if(currString != Null){
                        multiPickoptions.add(new SelectOption(currString.trim(),currString.trim()));
                    }
                }
            }
            else{
                
                displaymsgPop = true;
                
            }
        }
        return null;
    }
    
    public pagereference sendpdftoEmail (){
        displayPopup = false;
        String queryName = '';
        String querySignature = '' ;
        isEmpty = false;
        Set<String> senderNameSet = new Set<String>();
        for(String processEmailList :emailList ){
            if(processEmailList != Null){
                processEmailList = processEmailList.trim();
                senderNameSet.add(processEmailList);
            }
        }
        for(String currString : emailSignatureMap.keySet()){
            if(senderNameset.Contains(currString)){
                if((!(String.isEmpty(emailSignatureMap.get(currString)) || String.isBlank(emailSignatureMap.get(currString)))) && currString != Null){
                    sendEmailMap.put(currString.trim(),emailSignatureMap.get(currString).trim());
                }
                else if(currString != Null && (String.isEmpty(emailSignatureMap.get(currString)) || String.isBlank(emailSignatureMap.get(currString)))){
                    isEmpty = true;
                }
            }
        }
        System.debug('@@@@@ sendEmailMap @@@@@'+sendEmailMap);
        System.debug('@@@@@ sendEmailMap @@@@@'+isEmpty);
        if(sendEmailMap.size() > 0 && isEmpty == false){
            callOuttoDocusign(sendEmailMap,caseId,Apexpages.currentPage().getParameters().get('option'));
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm,'An email has been sent successfully'));
            isRedriect = true;
        }
        /* if(isEmpty == true){
ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'The parent/legal guardian or participant you have selected has no email address available. Please add email on wish form and try to send form again.'));
}*/
        return null;
    }
    
    @future(Callout = true)   
    public Static void callOuttoDocusign(Map<String,String>emailMap,String caseId,String currentParam){
        boolean isParent;
        List<Contact> contactList = new List<Contact>(); 
        Wish_Child_Form__c  childFormInstance;
        Map<String,npe4__Relationship__c> recipientMap = new Map<String,npe4__Relationship__c>();
        Set<String> parentGardienSet = new Set<String>();
        childFormInstance = [SELECT Id,Parent_Gurdian_above_18__c,Parent_Gurdian_above_18_Email__c,Case__c, Case__r.Contact.Name,Case__r.Contact.FirstName, Participant_Name__c FROM Wish_Child_Form__c WHERE Case__c =: caseId LIMIT 1];
        Pagereference PDF;
        if(currentParam == 'One')
            PDF = Page.WishLiabilityOption1_VF;
        else if(currentParam == 'Two')
            PDF = Page.WishLiabilityOption2_VF;
        else
            PDF = Page.WishLiabilitySendPDF;
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
        boolean isFirstParent = true;
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
        String Name;
        //Fetching related contacts that has email address and forming recipients with signature location.
        String recipientsParticipants = '';
        if(currentParam != 'Three'){
            for (String currString: emailMap.KeySet()) {
                Name = currString;
                email = emailMap.get(Name);
                clientUserId = '';
                if (recipients != '')
                    recipients = recipients + ',';
                recipients = recipients + '{' +
                    '      "email": "' + email + '",' +
                    '      "name": "' + Name + '",' +
                    '     "roleName": "Signer ' + i + '",' +
                    //'     "routingOrder": "'+i+'",'+
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
                i++;
            }
        }
        else{
            for(String currString : emailMap.KeySet()){
                Name = currString;
                email = emailMap.get(currString);
                
                if(isFirstParent == true ){
                    
                    if(recipients != '')
                        recipients = recipients + ',';
                    recipients = recipients + '{'+
                        '      "email": "'+email+'",'+
                        '      "name": "'+Name+'",'+
                        '      "recipientId":"' + i + '",' + clientUserId +
                        '      "tabs": {'+
                        '                "signHereTabs": [{'+
                        '                     "anchorString":"~s'+i+'",'+
                        '                    "anchorXOffset": "0",'+
                        '                   "anchorYOffset": "0",'+
                        '                    "anchorIgnoreIfNotPresent": "false",'+
                        '                    "anchorUnits": "inches"'+
                        '                  }],'+
                        '                 "radioGroupTabs": [{'+
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
                        '                  "dateSignedTabs": [{'+
                        '                      "anchorString": "~date'+i+'",'+
                        '                       "anchorXOffset": "0",'+
                        '                       "fontSize":      "Size14",'+
                        '                       "fontColor":     "Black",'+
                        '                        "anchorYOffset": "0",'+
                        '                        "anchorIgnoreIfNotPresent": "false",'+
                        '                        "xPosition": "100",'+
                        '                         "yPosition": "72",'+
                        '                         "anchorUnits": "inches"'+
                        '                    }]'+
                        '            }'+
                        '    }';
                    isFirstParent = false;
                }
                
                else{
                    system.debug('@@@@ isFirstParent @@@@'+isFirstParent );
                    system.debug('@@@@ Name @@@@'+Name);
                    system.debug('@@@@ email @@@@'+email);
                    if(recipients != '')
                        recipients = recipients + ',';
                    recipients = recipients + '{'+
                        '      "email": "'+email+'",'+
                        '      "name": "'+Name+'",'+
                        '      "recipientId":"' + i + '",' + clientUserId +
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
                    
                }
                i++;
                
            }
        }
        if(recipientsParticipants != '')
            recipients = recipientsParticipants +','+ recipients; 
        
        //forming payload with the document and recipients.
        String body =  '{'+
            '  "status":"sent",'+
            '  "enableWetSign": "false",'+
            '  "emailBlurb":"Hello,\n'+'\r\n Please sign the attached Liability and Publicity Release Form necessary for '+ childFormInstance.Case__r.Contact.FirstName +'\'s wish. \r\n\n Thank You,\r\n Wish & Volunteer Center",'+
            '  "emailSubject": "Signature Required - Liability And Publicity Release Form",'+
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
            System.debug('Some Exception has occured');
        }
    }
    
    public pageReference redirect(){
        PageReference acctPage = new PageReference ('/'+caseId);
        acctPage.setRedirect(true);
        return acctPage;
    }
    
    
    
    /*This method is used to Identify the users who are all going to sign the document*/
    public pageReference signNowmultiEmail(){
        if(signNowemailMap.size() > 0){
            displaySignNowPopup = true;
            multiPickoptions = new List<SelectOption>();
            for(String currString : signNowemailMap.keySet()){
                if(!holdEmailNameSet.contains(currString )){
                    multiPickoptions.add(new SelectOption(currString,currString ));
                }
            }
            system.debug('@@@@@ graterThan now @@@'+signNowemailMap);
        }
        else{
            
            displayError = true;
            system.debug('@@@@@ lessthan @@@'+displayError );
        }
        return null;
    }          
    
    /*This method is used Sign the document by the selected user. */
    public Pagereference submitAndSign(){
        String account;
        String userName;
        String password;
        String integratorKey;
        String endPointURL;
        List<Contact> relationShipList = new List<Contact>();
        Map<String,DocuSignCredentialsSetting__c> credentialSetting = DocuSignCredentialsSetting__c.getAll();
        Map<Id,Wish_Child_Form__c> wishChildFormMap = new Map<Id,Wish_Child_Form__c>();
        Map<String, Object> results;
        String timmedName = SingerName.trim();
        PageReference reference;
        List<dsfs__DocuSign_Status__c> dsfsList = new List<dsfs__DocuSign_Status__c>();
        if(signNowemailMap.size() > 0){            
            boolean isParent;
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
            }
            catch(Exception e) {
                System.debug('Some Exception has occured');
            }
            Map<String,String> recipientMap = new Map<String,String>();
            Set<String> signerSet = new Set<String>();
            for(Wish_Child_Form__c wishChildForm : [SELECT Id,Name,Case__c,Participant_Name__c,Parent_Gurdian_above_18__c,Parent_Gurdian_above_18_Email__c FROM Wish_Child_Form__c WHERE
                                                    Case__c =: caseId]){
                                                       
                                                          if(wishChildForm.Parent_Gurdian_above_18__c != Null) {                                     
                                                            for(String keys : wishChildForm.Parent_Gurdian_above_18__c .split('#')){
                                                                String name = keys.split('-')[0];
                                                                //String emailadd = keys.split('-')[1];
                                                                recipientMap.put(name.trim(),'PARENT/LEGAL GUARDIAN');
                                                                isFirstParent = true;
                                                                signerSet.add(name); 
                                                            } 
                                                        }
                                                        if(wishChildForm.Participant_Name__c!= Null){
                                                            for(String keys : wishChildForm.Participant_Name__c.split('#')){
                                                                String key = keys.split('::')[0];
                                                                String values = keys.split('::')[1];
                                                                recipientMap.put(key.trim(),'Participant');
                                                                signerSet.add(key); 
                                                            } 
                                                        }
                                                    }
            Wish_Child_Form__c  dbcase = [SELECT Id,Wish_Liability_Envolep__c,LiabilitySignerMapKeyPair__c,Case__c,Hidden_Liability_Envelop_Id_1__c,
                                          Hidden_Liability_Envelop_Id_2__c,Hidden_Liability_Envelop_Id_3__c,Hidden_Liability_SignerMap_Key_1__c,
                                          Hidden_Liability_SignerMap_Key_2__c,Hidden_Liability_SignerMap_Key_3__c,Delivered_Hidden_Envelop_Id__c,Delivered_LiabilitySignerMapKeyPair__c FROM Wish_Child_Form__c WHERE Case__c =: caseId LIMIT 1];
            Set<String> processSet = new Set<String>();
            if(dbcase.LiabilitySignerMapKeyPair__c != Null && dbcase.Wish_Liability_Envolep__c != Null && dbcase.Hidden_Liability_Envelop_Id_1__c == Null &&
               dbcase.Hidden_Liability_SignerMap_Key_1__c == Null )
            {
                
                for(String processName : dbcase.LiabilitySignerMapKeyPair__c.split('#')){
                    String keys = processName.split('-')[0];
                    String value = processName.split('-')[1];
                    String name = Keys.trim();
                    processSet.add(name);
                    
                }
                for(String signNowName : signerSet){
                    if(!processSet.contains(signNowName)){
                        j = 1;
                    }
                }
            }
            if(dbcase.Hidden_Liability_Envelop_Id_1__c != Null && dbcase.Hidden_Liability_SignerMap_Key_1__c != Null)
            {   
                system.debug('@@@@@ ENTER INTO ELSE STATEMENT 2@@@@');
                Set<String> processSetOne = new Set<String>();
                for(String processName : dbcase.Hidden_Liability_SignerMap_Key_1__c.split('#')){
                    String keys = processName.split('-')[0];
                    String value = processName.split('-')[1];
                    String name = Keys.trim();
                    processSetOne.add(name);
                }
                for(String processName : dbcase.LiabilitySignerMapKeyPair__c.split('#')){
                    String keys = processName.split('-')[0];
                    String value = processName.split('-')[1];
                    String name = Keys.trim();
                    processSet.add(name);
                }
                for(String signNowName : signerSet){
                    if(!processSet.contains(signNowName)){
                        if(!processSetOne.contains(signNowName)){
                            j = 2;
                            k = 1;
                        }
                    }
                }
            }
            if(dbcase.Hidden_Liability_Envelop_Id_2__c != Null && dbcase.Hidden_Liability_SignerMap_Key_2__c!= Null){
                
                system.debug('@@@@@ ENTER INTO ELSE STATEMENT 3@@@@');
                Set<String> processSetOne = new Set<String>();
                Set<String> processSetTwo = new Set<String>();
                for(String processName : dbcase.Hidden_Liability_SignerMap_Key_2__c.split('#')){
                    String keys = processName.split('-')[0];
                    String value = processName.split('-')[1];
                    String name = Keys.trim();
                    processSetTwo.add(name);
                }
                for(String processName : dbcase.Hidden_Liability_SignerMap_Key_1__c .split('#')){
                    String keys = processName.split('-')[0];
                    String value = processName.split('-')[1];
                    String name = Keys.trim();
                    processSetOne.add(name);
                }
                for(String processName : dbcase.LiabilitySignerMapKeyPair__c.split('#')){
                    String keys = processName.split('-')[0];
                    String value = processName.split('-')[1];
                    String name = Keys.trim();
                    processSet.add(name);
                }
                for(String signNowName : signerSet){
                    if(!processSet.contains(signNowName)){
                        if(!processSetOne.contains(signNowName)){
                            if(!processSetTwo.contains(signNowName)){
                                j = 3;
                                k = 2;
                            }
                        }
                    }
                }
            }
            if((dbcase.Wish_Liability_Envolep__c == Null && dbcase.LiabilitySignerMapKeyPair__c == Null && j == 0) || (dbcase.Hidden_Liability_Envelop_Id_1__c== Null && dbcase.Hidden_Liability_SignerMap_Key_1__c == Null && j == 1 && k == 0) || 
               (dbcase.Hidden_Liability_Envelop_Id_2__c == Null && dbcase.Hidden_Liability_SignerMap_Key_2__c == Null && j == 2 && k == 1) || (dbcase.Hidden_Liability_Envelop_Id_3__c == Null && dbcase.Hidden_Liability_SignerMap_Key_3__c  == Null && j == 3 && k == 2))
            {
                system.debug('@@@@@ ENTER INTO ELSE STATEMENT 4@@@@');
                for(String currString : recipientMap.Keyset()){
                    if(currString == SingerName && recipientMap.get(SingerName) != 'PARENT/LEGAL GUARDIAN'){
                        DisplayMessage();
                    }
                    else{
                        //displaypopwindow = false;
                    }
                }
                if(displaypopwindow == false){
                    for(String currString : recipientMap.Keyset()){
                        String Name = currString;
                        if(recipientMap.get(Name) == 'PARENT/LEGAL GUARDIAN' && isFirstParent == true && recipientMap.containsKey(SingerName) && Name == SingerName){
                            if(recipients != '')
                                recipients = recipients + ',';
                            recipients = recipients + '{'+
                                '      "email": "NotSent@NoEmail.com",'+
                                '      "name": "'+Name+'",'+
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
                                '                    "mergeField" : {"configurationType":"Salesforce","path":"Case.Option1__c","writeBack":"true","allowSenderToEdit":"true"},'+
                                '                    "anchorIgnoreIfNotPresent": "false",' +
                                '                    "anchorUnits": "inches"},{'+
                                '                    "anchorString": "~initial2",' +
                                '                    "optional"    :  "false",' +
                                '                    "conditionalParentLabel":"Radio Group 1",'+
                                '                    "mergeField" : {"configurationType":"Salesforce","path":"Case.Option2__c","writeBack":"true","allowSenderToEdit":"true"},'+
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
                                system.debug('@@ SignerMap @@'+signersKeyPairMap);
                            isFirstParent = false;
                        }
                        else if(recipientMap.get(Name) == 'PARENT/LEGAL GUARDIAN' && isFirstParent == false){
                            if(recipients != '')
                                recipients = recipients + ',';
                            recipients = recipients + '{'+
                                '      "email": "NotSent@NoEmail.com",'+
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
                            system.debug('### signersKeyPairMap1 ###'+signersKeyPairMap);
                        }
                        else{
                            if(recipients != '')
                                recipients = recipients + ',';
                            recipients = recipients + '{'+
                                '      "email": "NotSent@NoEmail.com",'+
                                '      "name": "'+Name+'",'+
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
                                system.debug('@@ SignerMap2 @@'+signersKeyPairMap);
                        }
                        i++;
                    }
                    //forming payload with the document and recipients.
                    String body =  '{'+
                        '  "status":"sent",'+
                        '  "enableWetSign": "false",'+
                        '  "emailSubject": "Signature Required - Liability And Publicity Release Form",'+
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
                            results = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                            if((String) results.get('envelopeId') != '')
                                envelopeId = (String) results.get('envelopeId');
                            if((String) results.get('status') == 'Sent'){
                                status = 'Agreement sent to email.';
                                dsfs__DocuSign_Status__c dsfs= NEW dsfs__DocuSign_Status__c();
                                dsfs.dsfs__DocuSign_Envelope_ID__c = (String) results.get('envelopeId');
                                dsfs.dsfs__Case__c= caseId;
                                dsfsList.add(dsfs);
                                //Insert dsfs;
                            }
                            else
                                status = (String) results.get('errorCode');
                        }
                    }catch(Exception e){
                        System.debug('Some Exception has occured');
                    }
                } 
            }
            else
            {
                system.debug('@@@@@ ENTER INTO ELSE STATEMENT @@@@');
                if((dbcase.Wish_Liability_Envolep__c != Null || dbcase.Delivered_Hidden_Envelop_Id__c != Null) && dbcase.Hidden_Liability_Envelop_Id_1__c == Null && dbcase.Hidden_Liability_Envelop_Id_2__c == Null && j == 0){
                    displaypopwindow = false;
                    if(dbcase.Wish_Liability_Envolep__c != Null)
                        envelopeId = dbcase.Wish_Liability_Envolep__c ; 
                    if(dbcase.Delivered_Hidden_Envelop_Id__c != Null) 
                        envelopeId = dbcase.Delivered_Hidden_Envelop_Id__c; 
                    system.debug('@@@@@ EnvelopeId @@@'+envelopeId);                  
                    system.debug('@@@@@ Liability @@@'+dbcase.LiabilitySignerMapKeyPair__c);                  
                    if(dbcase.Wish_Liability_Envolep__c != Null){
                        for(String key : dbcase.LiabilitySignerMapKeyPair__c.split('#')){
                            String keys = key.split('-')[0];
                            String value = key.split('-')[1];
                            signersKeyPairMap.put(keys.trim(),value.trim());
                            system.debug('@@ signersKeyPairMap3 @@'+signersKeyPairMap);
                        } 
                    }
                    
                    else if(dbcase.Delivered_Hidden_Envelop_Id__c != Null){
                        for(String key : dbcase.Delivered_LiabilitySignerMapKeyPair__c.split('#')){
                            String keys = key.split('-')[0];
                            String value = key.split('-')[1];
                            signersKeyPairMap.put(keys.trim(),value.trim());
                            system.debug('@@ signersKeyPairMap4 @@'+signersKeyPairMap);
                        } 
                    }
                }
                if(dbcase.Wish_Liability_Envolep__c != Null && dbcase.Hidden_Liability_Envelop_Id_1__c != Null && dbcase.Hidden_Liability_Envelop_Id_2__c== Null ){
                    displaypopwindow = false;
                    envelopeId = dbcase.Hidden_Liability_Envelop_Id_1__c ;
                    for(String key : dbcase.Hidden_Liability_SignerMap_Key_1__c.split('#')){
                        String keys = key.split('-')[0];
                        String value = key.split('-')[1];
                        signersKeyPairMap.put(keys.trim(),value.trim());
                        system.debug('@@ signersKeyPairMap5 @@'+signersKeyPairMap);
                    } 
                }
                if(dbcase.Wish_Liability_Envolep__c != Null && dbcase.Hidden_Liability_Envelop_Id_1__c != Null && dbcase.Hidden_Liability_Envelop_Id_2__c != Null ){
                    displaypopwindow = false;
                    envelopeId = dbcase.Hidden_Liability_Envelop_Id_2__c ;
                    for(String key : dbcase.Hidden_Liability_SignerMap_Key_2__c.split('#')){
                        String keys = key.split('-')[0];
                        String value = key.split('-')[1];
                        signersKeyPairMap.put(keys.trim(),value.trim());
                        system.debug('@@ signersKeyPairMap6 @@'+signersKeyPairMap);
                    }
                }
                if(dbcase.Wish_Liability_Envolep__c != Null && dbcase.Hidden_Liability_Envelop_Id_1__c != Null && dbcase.Hidden_Liability_Envelop_Id_2__c != Null && dbcase.Hidden_Liability_Envelop_Id_3__c != Null){
                    displaypopwindow = false;
                    envelopeId = dbcase.Hidden_Liability_Envelop_Id_3__c ;
                    for(String key : dbcase.Hidden_Liability_SignerMap_Key_3__c .split('#')){
                        String keys = key.split('-')[0];
                        String value = key.split('-')[1];
                        signersKeyPairMap.put(keys.trim(),value.trim());
                        system.debug('@@ signersKeyPairMap7 @@'+signersKeyPairMap);
                    }
                }
            }
        }
        Wish_Child_Form__c  dbcase = [SELECT Id,Wish_Liability_Envolep__c,LiabilitySignerMapKeyPair__c,Case__c,Hidden_Liability_Envelop_Id_1__c,
                                      Hidden_Liability_Envelop_Id_2__c,Hidden_Liability_Envelop_Id_3__c,Hidden_Liability_SignerMap_Key_1__c,
                                      Hidden_Liability_SignerMap_Key_2__c,Hidden_Liability_SignerMap_Key_3__c,Hidden_Email_List__c,Hidden_Name_List__c FROM Wish_Child_Form__c WHERE Case__c =: caseId LIMIT 1];
        for(DocuSignCredentialsSetting__c credentialIns : credentialSetting.values()){
            userName = credentialIns.name;
            account  = credentialIns.account__c;
            password = credentialIns.Password__c;
            integratorKey  = credentialIns.IntegratorKey__c;
            endPointURL = credentialIns.end_Point__c;
        }
        
        if(displaypopwindow == false){
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
            system.debug('### SingerName ###'+SingerName);
            system.debug('### signersKeyPairMap ###'+signersKeyPairMap);
            system.debug('### signersKeyPairMap.get(timmedName) ###'+signersKeyPairMap.get(timmedName));
            jsonPayload = '{'+
                '    "userName": "'+SingerName+'",'+
                '    "email": "NotSent@NoEmail.com",'+
                '    "recipientId": "'+signersKeyPairMap.get(timmedName)+'",'+
                '    "clientUserId": "'+signersKeyPairMap.get(timmedName)+'",'+
                '    "authenticationMethod": "None",'+
                '   "returnUrl": "'+baseUrl +'/apex/WishLiabilityForm_VF?Id='+CaseId+'"'+   
                '}'; 
            request.setBody(jsonPayload);
            response = httprequest.send(request);  
           system.debug('@@@ result @@@'+results);
            results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            //signersKeyPairMap.remove(SingerName);
            String sign;
            for(String name : signersKeyPairMap.KeySet()){
                if(sign == '' || sign == Null)
                    sign= name +' - '+ signersKeyPairMap.get(name);
                else
                    sign = sign+'#'+ name+' - '+ signersKeyPairMap.get(name);
            }
            Wish_Child_Form__c updateChildForm = new Wish_Child_Form__c();
            updateChildForm.Id = dbcase.id;
            if(dbcase.LiabilitySignerMapKeyPair__c == Null && dbcase.Wish_Liability_Envolep__c == Null &&
               dbcase.Hidden_Liability_SignerMap_Key_1__c == Null && dbcase.Hidden_Liability_Envelop_Id_1__c == Null && dbcase.Hidden_Liability_Envelop_Id_2__c == Null && dbcase.Hidden_Liability_SignerMap_Key_2__c == Null){
                   updateChildForm.LiabilitySignerMapKeyPair__c = sign;
                   updateChildForm.Wish_Liability_Envolep__c = envelopeId;
                   wishChildFormMap.put(updateChildForm.Id,updateChildForm); 
               }
            
            if(dbcase.LiabilitySignerMapKeyPair__c != Null && dbcase.Wish_Liability_Envolep__c != Null && dbcase.Hidden_Liability_SignerMap_Key_1__c == Null && dbcase.Hidden_Liability_Envelop_Id_1__c == Null
               && dbcase.Hidden_Liability_Envelop_Id_2__c == Null && dbcase.Hidden_Liability_SignerMap_Key_2__c == Null && j == 1 && k == 0){
                   
                   updateChildForm.Hidden_Liability_SignerMap_Key_1__c = sign;
                   updateChildForm.Hidden_Liability_Envelop_Id_1__c = envelopeId;
                   wishChildFormMap.put(updateChildForm.Id,updateChildForm); 
               }
            
            if(dbcase.LiabilitySignerMapKeyPair__c != Null && dbcase.Wish_Liability_Envolep__c != Null && dbcase.Hidden_Liability_Envelop_Id_2__c == Null && dbcase.Hidden_Liability_SignerMap_Key_2__c == Null &&
               dbcase.Hidden_Liability_SignerMap_Key_1__c != Null && dbcase.Hidden_Liability_Envelop_Id_1__c != Null && j == 2 && k == 1){
                   updateChildForm.Hidden_Liability_SignerMap_Key_2__c = sign;
                   updateChildForm.Hidden_Liability_Envelop_Id_2__c = envelopeId;
                   wishChildFormMap.put(updateChildForm.Id,updateChildForm); 
               }
            if(dbcase.LiabilitySignerMapKeyPair__c != Null && dbcase.Wish_Liability_Envolep__c != Null && dbcase.Hidden_Liability_Envelop_Id_2__c != Null && dbcase.Hidden_Liability_SignerMap_Key_2__c != Null &&
               dbcase.Hidden_Liability_SignerMap_Key_1__c != Null && dbcase.Hidden_Liability_Envelop_Id_1__c  != Null && dbcase.Hidden_Liability_Envelop_Id_3__c != Null && dbcase.Hidden_Liability_SignerMap_Key_3__c != Null && j == 3 && k == 2){
                   updateChildForm.Hidden_Liability_SignerMap_Key_3__c = sign;
                   updateChildForm.Hidden_Liability_Envelop_Id_3__c = envelopeId;
                   wishChildFormMap.put(updateChildForm.Id,updateChildForm); 
               }
            
            if(dsfsList.size() > 0)
                insert dsfsList;
            if(wishChildFormMap.size() > 0){
                update wishChildFormMap.Values();
            }
            reference=new PageReference((String) results.get('url'));
            reference.setRedirect(true);
        }
        return reference;
    }
    
    /*This method will display popup messages*/
    public pageReference displayMessage(){
        displaySignNowPopup = false;
        displaypopwindow = true;
        return null;
    }
}