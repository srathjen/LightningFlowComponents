Public Class WishChildFormValUpdate_AC
{

    public static void updateWishType(Map<string,Case> newCaseDetails)
    {
       Task taskInstance;
       List<task>  taskList=new List<task>();
       Map<String,Wish_Child_Form__c> wishFormDetailsMap = new Map<String,Wish_Child_Form__c>();
       for(Wish_Child_Form__c currWishChildform : [SELECT id,WishType__c,Case_Team_Member1__c, Case_Team_Member2__c,
                                                   Driver_Name__c,case__c,Case__r.ChapterName__c,Case__r.Contact.Language__c FROM Wish_Child_Form__c WHERE 
                                                   Case__c IN : newCaseDetails.keySet()])
       {
            wishFormDetailsMap.put(currWishChildform.case__c, currWishChildForm);
       }
       
       for(Case currRec : newCaseDetails.Values())
       {
          if(wishFormDetailsMap.containsKey(currRec.id))
          {
             currRec.Wish_Type__c= wishFormDetailsMap.get(currRec.id).wishType__c;
             currRec.Driver_Names__c= wishFormDetailsMap.get(currRec.id).Driver_Name__c;
             if(wishFormDetailsMap.get(currRec.id).Case_Team_Member1__c != Null &&
                   wishFormDetailsMap.get(currRec.id).Case_Team_Member2__c != Null)
                   {
                      currRec.Active_Wish_Granter__c = wishFormDetailsMap.get(currRec.id).Case_Team_Member1__c + ','+wishFormDetailsMap.get(currRec.id).Case_Team_Member2__c;
                   }
             else if(wishFormDetailsMap.get(currRec.id).Case_Team_Member1__c != Null)
                currRec.Active_Wish_Granter__c = wishFormDetailsMap.get(currRec.id).Case_Team_Member1__c;
             else if(wishFormDetailsMap.get(currRec.id).Case_Team_Member2__c != Null)
                currRec.Active_Wish_Granter__c = wishFormDetailsMap.get(currRec.id).Case_Team_Member1__c;
          }
         taskInstance=new Task();
         taskInstance.OwnerId = currRec.OwnerId;
         taskInstance.Subject = 'Wish Concept Approval';
         taskInstance.Priority = 'Normal';
         taskInstance.Status = 'Not Started';
         taskInstance.Type = 'Action';
         taskInstance.ActivityDate=system.Today()+5;
         taskInstance.Whatid=currRec.id;
         taskList.add(taskInstance); 
        }
        if(taskList.size()!=null){
             //insert taskList;
         }
        
       
      
    
    }




    public static List<Case> updateWishdetails(Map<Id,Case> caseToUpdateMap)
    {
       System.debug('wishChildFormMap0++++++++++++++++++++++++== ');
       Map<String,Wish_Child_Form__c> wishChildFormMap = new Map<String,Wish_Child_Form__c>();
       for(Wish_Child_Form__c currWishChildform : [SELECT id,Case__c,Case__r.ChapterName__c,Case__r.Contact.Language__c,When_thinking_some_of_my_wish_ideas_were__c,MY_WISH_IS_TO__c,This_is_my_wish_because__c,
                                                   To_me_the_most_important_part_of_my_wish__c, When_I_think_about_my_wish_I_imagine__c, Wish_Notes__c,
                                                   Availability_Time_Period_1__c,Availability_Time_Period_2__c,Availability_Time_Period_3__c, 
                                                   Any_impact_your_ability_to_join_wish__c,Details_about_Impact__c,Street__c,
                                                   Have_current_automobile_insurance__c,Automobile_insurance_provide_coverage__c,Is_your_family_comfortable_in_rendal_car__c,
                                                   Is_a_wheelchair_accessible_vehicle_neede__c,Participant_dietary_restrictions__c,Participant_dietary_restrictions_Note__c,
                                                   Participant_require_a_wheelchair__c,Participant_require_a_wheelchair_Note__c,Will_your_family_bring_wheelchair__c,
                                                   Will_your_family_bring_wheelchair_Note__c,Is_the_wheelchair_collapsible__c,Is_the_wheelchair_collapsible_Note__c,
                                                   Is_the_wheelchair_power__c,Is_the_wheelchair_power_Note__c,Participant_require_oxygen_how_often__c,Participant_require_oxygen_Note__c,
                                                   Medication_require_refrigeration__c,Medication_require_refrigeration_Note__c,Wish_child_receive_nursing_care__c,
                                                   Wish_child_receive_nursing_care_Note__c,Participant_have_allergies_to_food__c,Participant_have_allergies_to_food_Note__c,
                                                   Participant_require_medical_supplies__c,Participant_require_medical_suppliesNote__c,Additional_Requests__c,
                                                   Has_your_family_flown_before__c,Has_your_family_flown_before_Note__c,Will_an_interpreter_be_needed__c,Will_an_interpreter_be_needed_Note__c,
                                                   Will_a_rental_car_seat_s_be_needed__c,Will_a_rental_car_seat_s_be_needed_Note__c,
                                                   Sit_up_takeoff_landing_on_airplane__c,Sit_up_takeoff_landing_on_airplane_Note__c,Will_a_rental_stroller_be_needed__c,
                                                   Will_a_rental_stroller_be_needed_Note__c,Handicap_accommodations_be_required__c,Handicap_accommodations_be_required_No__c,
                                                   Participant_have_valid_passports__c,Participant_have_valid_passports_Note__c,Does_participant_have_valid_photo_ID__c,
                                                   Participant_have_valid_photo_ID_Note__c,Wish_Determination_Case_Id__c,Does_your_family_have_a_credit_card__c,Does_your_family_have_a_credit_card_Note__c,Bringing_Own_Wheel_Chair__c FROM 
                                                   Wish_Child_Form__c WHERE Case__c IN : caseToUpdateMap.keySet()])
       {
    
            wishChildFormMap.put(currWishChildform.case__c,currWishChildform);
            System.debug('wishChildFormMap1++++++++++++++++++++++++== ' + wishChildFormMap);
    
       }
       
       List<Case> updateCaseList = new List<Case>();
       for(Case currRec : caseToUpdateMap.Values())
       {
          if(wishChildFormMap.containsKey(currRec.id))
          {
          
            Case currCase = new Case();
          
            if(wishChildFormMap.get(currRec.id).Wish_Determination_Case_Id__c != Null)
            {
             currCase.id = wishChildFormMap.get(currRec.id).Wish_Determination_Case_Id__c ;
             currCase.When_thinking_some_of_my_wish_ideas_were__c = wishChildFormMap.get(currRec.id).When_thinking_some_of_my_wish_ideas_were__c;
             currCase.MY_WISH_IS_TO__c = wishChildFormMap.get(currRec.id).MY_WISH_IS_TO__c;
             currCase.This_is_my_wish_because__c = wishChildFormMap.get(currRec.id).This_is_my_wish_because__c;
             currCase.To_me_the_most_important_part_of_my_wish__c = wishChildFormMap.get(currRec.id).To_me_the_most_important_part_of_my_wish__c;
             currCase.When_I_think_about_my_wish_I_imagine__c = wishChildFormMap.get(currRec.id).When_I_think_about_my_wish_I_imagine__c;
             currCase.Wish_Notes__c = wishChildFormMap.get(currRec.id).Wish_Notes__c;
             currCase.Availability_1__c = wishChildFormMap.get(currRec.id).Availability_Time_Period_1__c ;
             currCase.Availability2__c = wishChildFormMap.get(currRec.id).Availability_Time_Period_2__c ;
             currCase.Availability3__c = wishChildFormMap.get(currRec.id).Availability_Time_Period_3__c ;
             currCase.Any_impact_your_ability_to_join_wish__c = wishChildFormMap.get(currRec.id).Any_impact_your_ability_to_join_wish__c;
             currCase.Details_about_Impact__c = wishChildFormMap.get(currRec.id).Details_about_Impact__c;
             currCase.Have_current_automobile_insurance__c = wishChildFormMap.get(currRec.id).Have_current_automobile_insurance__c;
             currCase.Automobile_insurance_provide_coverage__c = wishChildFormMap.get(currRec.id).Automobile_insurance_provide_coverage__c;
             currCase.Is_your_family_comfortable_in_rendal_car__c = wishChildFormMap.get(currRec.id).Is_your_family_comfortable_in_rendal_car__c;
             currCase.Is_a_wheelchair_accessible_vehicle_neede__c = wishChildFormMap.get(currRec.id).Is_a_wheelchair_accessible_vehicle_neede__c;
             currCase.Participant_dietary_restrictions__c = wishChildFormMap.get(currRec.id).Participant_dietary_restrictions__c;
             currCase.Participant_dietary_restrictions_Note__c = wishChildFormMap.get(currRec.id).Participant_dietary_restrictions_Note__c;
             currCase.Participant_require_a_wheelchair__c = wishChildFormMap.get(currRec.id).Participant_require_a_wheelchair__c;
             currCase.Participant_require_a_wheelchair_Note__c = wishChildFormMap.get(currRec.id).Participant_require_a_wheelchair_Note__c;
             currCase.Will_your_family_bring_wheelchair__c = wishChildFormMap.get(currRec.id).Will_your_family_bring_wheelchair__c;
             currCase.Will_your_family_bring_wheelchair_Note__c = wishChildFormMap.get(currRec.id).Will_your_family_bring_wheelchair_Note__c;
             currCase.Is_the_wheelchair_collapsible__c = wishChildFormMap.get(currRec.id).Is_the_wheelchair_collapsible__c;
             currCase.Is_the_wheelchair_collapsible_Note__c = wishChildFormMap.get(currRec.id).Is_the_wheelchair_collapsible_Note__c;
             currCase.Is_the_wheelchair_power__c = wishChildFormMap.get(currRec.id).Is_the_wheelchair_power__c;
             currCase.Is_the_wheelchair_power_Note__c = wishChildFormMap.get(currRec.id).Is_the_wheelchair_power_Note__c;
             currCase.Participant_require_oxygen_Note__c = wishChildFormMap.get(currRec.id).Participant_require_oxygen_Note__c;
             currCase.Medication_require_refrigeration__c = wishChildFormMap.get(currRec.id).Medication_require_refrigeration__c;
             currCase.Medication_require_refrigeration_Note__c = wishChildFormMap.get(currRec.id).Medication_require_refrigeration_Note__c;
             currCase.Wish_child_receive_nursing_care__c = wishChildFormMap.get(currRec.id).Wish_child_receive_nursing_care__c;
             currCase.Wish_child_receive_nursing_care_Note__c = wishChildFormMap.get(currRec.id).Wish_child_receive_nursing_care_Note__c;
             currCase.Participant_have_allergies_to_food__c = wishChildFormMap.get(currRec.id).Participant_have_allergies_to_food__c;
             currCase.Participant_have_allergies_to_food_Note__c = wishChildFormMap.get(currRec.id).Participant_have_allergies_to_food_Note__c;
             currCase.Participant_require_medical_supplies__c = wishChildFormMap.get(currRec.id).Participant_require_medical_supplies__c;
             currCase.Participant_require_medical_suppliesNote__c = wishChildFormMap.get(currRec.id).Participant_require_medical_suppliesNote__c;
             currCase.Additional_Requests__c = wishChildFormMap.get(currRec.id).Additional_Requests__c;
             currCase.Has_your_family_flown_before__c = wishChildFormMap.get(currRec.id).Has_your_family_flown_before__c;
             currCase.Has_your_family_flown_before_Note__c = wishChildFormMap.get(currRec.id).Has_your_family_flown_before_Note__c;
             currCase.Will_an_interpreter_be_needed__c = wishChildFormMap.get(currRec.id).Will_an_interpreter_be_needed__c;
             currCase.Will_an_interpreter_be_needed_Note__c = wishChildFormMap.get(currRec.id).Will_an_interpreter_be_needed_Note__c;
             currCase.Will_a_rental_car_seat_s_be_needed__c = wishChildFormMap.get(currRec.id).Will_a_rental_car_seat_s_be_needed__c;
             currCase.Will_a_rental_car_seat_s_be_needed_Note__c = wishChildFormMap.get(currRec.id).Will_a_rental_car_seat_s_be_needed_Note__c;
             currCase.Sit_up_takeoff_landing_on_airplane__c = wishChildFormMap.get(currRec.id).Sit_up_takeoff_landing_on_airplane__c;
             currCase.Sit_up_takeoff_landing_on_airplane_Note__c = wishChildFormMap.get(currRec.id).Sit_up_takeoff_landing_on_airplane_Note__c;
             currCase.Will_a_rental_stroller_be_needed__c = wishChildFormMap.get(currRec.id).Will_a_rental_stroller_be_needed__c;
             currCase.Will_a_rental_stroller_be_needed_Note__c = wishChildFormMap.get(currRec.id).Will_a_rental_stroller_be_needed_Note__c;
             currCase.Handicap_accommodations_be_required__c = wishChildFormMap.get(currRec.id).Handicap_accommodations_be_required__c;
             currCase.Handicap_accommodations_be_required_Note__c = wishChildFormMap.get(currRec.id).Handicap_accommodations_be_required_No__c;
             currCase.Participant_have_valid_passports__c = wishChildFormMap.get(currRec.id).Participant_have_valid_passports__c;
             currCase.Participant_have_valid_passports_Note__c = wishChildFormMap.get(currRec.id).Participant_have_valid_passports_Note__c;
             currCase.Does_participant_have_valid_photo_ID__c = wishChildFormMap.get(currRec.id).Does_participant_have_valid_photo_ID__c;
             currCase.Participant_have_valid_photo_ID_Note__c = wishChildFormMap.get(currRec.id).Participant_have_valid_photo_ID_Note__c;
             currCase.Does_your_family_have_a_credit_card__c = wishChildFormMap.get(currRec.id).Does_your_family_have_a_credit_card__c;
             currCase.Does_your_family_have_a_credit_card_Note__c = wishChildFormMap.get(currRec.id).Does_your_family_have_a_credit_card_Note__c;
             currCase.Bringing_Own_Wheel_Chair__c = wishChildFormMap.get(currRec.id).Bringing_Own_Wheel_Chair__c;
            updateCaseList.add(currCase);
           
           }
          
          
          }
       
       
       }
         return updateCaseList;
     }
     
     
     public static void UpdateWishChildandWishFamily(Map<Id,Case> newWishMap)
     {  
            Constant_AC  constant = new Constant_Ac();
            String wishFamilyDT = Schema.Sobjecttype.Contact.getRecordTypeInfosByName().get(constant.wishFamilyRT).getRecordTypeId();
            Set<Id> caseIds = new Set<Id>();
            caseIds.addAll(newWishMap.keySet());
            Id ChapterAccId;
            Set<String> contactIds = new Set<String>();
     
            List<Case> updateWishDeterminationCaseList = WishChildFormValUpdate_AC.updateWishdetails(newWishMap);
     
     
            String wishChildQuery = 'SELECT id, ';
            for(Schema.FieldSetMember f : getWishChildFields()) {
                wishChildQuery+= f.getFieldPath() + ', ';
            }
           
             wishChildQuery+= ' Case__r.ContactId,Case__r.ChapterName__c,Case__r.Contact.AccountId,Case__r.Contact.Language__c from Wish_Child_Form__c' + ' WHERE Case__c = :'+'caseIds'+ ' lIMIT 1';
             List<Wish_Child_Form__c> wishChildList = Database.Query(wishChildQuery);
         
             List<Contact> updateWishChildContact = new List<Contact>();
             List<Account> updateWishFamilyAccount = new List<Account>();
             Map<String,Contact> createNewWishFamily = new Map<String,Contact>();
             Map<String,Contact> sameFamilyMap = new Map<String,Contact>();
             Set<String> firstNamesSet = new Set<String>();
             Set<String> lastNamesSet = new Set<String>();
             Set<String> relationshipsSet = new Set<String>();
             Set<Id> wishChildIds = new Set<Id>();
            
             Map<String,WishChildFormUtil.DriverWrapper> driverWrapperClsMap = new Map<String,WishChildFormUtil.DriverWrapper>();
             
              for(Wish_Child_Form__c currWishChildform : wishChildList)
              {
                 Contact currContact = new Contact();
                 Account updateAccount = new Account();
                
                 if(currWishChildForm.Case__r.ContactId != Null)
                 {
                     wishChildIds.add(currWishChildForm.Case__r.ContactId);
                     currContact.Id = currWishChildForm.Case__r.ContactId;
                     currContact.FirstName = currWishChildForm.FirstName__c;
                     currContact.LastName = currWishChildForm.LastName__c;
                     currContact.Middle_Name__c = currWishChildForm.Middle_Name__c;
                     currContact.Social_Media_Link__c = currWishChildForm.Social_Media_Link__c;
                     currContact.Already_wish_granted_by_MAW_Other_Org__c = currWishChildForm.Already_wish_granted_by_MAW_Other_Org__c;
                     currContact.If_yes_Enter_Org_Name_Wish_Date_it_was__c= currWishChildForm.If_yes_Enter_Org_Name_Wish_Date_it_wa__c;
                     currContact.Preferred_Name__c = currWishChildForm.Preferred_Name__c;
                     currContact.Gender__c= currWishChildForm.Gender__c;
                     currContact.BirthDate = currWishChildForm.BirthDate__c;
                     currContact.T_Shirt_Size__c= currWishChildForm.T_Shirt_Size__c;
                     currContact.Diagnosis__c = currWishChildForm.Diagnosis__c;
                     currContact.Primary_Address__c = currWishChildForm.PrimaryAddreess__c;
                     currContact.mobilePhone = currWishChildForm.mobilePhone__c;
                     currContact.Email = currWishChildForm.Email__c;
                     currContact.Color__c = currWishChildForm.Color__c;
                     currContact.Music_Singer__c  = currWishChildForm.Music_Singer__c;
                     currContact.Book_Story__c = currWishChildForm.Book_Story__c;
                     currContact.Hobby__c = currWishChildForm.Hobby__c;
                     currContact.Game__c= currWishChildForm.Game__c;
                     currContact.Food__c= currWishChildForm.Food__c;
                     currContact.Movie__c= currWishChildForm.Movie__c;
                     currContact.Food__c = currWishChildForm.Food__c;
                     currContact.TV_Show__c = currWishChildForm.TVShow__c;
                     currContact.Restaurant__c= currWishChildForm.Restaurant__c;
                     currContact.Actor_Actress__c = currWishChildForm.Actor_Actress__c;
                     currContact.Cake_Candy__c = currWishChildForm.Cake_Candy__c;
                     currContact.Sport_Athlete__c = currWishChildForm.Sport_Athlete__c;
                     currContact.Snack_Food__c = currWishChildForm.Snack_Food__c;
                     currContact.Pet_Animal__c = currWishChildForm.Pet_Animal__c;
                     currContact.Class_in_School__c = currWishChildForm.ClassinSchool__c;
                     currContact.Other__c= currWishChildForm.Other__c;
                     currContact.When_I_m_outside_I_like_to__c = currWishChildForm.When_I_m_outside_I_like_to__c;
                     currContact.When_I_m_inside_I_like_to__c = currWishChildForm.When_I_m_inside_I_like_to__c;
                     currContact.Electronics_Games_that_I_like_to_play__c = currWishChildForm.Electronics_Games_that_I_like_to_play__c;
                     currContact.When_I_m_with_my_family_I_like_to__c = currWishChildForm.When_I_m_with_my_family_I_like_to__c;
                     currContact.When_I_m_with_my_friends_I_like_to__c = currWishChildForm.When_I_m_with_my_friends_I_like_to__c;
                     currContact.Region_Chapter__c = currWishChildForm.Case__r.ChapterName__c;
                     ChapterAccId = currWishChildForm.Case__r.ChapterName__c;
                     currContact.Parent_Legal_Guardian__c = currWishChildForm.Hidden_Wish_Fmaily_Contact_Name__c;
                     if(currWishChildForm.Street__c != Null)
                         currContact.MailingStreet = currWishChildForm.Street__c;
                     if(currWishChildForm.City__c != Null)
                         currContact.MailingCity = currWishChildForm.City__c;
                     if(currWishChildForm.State__c != Null)
                         currContact.MailingState = currWishChildForm.State__c;
                     if(currWishChildForm.Zip_code__c != Null)
                         currContact.MailingPostalcode = currWishChildForm.Zip_code__c;
                     
                     updateWishChildContact.add(currContact);
                 }
                 
                 if(currWishChildForm.Case__r.Contact.AccountId != Null)
                 {
                     updateAccount.id = currWishChildForm.Case__r.Contact.AccountId;
                     if(currWishChildForm.Emergency_First_Name__c != Null && currWishChildForm.Emergency_Last_Name__c != Null)
                     updateAccount.Emergency_Contact__c = currWishChildForm.Emergency_First_Name__c+' '+currWishChildForm.Emergency_Last_Name__c;
                     if(currWishChildForm.Emergency_First_Name__c != Null && currWishChildForm.Emergency_Last_Name__c != Null && currWishChildForm.Emergency_Middle_Name__c != Null)
                     updateAccount.Emergency_Contact__c = currWishChildForm.Emergency_First_Name__c+' '+currWishChildForm.Emergency_Middle_Name__c+' '+currWishChildForm.Emergency_Last_Name__c;
                     updateAccount.Emergency_Contact_Phone__c = currWishChildForm.Emergency_Mobilephone__c;
                     updateAccount.Relationship_type__c = currWishChildForm.Emergency_Relationship__c;
                     updateAccount.Emergency_Contact_Middle_Name__c = currWishChildForm.Emergency_Middle_Name__c;
                     updateAccount.Emergency_Contact_Email__c = currWishChildForm.Emergency_Email__c; 
                     updateWishFamilyAccount.add(updateAccount);
                 }
                 
             
                 
                 if(currWishChildForm.Wish_Family_Contact__c != Null)
                  {
                      String jsonString = currWishChildForm.Wish_Family_Contact__c;
                      JsonString = jsonString.replace('&quot;', '"');
                      List<WishChildFormUtil.WrapperClass> wrapFamilyList = (List<WishChildFormUtil.WrapperClass>) System.JSON.deserialize(jsonString, List<WishChildFormUtil.WrapperClass>.class);
                 
                      for(WishChildFormUtil.WrapperClass  currRec : wrapFamilyList)
                      {
                        Contact newContact = new Contact();
                        newContact.RecordTypeId = wishFamilyDT;
                        //newContact.Wish_Child_Id_Hidden__c = currWishChildForm.case__r.contactId;
                         newContact.Hidden_Wish_Child_Id__c = currWishChildForm.case__r.contactId;
                        
                            newContact.FirstName = (currRec.FirstName!=Null)?currRec.FirstName:'';
                            newContact.Middle_Name__c = (currRec.MiddleName!=Null)?currRec.MiddleName:'';
                            newContact.LastName =  (currRec.lastName!=Null)?currRec.lastName:'';
                            newContact.Relationship__c = (currRec.Relationship!=Null)?currRec.Relationship:'';
                            newContact.HomePhone = (currRec.homeTelephone!=Null)?currRec.homeTelephone:'';
                            newContact.Work_Phone__c = (currRec.workTelephone!=Null)?currRec.workTelephone:'';
                            newContact.MobilePhone = (currRec.mobileTelephone!=Null)?currRec.mobileTelephone:'';
                            newContact.Email =  (currRec.Email!=Null)?currRec.Email:'';
                            newContact.BirthDate = (currRec.dob!=Null)?Date.valueOf(currRec.dob):currRec.dob;
                            newContact.IsParentGuardian__c = 'ParentGuardian';
                            newContact.Region_Chapter__c = ChapterAccId;
                            newContact.Language__c  = currWishChildForm.case__r.contact.Language__c;
                            if(currRec.relId != Null)
                            {
                              newContact.id = currRec.RelId;
                                  contactIds.add(newContact.Id);
                              System.debug('currRec.RelId;+++++++++++++++++++++++++++++++++++++ ' +currRec.RelId);
                            }
                              
                            createNewWishFamily.put(newContact.FirstName+'-'+newContact.lastName+'-'+newContact.Relationship__c,newContact);
                            
                        
                        
                      }
                 }
                 
                 
               if(currWishChildForm.Driver_Details__c!= Null)
                {
                    
                     String jsonString = currWishChildForm.Driver_Details__c;
                     JsonString = jsonString.replace('&quot;', '"');
                     List<WishChildFormUtil.DriverWrapper> wrapDriverList = (List<WishChildFormUtil.DriverWrapper>) System.JSON.deserialize(jsonString, List<WishChildFormUtil.DriverWrapper>.class);
                    
                        
                      for(WishChildFormUtil.DriverWrapper currRec : wrapDriverList)
                      {
                                WishChildFormUtil.DriverWrapper wrapCls = new WishChildFormUtil.DriverWrapper();
                                wrapCls.driverName  = (currRec.driverName!=Null)?currRec.driverName :'';
                                wrapCls.licenseNum  = (currRec.licenseNum !=Null)?currRec.licenseNum :'';
                                wrapCls.state  = (currRec.state !=Null)?currRec.state :'';
                                wrapCls.expirationDate  = (currRec.expirationDate!=Null)?Date.valueOf(currRec.expirationDate):Null;
                                wrapCls.type =  (currRec.type!=Null)?currRec.type:'';
                                driverWrapperClsMap.put(wrapCls.driverName,wrapCls);
                      }
                    
                  
                 }
                 
                 if(currWishChildForm.Participant_Contacts__c != Null)
                 {
                      String jsonString = currWishChildForm.Participant_Contacts__c;
                      JsonString = jsonString.replace('&quot;', '"');
                      List<WishChildFormUtil.WrapperClass> wrapParticipantsList = (List<WishChildFormUtil.WrapperClass>) System.JSON.deserialize(jsonString, List<WishChildFormUtil.WrapperClass>.class);
                      for(WishChildFormUtil.WrapperClass  currRec : wrapParticipantsList )
                      {
                      
                        Contact newContact = new Contact();
                        newContact.RecordTypeId = wishFamilyDT;
                       // newContact.Wish_Child_Id_Hidden__c = currWishChildForm.case__r.contactId;
                        newContact.Hidden_Wish_Child_Id__c = currWishChildForm.case__r.contactId;
                     
                        newContact.FirstName = (currRec.FirstName!=Null)?currRec.FirstName:'';
                        if(newContact.FirstName !='')
                            firstNamesSet.add(newContact.FirstName);
                        newContact.Middle_Name__c = (currRec.MiddleName!=Null)?currRec.MiddleName:'';
                        newContact.LastName = (currRec.lastName!=Null)?currRec.lastName:'';
                        if(newContact.lastName != '')
                            lastNamesSet.add(newContact.lastName); 
                        newContact.Relationship__c =  (currRec.Relationship!=Null)?currRec.Relationship:'';
                        if(newContact.Relationship__c != '')
                           relationshipsSet.add(newContact.Relationship__c); 
                        
                         newContact.BirthDate = (currRec.dob !=Null)?Date.valueOf(currRec.dob):currRec.dob;
                         newContact.Email = (currRec.Email!=Null)?currRec.Email:'';
                         newContact.T_Shirt_Size__c = (currRec.tshirtSize!=Null)?currRec.tshirtSize:'';
                         newContact.Medical_Needs__c = currRec.medicalNeeds;
                         newContact.Residing_with_Wish_child__c = currRec.residingWishMedical;
                         newContact.IsParentGuardian__c = 'Participant';
                         newContact.Region_Chapter__c = ChapterAccId;
                         newContact.Language__c  = currWishChildForm.case__r.contact.Language__c;
                        if(driverWrapperClsMap.containsKey(newContact.FirstName+' '+newContact.LastName))
                        {
                           newContact.MailingState = driverWrapperClsMap.get(newContact.FirstName+' '+newContact.LastName).State;
                           newContact.Valid_D_L__c = driverWrapperClsMap.get(newContact.FirstName+' '+newContact.LastName).licenseNum;
                           newContact.Expiration_Date__c = driverWrapperClsMap.get(newContact.FirstName+' '+newContact.LastName).expirationDate;
                           newContact.Driver_Type__c = driverWrapperClsMap.get(newContact.FirstName+' '+newContact.LastName).type;
                        }
                        
                        if(createNewWishFamily.containsKey(newContact.FirstName+'-'+newContact.lastName+'-'+newContact.Relationship__c))
                        {
                            newContact.id = createNewWishFamily.get(newContact.FirstName+'-'+newContact.lastName+'-'+newContact.Relationship__c).id;
                            sameFamilyMap.put(newContact.FirstName+'-'+newContact.lastName,newContact);
                            System.debug('currRec.RelId;+++++++++++++++++++++++++++++++++++++ ' +newContact.id);
                            newContact.IsParentGuardian__c = 'ParentGuardian';
                           newContact.Region_Chapter__c = ChapterAccId;
                            if(newContact.id != Null)
                                contactIds.add(newContact.Id);
                        }
                            
                            createNewWishFamily.put(newContact.FirstName+'-'+newContact.lastName+'-'+newContact.Relationship__c,newContact);
                  
                 
                      }
                 
                 
                 
                 
                 
                 
                    
                 }
                 
              }
              
              
              System.debug('firstNamesSet++++++++++++++++++++++++++ ' + firstNamesSet);
              System.debug('lastNamesSet++++++++++++++++++++++++++ ' + lastNamesSet);
              System.debug('relationshipsSet++++++++++++++++++++++++++ ' + relationshipsSet);
              
               Map<String, Contact> existingContactMap = new Map<String, Contact>();
               Map<String,String> existingRelationMap = new Map<String,String>();
               
               Map<Id, Contact> existingContacts = new Map<Id, Contact>();
               
              for(Contact exContact : [SELECT ID,firstname, lastname, Relationship__c from Contact WHERE (firstName IN :firstNamesSet AND
                                      LastName IN :lastNamesSet AND Relationship__c IN :relationshipsSet)])
              {
              
                  existingContactMap.put(exContact.firstname+'-'+exContact.lastname+'-'+exContact.Relationship__c,exContact);
                
              }
              
              System.debug('existingContactMap+++++++++++++++++++++++++++++++++ ' + existingContactMap);
              
              Map<String,Contact> toUpdateContact = new Map<String,Contact>();  
              for(Contact currCon : createNewWishFamily.values())
              {
                 System.debug('currCon ++++++++++++++++++++++++++++++++++++++ ' + currCon.id);
                 System.debug('currCon ++++++++++++++++++++++++++++++++++++++ ' + currCon.Wish_Child_Id_Hidden__c); 
                if(existingContactMap.containsKey(currCon.firstName+'-'+currCon.lastname+'-'+currCon.Relationship__c))
                {
                   // currCon.id = existingContactMap.get(currCon.firstName+'-'+currCon.lastname+'-'+currCon.Relationship__c).id;
                }
                
                
                 toUpdateContact.put(currCon.firstName+'-'+currCon.lastname+'-'+currCon.Relationship__c,currCon); 
              }
              
              
              if(updateWishDeterminationCaseList.size() > 0)
                 update updateWishDeterminationCaseList;
              if(toUpdateContact.size() > 0)
              { if(!Test.isRunningTest())
                Upsert toUpdateContact.values();
                System.debug('toUpdateContact++++++++++++++++++++++++++++++++++ ' +toUpdateContact);
              }
              if(updateWishFamilyAccount.size() > 0)
                update updateWishFamilyAccount;
              if(updateWishChildContact.size() > 0)  
                update updateWishChildContact;
                
             System.debug('updateWishDeterminationCaseList+++++++++++++++++++++++++++++++++++= ' + updateWishDeterminationCaseList);      
                
            // Create Relationship Records.  
            
              //  Map<String,String> existingRelationMap = new Map<String,String>();
                for(npe4__Relationship__c currRel : [SELECT Id,npe4__Contact__c,npe4__RelatedContact__c  FROM npe4__Relationship__c 
                                                     WHERE npe4__Contact__c  IN :wishChildIds] )
                {
                    existingRelationMap.put(currRel.npe4__Contact__c+'-'+currRel.npe4__RelatedContact__c, currRel.id);
                }
              
             System.debug('existingRelationMap++++++++++++++++++++++++++++= ' + existingRelationMap);  
            
             List<npe4__Relationship__c> relationshipList = new  List<npe4__Relationship__c>();
             for(Contact newContact : toUpdateContact.values())
             {
                npe4__Relationship__c newRelation = new npe4__Relationship__c();
               
                newRelation.npe4__Type__c  = newContact.Relationship__c;
                newRelation.Medical_Needs__c = newContact.Medical_Needs__c;
                newRelation.Residing_with_Wish_child__c = newContact.Residing_with_Wish_child__c;
                String name = newContact.FirstName+'-'+newContact.LastName;
                System.debug('-----name ----- ' +newRelation);
                if(sameFamilyMap.containsKey(name)){
                    newRelation.Parent_Legal_Guardian__c = true;
                    newRelation.Wish_Participant__c = true;
                }
                else{
                if(newContact.IsParentGuardian__c == 'ParentGuardian'){
                        newRelation.Parent_Legal_Guardian__c = true;
                }
                if(newContact.IsParentGuardian__c == 'Participant'){
                        newRelation.Wish_Participant__c = true;
                         Date dt = Date.Valueof(newContact.Birthdate);
                         Integer days = dt.daysBetween(Date.Today());
                         integer age = Integer.valueOf(days/365);
                         if(age < 18){
                             newRelation.Under_18__c = true;
                         }
    
                }
              }  
                if(existingRelationMap.containsKey(newContact.Hidden_Wish_Child_Id__c+'-'+newContact.id))
                {
                  newRelation.id = existingRelationMap.get(newContact.Hidden_Wish_Child_Id__c+'-'+newContact.id);
               
                }
                
                else
                {
                   System.debug('newContact.Hidden_Wish_Child_Id__c++++++++++++++++++++++++++= ' + newContact.Hidden_Wish_Child_Id__c);
                     newRelation.npe4__Contact__c  = newContact.Hidden_Wish_Child_Id__c;
                     newRelation.npe4__RelatedContact__c  = newContact.id;
                }
                  
                relationshipList.add(newRelation);
               
             }
             
             if(relationshipList.size() > 0)
             {   if(!Test.isRunningTest())
                 upsert relationshipList;
             }
           
     }

      // Medical Referral Field set contains the mandatory fields of Medical Professional.
     public static List<Schema.FieldSetMember> getWishChildFields() 
     {
        return SObjectType.Wish_child_form__c.FieldSets.Wish_Child_Contact_Map.getFields();

     }
      
      
    public class DriverWrapper
    {
       public string driverName{get;set;}
       public String licenseNum{get;set;}
       public string state{get;set;}
       public Date expirationDate{get;set;}
       public string type{get;set;}
    }   
      
     

}