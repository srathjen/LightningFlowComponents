@isTest
public class OrientationandTrainingUtil{
  
    public static Account createchapterAccount(){
        Constant_AC  constant = new Constant_AC();
        Id ChapterRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(constant.chapterRT).getRecordTypeId();
            
            Account newchapterAccount = new Account();
            newchapterAccount .Name = 'Make-A-Wish Arizona';
            newchapterAccount.RecordTypeId = ChapterRecordTypeId;
       insert newchapterAccount;
       return newchapterAccount;
    }
    
    
    public static void createChapterList(){
       /* Chapter_List__c newChapter = new Chapter_List__c();
        newChapter.Name = '35004';
        newChapter.chapter_name__c= 'Alabama';
        insert newChapter;*/
    }
    
    public static Role__c createRole()
    {
        Role__c newRole = new Role__c();
        newRole.Name = 'Wish Granting';
        newRole.isWishRole__c = true;
        insert newRole;
        return newRole;
    }
    
    public static Role__c createNonWishRole()
    {
        Role__c newRole = new Role__c();
        newRole.Name = 'Water Handler';
        newRole.isWishRole__c = false;
        insert newRole;
        return newRole;
    }
    
    public Static Chapter_Role__c createChapter(String chapterId, String RoleId)
    {
        Chapter_Role__c newChapRole = new Chapter_Role__c();
        newChapRole.Chapter_Name__c = chapterId;
        newChapRole.Role_Name__c = roleId;
        insert newChapRole;
        return newChapRole;
        
    }
    
    public static Volunteer_Roles__c createVolRole(String contactId, String chapterRoleId)
    {
        Volunteer_Roles__c newVolRole = new Volunteer_Roles__c ();
        newVolRole.Chapter_Role__c = chapterRoleId;
        newVolRole.Volunteer_Name__c = contactId;
        insert newVolRole;
        return newVolRole;
        
    }
    
    public static Orientation_Training__c CreateVolunteerTrainingRecord(){
        Constant_AC  constant = new Constant_AC();
        Id volunteerTrainingRecordTypeId = Schema.SObjectType.Orientation_Training__c.getRecordTypeInfosByName().get(constant.trainingRT).getRecordTypeId();
        Orientation_Training__c newTraining = new Orientation_Training__c();
        newTraining.Name = 'Trainging1';
        newTraining.RecordTypeId = volunteerTrainingRecordTypeId ;
        
        insert newTraining;
        return newTraining;
    }
    
    public static Orientation_Training__c CreateVolunteerOrientationRecord(){
        Constant_AC  constant = new Constant_AC();
        Id volunteerOrientationRecordTypeId = Schema.SObjectType.Orientation_Training__c.getRecordTypeInfosByName().get(constant.OrientationRT).getRecordTypeId();
        Orientation_Training__c newOrientation = new Orientation_Training__c();
        newOrientation.Name = 'Orienatation1';
        newOrientation.RecordTypeId = volunteerOrientationRecordTypeId;
        
        insert newOrientation;
        return newOrientation;
    }
    
    public static Chapter_Role_O_T__c createChapterOandT(String chapterRole, String OrientationId)
    {
        Chapter_Role_O_T__c  newChapterRoleOandT = new Chapter_Role_O_T__c();
        newChapterRoleOandT.Orientation_Training__c = OrientationId;
        newChapterRoleOandT.Chapter_Role__c = chapterRole;
        newChapterRoleOandT.Required__c = true;
        insert newChapterRoleOandT;
        return newChapterRoleOandT;
    }
    
    public static Class_Offering__c createClassOffering(String chapRoleandId)
    {
        Class_Offering__c newOffering = new Class_Offering__c();
        Constant_AC  constant = new Constant_AC();
        newOffering.Chapter_Role_O_T__c = chapRoleandId;
        newOffering.Date__c = System.Today() +10;
        newOffering.Start_Time__c = '10:00:AM';
        newOffering.End_Time__c = '11:00:AM';
        newOffering.max_capacity__c= 100;
        newOffering.Location__c = 'Test';
        newOffering.RecordTypeId = Schema.SObjectType.Class_Offering__c.getRecordTypeInfosByName().get(constant.classOfferingRecordTypeId).getRecordTypeId();
        insert newOffering;
        return newOffering;
    }
    public static Class_Offering__c createClassOfferingDup(String chapRoleandId)
    {
        Class_Offering__c newOffering = new Class_Offering__c();
        newOffering.Chapter_Role_O_T__c = chapRoleandId;
        newOffering.Date__c = System.Today() +10;
        newOffering.Start_Time__c = '12:00:AM';
        newOffering.End_Time__c = '1:00:AM';
        newOffering.max_capacity__c= 100;
        newOffering.Location__c = 'Test';
        insert newOffering;
        return newOffering;
    }
    public static Account createVolunteerAccount(){
        Constant_AC constant = new Constant_AC();
        String chapterRT= Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(constant.ChapterRT).getRecordTypeId();
        Account newAccount = new Account();
        newAccount.Name = 'Make-A-Wish Alabama';
        newAccount.RecordTypeId = chapterRT;
        insert newAccount;
        return newAccount;
    }
    
    public static Contact createVolunteerContact(Id AccountId){
        Constant_AC  constant = new Constant_AC();
        Id volunteerRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.volunteerRT).getRecordTypeId();
        Contact newContact = new Contact();
        newContact.FirstName = 'moss';
        newContact.LastName = 'Smith';
        newContact.Birthdate = System.today()-1;
        newContact.Parent_Guardian_Name__c = 'Steve Smith'; 
        newContact.RecordTypeId = volunteerRecordTypeId;
        newContact.Title = 'Mr';
        newContact.Birth_Month__c = 'January';
        newContact.Birth_Day__c = '12';
        newContact.Birth_Year__c = '1985';
        newContact.Alternate_Phone_Type__c = 'Home';
        newContact.Preferred_Phone_Types__c = 'Mobile';
        newContact.OtherPhone = '3332211144';
        newContact.HomePhone= '9003910426';
        newContact.MobilePhone= '9003910426';
        newContact.I_m_on_LinkedIn__c ='Yes';
        newContact.How_did_you_hear_about_Make_A_Wish__c  = 'Family';
        newContact.MailingStreet  = 'ThillaiNagar';
        newContact.MailingCity = 'Trichy';
        newContact.MailingCountrycode = 'US';
        newContact.MailingPostalCode = '621010';
        newContact.mailingstatecode = 'AZ';
        newContact.Emergency_Contact__c  = 'Test';
        newContact.Emergency_Contact_Relationship__c= 'Father';
        newContact.Emergency_Contact_Phone__c  = '9003910426';
        newContact.Read__c  = 'English';
        newContact.language__c = 'English';
        newContact.speak__c = 'English';
        newContact.understand__c = 'English';
        newContact.Professional_Skills__c = 'Photography';
        newContact.Language_Notes__c = 'Test';
        newContact.Volunteer_Role__c = 'Special Events';
        newContact.is_Application__c ='Partial Submit';
        newContact.AccountId = AccountId;
        newContact.Volunteer_Role__c = 'Water Handler';
        
        insert newContact;
        return newContact;
    } 
    
     public static Contact createVolunteerContactwithOtherPhone(Id AccountId){
        Constant_AC  constant = new Constant_AC();
        Id volunteerRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.volunteerRT).getRecordTypeId();
        Contact newContact = new Contact();
        newContact.FirstName = 'moss';
        newContact.LastName = 'Smith';
        newContact.Birthdate = System.today()-1;
        newContact.Parent_Guardian_Name__c = 'Steve Smith'; 
        newContact.RecordTypeId = volunteerRecordTypeId;
        newContact.Title = 'Mr';
        newContact.Birth_Month__c = 'January';
        newContact.Birth_Day__c = '12';
        newContact.Birth_Year__c = '1985';
        newContact.Alternate_Phone_Type__c = 'Mobile';
        newContact.Preferred_Phone_Types__c = 'Home';
        newContact.OtherPhone = '3332211144';
        newContact.HomePhone= '9003910426';
        newContact.MobilePhone= '9003910426';
        newContact.I_m_on_LinkedIn__c ='Yes';
        newContact.How_did_you_hear_about_Make_A_Wish__c  = 'Family';
        newContact.MailingStreet  = 'ThillaiNagar';
        newContact.MailingCity = 'Trichy';
        newContact.MailingCountrycode = 'US';
        newContact.MailingPostalCode = '621010';
        newContact.mailingstatecode = 'AZ';
        newContact.Emergency_Contact__c  = 'Test';
        newContact.Emergency_Contact_Relationship__c= 'Father';
        newContact.Emergency_Contact_Phone__c  = '9003910426';
        newContact.Read__c  = 'English';
        newContact.language__c = 'English';
        newContact.speak__c = 'English';
        newContact.understand__c = 'English';
        newContact.Professional_Skills__c = 'Photography';
        newContact.Language_Notes__c = 'Test';
        newContact.Volunteer_Role__c = 'Special Events';
        newContact.is_Application__c ='Partial Submit';
        newContact.AccountId = AccountId;
        newContact.Volunteer_Role__c = 'Water Handler';
        
        insert newContact;
        return newContact;
    } 
    
    
     public static Contact VolunteerContactwithHomePhone(Id AccountId){
        Constant_AC  constant = new Constant_AC();
        Id volunteerRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.volunteerRT).getRecordTypeId();
        Contact newContact = new Contact();
        newContact.FirstName = 'moss';
        newContact.LastName = 'Smith';
        newContact.Birthdate = System.today()-1;
        newContact.Parent_Guardian_Name__c = 'Steve Smith'; 
        newContact.RecordTypeId = volunteerRecordTypeId;
        newContact.Title = 'Mr';
        newContact.Birth_Month__c = 'January';
        newContact.Birth_Day__c = '12';
        newContact.Birth_Year__c = '1985';
        newContact.Alternate_Phone_Type__c = 'Home';
        newContact.Preferred_Phone_Types__c = 'Home';
        newContact.HomePhone= '9003910426';
        newContact.otherPhone= '9003910426';
        newContact.I_m_on_LinkedIn__c ='Yes';
        newContact.How_did_you_hear_about_Make_A_Wish__c  = 'Family';
        newContact.MailingStreet  = 'ThillaiNagar';
        newContact.MailingCity = 'Trichy';
        newContact.MailingCountrycode = 'US';
        newContact.MailingPostalCode = '621010';
        newContact.mailingstatecode = 'AZ';
        newContact.Emergency_Contact__c  = 'Test';
        newContact.Emergency_Contact_Relationship__c= 'Father';
        newContact.Emergency_Contact_Phone__c  = '9003910426';
        newContact.Read__c  = 'English';
        newContact.language__c = 'English';
        newContact.speak__c = 'English';
        newContact.understand__c = 'English';
        newContact.Professional_Skills__c = 'Photography';
        newContact.Language_Notes__c = 'Test';
        newContact.Volunteer_Role__c = 'Special Events';
        newContact.is_Application__c ='Partial Submit';
        newContact.AccountId = AccountId;
        newContact.Volunteer_Role__c = 'Water Handler';
        
        insert newContact;
        return newContact;
    } 
    
    public static Contact VolunteerContactwithMobilePhone(Id AccountId){
        Constant_AC  constant = new Constant_AC();
        Id volunteerRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.volunteerRT).getRecordTypeId();
        Contact newContact = new Contact();
        newContact.FirstName = 'moss';
        newContact.LastName = 'Smith';
        newContact.Birthdate = System.today()-1;
        newContact.Parent_Guardian_Name__c = 'Steve Smith'; 
        newContact.RecordTypeId = volunteerRecordTypeId;
        newContact.Title = 'Mr';
        newContact.Birth_Month__c = 'January';
        newContact.Birth_Day__c = '12';
        newContact.Birth_Year__c = '1985';
        newContact.Alternate_Phone_Type__c = 'Mobile';
        newContact.Preferred_Phone_Types__c = 'Mobile';
        newContact.MobilePhone= '9003910426';
        newContact.otherPhone= '9003910426';
        newContact.I_m_on_LinkedIn__c ='Yes';
        newContact.How_did_you_hear_about_Make_A_Wish__c  = 'Family';
        newContact.MailingStreet  = 'ThillaiNagar';
        newContact.MailingCity = 'Trichy';
        newContact.MailingCountrycode = 'US';
        newContact.MailingPostalCode = '621010';
        newContact.mailingstatecode = 'AZ';
        newContact.Emergency_Contact__c  = 'Test';
        newContact.Emergency_Contact_Relationship__c= 'Father';
        newContact.Emergency_Contact_Phone__c  = '9003910426';
        newContact.Read__c  = 'English';
        newContact.language__c = 'English';
        newContact.speak__c = 'English';
        newContact.understand__c = 'English';
        newContact.Professional_Skills__c = 'Photography';
        newContact.Language_Notes__c = 'Test';
        newContact.Volunteer_Role__c = 'Special Events';
        newContact.is_Application__c ='Partial Submit';
        newContact.AccountId = AccountId;
        newContact.Volunteer_Role__c = 'Water Handler';
        
        insert newContact;
        return newContact;
    } 
    
    public static User createProspectiveVolunteerUser(Id contactId){ 
        
        
        Profile volunteerProspectiveProfile = [SELECT Id FROM Profile WHERE Name = 'Prospective Volunteer'];
        
        User newProspectiveVolunteerUser = new User(  firstname = 'Jonathan',lastName = 'Edwards',email = 'jonathan@gmail.com',Username = 'joathanedwards@gmail.com',
                                                    EmailEncodingKey = 'ISO-8859-1',Alias = 'jone',TimeZoneSidKey = 'America/Los_Angeles',LocaleSidKey = 'en_US',
                                                    LanguageLocaleKey = 'en_US',ProfileId = volunteerProspectiveProfile.Id,ContactId = contactId,isActive = true,Statecode = 'AZ');
        insert newProspectiveVolunteerUser;
        return newProspectiveVolunteerUser;
        
    }
   
    public static User createUserWithOutContact(){ 
        
        
        Profile volunteerProspectiveProfile = [SELECT Id FROM Profile WHERE Name = 'Prospective Volunteer'];
        
        User newProspectiveVolunteerUser = new User(  firstname = 'Jonathan',lastName = 'Edwards',email = 'jonathan@gmail.com',Username = 'joathanedwards@gmail.com',
                                                    EmailEncodingKey = 'ISO-8859-1',Alias = 'jone',TimeZoneSidKey = 'America/Los_Angeles',LocaleSidKey = 'en_US',
                                                    LanguageLocaleKey = 'en_US',ProfileId = volunteerProspectiveProfile.Id,isActive = true,Statecode = 'AZ');
        insert newProspectiveVolunteerUser;
        return newProspectiveVolunteerUser;
        
    }
   
    public static User CreateActiveVolunteerUser(Id contactId){ 
        Profile volunteerActiveProfile = [SELECT Id FROM Profile WHERE Name = 'Active Volunteer'];
        User newActiveVolunteerUser = new User(  firstname = 'Jonathan',lastName = 'Edwards',email = 'jonathan@gmail.com',Username = 'joathanedwards@gmail.com',
                                               EmailEncodingKey = 'ISO-8859-1',Alias = 'jone',TimeZoneSidKey = 'America/Los_Angeles',LocaleSidKey = 'en_US',
                                               LanguageLocaleKey = 'en_US',ProfileId = volunteerActiveProfile .Id,ContactId = contactId,isActive = true);
        insert newActiveVolunteerUser;
        return newActiveVolunteerUser;
    }
    
    public static Background_check__c createBackgroundCheck(Id ContactId){
        Background_check__c backCheck = new Background_check__c();
        backCheck.Date__c = system.today();
        backCheck.Volunteer__c = ContactId;
        insert backCheck;
        system.debug('@@@@@@@@@@@@ backCheck  ############'+backCheck );
        return backCheck;
    }
    
    public static Conflict_Of_Interest__c createCOI(Id conId){
        Conflict_Of_Interest__c newCOI = new Conflict_Of_Interest__c();
        newCOI.Volunteer_Contact__c = conId;
        newCOI.Expiration_Date__c = system.today() + 3;
        insert newCOI;
        return newCOI;
    }
    
    public static npe5__Affiliation__c CreateAffiliation(Id contactId)
    {
        
        npe5__Affiliation__c neworgAffiliation = new npe5__Affiliation__c ();
        neworgAffiliation.npe5__Contact__c  = contactId;
        neworgAffiliation.npe5__Organization__c = TestClassUtil.createVolunteerAccount().Id;
        neworgAffiliation.npe5__Primary__c = true;
        neworgAffiliation.npe5__Status__c = 'Prospective';
        insert neworgAffiliation;
        return neworgAffiliation;
        
    }
    
    
    public static Volunteer_Orientation_Training__c createVolTraining(Id OrienationId, Id ClassOfferingId,Id volunteer,string status)
    {
        Volunteer_Orientation_Training__c createNewVol = new Volunteer_Orientation_Training__c();
        createNewVol.class_offering__c = ClassOfferingId;
        createNewVol.Orientation_Training__c = OrienationId;
        createNewVol.Registered_Date__c = Date.Today();
        createNewVol.Volunteer__c = volunteer;
        createNewVol.Volunteer_Attendance__c = status;
        createNewVol.Type__c = 'Training';
        insert createNewVol;
        return createNewVol;
    }
    public static Volunteer_Orientation_Training__c createVolOrientation(Id OrienationId, Id ClassOfferingId,Id volunteer,string status)
    {
        Volunteer_Orientation_Training__c createNewVol = new Volunteer_Orientation_Training__c();
        createNewVol.class_offering__c = ClassOfferingId;
        createNewVol.Orientation_Training__c = OrienationId;
        createNewVol.Registered_Date__c = Date.Today();
        createNewVol.Volunteer__c = volunteer;
        createNewVol.Volunteer_Attendance__c = status;
        createNewVol.Type__c = 'Orientation';
        insert createNewVol;
        return createNewVol;
    }
    public static Contact CreateWishChild(){
        Constant_AC  constant = new Constant_AC();
        Id wishChildRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.contactWishChildRT).getRecordTypeId();            
        Contact newWishChild = new Contact();
        newWishChild.FirstName = 'Steven';
        newWishChild.LastName = 'Smith';
        newWishChild.Parent_Guardian_Name__c ='Jonathan Edwards'; 
        newWishChild.RecordTypeId = wishChildRecordTypeId ;
        insert newWishChild;
        return newWishChild;
    }
    public static Dynamic_Content__c ChapterDynamicContent(String chapterId) {
        
        Constant_AC constant = new Constant_AC();
        String activeRT = Schema.Sobjecttype.Dynamic_Content__c.getRecordTypeInfosByName().get(constant.activeVolRT).getRecordTypeId();
        Dynamic_Content__c newChapterContent = new Dynamic_Content__c();
        newChapterContent.Feature_Quote__c = 'Test Feature Quote';
        newChapterContent.Active__c = true;
        newChapterContent.Welcome_Message__c = 'Test Welcome Page';
        newChapterContent.Heading_Highlight_Text_1__c = 'Test Heightlisght Text';
        newChapterContent.Heading_Highlight_Text_2__c = 'Test Heightlisght Text';
        newChapterContent.Heading_Highlight_Text_3__c = 'Test Heightlisght Text';
        newChapterContent.Heading_Highlight_Title_1__c = 'Test Title';
        newChapterContent.Heading_Highlight_Title_2__c = 'Test Title';
        newChapterContent.Heading_Highlight_Title_3__c = 'Test Title';
        newChapterContent.RecordTypeId = activeRT;
        newChapterContent.Chapter_Name__c = chapterId;
        insert newChapterContent;
        return newChapterContent;
    }
    
    public static Dynamic_Content__c  createDynamicContent()
    {
        Constant_AC constant = new Constant_AC();
        String nationalRT = Schema.Sobjecttype.Dynamic_Content__c.getRecordTypeInfosByName().get(constant.nationalRT).getRecordTypeId();
        Dynamic_Content__c  newContent = new Dynamic_Content__c();
        newContent.Sign_Up_Page__c = 'Hai';
        newContent.RecordTypeId = nationalRT;
        newContent.Application_Overview__c = 'An interview is a great way to better understand the role(s) and expectations of the volunteer opportunities that you are interested in';
        newContent .Active__c = true;
        newContent.Interview_Additional_Info__c = 'Test';
        newContent.Orientation_Add_l_Info__c = 'Test';
        newContent.Sign_Up_Page__c = 'Test';
        newContent.Training_Additional_Info__c = 'Test';
        newContent.Welcome_Message__c = 'Test';
        newContent.WelcomePage__c = 'Test';
        newContent.Welcome_Text__c = 'Test';
        newContent.Why_Need_Background_Check__c = 'Test';
        
        insert newContent;
        return newContent;
        
    }
    
    public Static DocuSignCredentialsSetting__c insertDocusignSetting(){
        DocuSignCredentialsSetting__c newSetting = new DocuSignCredentialsSetting__c();
        newSetting.account__c = '0afd45e1-ae2d-468c-a168-b8603dae66a3';
        newSetting.IntegratorKey__c = 'ea6d625f-6c08-4b12-aa2d-554909addb30';
        newSetting.Password__c = 'metasoft100';
        newSetting.Name = 'kanagaraj@mstsolutions.com';
        insert newSetting;
        return newSetting;
    }
    public static case CreateParentCase( Id wishChildId) {
        Constant_AC  constant = new Constant_Ac();    
        Id parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
        Case newParentWish = new Case();
        newParentWish.RecordTypeId = parentWishRecordTypeId;
        newParentWish.Chapter_Name__c = 'Make A Wish Alabama';
        newParentWish.Subject = 'Parent Wish';
        newParentWish.ContactId = wishChildId;
        insert newParentWish;
        return newParentWish;
    }
    
    public static case createWishDeterminationCase(Id wishChildId, Id parentCaseId) {
        Constant_AC  constant = new Constant_Ac();    
        Id determinationtWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishDeterminationRT).getRecordTypeId();
        
        Case newDeterminationtWish = new Case();
        newDeterminationtWish.RecordTypeId = determinationtWishRecordTypeId;
        newDeterminationtWish.Chapter_Name__c = 'Make A Wish Alabama';
        newDeterminationtWish.Subject = 'Parent Wish';
        newDeterminationtWish.ContactId = wishChildId;
        insert newDeterminationtWish;
        return newDeterminationtWish;
        
    }
    
    public static case createWishPlanningCase(Id wishChildId, Id parentCaseId) {
        Constant_AC  constant = new Constant_Ac();    
        Id planningWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishPlanningAnticipationRT).getRecordTypeId();
        
        Case newPlanningtWish = new Case();
        newPlanningtWish.RecordTypeId = planningWishRecordTypeId;
        newPlanningtWish.Chapter_Name__c = 'Make A Wish Alabama';
        newPlanningtWish.Subject = 'Wish Planning & Anticipation';
        newPlanningtWish.ContactId = wishChildId;
        insert newPlanningtWish;
        return newPlanningtWish;
        
    }
    
    public static case createWishAssistCase(Id wishChildId, Id parentCaseId) {
        Constant_AC  constant = new Constant_Ac();    
        Id assistWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishAssistRT).getRecordTypeId();
        
        Case newAssistWish = new Case();
        newAssistWish.RecordTypeId = assistWishRecordTypeId;
        newAssistWish.Chapter_Name__c = 'Make A Wish Alabama';
        newAssistWish.Subject = 'Wish Assist';
        newAssistWish.ContactId = wishChildId;
        insert newAssistWish;
        return newAssistWish;
        
    }
    
    public static case createWishGrantCase(Id wishChildId, Id parentCaseId) {
        Constant_AC  constant = new Constant_Ac();    
        Id grantWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishGrantRT).getRecordTypeId();
        
        Case newGrantWish = new Case();
        newGrantWish.RecordTypeId = grantWishRecordTypeId;
        newGrantWish.Chapter_Name__c = 'Make A Wish Alabama';
        newGrantWish.Subject = 'Wish Grant';
        newGrantWish.ContactId = wishChildId;
        insert newGrantWish;
        return newGrantWish;
        
    }
    
    public static Volunteer_Opportunity__c CreateNewWishVolunteerOpportunity(Id chapterId, Id roleId, Id wishId) {
        Constant_AC  constant = new Constant_Ac();    
        Id wishVolunteerOpportunityRecordTypeId = Schema.Sobjecttype.Volunteer_Opportunity__c.getRecordTypeInfosByName().get(constant.wishVolunteerOpportunity).getRecordTypeId();
        
        Volunteer_Opportunity__c newWishOpportunity =  new Volunteer_Opportunity__c();
        newWishOpportunity.Chapter_Role_Opportunity__c = roleId;
        newWishOpportunity.Wish__c = wishId;
        newWishOpportunity.Chapter_Name__c = chapterId;
        newWishOpportunity.RecordTypeId = wishVolunteerOpportunityRecordTypeId;
        insert newWishOpportunity;
        return newWishOpportunity;
        
    }
    
    public static Volunteer_Opportunity__c createDuplicateNewWishVolunteerOpportunity(Id chapterId, Id roleId, Id wishId) {
        Constant_AC  constant = new Constant_Ac();    
        Id wishVolunteerOpportunityRecordTypeId = Schema.Sobjecttype.Volunteer_Opportunity__c.getRecordTypeInfosByName().get(constant.wishVolunteerOpportunity).getRecordTypeId();
        
        Volunteer_Opportunity__c newWishOpportunity =  new Volunteer_Opportunity__c();
        newWishOpportunity.Chapter_Role_Opportunity__c = roleId;
        //newWishOpportunity.Volunteer_Name__c = volunteerId;
        newWishOpportunity.Wish__c = wishId;
        newWishOpportunity.Chapter_Name__c = chapterId;
        newWishOpportunity.RecordTypeId = wishVolunteerOpportunityRecordTypeId;
        insert newWishOpportunity;
        return newWishOpportunity;
        
    }
    
    
    public static Non_Wish_Events__c CreateEvent(Id ChapterId) {
        Constant_AC  constant = new Constant_Ac();    
        Id EventRecTypeId = Schema.Sobjecttype.Non_Wish_Events__c.getRecordTypeInfosByName().get(constant.events).getRecordTypeId();
        Non_Wish_Events__c newEvent = new Non_Wish_Events__c();
        newEvent.Event_Name__c = 'Send Off';
        newEvent.Event_Date__c = System.Today()+5;
        newEvent.Event_Text__c = 'Sending Wish Child';
        newEvent.RecordTypeId =  EventRecTypeId;
        insert newEvent;
        return newEvent;
    }
    
    public static Non_Wish_Events__c CreateEventRec(Id chaterRoleId,Id chaterId) {
        Constant_AC  constant = new Constant_Ac();    
        Id EventRecTypeId = Schema.Sobjecttype.Non_Wish_Events__c.getRecordTypeInfosByName().get(constant.events).getRecordTypeId();
        Non_Wish_Events__c newEvent = new Non_Wish_Events__c();
        newEvent.Event_Name__c = 'Send Off';
        newEvent.Event_Date__c = System.Today()+5;
        newEvent.Event_Text__c = 'Sending Wish Child';
        newEvent.RecordTypeId =  EventRecTypeId;
        newEvent.Volunteer_Need__c = 3;
        newEvent.Chapter_Role__c = chaterRoleId;
        newEvent.Chapter__c = chaterId;
        insert newEvent;
        system.debug('_____ NONWISH EVENTID _____'+newEvent.id);
        return newEvent;
        
    }
    
    public static Volunteer_Count__c  createVolunteerCount(Id nonWishId,Id chapterRoleId,Integer count){
        Volunteer_Count__c newVolCount = new Volunteer_Count__c ();
        newVolCount.Volunteer_Needed__c = count;
        newVolCount.Chapter_Role__c = chapterRoleId;
        newVolCount .Non_Wish_Events__c = nonWishId;
        insert newVolCount; 
        system.debug('@@@@@@@ createVolunteerCount @@@@@@@'+newVolCount);
        return newVolCount;
        
    }
    
    public static Volunteer_Opportunity__c CreateNonWishVolunteerOpportunity(Id chapterId, Id roleId, Id eventId) {
        Constant_AC  constant = new Constant_Ac();    
        Id nonWishRT = Schema.Sobjecttype.Volunteer_Opportunity__c.getRecordTypeInfosByName().get(constant.nonWishEventRT).getRecordTypeId();
        
        Volunteer_Opportunity__c newNonWishOpportunity =  new Volunteer_Opportunity__c();
        newNonWishOpportunity.Chapter_Role_Opportunity__c = roleId;
        newNonWishOpportunity.Non_Wish_Event__c = eventId;
        newNonWishOpportunity.Chapter_Name__c = chapterId;
        newNonWishOpportunity.RecordTypeId = nonWishRT;
        insert newNonWishOpportunity;
        return newNonWishOpportunity;
        
    }
    public static Volunteer_Opportunity__c CreateNonWishDuplicateVolunteerOpportunity(Id chapterId, Id roleId, Id eventId) {
        Constant_AC  constant = new Constant_Ac();    
        Id nonWishRT = Schema.Sobjecttype.Volunteer_Opportunity__c.getRecordTypeInfosByName().get(constant.nonWishEventRT).getRecordTypeId();
        
        Volunteer_Opportunity__c newNonWishOpportunity =  new Volunteer_Opportunity__c();
        newNonWishOpportunity.Chapter_Role_Opportunity__c = roleId;
        newNonWishOpportunity.Non_Wish_Event__c = eventId;
        newNonWishOpportunity.Chapter_Name__c = chapterId;
        newNonWishOpportunity.RecordTypeId = nonWishRT;
        insert newNonWishOpportunity;
        return newNonWishOpportunity;
        
    }
    
    
    
    public static Dynamic_Content__c  createProspectiveDynamicContent(Id chapterId)
    {
        Constant_AC constant = new Constant_AC();
        String nationalRT = Schema.Sobjecttype.Dynamic_Content__c.getRecordTypeInfosByName().get(constant.prospectiveVolunteerRT).getRecordTypeId();
        Dynamic_Content__c  newContent = new Dynamic_Content__c();
        newContent.RecordTypeId = nationalRT;
        newContent.How_do_I_Become_a_Volunteer__c = 'Test';
        newContent.Chapter_Name__c = chapterId;
        
        insert newContent;
        return newContent;
        
    }
    
    public static List<Volunteer_Opportunity__c> NewWishVolunteerOpportunityList(Id chapterId, Id roleId, Id wishId,Integer count) {
        Constant_AC  constant = new Constant_Ac();    
        Id wishVolunteerOpportunityRecordTypeId = Schema.Sobjecttype.Volunteer_Opportunity__c.getRecordTypeInfosByName().get(constant.wishVolunteerOpportunity).getRecordTypeId();
        List<Volunteer_Opportunity__c> volunteerOpportunityList = new List<Volunteer_Opportunity__c>();
        for(Integer i = 0; i<= count; i++){
            Volunteer_Opportunity__c newWishOpportunity =  new Volunteer_Opportunity__c();
            newWishOpportunity.Chapter_Role_Opportunity__c = roleId;
            newWishOpportunity.Wish__c = wishId;
            newWishOpportunity.Chapter_Name__c = chapterId;
            newWishOpportunity.IsApproved__c = false;
            newWishOpportunity.RecordTypeId = wishVolunteerOpportunityRecordTypeId;
            volunteerOpportunityList.add(newWishOpportunity);
            insert newWishOpportunity;
        }
        return volunteerOpportunityList;
        
    }
    
    public static List<Volunteer_Opportunity__c> NewnonWishVolunteerOpportunityList(Id chapterId, Id roleId, Id nonWishId,Integer count) {
        Constant_AC  constant = new Constant_Ac();    
        Id wishVolunteerOpportunityRecordTypeId = Schema.Sobjecttype.Volunteer_Opportunity__c.getRecordTypeInfosByName().get(constant.wishVolunteerOpportunity).getRecordTypeId();
        List<Volunteer_Opportunity__c> volunteerOpportunityList = new List<Volunteer_Opportunity__c>();
        for(Integer i = 1; i<= count; i++){
            Volunteer_Opportunity__c newWishOpportunity =  new Volunteer_Opportunity__c();
            newWishOpportunity.Chapter_Role_Opportunity__c = roleId;
            newWishOpportunity.Non_Wish_Event__c = nonWishId;
            newWishOpportunity.Chapter_Name__c = chapterId;
            newWishOpportunity.RecordTypeId = wishVolunteerOpportunityRecordTypeId;
            volunteerOpportunityList.add(newWishOpportunity);
            insert newWishOpportunity;
        }
        return volunteerOpportunityList;
        
    }
    
    public Static  List<Time_sheet__c> crateWishTimeSheet(List<Volunteer_Opportunity__c> WishOpportunityList){
        List<Time_sheet__c> nonwishDeterminationList = new List<Time_sheet__c>();
        for(Integer i = 0; i< WishOpportunityList.Size(); i++){
            Time_sheet__c newTimeSheet = new Time_sheet__c();
            newTimeSheet.Date__c = system.today();
            newTimeSheet.Hours_spent__c = 12.50;
            newTimeSheet.Volunteer_Opportunity__c =WishOpportunityList.get(i).Id;
            nonwishDeterminationList .add(newTimeSheet);
        }
        insert nonwishDeterminationList;
        return nonwishDeterminationList;
        
    }
    
    public Static  List<Time_sheet__c> crateNonWishTimeSheet(List<Volunteer_Opportunity__c> nonWishopportunityList,integer a ){
        List<Time_sheet__c> nonwishDeterminationList = new List<Time_sheet__c>();
        for(Integer i = 1; i <=a; i++){
            Time_sheet__c newTimeSheet = new Time_sheet__c();
            newTimeSheet.Date__c = system.today();
            newTimeSheet.Hours_spent__c = 12.50;
            newTimeSheet.Volunteer_Opportunity__c =nonWishopportunityList.get(0).Id;
            nonwishDeterminationList .add(newTimeSheet);
        }
        insert nonwishDeterminationList;
        return nonwishDeterminationList;
        
    }
    
    public static user createrSystemAdminUser(){
        UserRole newUserRole = new UserRole();
        newUserRole.Name  = 'Make A Wish Alabama';
        Insert newUserRole;
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
        
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        
        User tuser = new User(  firstname = 'Test FirstName',
                              lastName = 'Test LastName',
                              email = 'testmawa@gmail.com',
                              Username = uniqueName + '@test' + orgId + '.org',
                              EmailEncodingKey = 'ISO-8859-1',
                              Alias = uniqueName.substring(18, 23),
                              TimeZoneSidKey = 'America/Los_Angeles',
                              LocaleSidKey = 'en_US',
                              LanguageLocaleKey = 'en_US',
                              ProfileId = pf.Id,
                              isActive = true,
                              State = 'Arizona',
                              UserRoleId = newUserRole.Id);
        insert tuser;
        
        return tuser;
        
    }
    
    public static npe5__Affiliation__c CreateAffiliationwithAccount(Id contactId,Id AccountId)
    {
        
        npe5__Affiliation__c neworgAffiliation = new npe5__Affiliation__c ();
        neworgAffiliation.npe5__Contact__c  = contactId;
        neworgAffiliation.npe5__Organization__c = AccountId;
        neworgAffiliation.npe5__Primary__c = true;
        neworgAffiliation.npe5__Status__c = 'Prospective';
        insert neworgAffiliation;
        return neworgAffiliation;
        
    }
    
    public static npe5__Affiliation__c CreateAffiliationwithNullStatus(Id AccountId,Id contactId)
    {
        
        npe5__Affiliation__c neworgAffiliation = new npe5__Affiliation__c ();
        neworgAffiliation.npe5__Contact__c  = contactId;
        neworgAffiliation.npe5__Organization__c = AccountId;
        neworgAffiliation.npe5__Primary__c = true;
        //neworgAffiliation.npe5__Status__c = '';
        insert neworgAffiliation;
        return neworgAffiliation;
        
    }
    
    
    
    public Static void cretateGroup(){
        Group leadalabamaGroup = new Group(Type='Regular', Name='Arizona');
        insert leadalabamaGroup ;
    }
    
    
    public static case ParentCasetoAddCaseMember( Id wishChildId) {
        Constant_AC  constant = new Constant_Ac();    
        Id parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
        Case newParentWish = new Case();
        newParentWish.RecordTypeId = parentWishRecordTypeId;
        newParentWish.Chapter_Name__c = 'Make A Wish Alabama';
        newParentWish.Subject = 'Parent Wish';
        newParentWish.ContactId = wishChildId;
        insert newParentWish;
        return newParentWish;
    }
    
    public static Chapter_Action_Track__c createChapterActionTrack() {
        Chapter_Action_Track__c newChapterAction = new Chapter_Action_Track__c();
        newChapterAction.Assigned_To__c = 'Volunteer Manager';
        newChapterAction.Case_Type_Stage__c = 'Wish Determination';
        newChapterAction.Due_Date__c = 10;
        newChapterAction.Task_Name__c = 'Planning';
        newChapterAction.Sort_Order__c = 1;
        newChapterAction.Wish_type__c = 'Standard';
        newChapterAction.Recurring__c = true;
        newChapterAction.Recurring_Frequency__c = 1;
        return newChapterAction;
    }
    
    public static Chapter_Action_Track__c duplicateChapterActionTrack() {
        Chapter_Action_Track__c newChapterAction = new Chapter_Action_Track__c();
        newChapterAction.Assigned_To__c = 'Volunteer Manager';
        newChapterAction.Case_Type_Stage__c = 'Wish Planning & Anticipation';
        newChapterAction.Due_Date__c = 10;
        newChapterAction.Task_Name__c = 'Planning';
        newChapterAction.Sort_Order__c = 1;
        newChapterAction.Wish_type__c = 'Standard';
        newChapterAction.Recurring__c = true;
        newChapterAction.Recurring_Frequency__c = 10;
        return newChapterAction;
    }
    
    public static Group createChatterGroup() {
        Group alabamaGroup = new Group();
        alabamaGroup.Name = 'Make-A-Wish Alabama';
        alabamaGroup.DeveloperName = 'ABC';
        insert alabamaGroup;
        return  alabamaGroup;
    }
    
    public static CaseTeamMember createCaseTeamMember(Id parentId, Id wishId, Id roleId) {
        CaseTeamMember caseMember = new CaseTeamMember();
        caseMember.ParentId = parentId;
        caseMember.memberId = wishId;
        caseMember.TeamRoleId = roleId;
        insert caseMember;
        return caseMember;
    }
    
    public static CollaborationGroup createCollaborationGroup(string chapterName){
        CollaborationGroup newGroup = new CollaborationGroup();
        newGroup.name = chapterName;
        newGroup.CollaborationType = 'Public';
        insert newGroup;
        return newGroup;
        
    }
    
    public static CollaborationGroupMember createCollabrationGroupMember(Id collabrationId,Id sysUserId){
    CollaborationGroupMember newGroupMember = new CollaborationGroupMember();
    newGroupMember.CollaborationGroupId = collabrationId;
    newGroupMember.MemberId = sysUserId;
    insert newGroupMember;
    return newGroupMember;
    }
    
     public static Background_check__c createBackgroundCheckFasleRec(Id contactId){
        Background_check__c backCheck = new Background_check__c();
        backCheck.Date__c = system.today() + 3;
        backCheck.Volunteer__c = contactId;
        backCheck.Date_Completed__c = system.today() + 3;
        backCheck.Status__c = '';
        backCheck.active__c = false;
        insert backCheck;
        return backCheck;
    }
    
     public static Background_check__c createBackgroundCheckRec(Id contactId){
        Background_check__c backCheck = new Background_check__c();
        backCheck.Date__c = system.today() + 3;
        backCheck.Volunteer__c = contactId;
        backCheck.Status__c = '';
        backCheck.Active__c = true;
        backCheck.Date_Completed__c = system.today() + 9;
        insert backCheck;
        return backCheck;
    }
    
    public static Background_check__c createBackgroundCheckActiveRec(Id contactId){
        Background_check__c backCheck = new Background_check__c();
        backCheck.Date__c = system.today() + 3;
        backCheck.Volunteer__c = contactId;
        backCheck.Status__c = '';
        backCheck.Active__c = true;
        backCheck.Date_Completed__c = system.today() + 9;
        insert backCheck;
        return backCheck;
    }
    
    public static Account AlabamaAccount(){
        Constant_AC  constant = new Constant_AC();
        Id ChapterRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(constant.chapterRT).getRecordTypeId();
            
            Account newchapterAccount = new Account();
            newchapterAccount .Name = 'Make-A-Wish Alabama';
            newchapterAccount.RecordTypeId = ChapterRecordTypeId;
       insert newchapterAccount;
       return newchapterAccount;
    }
    
     public static Office__c createOffice(Id AccountId) {
        Office__c newOffice = new Office__c();
        newOffice.Chapter__c = AccountId;
        newOffice.Name = 'Make-A-Wish Alabama';
        newOffice.Office_Id__c = '014-000';
        newOffice.Office_Legal_Name__c = 'Make-A-Wish Alabama,NY, Inc.';
        newOffice.General_Email_Address__c = 'wishmail@suffolk.wish.org';
        newOffice.Website__c = 'http://suffolk.wish.org';
        newOffice.Address_1__c = '1 Comac Loop';
        newOffice.Address_2__c = 'Suite 1A1';
        newOffice.City__c = 'Ronkonkoma';
        newOffice.State__c = 'NY';
        newOffice.Zip_Code__c = '32193';
        newOffice.Country__c = 'US';
        newOffice.Phone_Number__c = '(631) 585-9474';
        
        return newOffice;
    }
    
    public static Zip_Code__c createZipcode(Id officeId){
        Zip_Code__c  newZip = new Zip_Code__c ();
        newZip.Name = '32193';
        newZip.Office__c  = officeId;
        return newZip;
    }
    
    
     public static user createChapterUser(){
        UserRole newUserRole = new UserRole();
        newUserRole.Name  = 'Make A Wish Alabama';
        Insert newUserRole;
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'Chapter Dev/Fin Staff'];
        
        
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        
        User tuser = new User(  firstname = 'Test FirstName',
                              lastName = 'Test LastName',
                              email = 'test123@gmail.com',
                              Username = uniqueName + '@test' + orgId + '.org',
                              EmailEncodingKey = 'ISO-8859-1',
                              Alias = uniqueName.substring(18, 23),
                              TimeZoneSidKey = 'America/Los_Angeles',
                              LocaleSidKey = 'en_US',
                              LanguageLocaleKey = 'en_US',
                              ProfileId = pf.Id,
                              isActive = true,
                              State = 'Alabama',
                              UserRoleId = newUserRole.Id);
        insert tuser;
        
        return tuser;
        
    }
    
    public static Lead createTestLeadRec(Id chapterAccountId){
     
            Lead newLead = new Lead();
            newLead.FirstName = 'moss';
            newLead.LastName = 'Smith Household';
            newLead.Phone = '9600467559';
            newLead.Email = 'testmawa@gmail.com';
            newLead.Street = 'KuttaiKarai Street';
            newLead.StateCode = 'AZ';
            newLead.city = 'Trichy';
            newLead.Postalcode = '6201717';
            newLead.CountryCode = 'US';
            newLead.DOB__c = System.today() - 1435;
            newLead.company = 'MAWA';
            newLead.Status = 'Inquiry';
            newLead.Gender__c = 'Male';
            newLead.ChapterName__c = chapterAccountId;
            newLead.Referrer_FirstName__c = 'Sudhar';
            newLead.Referrer_Last_Name__c = 'test';
            newLead.Referrer_Email__c = 'sudhar1@gmail.com';
            newLead.Referrer_Phone__c = '0600467559';
            newLead.Referrer_City__c = 'Trichy';
            newLead.Referrer_Zip__c = '6210';
            newLead.Sibling_Detail__c = 'aa | aaab | 14 bbb | bbbc | 15';
            newLead.Primary_Diagnosis__c = 'Test Diagnosis';
            newLead.Parent_First_Name__c = 'MAWAFirstName';
            newLead.Parent_Last_Name__c = 'MAWALastName';
            newLead.Medical_Professional_First_Name__c = 'moss';
            newLead.Medical_Professional_Last_Name__c = 'hart';
            newLead.Medical_Professional_Phone__c = '9600467558';
            newLead.Medical_Professional_Email__c = 'testmawa1@gmail.com';
            newLead.Hospital_Treatment_Facility__c = 'Moss Hart AC';
            newLead.Treating_Medical_Professional_First_Name__c = 'Steve';
            newLead.Treating_Medical_Professional_Last_Name__c = 'Waugh';
            newLead.Treating_Medical_Professional_Phone__c = '9600467557';
            newLead.Treating_Medical_Professional_Email__c = 'testmawa2@gmail.com';
            newLead.Hospital_Treatment_Facility_Treating__c = 'Steve Smith AC';
            newLead.is_Family_Aware_of_Referral__c = 'Yes';
            newLead.Medical_Questions__c = 'Test Diagnosis';
            newLead.ICD_10_Code__c = 'C12.0';
          newLead.Lung_Disease__c = 'Test1;Test2';
            newLead.Angina__c = 'Test1;Test2';
            newLead.Ventilator__c = 'Test1;Test2';
            newLead.Arrhythmia__c = 'Test1;Test2';
            newLead.Heart_Failure__c = 'Test1;Test2';
            newLead.Congenital_Heart_Disease__c = 'Test1;Test2';
            newLead.Chronic_Hepatitis__c = 'Test1;Test2';
            newLead.Convulsive_Disorders__c = 'Test1;Test2';
            newLead.Pulmonary_Hypertension__c = 'Test1;Test2';
            newLead.Strokes__c = 'Test1;Test2';
        newLead.Chronic_Heart_Failure__c = 'Test1;Test2';
            newLead.isSign__c = true;
       newLead.Communication__c = 'Non-Verbal';
        newLead.Travel_algorithm__c = 'Test1;Test2;';
            return newLead;
        
     }
     
    public Static Medical_Questions__c CreateMedicalQuestion(Id ConditionDesc) {
        Constant_AC  constant = new Constant_AC();
        Id algorithmRecordTypeId = Schema.SObjectType.Medical_questions__c.getRecordTypeInfosByName().get(constant.travelAlgmRT).getRecordTypeId();
        Medical_Questions__c newQuestions = new Medical_Questions__c();
        newQuestions.Question__c = 'Is child currently or within one year of completing treatment for this condition?';
        newQuestions.Picklist_values__c = 'Yes,No';
        newQuestions.Data_Type__c = 'Picklist';
        newQuestions.RecordTypeId = algorithmRecordTypeId;
        newQuestions.Wrapper_Variable__c = 'TestWrapper';
        newQuestions.Current_Condition__c = 'Test';
        newQuestions.Recommendation_to_Chapter__c = 'None Apply';
        newQuestions.Condition_Description__c = ConditionDesc;
        return newQuestions;
    }
    
    public Static Diagnosis_Verification__c createDiagnosis(Id leadId, Id medicalQues) {
        Diagnosis_Verification__c newDiagnosis = new Diagnosis_Verification__c();
        newDiagnosis.Lead__c = leadId;
        newDiagnosis.Epilepsy_Value__c = '';
        newDiagnosis.Medical_Question__c = medicalQues;
        return newDiagnosis;
    }
     
      public static contact CreateTreatingMedicalProfContact(){
        Constant_AC  constant = new Constant_AC();
        Id medicalProfessionalRecordTypeId = Schema.SobjectType.Contact.getRecordTypeInfosByName().get(constant.MedicalProfessionalRT).getRecordTypeId();
        Contact treatingProfContact = new Contact();
        treatingProfContact.FirstName = 'Steve';
        treatingProfContact.LastName = 'Waugh';
        treatingProfContact.Email = 'testmawa2@gmail.com';
        treatingProfContact.Phone =  '9600467557';
        treatingProfContact.MailingStreet ='KuttaiKarai Street';
        treatingProfContact.MailingCity = 'Trichy';
        treatingProfContact.MailingStateCode = 'AZ';
        treatingProfContact.MailingPostalCode  = '6201717';
        treatingProfContact.MailingCountryCode = 'US';
        treatingProfContact.RecordTypeId = medicalProfessionalRecordTypeId;
        insert treatingProfContact;
        return treatingProfContact;
    
    }
     
     
     
     public static contact CreateMedicalProfContact(){
        Constant_AC  constant = new Constant_AC();
        Id medicalProfessionalRecordTypeId = Schema.SobjectType.Contact.getRecordTypeInfosByName().get(constant.MedicalProfessionalRT).getRecordTypeId();
        Contact medicalProfContact = new Contact();
        medicalProfContact .FirstName = 'moss';
        medicalProfContact .LastName = 'hart';
        medicalProfContact .Email = 'testmawa1@gmail.com';
        medicalProfContact .Phone =  '9600467558';
        medicalProfContact .MailingStreet ='KuttaiKarai Street';
        medicalProfContact .MailingCity = 'Trichy';
        medicalProfContact .MailingStateCode = 'AZ';
        medicalProfContact .MailingPostalCode  = '6201717';
        medicalProfContact .MailingCountryCode = 'US';
        medicalProfContact .RecordTypeId = medicalProfessionalRecordTypeId;
        insert medicalProfContact;
        return medicalProfContact;
    
    }
     
     
     
     public static contact CreateWishFamily(){
        Constant_AC  constant = new Constant_AC();
         Id wishFamilyRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.wishFamilyRT).getRecordTypeId();
        Contact wishFamilyCon = new Contact();
        wishFamilyCon.FirstName = 'MAWAFirstName';
        wishFamilyCon.LastName = 'MAWALastName';
        wishFamilyCon.Email = 'testmawa@gmail.com';
        wishFamilyCon.Phone = '9600467559';
        wishFamilyCon.MailingStreet ='KuttaiKarai Street';
        wishFamilyCon.MailingCity = 'Trichy';
        wishFamilyCon.MailingStateCode = 'AZ';
        wishFamilyCon.MailingPostalCode  = '6201717';
        wishFamilyCon.MailingCountryCode = 'US';
        wishFamilyCon.RecordTypeId = wishFamilyRecordTypeId ;
        insert wishFamilyCon ;
        return wishFamilyCon ;
    
    }
     
    public static contact CreateWishChildCon(){
    
        Constant_AC  constant = new Constant_AC();
        Id wishChildRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.contactWishChildRT).getRecordTypeId();
        Contact wishChildCon = new Contact();
        wishChildCon.FirstName = 'moss';
        wishChildCon.LastName = 'Smith Household';
        wishChildCon.Email = 'testmawa@gmail.com';
        wishChildCon.Phone = '9600467559';
        wishChildCon.MailingCity = 'Trichy';
        wishChildCon.MailingStateCode = 'AZ';
        wishChildCon.MailingPostalCode  = '6201717';
        wishChildCon.MailingCountryCode = 'US';
        wishChildCon.RecordTypeId = wishChildRecordTypeId;
        insert wishChildCon;
        return wishChildCon;
    
    }
    
     
    
    
    public static Condition_Description__c createConditionDesCription(){
       
        Condition_Description__c newDesc = new Condition_Description__c();
        newDesc.Name = 'Malignant Melanoma';
        newDesc.Treatment_Subspecialty__c = 'Oncology';
        newDesc.Code_To_Use__c = 'C43';
        newDesc.MAW_Name__c = 'Malignant Melanoma';
        newDesc.Group1__c = true;
      
        return newDesc;
    }
    
    public static ICD_Codes__c createICDCode(Id conditionDescId){
        
        ICD_Codes__c  newICD = new ICD_Codes__c ();
        newICD.Name = 'C43.30';
        newICD.Condition_Description__c = conditionDescId;
        newICD.Group1__c = true;
        newICD.Short_Description__c = 'Malignant melanoma of unspecified part of face';
        newICD.Long_Description__c = 'Malignant melanoma of unspecified part of face';
       
        return newICD;
    }
    
    
    public static Diagnosis_Verification__c  createDiagnosis(Id leadId){
       
       Diagnosis_Verification__c newDiagVf = new Diagnosis_Verification__c();
       newDiagVf.ICD_Code__c = 'CRO13';
       newDiagVf.Epilepsy_Value__c = 'TEST';
       newDiagVf.Lead__c = leadId;
       //newDiagVf.Medical_Question__c = medicalconId;
       newDiagVf.Medical_Question_Answer__c = 'TEST';
       newDiagVf.Order__c = 2;
       newDiagVf.Primary_Diagnosis__c = 'test';
       newDiagVf.Reason_for_Need__c = 'test';
      
       return newDiagVf ;
       
    }
    
      public static dsfs__DocuSign_Status__c createDocusignStatus(Id LeadId){
     
            dsfs__DocuSign_Status__c dsfs= NEW dsfs__DocuSign_Status__c();
            dsfs.dsfs__DocuSign_Envelope_ID__c = '0F31B5A9-DB3A-4D31-8D69-9DE86F2010A8';
            dsfs.dsfs__Lead__c= LeadId;
            dsfs.isConflict__c = false;
           
        Insert dsfs;
        return dsfs;
     }
     
     public static case CreatePartAWish(Id LeadId){
         
         case newPartACase= new Case();
         newPartACase.Origin = 'Email';
         newPartACase.Lead__c = LeadId;
         newPartACase.Status = 'Open';
        
         insert newPartACase;
         return newPartACase;
     }
    
    
    public static case CreatePartAWishRec(){
         Constant_AC  constant = new Constant_Ac(); 
         Id partARecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(constant.partARecordTypeId).getRecordTypeId();   
         case newPartAcase = new Case();
         newPartAcase.Origin = 'Email';
         newPartAcase.Status = 'Open';
         newPartACase.RecordTypeId = partARecordTypeId; 
         return newPartAcase;
     }
    
      public static Account MakeAWishAmericaAcc(){
        Constant_AC  constant = new Constant_AC();
        Id ChapterRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(constant.chapterRT).getRecordTypeId();
            
            Account newchapterAccount = new Account();
            newchapterAccount .Name = 'Make-A-Wish America';
            newchapterAccount.RecordTypeId = ChapterRecordTypeId;
            newchapterAccount.MAC_Email_del__c = 'testMAC@gmail.com';
       insert newchapterAccount;
       return newchapterAccount;
    }
    
     public static dsfs__DocuSign_Status__c createDocusignStatuswithCon(Id contactId){
        
        dsfs__DocuSign_Status__c dsfs= NEW dsfs__DocuSign_Status__c();
        dsfs.dsfs__DocuSign_Envelope_ID__c = '0F31B5A9-DB3A-4D31-8D69-9DE86F2010A8';
        dsfs.dsfs__Contact__c = contactId;
        dsfs.dsfs__Envelope_Status__c  = 'Sent';
        
        Insert dsfs;
        return dsfs;
    }
    
    public static Lead_File__c createLeadFileRecord(Id LeadId) {
        Lead_File__c newLeadFile = new Lead_File__c();
        newLeadFile.File_Name__c = 'MedicalSummary.txt';
        newLeadFile.Parent__c = LeadId;
        newLeadFile.Content_Type__c = 'text/plain';
        insert newLeadFile;
        return newLeadFile;
    }
    
   /* public static Lead_File__c createLeadFileRec(Id LeadId);
        
        Lead_File__c  newLeadFile = new Lead_File__c ();
        //newLeadFile.Content_Type__c = text/plain;
        //newLeadFile.Description__c =
        //newLeadFile.File_Name__c = 'Tes2.txt';
        //newLeadFile.File_Size_in_Bytes__c = 
        //newLeadFile.Is_Latest_Version__c = 
        //newLeadFile.Key__c = '00Q11000008CXBp/a1Q11000001HtJ9EAK/Tes2.txt';
        newLeadFile.Parent__c = LeadId;
        //newLeadFile.Private__c = 
        //newLeadFile.Version_Description__c = 
        //newLeadFile.Version_Id__c = 
        //newLeadFile.WIP__c = 
        insert newLeadFile;
        retrun newLeadFile;*/
        
}