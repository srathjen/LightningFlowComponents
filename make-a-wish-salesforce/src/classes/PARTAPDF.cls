public class PARTAPDF
{
    public string leadId{get;set;}
    public string travelAlg{get;set;}
    public list<labelwrapper> wrapList{get;set;}
    public Lead currLead {get;set;}
    public String currentCondition {get;set;}
    public List<Diagnosis_Verification__c> questionList {get;set;}
    public PARTAPDF(ApexPages.StandardController controller) {
        if(ApexPages.currentPage().getParameters().get('Id') != Null)
            leadId =  ApexPages.currentPage().getParameters().get('Id');
        //currLead = (Lead)controller.getRecord();
        //leadId = currLead.Id;
        wrapList = new list<labelwrapper>();
        
        if(leadId != Null)
        {
            questionList = new List<Diagnosis_Verification__c>(); 
            System.debug('>>>>>>>>>>!!!!!!!!!!!!!!!!!!!!!!!!!');
            currLead = [SELECT id,Email,FirstName,Please_Explain_Deteriorate__c,Medical_Questions__c,Child_Age__c,Current_Condition__c,
                        DOB__c,Child_Middle_Initial__c,LastName,Gender__c,Parent_First_Name__c,
                        Parent_Last_Name__c,Treating_Medical_Professional_First_Name__c,Treating_Medical_Professional_Last_Name__c,
                        Treating_Medical_Professional_Phone__c,Treating_Medical_Professional_Email__c,
                        Hospital_Treatment_Facility_Treating__c,Travel_algorithm__c,RFI_Form_Info_Hidden__c,
                        Is_We_Need_To_Expedite_The_Process__c,Please_Explain__c,Will_Child_s_Condition_Deteriorate__c,Communication__c,I_am_Recognized_To_Practice_As_a__c,I_m_Part_of_The_Treating_HealthCare_Team__c ,Is_in_a_Comatose_Vegetative_State__c
                        from Lead WHERE id = :leadId limit 1];
            
            System.debug('------currLead--------'+currLead);
            if(currLead.Medical_Questions__c != Null)
            {
                for(String currString : currLead.Medical_Questions__c.split('<br>'))
                {
                    
                    String [] labelString = currString.split(':');
                    if(labelString.size() == 2)
                    {
                        labelwrapper currWrap = new labelwrapper();
                        currWrap.label = labelString[0];
                        currWrap.value = labelString[1];
                        wrapList.add(currWrap);
                    }
                    
                }
            }
            
            if((!String.isEmpty(currLead.Current_Condition__c)) && currLead.Current_Condition__c.contains(';')) {
                Integer i = 0;
                currentCondition = '';
                for(String currentSplitString : currLead.Current_Condition__c.split(';')) {
                    if(!String.isEmpty(currentSplitString)) {
                        currentCondition += i+1 +'. '+ currentSplitString + '\n';
                        i++;
                    }
                }
            }
            
            /*questionList = [SELECT Id, ICD_Code__c, Primary_Diagnosis__c, Lead__c, Medical_Question__c, Medical_Question_Answer__c, Medical_Question__r.Question__c,
Epilepsy_Value__c FROM Diagnosis_Verification__c WHERE Lead__c =:  leadId];*/
            
            for(Diagnosis_Verification__c medicQues : [SELECT Id, ICD_Code__c, Primary_Diagnosis__c, Lead__c, Medical_Question__c, Medical_Question_Answer__c, Medical_Question__r.Question__c,
                                                       Epilepsy_Value__c FROM Diagnosis_Verification__c WHERE Lead__c =:  leadId]) {
                                                           String ques = medicQues.Medical_Question__r.Question__c.replace(' [child\'s name] ', ' ' +currLead.FirstName+ ' ' +currLead.LastName).replace(' (child\'s name) ', currLead.FirstName+' '+currLead.LastName);
                                                           
                                                           medicQues.Medical_Question__r.Question__c = ques;
                                                           questionList.add(medicQues);
                                                           
                                                       }
            /*  {
if((currRec.medical_question__r.name).contains('name'))
{
// currRec.medical_question__r.name.replaceAll('name',currLead.Name);

}
questionList.add(currRec);
} */
            
        }
        
    }
    
    public pageReference SubmitSign(){
        String account;
        String UserName;
        String Password;
        String IntegratorKey;
        String endPointURL;
        
        Map<String,DocuSignCredentialsSetting__c> credentialSetting = DocuSignCredentialsSetting__c.getAll();
        //String currentRequestURL = URL.getSalesforceBaseUrl().toExternalForm();
        String currentRequestURL =   'https://fullcopy-wish.cs52.force.com';
        for(DocuSignCredentialsSetting__c credentialIns : credentialSetting.values()){
            UserName = credentialIns.name;
            account  = credentialIns.account__c;
            Password = credentialIns.Password__c;
            IntegratorKey  = credentialIns.IntegratorKey__c;
            endPointURL = credentialIns.end_Point__c;
        }
        string endpoint = endPointURL+'/accounts/'+account+'/envelopes';
        String authorizationHeader = '<DocuSignCredentials><Username>'+UserName+'</Username><Password>'+Password+'</Password><IntegratorKey>'+IntegratorKey+'</IntegratorKey></DocuSignCredentials>';
        String boundary = 'AAA';
        
        Pagereference PDF = Page.LeadPartA_ApprovalForm_VF_PDF;
        PDF.getParameters().put('id',currLead.id);
        
        String documentPDF;
        
        try {
            documentPDF = EncodingUtil.base64Encode(PDF.getContentAsPDF());
            
        }catch(Exception e) {
            // Generic exception handling code here.
        }
        system.debug('+r.email'+currLead.Treating_Medical_Professional_Email__c); 
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
            '    "signers" : [{'+
            '      "email": "'+currLead.Treating_Medical_Professional_Email__c+'",'+
            '      "name": "'+currLead.Treating_Medical_Professional_First_Name__c+' '+currLead.Treating_Medical_Professional_Last_Name__c+'",'+
            '      "recipientId":"1",'+
            '      "clientUserId":"1",'+
            '      "tabs": {'+
            '                "signHereTabs": [{'+
            '                    "anchorString": "~s1",'+
            '                    "anchorXOffset": "0.6",'+
            '                    "anchorYOffset": "0.1",'+
            '                    "anchorIgnoreIfNotPresent": "false",'+
            '                    "anchorUnits": "inches"'+
            '                }]'+
            '            }'+
            '    }]'+
            '  }'+
            '}';
        
        String header = '--'+boundary+'\nContent-Type: application/json\nContent-Disposition: form-data';
        String jsonBody = header +'\n\n'+body+'\n\n--'+boundary+'--';
        system.debug(jsonBody);
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
        
        res = http.send(req);
        system.debug(res.getBody());
        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        
        if((String) results.get('envelopeId')!=''){
            String env = (String) results.get('envelopeId');
            
            string endpoint2 = endPointURL+'/accounts/'+account+'/envelopes/'+env+'/views/recipient';
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
            jsonPayload = '{'+
                '    "userName": "'+ currLead.Treating_Medical_Professional_First_Name__c+' '+currLead.Treating_Medical_Professional_Last_Name__c+'",'+ 
                '    "email": "'+currLead.Treating_Medical_Professional_Email__c+'",'+
                '    "recipientId": "1",'+
                '    "clientUserId": "1",'+
                '    "authenticationMethod": "None",'+
                '    "returnUrl": "'+currentRequestURL+'/verification_success'+'"'+
                '}';     
            request.setBody(jsonPayload);
            response = httprequest.send(request); 
            system.debug('@@@@@@@ response @@@@@@@@'+response.getBody());
            results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            system.debug('@@@@@@@ results  @@@@@@@@'+results);
            if((String) results.get('url') != '' || (String) results.get('url') != null){
                
                dsfs__DocuSign_Status__c dsfs= NEW dsfs__DocuSign_Status__c();
                dsfs.dsfs__DocuSign_Envelope_ID__c = env;
                dsfs.dsfs__Lead__c= currLead.Id;
                Insert dsfs;  
                
                
                
                PageReference reference=new PageReference((String) results.get('url'));
                reference.setRedirect(true);
                return reference;
                
            }
        }
        
        return null;
    }
    
    public pageReference cancel(){
        String currentRequestURL =   'https://fullcopy-wish.cs52.force.com/';
        PageReference reference=new PageReference(currentRequestURL +'/LeadPartA_ApprovalFormClone_VF_V1?leadid='+currLead.id);
        reference.setRedirect(true);
        return reference;
    }
    public class labelwrapper
    {
        public string label{get;set;}
        public string value{get;set;}
        
    }
    
}