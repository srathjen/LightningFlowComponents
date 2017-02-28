/*****************************************************************************
Created by: Vennila Paramasivam
Author : MST Solutions
CreateDate : 06/01/2016
Description : Creating Wish Child Details from Wish Determination Case detail page.
******************************************************************************/

public Class WishChildForm_AC{

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
     

  public WishChildForm_AC(Apexpages.StandardController controller){
    isChildPart = false ;
    isParticipants  = false;    
    if(wcfUtil == null)   
     wcfUtil = new WishChildFormUtil();
    
    currentPageId =  ApexPages.currentPage().getParameters().get('id');
    if(currentPageId != null){
        //List<ProcessInstance> approvalIns =  [SELECT TargetObjectId,Status,ProcessDefinitionId,ProcessDefinition.Name FROM ProcessInstance WHERE TargetObjectId =: currentPageId AND Status =: 'Pending' AND ProcessDefinition.Name =: 'Wish Child Form Approval Process'];
        
         List<ProcessInstanceWorkitem> approvalIns = [SELECT Id,ActorId,OriginalActorId,ProcessInstanceId,ProcessInstance.TargetObjectId,ProcessInstance.Status,ProcessInstance.ProcessDefinition.Name FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId =: currentPageId AND ProcessInstance.Status =: 'Pending' AND ProcessInstance.ProcessDefinition.Name =: 'Wish Child Form Approval Process'
                                                    AND ActorId !=: UserInfo.getUserId()];
       
        If(approvalIns.size() > 0){           
             wcfUtil.approvalError = true;
             DisplayApprovalProcess();
        }
        else{
            this.currCase = (Case)controller.getRecord();
            currWishChild = new Wish_Child_Form__c();  

            this.currCase = [SELECT id,Hidden_Email_List__c,ContactId,Contact.FirstName,Contact.LastName, Contact.Middle_Name__c,
                      Contact.Diagnosis__c , Contact.Email, Contact.MobilePhone, Contact.Gender__C,
                      Contact.BirthDate, Contact.T_Shirt_Size__c, Contact.MailingStreet,
                      Contact.MailingCity, Contact.MailingState, Contact.MailingPostalCode
                      FROM Case WHERE Id = :this.currCase.id limit 1];
        
           if(this.currCase.Hidden_Email_List__c != null){
                wcfUtil.listofSenderName = currCase.Hidden_Email_List__c.split(',');
                system.debug('@@@@@@@@@@@ listofSenderName  @@@@@@@@@@@@@@'+wcfUtil.listofSenderName );
            }
      
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
            for(Wish_Child_Form__c wishChildForm : [SELECT Id,Name,Case__c,Hidden_Same_as_Family__c,Hidden_Contact_Name__c,Hidden_Wish_Fmaily_Contact_Email__c,Hidden_Wish_Fmaily_Contact_Name__c FROM Wish_Child_Form__c WHERE
                                                           Case__c =: this.currCase.Id]){
                system.debug('%%%listofSenderName%%%% '+wishChildForm );                                   
                if(wishChildForm.Hidden_Wish_Fmaily_Contact_Name__c != null) {  
                    system.debug('%%%listofSenderName%%%% '+wishChildForm.Hidden_Wish_Fmaily_Contact_Name__c);                                                                  
                    for(String keys : wishChildForm.Hidden_Wish_Fmaily_Contact_Name__c.split(',')){
                       wcfUtil.SignNowList.add(keys.trim());                     
                       system.debug('%%%listofSenderName%%%%'+wcfUtil.SignNowList);                                   
                    }                  
                }
                //setting same as family from table
                if( wishChildForm.Hidden_Same_as_Family__c ){
                   wcfUtil.sameParentGuardian = true;
                }else{
                    wcfUtil.sameParentGuardian = false;
                }
           }
    
           if(wcfUtil.wishChildList.size() == 0){          
                init(); 
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
                    
                    JsonString = jsonString.replace('&quot;', '"');
                    System.debug('WishChildFormUtil.jsonString : @@@@@@ '+jsonString );
                    List<WishChildFormUtil.WrapperClass> wrapFamilyList = (List<WishChildFormUtil.WrapperClass>) System.JSON.deserialize(jsonString, List<WishChildFormUtil.WrapperClass>.class);
                    System.debug('WishChildFormUtil.WrapperClass: @@@@@@ '+wrapFamilyList);
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
                        wrapCls.sameParentGuardianFlag = false;                         
                        wcfUtil.emailMap.put((wrapCls.FirstName+' '+wrapCls.LastName),wrapCls.Email);
                        wrapCls.dob=  (currRec.dob);
                        wrapCls.relId = currRec.relId;
                        wcfUtil.wishFamilyWrapList.add(wrapCls);
                    }
                }
                if(currWishChild.Driver_Details__c != null){
                    String jsonString = currWishChild.Driver_Details__c;
                    JsonString = jsonString.replace('&quot;', '"');
                    List<WishChildFormUtil.DriverWrapper> wrapDriverList = (List<WishChildFormUtil.DriverWrapper>) System.JSON.deserialize(jsonString, List<WishChildFormUtil.DriverWrapper>.class);
                    System.debug('WishChildFormUtil.wrapDriverList: '+wrapDriverList);
                    for(WishChildFormUtil.DriverWrapper currRec : wrapDriverList){
                          WishChildFormUtil.DriverWrapper wrapCls = new WishChildFormUtil.DriverWrapper();
                          wrapCls.driverName  = (currRec.driverName!=Null)?currRec.driverName :'';
                          wrapCls.licenseNum  = (currRec.licenseNum !=Null)?currRec.licenseNum :'';
                          wrapCls.state  = (currRec.state !=Null)?currRec.state :'';
                          wrapCls.expirationDate  = (currRec.expirationDate!=Null)?Date.valueOf(currRec.expirationDate):Null;
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
                 System.debug('####################'+currWishChild.Participant_Name_for_Dietary_Restriction__c);
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
                
               // Wish Participants Parser---------------------------------------------  
                if(currWishChild.Participant_Contacts__c != null){  
                    String jsonString = currWishChild.Participant_Contacts__c;
                    JsonString = jsonString.replace('&quot;', '"');
                    List<WishChildFormUtil.WrapperClass> wrapParticipantsList = (List<WishChildFormUtil.WrapperClass>) System.JSON.deserialize(jsonString, List<WishChildFormUtil.WrapperClass>.class);
                    System.debug('******jsonString:***** '+jsonString);             
                    List<Case> childAsPartList = [SELECT Contact.FirstName,Contact.LastName,Contact.Middle_Name__c,Contact.Email, Contact.MobilePhone,Contact.BirthDate, Contact.T_Shirt_Size__c FROM Case WHERE Id =: this.currCase.id limit 1 ] ;        
                                    
                    Integer count = 0;
                    for( Case childCase : childAsPartList){    
                        isChildPart = true;
                        WishChildFormUtil.WrapperClass childParticipantsWrap;
                        if(childParticipantsWrap == null){
                            childParticipantsWrap  = new WishChildFormUtil.WrapperClass();
                        }
                        childParticipantsWrap.firstName = childCase.Contact.FirstName;
                        childParticipantsWrap.LastName = childCase.Contact.LastName;
                        childParticipantsWrap.MiddleName = childCase.Contact.Middle_Name__c;               
                        childParticipantsWrap.Email = childCase.Contact.Email;   
                        childParticipantsWrap.dob = childCase.Contact.BirthDate;   
                        childParticipantsWrap.tshirtSize = childCase.Contact.T_Shirt_Size__c; 
                        childParticipantsWrap.isChildParticipants = isChildPart ; 
                        childParticipantsWrap.sameParentGuardianFlag = false;
                        childParticipantsWrap.Relationship = 'Self';
                        wrapParticipantsList.add(childParticipantsWrap);     
                        System.debug('New childParticipantsWrap');
                        if(count != 1 && wrapParticipantsList.get(wrapParticipantsList.size() - 1).FirstName == childCase.Contact.FirstName 
                        && wrapParticipantsList.get(wrapParticipantsList.size() - 1).LastName == childCase.Contact.LastName 
                        && wrapParticipantsList.get(wrapParticipantsList.size() - 1).MiddleName == childCase.Contact.Middle_Name__c 
                        && wrapParticipantsList.get(wrapParticipantsList.size() - 1).Email == childCase.Contact.Email 
                        && wrapParticipantsList.get(wrapParticipantsList.size() - 1).dob == childCase.Contact.BirthDate)
                        {  
                            wrapParticipantsList.remove(wrapParticipantsList.size() - 1);   
                        }
                        count = count + 1;
                    }              
                    ParticipantsMapping(wrapParticipantsList,false);  
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

  public void init(){
     currWishChild.FirstName__c =  currCase.Contact.FirstName;
     currWishChild.LastName__c  =  currCase.Contact.LastName;
     currWishChild.Middle_Name__c =  CurrCase.Contact.Middle_Name__c;
     currWishChild.BirthDate__c = currCase.Contact.BirthDate;
     currWishChild.Diagnosis__c = currCase.Contact.Diagnosis__c;
     currWishChild.Gender__c = currCase.Contact.Gender__c;
     currWishChild.mobilePhone__c = currCase.Contact.MobilePhone;
     currWishChild.Email__c = currCase.Contact.Email;
     currWishChild.T_Shirt_Size__c = currCase.Contact.T_Shirt_Size__c;
     currWishChild.Street__c = currCase.Contact.MailingStreet;
     currWishChild.State__c = currCase.Contact.MailingState;
     currWishChild.city__c = currCase.Contact.MailingCity;
     currWishChild.Zip_code__c = currCase.Contact.MailingPostalCode;
     currWishChild.Bringing_Own_Wheel_Chair__c = currWishChild.Bringing_Own_Wheel_Chair__c;
     for(npe4__Relationship__c currRel : [SELECT id,npe4__RelatedContact__c,npe4__RelatedContact__r.FirstName, npe4__RelatedContact__r.LastName,
                                          npe4__RelatedContact__r.Email, npe4__RelatedContact__r.Phone, npe4__RelatedContact__r.Middle_Name__c
                                          FROM npe4__Relationship__c  
                                          WHERE npe4__Contact__c  = :currCase.ContactId AND npe4__Type__c = 'Family'])
       {
            WishChildFormUtil.WrapperClass wrapCls = new WishChildFormUtil.WrapperClass();
            wrapCls.FirstName = currRel.npe4__RelatedContact__r.FirstName;
            wrapCls.MiddleName = currRel.npe4__RelatedContact__r.Middle_Name__c;
            wrapCls.lastName = currRel.npe4__RelatedContact__r.LastName;
            wrapCls.Relationship = null;
            wrapCls.homeTelephone =  null;
            wrapCls.workTelephone =  null;
            wrapCls.sameParentGuardianFlag = false;
            wrapCls.mobileTelephone = currRel.npe4__RelatedContact__r.Phone;
            wrapCls.Email =  currRel.npe4__RelatedContact__r.Email;
            wrapCls.relId = currRel.npe4__RelatedContact__c;
            wcfUtil.wishFamilyWrapList.add(wrapCls); 
             
       }   


      if(wcfUtil.wishFamilyWrapList.size() > 0){
          String JSONString = JSON.serialize(wcfUtil.wishFamilyWrapList);
          currWishChild.Wish_Family_Contact__c = JSONString;  
      }              
      List<WishChildFormUtil.WrapperClass> wrapParticipantsList = new  List<WishChildFormUtil.WrapperClass>();
      List<Case> childAsPartList = new List<Case>();
      childAsPartList = [SELECT Contact.FirstName,Contact.LastName,Contact.Middle_Name__c,Contact.Email, Contact.MobilePhone,Contact.BirthDate, Contact.T_Shirt_Size__c FROM Case WHERE Id = :currCase.id limit 1 ] ;        
      System.debug('isChildPart 3'+isChildPart);
      Integer count = 0;
      for( Case childCase:childAsPartList){
          if(count != 1){
            isChildPart = true;
            WishChildFormUtil.WrapperClass childParticipantsWrap = new WishChildFormUtil.WrapperClass();
            childParticipantsWrap.firstName = childCase.Contact.FirstName;
            childParticipantsWrap.LastName = childCase.Contact.LastName;
            childParticipantsWrap.MiddleName = childCase.Contact.Middle_Name__c;               
            childParticipantsWrap.Email = childCase.Contact.Email;   
            childParticipantsWrap.dob = childCase.Contact.BirthDate;   
            childParticipantsWrap.tshirtSize = childCase.Contact.T_Shirt_Size__c; 
            childParticipantsWrap.isChildParticipants = isChildPart ;
            childParticipantsWrap.sameParentGuardianFlag = false;
            childParticipantsWrap.Relationship = 'Self';
            System.debug('isChildPart 4'+isChildPart);
            wrapParticipantsList.add(childParticipantsWrap);
          }
          count = count + 1;
      }
      if(wrapParticipantsList.size() > 0)   
      {
          
          ParticipantsMapping(wrapParticipantsList,false);
          isParticipants = true;
      }
  }
  
  public void SaveContact(){
      currWishChild.Case__c = currCase.id;
      Constant_AC  constant = new Constant_Ac(); 
      Set<String> nameset = new Set<String>();   
       Set<String> namesetOne = new Set<String>();   
      Id wishDeterminationId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishDeterminationRT).getRecordTypeId();
      List<Case> currWishDeterminationCaseId = [SELECT ID FROM CASE WHERE  ParentId = :currWishChild.Case__c AND RecordTypeId = :wishDeterminationId];
     System.debug('342 - '+wcfUtil.wishFamilyWrapList);
      if(currWishDeterminationCaseId.size() > 0)
          currWishChild.Wish_Determination_Case_Id__c = currWishDeterminationCaseId[0].id;
          
      try{
        System.debug('wcfUtil.wishFamilyWrapList - '+wcfUtil.wishFamilyWrapList);
          if(wcfUtil.wishFamilyWrapList.size() > 0){
            String FamilyContactEmail = '';
            String FamilyContactName = '';
            if(currWishChild.Wish_Family_Contact__c == Null)
                 currWishChild.Wish_Family_Contact__c = '';
                 String JSONString = JSON.serialize(wcfUtil.wishFamilyWrapList);
                 currWishChild.Wish_Family_Contact__c = JSONString;
                 
            for(WishChildFormUtil.WrapperClass currRec : wcfUtil.wishFamilyWrapList){
                 if(currRec.FirstName != Null && currRec.LastName != Null && currRec.LastName!= Null){
                     String name = currRec.FirstName+'-'+currRec.LastName+'-'+currRec.Email;
                     String nameone = currRec.FirstName+'-'+currRec.LastName;
                     namesetOne.add(nameone); 
                     nameset.add(name);
                    if(FamilyContactEmail != Null && FamilyContactEmail != '' && FamilyContactName != Null && FamilyContactName != '')
                    FamilyContactEmail +=','+currRec.FirstName+ ' '+currRec.LastName+'-'+currRec.Email;
                    else
                    FamilyContactEmail = currRec.FirstName+ ' '+currRec.LastName+'-'+currRec.Email;
                    if(FamilyContactName != Null && FamilyContactName != '')
                    FamilyContactName +=','+currRec.FirstName+ ' '+currRec.LastName;
                    else
                    FamilyContactName = currRec.FirstName+ ' '+currRec.LastName;
                 }                     
            }
            currWishChild.Hidden_Wish_Fmaily_Contact_Email__c = FamilyContactEmail;
            currWishChild.Hidden_Wish_Fmaily_Contact_Name__c = FamilyContactName;
          }
          
          
          
          System.debug('wcfUtil.currrentDietaryNameList++++++++++++++++++++ ' + wcfUtil.currrentDietaryNameList);
          
          
       
          if(wcfUtil.isInformation == True){
              System.debug('wcfUtil.currrentDietaryNameListtttt++++++++++++++++++++ ' + wcfUtil.currrentDietaryNameList);
              currWishChild.Availability_Time_Period_1__c = wcfUtil.availableMonth1+'/'+wcfUtil.availableYear1;
              currWishChild.Availability_Time_Period_2__c = wcfUtil.availableMonth2+'/'+wcfUtil.availableYear2;
              currWishChild.Availability_Time_Period_3__c = wcfUtil.availableMonth3+'/'+wcfUtil.availableYear3;
              currWishChild.Participant_Name_for_Dietary_Restriction__c = wcfUtil.selectedNames(wcfUtil.currrentDietaryNameList);
              currWishChild.Requested_Participant_Name_forWheelchair__c = wcfUtil.selectedNames(wcfUtil.currentWCNamesList);
              currWishChild.Requested_Participant_Name_for_OtherNeed__c = wcfUtil.selectedNames(wcfUtil.currentOtherNeedsList);
              currWishChild.Requested_Participant_Name_for_Oxygen__c = wcfUtil.selectedNames(wcfUtil.currentOxygenNamesList);
              currWishChild.Requested_Participant_Name_for_Allergies__c = wcfUtil.selectedNames(wcfUtil.currentAllergyNamesList);
              currWishChild.Bringing_Own_Wheel_Chair__c = wcfUtil.selectedNames(wcfUtil.currentOwnWheelChairList);
              currWishChild.Name_of_wheelchair_collapsible__c= wcfUtil.selectedNames(wcfUtil.currentWCCollapsibleList);
              currWishChild.Pariticipant_name_havingWheelchair_Power__c= wcfUtil.selectedNames(wcfUtil.currentWCPowerList);
              currWishChild.Medication_require_refrigeration_name__c= wcfUtil.selectedNames(wcfUtil.currentMedicationList);
              currWishChild.Names_for_receiving_nursing_care__c= wcfUtil.selectedNames(wcfUtil.currentNursingCareList);
          }
          if(wcfUtil.wishParticipantList.size() > 0){
             currWishChild.Participant_Contacts__c= '';
             currWishChild.Participant_Name__c = '';
             currWishChild.Participant_Details__c = '';
             String JSONString = JSON.serialize(wcfUtil.wishParticipantList);                   
             currWishChild.Participant_Contacts__c= JSONString;
             currWishChild.Participant_Names__c = '';
             Integer age;
             System.debug('SAVE METHOD - '+wcfUtil.wishParticipantList);
             for(WishChildFormUtil.WrapperClass currRec : wcfUtil.wishParticipantList){
                 if(currRec.dob != Null){
                     Date dt = Date.Valueof(currRec.dob);
                     Integer days = dt.daysBetween(Date.Today());
                     age = Integer.valueOf(days/365);
                 }
                 
                 if(currRec.FirstName != Null && currRec.LastName != Null )
                 {
                    
                    currWishChild.Participant_Names__c += currRec.FirstName+ '  '+currRec.LastName+',';
                 } 
                 
                 if(currRec.FirstName != Null && currRec.LastName != Null && currRec.Email != Null && age >= 18){
                     String participantName = currRec.FirstName+'-'+currRec.LastName+'-'+currRec.Email;
                     if(!nameset.contains(participantName))
                     currWishChild.Participant_Details__c +=  currRec.FirstName+ '  '+currRec.LastName+'-'+currRec.Email+'-'+age+',';
                 }
                  if(currRec.FirstName != Null && currRec.LastName != Null && age >= 18){
                     String name = currRec.FirstName+'-'+currRec.LastName;
                     if(!namesetOne.contains(name))
                     currWishChild.Participant_Name__c +=  currRec.FirstName+ '  '+currRec.LastName+'-'+age+',';
                 }
                 
                 if(currRec.dob != Null){
                     Date dt = Date.Valueof(currRec.dob);
                     Integer days = dt.daysBetween(Date.Today());
                     age = Integer.valueOf(days/365);
                 }  
             }
             if(currWishChild.Participant_Names__c != Null)
              currWishChild.Participant_Names__c = currWishChild.Participant_Names__c.removeEnd(',');
            
             if(currWishChild.Participant_Details__c  != Null)
             currWishChild.Participant_Details__c = currWishChild.Participant_Details__c.removeEnd(',');
             currWishChild.Participant_Details__c = currWishChild.Participant_Details__c.removeEnd('-');
             currWishChild.Participant_Name__c = currWishChild.Participant_Name__c.removeEnd(',');
          }
      
          if(wcfUtil.driverWrapperCls.size() > 0 && wcfUtil.isInformation == True){
             currWishChild.Driver_Details__c = '';
             String JSONString = JSON.serialize(wcfUtil.driverWrapperCls);
             currWishChild.Driver_Details__c = JSONString;
             CurrWishChild.Driver_name__c = ''; 
              for(WishChildFormUtil.DriverWrapper currRec : wcfUtil.driverWrapperCls){
                    String driverName = '';
                    if(currRec.driverName != '')
                    {
                        driverName = currRec.driverName+' | ';
                        currWishChild.Driver_Name__c +=driverName;
                    }                            
               }        
          }   
      
          currWishChild.Case_Team_Member1__c = wcfUtil.caseTeamMemberNo1;
          currWishChild.Case_Team_Member2__c = wcfUtil.caseTeamMemberNo2;
          upsert currWishChild;
      }
      catch(DMLException e){        
          ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() +' >> '+ e.getLineNumber());
          ApexPages.addMessage(myMsg);
      }     
  }
  
  public PageReference SaveandWishChildExit(){
      
      try
      {
          saveContact();
          PageReference reference=new PageReference('/apex/WishChildForm_VF?Id='+this.currCase.id);
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
  
  public PageReference WCFNext(){ 
      try
      {
       /*if(currWishChild.Hidden_Same_as_Family__c == false){
           wcfUtil.sameParentGuardian = false;
           isChecked = false;
           currWishChild.Hidden_Same_as_Family__c = false; 
           isParticipants  = false; 
           UPDATE currWishChild; 
          
       }*/
          saveContact();
          PageReference reference=new PageReference('/apex/WishFamilyForm_VF?Id='+this.currCase.id);
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
  
  // Back to Case Detail page.
  public PageReference cancelfunction(){
      wcfUtil.displayExitPopup = true;
     
      return null;
  }
  
  public pageReference cancel(){
  
      PageReference reference=new PageReference('/apex/WishInformationForm_VF?id='+currCase.id);
      reference.setRedirect(true);     
      return reference;
  }
  
  public PageReference SavewithExit(){
  try{
    if(wcfUtil.sameParentGuardian)
        currWishChild.Hidden_Same_as_Family__c = true; 
    else
      currWishChild.Hidden_Same_as_Family__c = false;

    saveContact();
   
    PageReference reference=new PageReference('/'+currCase.id);
    reference.setRedirect(true);     
    return reference;
  }      
  catch(DMLException e)
  {
      ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() +' >> '+ e.getLineNumber());
      ApexPages.addMessage(myMsg);
      return null;
  }  
  return null; 
  }
  
  public void removeFamily(){
      Integer indexVal = Integer.valueof(system.currentpagereference().getparameters().get('index'));
    
      //Remove the contact from the table    
      wcfUtil.wishFamilyWrapList.remove(indexVal);            
  }   
  
  public void removeParticipants(){
      Integer indexVal = Integer.valueof(system.currentpagereference().getparameters().get('Participant'));
      //Remove the contact from the table    
      wcfUtil.wishParticipantList.remove(indexVal);            
  } 

  public void removeDriver(){
      Integer indexVal = Integer.valueof(system.currentpagereference().getparameters().get('driver'));
    
      //Remove the contact from the table    
      wcfUtil.driverWrapperCls.remove(indexVal);            
  }    
  
  public PageReference ExitWithOutSave(){
 
      PageReference reference=new PageReference('/'+currCase.id);
      reference.setRedirect(true);     
      return reference;
  }

  public PageReference ExitwithApprovalError(){
 
      PageReference reference=new PageReference('/'+currentPageId);
      reference.setRedirect(true);     
      return reference;
  }
  
  public void addFamily(){
          (wcfUtil.wishFamilyWrapList).add(new WishChildFormUtil.WrapperClass());
  }

  public void addDriver(){
      if(wcfUtil.driverWrapperCls.size() < wcfUtil.wishParticipantList.size())
          wcfUtil.driverWrapperCls.add(new WishChildFormUtil.DriverWrapper());
  }
  
  public void addParticipants(){ 
      wcfUtil.wishParticipantList.add(new WishChildFormUtil.WrapperClass());
  }

  public pageReference BackToWCF(){
  SaveContact();
  System.debug('AFTER SAVE');
    if(wcfUtil.sameParentGuardian)
      currWishChild.Hidden_Same_as_Family__c = true; 
    else
      currWishChild.Hidden_Same_as_Family__c = false;
    //UPDATE currWishChild;
    
    
    PageReference reference=new PageReference('/apex/WishChildForm_VF?Id='+this.currCase.id);
    reference.setRedirect(true);     
    return reference;
  }
  
  public pageReference CheckSameasParent(){
          PageReference reference=new PageReference('/apex/WishFamilyForm_VF?Id='+currCase.id+'&part='+isParticipants);
          reference.setRedirect(true);     
          return reference;
  }
  
  public PageReference SaveandwishFamilyExit(){
    try{
       if(wcfUtil.sameParentGuardian)
          currWishChild.Hidden_Same_as_Family__c = true;
       else 
          currWishChild.Hidden_Same_as_Family__c = false;         
          // UPDATE currWishChild; 
          // 
      saveContact();

      PageReference reference=new PageReference('/apex/WishFamilyForm_VF?Id='+currCase.id+'&part='+isParticipants);
      reference.setRedirect(true);  
      return reference;
    }      
    catch(DMLException e){
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() +' >> '+ e.getLineNumber());
        ApexPages.addMessage(myMsg);
        return null;
    }      
    return null;   
  }

  public PageReference WFFNext(){ 
      try
      {
          if(wcfUtil.sameParentGuardian)
              currWishChild.Hidden_Same_as_Family__c = true;
          else 
              currWishChild.Hidden_Same_as_Family__c = false;  
          System.debug('wcfUtil.currrentDietaryNameList++++++++++++++++++++ ' + wcfUtil.currrentDietaryNameList);
          saveContact();
          PageReference reference=new PageReference('/apex/WishInformationForm_VF?Id='+this.currCase.id);
          reference.setRedirect(true);     
          return reference;
      }      
      catch(DMLException e)
      {
          ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() +' >> '+ e.getLineNumber());
          ApexPages.addMessage(myMsg);
          return null;
      }
      
      return null; 
  }

  //Add Wish family as Wish participants
  public void SameAsFamily(){
    system.debug(' 802 '+wcfUtil.sameParentGuardian);
    if(wcfUtil.sameParentGuardian){
      currWishChild.Hidden_Same_as_Family__c = true; 
      ParticipantsMapping(wcfUtil.wishFamilyWrapList,true);
    }
    else{
      RemovesameParentGuardian();
     }  
  }
//Remove Wish family From Wish participants
  public void RemovesameParentGuardian(){ 
  System.debug(wcfUtil.wishParticipantList);
      Integer j = 0;
      while (j < wcfUtil.wishParticipantList.size()){
          if(wcfUtil.wishParticipantList.get(j).sameParentGuardianFlag){
            wcfUtil.wishParticipantList.remove(j);  
          }
          else {
            j++;        
          }
      }
  }

  public void ParticipantsMapping(List<WishChildFormUtil.WrapperClass> participantsList,Boolean isChecked){
    System.debug(isChecked+' - participantsList - '+participantsList);
    for(WishChildFormUtil.WrapperClass  currRec : participantsList){
        WishChildFormUtil.WrapperClass wrapCls;
        if(wrapCls == null){
        wrapCls = new WishChildFormUtil.WrapperClass();
        }

        wrapCls.FirstName = (currRec.FirstName!=Null)?currRec.FirstName:'';
        wrapCls.MiddleName = (currRec.MiddleName!=Null)?currRec.MiddleName:'';
        wrapCls.lastName = (currRec.lastName!=Null)?currRec.lastName:'';
        wrapCls.Relationship = (currRec.Relationship!=Null)?currRec.Relationship:'';
        wrapCls.dob =  (currRec.dob !=Null)?Date.valueOf(currRec.dob):currRec.dob;
        wrapCls.medicalNeeds =  currRec.medicalNeeds;
        wrapCls.residingWishMedical =currRec.residingWishMedical;
        wrapCls.Email =  (currRec.Email!=Null)?currRec.Email:'';
        wrapCls.tshirtSize =  (currRec.tshirtSize!=Null)?currRec.tshirtSize:'';
        wrapCls.sameParentGuardianFlag = (isChecked == true) ? isChecked : currRec.sameParentGuardianFlag;
        wrapCls.isChildParticipants = isChildPart;
        wcfUtil.wishParticipantList.add(wrapCls); 
        System.debug(isChecked+'--+--'+wcfUtil.wishParticipantList);                       


        String Name = wrapCls.FirstName+' ' +wrapCls.lastName;
        wcfUtil.driverNameList.add((new SelectOption(Name,Name)));
        if(!(wcfUtil.dietaryNamesSet.size() > 0 && wcfUtil.dietaryNamesSet.contains(wrapCls.FirstName+' ' +wrapCls.lastName)))
        wcfUtil.leftDietaryNameList.add(wrapCls.FirstName+' ' +wrapCls.lastName);
        if(!(wcfUtil.WCNamesSet.size() > 0 && wcfUtil.WCNamesSet.contains(wrapCls.FirstName+' ' +wrapCls.lastName)))
        wcfUtil.leftWCNamesList.add(wrapCls.FirstName+' ' +wrapCls.lastName);
        if(!(wcfUtil.OxygenNamesSet.size() > 0 && wcfUtil.OxygenNamesSet.contains(wrapCls.FirstName+' ' +wrapCls.lastName)))
        wcfUtil.leftOxygenNamesList.add(wrapCls.FirstName+' ' +wrapCls.lastName);
        if(!(wcfUtil.AllergyNamesSet.size() > 0 && wcfUtil.AllergyNamesSet.contains(wrapCls.FirstName+' ' +wrapCls.lastName)))
        wcfUtil.leftAllergyNamesList.add(wrapCls.FirstName+' ' +wrapCls.lastName);
        if(!(wcfUtil.OtherNeedsSet.size() > 0 && wcfUtil.OtherNeedsSet.contains(wrapCls.FirstName+' ' +wrapCls.lastName)))
        wcfUtil.leftOtherNeedsList.add(wrapCls.FirstName+' ' +wrapCls.lastName);
        if(!(wcfUtil.ownWheelChairNamesSet.size() > 0 && wcfUtil.ownWheelChairNamesSet.contains(wrapCls.FirstName+' ' +wrapCls.lastName)))
        wcfUtil.leftOwnWheelChairList.add(wrapCls.FirstName+' ' +wrapCls.lastName);
        if(!(wcfUtil.WCCollapsiblesSet.size() > 0 && wcfUtil.WCCollapsiblesSet.contains(wrapCls.FirstName+' ' +wrapCls.lastName)))
        wcfUtil.leftWCCollapsibleList.add(wrapCls.FirstName+' ' +wrapCls.lastName);
        if(!(wcfUtil.WCPowerNamesSet.size() > 0 && wcfUtil.WCPowerNamesSet.contains(wrapCls.FirstName+' ' +wrapCls.lastName)))
        wcfUtil.leftWCPowerList.add(wrapCls.FirstName+' ' +wrapCls.lastName);
        if(!(wcfUtil.MedicationNamesSet.size() > 0 && wcfUtil.MedicationNamesSet.contains(wrapCls.FirstName+' ' +wrapCls.lastName)))
        wcfUtil.leftMedicationList.add(wrapCls.FirstName+' ' +wrapCls.lastName);
        if(!(wcfUtil.nursingCaresSet.size() > 0 && wcfUtil.nursingCaresSet.contains(wrapCls.FirstName+' ' +wrapCls.lastName)))
        wcfUtil.leftNursingCareList.add(wrapCls.FirstName+' ' +wrapCls.lastName);
    }
  }

  public pageReference multiEmail(){
    wcfUtil.isInformation = True;
    saveContact();
    if(wcfUtil.emailMap.size() > 0){
     wcfUtil.multiPickoptions = new List<SelectOption>();
     Set<String> nameSet = new Set<String>();
     Map<String,String> processedNameMap = new Map<String,String>();
      
      for(Wish_Child_Form__c wishChildForm : [SELECT Id,Name,Case__c,Hidden_Contact_Name__c,Hidden_Wish_Fmaily_Contact_Email__c,Hidden_Wish_Fmaily_Contact_Name__c FROM Wish_Child_Form__c WHERE
                                                       Case__c =: currCase.id]){
                if(wishChildForm.Hidden_Contact_Name__c != Null) {                                     
                for(String keys : wishChildForm.Hidden_Contact_Name__c.split(',')){
                   nameSet.add(keys.trim());
                } 
                
                }
      }
       
      Wish_Child_Form__c wishChildForm = [SELECT Id,Name,Case__c,Hidden_Contact_Name__c,Hidden_Wish_Fmaily_Contact_Email__c,Hidden_Wish_Fmaily_Contact_Name__c FROM Wish_Child_Form__c WHERE
                                                       Case__c =: currCase.id];
        for(String key : wishChildForm.Hidden_Wish_Fmaily_Contact_Email__c.split(',')){
               String keys = key.split('-')[0];
               keys = keys.replaceAll('  ',' ');
               String value = key.split('-')[1];
               processedNameMap.put(keys.trim(),value);
        } 
       system.debug('@@@@@@@@ processedNameMap @@@@@@@@@@'+processedNameMap);
      if(processedNameMap.size() > 0){
          for(String name : processedNameMap.KeySet()){
                if(!nameSet.contains(name)){
                 name = name.replaceAll('  ',' ');
                if(wcfUtil.selectedMailMap.containsKey(name)){
                    name = name+' ';
                    wcfUtil.selectedMailMap.put(name,processedNameMap.get(name));
                 system.debug('@@@@@@@@ selectedMailMap111 @@@@@@@@@@'+wcfUtil.selectedMailMap);
                }
                else
                wcfUtil.selectedMailMap.put(name,processedNameMap.get(name));
                system.debug('@@@@@@@@ selectedMailMap @@@@@@@@@@'+wcfUtil.selectedMailMap);
                }
          }
      }
      for(String currString : wcfUtil.selectedMailMap.keySet()){
          CurrString = CurrString.replaceAll('  ',' ');
          wcfUtil.multiPickoptions.add(new SelectOption(currString,currString ));
          system.debug(currString +'@@@@@@@@ multiPickoptions @@@@@@@@@@'+wcfUtil.multiPickoptions);
      }
         
      if(wcfUtil.selectedMailMap.size() > 0){
               wcfUtil.displayPopup = true;
      }         
     else{
         wcfUtil.displayError = true;
         ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Already an email sent to specified address click [OK].'));
     }
    }
    return null;
  }

  public pageReference confirmSignNow(){
    wcfUtil.isInformation = True;
    SaveContact();        
    PageReference reference=new PageReference('/apex/WishChildForm_VF?Id='+this.currCase.id);
    wcfUtil.confirmSignNow = true;
    return null;
  }
  
    public PageReference SaveandRedirectChildForm(){
    
        if(wcfUtil.sameParentGuardian)
             currWishChild.Hidden_Same_as_Family__c = true;
        else 
             currWishChild.Hidden_Same_as_Family__c = false; 
    
        saveContact();
        PageReference reference=new PageReference('/apex/WishChildForm_VF?Id='+this.currCase.id);
        reference.setRedirect(true);     
        return reference;
    
    }
    
    
     public PageReference SaveAndRedirectFamilyForm(){
     
         if(wcfUtil.sameParentGuardian)
             currWishChild.Hidden_Same_as_Family__c = true;
         else 
             currWishChild.Hidden_Same_as_Family__c = false; 
    
        saveContact();
        PageReference reference=new PageReference('/apex/WishFamilyForm_VF?Id='+this.currCase.id);
        reference.setRedirect(true);     
        return reference;
    
    }
    
    
     public PageReference SaveAndRedirectInformationForm(){
     
         if(wcfUtil.sameParentGuardian)
             currWishChild.Hidden_Same_as_Family__c = true;
         else 
             currWishChild.Hidden_Same_as_Family__c = false; 
     
    
        WishInfoSave();
        PageReference reference=new PageReference('/apex/WishInformationForm_VF?Id='+this.currCase.id);
        reference.setRedirect(true);     
        return reference;
    
    }
    
    public PageReference SaveFromInformationToChildForm(){
    
        if(wcfUtil.sameParentGuardian)
             currWishChild.Hidden_Same_as_Family__c = true;
        else 
             currWishChild.Hidden_Same_as_Family__c = false; 
    
        WishInfoSave();
        PageReference reference=new PageReference('/apex/WishChildForm_VF?Id='+this.currCase.id);
        reference.setRedirect(true);     
        return reference;
    
    }
     

  public PageReference SignNowmultiEmail(){
      wcfUtil.confirmSignNow = false;
      wcfUtil.multiPickoptions = new List<SelectOption>();
      if(wcfUtil.emailMap.size() > 0){
      Map<String,String> nameMap = new Map<String,String>();
      Map<String,String> processedNameMap = new Map<String,String>();
       
      for(Wish_Child_Form__c wishChildForm : [SELECT Id,Name,Case__c,Hidden_Contact_Name__c,Hidden_Wish_Fmaily_Contact_Email__c,Hidden_Wish_Fmaily_Contact_Name__c FROM Wish_Child_Form__c WHERE
                                                       Case__c =: currCase.id]){
                 if(wishChildForm.Hidden_Contact_Name__c != Null) {                                     
                    for(String keys : wishChildForm.Hidden_Contact_Name__c.split(',')){
                       nameMap.put(keys.trim(),'abc');
                       system.debug('##### nameMap ####'+nameMap);
                    } 
                
                }
      }
       
      for(Wish_Child_Form__c wishChildForm : [SELECT Id,Name,Case__c,Hidden_Contact_Name__c,Hidden_Wish_Fmaily_Contact_Email__c,Hidden_Wish_Fmaily_Contact_Name__c FROM Wish_Child_Form__c WHERE
                                                       Case__c =: currCase.id]){ 
        for(String key : wishChildForm.Hidden_Wish_Fmaily_Contact_Email__c.split(',')){
               String keys = key.split('-')[0];
               keys = keys.replaceAll('  ',' ');
               String value = key.split('-')[1];
              processedNameMap.put(keys.trim(),value);
           } 
      }
      if(processedNameMap.size() > 0){
          for(String name : processedNameMap.KeySet()){
        
                if(!nameMap.containsKey(name)){
                    wcfUtil.selectedMailMap.put(name,processedNameMap.get(name));
                
                }
          }
      }
      }
      if(wcfUtil.selectedMailMap.size() > 0){
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
          PDF.getParameters().put('Id',currCase.id);
          try {
          wcfUtil.documentPDF = EncodingUtil.base64Encode(PDF.getContentAsPDF());
          }catch(Exception e) {
          }
          case dbcase = [SELECT Id,Envelop_Id__c,SignerMapKeyPair__c FROM Case WHERE Id =:currCase.id];
          if(dbcase.Envelop_Id__c  == Null){
          for(String currString : wcfUtil.selectedMailMap.keySet()){
          String Name = currString;
          email = wcfUtil.sendEmailMap.get(currString);
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
          if(!wcfUtil.signersKeyPairMap.containsKey(Name))
          wcfUtil.signersKeyPairMap.put(Name,String.valueof(i));
          i++;
          }
          //forming payload with the document and recipients.
          String body =  '{'+
          '  "status":"sent",'+
          '  "enableWetSign": "false",'+
          '  "emailBlurb":"Wish Paperwork Packet",'+
          '  "emailSubject": "Wish Paperwork Packet",'+
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
          try{
          if(recipients != ''){
          res = http.send(req);
          system.debug(res.getBody());
          //Docusign status record creation.
          Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
          if((String) results.get('envelopeId') != '')
          wcfUtil.envelopeId = (String) results.get('envelopeId');
          if((String) results.get('status') == 'Sent'){
              status = 'Agreement sent to email.';
              dsfs__DocuSign_Status__c dsfs= NEW dsfs__DocuSign_Status__c();
              dsfs.dsfs__DocuSign_Envelope_ID__c = (String) results.get('envelopeId');
              dsfs.dsfs__Case__c= currCase.id;
              Insert dsfs;
          }else
              status = (String) results.get('errorCode');

          }
          }catch(Exception e){
          }
          system.debug('%%%%%%%% envelopeId value %%%%%%%%%'+wcfUtil.envelopeId);
          }
          else{
          wcfUtil.envelopeId = dbcase.Envelop_Id__c;
          for(String key : dbcase.SignerMapKeyPair__c.split(',')){
          String keys = key.split('-')[0];
          String value = key.split('-')[1];
          wcfUtil.signersKeyPairMap.put(keys.trim(),value.trim());
          } 
          system.debug('%%%%%%%% ENTER INTO ELSE signersKeyPairMap %%%%%%%%%'+wcfUtil.signersKeyPairMap);
          }
          wcfUtil.displaySignNowPopup = true;
          for(String currString : wcfUtil.selectedMailMap.keySet()){           
          wcfUtil.multiPickoptions.add(new SelectOption(currString,currString ));
          }
      }     
      else{
         wcfUtil.displayError = true;
         ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'There is no user to sign click [OK].'));
      }
     return null;
  }
  
  public pageReference BackToWFF() {
         // system.debug('@@@@@@ currWishChild @@@@@@'+currWishChild.Hidden_Same_as_Family__c);    
          system.debug('@@@@@@ BackToWFF @@@@@@'+wcfUtil.sameParentGuardian);
        /*   if(wcfUtil.sameParentGuardian)
            {  
              isChecked = true;
              isParticipants  = true; 
              currWishChild.Hidden_Same_as_Family__c = true;            
              ParticipantsMapping(wcfUtil.wishFamilyWrapList);       
          } 
      else
        { 
          isChecked = false;
           currWishChild.Hidden_Same_as_Family__c = false; 
           isParticipants  = false; 
           UPDATE currWishChild; 
           
           system.debug('@@@@@@ currWishChild @@@@@@'+currWishChild.Hidden_Same_as_Family__c);           
           RemovesameParentGuardian();
            
      }*/
      
          System.debug('wcfUtil.currrentDietaryNameList++++++++++++++++++++ ' + wcfUtil.currrentDietaryNameList);   
          WishInfoSave();
          PageReference reference=new PageReference('/apex/WishFamilyForm_VF?Id='+this.currCase.id);
          reference.setRedirect(true);     
          return reference;
  } 
  
  public void WishInfoSave(){
      //PageReference reference;
      try
      {
          System.debug('wcfUtil.currrentDietaryNameList++++++++++++++++++++ ' + wcfUtil.currrentDietaryNameList);
          wcfUtil.isInformation = True;
          saveContact();
          
           /*reference=new PageReference('/apex/WishInformationForm_VF?Id='+currcase.Id+'&part='+isParticipants);
           reference.setRedirect(true);     
        
          
          ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.CONFIRM,'You Have Successfully Saved Your Information');
          ApexPages.addMessage(myMsg);
          return reference;*/
        
      }
      
      Catch(DMLException e)
      {
          /*ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() +' >> '+ e.getLineNumber());
          ApexPages.addMessage(myMsg);
          return null;*/
      }
      
      //return null; 
  }
  
  public pagereference submitforApproval(){
        PageReference reference;
        List<ProcessInstance> approvalIns =  [SELECT TargetObjectId,Status,ProcessDefinitionId,ProcessDefinition.Name FROM ProcessInstance WHERE TargetObjectId =: currCase.id AND Status =: 'Pending' ];
        If(approvalIns.size() > 0){
           displayError();
        }
        else{
         wcfUtil.isInformation = True;
         saveContact();
         Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
         req.setComments('Submitting request for approval.');
         req.setObjectId(currCase.id);
         req.setProcessDefinitionNameOrId('Wish_Child_Form_Approval_Process');
         req.setSkipEntryCriteria(true);
         Approval.ProcessResult result = Approval.process(req);
          
          reference=new PageReference('/'+currCase.id);
          reference.setRedirect(true);     
          
        }
      return reference;  
  }
  
  public pagereference displayError(){
           
           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,' This record is already in approval process'));
           return null;
  }
  
  public pagereference generatePDF(){
          PageReference reference=new PageReference('/apex/WishFormDownloadPDF?Id='+currCase.id+'&force_download=true');
          reference.setRedirect(true);     
          return reference;
  }
  
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
                wcfUtil.querySignature = wcfUtil.querySignature + ',' +currString;
            }
      }
      
      for(Case dbCase : [SELECT Id,Hidden_Email_List__c From Case WHERE Id =:currcase.Id]){
          
          case newCase = new case();
          newCase.Id = dbCase.Id;
          newCase.Hidden_Email_List__c  = wcfUtil.querySignature;
          try{
          update newCase;
          }
              catch(Exception e){
          }
      }
      if(wcfUtil.sendEmailMap.size() > 0)    
        callouttoDocusing(wcfUtil.sendEmailMap,CurrCase.id,wcfUtil.wishChildId );
        
         ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm,'An email has been sent successfully'));
         PageReference acctPage = new PageReference ('/apex/WishInformationForm_VF?id='+currCase.id+'&part='+isParticipants);
         acctPage.setRedirect(true);
         return acctPage;  
  }
  
 @Future(callout=true)
  public static void callouttoDocusing(map<String,String> sendEmailMap,String caseId,Id wishChildId ){
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
                  '  "emailBlurb":"Wish Paperwork Packet",'+
                  '  "emailSubject": "Wish Paperwork Packet",'+
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

                 for(Wish_Child_Form__c wishChildForm : [SELECT Id,Name,Case__c,Hidden_Contact_Name__c,Hidden_Wish_Fmaily_Contact_Email__c,Hidden_Wish_Fmaily_Contact_Name__c FROM Wish_Child_Form__c WHERE
                                                         Case__c =: caseId]){
                     
                     Wish_Child_Form__c  updateWishChild = new Wish_Child_Form__c ();
                     updateWishChild.Id = wishChildForm.Id;
                     if(wishChildForm.Hidden_Contact_Name__c != Null)
                     updateWishChild.Hidden_Contact_Name__c=wishChildForm.Hidden_Contact_Name__c+','+ ContactName;
                     else
                     updateWishChild.Hidden_Contact_Name__c = ContactName;
                     update updateWishChild ;
                     System.debug('@@@@@@@@@@@ wishChildForm @@@@@@@@@@@@@@'+wishChildForm);
                 }
                  
              }catch(Exception e){
               
              }    
  }
  
  public Pagereference SubmitAndSign(){
    
      String account;
      String UserName;
      String Password;
      String IntegratorKey;
      String endPointURL;
     
      //List<Contact> relationShipList = new List<Contact>();
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

          
          string endpoint2 = endPointURL+'/accounts/'+account+'/envelopes/'+wcfUtil.envelopeId+'/views/recipient';
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
          
          jsonPayload = '{'+
              '    "userName": "'+wcfUtil.SignNowName+'",'+
              '    "email": "kanagaraj@mstsolutions.com",'+
              '    "recipientId": "'+wcfUtil.signersKeyPairMap.get(wcfUtil.SignNowName)+'",'+
              '    "clientUserId": "'+wcfUtil.signersKeyPairMap.get(wcfUtil.SignNowName)+'",'+
              '    "authenticationMethod": "None",'+
              '   "returnUrl": "'+baseUrl +'/apex/WishInformationForm_VF?Id='+currCase.id+'"'+   
              '}'; 
              
          
          request.setBody(jsonPayload);
          response = httprequest.send(request);  
          
          Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                //signersKeyPairMap.remove(SignNowName);
                String sign;
                for(String name : wcfUtil.signersKeyPairMap.KeySet()){
                     if(sign == '' || sign == Null)
                     sign= name +' - '+ wcfUtil.signersKeyPairMap.get(name);
                     else
                     sign = sign +','+ name + '- '+ wcfUtil.signersKeyPairMap.get(name);
                 }
                 case newCase = new case();
                 newCase.Id = currCase.id;
                 newCase.SignerMapKeyPair__c = sign;
                 newCase.Envelop_Id__c = wcfUtil.envelopeId;
                 update newCase;
                 
              PageReference reference=new PageReference((String) results.get('url'));
              reference.setRedirect(true);
              return reference;
  }
  
  public PageReference WishInfoWithSave(){
      
      try
      {
          wcfUtil.isInformation = True;
          saveContact();
          if(wcfUtil.displayExitPopup == true)
          {
              PageReference reference=new PageReference('/'+currCase.id);
              reference.setRedirect(true);     
              return reference;
          }
      }
      
      Catch(DMLException e)
      {
          ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() +' >> '+ e.getLineNumber());
          ApexPages.addMessage(myMsg);
          return null;
      }
      
      return null; 
  }
    
  public void forceDownloadPDF(){

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
  
  public pageReference DisplayApprovalProcess(){
      
      ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,' This record is already in approval process'));
      return null;
  }  
}