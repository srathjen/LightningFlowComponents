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
    public string email{get;set;}
    public boolean displayBCMsg{get;set;}
    public string broadCaseMsg{get;set;}
    public string broadCastName;
    public List<Orientation_Training__c>  orientationList{get;set;}
    public List<Class_Offering__c> diplayClassOffRec{get;set;}
    public boolean displayTrainingDetails{get;set;}
    public boolean displayTrainingAck{get;set;}
    public String myId;
    public string trainingName{get;set;}
    public boolean isBGRoleExpOOC{get;set;}
    
    /*** Dynamic Content variables */
    
    public string featuredImage{get;set;}
    public string featuredQuote{get;set;}
    public string welcomeMsg{get;set;}
    public string headingTitle1{get;set;}
    public string headingText1{get;set;}
    public string title1{get;set;}
    public string image1{get;set;}
    public string text1{get;set;}
    public string title2{get;set;}
    public string image2{get;set;}
    public string text2{get;set;}
    public string title3{get;set;}
    public string image3{get;set;}
    public string text3{get;set;}
    public boolean confirmPopup{get;set;}
    
    
    public VolunteerLanding_AC() {
        confirmPopup = False;
        String Logvalue,recId;         
        myId = ApexPages.currentPage().getParameters().get('event');
        constant = new Constant_AC();
        diplayClassOffRec = new List<Class_Offering__c>();
        Id activeVolunteerRecordTypeId = Schema.Sobjecttype.Dynamic_Content__c.getRecordTypeInfosByName().get(constant.activeVolRT).getRecordTypeId();
        currentUserId = userInfo.getUserId();
        currUser = [SELECT contactId FROM User WHERE Id = :userInfo.getUserId()];
        List<Background_check__c> dbBackGround = [SELECT Id,CreatedDate,Hidden_Display_Popup__c,Volunteer__c,Status__c FROM Background_check__c WHERE Volunteer__c =: currUser.contactId  order by createdDate DESC Limit 1];
        Logvalue = String.valueOf(dbBackGround);
        
        if(!Test.isRunningTest()) {
            if(dbBackGround.size()>0 && dbBackGround[0].Hidden_Display_Popup__c == true){
                confirmPopup = true;
            }
        }
        
        isBGRoleExpOOC  = false;
        for(Volunteer_Roles__c currRole : [SELECT Id FROM Volunteer_Roles__c WHERE Volunteer_Name__c  =: currUser.contactId AND (Status__c = 'Trained' OR Status__c = 'Out of Compliance')])
        {
            Logvalue = String.valueOf(currRole);
            isBGRoleExpOOC = True;
        }
        
        volunteercon = [SELECT Id,FirstName,LastName,Name,Residing_in_US__c,Region_Chapter__c,isApplication__c,Account.Volunteer_Manager__c,AccountId,npe01__HomeEmail__c,BackGroundCheckUpdated__c,
                        Email,Phone,Broadcast_Number__c,OwnerId,HomePhone,MobilePhone,npe01__Preferred_Email__c,npe01__AlternateEmail__c,npe01__WorkEmail__c FROM Contact WHERE Id =: currUser.ContactId Limit 1];
        if(volunteercon!=Null)
        {   
            
            currentChapter = volunteercon.Region_Chapter__c; 
            activeVolunteerLandingPageInfoList = [SELECT Id, Featured_Image__c, Feature_Quote__c, Heading_Highlight_Image_1__c, Heading_Highlight_Image_2__c, Heading_Highlight_Image_3__c, Heading_Highlight_Text_1__c, Heading_Highlight_Text_2__c, Heading_Highlight_Text_3__c,
                                                  Heading_Highlight_Title_1__c, Heading_Highlight_Title_2__c,Heading_Text__c, Heading_Highlight_Title_3__c, Heading_Title__c, Welcome_Message__c FROM Dynamic_Content__c WHERE RecordTypeId =: activeVolunteerRecordTypeId AND Chapter_Name__c =: currentChapter AND Active__c = True LIMIT 1];
            
            System.debug('activeVolunteerLandingPageInfoList:' + activeVolunteerLandingPageInfoList);
            
            Logvalue = String.valueOf(activeVolunteerLandingPageInfoList);
            if(activeVolunteerLandingPageInfoList.size() > 0)
            {
                featuredImage = activeVolunteerLandingPageInfoList[0].Featured_Image__c;
                featuredQuote = activeVolunteerLandingPageInfoList[0].Feature_Quote__c;
                welcomeMsg = activeVolunteerLandingPageInfoList[0].Welcome_Message__c;
                headingTitle1 = activeVolunteerLandingPageInfoList[0].Heading_Title__c;
                headingText1 = activeVolunteerLandingPageInfoList[0].Heading_Text__c;
                title1 = activeVolunteerLandingPageInfoList[0].Heading_Highlight_Title_1__c;
                image1 = activeVolunteerLandingPageInfoList[0].Heading_Highlight_Image_1__c;
                text1 = activeVolunteerLandingPageInfoList[0].Heading_Highlight_Text_1__c;
                title2 = activeVolunteerLandingPageInfoList[0].Heading_Highlight_Title_2__c;
                image2 = activeVolunteerLandingPageInfoList[0].Heading_Highlight_Image_2__c;
                text2  = activeVolunteerLandingPageInfoList[0].Heading_Highlight_Text_2__c;
                title3 = activeVolunteerLandingPageInfoList[0].Heading_Highlight_Title_3__c;
                image3 = activeVolunteerLandingPageInfoList[0].Heading_Highlight_Image_3__c;
                text3 = activeVolunteerLandingPageInfoList[0].Heading_Highlight_Text_3__c;
                
                
                
            }
        }
    }
    
    
    /* *****************************************************************************************
This method is used to get the chapter list if the volunteer belongs to more than one chapter    
******************************************************************************************* */
    public List<SelectOption> getChapterList() {
        String Logvalue,recId;         
        
        getRelatedContactId = [SELECT Id, ContactId FROM User WHERE Id =:currentUserId];
        List<SelectOption> chapterList = new List<SelectOption>();
        if(getRelatedContactId.size()>0) {
            for(npe5__Affiliation__c getChapterList : [SELECT Id, npe5__Organization__r.Name FROM npe5__Affiliation__c WHERE npe5__Organization__r.Name !=: currentChapter AND npe5__Contact__c =: getRelatedContactId.get(0).ContactId]) {
                Logvalue =  String.valueOf(getChapterList);
                recId = getChapterList.Id;
                chapterList.add(new SelectOption(getChapterList.npe5__Organization__r.Name,getChapterList.npe5__Organization__r.Name));
            }
        }
        return chapterList;
        
    }
    
    /* *****************************************
This method is used to switch beteen chapters
******************************************* */
    public PageReference EnterchapterPage() {
        String Logvalue,recId;         
        try{
            if(selectedChapter != '--Swith Chapter--') {
                List<HoldCurrentChapter__c> getChapterValues = [SELECT Name,CurrentChapter__c FROM HoldCurrentChapter__c  WHERE Name =: currentUserId ];
                if(getChapterValues.size()>0) {
                    getChapterValues.get(0).CurrentChapter__c = selectedChapter;
                    recId = getChapterValues[0].id;
                    Logvalue = String.ValueOf(getChapterValues);
                    update getChapterValues;
                } else {
                    HoldCurrentChapter__c newHoldChapter = new HoldCurrentChapter__c();
                    newHoldChapter.Name = currentUserId;
                    newHoldChapter.CurrentChapter__c = selectedChapter;
                    Logvalue = String.valueOf(newHoldChapter);
                    insert newHoldChapter;
                }
            }
            PageReference page = new PageReference( '/VolunteerLanding_VF');
            page.setRedirect(true);
            return page;  
        }
        catch(Exception ex){
            new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerLanding_AC','EnterchapterPage',recId,ex,Logvalue));
            //ex.setMessage(Label.Debug_log_error_message); 
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
            ApexPages.addMessage(myMsg);
            return Null;
        }
    }
    
    /*********************************************************
This method is used to display top 4 events of that chapter.
********************************************************* */
    public list<Non_Wish_Events__c> getEvents() {
        String Logvalue,recId;
        
        eventsRTId = Schema.Sobjecttype.Non_Wish_Events__c.getRecordTypeInfosByName().get(constant.events).getRecordTypeId();
        List<Non_Wish_Events__c> eventRecords = [SELECT id,Name,Event_Name__c, Priority__c,Event_Image__c,Event_Text__c,Event_Date__c
                                                 //FROM Non_Wish_Events__c  WHERE chapter__c = :currentChapter  AND Event_Date__c >= :Date.Today() AND RecordTypeId = :eventsRTId AND priority__c != Null order by priority__c ASC limit 4];
                                                 FROM Non_Wish_Events__c  WHERE chapter__c = :currentChapter  AND Event_Date__c >= :Date.Today() AND priority__c != Null order by priority__c ASC, Event_Date__c ASC limit 4];
        
        if(eventRecords.size() < 4)
        {
            for(Non_Wish_Events__c  currRec : [SELECT id,Name,Event_Name__c, Priority__c,Event_Image__c,Event_Text__c,Event_Date__c
                                               //FROM Non_Wish_Events__c  WHERE chapter__c = :currentChapter  AND Event_Date__c >= :Date.Today() AND RecordTypeId = :eventsRTId AND priority__c = Null limit 4])
                                               FROM Non_Wish_Events__c  WHERE chapter__c = :currentChapter  AND Event_Date__c >= :Date.Today() AND priority__c = Null ORDER BY Event_Date__c ASC limit 4])
            {
                
                if(eventRecords.size() < 4)
                    eventRecords.add(currRec);
                
            }
        }
        return eventRecords;
        
        
    } 
    
    /* ************************************************************************************
This function is calling on page layout and checking the expiration date of COI and Background check. 
If background is expired or going to expired in 30 days, Then It will display the warning
message to volunteer for updating their details. 
*************************************************************************************** */
    
    
    public void COICheck()
    {
        String Logvalue,recId;
        try{
            integer coiDays = Integer.valueOf(label.COI_no_of_expiration_days);
            displayPopupconflict = false;
            List<Conflict_Of_Interest__c> conflictIns = [SELECT Id,Name,Expiration_Date__c,Signed_Date__c,current__c,Volunteer_Contact__c FROM  Conflict_Of_Interest__c WHERE Volunteer_Contact__c  =: currUser.ContactId AND Expiration_Date__c != NULL AND current__c = TRUE  ORDER BY CreatedDate DESC LIMIT 1];
            Logvalue = String.valueOf(conflictIns);
            // isExpired = false;
            isCOIExpired  =false;
            if(conflictIns.size() > 0)
            {
                nCOIDays = (Date.Today()).daysBetween(conflictIns[0].Expiration_Date__c); 
                System.debug('COI Days:' + nCOIDays);
            }
            
            if(conflictIns.size() > 0 && myId == Null)
            {
                
                If(conflictIns[0].Expiration_Date__c >= Date.Today()  && conflictIns[0].Expiration_Date__c < Date.Today().addDays(coiDays) && myId == Null){
                    displayPopupconflict = true;
                    flagForCOICancel = true;
                }
                
                else if(conflictIns[0].Expiration_Date__c < Date.Today() && myId == Null)
                {
                    displayPopupconflict = True;
                    flagForCOICancel = false;
                    isCOIExpired = true;
                }
            }
            
            if(displayPopupconflict == false)
                BackgroundCheck(displayPopupconflict);
        }catch(Exception ex){
            new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerLanding_AC','COICheck',recId,ex,Logvalue));
            //ex.setMessage(Label.Debug_log_error_message); 
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
            ApexPages.addMessage(myMsg);
        }
    }
    
    
    /*****************************************************************************
This method is used to display the Backgrond check popup based on the BC Expiration date.
*******************************************************************************/
    public void BackgroundCheck(boolean displayPopupconflict)
    {   
        String Logvalue,recId;
        try{
            Integer bcDays = Integer.valueOf(label.B_C_No_of_days_for_expiration);
            User currUser = [SELECT contactId FROM User WHERE Id = :userInfo.getUserId()];
            List<Background_check__c> currVolBGCheck = [SELECT Id,Volunteer__c, Current__c, Date_Completed__c,Date__c,status__c FROM Background_check__c WHERE Volunteer__c = :currUser.contactId  Order by CreatedDate DESC limit 2];
            //List<Background_check__c> currVolBGCheck = [SELECT Id,Volunteer__c, Date_Completed__c,Date__c,status__c FROM Background_check__c WHERE Volunteer__c = :currUser.contactId AND Current__c = True limit 1];
            List<Volunteer_Roles__c> DbVolRoleBGReqCheck = [SELECT Id, Chapter_Role__c, Volunteer_Name__c, Status__c, Chapter_Role__r.Background_Check_Required__c 
                                                            FROM Volunteer_Roles__c WHERE (Status__c != 'Not Approved' AND Status__c != 'Former - Chapter' AND Status__c != 'Former - Volunteer') AND Chapter_Role__r.Background_Check_Required__c =: true
                                                            AND Volunteer_Name__c  =: currUser.contactId];
            isExpired = false;
            blockNewBG = false;
            displayPopup = false;
            
            if(isBGRoleExpOOC==True) {
                If(currVolBGCheck.size() == 1) {
                    if(currVolBGCheck[0].Date__c >= Date.Today() && Date.Today().daysBetween(currVolBGCheck[0].Date__c) <= 30 && currVolBGCheck[0].Status__c != 'Rejected' && DbVolRoleBGReqCheck.size() >0 && currVolBGCheck[0].Current__c == true) {
                        nBCDays  = (Date.Today()).daysBetween(currVolBGCheck[0].Date__c); 
                        displayPopup = True;
                        flagForCancel = true;
                    } else if(currVolBGCheck[0].Date__c < Date.Today() && currVolBGCheck[0].Status__c != 'Rejected' && DbVolRoleBGReqCheck.size() >0 && currVolBGCheck[0].Current__c == true) {
                        displayPopUp = True;
                        flagForCancel = false;
                        isExpired = true;
                    } else if(currVolBGCheck[0].Status__c == 'Rejected' && DbVolRoleBGReqCheck.size() >0 && currVolBGCheck[0].Current__c == true) {
                        isExpired = true;
                    }
                } else if(currVolBGCheck.size() == 2) {
                    if(currVolBGCheck[0].Date__c == null && currVolBGCheck[1].Date__c > Date.Today() && DbVolRoleBGReqCheck.size() >0 && currVolBGCheck[1].Current__c == true) {
                        if(currVolBGCheck[1].Status__c == 'Rejected') {
                            blockNewBG = true;
                        }
                    } else if(currVolBGCheck[0].Date__c == null && currVolBGCheck[1].Date__c < Date.Today() && DbVolRoleBGReqCheck.size() >0 && currVolBGCheck[1].Current__c == true) {
                        if(currVolBGCheck[1].Status__c != 'Rejected') {
                            blockNewBG = true;
                        }
                    } else if(currVolBGCheck[0].Date__c > Date.Today() && Date.Today().daysBetween(currVolBGCheck[0].Date__c) <= 30 && currVolBGCheck[0].Status__c != 'Rejected' && DbVolRoleBGReqCheck.size() >0 && currVolBGCheck[0].Current__c == true) {
                        nBCDays  = (Date.Today()).daysBetween(currVolBGCheck[0].Date__c);
                        displayPopup = True;
                        flagForCancel = true;
                        
                    } else if(currVolBGCheck[0].Date__c <= Date.Today() && currVolBGCheck[0].Status__c != 'Rejected' && DbVolRoleBGReqCheck.size() >0 && currVolBGCheck[0].Current__c == true) {
                        nBCDays  = (Date.Today()).daysBetween(currVolBGCheck[0].Date__c);
                        displayPopUp = True;
                        flagForCancel = false;
                        isExpired = true;
                    } else if(currVolBGCheck[0].Status__c == 'Rejected' && DbVolRoleBGReqCheck.size() >0 && currVolBGCheck[0].Current__c == true) {
                        blockNewBG = true;
                    }
                }
            }
            
            
            if(displayPopup == false && blockNewBG == false)
            {
                DisplayBroadCast(displayPopup);
            }
        }catch(Exception ex){
            new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerLanding_AC','BackgroundCheck',recId,ex,Logvalue));
            //ex.setMessage(Label.Debug_log_error_message); 
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
            ApexPages.addMessage(myMsg);
            
        }
    }
    
    /*****************************************************************************
It will fetch the new Broadcast message and display on the active volunteer portal.
*********************************************************************************/
    
    Public void DisplayBroadCast(Boolean displayPopup)
    {
        String Logvalue,recId;
        try{
            Set<String> broadCastsNameSet = new Set<String>();
            volunteercon = [SELECT Id,FirstName,OwnerId,Name,LastName,isApplication__c,AccountId,Account.Volunteer_Manager__c,Email,Phone,Broadcast_Number__c,npe01__Preferred_Email__c  FROM Contact WHERE Id =: currUser.ContactId Limit 1] ;
            npe5__Affiliation__c primaryChapter = [SELECT Id, npe5__Organization__c, npe5__Contact__c FROM npe5__Affiliation__c WHERE npe5__Primary__c = True AND npe5__Contact__c = :currUser.ContactId limit 1];
            displayBCMsg = false;
            if(volunteercon.Broadcast_Number__c != Null)
            {
                for(String currStr : (volunteercon.Broadcast_Number__c).split(','))
                {
                    broadCastsNameSet.add(currStr); 
                    Logvalue += String.valueOf(currStr);
                }
            }
            
            List<Broadcast__c> recentBroadCastList = [SELECT id,Name, Broadcast_Message__c,Active__c FROM Broadcast__c WHERE Name NOT IN :broadCastsNameSet AND (Date__c < :Date.Today().addDays(30)) AND Chapter_Name__c = :primaryChapter.npe5__Organization__c AND Active__c = true limit 1];
            
            if(recentBroadCastList.size() > 0 && displayPopup != true)
            {
                Logvalue += String.valueOf(recentBroadCastList);
                broadCaseMsg = recentBroadCastList[0].Broadcast_Message__c;
                broadCastName = recentBroadCastList[0].Name;
                displayBCMsg = True;
                
            }
            
            if(displayBCMsg == false)
                DisplayTraining(displayBCMsg);
        }catch(Exception ex){
            new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerLanding_AC','DisplayBroadCast',recId,ex,Logvalue));
            //ex.setMessage(Label.Debug_log_error_message); 
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
            ApexPages.addMessage(myMsg);
            
        }
    }
    
    /*************************************************************************************
This method is used to disoplay the popup for required traing registration. 
************************************************************************************* */
    public void DisplayTraining( boolean displayBCMsg)
    {
        String Logvalue,recId;
        try{
            Set<Id> orientationIds = new Set<Id>();
            Set<Id> registeredIds = new Set<Id>();
            Set<Id> chapterRoles = new Set<Id>();
            Set<Id> chapterIds = new Set<Id>();
            // Fetching Training details which are marked as "Prompt upon login" and display on the portal, if it is not completed by volunteer.
            for(Volunteer_Roles__c  chapterRole : [SELECT Chapter_Role__c,Chapter_Role__r.Chapter_Name__c FROM Volunteer_Roles__c WHERE Volunteer_Name__c = :currUser.contactId])
            {
                Logvalue += String.valueOf(chapterRole);
                chapterRoles.add(chapterRole.Chapter_Role__c);
                chapterIds.add(chapterRole.Chapter_Role__r.Chapter_Name__c);
            }
            
            for(Chapter_Role__c currRec : [SELECT Id FROM Chapter_Role__c WHERE Chapter_Name__c IN :chapterIds AND Role_Name__r.Name = 'All Roles'])
            {
                chapterRoles.add(currRec.id);
            }
            for(Volunteer_Orientation_Training__c currRec : [SELECT Id,Volunteer_Attendance__c,Hidden_O_T_Id__c
                                                             FROM Volunteer_Orientation_Training__c  Where 
                                                             Volunteer__c = :currUser.ContactId AND 
                                                             Volunteer_Attendance__c != 'Cancelled' AND Type__c = 'Training'])
            {
                orientationIds.add(currRec.Hidden_O_T_Id__c);
                Logvalue += String.valueOf(currRec);
                if(currRec.Volunteer_Attendance__c == 'Registered')
                    registeredIds.add(currRec.Hidden_O_T_Id__c);
                
            }
            
            diplayClassOffRec = [SELECT id,Orientation_and_Training__c,Chapter_Role_O_T__c,
                                 Chapter_Role_O_T__r.Orientation_Training__c,Date__c,Start_Time__c,End_Time__c 
                                 FROM Class_Offering__c WHERE Chapter_Role_O_T__r.Orientation_Training__c NOT IN :orientationIds 
                                 AND Chapter_Role_O_T__r.Orientation_Training__r.Prompt_upon_Login__c = True 
                                 AND Chapter_Role_O_T__r.Orientation_Training__r.RecordType.Name = 'Training' 
                                 AND Chapter_Role_O_T__r.chapter_Role__c IN :chapterRoles AND ((Date__c >= :Date.Today() AND Date__c <= :Date.today().addMonths(6)) OR Date__c = Null) AND 
                                 (max_capacity__c = null OR (max_capacity__c > 0 AND AvailableSeats__c>0)) limit 1];
            
            List<Class_Offering__c> registeredClassOff = [SELECT id,Orientation_and_Training__c,Date__c,Chapter_Role_O_T__c,Chapter_Role_O_T__r.Orientation_Training__c,
                                                          Start_Time__c,End_Time__c FROM Class_Offering__c WHERE 
                                                          Chapter_Role_O_T__r.Orientation_Training__c  IN :registeredIds AND 
                                                          Chapter_Role_O_T__r.Orientation_Training__r.Prompt_upon_Login__c = True AND 
                                                          Chapter_Role_O_T__r.Orientation_Training__r.RecordType.Name = 'Training' 
                                                          AND Chapter_Role_O_T__r.chapter_Role__c IN :chapterRoles limit 1];
            
            
            
            if(diplayClassOffRec.size() > 0 && blockNewBG != True)
            {
                trainingName = diplayClassOffRec[0].Orientation_and_Training__c;
                displayTrainingDetails = True;
                
            }
        }catch(Exception ex){
            new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerLanding_AC','DisplayTraining',recId,ex,Logvalue));
            //ex.setMessage(Label.Debug_log_error_message); 
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
            ApexPages.addMessage(myMsg);
            
        }
        
    } 
    
    
    /* *************************************************************************
Register for the Required Training which is populating on the landing portal. 
****************************************************************************** */
    public pageReference register()
    {
        pageReference pr;
        pr = new PageReference('/VolunteerActiveTraining_VF');
        return pr;
    }
    
    
    
    /* ***********************************************************************************************
If user submits [ok] button for background rechecking, it will create new Background check for the volunteer.
******************************************************************************************************* */
    Public PageReference confirmBackGroundCheck()
    {
        String Logvalue;
        String recId;
        try{
            IF(volunteercon.BackGroundCheckUpdated__c == true){   
                Contact updateContact = new Contact();
                updateContact.Id = currUser.contactId;
                updateContact.HomePhone = volunteercon.HomePhone; 
                updateContact.MobilePhone = volunteercon.MobilePhone;
                //updateContact.BackGroundCheckUpdated__c = volunteercon.BackGroundCheckUpdated__c;
                updateContact.npe01__Preferred_Email__c = volunteercon.npe01__Preferred_Email__c;
                updateContact.npe01__HomeEmail__c = volunteercon.npe01__HomeEmail__c;
                updateContact.npe01__WorkEmail__c = volunteercon.npe01__WorkEmail__c;
                updateContact.npe01__AlternateEmail__c  = volunteercon.npe01__AlternateEmail__c;
                RecursiveTriggerHandler.blockBeforeUpdate = true;
                RecursiveTriggerHandler.blockAfterUpdate = true;
                recId = updateContact.Id;
                Logvalue = String.valueOf(updateContact);
                update updateContact;
            }  
            Background_check__c currVolBGCheck = [SELECT Id,Volunteer__c,Volunteer__r.OwnerId,Date_Completed__c,Date__c,Current__c FROM Background_check__c WHERE Volunteer__c = :currUser.contactId AND Current__c =: True  Order by CreatedDate DESC limit 1];
            system.debug('@@@ Date @@@@'+currVolBGCheck.Date__c);
            system.debug('@@@ Now @@@@'+system.today());
            
            if(currVolBGCheck.Date__c >= system.today()){
                confirmPopup = true;
                system.debug('@@@ confirmPopup @@@@'+confirmPopup);
            }
            else{
                confirmPopup = false;
            }
            Background_check__c newCheck = new Background_check__c();
            newCheck.Date_Requested__c = Date.Today();
            newcheck.Requested_By__c = userInfo.getUserId();
            newCheck.volunteer__c = currUser.contactId;
            if(confirmPopup == true){
                newcheck.Hidden_Display_Popup__c = true;
            }
            else{
                newcheck.Hidden_Display_Popup__c = false;
            }
            if(volunteercon.Residing_in_US__c == true)
                newCheck.Resided_in_US_for_past_7_years__c = 'Yes';
            else
                newCheck.Resided_in_US_for_past_7_years__c = 'No';
            Logvalue = String.valueOf(newCheck);
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
            newBGTask.SystemGeneratedTask__c = TRUE;
            newBGTask.RecordTypeId = taskRecordTypeId;
            Logvalue = String.valueOf(newBGTask);
            insert newBGTask;
            
            displayPopUp = false;
            if(currVolBGCheck.Date__c >= Date.Today())
            {
                blockNewBG = false;
            }
            else
            {
                blockNewBG = true;
                displayPopupconflict = false;
                displayPopup = false;               
            }
            
            PageReference page = new PageReference( '/VolunteerLanding_VF');
            page.setRedirect(true);
            return page;
        }
        catch(Exception ex){
            new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerLanding_AC','confirmBackGroundCheck',recId,ex,Logvalue));
            //ex.setMessage(Label.Debug_log_error_message); 
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
            ApexPages.addMessage(myMsg);
            return Null;      
        }
        
    }
    
    /* *****************************************
User can disable the warning popup via cancel button.
********************************************** */
    public void cancel()
    {
        displayPopup = false;
        DisplayBroadCast(displayPopup);
        
    }
    
    /* ********************
Cancel the Trainig popup.
*********************** */
    public void TrainingAckCancel()
    {
        displayTrainingAck  = false;
        
    }
    
    /*****************************************************************************************
Once the user read the Broadcast message, Broadcast number will be stored in the Volunteer Contact Record, 
in order to prevent it next time popup.     
*******************************************************************************************/
    public void broadCastCancel()
    {
        displayBCMsg = false;
        String Logvalue;
        if(broadCastName != '')
        {
            try{
                contact updateContact = new Contact();
                updateContact.id = currUser.contactId;
                if(volunteercon != NULL && volunteercon.Broadcast_Number__c != Null)
                {
                    updateContact.Broadcast_Number__c = volunteercon.Broadcast_Number__c +','+broadCastName;
                }
                else
                {
                    updateContact.Broadcast_Number__c = broadCastName;
                }
                Logvalue = String.valueOf(updateContact);
                Update updateContact;
            }
            catch(Exception ex){
                new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerLanding_AC','broadCastCancel',Null,ex,Logvalue));
                //ex.setMessage(Label.Debug_log_error_message); 
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
                ApexPages.addMessage(myMsg);
            }
        }
        
        DisplayTraining(displayBCMsg);
    }
    
    /***************************************************
User can disable the COI warning popup via cancel button.
*************************************************** */
    public void cancelConflict(){
        
        displayPopupconflict = false;
        BackgroundCheck(displayPopupconflict);
    }
    
    /********************************************************************************************************************
If user submits [ok] for COI, then it will send the document for sign , once sign completed then it will create new COI.
********************************************************************************************************************* */
    Public Pagereference confirmConflict()
    {   
        displayPopupconflict = false;
        String account;
        String UserName;
        String Password;
        String IntegratorKey;
        String endPointURL;
        String Logvalue;
        String recId;
        try {
            User currUser = [SELECT contactId FROM User WHERE Id = :userInfo.getUserId()];
            volunteercon = [SELECT Id,FirstName,LastName,Name,Email,Phone FROM Contact WHERE Id =: currUser.ContactId Limit 1] ;
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
                new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerLanding_AC','confirmConflict',Null,e,Logvalue));
            }
            system.debug('+currentVolunteer.email'+volunteercon.email); 
            String body =  '{'+
                '  "status":"sent",'+
                '  "enableWetSign": "false",'+
                '  "emailBlurb":"",'+
                '  "emailSubject": "Please review & act on these document",'+
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
                '      "name": "'+volunteercon.Name+'",'+
                '      "recipientId":"1",'+
                '      "clientUserId":"1",'+
                '      "tabs": {'+
                '                "signHereTabs": [{'+
                '                    "anchorString": "~s1",'+
                '                    "anchorXOffset": "0.1",'+
                '                    "anchorYOffset": "0.1",'+
                '                    "anchorIgnoreIfNotPresent": "false",'+
                '                    "anchorUnits": "inches"'+
                '                }],'+
                '                "dateSignedTabs": [{'+
                '                      "anchorString": "~date",'+
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
            Logvalue = String.valueOf(req);
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
                    '    "userName": "'+volunteercon.Name+'",'+
                    '    "email": "'+volunteercon.email+'",'+
                    '    "recipientId": "1",'+
                    '    "clientUserId": "1",'+
                    '    "authenticationMethod": "None",'+
                    '    "returnUrl": "'+label.Site_Url+'/VolunteerLanding_VF"'+
                    '}';     
                request.setBody(jsonPayload);
                Logvalue = String.valueOf(request);
                response = httprequest.send(request); 
                system.debug('@@@@@@@ response @@@@@@@@'+response.getBody());
                results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                
                if((String) results.get('url') != '' || (String) results.get('url') != null){
                    
                    volunteercon.isApplication__c = true;
                    if(!Test.isRunningTest()){
                        recId = volunteercon.id;
                        Logvalue = String.valueOf(volunteercon);
                        update volunteercon;
                    }
                    
                    dsfs__DocuSign_Status__c dsfs= NEW dsfs__DocuSign_Status__c();
                    dsfs.dsfs__DocuSign_Envelope_ID__c = env;
                    dsfs.isConflict__c = true;
                    dsfs.Docusign_Hidden_Contact__c = volunteercon.Id;
                    Logvalue = String.valueOf(dsfs);
                    Insert dsfs;
                    system.debug('@@@@@@@@ DOCUSIGN REC @@@@@'+dsfs);
                    PageReference reference=new PageReference((String) results.get('url'));
                    reference.setRedirect(true);
                    return reference;                        
                }
            }
            return null;
        }
        catch(Exception ex){
            new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerLanding_AC','confirmConflict',recId,ex,Logvalue));
            //ex.setMessage(Label.Debug_log_error_message); 
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
            ApexPages.addMessage(myMsg);
            return Null;
        }
    }
    
    /* ************************************************************************************************
This method is used to deisplay the coresponding email address in backgrong check expired popup message for
volunteer update their email address purpose.     
************************************************************************************************* */
    public void displayEmail(){       
        
        Contact dbContact  = [SELECT Id,FirstName,LastName,Name,Region_Chapter__c,isApplication__c,Account.Volunteer_Manager__c,AccountId,npe01__HomeEmail__c,
                              Email,Phone,Broadcast_Number__c,OwnerId,HomePhone,MobilePhone,npe01__Preferred_Email__c,npe01__AlternateEmail__c,npe01__WorkEmail__c FROM Contact WHERE Id =: currUser.ContactId Limit 1] ;
        
        if(volunteercon.npe01__Preferred_Email__c == 'Personal'){
            email = dbContact.npe01__HomeEmail__c;
            
        }
        if(volunteercon.npe01__Preferred_Email__c == 'Work'){
            email = dbContact.npe01__WorkEmail__c;
            
        }
        if(volunteercon.npe01__Preferred_Email__c == 'Alternate'){
            email = dbContact.npe01__AlternateEmail__c;
            
        }
        
    }
    /*************************************************************************************************
This method is used to hide the BC expired popup when the BC created date is today for the renival of BC.
*****************************************************************************************************/ 
    public void hidePopup(){
        confirmPopup = false;
        Background_check__c newback = new Background_check__c();
        String Logvalue;
        String recId;
        try{
            List<Background_check__c> dbBackGround = [SELECT Id,CreatedDate,Hidden_Display_Popup__c,Volunteer__c,Status__c FROM Background_check__c WHERE Volunteer__c =: currUser.contactId  order by createdDate DESC Limit 1];
            if(dbBackGround.size() > 0) {
                newback.Id = dbBackGround[0].id;
                newback.Hidden_Display_Popup__c = false;
                recId = newback.Id;
                Logvalue = String.valueOf(dbBackGround[0]);
                update newback;
            }
        }
        catch(Exception ex){
            new ApexDebugLog().createLog(new ApexDebugLog.Error('VolunteerLanding_AC','hidePopup',recId,ex,Logvalue));
            //ex.setMessage(Label.Debug_log_error_message); 
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
            ApexPages.addMessage(myMsg);
        }    
    }
    
}