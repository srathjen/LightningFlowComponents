/*****************************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kanagaraj & Vennila
Date        : 5/23/2016
Location    : This class referred in the Application_VF page.
Description : This Application VF and Controller used to capture the volunteer details from the portal and Update
their corresponding volunteer details inside the salesforce.
In this page, volunteer role is displaying the values based on the  volunteer chapter roles. If the volunteer selects 
the roles and hit [Save] button, It would update the value in Volunteer Role field as well as creating 
Volunteer Role custom record.
If the user enters all the mandatory fields on the form and hit [Save] button, It will display [Submit & Sign] button
on the detailed mode. else [Submit & Sign] won't display. 
If the user hits [Submit & Sign] button, It will redirect user to docusign page for capturing volunteer sign. Once sign completed,
It will create Conflict of Interst and Docusign status record with atttachment.
*******************************************************************************************************************/

public class Application_AC {
    
    public Contact currentVolunteer { get; set; }
    public Boolean saveMode { get; set; }
    public Boolean editMode { get; set; }
    public Boolean showSubmitButton { get; set; }
    public Id contactId;
    public Id currAccountId;
    public String dynamicName { get; set; }
    public String applicationDynamicContent { get; set; }
    public Boolean submitDisable { get; set; }
    public Id volunteerRecordTypeId = Constant_AC.VOLUNTEER_RT_ID;
    public Id boardMemberContactRecTyped = Constant_AC.BOARD_MEMBER_RT_ID;
    public Boolean isSigned { get; set; }
    public Set<String> chaptersNameSet = new Set<String>();
    public Boolean showSubmitandSign { get; set; }
    public List<String> volRoles { get; set; }
    public List<String> professionalSkillsList { get; set; }
    public List<String> langToRead { get; set; }
    public List<String> langToWrite { get; set; }
    public List<String> langToSpeak { get; set; }
    public List<String> langToUndetstand { get; set; }
    public List<String> languagesList { get; set; }
    public List<String> howKnowAbtMAWA { get; set; }
    public List<roleWrapper> roleDiscriptionList { get; set; }
    public Boolean displayPopup { get; set; }
    public Set<String> roleNameSet { get; set; }
    public Boolean bgTabPermission { get; set; }
    public Boolean trainingTabVisible { get; set; }
    public Boolean displaySignNowPopup { get; set; }
    public String contactName { get; set; }
    private Boolean showEdit { get; set; }
    private String signingStatus { get; set; }
    
    public Application_AC() {
        contactId =  Utils.currentUser.ContactId;
        showSubmitandSign = false;
        displaySignNowPopup = false;
        volRoles = new List<String>();
        langToRead = new List<String>();
        langToSpeak = new List<String>();
        langToWrite = new List<String>();
        langToUndetstand = new List<String>();
        languagesList = new List<String>();
        howKnowAbtMAWA = new List<String>();
        professionalSkillsList = new List<String>();
        showEdit = false;
        signingStatus = '';
        
        if(ApexPages.currentPage().getParameters().get('showeditMode') != null) {
            showEdit = Boolean.valueOf(ApexPages.currentPage().getParameters().get('showeditMode'));
        }
        if(ApexPages.currentPage().getParameters().get('event') != null) {
            signingStatus = ApexPages.currentPage().getParameters().get('event');
        }
        if(ApexPages.currentPage().getParameters().get('bgRequired') != null) {
            bgTabPermission = Boolean.valueOf(ApexPages.currentPage().getParameters().get('bgRequired'));
        }
        if(ApexPages.currentPage().getParameters().get('trainingRequired') != null) {
            trainingTabVisible = Boolean.valueOf(ApexPages.currentPage().getParameters().get('trainingRequired'));
        }
        if(contactId == null) {
            currentVolunteer = new Contact();
            currentVolunteer.RecordTypeId = volunteerRecordTypeId;
        } else {
            currentVolunteer = [
                SELECT Id,Title, Salutation,RecordTypeId,FirstName,Middle_Name__c,LastName,State_Employer__c,Preferred_Name__c,Birth_Month__c,Birth_Day__c,HomePhone,Alternate_Phone_Type__c,npe01__PreferredPhone__c,MobilePhone,
                OtherPhone,Email,I_m_on_LinkedIn__c,How_did_you_hear_about_Make_A_Wish__c,MailingStreet,MailingCity,mailingstatecode,MailingCountrycode,MailingPostalCode,
                Employer__c,Position__c,Street_Employer__c,City_Employer__c,Zip_Employer__c,May_We_Contact_You_at_Work__c,Interested_involved_with_Make_A_Wish__c,
                Emergency_Contact__c,Emergency_Contact_Phone__c,Professional_Skills__c,Language__c,Language_Notes__c,Read__c,Write__c,Speak__c,Understand__c,
                Volunteer_Role__c,is_Application__c,npe01__WorkPhone__c,MailingState,Emergency_Contact_Relationship__c,county__c,Professional_Skills_Other_Notes__c,
                How_did_you_know_MAWA_Other_Notes__c
                FROM Contact
                WHERE (RecordTypeId = :volunteerRecordTypeId OR RecordTypeId = :boardMemberContactRecTyped) 
                AND Id = :contactId
            ];
            currentVolunteer.MailingState = currentVolunteer.MailingState;
            currentVolunteer.Emergency_Contact_Relationship__c = currentVolunteer.Emergency_Contact_Relationship__c;
            currentVolunteer.State_Employer__c = currentVolunteer.State_Employer__c;
            currentVolunteer.I_m_on_LinkedIn__c = currentVolunteer.I_m_on_LinkedIn__c;
            currentVolunteer.May_We_Contact_You_at_Work__c = currentVolunteer.May_We_Contact_You_at_Work__c;
            currentVolunteer.Interested_involved_with_Make_A_Wish__c = currentVolunteer.Interested_involved_with_Make_A_Wish__c;
            currentVolunteer.Salutation = currentVolunteer.Salutation;
            currentVolunteer.Birth_Month__c = currentVolunteer.Birth_Month__c;
            if(currentVolunteer.Birth_Day__c != null) {
                currentVolunteer.Birth_Day__c = currentVolunteer.Birth_Day__c;
            }
            contactName = currentVolunteer.Name;
            
            if(currentVolunteer.Volunteer_Role__c != null) {
                for(String role : currentVolunteer.Volunteer_Role__c.split(';')) {
                    volRoles.add(role);
                }
            }
            if(currentVolunteer.read__c != null) {
                for (String read : currentVolunteer.read__c.split(';')) {
                    langToRead.add(read);
                }
            } else {
                langToRead.add('English');
            }
            if(currentVolunteer.Speak__c != null) {
                for(String speak : currentVolunteer.Speak__c.split(';')) {
                    langToSpeak.add(speak);
                }
            } else {
                langToSpeak.add('English');
            }
            if(currentVolunteer.Write__c != null) {
                for(String write : currentVolunteer.Write__c.split(';')) {
                    langToWrite.add(write);
                }
            } else {
                langToWrite.add('English');
            }
            if(currentVolunteer.Understand__c != null) {
                for(String understand : currentVolunteer.Understand__c.split(';')) {
                    langToUndetstand.add(understand);
                }
            } else {
                langToUndetstand.add('English');
            }
            if(currentVolunteer.Language__c != null) {
                for(String lang : currentVolunteer.Language__c.split(';')) {
                    languagesList.add(lang);
                }
            } else {
                languagesList.add('English');
            }
            if(currentVolunteer.How_did_you_hear_about_Make_A_Wish__c != null) {
                for(String mwa : currentVolunteer.How_did_you_hear_about_Make_A_Wish__c.split(';')) {
                    howKnowAbtMAWA.add(mwa);
                }
            }
            if(currentVolunteer.Professional_Skills__c != null) {
                for(String mwa : currentVolunteer.Professional_Skills__c.split(';')) {
                    professionalSkillsList.add(mwa);
                }
            }
        }
        if(signingStatus == 'signing_complete' || currentVolunteer.is_Application__c == 'Complete' 
           || currentVolunteer.is_Application__c == 'Approved') {
               isSigned = true;
               editMode = true;
           } else if(currentVolunteer.is_Application__c == 'Submit' || currentVolunteer.is_Application__c == 'Fully Submit' 
                     || currentVolunteer.is_Application__c == 'Partial Submit' || currentVolunteer.is_Application__c == 'Rejected') {
                         isSigned = false;
                         editMode = false;
                         saveMode = true;
                     }
        if(currentVolunteer.is_Application__c == '' || currentVolunteer.is_Application__c == null || showEdit == true) {
            saveMode = true;
        }
        for(npe5__Affiliation__c currContactAffiliation : [
            SELECT Id, npe5__Primary__c, npe5__Organization__c, npe5__Contact__c
            FROM npe5__Affiliation__c
            WHERE npe5__Contact__c = :contactId
        ]) {
            if(currContactAffiliation.npe5__Primary__c == true) {
                currAccountId = currContactAffiliation.npe5__Organization__c;
            }
            chaptersNameSet.add(currContactAffiliation.npe5__Organization__c);
        }
        if(currAccountId != null) {
            Id nationalRT = Constant_AC.NATIONAL_RT_ID;
            List<Dynamic_Content__c> dynamicContent = [
                SELECT Id, Application_Overview__c, Chapter_Name__c
                FROM Dynamic_Content__c
                WHERE Active__c = true 
                AND RecordTypeId = :nationalRT
            ];
            if(!dynamicContent.isEmpty()) {
                applicationDynamicContent = dynamicContent[0].Application_Overview__c;
            }
        }
    }

    /**
    *  Saves the current volunteer contact information
    */
    public PageReference saveRec() {
        try {
            if(!howKnowAbtMAWA.isEmpty()) {
                currentVolunteer.How_did_you_hear_about_Make_A_Wish__c = buildStringFromList(howKnowAbtMAWA);
            }
            if(!languagesList.isEmpty()) {
                currentVolunteer.Language__c = buildStringFromList(languagesList);
            }
            if(!langToRead.isEmpty()) {
                currentVolunteer.read__c = buildStringFromList(langToRead);
            }
            if(!langToWrite.isEmpty()) {
                currentVolunteer.write__c = buildStringFromList(langToWrite);
            }
            if(!langToSpeak.isEmpty()) {
                currentVolunteer.speak__c = buildStringFromList(langToSpeak);
            }
            if(!langToUndetstand.isEmpty()) {
                currentVolunteer.Understand__c = buildStringFromList(langToUndetstand);
            }
            if(!professionalSkillsList.isEmpty()) {
                currentVolunteer.Professional_Skills__c = buildStringFromList(professionalSkillsList);
            }
            if(!volRoles.isEmpty()) {
                currentVolunteer.volunteer_role__c = buildStringFromList(volRoles);
            }
            if(currentVolunteer.npe01__PreferredPhone__c == null || currentVolunteer.npe01__PreferredPhone__c == '') {
                currentVolunteer.npe01__PreferredPhone__c = 'Mobile';
            }
            if(currentVolunteer.LastName == null || currentVolunteer.Email == null || currentVolunteer.Title == null 
               || currentVolunteer.FirstName == null || currentVolunteer.Birth_Month__c == null 
               || currentVolunteer.Birth_Day__c == null || currentVolunteer.npe01__PreferredPhone__c == null 
               || currentVolunteer.HomePhone == null || currentVolunteer.HomePhone == '' 
               || currentVolunteer.I_m_on_LinkedIn__c == null || currentVolunteer.How_did_you_hear_about_Make_A_Wish__c == null 
               || currentVolunteer.MailingStreet == null || currentVolunteer.MailingCity == null
               || currentVolunteer.county__c == null || currentVolunteer.MailingPostalCode == null 
               || currentVolunteer.mailingstatecode == null || currentVolunteer.Emergency_Contact__c == null 
               || currentVolunteer.Emergency_Contact_Relationship__c == null || currentVolunteer.Emergency_Contact_Phone__c == null 
               || currentVolunteer.Read__c == null || currentVolunteer.Write__c == null || currentVolunteer.Speak__c == null 
               || currentVolunteer.Understand__c == null || currentVolunteer.Language__c == null 
               || currentVolunteer.volunteer_role__c == null) {
                   currentVolunteer.is_Application__c = 'Partial Submit';
               } else {
                   currentVolunteer.is_Application__c = 'Fully Submit';
               }
            
            update currentVolunteer;
            
            if(!displaySignNowPopup) {
                PageReference pr = new PageReference('/apex/Application_VF?showeditMode=true' + '&bgRequired=' + bgTabPermission + '&trainingRequired=' + trainingTabVisible);
                pr.setRedirect(true);
                return pr;
            }
            return null;
        } catch (Exception ex) {
            String logValue;
            logValue = String.valueOf(currentVolunteer);
            new ApexDebugLog().createLog(new ApexDebugLog.Error('Application_AC', 'saveRec', currentVolunteer.Id, ex, logValue));
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
            ApexPages.addMessage(myMsg);
            return null;
        }
    }

    /**
    *  Checks if pending approval process exists for volunteer before displaying docusign page
    */
    public void confirmSign() {
        List<ProcessInstance> approvals = [
            SELECT TargetObjectId, Status, ProcessDefinitionId, ProcessDefinition.Name
            FROM ProcessInstance
            WHERE TargetObjectId = :currentVolunteer.Id 
            AND Status = 'Pending'];
        if(!approvals.isEmpty()) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, ' This record is already in approval process'));
        } else {
            displaySignNowPopup = true;
            saveRec();
        }
    }

    /**
    * Redirects user to docusign page when all required fields are populated
    */
    public PageReference submitAndSign() {
        String account;
        String IntegratorKey;
        Map<String, DocuSignCredentialsSetting__c> credentialSetting = DocuSignCredentialsSetting__c.getAll();
        String recId;
        try {
            for(DocuSignCredentialsSetting__c credentialIns : credentialSetting.values()) {
                account = credentialIns.account__c;
                IntegratorKey = credentialIns.IntegratorKey__c;
            }
            String authorizationHeader = '<DocuSignCredentials><Username>{!$Credential.Username}</Username><Password>{!$Credential.Password}</Password><IntegratorKey>' + IntegratorKey + '</IntegratorKey></DocuSignCredentials>';
            String boundary = 'AAA';
            Pagereference PDF = Page.Application_PDF_VF;
            PDF.getParameters().put('Id', currentVolunteer.Id);
            String documentPDF;
            if(!Test.isRunningTest()) {
                documentPDF = EncodingUtil.base64Encode(PDF.getContentAsPDF());
            }
            String body = '{' +
                '  "status":"sent",' +
                '  "enableWetSign": "false",' +
                '  "emailBlurb":"Volunteer Application Form",' +
                '  "emailSubject": "Volunteer Application Form",' +
                '  "enforceSignerVisibility":"True",' +
                '  "documents": [{' +
                '      "name": "document.pdf",' +
                '      "documentId":"1",' +
                '      "order":"1",' +
                '      "documentBase64":"' + documentPDF + '"' +
                '  }],' +
                '"recipients": {' +
                '    "signers" : [{' +
                '      "email": "' + currentVolunteer.email + '",' +
                '      "name": "' + currentVolunteer.FirstName + ' ' + currentVolunteer.LastName + '",' +
                '      "recipientId":"1",' +
                '      "clientUserId":"1",' +
                '      "tabs": {' +
                '                "signHereTabs": [{' +
                '                    "anchorString": "~s1",' +
                '                    "anchorXOffset": "0.1",' +
                '                    "anchorYOffset": "0.1",' +
                '                    "anchorIgnoreIfNotPresent": "false",' +
                '                    "anchorUnits": "inches"' +
                '                }],' +
                '                "dateSignedTabs": [{' +
                '                      "anchorString": "~date",' +
                '                       "anchorXOffset": "0",' +
                '                       "fontSize":      "Size14",' +
                '                       "fontColor":     "Black",' +
                '                       "fonttype":     "Helvetica",' +
                '                        "anchorYOffset": "0",' +
                '                        "anchorIgnoreIfNotPresent": "false",' +
                '                        "xPosition": "100",' +
                '                        "yPosition": "72",' +
                '                        "anchorUnits": "inches"' +
                '                    }]' +
                '            }' +
                '    }]' +
                '  }' +
                '}';
            
            String header = '--' + boundary + '\nContent-Type: application/json\nContent-Disposition: form-data';
            String jsonBody = header + '\n\n' + body + '\n\n--' + boundary + '--';
            
            //Callout to Docusign
            HttpRequest req = new HttpRequest();
            req.setHeader('X-DocuSign-Authentication', authorizationHeader);
            req.setHeader('Accept', 'application/json');
            req.setHeader('Host', 'demo.docusign.net');
            req.setHeader('Content-Length', '162100');
            req.setHeader('Content-Type', 'multipart/form-data; boundary=' + boundary);
            req.setEndpoint('Callout:Docusign_Credential/accounts/' + account + '/envelopes');
            req.setMethod('POST');
            req.setBody(jsonBody);
            Http http = new Http();
            HttpResponse res;
            res = http.send(req);
            if(res.getstatusCode() != 200 && res.getstatusCode() != 201) {
                displaySignNowPopup = false;
                new ApexDebugLog().createLog(new ApexDebugLog.Error('Application_AC', 'SubmitAndSign', recId, null, res.getBody()));
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
                ApexPages.addMessage(myMsg);
                return null;
            } else {
                Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                if((String) results.get('envelopeId') != '') {
                    String env = (String)results.get('envelopeId');
                    HttpRequest request = new HttpRequest();
                    request.setHeader('X-DocuSign-Authentication', authorizationHeader);
                    request.setHeader('Accept', 'application/json');
                    request.setHeader('Host', 'demo.docusign.net');
                    request.setHeader('Content-Length', '162100');
                    request.setHeader('Content-Type', 'application/json');
                    request.setMethod('POST');
                    Http httprequest = new Http();
                    HttpResponse response;
                    request.setEndpoint('Callout:Docusign_Credential/accounts/' + account + '/envelopes/' + env + '/views/recipient');
                    String jsonPayload;
                    jsonPayload = '{' +
                        '    "userName": "' + currentVolunteer.FirstName + ' ' + currentVolunteer.LastName + '",' +
                        '    "email": "' + currentVolunteer.email + '",' +
                        '    "recipientId": "1",' +
                        '    "clientUserId": "1",' +
                        '    "authenticationMethod": "None",' +
                        '    "returnUrl": "' + Endpoints__c.getInstance().Site_URL__c + '/Application_VF"' +
                        '}';
                    request.setBody(jsonPayload);
                    response = httprequest.send(request);
                    if(res.getstatusCode() != 200 && res.getstatusCode() != 201) {
                        displaySignNowPopup = false;
                        new ApexDebugLog().createLog(new ApexDebugLog.Error('Application_AC', 'SubmitAndSign', recId, null, string.valueof(response.getstatusCode())));
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
                        ApexPages.addMessage(myMsg);
                        return null;
                    } else {
                        results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                        if((String)results.get('url') != '' || (String)results.get('url') != null) {
                            dsfs__DocuSign_Status__c dsfs = new dsfs__DocuSign_Status__c();
                            dsfs.dsfs__DocuSign_Envelope_ID__c = env;
                            dsfs.Docusign_Hidden_Contact__c = currentVolunteer.id;
                            insert dsfs;
                            if(dsfs.Id != null) {
                                currentVolunteer.is_Application__c = 'Submit';
                                currentVolunteer.onboarding_status__c = 'Application';
                                if (!Test.isRunningTest()) {
                                    recId = currentVolunteer.Id;
                                    update currentVolunteer;
                                }
                            }
                            PageReference reference = new PageReference((String)results.get('url'));
                            reference.setRedirect(true);
                            return reference;
                        }
                    }
                }
            }
        } catch (Exception ex) {
            String logValue = String.valueOf(currentVolunteer);
            new ApexDebugLog().createLog(new ApexDebugLog.Error('Application_AC', 'SubmitAndSign', currentVolunteer.Id, ex, logValue));
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
            ApexPages.addMessage(myMsg);
        }
        return null;
    }

    /**
    * Allows volunteer to edit their record details 
    */
    public PageReference editRec() {
        PageReference pageRef = new PageReference('/apex/Application_VF?showeditMode=True' + '&bgRequired=' + bgTabPermission + '&trainingRequired=' + trainingTabVisible);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    /**
    *  Displays the Role Description on the Application Page
    */
    public void displayDescription() {
        try {
            displayPopup = true;
            roleDiscriptionList = new List<roleWrapper>();
            for (Chapter_Role__c currRole : [
                SELECT Id, Role_Name__r.Name, Role_Name__r.Description__c
                FROM Chapter_Role__c
                WHERE Chapter_name__c IN :chaptersNameSet 
                AND Role_Name__r.Exclude_from_Application__c = false
                ORDER BY Role_Name__r.Name
            ]) {
                roleWrapper wrap = new roleWrapper();
                wrap.roleName = currRole.Role_Name__r.Name;
                wrap.roleDescription = currRole.Role_Name__r.Description__c;
                roleDiscriptionList.add(wrap);
            }
        } catch (Exception ex) {
            String logValue = string.valueOf(currentVolunteer);
            new ApexDebugLog().createLog(new ApexDebugLog.Error('Application_AC', 'DisplayDescription', currentVolunteer.id, ex, logValue));
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
            ApexPages.addMessage(myMsg);
        }
    }
    
    /**
    *  Close popup for submit and sign warning
    */
    public void hidePopup() {
        displaySignNowPopup = false;
    }
    
    /**
    * Retrieves values 1-31 for birth day option
    */
    public List<SelectOption> getDays() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Day', 'Day'));
        for(Integer i = 0; i <= 31; i++) {
            options.add(new SelectOption(String.valueOf(i), String.valueOf(i)));
        }
        return options;
    }
    
    /**
    * Retrieves month values for birth month option
    */
    public List<SelectOption> getMonths() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Month', 'Month'));
        options.add(new SelectOption('January', 'January'));
        options.add(new SelectOption('February', 'February'));
        options.add(new SelectOption('March', 'March'));
        options.add(new SelectOption('April', 'April'));
        options.add(new SelectOption('May', 'May'));
        options.add(new SelectOption('June', 'June'));
        options.add(new SelectOption('July', 'July'));
        options.add(new SelectOption('August', 'August'));
        options.add(new SelectOption('September', 'September'));
        options.add(new SelectOption('October', 'October'));
        options.add(new SelectOption('November', 'November'));
        options.add(new SelectOption('December', 'December'));
        return options;
    }
    
    /**
    * Retrieves Role values to display as options
    */
    public List<SelectOption> getRoles() {
        List<SelectOption> options = new List<SelectOption>();
        for(Chapter_Role__c currRole : [
            SELECT Id, Role_Name__c, Role_Name__r.Name, Role_Name__r.Description__c, Role_Name__r.Exclude_from_Application__c
            FROM Chapter_Role__c
            WHERE Chapter_name__c IN :chaptersNameSet 
            AND Role_Name__r.Exclude_from_Application__c = false
        ]) {
            if(currRole.Role_Name__c != null) {
                options.add(new SelectOption(currRole.Role_Name__r.Name, currRole.Role_Name__r.Name));
            }
        }
        options.sort();
        return options;
    }
    
    /**
    * Retrieves Title values to display as options
    */
    public List<SelectOption> getTitles() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', 'Please Select Title'));
        options.add(new SelectOption('Mr.', 'Mr.'));
        options.add(new SelectOption('Mrs.', 'Mrs.'));
        options.add(new SelectOption('Ms.', 'Ms.'));
        options.add(new SelectOption('Miss', 'Miss'));
        options.add(new SelectOption('Master', 'Master'));
        options.add(new SelectOption('Dr.', 'Dr.'));
        options.add(new SelectOption('Prof.', 'Prof.'));
        return options;
    }
    
    /**
    * Retrieves Country values to display as options
    */
    public List<SelectOption> getCountries() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('United States', 'United States'));
        return options;
    }
    
    /**
    * Retrieves state values to display as options 
    */
    public List<SelectOption> getStates() {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Lead.State_Picklist__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        options.add(new SelectOption('', 'Please select state'));
        for(Schema.PicklistEntry currVal : picklistValues) {
            options.add(new SelectOption(currVal.getLabel(), currVal.getValue()));
        }
        return options;
    }
    
    /**
    * Retrieves language values to display as options
    */
    public List<SelectOption> getLanguages() {
        return getPicklistValues('Language__c', '', '');
    }
    
    /**
    * Retrieves How Did You Hear About Make-A-Wish values to display as options
    */
    public List<SelectOption> getHowdidyouhearaboutMakeAWish() {
        return getPicklistValues('How_did_you_hear_about_Make_A_Wish__c', '', '');
    }
    
    /**
    * Retrieves Professional Skills values to display as options
    */
    public List<SelectOption> getProfessionalSKills() {
        return getPicklistValues('Professional_Skills__c', '', '');
    }
    
    /**
    * Retrieves Preferred Phone Type values to display as options
    */
    public List<SelectOption> getPreferedPhoneType() {
        return getPicklistValues('npe01__PreferredPhone__c', '', 'Select Type');
    }
    
    /**
    * Retrieves I Am On LinkedIn values to display as options
    */
    public List<SelectOption> getIamOnLinkedIn() {
        return getPicklistValues('I_m_on_LinkedIn__c', '', 'Select');
    }
    
    /**
    * Retrieves May We Contact You At Work values to display as options
    */
    public List<SelectOption> getContactAtWorks() {
        return getPicklistValues('May_We_Contact_You_at_Work__c', '', 'Select');
    }
    
    /**
    * Retrieves Would Your Company Be Interested MAW values to display as options
    */
    public List<SelectOption> getInterstedList() {
        return getPicklistValues('Interested_involved_with_Make_A_Wish__c', '', 'Select');
    }
    
    /**
    * Return list of picklist values based on field passed in
    * @param fieldApiName
    * @param firstOptionValue
    * @param firstOptionLabel
    * @return options
    */
    public List<SelectOption> getPicklistValues(String fieldApiName, String firstOptionValue, String firstOptionLabel) {
        Map<String, Schema.SObjectField> contactFieldsMap = new Map<String, Schema.SObjectField>();
        contactFieldsMap = Schema.SObjectType.Contact.Fields.getMap();
        List<Schema.PicklistEntry> picklistValues = contactFieldsMap.get(fieldApiName).getDescribe().getPicklistValues();
        List<SelectOption> options = new List<SelectOption>();
        if(!String.isEmpty(firstOptionValue) || !String.isEmpty(firstOptionLabel)) {
            options.add(new SelectOption(firstOptionValue, firstOptionLabel));
        }
        for(Schema.PicklistEntry value : picklistValues) {
            if(value.isActive()) {
                options.add(new SelectOption(value.getLabel(), value.getValue()));
            }
        }
        return options;
    }
    
    /**
    * Build string from list of strings
    * @param stringList
    * @return field
    */
    public String buildStringFromList(List<String> stringList) {
        String field = '';
        for(String str : stringList) {
            field += str + ';';
        }
        field.removeEnd(';');
        return field;
    }
    
    /**
    *  Role Description Wrapper
    */
    public class roleWrapper {
        public String roleName { get; set; }
        public String roleDescription { get; set; }
    }
}