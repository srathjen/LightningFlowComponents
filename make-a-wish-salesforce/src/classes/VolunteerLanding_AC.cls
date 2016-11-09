/*****************************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kesavakumar Murugesan
Date        : 7/4/2016
Description : This class is used to pull the landing page content dynamically for active volunteer. If Background
check / COI record is expired or going to expire in 30 days, It will display  a popup message for renewel
their details.
*******************************************************************************************************************/
public class VolunteerLanding_AC {
    
    public List<Dynamic_Content__c> activeVolunteerLandingPageInfoList {get;set;}
    public Id currentUserId;
    public Id userRelatedContactId;
    public String eventsRTId;
    public String currentChapter {get;set;}
    public Constant_AC constant;
    public String selectedChapter {get;set;}
    public List<User> getRelatedContactId;
    public boolean displayPopup{get;set;}
    public boolean displayPopupconflict{get;set;}
    public boolean blockNewBG{get;set;}
    public  User currUser;
    public boolean flagForCancel{get;set;}
    public boolean flagForCOICancel{get;set;}
    public Contact volunteercon{get;set;}
    public string residingStatus{get;set;}
    public boolean isExpired{get;set;}
    public integer nBCDays{get;set;}
    public integer nCOIDays{get;set;}
    public boolean isCOIExpired{get;set;}
    
    public boolean displayBCMsg{get;set;}
    public string broadCaseMsg{get;set;}
    public string broadCastName;
    public List<Orientation_Training__c>  orientationList{get;set;}
    public List<Class_Offering__c> diplayClassOffRec{get;set;}
    public boolean displayTrainingDetails{get;set;}
    public boolean displayTrainingAck{get;set;}
    public String myId;
    public string trainingName{get;set;}
    
    public VolunteerLanding_AC() {
        myId = ApexPages.currentPage().getParameters().get('event');
        constant = new Constant_AC();
        diplayClassOffRec = new List<Class_Offering__c>();
        Id activeVolunteerRecordTypeId = Schema.Sobjecttype.Dynamic_Content__c.getRecordTypeInfosByName().get(constant.activeVolRT).getRecordTypeId();
        currentUserId = userInfo.getUserId();
        currUser = [SELECT contactId FROM User WHERE Id = :userInfo.getUserId()];
        List<HoldCurrentChapter__c > primaryChapter = [SELECT Name,CurrentChapter__c FROM HoldCurrentChapter__c  WHERE Name =: currentUserId];
        if(primaryChapter.size() > 0)
        {
            currentChapter = primaryChapter.get(0).CurrentChapter__c; 
            volunteercon = [SELECT Id,FirstName,LastName,isApplication__c,Account.Volunteer_Manager__c,AccountId,
                            Email,Phone,Broadcast_Number__c,OwnerId FROM Contact WHERE Id =: currUser.ContactId Limit 1];
                            
            activeVolunteerLandingPageInfoList = [SELECT Id, Featured_Image__c, Feature_Quote__c, Heading_Highlight_Image_1__c, Heading_Highlight_Image_2__c, Heading_Highlight_Image_3__c, Heading_Highlight_Text_1__c, Heading_Highlight_Text_2__c, Heading_Highlight_Text_3__c,
                                              Heading_Highlight_Title_1__c, Heading_Highlight_Title_2__c,Heading_Text__c, Heading_Highlight_Title_3__c, Heading_Title__c, Welcome_Message__c FROM Dynamic_Content__c WHERE RecordTypeId =: activeVolunteerRecordTypeId AND Chapter_Name__r.Name =: primaryChapter.get(0).CurrentChapter__c AND Active__c = True LIMIT 1];
            
            System.debug('activeVolunteerLandingPageInfoList +++++++++++++++++= ' + activeVolunteerLandingPageInfoList);
        }                                  
    }
    
   
    //This method is used to get the chapter list if the volunteer belongs to more than one chapter
    public List<SelectOption> getChapterList() {
        getRelatedContactId = [SELECT Id, ContactId FROM User WHERE Id =:currentUserId];
        List<SelectOption> chapterList = new List<SelectOption>();
        if(getRelatedContactId.size()>0) {
            for(npe5__Affiliation__c getChapterList : [SELECT Id, npe5__Organization__r.Name FROM npe5__Affiliation__c WHERE npe5__Organization__r.Name !=: currentChapter AND npe5__Contact__c =: getRelatedContactId.get(0).ContactId]) {
                chapterList.add(new SelectOption(getChapterList.npe5__Organization__r.Name,getChapterList.npe5__Organization__r.Name));
            }
        }
        return chapterList;
    }
    
    //This method is used to switch beteen chapters
    public PageReference EnterchapterPage() {
        if(selectedChapter != '--Swith Chapter--') {
            List<HoldCurrentChapter__c> getChapterValues = [SELECT Name,CurrentChapter__c FROM HoldCurrentChapter__c  WHERE Name =: currentUserId ];
            if(getChapterValues.size()>0) {
                getChapterValues.get(0).CurrentChapter__c = selectedChapter;
                update getChapterValues;
            } else {
                HoldCurrentChapter__c newHoldChapter = new HoldCurrentChapter__c();
                newHoldChapter.Name = currentUserId;
                newHoldChapter.CurrentChapter__c = selectedChapter;
                insert newHoldChapter;
            }
        }
        PageReference page = new PageReference( '/VolunteerLanding_VF');
        page.setRedirect(true);
        return page;  
    }
    
    //This method is used to display top 4 events of that chapter.
    public list<Non_Wish_Events__c> getEvents() {
        eventsRTId = Schema.Sobjecttype.Non_Wish_Events__c.getRecordTypeInfosByName().get(constant.events).getRecordTypeId();
        List<Non_Wish_Events__c> eventRecords = [SELECT id,Name,Event_Name__c, Priority__c,Event_Image__c,Event_Text__c,Event_Date__c
                                                 FROM Non_Wish_Events__c  WHERE chapter__r.Name = :currentChapter  AND Event_Date__c >= :Date.Today() AND RecordTypeId = :eventsRTId AND priority__c != Null order by priority__c ASC limit 4];
      
        if(eventRecords.size() < 4)
        {
          for(Non_Wish_Events__c  currRec : [SELECT id,Name,Event_Name__c, Priority__c,Event_Image__c,Event_Text__c,Event_Date__c
                                            FROM Non_Wish_Events__c  WHERE chapter__r.Name = :currentChapter  AND Event_Date__c >= :Date.Today() AND RecordTypeId = :eventsRTId AND priority__c = Null limit 4])
          {
           
            if(eventRecords.size() < 4)
                eventRecords.add(currRec);
           
          }
        }
        return eventRecords;
        
    } 
    
    // This function is calling on page layout and checking the expiration date of COI and Background check. 
    // If background is expired or going to expired in 30 days, Then It will display the warning
   //  message to volunteer for updating their details.
    public void BackgroundCheck()
    {
           // This class is used to share the dynamic content record with the volunteer
           
          if(!Test.isRunningTest())
          {
            Dynamic_Content__Share dynamicContentShare  = new Dynamic_Content__Share();
            dynamicContentShare.ParentId = activeVolunteerLandingPageInfoList.get(0).Id;
            dynamicContentShare.AccessLevel = 'Read';
            dynamicContentShare.UserOrGroupId = currentUserId ;
            insert dynamicContentShare;
          }
    
        Integer bcDays = Integer.valueOf(label.B_C_No_of_days_for_expiration);
        integer coiDays = Integer.valueOf(label.COI_no_of_expiration_days);
        User currUser = [SELECT contactId FROM User WHERE Id = :userInfo.getUserId()];
        System.debug('Contact Id+++++++++++++++++++++++++++++++++ ' +currUser.contactId);
        List<Background_check__c> currVolBGCheck = [SELECT Id,Volunteer__c, Date_Completed__c,Date__c,status__c FROM Background_check__c WHERE Volunteer__c = :currUser.contactId AND Date__c != Null Order by CreatedDate DESC limit 2];
        List<Conflict_Of_Interest__c> conflictIns = [SELECT Id,Name,Expiration_Date__c,Signed_Date__c,Active__c,Volunteer_Contact__c FROM  Conflict_Of_Interest__c WHERE Volunteer_Contact__c  =: currUser.ContactId AND Expiration_Date__c != Null  Order by CreatedDate DESC Limit 1];
        volunteercon = [SELECT Id,FirstName,OwnerId,LastName,isApplication__c,AccountId,Account.Volunteer_Manager__c,Email,Phone,Broadcast_Number__c  FROM Contact WHERE Id =: currUser.ContactId Limit 1] ;
        isExpired = false;
        isCOIExpired  =false;
        
        if(currVolBGCheck.size() > 0)
        {
            nBCDays  = (Date.Today()).daysBetween(currVolBGCheck[0].Date__c); 
            
            System.debug('nBCDays  +++++++++++++++++++++ ' + nBCDays);
        }
        
        if(conflictIns.size() > 0)
        {
          nCOIDays = (Date.Today()).daysBetween(conflictIns[0].Expiration_Date__c); 
          System.debug('nCOIDays +++++++++++++++++++++ ' + nCOIDays);
        }
        
       if(currVolBGCheck.size() > 0 && conflictIns.size() > 0)
        {
        
            System.debug('1+++++++++++++++++++++ ' );
            if((currVolBGCheck[0].Date__c >= Date.Today()  && currVolBGCheck[0].Date__c < Date.Today().addDays(bcDays)) && (conflictIns[0].Expiration_Date__c >= Date.Today()  && conflictIns[0].Expiration_Date__c < Date.Today().addDays(coiDays) && myId == Null))
            {
              displayPopupconflict = true;
              displayPopup = True;
              flagForCancel = true;
              flagForCOICancel = true;
            }
            
           If(conflictIns[0].Expiration_Date__c >= Date.Today()  && conflictIns[0].Expiration_Date__c < Date.Today().addDays(coiDays) && myId == Null){
                displayPopupconflict = true;
                flagForCOICancel = true;
            }
            
           if(currVolBGCheck[0].Date__c >= Date.Today()  && currVolBGCheck[0].Date__c < Date.Today().addDays(bcDays))
            {
              displayPopup = True;
              flagForCancel = true;
             
            }
        }
        
        else if(conflictIns.size() > 0 && myId == Null)
        {
            If(conflictIns[0].Expiration_Date__c >= Date.Today()  && conflictIns[0].Expiration_Date__c < Date.Today().addDays(coiDays)){
                displayPopupconflict = true;
                flagForCOICancel = true;
            }
        }
        
           
        else if(currVolBGCheck.size() > 0)
        {
            if(currVolBGCheck[0].Date__c >= Date.Today()  && currVolBGCheck[0].Date__c < Date.Today().addDays(bcDays))
            {
              displayPopup = True;
              flagForCancel = true;
             
            }
        }
        if(conflictIns.size() > 0 && myId == Null)
        {
        
            if(conflictIns[0].Expiration_Date__c == Date.Today() && myId == Null)
            {
               flagForCOICancel= true;
               displayPopupconflict = True;
            }
            if(conflictIns[0].Expiration_Date__c < Date.Today() && myId == Null)
            {
               displayPopupconflict = True;
               flagForCOICancel = false;
               isCOIExpired = true;
            }
        }
        
        if(currVolBGCheck.size() > 0)
        {
        
            if(currVolBGCheck[0].Date__c == Date.Today())
            {
               flagForCancel = true;
               displayPopup = True;
            }
            if(currVolBGCheck[0].Date__c < Date.Today())
            {
               displayPopup = True;
               flagForCancel = false;
               isExpired  = true;
            }
        }
        
        if(currVolBGCheck.size() > 1)
        {
            if(currVolBGCheck[0].status__c != 'Approved' && currVolBGCheck[1].date__c < Date.Today())
            {
              blockNewBG = true;
            }
        }
        
        // It will fetch the new Broadcast message and display on the active volunteer portal.
        Set<String> broadCastsNameSet = new Set<String>();
        npe5__Affiliation__c primaryChapter = [SELECT Id, npe5__Organization__c, npe5__Contact__c FROM npe5__Affiliation__c WHERE npe5__Primary__c = True AND npe5__Contact__c = :currUser.ContactId limit 1];
        
           if(volunteercon.Broadcast_Number__c != Null)
           {
            for(String currStr : (volunteercon.Broadcast_Number__c).split(','))
            {
                broadCastsNameSet.add(currStr); 
            }
           }
        
        List<Broadcast__c> recentBroadCastList = [SELECT id,Name, Broadcast_Message__c FROM Broadcast__c WHERE Name NOT IN :broadCastsNameSet AND (Date__c < :Date.Today().addDays(30)) AND Chapter_Name__c = :primaryChapter.npe5__Organization__c limit 1];
       
        if(recentBroadCastList.size() > 0)
        {
          broadCaseMsg = recentBroadCastList[0].Broadcast_Message__c;
          broadCastName = recentBroadCastList[0].Name;
          displayBCMsg = True;
          
        }
        
       Set<Id> orientationIds = new Set<Id>();
       Set<Id> registeredIds = new Set<Id>();
       Set<Id> chapterRoles = new Set<Id>();
       Set<Id> chapterIds = new Set<Id>();
       // Fetching Training details which are marked as "Prompt upon login" and display on the portal, if it is not completed by volunteer.
       for(Volunteer_Roles__c  chapterRole : [SELECT Chapter_Role__c,Chapter_Role__r.Chapter_Name__c FROM Volunteer_Roles__c WHERE Volunteer_Name__c = :currUser.contactId])
       {
           chapterRoles.add(chapterRole.Chapter_Role__c);
           chapterIds.add(chapterRole.Chapter_Role__r.Chapter_Name__c);
       }
       
       for(Chapter_Role__c currRec : [SELECT Id FROM Chapter_Role__c WHERE Chapter_Name__c IN :chapterIds AND Role_Name__r.Name = 'All Roles'])
       {
         chapterRoles.add(currRec.id);
       }
       for(Volunteer_Orientation_Training__c currRec : [SELECT Id,Volunteer_Attendance__c,Orientation_Training__c  
                                                        FROM Volunteer_Orientation_Training__c  Where 
                                                        Volunteer__c = :currUser.ContactId AND 
                                                        Volunteer_Attendance__c != 'Cancelled' AND Type__c = 'Training'])
       {
           orientationIds.add(currRec.Orientation_Training__c);
           
           if(currRec.Volunteer_Attendance__c == 'Registered')
               registeredIds.add(currRec.Orientation_Training__c);
           
       }
       
       diplayClassOffRec = [SELECT id,Orientation_and_Training__c,Chapter_Role_O_T__c,
                           Chapter_Role_O_T__r.Orientation_Training__c,Date__c,Start_Time__c,End_Time__c 
                           FROM Class_Offering__c WHERE Chapter_Role_O_T__r.Orientation_Training__c NOT IN :orientationIds 
                           AND Chapter_Role_O_T__r.Orientation_Training__r.Prompt_upon_Login__c = True 
                           AND Chapter_Role_O_T__r.Orientation_Training__r.RecordType.Name = 'Training' 
                           AND Chapter_Role_O_T__r.chapter_Role__c IN :chapterRoles   limit 1];
       
       List<Class_Offering__c> registeredClassOff = [SELECT id,Orientation_and_Training__c,Date__c,Chapter_Role_O_T__c,Chapter_Role_O_T__r.Orientation_Training__c,
                                                     Start_Time__c,End_Time__c FROM Class_Offering__c WHERE 
                                                     Chapter_Role_O_T__r.Orientation_Training__c  IN :registeredIds AND 
                                                     Chapter_Role_O_T__r.Orientation_Training__r.Prompt_upon_Login__c = True AND 
                                                     Chapter_Role_O_T__r.Orientation_Training__r.RecordType.Name = 'Training' 
                                                     AND Chapter_Role_O_T__r.chapter_Role__c IN :chapterRoles limit 1];
       
       if(registeredClassOff.size() > 0)
       {
           displayTrainingAck = True;
       
       }
       
       else if(diplayClassOffRec.size() > 0)
       {
           trainingName = diplayClassOffRec[0].Orientation_and_Training__c;
           displayTrainingDetails = True;
           
       }
        
    }
    
   // Register for the Required Training which is populating on the landing portal. 
   public pageReference register()
    {
        pageReference pr;
        
        Volunteer_Orientation_Training__c newTraining = new Volunteer_Orientation_Training__c();
        newTraining.Orientation_Training__c = diplayClassOffRec[0].Chapter_Role_O_T__r.Orientation_Training__c;
        newTraining.volunteer__c = currUser.ContactId;
        newTraining.Class_Offering__c = diplayClassOffRec[0].id;
        newTraining.Registered_Date__c = Date.Today();
        newTraining.Volunteer_Attendance__c  = 'Registered';
        newTraining.Type__c = 'Training';
        insert newTraining;
        displayTrainingDetails =false;
        displayTrainingAck  = True;
        
        pr = new PageReference('/VolunteerActiveTraining_VF');
        return pr;
    }
    
    // If user submits [ok] button for background rechecking, it will create new Background check for the volunteer.
    Public Void confirmBackGroundCheck()
    {
    
      Background_check__c currVolBGCheck = [SELECT Id,Volunteer__c,Volunteer__r.OwnerId,Date_Completed__c,Date__c FROM Background_check__c WHERE Volunteer__c = :currUser.contactId  Order by CreatedDate DESC limit 1];
      Background_check__c newCheck = new Background_check__c();
      newCheck.Date_Requested__c = Date.Today();
      newcheck.Requested_By__c = userInfo.getUserId();
      newCheck.volunteer__c = currUser.contactId;
      newCheck.Resided_in_US_for_past_7_years__c = residingStatus;
     /* if(volunteercon.ownerId != Null)
          newCheck.ownerId = volunteercon.ownerId;*/
      newCheck.date__c = Date.Today().addYears(3);
      insert newCheck;
      
        Constant_AC  constant = new Constant_Ac();
        string taskRecordTypeId = Schema.Sobjecttype.Task.getRecordTypeInfosByName().get(constant.backgroundRT).getRecordTypeId();
        Task newBGTask = new Task();
        newBGTask.Type = 'Email';
        newBGTask.Description = ''; 
        if(volunteercon != Null)
        {
           if(volunteerCon.Account.Volunteer_Manager__c != Null)
                newBGTask.OwnerId = volunteercon.account.volunteer_Manager__c; 
           else
              newBGTask.OwnerId = volunteercon.ownerId; 
        }
       
        newBGTask.WhoId = currUser.ContactId; 
        newBGTask.whatId = newCheck.id;
        newBGTask.Subject = 'Background Check';
        newBGTask.RecordTypeId = taskRecordTypeId;
        insert newBGTask;
            
      displayPopUp = false;
      if(currVolBGCheck.Date__c >= Date.Today())
      {
         blockNewBG = false;
      }
      else
      {
         blockNewBG = true;
      }
      
    }
    
    // User can disable the warning popup via cancel button.
    public void cancel()
    {
     displayPopup = false;
     
    }
    
    // Cancel the Trainig popup.
    public void TrainingAckCancel()
    {
        displayTrainingAck  = false;
    }
    
    // Once the user read the Broadcast message, Broadcast number will be stored in the Volunteer Contact Record, 
    //in order to prevent it next time popup.
    public void broadCastCancel()
    {
         displayBCMsg = false;
         if(broadCastName != '')
         {
         
          contact updateContact = new Contact();
          updateContact.id = currUser.contactId;
              if(volunteercon.Broadcast_Number__c != Null)
              {
                updateContact.Broadcast_Number__c = volunteercon.Broadcast_Number__c +','+broadCastName;
              }
              else
              {
               updateContact.Broadcast_Number__c = broadCastName;
              }
          Update updateContact;
         }
    }
    
    // User can disable the COI warning popup via cancel button.
    public void cancelConflict(){
        
         displayPopupconflict = false;
    }
    // If user submits [ok] for COI, then it will send the document for sign , once sign completed then it will create new COI.
    Public Pagereference confirmConflict()
    {   
        displayPopupconflict = false;
        User currUser = [SELECT contactId FROM User WHERE Id = :userInfo.getUserId()];
        volunteercon = [SELECT Id,FirstName,LastName,Email,Phone FROM Contact WHERE Id =: currUser.ContactId Limit 1] ;
        String account;
        String UserName;
        String Password;
        String IntegratorKey;
        String endPointURL;
        Map<String,DocuSignCredentialsSetting__c> credentialSetting = DocuSignCredentialsSetting__c.getAll();
        
        for(DocuSignCredentialsSetting__c credentialIns : credentialSetting.values()){
              UserName = credentialIns.name;
              account  = credentialIns.account__c;
              Password = credentialIns.Password__c;
              IntegratorKey  = credentialIns.IntegratorKey__c;
              endPointURL = credentialIns.end_Point__c;
              
        }
        String endpoint = endPointURL+'/accounts/'+account+'/envelopes';
        String authorizationHeader = '<DocuSignCredentials><Username>'+UserName+'</Username><Password>'+Password+'</Password><IntegratorKey>'+IntegratorKey+'</IntegratorKey></DocuSignCredentials>';
        String boundary = 'AAA';
        
        Pagereference PDF = Page.ConflictOfInterestPage_PDF_VF;
        PDF.getParameters().put('id',volunteercon.id);

        String documentPDF;
        
        try {
        documentPDF = EncodingUtil.base64Encode(PDF.getContentAsPDF());
        
        }catch(Exception e) {
        // Generic exception handling code here.
        }
        system.debug('+currentVolunteer.email'+volunteercon.email); 
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
            '      "email": "'+volunteercon.email+'",'+
            '      "name": "'+volunteercon.LastName+'",'+
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
                '    "userName": "'+volunteercon.LastName+'",'+
                '    "email": "'+volunteercon.email+'",'+
                '    "recipientId": "1",'+
                '    "clientUserId": "1",'+
                '    "authenticationMethod": "None",'+
                '    "returnUrl": "'+label.Site_Url+'/VolunteerLanding_VF"'+
                '}';     
            request.setBody(jsonPayload);
            response = httprequest.send(request); 
            system.debug('@@@@@@@ response @@@@@@@@'+response.getBody());
            results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            
            if((String) results.get('url') != '' || (String) results.get('url') != null){
                
                volunteercon.isApplication__c = true;
                if(!Test.isRunningTest())
                update volunteercon;
                
                dsfs__DocuSign_Status__c dsfs= NEW dsfs__DocuSign_Status__c();
                dsfs.dsfs__DocuSign_Envelope_ID__c = env;
                dsfs.isConflict__c = true;
                dsfs.Docusign_Hidden_Contact__c = volunteercon.Id;
                Insert dsfs;
                system.debug('@@@@@@@@ DOCUSIGN REC @@@@@'+dsfs);
                PageReference reference=new PageReference((String) results.get('url'));
                reference.setRedirect(true);
                return reference;
                
                
            }
        }
       
     
        return null;
        
        
    }
    
}