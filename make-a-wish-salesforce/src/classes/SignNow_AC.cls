/******************************************************************************************************************
Created by: Kanagaraj
Author : MST Solutions
CreateDate : 06/01/2016
Description : This SignNow_AC class is used to featch all the details given in the wish child form, 
wish family form and wish information form to display when the user sign the document usign electronic signature.
******************************************************************************************************************/
public Class SignNow_AC{
    public Contact currWishChildContact{get;set;}
    public WishChildFormUtil wcfUtil{get;set;}
    public Case currCase{get;set;}
    public Wish_Child_Form__c currWishChild{get;set;}
    public Id currentPageId;
    public Boolean isChildPart = false;
    public Boolean isParticipants {get;set;}
    public string queryString {get;set;}   
    public Map<string,string> wrapperClsMap {get;set;}  
    public Map<id,Wish_Child_Form__c> clonedMap{get;set;}
    public Map<id,Wish_Child_Form__c> objMap{get;set;}
    public List<String> ethnicityList{get;set;}
    public String Name{get;set;}
    public String participantsName{get;set;} 
    
    /*********************************************************************************************************
SignNow_AC this is the construcotr method it will load when the user trying to get electronic signature.
**********************************************************************************************************/
    public SignNow_AC(Apexpages.StandardController controller){
        currentPageId =  ApexPages.currentPage().getParameters().get('id');
        isChildPart = false ;
        isParticipants  = false;    
        if(wcfUtil == null)   
            wcfUtil = new WishChildFormUtil();
        ethnicityList = new List<String>();
        Name = '';
        currentPageId =  ApexPages.currentPage().getParameters().get('id');
        
        if(currentPageId != null){
            
            this.currCase = (Case)controller.getRecord();
            currWishChild = new Wish_Child_Form__c();  
            
            this.currCase = [SELECT id,Hidden_Email_List__c,ContactId,Contact.FirstName,Contact.LastName,Contact.Name,Contact.Middle_Name__c,
                             Contact.Diagnosis__c , Contact.Email, Contact.MobilePhone, Contact.Gender__C,
                             Contact.BirthDate, Contact.T_Shirt_Size__c, Contact.MailingStreet,
                             Contact.MailingCity, Contact.MailingState, Contact.MailingPostalCode
                             FROM Case WHERE Id = :this.currCase.id limit 1];
            
            List<CaseTeamMember> caseTeamMemberList = [SELECT id,Member.Name FROM CaseTeamMember WHERE ParentId =: this.currCase.id AND TeamRole.Name = 'Wish Granter' limit 2];
            if(caseTeamMemberList.size() > 0){
                wcfUtil.caseTeamMemberNo1 = caseTeamMemberList[0].Member.Name;
                if(caseTeamMemberList.size() > 1)
                    wcfUtil.caseTeamMemberNo2 = caseTeamMemberList[1].Member.Name;
            }
            
            //build wish child list
            if(this.currCase.Id != null){
                String caseId = this.currCase.id;
                String wishChildQuery = 'SELECT ';
                for(Schema.FieldSetMember f : wcfUtil.getWishChildFields()) {
                    wishChildQuery+= f.getFieldPath() + ', ';
                }
                wishChildQuery = WishchildQuery.removeEnd(', ');
                wishChildQuery+= ' from Wish_Child_Form__c' + ' WHERE Case__c = :'+'caseId'+ ' lIMIT 1';
                wcfUtil.wishChildList = Database.Query(wishChildQuery);
            }  
            //Build wishChild for SignNow List
            for(Wish_Child_Form__c wishChildForm : [SELECT Id,Name,Case__c,Hidden_Same_as_Family__c,ParentsParticipantsName__c ,Race_Ethnicity__c,Hidden_Contact_Name__c,Hidden_Wish_Fmaily_Contact_Email__c,Hidden_Wish_Fmaily_Contact_Name__c,Participant_Name__c FROM Wish_Child_Form__c WHERE
                                                    Case__c =: currentPageId]){
                                                        
                                                        if(wishChildForm.Hidden_Wish_Fmaily_Contact_Name__c != null) {  
                                                            for(String keys : wishChildForm.Hidden_Wish_Fmaily_Contact_Name__c.split('#')){
                                                                wcfUtil.SignNowList.add(keys.trim());
                                                                // wcfUtil.listofSenderName.add(keys.trim());
                                                                if(Name == '' || Name == Null)
                                                                    Name = keys;
                                                                else
                                                                    Name +=','+' '+Keys; 
                                                            } 
                                                            
                                                        }
                                                        if(wishChildForm.ParentsParticipantsName__c != null) {  
                                                            participantsName = wishChildForm.ParentsParticipantsName__c;
                                                            if(wishChildForm.ParentsParticipantsName__c.startsWith(',')){
                                                                participantsName = wishChildForm.ParentsParticipantsName__c.removeStart(',');
                                                            }
                                                            
                                                            if(wishChildForm.ParentsParticipantsName__c.startsWith('null')){
                                                                participantsName = wishChildForm.ParentsParticipantsName__c.removeStartIgnoreCase('null');
                                                            }
                                                            
                                                        }
                                                        if(wishChildForm.Participant_Name__c != Null){
                                                            for(String keys : wishChildForm.Participant_Name__c .split('#')){
                                                                if(Name == '' || Name == Null)
                                                                    Name = keys;
                                                                else
                                                                    Name +=','+' '+Keys; 
                                                            }
                                                        }
                                                        
                                                        if(wishChildForm.Hidden_Wish_Fmaily_Contact_Email__c!= Null){
                                                            List<String> proceessList = new List<String>();
                                                            for(String key : wishChildForm.Hidden_Wish_Fmaily_Contact_Email__c.split('#')){
                                                                proceessList.clear();
                                                                if(key.contains('::')){
                                                                    for(String sla : key.split('::')) {
                                                                        proceessList.add(sla);
                                                                    }
                                                                    if(proceessList.size() == 2 && key.contains('::')) {
                                                                        String name = key.split('::')[0];
                                                                        String email = key.split('::')[1];
                                                                        wcfUtil.listofSenderName.add(name.trim());
                                                                    }
                                                                }
                                                            } 
                                                        }  
                                                        
                                                        system.debug('$$$$ SignNow List $$$$$'+wcfUtil.SignNowList);                
                                                        //setting same as family from table
                                                        if( wishChildForm.Hidden_Same_as_Family__c ){
                                                            wcfUtil.sameParentGuardian = true;
                                                        }else{
                                                            wcfUtil.sameParentGuardian = false;
                                                        }
                                                        
                                                        if(wishChildForm.Race_Ethnicity__c != Null){
                                                            for(String mwa: wishChildForm.Race_Ethnicity__c .split(';'))
                                                            {
                                                                ethnicityList.add(mwa);
                                                            }
                                                        }
                                                    }
            
            if(wcfUtil.wishChildList.size() == 0){          
                //init(); 
            }
            else{
                currWishChild = wcfUtil.wishChildList[0]; 
                if(currWishChild.Case_Team_Member1__c != null)
                    wcfUtil.caseTeamMemberNo1 =  currWishChild.Case_Team_Member1__c;
                if(currWishChild.Case_Team_Member2__c != null)
                    wcfUtil.caseTeamMemberNo2 = currWishChild.Case_Team_Member2__c;  
                
                // Wish Family Parser--------------------------------------------- 
                if(currWishChild.Wish_Family_Contact__c != null){
                    String jsonString = currWishChild.Wish_Family_Contact__c;
                    
                    jsonString = jsonString.replace('&quot;', '"');
                    jsonString = jsonString.replace('&amp;', '&');
                    jsonString = jsonString.replace('&#39;', '\'');
                    
                    List<WishChildFormUtil.WrapperClass> wrapFamilyList = (List<WishChildFormUtil.WrapperClass>) System.JSON.deserialize(jsonString, List<WishChildFormUtil.WrapperClass>.class);
                    
                    for(WishChildFormUtil.WrapperClass  currRec : wrapFamilyList){
                        WishChildFormUtil.WrapperClass wrapCls;
                        if(wrapCls == null ){ 
                            wrapCls = new WishChildFormUtil.WrapperClass();
                        }
                        System.debug(wrapCls.sameParentGuardianFlag);
                        wrapCls.FirstName = (currRec.FirstName!=Null)?currRec.FirstName:'';
                        wrapCls.MiddleName = (currRec.MiddleName!=Null)?currRec.MiddleName:'';
                        wrapCls.lastName = (currRec.lastName!=Null)?currRec.lastName:'';
                        wrapCls.Relationship = (currRec.Relationship!=Null)?currRec.Relationship:'';
                        wrapCls.homeTelephone =  (currRec.homeTelephone!=Null)?currRec.homeTelephone:'';
                        wrapCls.workTelephone =  (currRec.workTelephone!=Null)?currRec.workTelephone:'';
                        wrapCls.mobileTelephone = (currRec.mobileTelephone!=Null)?currRec.mobileTelephone:'';
                        wrapCls.Email =  (currRec.Email!=Null)?currRec.Email:'';
                        wrapCls.City = (currRec.City!=Null)?currRec.City:'';
                        wrapCls.Street= (currRec.Street!=Null)?currRec.Street:'';
                        wrapCls.State= (currRec.State!=Null)?currRec.State:'';
                        wrapCls.PostalCode= (currRec.PostalCode!=Null)?currRec.PostalCode:'';
                        wrapCls.tshirtSize= (currRec.tshirtSize!=Null)?currRec.tshirtSize:'';
                        if(currRec.sameParentGuardianFlag == true)
                            wrapCls.sameParentGuardianFlag = true;
                        else
                            wrapCls.sameParentGuardianFlag = false;
                        wrapCls.residingWishMedical = (currRec.residingWishMedical !=Null)?currRec.residingWishMedical:'';
                        wcfUtil.emailMap.put((wrapCls.FirstName+' '+wrapCls.LastName),wrapCls.Email);
                        wrapCls.dob=  (currRec.dob);
                        wrapCls.relId = currRec.relId;
                        wcfUtil.wishFamilyWrapList.add(wrapCls);
                    }
                }
                if(currWishChild.Driver_Details__c != null){
                    String jsonString = currWishChild.Driver_Details__c;
                    jsonString = jsonString.replace('&quot;', '"');
                    jsonString = jsonString.replace('&amp;', '&');
                    jsonString = jsonString.replace('&#39;', '\'');
                    List<WishChildFormUtil.DriverWrapper> wrapDriverList = (List<WishChildFormUtil.DriverWrapper>) System.JSON.deserialize(jsonString, List<WishChildFormUtil.DriverWrapper>.class);
                    System.debug('WishChildFormUtil.wrapDriverList: '+wrapDriverList);
                    for(WishChildFormUtil.DriverWrapper currRec : wrapDriverList){
                        WishChildFormUtil.DriverWrapper wrapCls = new WishChildFormUtil.DriverWrapper();
                        wrapCls.driverName  = (currRec.driverName!=Null)?currRec.driverName :'';
                        wrapCls.licenseNum  = (currRec.licenseNum !=Null)?currRec.licenseNum :'';
                        wrapCls.state  = (currRec.state !=Null)?currRec.state :'';
                        wrapCls.expirationDate  = (currRec.expirationDate!=Null)? currRec.expirationDate:Null;
                        wrapCls.type =  (currRec.type!=Null)?currRec.type:'';
                        wcfUtil.driverWrapperCls.add(wrapCls);
                    }
                }
                if(currWishChild.Availability_Time_Period_1__c != null){
                    List<String> currString =  (currWishChild.Availability_Time_Period_1__c).split('/');
                    if(currString.size() > 0)
                        wcfUtil.availableMonth1 = currString[0];
                    if(CurrString.size() > 1)
                        wcfUtil.availableYear1 = currString[1];
                }
                if( currWishChild.Availability_Time_Period_2__c != null){
                    List<String> currString =  (currWishChild.Availability_Time_Period_2__c).split('/');
                    if(currString.size() > 0)
                        wcfUtil.availableMonth2 = currString[0];
                    if(CurrString.size() > 1)
                        wcfUtil.availableYear2 = currString[1];
                }
                if( currWishChild.Availability_Time_Period_3__c != null){
                    List<String> currString =  (currWishChild.Availability_Time_Period_3__c).split('/');
                    if(currString.size() > 0)
                        wcfUtil.availableMonth3 = currString[0];
                    if(CurrString.size() > 1)
                        wcfUtil.availableYear3 = currString[1];
                }  
                if(currWishChild.Participant_Name_for_Dietary_Restriction__c!= null){
                    
                    for(String s : (currWishChild.Participant_Name_for_Dietary_Restriction__c).split(';')){
                        s.removeEnd(';');
                        wcfUtil.righttDietaryNameList.add(s);
                        wcfUtil.currrentDietaryNameList.add(s);
                        wcfUtil.dietaryNamesSet.add(s);
                    }
                }
                if(currWishChild.Requested_Participant_Name_forWheelchair__c!= null){
                    for(String s : (currWishChild.Requested_Participant_Name_forWheelchair__c).split(';')){
                        s.removeEnd(';');
                        wcfUtil.rightWCNamesList.add(s);
                        wcfUtil.currentWCNamesList.add(s);
                        wcfUtil.WCNamesSet.add(s);
                    }                  
                }
                if(currWishChild.Requested_Participant_Name_for_OtherNeed__c!= null){
                    for(String s : (currWishChild.Requested_Participant_Name_for_OtherNeed__c).split(';')){
                        s.removeEnd(';');
                        wcfUtil.righttOtherNeedsList.add(s);
                        wcfUtil.currentOtherNeedsList.add(s);
                        wcfUtil.OtherNeedsSet.add(s);
                    }
                }
                if(currWishChild.Requested_Participant_Name_for_Oxygen__c!= null){
                    for(String s : (currWishChild.Requested_Participant_Name_for_Oxygen__c).split(';')){
                        s.removeEnd(';');
                        wcfUtil.rightOxygenNamesList.add(s);
                        wcfUtil.currentOxygenNamesList.add(s);
                        wcfUtil.OxygenNamesSet.add(s);
                    }                  
                }
                if(currWishChild.Requested_Participant_Name_for_Allergies__c!= Null){
                    for(String s : (currWishChild.Requested_Participant_Name_for_Allergies__c).split(';')){
                        s.removeEnd(';');
                        wcfUtil.rightAllergyNamesList.add(s);
                        wcfUtil.currentAllergyNamesList.add(s);
                        wcfUtil.AllergyNamesSet.add(s);
                    }                  
                }                  
                if(currWishChild.Bringing_Own_Wheel_Chair__c!= Null){
                    for(String s : (currWishChild.Bringing_Own_Wheel_Chair__c).split(';')){
                        s.removeEnd(';');
                        wcfUtil.rightOwnWheelChairList.add(s);
                        wcfUtil.currentOwnWheelChairList.add(s);
                        wcfUtil.ownWheelChairNamesSet.add(s);
                    }                  
                }                 
                if(currWishChild.Name_of_wheelchair_collapsible__c!= Null){
                    for(String s : (currWishChild.Name_of_wheelchair_collapsible__c).split(';')){
                        s.removeEnd(';');
                        wcfUtil.rightWCCollapsibleList.add(s);
                        wcfUtil.currentWCCollapsibleList.add(s);
                        wcfUtil.WCCollapsiblesSet.add(s);
                    }                  
                }
                if(currWishChild.Pariticipant_name_havingWheelchair_Power__c!= Null){
                    for(String s : (currWishChild.Pariticipant_name_havingWheelchair_Power__c).split(';')){
                        s.removeEnd(';');
                        wcfUtil.rightWCPowerList.add(s);
                        wcfUtil.currentWCPowerList.add(s);
                        wcfUtil.WCPowerNamesSet.add(s);
                    }                  
                }
                if(currWishChild.Medication_require_refrigeration_name__c!= Null) {
                    for(String s : (currWishChild.Medication_require_refrigeration_name__c).split(';')){
                        s.removeEnd(';');
                        wcfUtil.rightMedicationList.add(s);
                        wcfUtil.currentMedicationList.add(s);
                        wcfUtil.MedicationNamesSet.add(s);
                    }                  
                }
                if(currWishChild.Names_for_receiving_nursing_care__c!= Null){
                    for(String s : (currWishChild.Names_for_receiving_nursing_care__c).split(';')){
                        s.removeEnd(';');
                        wcfUtil.rightNursingCareList.add(s);
                        wcfUtil.currentNursingCareList.add(s);
                        wcfUtil.nursingCaresSet.add(s);
                    }                  
                }
                
                if(currWishChild.Participant_Contacts__c != null){  
                    String jsonString = currWishChild.Participant_Contacts__c;
                    jsonString = jsonString.replace('&quot;', '"');
                    jsonString = jsonString.replace('&amp;', '&');
                    jsonString = jsonString.replace('&#39;', '\'');
                    List<WishChildFormUtil.WrapperClass> wrapParticipantsList = (List<WishChildFormUtil.WrapperClass>) System.JSON.deserialize(jsonString, List<WishChildFormUtil.WrapperClass>.class);
                    System.debug('******jsonString:***** '+jsonString);             
                    List<Case> childAsPartList = [SELECT Contact.FirstName,Contact.LastName,Contact.Middle_Name__c,Contact.Email, Contact.MobilePhone,Contact.BirthDate, Contact.T_Shirt_Size__c FROM Case WHERE Id =: this.currCase.id limit 1 ] ;        
                    
                    Integer count = 0;
                    for(WishChildFormUtil.WrapperClass  currRec : wrapParticipantsList){
                        WishChildFormUtil.WrapperClass wrapCls;
                        if(wrapCls == null ){ 
                            wrapCls = new WishChildFormUtil.WrapperClass();
                        }
                        System.debug(wrapCls.sameParentGuardianFlag);
                        wrapCls.FirstName = (currRec.FirstName!=Null)?currRec.FirstName:'';
                        wrapCls.MiddleName = (currRec.MiddleName!=Null)?currRec.MiddleName:'';
                        wrapCls.lastName = (currRec.lastName!=Null)?currRec.lastName:'';
                        wrapCls.Relationship = (currRec.Relationship!=Null)?currRec.Relationship:'';
                        wrapCls.homeTelephone =  (currRec.homeTelephone!=Null)?currRec.homeTelephone:'';
                        wrapCls.workTelephone =  (currRec.workTelephone!=Null)?currRec.workTelephone:'';
                        wrapCls.mobileTelephone = (currRec.mobileTelephone!=Null)?currRec.mobileTelephone:'';
                        wrapCls.Email =  (currRec.Email!=Null)?currRec.Email:'';
                        wrapCls.City = (currRec.City!=Null)?currRec.City:'';
                        wrapCls.Street= (currRec.Street!=Null)?currRec.Street:'';
                        wrapCls.State= (currRec.State!=Null)?currRec.State:'';
                        wrapCls.PostalCode= (currRec.PostalCode!=Null)?currRec.PostalCode:'';
                        wrapCls.residingWishMedical= (currRec.residingWishMedical!=Null)?currRec.residingWishMedical:'';
                        wrapCls.medicalNeeds= (currRec.medicalNeeds!=Null)?currRec.medicalNeeds:'';
                        wrapCls.tshirtSize= (currRec.tshirtSize!=Null)?currRec.tshirtSize:'';
                        wrapCls.sameParentGuardianFlag = false;                         
                        wcfUtil.emailMap.put((wrapCls.FirstName+' '+wrapCls.LastName),wrapCls.Email);
                        wrapCls.dob=  (currRec.dob);
                        wcfUtil.wishParticipantList.add(wrapCls);
                    }
                }                 
            }
            if(wcfUtil.wishFamilyWrapList.size() == 0)
                wcfUtil.wishFamilyWrapList.add(new WishChildFormUtil.WrapperClass());
            if(wcfUtil.wishParticipantList.size() == 0)           
                wcfUtil.wishParticipantList.add(new WishChildFormUtil.WrapperClass()); 
            if(wcfUtil.driverWrapperCls.size() == 0)
                wcfUtil.driverWrapperCls.add(new WishChildFormUtil.DriverWrapper());  
        }      
    }
}