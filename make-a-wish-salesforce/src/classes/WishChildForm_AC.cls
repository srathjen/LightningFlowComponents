/*****************************************************************************
Created by: Vennila Paramasivam
Author : MST Solutions
CreateDate : 06/01/2016
Description : Creating Wish Child Details from Wish Determination Case detail page.
******************************************************************************/

Public Class WishChildForm_AC
{

    Public Contact currWishChildContact{get;set;}
    Public Boolean displayTrainingAck {get;set;}
    public Case currCase{get;set;}
    public List<SelectOption> multiPickoptions {get;set;}
    String caseId {get;set;}
    public List<Contact> wishFamilyContactList {get;set;}
    public List<Contact> wishParticipantsContactList {get;set;}
    public Id wishFamilyDT;
    public List<Contact> deleteContactList = new List<Contact>();
    Public String caseTeamMemberNo1{get;set;}
    Public String caseTeamMemberNo2{get;set;}
    public Wish_Child_Form__c currWishChild{get;set;}
    public list<Wish_Child_Form__c > wishChildList {get;set;}
    public List<WrapperClass> wishFamilyWrapList{get;set;}
    public List<WrapperClass> wishParticipantList{get;set;}
    public List<DriverWrapper> driverWrapperCls{get;set;}
    public Map<String,String> emailMap{get;set;}
    public List<String> emailList{get;set;}
   
    public Map<String,String> selectedMailMap{get;set;}
    public String SignNowName{get;set;}
    public String SignNowEmail{get;set;}
       /********************** Multiselect picklist variables **********************************/
    public List<String> leftDietaryNameList{get;set;}
    public List<String> righttDietaryNameList{get;set;}
    public List<String> currrentDietaryNameList{get;set;}
    Set<String> dietaryNamesSet  = new Set<String>();
    
    public List<String> leftWCNamesList{get;set;}
    public List<String> rightWCNamesList{get;set;}
    public List<String> currentWCNamesList{get;set;}
    Set<String> WCNamesSet  = new Set<String>();
    
    public List<String> leftOxygenNamesList{get;set;}
    public List<String> rightOxygenNamesList{get;set;}
    public List<String> currentOxygenNamesList{get;set;}
    Set<String> OxygenNamesSet  = new Set<String>();
    
    public List<String> leftAllergyNamesList{get;set;}
    public List<String> rightAllergyNamesList{get;set;}
    public List<String> currentAllergyNamesList{get;set;}
    Set<String> AllergyNamesSet  = new Set<String>();
    
    public List<String> leftOtherNeedsList{get;set;}
    public List<String> righttOtherNeedsList{get;set;}
    public List<String> currentOtherNeedsList{get;set;}
    Set<String> OtherNeedsSet  = new Set<String>();
    
    public List<String> leftOwnWheelChairList{get;set;}
    public List<String> rightOwnWheelChairList{get;set;}
    public List<String> currentOwnWheelChairList{get;set;}
    Set<String> ownWheelChairNamesSet  = new Set<String>();
    
    public List<String> leftWCCollapsibleList{get;set;}
    public List<String> rightWCCollapsibleList{get;set;}
    public List<String> currentWCCollapsibleList{get;set;}
    Set<String> WCCollapsiblesSet  = new Set<String>();
    
    
    public List<String> leftWCPowerList{get;set;}
    public List<String> rightWCPowerList{get;set;}
    public List<String> currentWCPowerList{get;set;}
    Set<String> WCPowerNamesSet= new Set<String>();
    
    public List<String> leftMedicationList{get;set;}
    public List<String> rightMedicationList{get;set;}
    public List<String> currentMedicationList{get;set;}
    Set<String> MedicationNamesSet  = new Set<String>();
    
    public List<String> leftNursingCareList{get;set;}
    public List<String> rightNursingCareList{get;set;}
    public List<String> currentNursingCareList{get;set;}
    Set<String> nursingCaresSet  = new Set<String>();
    
    public String availableMonth1{get;set;}
    public String availableMonth2{get;set;}
    public String availableMonth3{get;set;}
    public String availableYear1{get;set;}
    public String availableYear2{get;set;}
    public String availableYear3{get;set;}
    public list<SelectOption> driverNameList{get;set;}
    public boolean displayPopup{get;set;} 
    public boolean isInformation{get;set;}
    public String b64SignData{get;set;}
    public List<String> listofSenderName{get;set;}
    public  Map<String,String> sendEmailMap {get;set;}
    public String documentPDF;
    public String querySignature;
    public Id wishChildId{get;set;}
    public List<String> signedList{get;set;}
    public boolean displaySignNowPopup {get;set;}
    public boolean displayError{get;set;}
    public List<String> SignNowList{get;set;}
    
    public String envelopeId;
    public Map<String,String> signersKeyPairMap;
    
    public string childForm {get;set;}
    public string familyForm {get;set;}
    public string infoForm {get;set;}
    public WishChildForm_AC(Apexpages.StandardController control)
    {
    system.debug('@@CONSTRUCTOT@@@');
        envelopeId = '';
        signersKeyPairMap = New Map<String,String>();
            
        currCase = (Case)control.getRecord();
        wishChildList = new list<Wish_Child_Form__c >();
        emailList = new List<String>();
        isInformation = false;
        driverNameList = new List<SelectOption>();
          /***********************************************************************/
        leftDietaryNameList = new List<String>();
        righttDietaryNameList= new List<String>();
        currrentDietaryNameList= new List<String>();
        leftWCNamesList= new List<String>();
        rightWCNamesList= new List<String>();
        currentWCNamesList= new List<String>();
        leftOxygenNamesList= new List<String>();
        rightOxygenNamesList= new List<String>();
        currentOxygenNamesList= new List<String>();
        leftAllergyNamesList= new List<String>();
        rightAllergyNamesList= new List<String>();
        currentAllergyNamesList = new List<String>();
        leftOtherNeedsList= new List<String>();
        righttOtherNeedsList= new List<String>();
        currentOtherNeedsList= new List<String>();
        leftOwnWheelChairList = new List<String>();
        rightOwnWheelChairList = new List<String>();
        currentOwnWheelChairList = new List<String>();
        leftWCCollapsibleList = new List<String>();
        rightWCCollapsibleList= new List<String>();
        currentWCCollapsibleList = new List<String>();
        leftWCPowerList = new List<String>();
        rightWCPowerList= new List<String>();
        currentWCPowerList = new List<String>();
        leftMedicationList = new List<String>();
        rightMedicationList= new List<String>();
        currentMedicationList= new List<String>();
        leftNursingCareList = new List<String>();
        rightNursingCareList = new List<String>();
        currentNursingCareList = new List<String>();
        wishFamilyWrapList = new List<WrapperClass>();
        wishParticipantList = new List<WrapperClass>();
        driverWrapperCls = new List<DriverWrapper>();
        emailMap = new Map<String,String>();
        currWishChild = new Wish_Child_Form__c ();
        sendEmailMap = new Map<String,String>();
        selectedMailMap = new Map<String,String>();
        SignNowList = new List<String>();
        caseId = Apexpages.currentPage().getParameters().get('Id');
        childForm = '/apex/WishChildForm_VF?id='+caseId;
        familyForm = '/apex/WishFamilyForm_VF?id='+caseId;
        infoForm = '/apex/WishInformationForm_VF?id='+caseId;
        currCase = [SELECT id,Hidden_Email_List__c,ContactId,Contact.FirstName,Contact.LastName, Contact.Middle_Name__c,
                    Contact.Diagnosis__c , Contact.Email, Contact.MobilePhone, Contact.Gender__C,
                    Contact.BirthDate, Contact.T_Shirt_Size__c
                    FROM Case WHERE Id = :caseId limit 1];
        wishChildId = currCase.ContactId;
            if(currCase.Hidden_Email_List__c != Null){
             listofSenderName = new List<String>();
             listofSenderName = currCase.Hidden_Email_List__c.split(',');
            system.debug('@@@@@@@@@@@ listofSenderName  @@@@@@@@@@@@@@'+listofSenderName );
            
            }
           system.debug('@@@@@@@@@@@ caseId  @@@@@@@@@@@@@@'+caseId );
          for(Wish_Child_Form__c wishChildForm : [SELECT Id,Name,Case__c,Hidden_Contact_Name__c,Hidden_Wish_Fmaily_Contact_Email__c,Hidden_Wish_Fmaily_Contact_Name__c FROM Wish_Child_Form__c WHERE
                                                           Case__c =: caseId]){
            system.debug('3##333333 listofSenderName '+wishChildForm );                                   
                    if(wishChildForm.Hidden_Wish_Fmaily_Contact_Name__c != Null) {                                     
                    for(String keys : wishChildForm.Hidden_Wish_Fmaily_Contact_Name__c .split(',')){
                       SignNowList.add(keys.trim());
                    } 
                    
                    }
           }
         
        
        List<CaseTeamMember> caseTeamMemberList = [SELECT id,Member.Name FROM CaseTeamMember WHERE ParentId=:currCase.id AND TeamRole.Name = 'Wish Granter' limit 2];
        if(caseTeamMemberList.size() > 0)
        {
            caseTeamMemberNo1 = caseTeamMemberList[0].Member.Name;
            if(caseTeamMemberList.size() > 1)
                caseTeamMemberNo2 = caseTeamMemberList[1].Member.Name;
            
        }
      
        if(CaseId != Null)
        {
         String wishChildQuery = 'SELECT ';
            for(Schema.FieldSetMember f : getWishChildFields()) {
                wishChildQuery+= f.getFieldPath() + ', ';
            }
         wishChildQuery = WishchildQuery.removeEnd(', ');
         wishChildQuery+= ' from Wish_Child_Form__c' + ' WHERE Case__c = :'+'caseId'+ ' lIMIT 1';
         wishChildList = Database.Query(wishChildQuery);
         }
        
       
        if(wishChildList.size() > 0)
        {
            currWishChild = wishChildList[0]; 
            
            
            
            if(currWishChild.Case_Team_Member1__c != Null)
              caseTeamMemberNo1 =  currWishChild.Case_Team_Member1__c;
            if(currWishChild.Case_Team_Member2__c != Null)
              caseTeamMemberNo2 = currWishChild.Case_Team_Member2__c;
            
            if(currWishChild.Wish_Family_Contact__c != Null)
            {
                
               for(String currString : (currWishChild.Wish_Family_Contact__c).split('<br>'))
               {
                   WrapperClass wrapCls = new WrapperClass();
                 
                  List<String> currList = currString.split('\\|');
                   System.debug('currString++++++++++++++++++++++++++++++++++++++++++++ ' + currString);
                  
                 if((currList[0]).trim() != '-')
                    wrapCls.FirstName =  (currList[0]).trim();
                 else
                    wrapCls.FirstName = '';
                    
                 if(currList.size() > 1 && currList[1].trim() != '-')  
                     wrapCls.MiddleName =  currList[1].trim();
                 else
                     wrapCls.MiddleName = '';
                  
                  if(currList.size() > 2 && currList[2].trim() != '-')    
                    wrapCls.lastName =  currList[2].trim();
                  else
                    wrapCls.lastName = '';
                   
                  if(currList.size() > 3 && currList[3].trim() != '-')
                      wrapCls.Relationship =  currList[3].trim();
                  else
                      wrapCls.Relationship = '';
                      
                  if(currList.size() > 4 && currList[4].trim() != '-')
                       wrapCls.homeTelephone =  currList[4].trim();
                   else
                       wrapCls.homeTelephone =  '';
                       
                   if(currList.size() > 5 && currList[5].trim() != '-')
                       wrapCls.workTelephone =  currList[5].trim();
                   else
                       wrapCls.workTelephone =  '';    
                       
                   if(currList.size() > 6 && currList[6].trim() != '-')
                       wrapCls.mobileTelephone = currList[6].trim();
                   else
                       wrapCls.mobileTelephone = '';
                       
                   if(currList.size() > 7 && currList[7].trim() != '-')
                   {
                        wrapCls.Email =  currList[7].trim();
                        if(wrapCls.Email != Null && wrapCls.Email!='')
                            emailMap.put((wrapCls.FirstName+' '+wrapCls.LastName),wrapCls.Email);
                   }
                   else
                   {
                        wrapCls.Email =  '';
                   }
                  
                   if(currList.size() > 8 && currList[8].trim() != '-')
                   {
                     /* List<String> dateParts = (currList[8].trim()).split('-');
                      Datetime dateWithTime = Datetime.newInstance(Integer.valueOf(dateParts[0]), Integer.valueOf(dateParts[1]), Integer.valueOf(dateParts[2]));
                      String dayOrDate = dateWithTime.format('yyyy-mm-dd'); */
                      wrapCls.dob =  Date.valueOf(currList[8].trim());
                   }
                      
                  System.debug('wrapCls+++++++++++++++++++++++++++++++++ ' + wrapCls);    
                  wishFamilyWrapList.add(wrapCls);
                  
                  System.debug('wishFamilyWrapList+++++++++++++++++++++++++++++++++ ' + wishFamilyWrapList);
               }
            
            }
        
           
            
            if(currWishChild.Driver_Details__c!= Null)
            {
                
               for(String currString : (currWishChild.Driver_Details__c).split('<br>'))
               {
                   DriverWrapper wrapCls = new DriverWrapper();
                 
                  List<String> currList = currString.split('\\|');
                   System.debug('currString++++++++++++++++++++++++++++++++++++++++++++ ' + currString);
                  
                 if((currList[0]).trim() != '-')
                    wrapCls.driverName =  (currList[0]).trim();
                 else
                    wrapCls.driverName = '';
                    
                 if(currList.size() > 1 && currList[1].trim() != '-')  
                     wrapCls.licenseNum =  currList[1].trim();
                 else
                     wrapCls.licenseNum = '';
                  
                  if(currList.size() > 2 && currList[2].trim() != '-')    
                    wrapCls.state =  currList[2].trim();
                  else
                    wrapCls.state = '';
                   
                  if(currList.size() > 3 && currList[3].trim() != '-')
                  {
                      
                      wrapCls.expirationDate = Date.valueOf(currList[3].trim());//currList[3].trim();
                  }
                  else
                      wrapCls.expirationDate = Null;
                      
                 
                   driverWrapperCls.add(wrapCls);
                  
                 
               }
            }
         
            
            if( currWishChild.Availability_Time_Period_1__c != Null)
            {

                List<String> currString =  (currWishChild.Availability_Time_Period_1__c).split('/');
                if(currString.size() > 0)
                  availableMonth1 = currString[0];
                if(CurrString.size() > 1)
                  availableYear1 = currString[1];
            }

            if( currWishChild.Availability_Time_Period_2__c != Null)
            {

                List<String> currString =  (currWishChild.Availability_Time_Period_2__c).split('/');
                if(currString.size() > 0)
                  availableMonth2 = currString[0];
                if(CurrString.size() > 1)
                  availableYear2 = currString[1];
            }
            if( currWishChild.Availability_Time_Period_3__c != Null)
            {

                List<String> currString =  (currWishChild.Availability_Time_Period_3__c).split('/');
                if(currString.size() > 0)
                  availableMonth3 = currString[0];
                if(CurrString.size() > 1)
                  availableYear3 = currString[1];
            }

                
           if(currWishChild.Participant_Name_for_Dietary_Restriction__c!= Null)
            {
               for(String s : (currWishChild.Participant_Name_for_Dietary_Restriction__c).split(';'))
               {
                   righttDietaryNameList.add(s);
                   dietaryNamesSet.add(s);
               }
            }
            
            if(currWishChild.Requested_Participant_Name_forWheelchair__c!= Null)
            {
               for(String s : (currWishChild.Requested_Participant_Name_forWheelchair__c).split(';'))
               {
                   rightWCNamesList.add(s);
                   WCNamesSet.add(s);
               }
            
            }
            
            if(currWishChild.Requested_Participant_Name_for_OtherNeed__c!= Null)
            {
               for(String s : (currWishChild.Requested_Participant_Name_for_OtherNeed__c).split(';'))
               {
                   righttOtherNeedsList.add(s);
                   OtherNeedsSet.add(s);
               }
            
            }
            if(currWishChild.Requested_Participant_Name_for_Oxygen__c!= Null)
            {
               for(String s : (currWishChild.Requested_Participant_Name_for_Oxygen__c).split(';'))
               {
                   rightOxygenNamesList.add(s);
                   OxygenNamesSet.add(s);
               }
            
            }
            if(currWishChild.Requested_Participant_Name_for_Allergies__c!= Null)
            {
               for(String s : (currWishChild.Requested_Participant_Name_for_Allergies__c).split(';'))
               {
                   rightAllergyNamesList.add(s);
                   AllergyNamesSet.add(s);
               }
            
            }
            
            if(currWishChild.Bringing_Own_Wheel_Chair__c!= Null)
            {
               for(String s : (currWishChild.Bringing_Own_Wheel_Chair__c).split(';'))
               {
                   rightOwnWheelChairList.add(s);
                   ownWheelChairNamesSet.add(s);
               }
            
            }
           
            if(currWishChild.Name_of_wheelchair_collapsible__c!= Null)
            {
               for(String s : (currWishChild.Name_of_wheelchair_collapsible__c).split(';'))
               {
                   rightWCCollapsibleList.add(s);
                   WCCollapsiblesSet.add(s);
               }
            
            }
            if(currWishChild.Pariticipant_name_havingWheelchair_Power__c!= Null)
            {
               for(String s : (currWishChild.Pariticipant_name_havingWheelchair_Power__c).split(';'))
               {
                   rightWCPowerList.add(s);
                   WCPowerNamesSet.add(s);
               }
            
            }
            if(currWishChild.Medication_require_refrigeration_name__c!= Null)
            {
               for(String s : (currWishChild.Medication_require_refrigeration_name__c).split(';'))
               {
                   rightMedicationList.add(s);
                   MedicationNamesSet.add(s);
               }
            
            }
            if(currWishChild.Names_for_receiving_nursing_care__c!= Null)
            {
               for(String s : (currWishChild.Names_for_receiving_nursing_care__c).split(';'))
               {
                   rightNursingCareList.add(s);
                   nursingCaresSet.add(s);
               }
            
            }
            
            if(currWishChild.Participant_Contacts__c != Null)
            {
            
              
               
               for(String currString : (currWishChild.Participant_Contacts__c).split('<br>'))
               {
                   WrapperClass wrapCls = new WrapperClass();
                  System.debug('currString+++++++++++++++++++++++++++++++++' + currString);
                  List<String> currList = currString.split('\\|');
                  System.debug('currList +++++++++++++++++++++++++++++++++'+currList.size()+'-SIZE-' + currList );
                  
                  if(currList.size() > 0 && currList[0].trim() == '-')
                      wrapCls.FirstName =  '';
                  else
                      wrapCls.FirstName =  currList[0].trim();
                      
                  if(currList.size() > 1 && currList[1].trim() == '-')
                      wrapCls.MiddleName = '';
                  else
                      wrapCls.MiddleName =  currList[1].trim();
                      
                  if(currList.size() > 2 && currList[2].trim() == '-')
                      wrapCls.lastName =  '';
                  else
                       wrapCls.lastName =  currList[2].trim();
                
                  if(currList.size() > 3 && currList[3].trim() == '-')
                      wrapCls.Relationship = '';
                  else
                       wrapCls.Relationship =  currList[3].trim();
                  
                  if(currList.size() > 4 && currList[4].trim() == '-')     
                    wrapCls.dob = null;
                  else
                    wrapCls.dob = Date.valueOf(currList[4].trim());
                    
                  if(currList.size() > 5 && currList[5].trim() == '-')
                     wrapCls.Email = '';
                  else
                     wrapCls.Email = currList[5].trim();
                
                  if(currList.size() > 6 && currList[6].trim() == '-')     
                    wrapCls.tshirtSize=  '';
                  else
                    wrapCls.tshirtSize=  currList[6].trim();
                 
                
                  if(currList.size() > 7 && currList[7].trim() == '-')  
                    wrapCls.medicalNeeds = false;
                  else
                    wrapCls.medicalNeeds =  Boolean.ValueOf(currList[7].trim());
                    
                if(currList.size() > 8 && currList[8].trim() == '-')
                     wrapCls.residingWishMedical = false;
                  else 
                     wrapCls.residingWishMedical =  Boolean.valueOf(currList[8].trim()); 
                     
                //  wrapCls.dob =  Date.valueOf(currString.split('|')[4]);
                  wishParticipantList.add(wrapCls);
                  String Name = wrapCls.FirstName+' ' +wrapCls.lastName;
                  driverNameList.add((new SelectOption(Name,Name)));
                    if(!(dietaryNamesSet.size() > 0 && dietaryNamesSet.contains(wrapCls.FirstName+' ' +wrapCls.lastName)))
                        leftDietaryNameList.add(wrapCls.FirstName+' ' +wrapCls.lastName);
                    if(!(WCNamesSet.size() > 0 && WCNamesSet.contains(wrapCls.FirstName+' ' +wrapCls.lastName)))
                        leftWCNamesList.add(wrapCls.FirstName+' ' +wrapCls.lastName);
                    if(!(OxygenNamesSet.size() > 0 && OxygenNamesSet.contains(wrapCls.FirstName+' ' +wrapCls.lastName)))
                        leftOxygenNamesList.add(wrapCls.FirstName+' ' +wrapCls.lastName);
                    if(!(AllergyNamesSet.size() > 0 && AllergyNamesSet.contains(wrapCls.FirstName+' ' +wrapCls.lastName)))
                        leftAllergyNamesList.add(wrapCls.FirstName+' ' +wrapCls.lastName);
                    if(!(OtherNeedsSet.size() > 0 && OtherNeedsSet.contains(wrapCls.FirstName+' ' +wrapCls.lastName)))
                        leftOtherNeedsList.add(wrapCls.FirstName+' ' +wrapCls.lastName);
                    if(!(ownWheelChairNamesSet.size() > 0 && ownWheelChairNamesSet.contains(wrapCls.FirstName+' ' +wrapCls.lastName)))
                        leftOwnWheelChairList.add(wrapCls.FirstName+' ' +wrapCls.lastName);
                    if(!(WCCollapsiblesSet.size() > 0 && WCCollapsiblesSet.contains(wrapCls.FirstName+' ' +wrapCls.lastName)))
                        leftWCCollapsibleList.add(wrapCls.FirstName+' ' +wrapCls.lastName);
                    if(!(WCPowerNamesSet.size() > 0 && WCPowerNamesSet.contains(wrapCls.FirstName+' ' +wrapCls.lastName)))
                        leftWCPowerList.add(wrapCls.FirstName+' ' +wrapCls.lastName);
                    if(!(MedicationNamesSet.size() > 0 && MedicationNamesSet.contains(wrapCls.FirstName+' ' +wrapCls.lastName)))
                        leftMedicationList.add(wrapCls.FirstName+' ' +wrapCls.lastName);
                    if(!(nursingCaresSet.size() > 0 && nursingCaresSet.contains(wrapCls.FirstName+' ' +wrapCls.lastName)))
                        leftNursingCareList.add(wrapCls.FirstName+' ' +wrapCls.lastName);
                  
                  
                  
               }
            
            }
            
           
           
        
        }
        else
        {
                 currWishChild.FirstName__c =  currCase.Contact.FirstName;
                 currWishChild.LastName__c  =  currCase.Contact.LastName;
                 currWishChild.Middle_Name__c =  CurrCase.Contact.Middle_Name__c;
                 currWishChild.BirthDate__c = currCase.Contact.BirthDate;
                 currWishChild.Diagnosis__c = currCase.Contact.Diagnosis__c;
                 currWishChild.Gender__c = currCase.Contact.Gender__c;
                 currWishChild.mobilePhone__c = currCase.Contact.MobilePhone;
                 currWishChild.Email__c = currCase.Contact.Email;
                 currWishChild.T_Shirt_Size__c = currCase.Contact.T_Shirt_Size__c;
        
        }    
       
        
        if(wishFamilyWrapList.size() == 0)
        {
           wishFamilyWrapList.add(new WrapperClass());
        }
        if(wishParticipantList.size() == 0)
           wishParticipantList.add(new WrapperClass()); 
        if(driverWrapperCls.size() == 0)
            driverWrapperCls.add(new DriverWrapper());
            
  
     }
 
    public void saveContact(){
      
        currWishChild.Case__c = caseId;
        Constant_AC  constant = new Constant_Ac();    
        Id wishDeterminationId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishDeterminationRT).getRecordTypeId();
        List<Case> currWishDeterminationCaseId = [SELECT ID FROM CASE WHERE  ParentId = :caseId AND RecordTypeId = :wishDeterminationId];
       
        if(currWishDeterminationCaseId.size() > 0)
            currWishChild.Wish_Determination_Case_Id__c = currWishDeterminationCaseId[0].id;
        
        if(wishFamilyWrapList.size() > 0 && isInformation == False)
        {
               String FamilyContactEmail = '';
               String FamilyContactName = '';
               currWishChild.Wish_Family_Contact__c = '';
           for(WrapperClass currRec : wishFamilyWrapList)
           {
              String currValue = '';
              
              
               if(currRec.FirstName != Null)
               {
                  currValue+= currRec.FirstName + ' | ';
                  if(FamilyContactEmail != Null && FamilyContactEmail != '')
                  FamilyContactEmail = FamilyContactEmail + ','+currRec.FirstName;
                  else
                  FamilyContactEmail = currRec.FirstName;
                  if(FamilyContactName != Null && FamilyContactName != '')
                  FamilyContactName = FamilyContactName + ','+currRec.FirstName;
                  else
                  FamilyContactName = currRec.FirstName;
               }
               else
                  currValue+= '-' + ' | ';
                  
               if(currRec.MiddleName!= Null)
               {
                  currValue+= currRec.MiddleName+ ' | ';
                  if(FamilyContactEmail  != Null)
                  FamilyContactEmail = FamilyContactEmail+' '+currRec.MiddleName;
                  else
                  FamilyContactEmail = currRec.MiddleName;
                  if(FamilyContactName  != Null)
                  FamilyContactName = FamilyContactName+ ' '+currRec.MiddleName;
                  else
                  FamilyContactName = currRec.MiddleName;
               }
               else
                  currValue+= '-' + ' | ';
                  
               if(currRec.lastName!= Null)
               {
                  currValue+= currRec.lastName+ ' | ';
                  if(FamilyContactEmail != Null)
                  FamilyContactEmail = FamilyContactEmail + ' ' +currRec.lastName;
                  else
                  FamilyContactEmail = currRec.lastName;
                  
                  if(FamilyContactName != Null)
                  FamilyContactName = FamilyContactName+ ' '+currRec.lastName;
                  else
                  FamilyContactName = currRec.lastName;
               }
               else
                  currValue+= '-' + ' | ';
               
               
               if(currRec.Relationship!= Null)
               {
                  currValue+= currRec.Relationship+ ' | ';
               }
               else
                  currValue+= '-' + ' | ';
                  
               if(currRec.homeTelephone!= Null)
               {
                  currValue+= currRec.homeTelephone + ' | ';
               }
               else
                  currValue+= '-' + ' | ';
               
               
               if(currRec.workTelephone!= Null)
               {
                  currValue+= currRec.workTelephone+ ' | ';
               }
               else
                  currValue+= '-' + ' | ';
               
               if(currRec.mobileTelephone!= Null)
               {
                  currValue+= currRec.mobileTelephone+ ' | ';
               }
               else
                  currValue+= '-' + ' | ';
                  
               if(currRec.Email!= Null)
               {
                  currValue+= currRec.Email+ ' | ';
                  if(FamilyContactEmail != Null)
                  FamilyContactEmail = FamilyContactEmail+ ' - '+currRec.Email;
                  else
                  FamilyContactEmail = currRec.Email;
               }
               else
                  currValue+= '-' + ' | ';
                  
               if(currRec.dob!= Null)
               {
                  String currDate = currRec.dob.year() + '-' + currRec.dob.month() + '-' + currRec.dob.day();
                  currValue+=currDate+ ' | ';
               }
               else
                  currValue+= '-' + ' | ';
               
               currValue= currValue.removeEnd(' | ');
               System.debug('currValue1 +++++++++++++++++++++++ ' + currValue);
               currWishChild.Wish_Family_Contact__c+= currValue+'<br>'; 
               
           }
           currWishChild.Hidden_Wish_Fmaily_Contact_Email__c = FamilyContactEmail;
           currWishChild.Hidden_Wish_Fmaily_Contact_Name__c = FamilyContactName;
        }
        
        if(isInformation == True)
        {
        
            currWishChild.Availability_Time_Period_1__c = availableMonth1+'/'+availableYear1;
            currWishChild.Availability_Time_Period_2__c = availableMonth2+'/'+availableYear2;
            currWishChild.Availability_Time_Period_3__c = availableMonth3+'/'+availableYear3;
            currWishChild.Participant_Name_for_Dietary_Restriction__c = selectedNames(currrentDietaryNameList);
            currWishChild.Requested_Participant_Name_forWheelchair__c = selectedNames(currentWCNamesList);
            System.debug('currWishChild.Requested_Participant_Name_forWheelchair__c ++++++++++++++ ' + selectedNames(currentWCNamesList));
            currWishChild.Requested_Participant_Name_for_OtherNeed__c = selectedNames(currentOtherNeedsList);
            currWishChild.Requested_Participant_Name_for_Oxygen__c = selectedNames(currentOxygenNamesList);
            currWishChild.Requested_Participant_Name_for_Allergies__c = selectedNames(currentAllergyNamesList);
            currWishChild.Bringing_Own_Wheel_Chair__c = selectedNames(currentOwnWheelChairList);
            currWishChild.Name_of_wheelchair_collapsible__c= selectedNames(currentWCCollapsibleList);
            currWishChild.Pariticipant_name_havingWheelchair_Power__c= selectedNames(currentWCPowerList);
            currWishChild.Medication_require_refrigeration_name__c= selectedNames(currentMedicationList);
            currWishChild.Names_for_receiving_nursing_care__c= selectedNames(currentNursingCareList);
        
        }
        
        
        if(wishParticipantList.size() > 0 && isInformation == False)
        {
          currWishChild.Participant_Contacts__c= '';
          for(Wrapperclass currVal : wishParticipantList)
          {
          
            String currValue = '';
            if(currVal.FirstName != Null)
            {
              currValue+=currVal.FirstName+' | ';
            }
            else
                  currValue+= '-' + ' | ';
            if(currVal.MiddleName!= Null)
            {
              currValue+=currVal.MiddleName+' | ';
            }
            else
                  currValue+= '-' + ' | ';
            if(currVal.lastName!= Null)
            {
              currValue+=currVal.lastName+' | ';
            }
            else
                currValue+= '-' + ' | ';
            if(currVal.relationship!= Null)
            {
              currValue+=currVal.relationship+' | ';
            }
            else
                  currValue+= '-' + ' | ';
            
            if(currVal.dob != Null)
            {
               currValue+=currVal.dob+' | ';
            }
            else
                  currValue+= '-' + ' | ';
            
          /*added Start*/  
          System.debug('&&&currValue+=currVal.Email&&&'+currVal.Email);
           if(currVal.Email!= Null)
            {
              currValue+=currVal.Email+' | ';
            }
            else
                  currValue+= '-' + ' | ';
                  
           /*added End*/ 
            System.debug('&&&currValue+=currValue&&&'+currValue);
            if(currVal.tshirtSize!= Null)
            {
              currValue+=currVal.tshirtSize+' | ';
            }
            else
                  currValue+= '-' + ' | ';      
                  
            if(currVal.medicalNeeds!= Null)
            {
              currValue+=currVal.medicalNeeds+' | ';
            }
            else
                  currValue+= '-' + ' | ';
                  
            if(currVal.residingWishMedical!= Null)
            {
              currValue+=currVal.residingWishMedical+' | ';
            }
            else
                  currValue+= '-' + ' | ';
            
               currValue= currValue.removeEnd(' | ');
               
               System.debug('currValue +++++++++++++++++++++++ ' + currValue);
               currWishChild.Participant_Contacts__c+= currValue+'<br>'; 
          }
          
          
        }
        
        System.debug('isInformation+++++++++++++++++++++++++++++++= ' + isInformation);
        
        if(driverWrapperCls.size() > 0 && isInformation == True)
        {
          currWishChild.Driver_Details__c = '';
          CurrWishChild.Driver_name__c = '';
          for(DriverWrapper currVal : driverWrapperCls)
          {
          
            String currValue = '';
            String driverName = '';
            if(currVal.driverName != Null)
            {
              currValue+=currVal.driverName+' | ';
              driverName = currVal.driverName+' | ';
            }
            else
                  currValue+= '-' + ' | ';
            if(currVal.licenseNum != Null)
            {
              currValue+=currVal.licenseNum +' | ';
            }
            else
                  currValue+= '-' + ' | ';
            if(currVal.state != Null)
            {
              currValue+=currVal.state+' | ';
            }
            else
                currValue+= '-' + ' | ';
                
            if(currVal.expirationDate!= Null)
            {
              currValue+=String.valueOf(currVal.expirationDate)+' | ';
            }
            else
                  currValue+= '-' + ' | ';
            
              currValue= currValue.removeEnd(' | ');
              currWishChild.Driver_Details__c += currValue+'<br>'; 
              currWishChild.Driver_Name__c +=driverName;
          }
          
          
        }
  
            currWishChild.Case_Team_Member1__c = caseTeamMemberNo1;
            currWishChild.Case_Team_Member2__c = caseTeamMemberNo2;
            
       System.debug('Participant_Contacts__c'+currWishChild.Participant_Contacts__c);
        try
        {
            System.debug('Participant_Contacts__c'+currWishChild.Participant_Contacts__c);
            upsert currWishChild;
        }
        Catch(DMLException e)
        {
        
                System.debug('Exception+++++++++++++++++++++++++++++++= ' + e.getmessage());
        }
            
    }
    
   public void removeFamily(){
        Integer indexVal = Integer.valueof(system.currentpagereference().getparameters().get('index'));
      
        //Remove the contact from the table    
        wishFamilyWrapList.remove(indexVal);            
    }   
    
    public void removeParticipants(){
        Integer indexVal = Integer.valueof(system.currentpagereference().getparameters().get('Participant'));
        //Remove the contact from the table    
        wishParticipantList.remove(indexVal);            
    } 
   public void removeDriver(){
        Integer indexVal = Integer.valueof(system.currentpagereference().getparameters().get('driver'));
      
        //Remove the contact from the table    
        driverWrapperCls.remove(indexVal);            
    }    
    
    
  Public PageReference SaveandExit()
    {
        
        try
        {
            saveContact();
            PageReference reference=new PageReference('/'+caseId);
            reference.setRedirect(true);     
            return reference;
        }
        
        Catch(DMLException e)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() +' >> '+ e.getLineNumber());
            ApexPages.addMessage(myMsg);
            return null;
        }
        
        return null;
        
    }
    
     Public PageReference WishInfoSave()
    {
        
        try
        {
            isInformation = True;
            saveContact();
            PageReference reference=new PageReference('/'+caseId);
            reference.setRedirect(true);     
            return reference;
        }
        
        Catch(DMLException e)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() +' >> '+ e.getLineNumber());
            ApexPages.addMessage(myMsg);
            return null;
        }
        
        return null;
        
    }

  Public PageReference WCFNext()
    { 
        try
        {
            saveContact();
            caseId =  ApexPages.currentPage().getParameters().get('Id');
            PageReference reference=new PageReference('/apex/WishFamilyForm_VF?Id='+caseId);
            reference.setRedirect(true);     
            return reference;
        }
        Catch(DMLException e)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() +' >> '+ e.getLineNumber());
            ApexPages.addMessage(myMsg);
            return null;
        }
        
        return null;
    }
    
    Public PageReference WFFNext()
    { 
        try
        {
            saveContact();
            PageReference reference=new PageReference('/apex/WishInformationForm_VF?Id='+caseId);
            reference.setRedirect(true);     
            return reference;
        }
        
        Catch(DMLException e)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() +' >> '+ e.getLineNumber());
            ApexPages.addMessage(myMsg);
            return null;
        }
        
        return null;
        
    }  
    
    public pageReference BackToWCF()
    {
            PageReference reference=new PageReference('/apex/WishChildForm_VF?Id='+caseId);
            reference.setRedirect(true);     
            return reference;
    }

    public void addFamily()
    {
    
       System.debug(' wishFamilyWrapList+++++++++++++++++++++++ ' +  wishFamilyWrapList);
        wishFamilyWrapList.add(new WrapperClass());
    }
    public void addDriver()
    {
        if(driverWrapperCls.size() < wishParticipantList.size())
            driverWrapperCls.add(new DriverWrapper());
    }
    
    public void addParticipants()
    {
       
        wishParticipantList.add(new WrapperClass());
    }
    
    public pageReference BackToWFF()
    {
            PageReference reference=new PageReference('/apex/WishFamilyForm_VF?Id='+caseId);
            reference.setRedirect(true);     
            return reference;
    } 
    
  // Back to Case Detail page.
    Public PageReference cancelfunction()
    {
        String caseId =  ApexPages.currentPage().getParameters().get('Id');
        PageReference reference=new PageReference('/'+caseId );
        reference.setRedirect(true);     
        return reference;
        
    }
    
 public class WrapperClass {
    public string firstName{get;set;}
    public string lastName{get;set;}
    public String MiddleName{get;set;}
    public Date dob{get;set;}
    public String Email{get;set;}
    public string relationship{get;set;}
    public string mobileTelephone{get;set;}
    public string workTelephone{get;set;}
    public string homeTelephone{get;set;}
    public String tshirtSize{get;set;}
    public Boolean medicalNeeds{get;set;}
    public Boolean residingWishMedical{get;set;}
 }
 
 
 
 
   
   public pageReference downLoadAsPdf()
   {
            PageReference reference=new PageReference('/apex/PDF?Id='+caseId);
            reference.setRedirect(true);     
            return reference;   
   }
 
 
 
    public List<SelectOption> getMonths()
    {
      List<SelectOption> options = new List<SelectOption>();
      options.add(new SelectOption('','Month'));
      options.add(new SelectOption('Jan','Jan'));
      options.add(new SelectOption('Feb','Feb'));
      options.add(new SelectOption('Mar','Mar'));
      options.add(new SelectOption('Apr','Apr'));
      options.add(new SelectOption('May','May'));
      options.add(new SelectOption('Jun','Jun'));
      options.add(new SelectOption('Jul','Jul'));
      options.add(new SelectOption('Aug','Aug'));
      options.add(new SelectOption('Sep','Sep'));
      options.add(new SelectOption('Oct','Oct'));
      options.add(new SelectOption('Nov','Nov'));
      options.add(new SelectOption('Dec','Dec'));
      return options;
    }
    Public String selectedNames(List<String> SelectedNameList)
    {
            Boolean start=True;
            String currString;
            if(!SelectedNameList.isEmpty()) {           
                for(String Str : SelectedNameList) {
                if(Start) {
                    currString = Str+';';
                    Start = false;
                } else {               
                    currString = currString + ';' + Str;
                }
                }
               
            }
       return currString;
    }
   
  
    
     public PageReference SignNowmultiEmail(){
         
        multiPickoptions = new List<SelectOption>();
         if(emailMap.size() > 0){

          Set<String> nameSet = new Set<String>();
         Map<String,String> processedNameMap = new Map<String,String>();
            /* for( npe4__Relationship__c nper : [SELECT ID,npe4__Contact__c,npe4__RelatedContact__c,npe4__RelatedContact__r.Name,npe4__RelatedContact__r.Email,npe4__RelatedContact__r.IsSigned__c,npe4__RelatedContact__r.IsParentGuardian__c FROM npe4__Relationship__c WHERE 
                                           npe4__Contact__c =: wishChildId  AND npe4__RelatedContact__r.IsParentGuardian__c = 'ParentGuardian']){
               if(nper.Id != NUll && nper.npe4__RelatedContact__r.IsSigned__c == false){                        
                selectedMailMap.put(nper.npe4__RelatedContact__r.Name,nper.npe4__RelatedContact__r.Email);
                }
             }*/
             
          for(Wish_Child_Form__c wishChildForm : [SELECT Id,Name,Case__c,Hidden_Contact_Name__c,Hidden_Wish_Fmaily_Contact_Email__c,Hidden_Wish_Fmaily_Contact_Name__c FROM Wish_Child_Form__c WHERE
                                                           Case__c =: caseId]){
                     if(wishChildForm.Hidden_Contact_Name__c != Null) {                                     
                        for(String keys : wishChildForm.Hidden_Contact_Name__c.split(',')){
                           nameSet.add(keys.trim());
                        } 
                    
                    }
          }
           
          for(Wish_Child_Form__c wishChildForm : [SELECT Id,Name,Case__c,Hidden_Contact_Name__c,Hidden_Wish_Fmaily_Contact_Email__c,Hidden_Wish_Fmaily_Contact_Name__c FROM Wish_Child_Form__c WHERE
                                                           Case__c =: caseId]){ 
            for(String key : wishChildForm.Hidden_Wish_Fmaily_Contact_Email__c.split(',')){
                   String keys = key.split('-')[0];
                   keys = keys.replaceAll('  ',' ');
                   String value = key.split('-')[1];
                   processedNameMap.put(keys.trim(),value.trim());
               } 
          }
          if(processedNameMap.size() > 0){
              for(String name : processedNameMap.KeySet()){
                    if(!nameSet.contains(name)){
                    selectedMailMap.put(name,processedNameMap.get(name));
                    }
              }
          }
        }
       if(selectedMailMap.size() > 0){
            
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
            String status;
            String email;
            String recipients = '';
            Integer i = 1;
            String boundary = 'AAA';
                
                Pagereference PDF = Page.SignNowPDF;
                PDF.getParameters().put('Id',caseId);
               try {
                documentPDF = EncodingUtil.base64Encode(PDF.getContentAsPDF());
        
                }catch(Exception e) {
                }
              case dbcase = [SELECT Id,Envelop_Id__c,SignerMapKeyPair__c FROM Case WHERE Id =:caseId];
              if(dbcase.Envelop_Id__c  == Null){
              
                for(String currString : selectedMailMap.keySet()){
                        String Name = currString;
                         email = sendEmailMap.get(currString);

                        
                    if(recipients != '')
                        recipients = recipients + ',';
                    recipients = recipients + '{'+
                        '      "email": "kanagaraj@mstsolutions.com",'+
                        '      "name": "'+Name+'",'+
                        '      "recipientId":"'+i+'",'+
                        '      "clientUserId":"'+i+'",'+
                        '      "tabs": {'+
                        '                "signHereTabs": [{'+
                        '                     "anchorString":"~s'+i+'",'+
                        '                    "anchorXOffset": "0",'+
                        '                   "anchorYOffset": "0",'+
                        '                    "anchorIgnoreIfNotPresent": "false",'+
                        '                    "anchorUnits": "inches"'+
                        '                }],'+
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
                    
                    if(!signersKeyPairMap.containsKey(Name))
                        signersKeyPairMap.put(Name,String.valueof(i));
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
                        system.debug(res.getBody());
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
               envelopeId = dbcase.Envelop_Id__c;
               for(String key : dbcase.SignerMapKeyPair__c.split(',')){
                   String keys = key.split('-')[0];
                   String value = key.split('-')[1];
                   signersKeyPairMap.put(keys.trim(),value.trim());
               } 
          
               system.debug('%%%%%%%% ENTER INTO ELSE signersKeyPairMap %%%%%%%%%'+signersKeyPairMap);
          }
  
        displaySignNowPopup = true;
           for(String currString : selectedMailMap.keySet()){
               multiPickoptions.add(new SelectOption(currString,currString ));
           }
       
       
       }
     
  else{
     displayError = true;
     ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'There is no user to sign click [OK].'));
     }
     return null;
     
    }
    
    
    
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
            system.debug('@@@@@@@@@@@@@@@ signersKeyPairMap @@@@@@@@@@@@'+SignNowName); 
            jsonPayload = '{'+
                '    "userName": "'+SignNowName+'",'+
                '    "email": "kanagaraj@mstsolutions.com",'+
                '    "recipientId": "'+signersKeyPairMap.get(SignNowName)+'",'+
                '    "clientUserId": "'+signersKeyPairMap.get(SignNowName)+'",'+
                '    "authenticationMethod": "None",'+
                '   "returnUrl": "'+baseUrl +'/apex/WishInformationForm_VF?Id='+CaseId+'"'+   
                '}'; 
                
            system.debug('@@@@@@@@@@@@@@@ jsonPayload @@@@@@@@@@@@'+jsonPayload ); 
            request.setBody(jsonPayload);
            response = httprequest.send(request);  
            system.debug('@@@@@@@@@@@@@@@ response @@@@@@@@@@@@'+response);
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                  //signersKeyPairMap.remove(SignNowName);
                  String sign;
                  for(String name : signersKeyPairMap.KeySet()){
                       if(sign == '' || sign == Null)
                       sign= name +' - '+ signersKeyPairMap.get(name);
                       else
                       sign = sign +','+ name + '- '+ signersKeyPairMap.get(name);
                   }
                   case newCase = new case();
                   newCase.Id = caseId;
                   newCase.SignerMapKeyPair__c = sign;
                   newCase.Envelop_Id__c = envelopeId;
                   update newCase;
                   system.debug('############ newCase ##############'+newCase);
                  for(npe4__Relationship__c nper : [SELECT ID,npe4__Contact__c,npe4__RelatedContact__c,npe4__RelatedContact__r.Name,npe4__RelatedContact__r.Email,npe4__RelatedContact__r.IsSigned__c FROM npe4__Relationship__c WHERE 
                                       npe4__Contact__c =: wishChildId  AND npe4__RelatedContact__r.Name  =:SignNowName]){
                          
                          Contact wishFamilyCon = new Contact();
                          wishFamilyCon.Id = nper.npe4__RelatedContact__c;
                          wishFamilyCon.IsSigned__c = true;
                          relationShipList.add(wishFamilyCon);
                    }
                    
                    update relationShipList;
                
                PageReference reference=new PageReference((String) results.get('url'));
                reference.setRedirect(true);
                return reference;

    }
    
    
      public pageReference Cancel(){
      displayPopup = false;
      pageReference pg = new pageReference('/apex/WishInformationForm_VF?id='+caseId);
      pg.setRedirect(true);
      return pg;
      }
      
      
      public pageReference multiEmail(){
         System.debug('EmailMap++++++++++++++++++++++++++++++++ ' + emailMap);
         if(emailMap.size() > 0){
         
         multiPickoptions = new List<SelectOption>();
         Set<String> nameSet = new Set<String>();
         Map<String,String> processedNameMap = new Map<String,String>();
          
          for(Wish_Child_Form__c wishChildForm : [SELECT Id,Name,Case__c,Hidden_Contact_Name__c,Hidden_Wish_Fmaily_Contact_Email__c,Hidden_Wish_Fmaily_Contact_Name__c FROM Wish_Child_Form__c WHERE
                                                           Case__c =: caseId]){
                    if(wishChildForm.Hidden_Contact_Name__c != Null) {                                     
                    for(String keys : wishChildForm.Hidden_Contact_Name__c.split(',')){
                       nameSet.add(keys.trim());
                    } 
                    
                    }
          }
           
          Wish_Child_Form__c wishChildForm = [SELECT Id,Name,Case__c,Hidden_Contact_Name__c,Hidden_Wish_Fmaily_Contact_Email__c,Hidden_Wish_Fmaily_Contact_Name__c FROM Wish_Child_Form__c WHERE
                                                           Case__c =: caseId];
            for(String key : wishChildForm.Hidden_Wish_Fmaily_Contact_Email__c.split(',')){
                   String keys = key.split('-')[0];
                   keys = keys.replaceAll('  ',' ');
                   String value = key.split('-')[1];
                   if(processedNameMap.containsKey(keys)){
                      keys = keys+' ';
                      processedNameMap.put(keys,value);
                   }
                   processedNameMap.put(keys,value);
               } 
           system.debug('@@@@@@@@ processedNameMap @@@@@@@@@@'+processedNameMap);
          if(processedNameMap.size() > 0){
              for(String name : processedNameMap.KeySet()){
                    if(!nameSet.contains(name)){
                     name = name.replaceAll('  ',' ');
                    if(selectedMailMap.containsKey(name)){
                        name = name+' ';
                        selectedMailMap.put(name,processedNameMap.get(name));
                     system.debug('@@@@@@@@ selectedMailMap111 @@@@@@@@@@'+selectedMailMap);
                    }
                    else
                    selectedMailMap.put(name,processedNameMap.get(name));
                    system.debug('@@@@@@@@ selectedMailMap @@@@@@@@@@'+selectedMailMap);
                    }
              }
          }
  
     
       for(String currString : selectedMailMap.keySet()){
             CurrString = CurrString.replaceAll('  ',' ');
            multiPickoptions.add(new SelectOption(currString,currString ));
            system.debug(currString +'@@@@@@@@ multiPickoptions @@@@@@@@@@'+multiPickoptions);
         }
         
           if(selectedMailMap.size() > 0){
               displayPopup = true;
     }
     
     else{
     displayError = true;
     ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Already an email sent to specified address click [OK].'));
     }
     }
     return null;
     
    }
   public pageReference sendpdftoEmail (){
     system.debug('@@@@@@@ ENTER INTO SENDPDFTOEMAIL @@@@@@@@@'+sendEmailMap);
     System.debug('EmailList++++++++++++++++++++++++++++++++++++ ' + emailList);
           displayPopup = false;
           Set<String> senderNameSet = new Set<String>();
                for(String processEmailList :emailList ){
                 if(senderNameSet.contains(processEmailList )){
                 
                     processEmailList = processEmailList+' ';
                     senderNameSet.add(processEmailList);
                 }
                     senderNameSet.add(processEmailList);
                   system.debug('@@@@@@@ ENTER INTO SENDPDFTOEMAIL @@@@@@@@@'+senderNameSet);
                }
                for(String currString : selectedMailMap.keySet()){
                
                 if(senderNameset.Contains(currString)){
                 sendEmailMap.put(currString,selectedMailMap.get(currString));
                 system.debug('@@@@@@@ sendEmailMap @@@@@@@@@'+sendEmailMap);
                 
                 }
                }
           
             if((!sendEmailMap.isEmpty()) && sendEmailMap.size() > 0 ){
                 for(String currString : sendEmailMap.KeySet()){
                   if(querySignature==null)
                      querySignature = currString;
                   else
                      querySignature = querySignature + ',' +currString;
                }
            }
            
            for(Case dbCase : [SELECT Id,Hidden_Email_List__c From Case WHERE Id =:caseId]){
                
                case newCase = new case();
                newCase.Id = dbCase.Id;
                newCase.Hidden_Email_List__c  = querySignature;
                try{
                update newCase;
                }
                    catch(Exception e){
                }
              }
        if(sendEmailMap.size() > 0)    
          callouttoDocusing(sendEmailMap,caseId,wishChildId );
          
           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm,'An email has been sent successfully'));
           PageReference acctPage = new PageReference ('/apex/WishInformationForm_VF?id='+caseId);
           acctPage.setRedirect(true);
           return acctPage;
       
    }
    
   @Future(callout=true)
    public static void callouttoDocusing(map<String,String>sendEmailMap,String caseId,Id wishChildId ){
        List<Contact> relationShipList = new List<Contact>();
            Pagereference PDF = Page.SendPDF;
            String documentPDF;
            PDF.setRedirect(false);
            PDF.getParameters().put('Id',caseId);
            If(!Test.isrunningtest())
            documentPDF = EncodingUtil.base64Encode(PDF.getContentAsPDF());
            system.debug(PDF+'base64 value '+documentPDF);
            String recipients = '';
            Integer i = 1;
            String status;
            String boundary = 'AAA';
            String ContactName = '';
            List<contact> contactList = new List<contact>(); 
            List<contact> finalList = new List<contact>();
            
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
                for(String currString : sendEmailMap.KeySet()){
                
                        
                        String Name = currString;
                         email = sendEmailMap.get(currString);
                        clientUserId = '';
                        if(ContactName == '')
                        ContactName = Name;
                        ContactName = ContactName +','+Name;
                    if(recipients != '')
                        recipients = recipients + ',';
                    recipients = recipients + '{'+
                        '      "email": "'+email+'",'+
                        '      "name": "'+Name+'",'+
                        '      "recipientId":"'+i+'",'+clientUserId+
                        '      "tabs": {'+
                        '                "signHereTabs": [{'+
                        '                     "anchorString":"~s'+i+'",'+
                        '                    "anchorXOffset": "0",'+
                        '                    "anchorYOffset": "0",'+
                        '                    "anchorIgnoreIfNotPresent": "false",'+
                        '                    "anchorUnits": "inches"'+
                        '                }],'+
                        '                    "dateSignedTabs": [{'+
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
                        system.debug('@@@@@@@@@@@@@@@ I VALUE @@@@@@@@@@@@@@@'+recipients);
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
                   
                   /*for(npe4__Relationship__c nper : [SELECT ID,npe4__Contact__c,npe4__RelatedContact__c,npe4__RelatedContact__r.Name,npe4__RelatedContact__r.Email,npe4__RelatedContact__r.IsSigned__c FROM npe4__Relationship__c WHERE 
                                       npe4__Contact__c =: wishChildId  AND npe4__RelatedContact__r.Email IN:sendEmailMap.values()]){
                          
                          Contact wishFamilyCon = new Contact();
                          wishFamilyCon.Id = nper.npe4__RelatedContact__c;
                          wishFamilyCon.IsSigned__c = true;
                          relationShipList.add(wishFamilyCon);
                    }
                    
                    update relationShipList;*/
                   
                   for(Wish_Child_Form__c wishChildForm : [SELECT Id,Name,Case__c,Hidden_Contact_Name__c,Hidden_Wish_Fmaily_Contact_Email__c,Hidden_Wish_Fmaily_Contact_Name__c FROM Wish_Child_Form__c WHERE
                                                           Case__c =: caseId]){
                       
                       Wish_Child_Form__c  updateWishChild = new Wish_Child_Form__c ();
                       updateWishChild.Id = wishChildForm.Id;
                       updateWishChild.Hidden_Contact_Name__c = ContactName;
                       update updateWishChild ;
                       System.debug('@@@@@@@@@@@ wishChildForm @@@@@@@@@@@@@@'+wishChildForm);
                   }
                    
                }catch(Exception e){
                    
                    
                    
                }
                
    }
  
    public List<SelectOption> getYear()
    {
       List<SelectOption> options = new List<SelectOption>();
       Integer Year = Date.Today().Year();
       options.add(new SelectOption('','Year'));
       for(integer i = Year;i<=Year+10; i++)
       {
            String curryear = String.valueOf(i);
            options.add(new SelectOption(curryear,curryear));
       }
    
       return options;
    }
    
     public List<Schema.FieldSetMember> getWishChildFields() {
        return SObjectType.Wish_Child_Form__c.FieldSets.Wish_Child_Form.getFields();
    }
    
    public List<SelectOption> getRelationships(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =  Wish_Child_Form__c.Emergency_Relationship__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry currVal : picklistValues)
        {      options.add(new SelectOption(currVal.getLabel(), currVal.getValue())); 
         
        }  
        return options;
    }   
    
    
    public pagereference generatePDF()
    {
            PageReference reference=new PageReference('/apex/WishFormDownloadPDF?Id='+caseId+'&force_download=true');
            reference.setRedirect(true);     
            return reference;
    }
    
      /*To display the state value of current logged in volunteer contact in community.*/
    public List<SelectOption> getStates(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =  Lead.State_Picklist__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        options.add(new SelectOption('', 'Please select state')); 
        for( Schema.PicklistEntry currVal : picklistValues)
        {      options.add(new SelectOption(currVal.getLabel(), currVal.getValue())); 
         
        }  
        return options;
    }  
    
    public void forceDownloadPDF()
    {

        //figure out if the user passed in the pdf url variable and if it is set to true.
       

            //figure out if we are forcing download or not.
            if(ApexPages.currentPage().getParameters().get('force_download') != null && ApexPages.currentPage().getParameters().get('force_download') == 'true') 
            {
                //setup a default file name
                string fileName = 'WishFamilyForm '+date.today()+'.pdf';

                //we can even get more created and allow the user to pass in a filename via the URL so it can be customized further
                if(apexPages.currentPage().getParameters().get('filename') != null)
                {
                    fileName = apexPages.currentPage().getParameters().get('filename') +'.pdf';
                }
                //here is were the magic happens. We have to set the content disposition as attachment.
                Apexpages.currentPage().getHeaders().put('content-disposition', 'attachemnt; filename='+fileName);
            }               
            
    }
    
    public pagereference submitforApproval()
    {
          List<ProcessInstance> approvalIns =  [SELECT TargetObjectId,Status,ProcessDefinitionId,ProcessDefinition.Name FROM ProcessInstance WHERE TargetObjectId =: caseId AND Status =: 'Pending' ];
          If(approvalIns.size() > 0){
             displayError();
          }
           isInformation = True;
           saveContact();
           Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
           req.setComments('Submitting request for approval.');
           req.setObjectId(caseId);
           req.setProcessDefinitionNameOrId('Wish_Child_Form_Approval_Process');
           req.setSkipEntryCriteria(true);
           Approval.ProcessResult result = Approval.process(req);
            
            PageReference reference=new PageReference('/'+caseId);
            reference.setRedirect(true);     
            return reference;
    }
    public pagereference displayError(){
             
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,' This record is already in approval process'));
             return null;
    }
    
    public class DriverWrapper
    {
       public string driverName{get;set;}
       public String licenseNum{get;set;}
       public string state{get;set;}
       public Date expirationDate{get;set;}
    }
}