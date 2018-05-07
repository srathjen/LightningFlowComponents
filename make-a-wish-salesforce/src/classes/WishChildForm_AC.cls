/************************************************************************************************************************************
Created by: Vennila Paramasivam & Kanagaraj
Author : MST Solutions
CreateDate : 06/01/2016
Description : This WishChildForm_AC class is used to update wish child contact and wish family contact details.
And aslo we can able to add additional parent legaual guardian and participant in wish family form and 
we can add dervier details,medical information and travel information in wish information form.
And we can able to electronic sign this form with details volunteer has filled using sing now and
send for signature options.And user can able to download this form. Once all the information hase been 
entered the volunteer is submit this record for approval. Once the chapter staff approved this record
the corresponding details are updated in wish child and wish family and wish record. It also create relationship
record.
**************************************************************************************************************************************/

public Class WishChildForm_AC{
    Constant_AC  constant = new Constant_AC();
    Public Id familyContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.wishFamilyRT).getRecordTypeId();
    Public Id wichChildRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.contactWishChildRT).getRecordTypeId();
    public WishChildFormUtil wcfUtil{get;set;}
    public Case currCase{get;set;}
    public Wish_Child_Form__c currWishChild{get;set;}
    public Id currentPageId;
    public Boolean isChildPart = false;
    public Boolean isParticipants {get;set;}
    public List<String> ethnicityList{get;set;}
    public List<string> tempName = new List<string>();
    public List<String>currentOwnWheelChairList =new List<String>();
    Public List<String>currentWCCollapsibleList = new List<String>();
    Public List<String>currentWCPowerList = new List<String>();
    Public List<String>currentOxygenNamesList = new List<String>();
    Public List<String>currrentDietaryNameList = new List<String>();
    Public List<String>currentNursingCareList = new List<String>();
    Public List<String>currentMedicationList = new List<String>();
    Public List<String>currentAllergyNamesList = new List<String>();
    Public List<String>currentOtherNeedsList = new List<String>();
    public String tshirt{get;set;}
    public boolean isWishchildFormRequired{get;set;}
    public boolean isWishfamilyFormRequired{get;set;}
    public Integer j = 0;
    public Integer k = 0;
    Public String driverInfo = '';
    public Set<String> relationShipSet = new Set<String>();
    public Map<String,String> processedNameMap;
    public Map<String,String> nameMap;
    public Set<String> signerSet;
    public boolean displaypopwindow{get;set;}
    public string attachmentId {get; set;}
    public Attachment newAttachment {get; set;}
    public Id recId;    
    public boolean isSaved{get;set;}
    public boolean isDeleted{get;set;}
    public List<cg__CaseFile__c> attachmentList{get;set;}
    public boolean sucess{get;set;}
    public boolean showException;
    /********************************************************************************************
This is the constructor method will call when the wishchild form is open and it display
all the wish child details and wish family details in wish child form and wish family form. 
**********************************************************************************************/
    public WishChildForm_AC(Apexpages.StandardController controller){
        currentPageId =  ApexPages.currentPage().getParameters().get('id');
        isChildPart = false ;
        isParticipants  = false;         
        if(wcfUtil == null)   
            wcfUtil = new WishChildFormUtil();
        ethnicityList = new List<String>();
        processedNameMap = new Map<String,String>();
        nameMap = new Map<String,String>();
        signerSet = new Set<String>();
        displaypopwindow = false;
        newAttachment = new Attachment();
        currentPageId =  ApexPages.currentPage().getParameters().get('id');
        if(ApexPages.currentPage().getParameters().get('saved') != null && ApexPages.currentPage().getParameters().get('saved') == 'true'){
            isSaved = true;
        } 
        if(currentPageId != null){
            List<ProcessInstanceWorkitem> approvalIns = [SELECT Id,ActorId,OriginalActorId,ProcessInstanceId,ProcessInstance.TargetObjectId,ProcessInstance.Status,ProcessInstance.ProcessDefinition.Name FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId =: currentPageId AND ProcessInstance.Status =: 'Pending' AND ProcessInstance.ProcessDefinition.Name =: 'Wish Paperwork Packet'
                                                         AND (ActorId !=: UserInfo.getUserId() AND OriginalActorId !=: UserInfo.getUserId())];
            
            this.currCase = (Case)controller.getRecord();
            recId = this.currCase.Id;
            attachmentList =new List<cg__CaseFile__c>();
            // attachmentList = [select Id, File_Path__c,cg__Description__c, cg__Case__c, cg__File_Name__c from cg__CaseFile__c where cg__Case__c =: recId AND cg__Parent_Folder_Id__c != Null];
            currWishChild = new Wish_Child_Form__c();  
            this.currCase = [SELECT id,Hidden_Email_List__c,ContactId,Contact.FirstName,Contact.LastName, Contact.Middle_Name__c,
                             Contact.Diagnosis__c , Contact.Email, Contact.MobilePhone, Contact.Gender__C, Contact.Self_describe_comment_box__c,
                             Contact.BirthDate, Contact.T_Shirt_Size__c, Contact.MailingStreet,
                             Contact.MailingCity, Contact.MailingState, Contact.MailingPostalCode,ChapterName__r.Name,Contact.Name
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
            for(Wish_Child_Form__c wishChildForm : [SELECT Id,Name,Case__c,Hidden_Same_as_Family__c,T_Shirt_Size__c,Race_Ethnicity__c,Signers__c,Hidden_Contact_Name__c,Hidden_Wish_Fmaily_Contact_Email__c,Hidden_Wish_Fmaily_Contact_Name__c,WPP_WLSignNow__c,WPP_WLSendForSign__c FROM Wish_Child_Form__c WHERE
                                                    Case__c =: currentPageId]){
                                                        
                                                        if(wishChildForm.Hidden_Contact_Name__c != Null) {                                     
                                                            for(String keys : wishChildForm.Hidden_Contact_Name__c.split('#')){
                                                                nameMap.put(keys.trim(),'abc');
                                                            } 
                                                        }
                                                        
                                                        if(wishChildForm.Hidden_Wish_Fmaily_Contact_Name__c != null) {  
                                                            for(String keys : wishChildForm.Hidden_Wish_Fmaily_Contact_Name__c.split('#')){
                                                                wcfUtil.SignNowList.add(keys.trim());                     
                                                                wcfUtil.listofSenderName.add(keys.trim());
                                                                signerSet.add(keys.trim()); 
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
                                                                        processedNameMap.put(name,email);
                                                                    }
                                                                }
                                                            } 
                                                        }  
                                                        
                                                        if(wishChildForm.Race_Ethnicity__c != Null){
                                                            for(String mwa: wishChildForm.Race_Ethnicity__c .split(';'))
                                                            {
                                                                ethnicityList.add(mwa);
                                                            }
                                                        }
                                                        tshirt = wishChildForm.T_Shirt_Size__c;
                                                    }
            
            if(wcfUtil.wishChildList.size() == 0){ 
                init(); 
            }
            else{
                currWishChild = wcfUtil.wishChildList[0]; 
                if(currWishChild.Id != Null && currWishChild.Hidden_Same_as_Family__c == true){
                    wishChildMap(currWishChild.FirstName__c,currWishChild.LastName__c);
                }
                if(currWishChild.Case_Team_Member1__c != null)
                    wcfUtil.caseTeamMemberNo1 =  currWishChild.Case_Team_Member1__c;
                if(currWishChild.Case_Team_Member2__c != null)
                    wcfUtil.caseTeamMemberNo2 = currWishChild.Case_Team_Member2__c;  
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
                        wrapCls.FirstName = (currRec.FirstName!=Null)?currRec.FirstName.trim():'';
                        wrapCls.MiddleName = (currRec.MiddleName!=Null)?currRec.MiddleName.trim():'';
                        wrapCls.lastName = (currRec.lastName!=Null)?currRec.lastName.trim():'';
                        wrapCls.Relationship = (currRec.Relationship!=Null)?currRec.Relationship:'';
                        wrapCls.homeTelephone =  (currRec.homeTelephone!=Null)?currRec.homeTelephone:'';
                        wrapCls.workTelephone =  (currRec.workTelephone!=Null)?currRec.workTelephone:'';
                        wrapCls.mobileTelephone = (currRec.mobileTelephone!=Null)?currRec.mobileTelephone:'';
                        wrapCls.Email =  (currRec.Email!=Null)?currRec.Email:'';
                        wrapCls.City = (currRec.City!=Null)?currRec.City:'';
                        wrapCls.Street= (currRec.Street!=Null)?currRec.Street:'';
                        wrapCls.State= (currRec.State!=Null)?currRec.State:'';
                        wrapCls.PostalCode= (currRec.PostalCode!=Null)?currRec.PostalCode:'';
                        wrapCls.tshirtSize = (currRec.tshirtSize !=Null)?currRec.tshirtSize:'';
                        wrapCls.sameParentGuardianFlag = (currRec.sameParentGuardianFlag == true)? true : false;                        
                        wcfUtil.emailMap.put((wrapCls.FirstName+' '+wrapCls.LastName),wrapCls.Email);
                        wrapCls.dob=  (currRec.dob);
                        wrapCls.relId = currRec.relId;
                        wrapCls.residingWishMedical= currRec.residingWishMedical;
                        wcfUtil.wishFamilyWrapList.add(wrapCls);
                    }
                    
                    ParentLegalMapping(wrapFamilyList,false); 
                }
                if(currWishChild.Driver_Details__c != null){
                    Integer i = 0;
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
                        wrapCls.expirationDate  = (currRec.expirationDate!=Null)?currRec.expirationDate:Null;
                        wrapCls.type =  (currRec.type!=Null)?currRec.type:'';
                        if(driverInfo == '' && i == 0){
                            if(string.valueof(wrapCls.expirationDate) != null ){
                                String S = String.valueof(wrapCls.expirationDate);
                                String s1 = S.remove(' 00:00:00');
                                driverInfo = wrapCls.driverName+' '+'|'+' '+wrapCls.licenseNum+' '+'|'+' '+wrapCls.state +' '+'|'+' '+ s1 +' '+'|'+' '+wrapCls.type;      
                            }
                        } 
                        if(driverInfo != '' && i > 0){
                            if(string.valueof(wrapCls.expirationDate) != null){
                                String S = String.valueof(wrapCls.expirationDate);
                                String s1 = S.remove(' 00:00:00');
                                driverInfo +=  '<br/>'+wrapCls.driverName+' '+'|'+' '+wrapCls.licenseNum+' '+'|'+' '+wrapCls.state +' '+'|'+' '+s1+' '+'|'+' '+wrapCls.type;      
                            }
                        }
                        i++;
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
                    String name = '';
                    for(String s : (currWishChild.Participant_Name_for_Dietary_Restriction__c).split(';')){
                        if(name == '')
                            name = s;
                        else
                            name+=','+' '+s;
                    }
                    name =  name.removeEnd(';');
                    wcfUtil.righttDietaryNameList.add(name);
                    wcfUtil.currrentDietaryName = name;
                    wcfUtil.dietaryNamesSet.add(name);
                }
                if(currWishChild.Requested_Participant_Name_for_OtherNeed__c!= null){
                    String name = '';
                    for(String s : (currWishChild.Requested_Participant_Name_for_OtherNeed__c).split(';')){
                        if(name == '')
                            name = s;
                        else
                            name+=','+' '+s;
                    }
                    name =  name.removeEnd(';');
                    wcfUtil.righttOtherNeedsList.add(name);
                    wcfUtil.currentOtherNeeds = name;
                    wcfUtil.OtherNeedsSet.add(name);
                }
                if(currWishChild.Requested_Participant_Name_for_Oxygen__c!= null){
                    String name = '';
                    for(String s : (currWishChild.Requested_Participant_Name_for_Oxygen__c).split(';')){
                        if(name == '')
                            name = s;
                        else
                            name+=','+' '+s;
                    }      
                    name =  name.removeEnd(';');
                    wcfUtil.rightOxygenNamesList.add(name);
                    wcfUtil.currentOxygenNames = name;
                    wcfUtil.OxygenNamesSet.add(name) ;           
                }
                if(currWishChild.Requested_Participant_Name_for_Allergies__c!= Null){
                    String name = '';
                    for(String s : (currWishChild.Requested_Participant_Name_for_Allergies__c).split(';')){
                        if(name == '')
                            name = s;
                        else
                            name+=','+' '+s;
                    }     
                    name =  name.removeEnd(';');
                    wcfUtil.rightAllergyNamesList.add(name);
                    wcfUtil.currentAllergyNames = name;
                    wcfUtil.AllergyNamesSet.add(name);             
                }                  
                if(currWishChild.Bringing_Own_Wheel_Chair__c!= Null){
                    string name = '';
                    for(String s : (currWishChild.Bringing_Own_Wheel_Chair__c).split(';')){
                        if(name == '')
                            name = s;
                        else
                            name+=','+' '+s;
                    }         
                    name =  name.removeEnd(';');
                    wcfUtil.rightOwnWheelChairList.add(name);
                    wcfUtil.currentOwnWheelChair = name;
                    wcfUtil.ownWheelChairNamesSet.add(name);         
                }                 
                if(currWishChild.Name_of_wheelchair_collapsible__c!= Null){
                    string name = '';
                    for(String s : (currWishChild.Name_of_wheelchair_collapsible__c).split(';')){
                        if(name == '')
                            name = s;
                        else
                            name+=','+' '+s;
                    }        
                    name =  name.removeEnd(';');
                    wcfUtil.rightWCCollapsibleList.add(name);
                    wcfUtil.currentWCCollapsible = name;
                    wcfUtil.WCCollapsiblesSet.add(name);          
                }
                if(currWishChild.Pariticipant_name_havingWheelchair_Power__c!= Null){
                    string name = '';
                    for(String s : (currWishChild.Pariticipant_name_havingWheelchair_Power__c).split(';')){
                        if(name == '')
                            name = s;
                        else
                            name+=','+' '+s;
                    }    
                    name =  name.removeEnd(';');
                    wcfUtil.rightWCPowerList.add(name);
                    wcfUtil.currentWCPower = name;
                    wcfUtil.WCPowerNamesSet.add(name);              
                }
                if(currWishChild.Medication_require_refrigeration_name__c!= Null) {
                    string name = '';
                    for(String s : (currWishChild.Medication_require_refrigeration_name__c).split(';')){
                        if(name == '')
                            name = s;
                        else
                            name+=','+' '+s;
                    }          
                    name =  name.removeEnd(';');
                    wcfUtil.rightMedicationList.add(name);
                    wcfUtil.currentMedication = name ;
                    wcfUtil.MedicationNamesSet.add(name);        
                }
                if(currWishChild.Names_for_receiving_nursing_care__c!= Null){
                    string name = '';
                    for(String s : (currWishChild.Names_for_receiving_nursing_care__c).split(';')){
                        if(name == '')
                            name = s;
                        else
                            name+=','+' '+s;
                    }           
                    name =  name.removeEnd(';');
                    wcfUtil.rightNursingCareList.add(name);
                    wcfUtil.currentNursingCare = name;
                    wcfUtil.nursingCaresSet.add(name);       
                }
                // Wish Participants Parser---------------------------------------------  
                if(currWishChild.Participant_Contacts__c != null){  
                    String jsonString = currWishChild.Participant_Contacts__c;
                    jsonString = jsonString.replace('&quot;', '"');
                    jsonString = jsonString.replace('&amp;', '&');
                    jsonString = jsonString.replace('&#39;', '\'');
                    List<WishChildFormUtil.WrapperClass> wrapParticipantsList = (List<WishChildFormUtil.WrapperClass>) System.JSON.deserialize(jsonString, List<WishChildFormUtil.WrapperClass>.class);
                    ParticipantsMapping(wrapParticipantsList,false);  
                }                 
            }
            if(wcfUtil.wishFamilyWrapList.size() == 0)
                wcfUtil.wishFamilyWrapList.add(new WishChildFormUtil.WrapperClass());
            
            if(wcfUtil.driverWrapperCls.size() == 0){
                wcfUtil.driverWrapperCls.add(new WishChildFormUtil.DriverWrapper());  
            }
            
            If(approvalIns.size() > 0){           
                wcfUtil.approvalError = true;
            }
            if(currWishChild.FirstName__c == Null || currWishChild.LastName__c == Null || currWishChild.BirthDate__c == Null || currWishChild.Gender__c == Null || 
               currWishChild.Street__c ==  Null || currWishChild.City__c == Null || currWishChild.State__c == Null ||
               currWishChild.Zip_Code__c ==  Null){
                   isWishchildFormRequired = true;
               }
            if(currWishChild.Gender__c == 'Self-describe' && currWishChild.Self_describe_comment_box__c == Null) {
                isWishchildFormRequired = true;
            }
            if(currWishChild.Emergency_Relationship__c == Null || currWishChild.Emergency_First_Name__c == Null || currWishChild.Emergency_Last_Name__c == Null || currWishChild.Emergency_Mobilephone__c == Null || currWishChild.Wish_Family_Contact__c == Null  
               || currWishChild.Already_wish_granted_by_MAW_Other_Org__c == Null || currWishChild.IsWishFamily__c == true){
                   isWishfamilyFormRequired = true;
               }
            if(currWishChild.Hidden_Contact_Name__c != Null && currWishChild.Hidden_Wish_Fmaily_Contact_Name__c != Null){
                Set<String> nameset = new Set<String>();
                Set<String> namesetOne = new Set<String>();
                for(String processName : currWishChild.Hidden_Contact_Name__c .split('#')){
                    nameset.add(processName);
                }
                for(String processName : currWishChild.Hidden_Wish_Fmaily_Contact_Name__c.split('#')){
                    namesetOne.add(processName);
                }
                if(nameset.size() == namesetOne.size())
                    wcfUtil.displayError = true;
            }
        } 
        
        
    }
    
    /********************************************************************************************
This is the init() method is used to query all the related contact details and this details are
displayed in wishfamily form.
**********************************************************************************************/
    public void init(){
        String Logvalue;
        
        Logvalue = String.valueOf(currCase);
        currWishChild.FirstName__c =  currCase.Contact.FirstName;
        currWishChild.LastName__c  =  currCase.Contact.LastName;
        currWishChild.Middle_Name__c =  currCase.Contact.Middle_Name__c;
        currWishChild.BirthDate__c = currCase.Contact.BirthDate;
        currWishChild.Diagnosis__c = currCase.Contact.Diagnosis__c;
        currWishChild.Gender__c = currCase.Contact.Gender__c;
        currWishChild.Self_describe_comment_box__c = currCase.Contact.Self_describe_comment_box__c;
        currWishChild.mobilePhone__c = currCase.Contact.MobilePhone;
        currWishChild.Email__c = currCase.Contact.Email;
        if(currWishChild.Email__c == Null)
            currWishChild.Email__c = currWishChild.Email__c;
        currWishChild.T_Shirt_Size__c = currWishChild.T_Shirt_Size__c;
        currWishChild.Street__c = currCase.Contact.MailingStreet;
        currWishChild.State__c = currCase.Contact.MailingState;
        currWishChild.city__c = currCase.Contact.MailingCity;
        currWishChild.Zip_code__c = currCase.Contact.MailingPostalCode;
        currWishChild.Bringing_Own_Wheel_Chair__c = currWishChild.Bringing_Own_Wheel_Chair__c;            
        for(npe4__Relationship__c currRel : [SELECT id,npe4__RelatedContact__c,npe4__RelatedContact__r.FirstName, npe4__RelatedContact__r.LastName,
                                             npe4__RelatedContact__r.Email,Hidden_isparentFirst__c,npe4__RelatedContact__r.Phone, npe4__RelatedContact__r.Middle_Name__c,npe4__RelatedContact__r.Mailingcity,npe4__RelatedContact__r.Mailingstreet,
                                             npe4__RelatedContact__r.MailingState,npe4__RelatedContact__r.MailingPostalCode,npe4__Type__c,npe4__RelatedContact__r.HomePhone,npe4__RelatedContact__r.npe01__WorkPhone__c,npe4__RelatedContact__r.MobilePhone FROM npe4__Relationship__c WHERE npe4__Contact__c  = :currCase.ContactId AND 
                                             npe4__RelatedContact__r.RecordTypeId =: familyContactRecordTypeId AND npe4__Type__c != 'Sibling' AND Parent_Legal_Guardian__c = true])
        {
            Logvalue = String.valueOf(currRel);
            WishChildFormUtil.WrapperClass wrapCls = new WishChildFormUtil.WrapperClass();
            wrapCls.FirstName = currRel.npe4__RelatedContact__r.FirstName;
            wrapCls.MiddleName = currRel.npe4__RelatedContact__r.Middle_Name__c;
            wrapCls.lastName = currRel.npe4__RelatedContact__r.LastName;
            wrapCls.mobileTelephone = currRel.npe4__RelatedContact__r.MobilePhone;
            wrapCls.Email =  currRel.npe4__RelatedContact__r.Email;
            wrapCls.City = currRel.npe4__RelatedContact__r.Mailingcity; 
            wrapCls.Street = currRel.npe4__RelatedContact__r.MailingStreet;
            wrapCls.State = currRel.npe4__RelatedContact__r.MailingState;
            wrapCls.PostalCode = currRel.npe4__RelatedContact__r.MailingPostalCode;
            wrapCls.Relationship = currRel.npe4__Type__c;
            wrapCls.homeTelephone =  currRel.npe4__RelatedContact__r.HomePhone;
            wrapCls.workTelephone =  currRel.npe4__RelatedContact__r.npe01__WorkPhone__c;
            wrapCls.sameParentGuardianFlag = false;
            wrapCls.residingWishMedical = null;
            wrapCls.relId = currRel.npe4__RelatedContact__c;
            wcfUtil.wishFamilyWrapList.add(wrapCls); 
        }   
        if(wcfUtil.wishFamilyWrapList.size() > 0){
            String JSONString = JSON.serialize(wcfUtil.wishFamilyWrapList);
            currWishChild.Wish_Family_Contact__c = JSONString;  
        }              
        List<WishChildFormUtil.WrapperClass> wrapParticipantsList = new  List<WishChildFormUtil.WrapperClass>();
        
        if(wrapParticipantsList.size() > 0)   
        {
            ParticipantsMapping(wrapParticipantsList,false);
            isParticipants = true;
        }
    }
    
    /********************************************************************************************
This is the SaveContact() method is used to all the details entered in wish child, wish family and 
Wish information form.
**********************************************************************************************/
    public void SaveContact(){
        currWishChild.Case__c = currCase.id;
        Constant_AC  constant = new Constant_Ac(); 
        Set<String> nameSet = new Set<String>();   
        Set<String> nameWithEmailSet = new Set<String>();
        String FamilyContactEmail = '';
        String FamilyContactName = '';
        String ParticipantConEmail = '';
        String ParticipantConName = '';
        String ParentGurdianabove18 = '';
        String ParentGurdianabove18Email = '';
        String RelatedContact = '';
        String ParentAndParticipantsNames = '';
        boolean isFamily = false;
        boolean isEmail = false;
        Set<String> parentParticipantSet = new Set<String>();
        String Logvalue;
        String recId;        
        try{
            List<Wish_Child_Form__c> wishchildList = [Select Id,Case__c,CreatedDate From Wish_Child_Form__c Where case__c =:currCase.id ORDER BY CreatedDate ASC Limit 1];
            
            Id wishDeterminationId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishDeterminationRT).getRecordTypeId();
            List<Case> currWishDeterminationCaseId = [SELECT ID FROM CASE WHERE  ParentId = :currWishChild.Case__c AND RecordTypeId = :wishDeterminationId limit 50000];
            
            if(currWishDeterminationCaseId.size() > 0)
                currWishChild.Wish_Determination_Case_Id__c = currWishDeterminationCaseId[0].id;
            
            
            
            if(wcfUtil.wishFamilyWrapList.size() > 0){
                if(currWishChild.Wish_Family_Contact__c == Null)
                    currWishChild.Wish_Family_Contact__c = '';
                String JSONString = JSON.serialize(wcfUtil.wishFamilyWrapList);
                currWishChild.Wish_Family_Contact__c = JSONString;                
                Integer age;
                
                WishChildFormUtil.WrapperClass getFirstIndex = wcfUtil.wishFamilyWrapList.get(0);
                
                if(String.isEmpty(getFirstIndex.FirstName) || String.isEmpty(getFirstIndex.LastName)  ||  getFirstIndex.Relationship == null || String.isEmpty(getFirstIndex.City)|| String.isEmpty(getFirstIndex.Street)|| String.isEmpty(getFirstIndex.State) || 
                   String.isEmpty(getFirstIndex.PostalCode)|| getFirstIndex.dob == null|| (String.isEmpty(getFirstIndex.homeTelephone)  && String.isEmpty(getFirstIndex.workTelephone) && String.isEmpty(getFirstIndex.mobileTelephone)))
                {  
                    isFamily = true;
                }
                
                for(WishChildFormUtil.WrapperClass currRec : wcfUtil.wishFamilyWrapList){
                    if(currRec.dob != Null){
                        Date dt = Date.Valueof(currRec.dob);
                        Integer days = dt.daysBetween(Date.Today());
                        age = Integer.valueOf(days/365);
                    }
                    
                    if(String.isEmpty(currRec.FirstName) || String.isEmpty(currRec.LastName)  ||  currRec.Relationship == null || 
                       currRec.dob == null|| String.isEmpty(currRec.residingWishMedical) || (String.isEmpty(currRec.homeTelephone)  && String.isEmpty(currRec.workTelephone) && String.isEmpty(currRec.mobileTelephone))){
                           isFamily = true;
                       }
                    
                    if(String.isEmpty(currRec.Email)){
                        isEmail = true;
                    }
                    
                    if(currRec.FirstName != Null && currRec.LastName != Null){
                        if(ParentAndParticipantsNames == Null || ParentAndParticipantsNames == ''){
                            ParentAndParticipantsNames = currRec.FirstName+' '+ currRec.LastName;
                            String name = currRec.FirstName+' '+ currRec.LastName;
                            parentParticipantSet.add(name);
                        }
                        else
                        {
                            ParentAndParticipantsNames = ParentAndParticipantsNames+', '+ currRec.FirstName+' '+ currRec.LastName;
                            String name = currRec.FirstName+' '+ currRec.LastName;
                            parentParticipantSet.add(name);
                            
                        }
                        if(FamilyContactEmail != Null && FamilyContactEmail != '' && FamilyContactName != Null && FamilyContactName != ''){
                            if(currRec.FirstName != Null && currRec.LastName != Null && currRec.Email != Null){
                                FamilyContactEmail +='#'+currRec.FirstName.trim()+' '+currRec.LastName.trim()+'::'+currRec.Email;
                                String name = currRec.FirstName.trim()+' '+currRec.LastName.trim()+'::'+currRec.Email;
                                nameWithEmailSet.add(name);
                                
                                if(ParentGurdianabove18Email != Null && ParentGurdianabove18 != '')
                                    ParentGurdianabove18Email +='#'+ currRec.FirstName.trim()+' '+currRec.LastName.trim()+'::'+currRec.Email;
                            }
                            if(currRec.FirstName != Null && currRec.LastName != Null){
                                FamilyContactName +='#'+currRec.FirstName.trim()+' '+currRec.LastName.trim();
                                String name = currRec.FirstName.trim()+' '+currRec.LastName.trim();
                                nameSet.add(name);
                                if(ParentGurdianabove18 != Null && ParentGurdianabove18 != '')
                                    ParentGurdianabove18 +='#'+ currRec.FirstName.trim()+' '+currRec.LastName.trim();
                            }
                        }
                        else{
                            if(currRec.FirstName != Null && currRec.LastName != Null && currRec.Email != Null){
                                FamilyContactEmail = currRec.FirstName.trim()+' '+currRec.LastName.trim()+'::'+currRec.Email;
                                String name = currRec.FirstName.trim()+' '+currRec.LastName.trim()+'::'+currRec.Email;
                                nameWithEmailSet.add(name);
                                ParentGurdianabove18Email = currRec.FirstName.trim()+' '+currRec.LastName.trim()+'::'+currRec.Email;
                            }
                            if(currRec.FirstName != Null && currRec.LastName != Null){
                                FamilyContactName = currRec.FirstName.trim()+' '+currRec.LastName.trim();
                                String name = currRec.FirstName.trim()+' '+currRec.LastName.trim();
                                nameSet.add(name);
                                ParentGurdianabove18 = currRec.FirstName.trim()+' '+currRec.LastName.trim();
                            }
                        }
                        if(RelatedContact != Null && RelatedContact != '' ){
                            if(currRec.Relationship != 'Other')
                                RelatedContact =  RelatedContact+','+' '+ currRec.FirstName.trim()+' '+currRec.LastName.trim();
                        }
                        else{
                            if(currRec.Relationship != 'Other')
                                RelatedContact = currRec.FirstName.trim()+' '+currRec.LastName.trim();
                        }
                    }
                } 
                
                if(isFamily == false){
                    isFamily = false;
                } 
                if(isEmail == false){
                    isEmail = false;
                }                   
                
                currWishChild.RelatedContact__c = RelatedContact;
                currWishChild.IsWishFamily__c = isFamily;
                currWishChild.IsParticipant__c = isEmail;
            }
            if(ethnicityList.size() > 0)
            {
                String ect = '';
                for(String str : ethnicityList){
                    if(str != null){
                        ect+=str+';';
                    }
                }
                ect = ect.removeEnd(';');                
                currWishChild.Race_Ethnicity__c = ect;
            }
            
            if(wcfUtil.wishParticipantList.size() > 0){
                currWishChild.Participant_Contacts__c= '';
                String JSONString = JSON.serialize(wcfUtil.wishParticipantList);                   
                currWishChild.Participant_Contacts__c= JSONString;
                currWishChild.Participant_Names__c = '';
                
                Integer age;
                System.debug('SAVE METHOD - '+wcfUtil.wishParticipantList);
                for(WishChildFormUtil.WrapperClass currRec : wcfUtil.wishParticipantList){
                    system.debug('@@@ currRec @@@'+currRec);
                    if(currRec.dob != Null){
                        Date dt = Date.Valueof(currRec.dob);
                        Integer days = dt.daysBetween(Date.Today());
                        age = Integer.valueOf(days/365);
                    }
                    if(currRec.FirstName != Null && currRec.LastName != Null && currRec.relationship != 'Wish Child (self)' )
                    {   String name = currRec.FirstName+' '+currRec.LastName;
                     if(!parentParticipantSet.contains(name)){
                         ParentAndParticipantsNames = ParentAndParticipantsNames+', '+ currRec.FirstName+' '+ currRec.LastName;
                     }
                     if(currWishChild.Participant_Names__c == '' || currWishChild.Participant_Names__c == Null)
                         currWishChild.Participant_Names__c = currRec.FirstName.trim()+' '+currRec.LastName.trim();
                     else
                         currWishChild.Participant_Names__c =currWishChild.Participant_Names__c+','+' '+currRec.FirstName.trim()+' '+currRec.LastName.trim();
                    }
                    if(String.isEmpty(currRec.FirstName) || String.isEmpty(currRec.LastName) || currRec.relationship == null || currRec.dob == null || String.isEmpty(currRec.residingWishMedical)){
                        isFamily = true;
                    } 
                    
                    if(currRec.FirstName != Null && currRec.LastName != Null && currRec.Email != Null && age >= 18 && currRec.relationship != 'Wish Child (self)'){
                        String participantName = currRec.FirstName.trim()+' '+currRec.LastName.trim()+'::'+currRec.Email;
                        if(!nameWithEmailSet.contains(participantName)){
                            if(ParticipantConEmail == '' || ParticipantConEmail == Null)
                                ParticipantConEmail =  currRec.FirstName.trim()+' '+currRec.LastName.trim()+'::'+currRec.Email+'::'+age;
                            else 
                                ParticipantConEmail +='#'+currRec.FirstName.trim()+' '+currRec.LastName.trim()+'::'+currRec.Email+'::'+age;
                        }
                        
                    }
                    if(currRec.FirstName != Null && currRec.LastName != Null && currRec.relationship != 'Wish Child (self)' && age >= 18){
                        String name = currRec.FirstName.trim()+' '+currRec.LastName.trim();
                        if(!nameSet.contains(name)){
                            if(ParticipantConName == Null || ParticipantConName == '')
                                ParticipantConName = currRec.FirstName.trim()+' '+currRec.LastName.trim()+'::'+age;
                            else
                                ParticipantConName +='#'+currRec.FirstName.trim()+' '+currRec.LastName.trim()+'::'+age;
                        }
                    }
                    
                }
                
                if(isFamily == false){
                    isFamily = false;
                }
                if(currWishChild.Participant_Names__c != Null)
                    currWishChild.Participant_Names__c = currWishChild.Participant_Names__c.removeEnd('#');
                
            }   
            if(wcfUtil.wishParticipantList.size() == 0){
                currWishChild.Participant_Contacts__c = null;}
            currWishChild.Hidden_Wish_Fmaily_Contact_Email__c = FamilyContactEmail;
            currWishChild.Hidden_Wish_Fmaily_Contact_Name__c = FamilyContactName;
            currWishChild.ParentsParticipantsName__c = ParentAndParticipantsNames;
            currWishChild.Participant_Details__c = ParticipantConEmail;
            currWishChild.Participant_Name__c = ParticipantConName ;
            currWishChild.Parent_Gurdian_above_18__c = ParentGurdianabove18;
            currWishChild.Parent_Gurdian_above_18_Email__c = ParentGurdianabove18Email;
            currWishChild.IsWishFamily__c = isFamily; 
            
            if(wcfUtil.isInformation == True){
                currWishChild.Availability_Time_Period_1__c = wcfUtil.availableMonth1+'/'+wcfUtil.availableYear1;
                currWishChild.Availability_Time_Period_2__c = wcfUtil.availableMonth2+'/'+wcfUtil.availableYear2;
                currWishChild.Availability_Time_Period_3__c = wcfUtil.availableMonth3+'/'+wcfUtil.availableYear3;
                currWishChild.Requested_Participant_Name_forWheelchair__c = selectedNamesss(tempName);
                currWishChild.Participant_Name_for_Dietary_Restriction__c = selectedNamesss(currrentDietaryNameList);
                currWishChild.Requested_Participant_Name_for_OtherNeed__c = selectedNamesss(currentOtherNeedsList);
                currWishChild.Requested_Participant_Name_for_Oxygen__c = selectedNamesss(currentOxygenNamesList);
                currWishChild.Requested_Participant_Name_for_Allergies__c = selectedNamesss(currentAllergyNamesList);
                currWishChild.Bringing_Own_Wheel_Chair__c = selectedNamesss(currentOwnWheelChairList);
                currWishChild.Name_of_wheelchair_collapsible__c= selectedNamesss(currentWCCollapsibleList);
                currWishChild.Pariticipant_name_havingWheelchair_Power__c= selectedNamesss(currentWCPowerList);
                currWishChild.Medication_require_refrigeration_name__c= selectedNamesss(currentMedicationList);
                currWishChild.Names_for_receiving_nursing_care__c= selectedNamesss(currentNursingCareList);
            }
            
            if(wcfUtil.driverWrapperCls.size() > 0 ){
                currWishChild.Driver_Details__c = '';
                String JSONString = JSON.serialize(wcfUtil.driverWrapperCls);
                currWishChild.Driver_Details__c = JSONString;
                String driverInfo = '';
                Integer i = 0;
                String driverName = '';
                for(WishChildFormUtil.DriverWrapper currRec : wcfUtil.driverWrapperCls){
                    if(currRec.driverName != '')
                    {  
                        If(driverName == ''){
                            driverName = currRec.driverName;
                        }
                        else{
                            driverName = currRec.driverName+','+' '+driverName ;
                        }
                        if(driverInfo == ''){
                            if(string.valueof(currRec.expirationDate) != null ){
                                String S = String.valueof(currRec.expirationDate);
                                String s1 = S.remove(' 00:00:00');
                                driverInfo = currRec.driverName+' '+'|'+' '+currRec.licenseNum+' '+'|'+' '+currRec.state +' '+'|'+' '+ s1 +' '+'|'+' '+currRec.type;      
                            }
                            
                        }
                        
                        else{
                            
                            if(string.valueof(currRec.expirationDate) != null ){
                                String S = String.valueof(currRec.expirationDate);
                                String s1 = S.remove(' 00:00:00');
                                driverInfo =driverInfo +'<br/>'+currRec.driverName+' '+'|'+' '+currRec.licenseNum+' '+'|'+' '+currRec.state +' '+'|'+' '+ s1 +' '+'|'+' '+currRec.type;      
                            }
                            
                        }
                    }   
                } 
                CurrWishChild.Driver_name__c = driverName; 
                currWishChild.Driver_Information__c = driverInfo;
            }  
            
            if(wcfUtil.driverWrapperCls.size() == 0 && wcfUtil.isInformation == True){
                currWishChild.Driver_Information__c = null;
                currWishChild.Driver_Details__c = null;
            } 
            currWishChild.Case_Team_Member1__c = wcfUtil.caseTeamMemberNo1;
            currWishChild.Case_Team_Member2__c = wcfUtil.caseTeamMemberNo2;
            
            if(wishchildList.size() == 0){
                Logvalue = String.valueOf(currWishChild);
                recId = currWishChild.Id;
                insert currWishChild;                
            }
            if(wishchildList.size() == 1){
                Logvalue = String.valueOf(currWishChild);
                recId = currWishChild.Id;
                update currWishChild;
            }
        }
        catch(DMLException e){              
            //showException = true;
            new ApexDebugLog().createLog(new ApexDebugLog.Error('WishChildForm_AC','SaveContact',recId,e,Logvalue)); 
            displayErrorMessage(e);
            
        }     
    }
    
    
    /******************************************************************************************************
This is the SaveandWishChildExit() method is used nevigate the user to corresponding form like 
if the user in wish child form and if the user wants to go wishinformation form they can click 
the corresponding link then the user redirect to that form and information are saved in backend 
object.
*******************************************************************************************************/
    public void SaveandWishChildExit(){
        String Logvalue;
        
        String pageName = ApexPages.currentPage().getUrl().substringBetween('apex/', '?');
        if(pageName == 'WishChildForm_VF'){
            saveContact();
        }
        if(pageName == 'WishFamilyForm_VF'){
            saveContact();
        }
        if(pageName == 'WishInformationForm_VF'){
            WishInfoSave();
        }
    }
    
    
    /******************************************************************************************************
This WCFNext() method is used to redirect the user from wish child form to wish family form.
*******************************************************************************************************/
    public PageReference WCFNext(){ 
        String Logvalue;
        saveContact();
        Logvalue = String.valueOf(this.currCase);
        PageReference reference=new PageReference('/apex/WishFamilyForm_VF?id='+this.currCase.id);
        reference.setRedirect(true);     
        return reference;
    }
    
    
    /******************************************************************************************************
This WCFtoWIF() method is used to redirect the user from wish family form to wish information form 
*******************************************************************************************************/    
    public PageReference WCFtoWIF(){
        String Logvalue;
        
        saveContact();
        Logvalue = String.valueOf(this.currCase);
        PageReference reference=new PageReference('/apex/WishInformationForm_VF?id='+this.currCase.id);
        reference.setRedirect(true);     
        return reference;
        
    }
    
    /******************************************************************************************************
This WCFtoWFF() method is used to redirect the user from wish child form to wish information form 
*******************************************************************************************************/ 
    public PageReference WCFtoWFF(){
        PageReference reference;
        String Logvalue;
        
        saveContact();
        Logvalue = String.valueOf(this.currCase);
        reference=new PageReference('/apex/WishFamilyForm_VF?id='+this.currCase.id);
        reference.setRedirect(true);                 
        return reference;
    }
    
    /******************************************************************************************************
This WCFtoWFF() method is used to redirect to wish information form 
*******************************************************************************************************/ 
    public PageReference WishFamilytoWishInfo(){
        PageReference reference;
        String Logvalue;
        try
        {  
            
            saveContact();
            Logvalue = String.valueOf(this.currCase);
            reference=new PageReference('/apex/WishInformationForm_VF?id='+this.currCase.id);            
            reference.setRedirect(true);
                
        }
        Catch(DMLException e)
        {   
            //showException = true;
            new ApexDebugLog().createLog(new ApexDebugLog.Error('WishChildForm_AC','WishFamilytoWishInfo',currCase.id,e,Logvalue));
            displayErrorMessage(e);           
        }
        return reference;
    }
    
    /******************************************************************************************************
This WCFtoWFF() method is used to redirect the user to wish child form
*******************************************************************************************************/ 
    public PageReference WishInfotoWishChild(){
        PageReference reference;
        String Logvalue;
        try
        {    
            
            wcfUtil.isInformation = True;
            saveContact();
            Logvalue = String.valueOf(this.currCase);            
            reference=new PageReference('/apex/WishChildForm_VF?id='+this.currCase.id);
            reference.setRedirect(true);
                
        }
        Catch(DMLException e)
        {  
            //showException = true;
            new ApexDebugLog().createLog(new ApexDebugLog.Error('WishChildForm_AC','WishInfotoWishChild',currCase.id,e,Logvalue));
            displayErrorMessage(e);           
        }
        return reference;
    }
    
    /******************************************************************************************************
This WCFtoWFF() method is used to redirect the user to wish family form
*******************************************************************************************************/ 
    public PageReference WishInfotoWishFamily(){
        PageReference reference;
        String Logvalue;
        try
        {    
            
            wcfUtil.isInformation = True;
            saveContact();
            Logvalue = String.valueOf(this.currCase);
            reference=new PageReference('/apex/WishFamilyForm_VF?id='+this.currCase.id);
            reference.setRedirect(true);
           
        }
        Catch(DMLException e)
        {    
            //showException = true;
            new ApexDebugLog().createLog(new ApexDebugLog.Error('WishChildForm_AC','WishInfotoWishFamily',currCase.id,e,Logvalue));
            displayErrorMessage(e);          
        }
        return reference;
    }
    
    /******************************************************************************************************
This WCFtoWFF() method is used to redirect the user to wish child form
*******************************************************************************************************/ 
    public PageReference NavigatetoWishChildForm(){
        PageReference reference;
        String Logvalue;
        try
        {   
            
            wcfUtil.isInformation = True;
            saveContact();
            Logvalue = String.valueOf(this.currCase);
            reference=new PageReference('/apex/WishChildForm_VF?id='+this.currCase.id + '&required=true');
            reference.setRedirect(true);
            
        }
        Catch(DMLException e)
        {   
            //showException = true;
            new ApexDebugLog().createLog(new ApexDebugLog.Error('WishChildForm_AC','NavigatetoWishChildForm',currCase.id,e,Logvalue));
            displayErrorMessage(e);            
        }
        return reference;
    }
    
    /******************************************************************************************************
This WCFtoWFF() method is used to redirect the user to wish family form
*******************************************************************************************************/ 
    public PageReference NavigatetoWishFamily(){
        PageReference reference;
        String Logvalue;
        try
        {   
            
            wcfUtil.isInformation = True;
            SaveContact();  
            Logvalue = String.valueOf(this.currCase);
            reference=new PageReference('/apex/WishFamilyForm_VF?id='+this.currCase.id + '&required=true');
            reference.setRedirect(true);
           
        }
        Catch(DMLException e)
        {
            //showException = true;
            new ApexDebugLog().createLog(new ApexDebugLog.Error('WishChildForm_AC','NavigatetoWishFamily',currCase.id,e,Logvalue));
            displayErrorMessage(e);           
        }
        return reference;
    }
    
    /******************************************************************************************************
This cancelfunction() method is used to redirect the user case details page
*******************************************************************************************************/ 
    public PageReference cancelfunction(){
        PageReference reference=new PageReference('/'+currCase.id);
        reference.setRedirect(true);     
        return reference;
    }
    
    /******************************************************************************************************
This WCFtoWFF() method is used to redirect the user to wish information form.
*******************************************************************************************************/ 
    public pageReference cancel(){
        PageReference reference=new PageReference('/apex/WishInformationForm_VF?id='+currCase.id);
        reference.setRedirect(true);     
        return reference;
    }
    
    /******************************************************************************************************
This SavewithExit() method is used save the current page details and redirect the user to case detail page.
*******************************************************************************************************/ 
    public PageReference SavewithExit(){
        String Logvalue;
        try{
            
            saveContact();
            Logvalue = String.valueOf(currCase);
            PageReference reference=new PageReference('/'+currCase.id);
            reference.setRedirect(true);     
            return reference;
            
        }      
        catch(DMLException e)
        {   
            //showException = true;
            new ApexDebugLog().createLog(new ApexDebugLog.Error('WishChildForm_AC','SavewithExit',currCase.id,e,Logvalue));
            displayErrorMessage(e);
        }  
        return null; 
    }
    
    /******************************************************************************************************
This removeFamily() method is used remove the parent legual guardian details from paren guardian sections..
*******************************************************************************************************/ 
    public void removeFamily(){
        
        Integer indexVal = Integer.valueof(system.currentpagereference().getparameters().get('index'));
        //Remove the contact from the table    
        wcfUtil.wishFamilyWrapList.remove(indexVal);            
    }   
    
    /******************************************************************************************************
This removeParticipants() method is used remove the participant details from participant sections..
*******************************************************************************************************/ 
    public void removeParticipants(){
        Integer indexVal = Integer.valueof(system.currentpagereference().getparameters().get('Participant'));
        //Remove the contact from the table    
        wcfUtil.wishParticipantList.remove(indexVal);            
    } 
    
    /******************************************************************************************************
This removeDriver() method is used remove the driver details from driver information section.
*******************************************************************************************************/
    public void removeDriver(){
        Integer indexVal = Integer.valueof(system.currentpagereference().getparameters().get('driver'));
        
        wcfUtil.driverWrapperCls.remove(indexVal);            
    }    
    
    /********************************************************************
This ExitwithApprovalError() redirect the user to case detail page.
*********************************************************************/
    public PageReference ExitwithApprovalError(){
        PageReference reference=new PageReference('/'+currentPageId);
        reference.setRedirect(true);     
        return reference;
    }
    
    /*************************************************************************************************
This addFamily() is used to initilaze the wishFamilyWrapList when the wish family form is loaded.
**************************************************************************************************/
    public void addFamily(){
        System.debug('Function called+++++++++++');
        (wcfUtil.wishFamilyWrapList).add(new WishChildFormUtil.WrapperClass());
    }
    
    /*************************************************************************************************
This addDriver() is used to initilaze the driverWrapperCls when the wish information form is loaded.
**************************************************************************************************/
    public void addDriver(){
        // if(wcfUtil.driverWrapperCls.size() < wcfUtil.wishParticipantList.size())
        wcfUtil.driverWrapperCls.add(new WishChildFormUtil.DriverWrapper());
    }
    
    /*************************************************************************************************
This addParticipants() is used to initilaze the wishParticipantList when the wish family form is 
loaded.
**************************************************************************************************/
    public void addParticipants(){ 
        wcfUtil.wishParticipantList.add(new WishChildFormUtil.WrapperClass());
    }
    
    /*************************************************************************************************
This BackToWCF() is used to redrict the user to wish child form and save the current page information.
**************************************************************************************************/
    public pageReference BackToWCF()
    {
        String Logvalue;
        try{
            
            SaveContact();
            System.debug('AFTER SAVE');
            Logvalue = string.valueOf(currCase);
            PageReference reference=new PageReference('/apex/WishChildForm_VF?id='+this.currCase.id);
            reference.setRedirect(true);     
            return reference;
            
        }
        catch(Exception e){
            //showException = true;
            new ApexDebugLog().createLog(new ApexDebugLog.Error('WishChildForm_AC','BackToWCF',currCase.id,e,Logvalue));
            displayErrorMessage(e);
            
        }
       return null;
    }
    
    
    /*************************************************************************************************
This SaveandwishFamilyExit() is used to redrict the user to wish family form and save the current page information.
**************************************************************************************************/
    public PageReference SaveandwishFamilyExit()
    {
        String Logvalue;
        try{
           
            saveContact();
            Logvalue = string.valueOf(currCase);
            PageReference reference=new PageReference('/apex/WishFamilyForm_VF?id='+currCase.id+'&part='+isParticipants);
            reference.setRedirect(true);  
            return reference;
            
        }      
        catch(DMLException e)
        {   
            //showException = true;
            new ApexDebugLog().createLog(new ApexDebugLog.Error('WishChildForm_AC','SaveandwishFamilyExit',currCase.id,e,Logvalue));
            displayErrorMessage(e);
        }      
        return null;   
    }
    
    
    /*********************************************************************************************************
This WFFNext() is used to redrict the user to wish information form and save the current page information.
**********************************************************************************************************/
    public PageReference WFFNext(){ 
        String Logvalue;
        try
        {
            
            saveContact();
            Logvalue = string.valueOf(currCase);
            PageReference reference=new PageReference('/apex/WishInformationForm_VF?id='+this.currCase.id);
            reference.setRedirect(true);     
            return reference;
            
        }      
        catch(DMLException e)
        {   
            //showException = true;
            new ApexDebugLog().createLog(new ApexDebugLog.Error('WishChildForm_AC','WFFNext',currCase.id,e,Logvalue));
            displayErrorMessage(e);
        }
        return null; 
    }
    
    
    /*****************************************************************************************************************
This withOutSavefromWCFtoWIF() is used to redrict the user to wish information form with out save the current page.
*******************************************************************************************************************/
    Public pageReference withOutSavefromWCFtoWIF(){
        
        PageReference reference=new PageReference('/apex/WishInformationForm_VF?id='+currCase.id);
        reference.setRedirect(true);     
        return reference;
    }
    
    /*****************************************************************************************************************
This withOutSavetoChild() is used to redrict the user to wish child form with out save the current page.
*******************************************************************************************************************/
    Public pageReference withOutSavetoChild(){
        PageReference reference=new PageReference('/apex/WishChildForm_VF?id='+currCase.id);
        reference.setRedirect(true);     
        return reference;
    }
    
    /*****************************************************************************************************************
This withOutSaveWCCF() is used to redrict the user to wish information form with out save the current page.
*******************************************************************************************************************/
    Public pageReference withOutSaveWCCF(){
        system.debug('withOutSaveWCCF method');
        PageReference reference=new PageReference('/apex/WishFamilyForm_VF?id='+currCase.id);
        reference.setRedirect(true);     
        return reference;
    }
    
    /*************************************************************************************************
This wishChildMap() is used to add the wish child name in medical information section. This method 
is called when wish information page is loded.
**************************************************************************************************/
    Public void wishChildMap(String firstName,String lastName){
        
        if(firstName != Null && lastName != Null)
            wcfUtil.leftDietaryNameList.add('Wish Child - '+firstName+' ' +lastName);
        if(firstName != Null && lastName != Null)
            wcfUtil.leftWCNamesList.add('Wish Child - '+firstName+' ' +lastName);
        
        if(firstName != Null && lastName != Null)
            wcfUtil.leftOxygenNamesList.add('Wish Child - '+firstName+' ' +lastName);
        
        if(firstName != Null && lastName != Null)
            wcfUtil.leftAllergyNamesList.add('Wish Child - '+firstName+' ' +lastName);
        
        if(firstName != Null && lastName != Null)
            wcfUtil.leftOtherNeedsList.add('Wish Child - '+firstName+' ' +lastName);
        
        if(firstName != Null && lastName != Null)
            wcfUtil.leftOwnWheelChairList.add('Wish Child - '+firstName+' ' +lastName);
        
        if(firstName != Null && lastName != Null)
            wcfUtil.leftWCCollapsibleList.add('Wish Child - '+firstName+' ' +lastName);
        
        if(firstName != Null && lastName != Null)
            wcfUtil.leftWCPowerList.add('Wish Child - '+firstName+' ' +lastName);
        
        if(firstName != Null && lastName != Null)
            wcfUtil.leftMedicationList.add('Wish Child - '+firstName+' ' +lastName);
        
        if(firstName != Null && lastName != Null)
            wcfUtil.leftNursingCareList.add('Wish Child - '+firstName+' ' +lastName);
    }
    
    /*************************************************************************************************
This ParentLegalMapping() is used to add the parent legual guardian name in medical information section 
and drive details. This method is called when wish information page is loded.
**************************************************************************************************/
    public void ParentLegalMapping(List<WishChildFormUtil.WrapperClass> wrapFamilyList,Boolean isChecked){
        
        for(WishChildFormUtil.WrapperClass  currRec : wrapFamilyList){
            
            WishChildFormUtil.WrapperClass wrapCls = new WishChildFormUtil.WrapperClass();
            wrapCls.FirstName = (currRec.FirstName!=Null)?currRec.FirstName:'';
            wrapCls.MiddleName = (currRec.MiddleName!=Null)?currRec.MiddleName:'';
            wrapCls.lastName = (currRec.lastName!=Null)?currRec.lastName:'';
            wrapCls.Relationship = (currRec.Relationship!=Null)?currRec.Relationship:'';
            wrapCls.dob =  (currRec.dob !=Null)?Date.valueOf(currRec.dob):currRec.dob;
            wrapCls.medicalNeeds =  currRec.medicalNeeds;
            wrapCls.residingWishMedical =currRec.residingWishMedical;
            wrapCls.Email =  (currRec.Email!=Null)?currRec.Email:'';
            wrapCls.tshirtSize = (currRec.tshirtSize!=Null)?currRec.tshirtSize:'';
            wrapCls.sameParentGuardianFlag = (isChecked == true) ? isChecked : currRec.sameParentGuardianFlag;
            wrapCls.isChildParticipants = isChildPart;
            //wcfUtil.wishParticipantList.add(wrapCls); 
            if(wrapCls.dob != null && wrapCls.Relationship != 'Wish Child (self)') {
                if(Integer.valueOf(wrapCls.dob.daysBetween(Date.Today())/365) >= 18 && wrapCls.sameParentGuardianFlag == true) {
                    String Name = wrapCls.Relationship+' - '+wrapCls.FirstName+' '+wrapCls.lastName;
                    wcfUtil.driverNameList.add((new SelectOption(Name,Name)));
                }
            }
            if(wrapCls.sameParentGuardianFlag == true){
                if(wrapCls.FirstName != Null && wrapCls.lastName != Null)
                    wcfUtil.leftDietaryNameList.add(wrapCls.Relationship+' - '+wrapCls.FirstName+' ' +wrapCls.lastName);
                if(wrapCls.FirstName != Null && wrapCls.lastName != Null)
                    wcfUtil.leftWCNamesList.add(wrapCls.Relationship+' - '+wrapCls.FirstName+' ' +wrapCls.lastName);
                
                if(wrapCls.FirstName != Null && wrapCls.lastName != Null)
                    wcfUtil.leftOxygenNamesList.add(wrapCls.Relationship+' - '+wrapCls.FirstName+' ' +wrapCls.lastName);
                
                if(wrapCls.FirstName != Null && wrapCls.lastName != Null)
                    wcfUtil.leftAllergyNamesList.add(wrapCls.Relationship+' - '+wrapCls.FirstName+' ' +wrapCls.lastName);
                
                if(wrapCls.FirstName != Null && wrapCls.lastName != Null)
                    wcfUtil.leftOtherNeedsList.add(wrapCls.Relationship+' - '+wrapCls.FirstName+' ' +wrapCls.lastName);
                
                if(wrapCls.FirstName != Null && wrapCls.lastName != Null)
                    wcfUtil.leftOwnWheelChairList.add(wrapCls.Relationship+' - '+wrapCls.FirstName+' ' +wrapCls.lastName);
                
                if(wrapCls.FirstName != Null && wrapCls.lastName != Null)
                    wcfUtil.leftWCCollapsibleList.add(wrapCls.Relationship+' - '+wrapCls.FirstName+' ' +wrapCls.lastName);
                
                if(wrapCls.FirstName != Null && wrapCls.lastName != Null)
                    wcfUtil.leftWCPowerList.add(wrapCls.Relationship+' - '+wrapCls.FirstName+' ' +wrapCls.lastName);
                
                if(wrapCls.FirstName != Null && wrapCls.lastName != Null)
                    wcfUtil.leftMedicationList.add(wrapCls.Relationship+' - '+wrapCls.FirstName+' ' +wrapCls.lastName);
                
                if(wrapCls.FirstName != Null && wrapCls.lastName != Null)
                    wcfUtil.leftNursingCareList.add(wrapCls.Relationship+' - '+wrapCls.FirstName+' ' +wrapCls.lastName);
            }
            
        }
    } 
    
    /*************************************************************************************************
This ParticipantsMapping() is used to add the participant name in medical information section 
and drive details. This method is called when wish information page is loded.
**************************************************************************************************/
    public void ParticipantsMapping(List<WishChildFormUtil.WrapperClass> participantsList,Boolean isChecked){
        
        for(WishChildFormUtil.WrapperClass  currRec : participantsList){
            
            WishChildFormUtil.WrapperClass wrapCls = new WishChildFormUtil.WrapperClass();
            wrapCls.FirstName = (currRec.FirstName!=Null)?currRec.FirstName:'';
            wrapCls.MiddleName = (currRec.MiddleName!=Null)?currRec.MiddleName:'';
            wrapCls.lastName = (currRec.lastName!=Null)?currRec.lastName:'';
            wrapCls.Relationship = (currRec.Relationship!=Null)?currRec.Relationship:'';
            wrapCls.dob =  (currRec.dob !=Null)?Date.valueOf(currRec.dob):currRec.dob;
            wrapCls.medicalNeeds =  currRec.medicalNeeds;
            wrapCls.residingWishMedical =currRec.residingWishMedical;
            wrapCls.Email =  (currRec.Email!=Null)?currRec.Email:'';
            wrapCls.tshirtSize = (currRec.tshirtSize!=Null)?currRec.tshirtSize:'';
            wrapCls.sameParentGuardianFlag = (isChecked == true) ? isChecked : currRec.sameParentGuardianFlag;
            wrapCls.isChildParticipants = isChildPart;
            wcfUtil.wishParticipantList.add(wrapCls); 
            if(wrapCls.dob != null && wrapCls.Relationship != 'Wish Child (self)') {
                if(Integer.valueOf(wrapCls.dob.daysBetween(Date.Today())/365) >= 18) {
                    String Name = wrapCls.Relationship+' - '+wrapCls.FirstName+' '+wrapCls.lastName;
                    wcfUtil.driverNameList.add((new SelectOption(Name,Name)));
                }
            }
            if(wrapCls.FirstName != Null && wrapCls.lastName != Null)
                wcfUtil.leftDietaryNameList.add(wrapCls.Relationship+' - '+wrapCls.FirstName+' ' +wrapCls.lastName);
            if(wrapCls.FirstName != Null && wrapCls.lastName != Null)
                wcfUtil.leftWCNamesList.add(wrapCls.Relationship+' - '+wrapCls.FirstName+' ' +wrapCls.lastName);
            
            if(wrapCls.FirstName != Null && wrapCls.lastName != Null)
                wcfUtil.leftOxygenNamesList.add(wrapCls.Relationship+' - '+wrapCls.FirstName+' ' +wrapCls.lastName);
            
            if(wrapCls.FirstName != Null && wrapCls.lastName != Null)
                wcfUtil.leftAllergyNamesList.add(wrapCls.Relationship+' - '+wrapCls.FirstName+' ' +wrapCls.lastName);
            
            if(wrapCls.FirstName != Null && wrapCls.lastName != Null)
                wcfUtil.leftOtherNeedsList.add(wrapCls.Relationship+' - '+wrapCls.FirstName+' ' +wrapCls.lastName);
            
            if(wrapCls.FirstName != Null && wrapCls.lastName != Null)
                wcfUtil.leftOwnWheelChairList.add(wrapCls.Relationship+' - '+wrapCls.FirstName+' ' +wrapCls.lastName);
            
            if(wrapCls.FirstName != Null && wrapCls.lastName != Null)
                wcfUtil.leftWCCollapsibleList.add(wrapCls.Relationship+' - '+wrapCls.FirstName+' ' +wrapCls.lastName);
            
            if(wrapCls.FirstName != Null && wrapCls.lastName != Null)
                wcfUtil.leftWCPowerList.add(wrapCls.Relationship+' - '+wrapCls.FirstName+' ' +wrapCls.lastName);
            
            if(wrapCls.FirstName != Null && wrapCls.lastName != Null)
                wcfUtil.leftMedicationList.add(wrapCls.Relationship+' - '+wrapCls.FirstName+' ' +wrapCls.lastName);
            
            if(wrapCls.FirstName != Null && wrapCls.lastName != Null)
                wcfUtil.leftNursingCareList.add(wrapCls.Relationship+' - '+wrapCls.FirstName+' ' +wrapCls.lastName);
            
        }
    }
    
    
    /****************************************************************************************************
This SaveandRedirectChildForm() is used to redirect the user to wish child form and save the current.
page information
*****************************************************************************************************/
    public PageReference SaveandRedirectChildForm(){
        String Logvalue;
        try{
            
            saveContact();
            Logvalue = String.valueOf(this.currCase);
            PageReference reference=new PageReference('/apex/WishChildForm_VF?id='+this.currCase.id);
            reference.setRedirect(true);     
            return reference;
            
        }
        catch(Exception e){
           //showException = true;
           new ApexDebugLog().createLog(new ApexDebugLog.Error('WishChildForm_AC','SaveandRedirectChildForm',currCase.id,e,Logvalue));
           displayErrorMessage(e);
        }
        return null;
    }
    
    /****************************************************************************************************
This SaveAndRedirectFamilyForm() is used to redirect the user to wish family form and save the current.
page information
*****************************************************************************************************/
    public PageReference SaveAndRedirectFamilyForm(){
        
        String Logvalue;
        try{
            
            saveContact();
            PageReference reference=new PageReference('/apex/WishFamilyForm_VF?id='+this.currCase.id);
            reference.setRedirect(true);     
            return reference;
            
        }
        catch(Exception e){
            //showException = true;
            new ApexDebugLog().createLog(new ApexDebugLog.Error('WishChildForm_AC','SaveAndRedirectFamilyForm',currCase.id,e,Logvalue));
            displayErrorMessage(e);
        }
         return null;
    }
    
    /****************************************************************************************************
This SaveAndRedirectInformationForm() is used to redirect the user to wish family form and save the current.
page information
*****************************************************************************************************/
    public PageReference SaveAndRedirectInformationForm(){
        String Logvalue;
        try{
            
            WishInfoSave();
            PageReference reference=new PageReference('/apex/WishFamilyForm_VF?id='+this.currCase.id);
            reference.setRedirect(true);     
            return reference;
            
        }
        catch(Exception e){
            //showException = true;
            new ApexDebugLog().createLog(new ApexDebugLog.Error('WishChildForm_AC','SaveAndRedirectInformationForm',currCase.id,e,Logvalue));
            displayErrorMessage(e);
        }
        return null;
    }
    
    /****************************************************************************************************
This SaveFromInformationToChildForm() is used to redirect the user to wish child form and save the current.
page information
*****************************************************************************************************/   
    public PageReference SaveFromInformationToChildForm()
    {
        String Logvalue;
        try{
            
            WishInfoSave();
            PageReference reference=new PageReference('/apex/WishChildForm_VF?id='+this.currCase.id);
            reference.setRedirect(true);     
            return reference;
            
        }
        catch(Exception e){
           //showException = true;
           new ApexDebugLog().createLog(new ApexDebugLog.Error('WishChildForm_AC','SaveFromInformationToChildForm',currCase.id,e,Logvalue));
           displayErrorMessage(e);
        }
        return null;
    }
    
    /****************************************************************************************************
This confirmSignNow() is used to query the parent legual guardian who are all going to sign the
wish form.
*****************************************************************************************************/  
    public void confirmSignNow()
    {
        String Logvalue;
        try{
            
            wcfUtil.isInformation = True;
            SaveContact();        
            for(Wish_Child_Form__c wishChildForm : [SELECT Id,Name,Case__c,Hidden_Same_as_Family__c,Race_Ethnicity__c,Hidden_Contact_Name__c,Hidden_Wish_Fmaily_Contact_Email__c,Hidden_Wish_Fmaily_Contact_Name__c FROM Wish_Child_Form__c WHERE
                                                    Case__c =: this.currCase.Id])
            {
                if(wishChildForm.Hidden_Wish_Fmaily_Contact_Name__c != null) {  
                    for(String keys : wishChildForm.Hidden_Wish_Fmaily_Contact_Name__c.split('#'))
                    {
                        wcfUtil.SignNowList.add(keys .trim());                     
                    }                  
                }
            }
          
        }
        catch(Exception e){
            //showException = true;
            new ApexDebugLog().createLog(new ApexDebugLog.Error('WishChildForm_AC','confirmSignNow',currCase.Id,e,Logvalue));
            displayErrorMessage(e);
            
        }
    }
    
    /****************************************************************************************************
This SignNowmultiEmail() is used to display the parent legual guardian who are all going to sign the
wish form using the sign now option.
*****************************************************************************************************/  
    public void SignNowmultiEmail(){
        wcfUtil.multiPickoptions = new List<SelectOption>();
        if(wcfUtil.emailMap.size() > 0)
        {
            if(processedNameMap.size() > 0)
            {
                for(String name : processedNameMap.KeySet())
                {
                    if(!nameMap.containsKey(name)){
                        wcfUtil.selectedMailMap.put(name,processedNameMap.get(name));
                    }
                }
            }
        }
        if(wcfUtil.selectedMailMap.size() > 0)
        {
            for(String currString : wcfUtil.selectedMailMap.keySet()){           
                wcfUtil.multiPickoptions.add(new SelectOption(currString,currString ));
            }
        }     
        if(wcfUtil.selectedMailMap.size() == 0){
            wcfUtil.displayError = true;
        }
    }
    
     /****************************************************************************************************
This SubmitAndSign() is used to initiate the callout to docusign to create an envelop and generate the 
recepient who are all going to sign the wish form.
*****************************************************************************************************/
    public Pagereference SubmitAndSign(){
        String account;
        String UserName;
        String Password;
        String IntegratorKey;
        String endPointURL;
        String currentSigner;
        Id wishPaperPocketId;
        String authorizationHeader;
        String endpoint; 
        String status;
        String email;
        String recipients = '';
        Integer i = 1;
        String boundary = 'AAA';
        boolean isFirstParent = true;
        PageReference reference;
        String Logvalue;
        String recId;
        List<dsfs__DocuSign_Status__c> dsfsList = new List<dsfs__DocuSign_Status__c>();
        Set<String> processSet = new Set<String>(); 
        Map<String,DocuSignCredentialsSetting__c> credentialSetting = DocuSignCredentialsSetting__c.getAll();        
        try{
            Wish_Child_Form__c dbcase = [SELECT Id,Envelop_Id__c,Case__c,SignerMapKeyPair__c,Hidden_Envelop_Id_1__c,Hidden_Envelop_Id_2__c,Hidden_Wish_Fmaily_Contact_Name__c,
                                         Hidden_SignerMap_Key_1__c,Hidden_SignerMap_Key_2__c,Hidden_Envelop_Id_3__c,Hidden_SignerMap_Key_3__c FROM Wish_Child_Form__c WHERE Case__c =:currCase.id];
            for(DocuSignCredentialsSetting__c credentialIns : credentialSetting.values()){
                UserName = credentialIns.name;
                account  = credentialIns.account__c;
                Password = credentialIns.Password__c;
                IntegratorKey  = credentialIns.IntegratorKey__c;
                endPointURL = credentialIns.end_Point__c;
            }
            endpoint = endPointURL+'/accounts/'+account+'/envelopes';
            authorizationHeader = '<DocuSignCredentials><Username>'+UserName+'</Username><Password>'+Password+'</Password><IntegratorKey>'+IntegratorKey+'</IntegratorKey></DocuSignCredentials>';
            Pagereference PDF = Page.SignNowPDF;
            PDF.getParameters().put('Id',currCase.id);
            try {
                //If(!Test.isrunningtest())
                wcfUtil.documentPDF = EncodingUtil.base64Encode(PDF.getContentAsPDF());
            }
            catch(Exception e){
                e.getMessage();
            }
            
            if(dbcase.SignerMapKeyPair__c != Null && dbcase.Envelop_Id__c != Null && dbcase.Hidden_Envelop_Id_1__c == Null &&
               dbcase.Hidden_SignerMap_Key_1__c == Null ){
                   for(String processName : dbcase.SignerMapKeyPair__c.split('#')){
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
            if(dbcase.Hidden_Envelop_Id_1__c != Null && dbcase.Hidden_SignerMap_Key_1__c != Null)
            {
                set<String> processSetOne = new Set<String>();
                for(String processName : dbcase.Hidden_SignerMap_Key_1__c .split('#')){
                    String keys = processName.split('-')[0];
                    String value = processName.split('-')[1];
                    String name = Keys.trim();
                    processSetOne.add(name);
                }
                for(String processName : dbcase.SignerMapKeyPair__c.split('#'))
                {
                    String keys = processName.split('-')[0];
                    String value = processName.split('-')[1];
                    String name = Keys.trim();
                    processSet.add(name);
                }
                for(String signNowName : signerSet)
                {
                    if(!processSet.contains(signNowName)){
                        if(!processSetOne.contains(signNowName)){
                            j = 2;
                            k = 1;
                        }
                    }
                }
            }
            if(dbcase.Hidden_Envelop_Id_2__c != Null && dbcase.Hidden_SignerMap_Key_2__c != Null)
            {
                Set<String> processSetOne = new Set<String>();
                Set<String> processSetTwo = new Set<String>();
                for(String processName : dbcase.Hidden_SignerMap_Key_2__c .split('#'))
                {
                    String keys = processName.split('-')[0];
                    String value = processName.split('-')[1];
                    String name = Keys.trim();
                    processSetTwo.add(name);
                }
                for(String processName : dbcase.Hidden_SignerMap_Key_1__c .split('#'))
                {
                    String keys = processName.split('-')[0];
                    String value = processName.split('-')[1];
                    String name = Keys.trim();
                    processSetOne.add(name);
                }
                for(String processName : dbcase.SignerMapKeyPair__c.split('#'))
                {
                    String keys = processName.split('-')[0];
                    String value = processName.split('-')[1];
                    String name = Keys.trim();
                    processSet.add(name);
                }
                
                for(String signNowName : signerSet)
                {
                    if(!processSet.contains(signNowName))
                    {
                        if(!processSetOne.contains(signNowName))
                        {
                            if(!processSetTwo.contains(signNowName))
                            {
                                j = 3;
                                k = 2;
                            }
                        }
                    }
                }
            }
            if((dbcase.Envelop_Id__c  == Null && dbcase.SignerMapKeyPair__c == Null && j == 0) || (dbcase.Hidden_Envelop_Id_1__c == Null && dbcase.Hidden_SignerMap_Key_1__c == Null && j == 1 && k == 0) || 
               (dbcase.Hidden_Envelop_Id_2__c == Null && dbcase.Hidden_SignerMap_Key_2__c  == Null && j == 2 && k == 1) || (dbcase.Hidden_Envelop_Id_3__c == Null && dbcase.Hidden_SignerMap_Key_3__c == Null && j == 3 && k == 2)){
                   Map<String,String> ParentGurdianMap = new Map<String,String>();
                   for(String currString : dbcase.Hidden_Wish_Fmaily_Contact_Name__c.split('#')){
                       
                       if(wcfUtil.selectedMailMap.containsKey(currString) && isFirstParent == true && wcfUtil.SignNowName == currString ){
                           if(recipients != '')
                               recipients = recipients + ',';
                           recipients = recipients + '{'+
                               '      "email": "NotSent@NoEmail.com",'+
                               '      "name": "'+currString +'",'+
                               '      "recipientId":"'+i+'",'+
                               '      "clientUserId":"'+i+'",'+
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
                           
                           if(!wcfUtil.signersKeyPairMap.containsKey(currString ))
                               wcfUtil.signersKeyPairMap.put(currString,String.valueof(i));
                           isFirstParent = false;
                       }
                       
                       else{
                           if(recipients != '')
                               recipients = recipients + ',';
                           recipients = recipients + '{'+
                               '      "email": "NotSent@NoEmail.com",'+
                               '      "name": "'+currString+'",'+
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
                           
                           if(!wcfUtil.signersKeyPairMap.containsKey(currString))
                               wcfUtil.signersKeyPairMap.put(currString,String.valueof(i));
                       }
                       i++;
                   }
                   
                   //forming payload with the document and recipients.
                   String body =  '{'+
                       '  "status":"sent",'+
                       '  "enableWetSign": "false",'+
                       '  "emailBlurb":"Wish Form & Liability And Publicity Release Form",'+
                       '  "emailSubject": "Signature Required - Wish Form & Liability And Publicity Release Form",'+
                       '  "enforceSignerVisibility":"True",'+
                       '  "documents": [{'+
                       '      "name": "document.pdf",'+
                       '      "documentId":"1",'+
                       '      "order":"1",'+
                       '      "documentBase64":"'+wcfUtil.documentPDF+'"'+
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
                   //try{
                   if(recipients != ''){
                       Logvalue = String.valueOf(req);
                       res = http.send(req);
                       system.debug(res.getBody());
                      if(res.getstatusCode() != 200 && res.getstatusCode() != 201){
                        new ApexDebugLog().createLog(new ApexDebugLog.Error('WishChildForm_AC','SubmitAndSign',currCase.id,null,res.getBody()));
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
                        ApexPages.addMessage(myMsg);
                        return null;
                    }
                       //Docusign status record creation.
                       else{
                       Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                       if((String) results.get('envelopeId') != '')
                           wcfUtil.envelopeId = (String) results.get('envelopeId');
                       if((String) results.get('status') == 'Sent'){
                           status = 'Agreement sent to email.';
                           dsfs__DocuSign_Status__c dsfs= NEW dsfs__DocuSign_Status__c();
                           dsfs.dsfs__DocuSign_Envelope_ID__c = (String) results.get('envelopeId');
                           dsfs.dsfs__Case__c= currCase.id;
                           dsfsList.add(dsfs);
                           
                       }else
                           status = (String) results.get('errorCode');
                     }
                   }
                   // }catch(Exception e){
                   //}
                   
               }
            else{
                if(dbcase.Envelop_Id__c != Null && dbcase.Hidden_Envelop_Id_1__c  == Null && dbcase.Hidden_Envelop_Id_2__c == Null && j == 0){
                    wcfUtil.envelopeId = dbcase.Envelop_Id__c;
                    for(String key : dbcase.SignerMapKeyPair__c.split('#')){
                        String keys = key.split('-')[0];
                        String value = key.split('-')[1];
                        wcfUtil.signersKeyPairMap.put(keys.trim(),value.trim());
                    } 
                }
                if(dbcase.Envelop_Id__c != Null && dbcase.Hidden_Envelop_Id_1__c  != Null && dbcase.Hidden_Envelop_Id_2__c == Null ){
                    wcfUtil.envelopeId = dbcase.Hidden_Envelop_Id_1__c;
                    for(String key : dbcase.Hidden_SignerMap_Key_1__c.split('#')){
                        String keys = key.split('-')[0];
                        String value = key.split('-')[1];
                        wcfUtil.signersKeyPairMap.put(keys.trim(),value.trim());
                    } 
                }
                if(dbcase.Envelop_Id__c != Null && dbcase.Hidden_Envelop_Id_1__c  != Null && dbcase.Hidden_Envelop_Id_2__c != Null ){
                    wcfUtil.envelopeId = dbcase.Hidden_Envelop_Id_2__c;
                    for(String key : dbcase.Hidden_SignerMap_Key_2__c.split('#')){
                        String keys = key.split('-')[0];
                        String value = key.split('-')[1];
                        wcfUtil.signersKeyPairMap.put(keys.trim(),value.trim());
                    }
                }
                
                if(dbcase.Envelop_Id__c != Null && dbcase.Hidden_Envelop_Id_1__c  != Null && dbcase.Hidden_Envelop_Id_2__c != Null && dbcase.Hidden_Envelop_Id_3__c != Null){
                    wcfUtil.envelopeId = dbcase.Hidden_Envelop_Id_3__c;
                    for(String key : dbcase.Hidden_SignerMap_Key_3__c.split('#')){
                        String keys = key.split('-')[0];
                        String value = key.split('-')[1];
                        wcfUtil.signersKeyPairMap.put(keys.trim(),value.trim());
                    }
                }
            }
            if(displaypopwindow == false){
                endpoint += '/'+ wcfUtil.envelopeId+'/views/recipient';
                HttpRequest request = new HttpRequest();
                request.setHeader('X-DocuSign-Authentication', authorizationHeader);
                request.setHeader('Accept','application/json');
                request.setHeader('Host','demo.docusign.net');
                request.setHeader('Content-Length','162100');
                request.setHeader('Content-Type','application/json');
                request.setMethod('POST'); 
                Http httprequest = new Http();
                HTTPResponse response;
                request.setEndpoint(endpoint);
                string jsonPayload;
                system.debug('URL.getSalesforceBaseUrl().toExternalForm()'+URL.getSalesforceBaseUrl().toExternalForm());
                String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
                jsonPayload = '{'+
                    '    "userName": "'+wcfUtil.SignNowName+'",'+
                    '    "email": "NotSent@NoEmail.com",'+
                    '    "recipientId": "'+wcfUtil.signersKeyPairMap.get(wcfUtil.SignNowName)+'",'+
                    '    "clientUserId": "'+wcfUtil.signersKeyPairMap.get(wcfUtil.SignNowName)+'",'+
                    '    "authenticationMethod": "None",'+
                    '   "returnUrl": "'+baseUrl +'/apex/WishInformationForm_VF?Id='+currCase.id+'"'+   
                    '}'; 
                request.setBody(jsonPayload);
                Logvalue = String.valueOf(request);
                response = httprequest.send(request);  
                system.debug(response.getBody());
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                //signersKeyPairMap.remove(SignNowName);
                String sign;
                for(String name : wcfUtil.signersKeyPairMap.KeySet()){
                    if(sign == '' || sign == Null)
                        sign= name +' - '+ wcfUtil.signersKeyPairMap.get(name);
                    else
                        sign = sign +'#'+ name +' - '+ wcfUtil.signersKeyPairMap.get(name);
                }
                if(dbcase.SignerMapKeyPair__c == Null && dbcase.Envelop_Id__c == Null &&
                   dbcase.Hidden_SignerMap_Key_1__c == Null && dbcase.Hidden_Envelop_Id_1__c == Null && dbcase.Hidden_Envelop_Id_2__c == Null && dbcase.Hidden_SignerMap_Key_2__c == Null){
                       Wish_Child_Form__c newCase = new Wish_Child_Form__c();
                       newCase.Id = dbcase.id;
                       newCase.SignerMapKeyPair__c = sign;
                       newCase.Envelop_Id__c = wcfUtil.envelopeId;
                       Logvalue = String.valueOf(newCase);
                       recId = newCase.Id; 
                       update newCase;
                   }
                if(dbcase.SignerMapKeyPair__c != Null && dbcase.Envelop_Id__c != Null && dbcase.Hidden_SignerMap_Key_1__c == Null && dbcase.Hidden_Envelop_Id_1__c == Null
                   && dbcase.Hidden_Envelop_Id_2__c == Null && dbcase.Hidden_SignerMap_Key_2__c == Null && j == 1 && k == 0){
                       Wish_Child_Form__c newCase = new Wish_Child_Form__c();
                       newCase.Id = dbcase.id;
                       newCase.Hidden_SignerMap_Key_1__c = sign;
                       newCase.Hidden_Envelop_Id_1__c = wcfUtil.envelopeId;
                       Logvalue = String.valueOf(newCase);
                       recId = newCase.Id; 
                       update newCase;
                   }
                if(dbcase.SignerMapKeyPair__c != Null && dbcase.Envelop_Id__c != Null && dbcase.Hidden_Envelop_Id_2__c == Null && dbcase.Hidden_SignerMap_Key_2__c == Null &&
                   dbcase.Hidden_SignerMap_Key_1__c != Null && dbcase.Hidden_Envelop_Id_1__c != Null && j == 2 && k == 1){
                       Wish_Child_Form__c newCase = new Wish_Child_Form__c();
                       newCase.Id = dbcase.id;
                       newCase.Hidden_SignerMap_Key_2__c = sign;
                       newCase.Hidden_Envelop_Id_2__c = wcfUtil.envelopeId;
                       Logvalue = String.valueOf(newCase);
                       recId = newCase.Id;
                       update newCase;
                   }
                if(dbcase.SignerMapKeyPair__c != Null && dbcase.Envelop_Id__c != Null && dbcase.Hidden_Envelop_Id_2__c != Null && dbcase.Hidden_SignerMap_Key_2__c != Null &&
                   dbcase.Hidden_SignerMap_Key_1__c != Null && dbcase.Hidden_Envelop_Id_1__c != Null && dbcase.Hidden_Envelop_Id_3__c != Null && dbcase.Hidden_SignerMap_Key_3__c != Null && j == 3 && k == 2){
                       Wish_Child_Form__c newCase = new Wish_Child_Form__c();
                       newCase.Id = dbcase.id;
                       newCase.Hidden_SignerMap_Key_3__c = sign;
                       newCase.Hidden_Envelop_Id_3__c = wcfUtil.envelopeId;
                       Logvalue = String.valueOf(newCase);
                       recId = newCase.Id; 
                       update newCase;
                   }
                if(dsfsList.size() > 0){
                    Logvalue = String.ValueOf(dsfsList);
                    recId = Null; 
                    Insert dsfsList;
                }
                reference=new PageReference((String) results.get('url'));
                reference.setRedirect(true);
            }
            return reference;
        }
        Catch(DMLException e)
        {            
            new ApexDebugLog().createLog(new ApexDebugLog.Error('WishChildForm_AC','SubmitAndSign',recId,e,Logvalue)); 
            displayErrorMessage(e);
            return null;
        }
        
    }

    
    /****************************************************************************************************
This BackToWFF() is used to redirect the user into wishFamily form and save the current page details.
*****************************************************************************************************/
    public pageReference BackToWFF() {
        String Logvalue;
        try
        {  
           
            WishInfoSave();
            PageReference reference=new PageReference('/apex/WishFamilyForm_VF?id='+this.currCase.id);
            reference.setRedirect(true);     
            return reference;
            
        }
        Catch(DMLException e)
        {   //showException = true;
            new ApexDebugLog().createLog(new ApexDebugLog.Error('WishChildForm_AC','BackToWFF',currCase.id,e,Logvalue)); 
            displayErrorMessage(e);
        }
        return null;
       
    } 
    
    /****************************************************************************************************
This WishInfoSave() is used to redirect the user into wish information form and save the current page details.
*****************************************************************************************************/
    public PageReference WishInfoSave(){
        String Logvalue;
        try
        {
            
            wcfUtil.isInformation = True;
            saveContact();
            PageReference  reference=new PageReference('/apex/WishInformationForm_VF?id='+currcase.Id+'&part='+isParticipants);
            reference.setRedirect(true);     
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.CONFIRM,'You Have Successfully Saved Your Information');
            ApexPages.addMessage(myMsg);
            return reference;
            
        }
        Catch(DMLException e)
        {   
            //showException = true;
            new ApexDebugLog().createLog(new ApexDebugLog.Error('WishChildForm_AC','WishInfoSave',Null,e,Logvalue));  
            displayErrorMessage(e);
        }
        return null;
    }
    
    /****************************************************************************************************
This submitforApproval() is used to send the wish form to approval process. Once chapter staff approved
the changes are updated into corresponding records.
*****************************************************************************************************/
    public pagereference submitforApproval(){
        boolean isApproval;
        PageReference reference;        
        String Logvalue;
        try{
            
            List<ProcessInstance> approvalIns =  [SELECT TargetObjectId,Status,ProcessDefinitionId,ProcessDefinition.Name FROM ProcessInstance WHERE TargetObjectId =: currCase.id AND Status =: 'Pending' limit 50000];
            If(approvalIns.size() > 0){
                isApproval = true;
            }
            else{
                wcfUtil.isInformation = True;
                saveContact();
                case updateParentCase = new Case();
                updateParentCase.Id = currCase.id;
                updateParentCase.Wish_Family_Form_Submitted__c = true;
                Logvalue = String.valueOf(updateParentCase);
                update updateParentCase ;
                
                //String chapterName = currCase.ChapterName__r.Name;
                //String queueName = chapterName.substringAfter('Make-A-Wish ');
                //Group approvarQueue = [SELECT Id,Name FROM Group WHERE Type = 'Queue' AND Name =: queueName LIMIT 1];
                
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments('Submitting request for approval.');
                req.setObjectId(currCase.id);
                req.setProcessDefinitionNameOrId('Wish_Child_Form_Approval_Process');
                req.setSkipEntryCriteria(true);
                //req.setNextApproverIds(new Id[]{approvarQueue.Id});
                Logvalue = String.valueOf(req);
                Approval.ProcessResult result = Approval.process(req);
            }
            reference=new PageReference('/'+currCase.id);
            reference.setRedirect(true);     
            return reference;
        }
        catch(Exception e){          
            new ApexDebugLog().createLog(new ApexDebugLog.Error('WishChildForm_AC','submitforApproval',currCase.id,e,Logvalue));
            e.setMessage(Label.Debug_log_error_message);
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
            ApexPages.addMessage(myMsg);
            return null; 
        }  
    }
    
    /****************************************************************************************************
This generatePDF() is used to generate the pdf file which contains the wish child, wish family and wish
information form.
*****************************************************************************************************/ 
    public pagereference generatePDF(){
        String Logvalue;
        try{
            String pageName = ApexPages.currentPage().getUrl().substringBetween('apex/', '?');
            if(pageName == 'WishChildForm_VF'){
                saveContact();
            }
            if(pageName == 'WishFamilyForm_VF'){
                saveContact();
            }
            if(pageName == 'WishInformationForm_VF'){
                WishInfoSave();
            }
            
            PageReference reference=new PageReference('/apex/WishFormDownloadPDF?Id='+currCase.id+'&force_download=true');
            reference.setRedirect(true);     
            return reference;
            
        }
        catch(Exception e){
            //showException = true;
            new ApexDebugLog().createLog(new ApexDebugLog.Error('WishChildForm_AC','generatePDF',Null,e,Logvalue));
            displayErrorMessage(e);
        }
        return null;
    }
    
    /****************************************************************************************************
This searchCaseFile() is used to query the case file and return the list of case file records.
information form.
*****************************************************************************************************/ 
    @RemoteAction
    public static Boolean searchCaseFile(String contId) {
        String Logvalue;
       
            List<cg__CaseFile__c> caseFileList = [SELECT id,cg__Case__c FROM cg__CaseFile__c WHERE cg__Case__c =:contId AND cg__Content_Type__c != 'Folder' limit 50000];
            if(caseFileList.size() > 0) {
                return false;
            } else {
                return true;
            }
       } 
    /****************************************************************************************************
This multiEmail() is used query the list of parent legual gurdian name and email who are all going to
sign the wish form
*****************************************************************************************************/ 
    public pageReference multiEmail(){
        String Logvalue;
        try{
            if(currWishChild.IsParticipant__c != true){
                wcfUtil.isInformation = True;
                saveContact();
                if(currWishChild.Emergency_Relationship__c != Null && currWishChild.Emergency_First_Name__c != Null && currWishChild.Emergency_Last_Name__c != Null && currWishChild.Emergency_Mobilephone__c != Null && currWishChild.Hidden_Wish_Fmaily_Contact_Email__c != Null && currWishChild.Wish_Family_Contact__c != Null)
                {
                    if(wcfUtil.emailMap.size() > 0){
                        wcfUtil.multiPickoptions = new List<SelectOption>();
                        Set<String> nameSet = new Set<String>();
                        Map<String,String> processedNameMap = new Map<String,String>();
                        for(Wish_Child_Form__c wishChildForm : [SELECT Id,Name,Case__c,Hidden_Contact_Name__c,Hidden_Wish_Fmaily_Contact_Email__c,Hidden_Wish_Fmaily_Contact_Name__c FROM Wish_Child_Form__c WHERE
                                                                Case__c =: currCase.id]){
                                                                    if(wishChildForm.Hidden_Contact_Name__c != Null) {                                     
                                                                        for(String keys : wishChildForm.Hidden_Contact_Name__c.split('#')){
                                                                            nameSet.add(keys.trim());
                                                                        } 
                                                                    }
                                                                }
                        
                        Wish_Child_Form__c wishChildForm = [SELECT Id,Name,Case__c,Hidden_Contact_Name__c,Hidden_Wish_Fmaily_Contact_Email__c,Hidden_Wish_Fmaily_Contact_Name__c FROM Wish_Child_Form__c WHERE
                                                            Case__c =: currCase.id];
                        for(String key : wishChildForm.Hidden_Wish_Fmaily_Contact_Email__c.split('#')){
                            String keys = key.split('::')[0];
                            String value = key.split('::')[1];
                            processedNameMap.put(keys.trim(),value);
                        } 
                        if(processedNameMap.size() > 0){
                            for(String name : processedNameMap.KeySet()){
                                if(!nameSet.contains(name)){
                                    if(wcfUtil.selectedMailMap.containsKey(name)){
                                        wcfUtil.selectedMailMap.put(name,processedNameMap.get(name));
                                    }
                                    else
                                        wcfUtil.selectedMailMap.put(name,processedNameMap.get(name));
                                }
                            }
                        }
                        for(String currString : wcfUtil.selectedMailMap.keySet()){
                            wcfUtil.multiPickoptions.add(new SelectOption(currString,currString ));
                        }
                        if(wcfUtil.selectedMailMap.size() > 0){
                            wcfUtil.displayPopup = true;
                        }         
                    }
                    else{
                        wcfUtil.displayError = true;
                        
                    }
                }
            }
        }
        catch(Exception e){
            //showException = true;
            new ApexDebugLog().createLog(new ApexDebugLog.Error('WishChildForm_AC','multiEmail',Null,e,Logvalue));
            displayErrorMessage(e);
        }
        return null;
    }
    
    
    /****************************************************************************************************
This multiEmail() is used display the list of parent legual gurdian name and email who are all going to
sign the wish form
*****************************************************************************************************/ 
    public pageReference sendpdftoEmail (){
        wcfUtil.displayPopup = false;
        Set<String> senderNameSet = new Set<String>();
        
            for(String processEmailList :wcfUtil.emailList ){
                if(senderNameSet.contains(processEmailList )){
                    processEmailList = processEmailList+' ';
                    senderNameSet.add(processEmailList);
                }
                senderNameSet.add(processEmailList);
            }
            for(String currString : wcfUtil.selectedMailMap.keySet()){
                if(senderNameset.Contains(currString)){
                    wcfUtil.sendEmailMap.put(currString,wcfUtil.selectedMailMap.get(currString));
                    
                }
            }
            if((!wcfUtil.sendEmailMap.isEmpty()) && wcfUtil.sendEmailMap.size() > 0 ){
                for(String currString : wcfUtil.sendEmailMap.KeySet()){
                    if(wcfUtil.querySignature==null)
                        wcfUtil.querySignature = currString;
                    else
                        wcfUtil.querySignature = wcfUtil.querySignature + '#' +currString;
                }
            }
            if(wcfUtil.sendEmailMap.size() > 0){    
                callouttoDocusing(wcfUtil.sendEmailMap,CurrCase.id,wcfUtil.wishChildId );
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm,'An email has been sent successfully'));
            }
            PageReference acctPage = new PageReference ('/apex/WishInformationForm_VF?id='+currCase.id+'&part='+isParticipants);
            acctPage.setRedirect(true);
            return acctPage; 
        
    }
    
    /****************************************************************************************************
This callouttoDocusing() is used initiate the call out to docusign to send an email to sign the wish
form.
*****************************************************************************************************/ 
    @Future(callout=true)
    public static void callouttoDocusing(map<String,String> sendEmailMap,String caseId,Id wishChildId ){
        System.debug('>>>>sendEmailMap>>'+sendEmailMap);
        String Logvalue;
        List<Contact> relationShipList = new List<Contact>();
        List<Case> wishChildContact;
        String recId;
            try{
            wishChildContact = [SELECT Id, Contact.FirstName FROM Case WHERE Id =: caseId];
            String childFirstName = '';
       
            if(wishChildContact.size() > 0) {
                childFirstName = wishChildContact[0].Contact.FirstName;
            }
            
            Pagereference PDF = Page.SendPDF;
            String documentPDF;
            PDF.setRedirect(false);
            PDF.getParameters().put('Id',caseId);
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
            boolean isFirstParent = True;
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
            for(String currString : sendEmailMap.KeySet()){
                Name = currString;
                email = sendEmailMap.get(currString);
                system.debug('@@@@ Name Send @@@@'+Name);
                system.debug('@@@@ email Send @@@@'+email);
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
            //forming payload with the document and recipients.
            String body =  '{'+
                '  "status":"sent",'+
                '  "enableWetSign": "false",'+
                '  "emailBlurb":"Hello,'+'\r\n\n Please sign the attached Wish Form and Liability and Publicity Release Form necessary for '+ childFirstName +'\'s wish. \r\n\nThank You,\r\n Wish & Volunteer Center",'+
                '  "emailSubject": "Signature Required - Wish Form & Liability And Publicity Release Form",'+
                '  "enforceSignerVisibility":"True",'+
                '  "documents": [{'+
                '      "name": "document.pdf",'+
                '      "documentId":"1",'+
                '      "order":"1",'+
                '      "documentBase64":"'+documentPDF+'"'+
                '  }],'+
                '"notification":{'+
                '"useAccountDefaults":"false",'+
                '"reminders":{'+
                '"reminderEnabled":"true",'+
                '"reminderDelay":"1",'+
                '"reminderFrequency":"1"'+
                '},'+
                '"expirations":{'+
                '"expireEnabled":"true",'+
                '"expireAfter":"10",'+
                '"expireWarn":"7"'+
                '}'+
                ' },'+
                '"recipients": {'+
                '    "signers" : ['+recipients+']'+
                ' }'+
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
            system.debug('reqbodyLog'+req.getBody());
            Http http = new Http();
            HTTPResponse res;
            
            if(recipients != '')
            {
                Logvalue = String.valueOf(req);
                res = http.send(req);
                system.debug('@@ systemdebug @@'+res.getstatusCode());
                //Docusign status record creation.
                if(res.getstatusCode() != 200 && res.getstatusCode() != 201){
                    new ApexDebugLog().createLog(new ApexDebugLog.Error('WishChildForm_AC','callouttoDocusing',caseId,null,res.getBody()));
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
                    ApexPages.addMessage(myMsg);
                    //return null;
                }
                
                else{
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                if((String) results.get('status') == 'Sent'){
                    status = 'Agreement sent to email.';
                    dsfs__DocuSign_Status__c dsfs= NEW dsfs__DocuSign_Status__c();
                    dsfs.dsfs__DocuSign_Envelope_ID__c = (String) results.get('envelopeId');
                    dsfs.dsfs__Case__c= caseId;
                    Logvalue = String.valueOf(dsfs);
                    Insert dsfs;
                }else
                    status = (String) results.get('errorCode');
                }
            }
        }
        catch(Exception e){
            new ApexDebugLog().createLog(new ApexDebugLog.Error('WishChildForm_AC','callouttoDocusing',Null,e,Logvalue));
            e.setMessage(Label.Debug_log_error_message);
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
            ApexPages.addMessage(myMsg);
        }    
    }
    
    /*********************************************************************
This WishInfoWithSave() is used to save the wish information form.
**********************************************************************/
    public void WishInfoWithSave(){
        String Logvalue;
        try
        {
            wcfUtil.isInformation = True;
            saveContact();
        } 
        Catch(Exception e)
        {   //showException = true;
            new ApexDebugLog().createLog(new ApexDebugLog.Error('WishChildForm_AC','WishInfoWithSave',Null,e,Logvalue));
            displayErrorMessage(e);
        }
    }
    
    /****************************************************************************************************
This forceDownloadPDF() is used to save the current page and download the entire wish form
*****************************************************************************************************/   
    public void forceDownloadPDF(){
        String pageName = ApexPages.currentPage().getUrl().substringBetween('apex/', '?');
        String Logvalue;
        try{
            if(pageName == 'WishChildForm_VF'){
                saveContact();
            }
            if(pageName == 'WishFamilyForm_VF'){
                saveContact();
            }
            if(pageName == 'WishInformationForm_VF'){
                WishInfoSave();
            }
            
           
            if(ApexPages.currentPage().getParameters().get('force_download') != null && ApexPages.currentPage().getParameters().get('force_download') == 'true') 
            {
                string fileName = 'Wish Forms'+date.today()+'.pdf';
                if(apexPages.currentPage().getParameters().get('filename') != null)
                {
                    fileName = apexPages.currentPage().getParameters().get('filename') +'.pdf';
                }
                Apexpages.currentPage().getHeaders().put('content-disposition', 'attachemnt; filename='+fileName);
            }
           
        }
        catch(Exception e){
            new ApexDebugLog().createLog(new ApexDebugLog.Error('WishChildForm_AC','forceDownloadPDF',Null,e,Logvalue));
            displayErrorMessage(e);
        }   
    }
    
    /***********
    ***********************************************************************************************
This DisplayApprovalProcess() is used to display the error message when the wish form is approval process
***********************************************************************************************************/
    public pageReference DisplayApprovalProcess(){
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,' This record is already in approval process'));
        return null;
    } 
    
    /**********************************************************************************************************
This getRaceEthnicity() is used to get the raceethnicity details values and displayed in wish family form.
***********************************************************************************************************/
    public List<SelectOption> getRaceEthnicity(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =  Wish_Child_Form__c.Race_Ethnicity__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        options.add(new SelectOption('', '')); 
        for( Schema.PicklistEntry currVal : picklistValues)
        {      
            options.add(new SelectOption(currVal.getLabel(), currVal.getValue())); 
        }  
        return options;
    }  
    
    /**********************************************************************************************************
This getRaceEthnicity() is used to get the raceethnicity details values and displayed in wish family form.
***********************************************************************************************************/
    public List<SelectOption> getDoesParticipantReqWheelchair(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','')); 
        
        for(String name : wcfUtil.leftWCNamesList){
            options.add(new SelectOption(name,name)); 
        }
        
        return options;
    }  
    
    /**********************************************************************************************************
This getWillYourFamilyBringWheelChair() is used to get the participant name from wish participant section
***********************************************************************************************************/
    public List<SelectOption>getWillYourFamilyBringWheelChair(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','')); 
        
        for(String name : wcfUtil.leftOwnWheelChairList){
            options.add(new SelectOption(name,name)); 
        }
        return options;
    } 
    
    /**********************************************************************************************************
This getWheelChairColapsable() is used to get the participant name from wish participant section
***********************************************************************************************************/
    public List<SelectOption>getWheelChairColapsable(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '')); 
        
        for(String name : wcfUtil.leftWCCollapsibleList){
            options.add(new SelectOption(name,name)); 
        }
        return options;
    } 
    
    /**********************************************************************************************************
This getwheelChairPower() is used to get the participant name from wish participant section
***********************************************************************************************************/
    public List<SelectOption>getwheelChairPower(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '')); 
        for(String name : wcfUtil.leftWCPowerList){
            options.add(new SelectOption(name,name)); 
        }
        
        return options;
    } 
    
    /**********************************************************************************************************
This getparticipantRequireOxygan() is used to get the participant name from wish participant section
***********************************************************************************************************/
    public List<SelectOption>getparticipantRequireOxygan(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '')); 
        for(String name : wcfUtil.leftOxygenNamesList){
            options.add(new SelectOption(name,name)); 
        }
        return options;
    } 
    
    /**********************************************************************************************************
This getparticipantHaveSpecialRestrictaion() is used to get the participant name from wish participant section
***********************************************************************************************************/
    public List<SelectOption>getparticipantHaveSpecialRestrictaion(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '')); 
        for(String name : wcfUtil.leftDietaryNameList){
            options.add(new SelectOption(name,name)); 
        }
        
        return options;
    } 
    
    /**********************************************************************************************************
This getparticipantHaveSpecialRestrictaion() is used to get the participant name from wish participant section
***********************************************************************************************************/
    public List<SelectOption>getparticipantHaveSpecialallergies(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '')); 
        
        for(String name : wcfUtil.leftNursingCareList){
            options.add(new SelectOption(name,name)); 
        }
        
        return options;
    } 
    
    /**********************************************************************************************************
This getmedicationRequireRefeigeration() is used to get the participant name from wish participant section
***********************************************************************************************************/
    public List<SelectOption>getmedicationRequireRefeigeration(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', ''));         
        
        for(String name : wcfUtil.leftMedicationList){
            options.add(new SelectOption(name,name)); 
        }
        return options;
    } 
    
    /**********************************************************************************************************
This getcurrentlyReceiveNursingCare() is used to get the participant name from wish participant section
***********************************************************************************************************/
    public List<SelectOption>getcurrentlyReceiveNursingCare(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '')); 
        for(String name : wcfUtil.leftAllergyNamesList){
            options.add(new SelectOption(name,name)); 
        }
        
        return options;
    } 
    
    /**********************************************************************************************************
This getanyOtherMedicalSupplies() is used to get the participant name from wish participant section
***********************************************************************************************************/
    public List<SelectOption>getanyOtherMedicalSupplies(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '')); 
        
        for(String name : wcfUtil.leftOtherNeedsList){
            options.add(new SelectOption(name,name)); 
        }
        return options;
    } 
    
    /************************************************************************
This withOutNavigate() is used nevegate the user to corresponding form.
**************************************************************************/
    Public pageReference withOutNavigate(){
        pageReference reference;
        String Logvalue;
        String pageName = ApexPages.currentPage().getUrl().substringBetween('apex/', '?');
        try{
          
            if(pageName == 'WishChildForm_VF'){
                reference=new PageReference('/apex/WishChildForm_VF?id='+this.currCase.id);
                reference.setRedirect(true);  
            }
            if(pageName == 'WishFamilyForm_VF'){
                reference=new PageReference('/apex/WishFamilyForm_VF?id='+currCase.id+'&part='+isParticipants);
                reference.setRedirect(true); 
            }
            if(pageName == 'WishInformationForm_VF'){
                reference=new PageReference('/apex/WishInformationForm_VF?id='+currCase.id+'&part='+isParticipants);
                reference.setRedirect(true);  
            }
            
            return reference;
        }
        catch(Exception e){
            //showException  = true;
            new ApexDebugLog().createLog(new ApexDebugLog.Error('WishChildForm_AC','withOutNavigate',Null,e,Logvalue));
            displayErrorMessage(e);
        }
        return null;
    }
    
    /**********************************************************************************************************
This RetrunToWish() is used to is used nevegate the user to corresponding form.
**********************************************************************************************************/
    public pageReference RetrunToWish(){
        String Logvalue;
        pageReference reference;
        String pageName = ApexPages.currentPage().getUrl().substringBetween('apex/', '?');
        if(pageName == 'WishChildForm_VF'){
            saveContact();
        }
        if(pageName == 'WishFamilyForm_VF'){
            saveContact();
        }
        if(pageName == 'WishInformationForm_VF'){
            WishInfoSave();
        }
        system.debug('pageName'+pageName);
        reference=new PageReference('/'+currCase.id);
        reference.setRedirect(true);  
        return reference;
    }
    
    /**********************************************************************************************************
This selectedNamesss() is used to get the participant name from wish participant section
***********************************************************************************************************/
    Public String selectedNamesss(List<String> selectedNames)
    {
        Boolean start=True;
        String currString = '';
        String returnName;
        String returnSecondName;
        if(selectedNames != Null) {           
            for(String Str : selectedNames) {
                if(currString == '')
                    currString = str;
                else
                    currString +=','+str;
            }
        }
        return currString ;
    }
    
    /**********************************************************************************************************
This getTempName() is used to get the participant name from wish participant section
***********************************************************************************************************/
    public list<String> getTempName(){
        
        if(currWishChild.Requested_Participant_Name_forWheelchair__c != null){
            tempName = (currWishChild.Requested_Participant_Name_forWheelchair__c).split(',');                                  
        }
        return tempName;
    }
    
    /*******************************************************************************************
This setTempName() is used to display the participant name in medical information section.
********************************************************************************************/
    public void setTempName(list<string> val){
        this.tempName = val;
    }
    
    /**********************************************************************************************************
This getCurrentOwnWheelChairList() is used to get the participant name from wish participant section
***********************************************************************************************************/
    public list<String> getCurrentOwnWheelChairList(){
        
        if(currWishChild.Bringing_Own_Wheel_Chair__c != null){
            currentOwnWheelChairList = (currWishChild.Bringing_Own_Wheel_Chair__c).split(',');
        }
        return currentOwnWheelChairList;
    }
    
    /***************************************************************************************************************
This setCurrentOwnWheelChairList() is used to display the participant name in medical information section.
*****************************************************************************************************************/
    public void setCurrentOwnWheelChairList(list<string> val){
        this.currentOwnWheelChairList= val;
    }
    
    /**********************************************************************************************************
This getCurrentWCCollapsibleList() is used to get the participant name from wish participant section
***********************************************************************************************************/
    Public list<String> getCurrentWCCollapsibleList(){
        if(currWishChild.Name_of_wheelchair_collapsible__c != Null){
            currentWCCollapsibleList = (currWishChild.Name_of_wheelchair_collapsible__c).split(',');
        }
        return currentWCCollapsibleList;
    }
    
    /**********************************************************************************************************
This setCurrentWCCollapsibleList() is used to display the participant name in medical information section.
***********************************************************************************************************/
    public void setCurrentWCCollapsibleList(list<string> val){
        this.currentWCCollapsibleList = val;
    }
    
    /**********************************************************************************************************
This getCurrentWCPowerList() is used to get the participant name from wish participant section
***********************************************************************************************************/
    Public list<String> getCurrentWCPowerList(){
        if(currWishChild.Pariticipant_name_havingWheelchair_Power__c != Null){
            currentWCPowerList = (currWishChild.Pariticipant_name_havingWheelchair_Power__c).split(',');
        }
        return currentWCPowerList;
    }
    
    /**********************************************************************************************************
This setCurrentWCPowerList() is used to display the participant name in medical information section.
***********************************************************************************************************/
    public void setCurrentWCPowerList(list<string> val){
        this.currentWCPowerList = val;
    }
    
    /**********************************************************************************************************
This getCurrentOxygenNamesList() is used to get the participant name from wish participant section
***********************************************************************************************************/
    Public list<String> getCurrentOxygenNamesList(){
        if( currWishChild.Requested_Participant_Name_for_Oxygen__c != Null){
            currentOxygenNamesList = ( currWishChild.Requested_Participant_Name_for_Oxygen__c).split(',');
        }
        return currentOxygenNamesList;
    }
    
    /**********************************************************************************************************
This setCurrentOxygenNamesList() is used to display the participant name in medical information section.
***********************************************************************************************************/
    public void setCurrentOxygenNamesList(list<string> val){
        this.currentOxygenNamesList = val;
    }
    
    /**********************************************************************************************************
This getCurrrentDietaryNameList() is used to display the participant name in medical information section.
***********************************************************************************************************/
    Public list<String> getCurrrentDietaryNameList(){
        if(currWishChild.Participant_Name_for_Dietary_Restriction__c != Null){
            currrentDietaryNameList = (currWishChild.Participant_Name_for_Dietary_Restriction__c).split(',');
        }
        return currrentDietaryNameList;
    }
    
    /**********************************************************************************************************
This setCurrrentDietaryNameList() is used to display the participant name in medical information section.
***********************************************************************************************************/
    public void setCurrrentDietaryNameList(list<string> val){
        this.currrentDietaryNameList= val;
    }
    
    /**********************************************************************************************************
This getCurrentNursingCareList() is used to display the participant name in medical information section.
***********************************************************************************************************/
    
    Public list<String> getCurrentNursingCareList(){
        if(currWishChild.Names_for_receiving_nursing_care__c != Null){
            currentNursingCareList = (currWishChild.Names_for_receiving_nursing_care__c).split(',');
        }
        return currentNursingCareList;
    }
    
    /**********************************************************************************************************
This setCurrentNursingCareList() is used to display the participant name in medical information section.
***********************************************************************************************************/
    public void setCurrentNursingCareList(list<string> val){
        this.currentNursingCareList = val;
    }
    
    /**********************************************************************************************************
This getCurrentMedicationList() is used to display the participant name in medical information section.
***********************************************************************************************************/
    Public list<String> getCurrentMedicationList(){
        if(currWishChild.Medication_require_refrigeration_name__c != Null){
            currentMedicationList = (currWishChild.Medication_require_refrigeration_name__c).split(',');
        }
        return currentMedicationList;
    }
    
    /**********************************************************************************************************
This setCurrentMedicationList() is used to display the participant name in medical information section.
***********************************************************************************************************/
    public void setCurrentMedicationList(list<string> val){
        this.currentMedicationList = val;
    }
    
    /**********************************************************************************************************
This getCurrentAllergyNamesList() is used to display the participant name in medical information section.
***********************************************************************************************************/
    Public list<String> getCurrentAllergyNamesList(){
        if(currWishChild.Requested_Participant_Name_for_Allergies__c  != Null){
            currentAllergyNamesList = (currWishChild.Requested_Participant_Name_for_Allergies__c).split(',');
        }
        return currentAllergyNamesList;
    }
    
    /**********************************************************************************************************
This setCurrentAllergyNamesList() is used to display the participant name in medical information section.
***********************************************************************************************************/
    public void setCurrentAllergyNamesList(list<string> val){
        this.currentAllergyNamesList = val;
    }
    
    /**********************************************************************************************************
This getCurrentOtherNeedsList() is used to display the participant name in medical information section.
***********************************************************************************************************/
    Public list<String> getCurrentOtherNeedsList(){
        if(currWishChild.Requested_Participant_Name_for_OtherNeed__c  != Null){
            currentOtherNeedsList = (currWishChild.Requested_Participant_Name_for_OtherNeed__c ).split(',');
        }
        return currentOtherNeedsList;
    }
    
    /**********************************************************************************************************
This setCurrentOtherNeedsList() is used to display the participant name in medical information section.
***********************************************************************************************************/
    public void setCurrentOtherNeedsList(list<string> val){
        this.CurrentOtherNeedsList = val;
    }
    
    /*****************************************************************************************************
It redirect to the File  Upload page when the wish fomr in Submit for approval Process.
******************************************************************************************************/
    public pageReference UploadFile(){       
        pageReference reference;
        reference = new PageReference('/apex/WishFormAttachments_VF?id='+currCase.Id);
        reference.setRedirect(true);
        return reference;
    }
    
    public List<cg__CaseFile__c> getAttachments() {
        attachmentList = [select Id, File_Path__c,cg__Description__c, cg__Case__c, cg__File_Name__c from cg__CaseFile__c where cg__Case__c =: recId AND cg__Parent_Folder_Id__c != Null LIMIT 50000];
        return attachmentList;
    }
    //Used to save new attachment theat attached from Wish child form
    public void saveAttachment() {
        if (newAttachment.Body!=null) {
            newAttachment.parentId = recId;
            insert newAttachment;  
            attachmentList.clear();
            // attachmentList = [select Id, File_Path__c,cg__Description__c, cg__Case__c, cg__File_Name__c from cg__CaseFile__c where cg__Case__c =: recId AND cg__Parent_Folder_Id__c != Null order by Name desc];                   
            newAttachment = new Attachment();
            sucess = True;
        }
    }
    
    //Used to refresh the block
    public PageReference refresh() {
        PageReference redirect = new PageReference('/apex/WishFormAttachments_VF?id='+recId);
        redirect.setRedirect(true);
        return redirect;
    }
    
    //Used to delete the attachment from wish child form
    public PageReference removeAttachment() {
        system.debug('attachmentId'+attachmentId);
        List<cg__CaseFile__c> attachmentToBeDeleted = [SELECT Id FROM cg__CaseFile__c WHERE Id =: attachmentId LIMIT 50000 ];
        if(attachmentToBeDeleted.size() > 0) {
            try{
                delete attachmentToBeDeleted;  
                PageReference redirect = new PageReference('/apex/WishFormAttachments_VF?id='+recId); 
                redirect.setRedirect(true);
                return redirect; 
            }
            Catch(Exception e){
                String Logvalue = String.valueof(attachmentToBeDeleted);
                new ApexDebugLog().createLog(new ApexDebugLog.Error('WishChildForm_AC','removeAttachment',recId,e,Logvalue)); 
                displayErrorMessage(e);
                return null;
            }            
        }
        
        return null;
    }
    
    // This method is used to display the error message when an exception has occured.
    Public Pagereference displayErrorMessage(Exception ex){
            ex.setMessage(Label.Debug_log_error_message);
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage());
            ApexPages.addMessage(myMsg);
            return null;
           
    }
}