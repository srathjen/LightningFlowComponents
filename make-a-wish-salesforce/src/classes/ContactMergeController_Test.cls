@isTest
public class ContactMergeController_Test 
{
    public static  testmethod void ContactMergerTest()
    {   
        Account hospitaltreatmentaccount=OrientationandTrainingUtil.HospitalTreatment();
        Account chapteraccount=OrientationandTrainingUtil.MakeAWishAmericaAcc();
        Account householdaccount=OrientationandTrainingUtil.HouseHoldAccount();
        Contact confamily = OrientationandTrainingUtil.CreateWishFamily();
        Contact conchild = OrientationandTrainingUtil.CreateWishChild();
        Contact convolunteer=OrientationandTrainingUtil.createVolunteerContact(chapteraccount.Id);
        
        test.startTest();
        Contact medicalprof=OrientationandTrainingUtil.CreateMedicalProfContact();
        Conflict_Of_Interest__c coi=OrientationandTrainingUtil.createCOI(convolunteer.id);
        Role__c role=OrientationandTrainingUtil.createRole();
        Orientation_Training__c ot=OrientationandTrainingUtil.CreateVolunteerOrientationRecord();
        Chapter_Role__c chapterrole=OrientationandTrainingUtil.createChapter(chapteraccount.id,role.id);
        Chapter_Role_O_T__c chapterroleot=OrientationandTrainingUtil.createChapterOandT(chapterrole.id,ot.Id);
        //Case wish=OrientationandTrainingUtil.ParentCasetoAddCaseMember(conchild.Id);
        Class_Offering__c classoff=OrientationandTrainingUtil.createClassOffering(chapterroleot.Id);
        npe4__Relationship__c relation=OrientationandTrainingUtil.relationshipChild(confamily.id,conchild.id);
        npe5__Affiliation__c affiliation=OrientationandTrainingUtil.CreateAffiliation(medicalprof.id);
        Volunteer_Roles__c volrole=OrientationandTrainingUtil.createVolRole(convolunteer.Id,chapterrole.Id);
        Volunteer_Orientation_Training__c volorientationtraining=OrientationandTrainingUtil.createVolOrientation(ot.Id,classoff.Id,medicalprof.Id,'Registered');
        Volunteer_Opportunity__c volopp=OrientationandTrainingUtil.NewnonWishVolunteerOpportunity(chapterAccount.Id,convolunteer.id);
        Background_check__c backgdcheck=OrientationandTrainingUtil.createBackgroundCheck(convolunteer.Id);
        Awards_Recognition__c awdreg=OrientationandTrainingUtil.CreateAwardRecognition(chapteraccount.Id,convolunteer.Id);
        In_Kind_Donation_Reimbursement__c inkinddonation=OrientationandTrainingUtil.createReImbursementRecord();
        ApexPages.StandardController sc = new ApexPages.StandardController(convolunteer);
        ContactMergeController_AC testobj = new ContactMergeController_AC(sc);
        testobj.getStates();
        ContactMergeController_AC.contactWrapper contactwrapper1=new ContactMergeController_AC.contactWrapper(convolunteer);
        ContactMergeController_AC.contactWrapper contactwrapper2=new ContactMergeController_AC.contactWrapper(convolunteer);
        ContactMergeController_AC.Cell testcellwrap=new ContactMergeController_AC.Cell(convolunteer.Id,convolunteer.Name);
        ContactMergeController_AC.VolunteerOpportunityWrapper volopwrap=new  ContactMergeController_AC.VolunteerOpportunityWrapper(volopp);
        ContactMergeController_AC.VolunteerRoleWrapper volrolwrap=new  ContactMergeController_AC.VolunteerRoleWrapper(volrole);
        ContactMergeController_AC.VolunteerOTWrapper volotwrap=new  ContactMergeController_AC.VolunteerOTWrapper(volorientationtraining);
        ContactMergeController_AC.affiliationWrapper affwrap=new ContactMergeController_AC.affiliationWrapper(affiliation);
        ContactMergeController_AC.relationshipWrapper relwrap=new ContactMergeController_AC.relationshipWrapper(relation);
        ContactMergeController_AC.BackgroundCheckWrapper backgdwrap=new  ContactMergeController_AC.BackgroundCheckWrapper(backgdcheck);
        ContactMergeController_AC.AwardsRecognitionWrapper awdwrap=new ContactMergeController_AC.AwardsRecognitionWrapper(awdreg);
        ContactMergeController_AC.ConflictOfInterestWrapper coiwrap=new ContactMergeController_AC.ConflictOfInterestWrapper(coi);
        ContactMergeController_AC.InkindDonationWrapper inkindwrap=new ContactMergeController_AC.InkindDonationWrapper(inkinddonation);
        ContactMergeController_AC.FieldRow fieldrow=new ContactMergeController_AC.FieldRow('$MASTER$','Master Record',true,'teststyleclass');
        cg__ContactFile__c cf=new cg__ContactFile__c();
        cf.Name='Test';
        cf.cg__Contact__c=convolunteer.id;
        cf.cg__File_Name__c='Test File';
        insert cf;
        // testobj.search();
        List<Contact> conlists=new List<Contact>();
        conlists.add(confamily);
        testobj.addFieldComparisonRows('Wish_Child_Id_Hidden__c',Contact.Wish_Child_Id_Hidden__c.getDescribe(),conlists);
        contactwrapper1.selected=true;
        testobj.searchResults.add(contactwrapper1);
        contactwrapper2.selected=true;
        testobj.searchResults.add(contactwrapper2);
        testobj.selectedRecords.put(confamily.id,confamily);
        testobj.setPageSize();
        testobj.nextStep();
        testobj.first();
        testobj.next();
        testobj.previous();
        testobj.last();
        Integer totalPage=testobj.getTotalPages();
        testobj.searchRecords();
        
        volopwrap.checkbox=true;
        volrolwrap.checkbox=true;
        volotwrap.checkbox=true;
        // testobj.volunteerRoleList.add(volrolwrap);
        relwrap.checkbox=true;
        affwrap.checkbox=true;
        backgdwrap.checkbox=true;
        inkindwrap.checkbox=true;
        awdwrap.checkbox=true;
        coiwrap.checkbox=true;
        
        testobj.volunteerOppList.add(volopwrap);
        testobj.volunteerRoleList.add(volrolwrap);
        testobj.volunteerOTList.add(volotwrap);
        testobj.relationshipList.add(relwrap);
        testobj.Affiliations.add(affwrap);
        testobj.backgroundcheckList.add(backgdwrap);
        testobj.awardsRecognitionList.add(awdwrap);
        testobj.inkindDonationList.add(inkindwrap);
        testobj.conflictofInterestList.add(coiwrap);
        testobj.fieldRows.add(fieldrow);
        // testobj.Affiliations.add(affiliation);
        testobj.mergeContacts();
        List<Contact> conlist=new List<Contact>();
        conlist.add(convolunteer);
        testobj.wrapSOSLResults(conlist);
        //User contid=[Select id,ContactId,IsPortalEnabled from User where IsPortalEnabled=true and isactive=false limit 1];
      //  Set<Id> contsetid=new Set<Id>();
      //  contsetid.add(contid.ContactId);
      //  ContactMergeController_AC.updateUser(contsetid);
        testobj.selectDefaultRecord();
        test.stopTest();
        // testobj.selectDefaultRecord();
        //testobj.mergeContacts();
        // 
        
    }
    
     public static  testmethod void ContactSearchRecord()
    {
        
        Account chapteraccount=OrientationandTrainingUtil.MakeAWishAmericaAcc();
        Contact confamily = OrientationandTrainingUtil.CreateWishFamily();
        Contact conchild = OrientationandTrainingUtil.CreateWishChild();
        Contact convolunteer=OrientationandTrainingUtil.createVolunteerContact(chapteraccount.Id);  
         ApexPages.StandardController sc = new ApexPages.StandardController(convolunteer);
        ContactMergeController_AC testobj = new ContactMergeController_AC(sc);
        
        testobj.con.FirstName = 'moss';
        testobj.con.LastName = 'Smith';
        testobj.con.MailingStreet  = 'ThillaiNagar';
        testobj.con.MailingCity = 'Trichy';
        testobj.con.MailingCountrycode = 'US';
        testobj.con.MailingPostalCode = '621010';
        testobj.con.mailingstatecode = 'AZ'; 
        testobj.searchRecords();
        testobj.setPageSize();
        testobj.first();
        testobj.next();
        testobj.previous();
        testobj.last();
        
        ContactMergeController_AC.contactWrapper contactwrapper1=new ContactMergeController_AC.contactWrapper(convolunteer);
        ContactMergeController_AC.contactWrapper contactwrapper2=new ContactMergeController_AC.contactWrapper(conchild);
        contactwrapper1.selected=true;
        testobj.searchResults.add(contactwrapper1);
        contactwrapper2.selected=true;
        testobj.searchResults.add(contactwrapper2);
        testobj.nextStep();
    }
    
}