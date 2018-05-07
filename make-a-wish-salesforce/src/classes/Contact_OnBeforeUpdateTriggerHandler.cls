/***************************************************************************************************
Author      : MST Solutions
Date        : 04/05/2018
Description : Contact_OnBeforeUpdateTriggerHandler is used assign the values to contact record based on the conditions when 
the contact record is get updated.

Modification Log
------------------
WVC-1884    KANAGARAJ  04/04/2018
STT-119     KESAVAKUMAR 04/10/2018

*****************************************************************************************************/
public class Contact_OnBeforeUpdateTriggerHandler{
    
    static Constant_AC  constant = new Constant_AC();
    static Id volunteerRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.volunteerRT).getRecordTypeId();
    static Id boardMemberRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.boardMemberRT).getRecordTypeId();
    static Id wichChildRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.contactWishChildRT).getRecordTypeId();
    
    //Assign the values to contact records, based on the conditions.
    public static void onBeforeUpdate(map<Id,Contact> newContactMap,map<Id,Contact> oldContactMap){
        
        Set<Id> wishChildIdSet = new Set<Id>();
        Map<Id,Contact> wishFamilyMap = new Map<Id,Contact>();
        Set<Id> wishFamliySet = new Set<Id>();
        set<Id> recallWishChild = new Set<Id>();
        List<Account> accList = new List<Account>();
        Map<Id,Account> houseHoldAccountMap = new Map<Id,Account>();
        Set<Id> icdCodeInfoIdSet = new Set<Id>();
        Map<Id, Set<Integer>> icdInfoMap = new Map<Id, Set<Integer>>();
        List<Contact> conICDList = new List<Contact>();
        Map<Id,Contact> ConrelationshipIdMap = new Map<Id,Contact>();
        Set<Id> removePrefIdSet = new Set<Id>();
        List<npe4__Relationship__c> updateRelList = new List<npe4__Relationship__c>();
        Map<Id,Id> relationshipContactIdMap = new Map<Id,Id>();
        Map<Id,Contact> wishChildCaseIdMap = new Map<Id,Contact>();
        String dummyValue = Label.Dummy_Email;
        List<case> updateCaseList = new List<Case>();
        Map<String, String> monthValMap = new Map<String, String>();
        Map<String, String> monthNameMap = new Map<String, String>();
        monthValMap.put('January','1');
        monthValMap.put('February','2');
        monthValMap.put('March','3');
        monthValMap.put('April','4');
        monthValMap.put('May','5');
        monthValMap.put('June','6');
        monthValMap.put('July','7');
        monthValMap.put('August','8');
        monthValMap.put('September','9');
        monthValMap.put('October','10');
        monthValMap.put('November','11');
        monthValMap.put('December','12');
        
        monthNameMap.put('1','January');
        monthNameMap.put('2','February');
        monthNameMap.put('3','March');
        monthNameMap.put('4','April');
        monthNameMap.put('5','May');
        monthNameMap.put('6','June');
        monthNameMap.put('7','July');
        monthNameMap.put('8','August');
        monthNameMap.put('9','September');
        monthNameMap.put('10','October');
        monthNameMap.put('11','November');
        monthNameMap.put('12','December');
        
       
        for(Contact newContact : newContactMap.values())
        { 
            if(Bypass_Triggers__c.getValues(userInfo.getUserId()) == Null)
            {    //the mailing address is already marked as verified and one of the mailing address fields changed
                if(newContact.MailingStreet != oldContactMap.get(newContact.Id).MailingStreet || newContact.MailingState != oldContactMap.get(newContact.Id).MailingState ||
                   newContact.MailingStateCode != oldContactMap.get(newContact.Id).MailingStateCode ||
                   newContact.MailingCity != oldContactMap.get(newContact.Id).MailingCity ||
                   newContact.MailingPostalCode != oldContactMap.get(newContact.Id).MailingPostalCode){
                       
                       newContact.MailingAddressVerified__c = false;
                       newContact.MailingAddressVerificationAttempted__c = null;
                       newContact.County__c = ' ';
                       
                   }
                
                // the other address is already marked as verified and one of the other address fields changed.
                if(newContact.OtherStreet != oldContactMap.get(newContact.Id).OtherStreet || newContact.OtherState != oldContactMap.get(newContact.Id).OtherState ||
                   newContact.OtherStateCode != oldContactMap.get(newContact.Id).OtherStateCode ||
                   newContact.OtherCity != oldContactMap.get(newContact.Id).OtherCity ||
                   newContact.OtherPostalCode != oldContactMap.get(newContact.Id).OtherPostalCode){
                       newContact.OtherAddressVerified__c = false;
                       newContact.OtherAddressVerificationAttempted__c = null;
                       
                   }
                
                if(newContact.SD1_ICD_Code__c != oldContactMap.get(newContact.Id).SD1_ICD_Code__c && newContact.SD1_ICD_Code__c != null) {
                    icdCodeInfoIdSet.add(newContact.SD1_ICD_Code__c);
                    conICDList.add(newContact);
                    if(icdInfoMap.containsKey(newContact.Id)) {
                        icdInfoMap.get(newContact.Id).add(1);
                    } else {
                        icdInfoMap.put(newContact.Id, new Set<Integer>{1});
                    }
                }
                //To update Secondary Diagnosis2 if ICD Code2 value is changed
                if(newContact.SD2_ICD_Code__c != oldContactMap.get(newContact.Id).SD2_ICD_Code__c && newContact.SD2_ICD_Code__c != null) {
                    icdCodeInfoIdSet.add(newContact.SD2_ICD_Code__c);
                    conICDList.add(newContact);
                    if(icdInfoMap.containsKey(newContact.Id)) {
                        icdInfoMap.get(newContact.Id).add(2);
                    } else {
                        icdInfoMap.put(newContact.Id, new Set<Integer>{2});
                    }
                }
                //To update Secondary Diagnosis3 if ICD Code3 value is changed
                if(newContact.SD3_ICD_Code__c != oldContactMap.get(newContact.Id).SD3_ICD_Code__c && newContact.SD3_ICD_Code__c != null) {
                    icdCodeInfoIdSet.add(newContact.SD3_ICD_Code__c);
                    conICDList.add(newContact);
                    if(icdInfoMap.containsKey(newContact.Id)) {
                        icdInfoMap.get(newContact.Id).add(3);
                    } else {
                        icdInfoMap.put(newContact.Id, new Set<Integer>{3});
                    }
                }
                //To update Secondary Diagnosis4  if ICD Code4 value is changed
                if(newContact.SD4_ICD_Code__c != oldContactMap.get(newContact.Id).SD4_ICD_Code__c && newContact.SD4_ICD_Code__c != null) {
                    icdCodeInfoIdSet.add(newContact.SD4_ICD_Code__c);
                    conICDList.add(newContact);
                    if(icdInfoMap.containsKey(newContact.Id)) {
                        icdInfoMap.get(newContact.Id).add(4);
                    } else {
                        icdInfoMap.put(newContact.Id, new Set<Integer>{4});
                    }
                }
                
                //To update Secondary Diagnosis4  if ICD Code4 value is changed
                if(newContact.ICD_10_Code__c != oldContactMap.get(newContact.Id).ICD_10_Code__c && newContact.ICD_10_Code__c != null) {
                    icdCodeInfoIdSet.add(newContact.ICD_10_Code__c);
                    conICDList.add(newContact);
                    if(icdInfoMap.containsKey(newContact.Id)) {
                        icdInfoMap.get(newContact.Id).add(5);
                    } else {
                        icdInfoMap.put(newContact.Id, new Set<Integer>{5});
                    }
                }
                
                
                if(newContact.RecordTypeId == volunteerRecordTypeId && newContact.RecordTypeId != oldContactMap.get(newContact.Id).RecordTypeId){
                    newContact.AccountId = newContact.Region_Chapter__c;   
                }
                
                if(newContact.Birth_Year__c != oldContactMap.get(newContact.Id).Birth_Year__c || newContact.Birth_Month__c != oldContactMap.get(newContact.Id).Birth_Month__c || newContact.Birth_Day__c != oldContactMap.get(newContact.Id).Birth_Day__c )
                {
                    if(newContact.Birth_Month__c != Null && newContact.Birth_Day__c != Null && newContact.Birth_Year__c != Null) {
                        date dtConverted = Date.valueOf(newContact.birth_year__c+'-'+monthValMap.get(newContact.birth_month__c)+'-'+newContact.birth_day__c);
                        newContact.BirthDate = dtConverted ;
                    } else {
                        newContact.BirthDate = NULL;
                    }
                    
                } else if(newContact.BirthDate != NULL && newContact.BirthDate != oldContactMap.get(newContact.Id).BirthDate) {
                    newContact.Birth_Month__c = monthNameMap.get(String.valueOf(newContact.BirthDate.month()));
                    newContact.Birth_Year__c = String.valueOf(newContact.BirthDate.year());
                    newContact.birth_day__c = String.valueOf(newContact.BirthDate.day());
                } else if(newContact.BirthDate == NULL && newContact.BirthDate != oldContactMap.get(newContact.Id).BirthDate) {
                    newContact.Birth_Month__c = '';
                    newContact.Birth_Year__c = '';
                    newContact.birth_day__c = '';
                }
                
                
                if(newContact.RecordTypeId == volunteerRecordTypeId || newContact.RecordTypeId == boardMemberRT)
                {
                    if(newContact.is_Active_Volunteer__c == false && (newContact.Active_Board_Member__c == True || newContact.Active_Non_Wish_Granter__c==True
                                                                      || newContact.Active_Single_Day_Event_Volunteer__c == True || newContact.Active_Wish_Granter__c == True))
                    {
                        newContact.is_Active_Volunteer__c = True;
                    }  
                    
                    if(newContact.is_Active_Volunteer__c == True && (newContact.Active_Board_Member__c == false && newContact.Active_Non_Wish_Granter__c==false
                                                                     && newContact.Active_Single_Day_Event_Volunteer__c == false && newContact.Active_Wish_Granter__c == false))
                    {
                        newContact.is_Active_Volunteer__c = false;
                    } 
                    
                }
                
                if(newContact.RecordTypeId == wichChildRecordTypeId && newContact.IsContactInfoUpdated__c == true)
                {
                    if(newContact.Hidden_First_Name__c != Null)
                    {
                        newContact.FirstName =  newContact.Hidden_First_Name__c;
                        newContact.Hidden_First_Name__c = Null;
                        newContact.IsContactInfoUpdated__c = false;
                    }
                    else{
                        
                        wishChildIdSet.add(newContact.Id);
                        newContact.IsContactInfoUpdated__c = false;
                    }
                    if(newContact.Hidden_Last_Name__c != Null)
                    {
                        newContact.LastName  =  newContact.Hidden_Last_Name__c;
                        newContact.Hidden_Last_Name__c = Null;
                        newContact.IsContactInfoUpdated__c = false;
                    }
                    else{
                        
                        wishChildIdSet.add(newContact.Id);
                        newContact.IsContactInfoUpdated__c = false;
                    }
                    if(newContact.Hidden_Phone__c != Null && newContact.Hidden_Phone__c != '9912121313' ){
                        newContact.HomePhone =   newContact.Hidden_Phone__c; 
                        newContact.Hidden_Phone__c = Null;
                        newContact.IsContactInfoUpdated__c = false;
                    }
                    else{
                        if(newContact.Hidden_Phone__c == '9912121313'){
                            newContact.HomePhone = null; 
                        }
                        wishChildIdSet.add(newContact.Id);
                        newContact.IsContactInfoUpdated__c = false;
                    }
                    if(newContact.HiddenOtherPhone__c!= Null && newContact.HiddenOtherPhone__c!= '9912121313' ){
                        newContact.OtherPhone =   newContact.HiddenOtherPhone__c; 
                        newContact.HiddenOtherPhone__c = Null;
                        newContact.IsContactInfoUpdated__c = false;
                        
                        
                    }
                    else{
                        if(newContact.HiddenOtherPhone__c == '9912121313'){
                            newContact.OtherPhone = null;
                        }
                        
                        wishChildIdSet.add(newContact.Id);
                        newContact.IsContactInfoUpdated__c = false;
                    }
                    if(newContact.HiddenMobilePhone__c!= Null && newContact.HiddenMobilePhone__c != '9912121313'){
                        newContact.MobilePhone =   newContact.HiddenMobilePhone__c; 
                        newContact.HiddenMobilePhone__c= Null;
                        newContact.IsContactInfoUpdated__c = false;
                    }
                    else{
                        
                        if(newContact.HiddenMobilePhone__c == '9912121313'){
                            newContact.MobilePhone = null;
                        }
                        
                        wishChildIdSet.add(newContact.Id);
                        newContact.IsContactInfoUpdated__c = false;
                    }
                    if(newContact.Hidden_Email__c != Null && newContact.Hidden_Email__c != dummyValue){
                        newContact.Email  =   newContact.Hidden_Email__c;
                        newContact.Hidden_Email__c = Null;
                        newContact.IsContactInfoUpdated__c = false;
                        
                    }
                    else{
                        
                        if(newContact.Hidden_Email__c == dummyValue){
                            newContact.Email  = null;
                        }
                        
                        wishChildIdSet.add(newContact.Id);
                        newContact.IsContactInfoUpdated__c = false;
                    } 
                    if(newContact.Hidden_Street__c != Null && newContact.Hidden_Street__c != dummyValue){
                        newContact.MailingStreet =   newContact.Hidden_Street__c; 
                        newContact.Hidden_Street__c = Null;
                        newContact.IsContactInfoUpdated__c = false;
                        
                    }
                    else{
                        if(newContact.Hidden_Street__c == dummyValue){
                            newContact.MailingStreet = null; 
                        }
                        
                        wishChildIdSet.add(newContact.Id);
                        newContact.IsContactInfoUpdated__c = false;
                    }
                    if(newContact.Hidden_city__c != Null && newContact.Hidden_city__c != dummyValue){
                        newContact.MailingCity =   newContact.Hidden_city__c;
                        newContact.Hidden_city__c = Null;
                        newContact.IsContactInfoUpdated__c = false;
                        
                    }
                    else{
                        
                        if(newContact.Hidden_city__c == dummyValue){
                            newContact.MailingCity =  null; 
                        }
                        wishChildIdSet.add(newContact.Id);
                        newContact.IsContactInfoUpdated__c = false;
                    }
                    if(newContact.Hidden_State__c != Null && newContact.Hidden_State__c != dummyValue){
                        newContact.MailingState =   newContact.Hidden_State__c; 
                        newContact.Hidden_State__c = Null;
                        newContact.IsContactInfoUpdated__c = false;
                        
                    }
                    else{
                        
                        if(newContact.Hidden_State__c == dummyValue){
                            newContact.MailingState = null;
                        }
                        wishChildIdSet.add(newContact.Id);
                        newContact.IsContactInfoUpdated__c = false;
                    }
                    if(newContact.Hidden_Country__c != Null && newContact.Hidden_Country__c != dummyValue){
                        newContact.MailingCountry =   newContact.Hidden_Country__c;
                        newContact.Hidden_Country__c  = Null;
                        newContact.IsContactInfoUpdated__c = false;
                        
                    }
                    else{
                        if(newContact.Hidden_Country__c == dummyValue){
                            newContact.MailingCountry = null;
                        }
                        wishChildIdSet.add(newContact.Id);
                        newContact.IsContactInfoUpdated__c = false;
                    }
                    if(newContact.Hidden_Zip_Code__c != Null && newContact.Hidden_Zip_Code__c != '11111'){
                        newContact.MailingPostalCode =   newContact.Hidden_Zip_Code__c; 
                        newContact.Hidden_Zip_Code__c = Null;
                        newContact.IsContactInfoUpdated__c = false;
                        
                    }
                    else{
                        if(newContact.Hidden_Zip_Code__c == '11111'){
                            newContact.MailingPostalCode =  null;
                        }
                        wishChildIdSet.add(newContact.Id);
                        newContact.IsContactInfoUpdated__c = false;
                    }
                    
                    if(newContact.Hidden_Preferred_Contact_Rel_Id__c != Null && newContact.Hidden_Preferred_Contact_Rel_Id__c != 'Remove'){
                        newContact.Hidden_Current_Pref_Con_Rel_Id__c = newContact.Hidden_Preferred_Contact_Rel_Id__c;
                        conrelationshipIdMap.put(newContact.Hidden_Preferred_Contact_Rel_Id__c,newContact); 
                        wishChildCaseIdMap.put(newContact.Id,newContact);
                        removePrefIdSet.add(newContact.Id);                        
                        newContact.Hidden_Preferred_Contact_Rel_Id__c = Null;
                        newContact.IsContactInfoUpdated__c = false; 
                        
                    }
                    else{
                        wishChildIdSet.add(newContact.Id);
                        newContact.IsContactInfoUpdated__c = false; 
                    }
                    
                    system.debug('ConrelationshipIdMap below assigned'+ConrelationshipIdMap);
                    if(newContact.Hidden_Preferred_Contact_Rel_Id__c == 'Remove'){
                        newContact.Preferred_Contact_Name__c = '';
                        newContact.Preferred_Contact_Relationship__c = '';
                        newContact.Preferred_Contact_Number__c = '';
                        newContact.Hidden_Preferred_Contact_Rel_Id__c = '';
                        newContact.Hidden_Current_Pref_Con_Rel_Id__c = '';
                        newContact.IsContactInfoUpdated__c = false;
                        wishChildCaseIdMap.put(newContact.Id,newContact);
                        removePrefIdSet.add(newContact.Id);
                        //wishChildIdSet.add(newContact.Id);
                    }
                    else{
                        wishChildIdSet.add(newContact.Id);
                        newContact.IsContactInfoUpdated__c = false; 
                    }
                    if((newContact.Hidden_Current_Pref_Con_Rel_Id__c != Null && newContact.Hidden_Current_Pref_Con_Rel_Id__c != '') && newContact.Hidden_Preferred_Contact_Rel_Id__c != 'Remove'){
                        system.debug('ConrelationshipIdMap below assigned2'+ConrelationshipIdMap);
                        conrelationshipIdMap.put(newContact.Hidden_Current_Pref_Con_Rel_Id__c,newContact); 
                        system.debug('ConrelationshipIdMap below assigned3'+ConrelationshipIdMap);
                    }
                    system.debug('ConrelationshipIdMap below assigned4'+ConrelationshipIdMap);
                }
                
                if(newContact.RecordTypeId == wichChildRecordTypeId && newContact.IsRejected_Contact_Info__c == true || newContact.isRecall_Contact_Info__c == true)
                {
                    if(newContact.Hidden_First_Name__c != Null || newContact.Hidden_Last_Name__c != Null ||  newContact.Hidden_Phone__c != Null|| 
                       newContact.Hidden_Email__c != Null || newContact.Hidden_Street__c != Null ||  newContact.Hidden_State__c != Null || newContact.HiddenOtherPhone__c != Null || newContact.HiddenMobilePhone__c  != Null || 
                       newContact.Hidden_Country__c != Null ||   newContact.Hidden_Zip_Code__c != Null ||  newContact.Hidden_city__c != Null || newContact.Hidden_Preferred_Contact_Rel_Id__c != Null ){     //|| newContact.Hidden_Preferred_Contact_Rel_Id__c == 'Remove'){ 
                           
                           newContact.Hidden_First_Name__c = Null;
                           newContact.Hidden_Last_Name__c = Null;
                           newContact.Hidden_Phone__c = Null;
                           newContact.HiddenMobilePhone__c = Null;
                           newContact.HiddenOtherPhone__c = Null;
                           newContact.Hidden_Email__c = Null;
                           newContact.Hidden_Street__c = Null;
                           newContact.Hidden_State__c = Null;
                           newContact.Hidden_Country__c  = Null;
                           newContact.Hidden_Zip_Code__c = Null;
                           newContact.Hidden_city__c = Null;
                           newContact.Hidden_Preferred_Contact_Rel_Id__c = Null;
                       }
                   // else
                   //{
                        recallWishChild.add(newContact.Id);
                        newContact.IsRejected_Contact_Info__c  = false;
                        newContact.isRecall_Contact_Info__c = false;
                    //}
                }
            } 
        }
        if(wishChildIdSet.size() > 0 && RecursiveTriggerHandler.accountRecursive == true){
            Contact_OnBeforeUpdateTriggerHelper.updateFamilyConInfo(wishChildIdSet,ConrelationshipIdMap,removePrefIdSet);
        }
        if(recallWishChild.size() > 0){
            Contact_OnBeforeUpdateTriggerHelper.recallApproval(recallWishChild);
        }
        if(icdInfoMap.size() > 0) {
            MatchConditionDescription(icdInfoMap,conICDList,icdCodeInfoIdSet);
        }
    }
    
    //Used to populated Condition Description based on ICD Code values
    public static void MatchConditionDescription(Map<Id, Set<Integer>> icdInfoMap, List<Contact> leadRecList, Set<Id> icdCodeRecSet) {
        Map<Id, ICD_Codes__c> icdCodeDetails = new Map<Id, ICD_Codes__c>();
        for(ICD_Codes__c icdInfo : [SELECT Id, Name, Group1__c,
                                    Condition_Description__c, Condition_Description__r.Code_to_Use__c, Condition_Description__r.Name
                                    FROM ICD_Codes__c WHERE Id IN : icdCodeRecSet]){
                                        icdCodeDetails.put(icdInfo.Id, icdInfo);
                                    }
        
        for(Contact updatePD : leadRecList) {
            if(icdInfoMap.containsKey(updatePD.Id)) {
                for(Integer icdField : icdInfoMap.get(updatePD.Id)) {
                    if(icdField == 1 && icdCodeDetails.containsKey(updatePD.SD1_ICD_Code__c)) {
                        updatePD.SD1_Condition_Description__c = icdCodeDetails.get(updatePD.SD1_ICD_Code__c).Condition_Description__r.Name;
                    } if(icdField == 2 && icdCodeDetails.containsKey(updatePD.SD2_ICD_Code__c)) {
                        updatePD.SD2_Condition_Description__c = icdCodeDetails.get(updatePD.SD2_ICD_Code__c).Condition_Description__r.Name;
                    } if(icdField == 3 && icdCodeDetails.containsKey(updatePD.SD3_ICD_Code__c)) {
                        updatePD.SD3_Condition_Description__c = icdCodeDetails.get(updatePD.SD3_ICD_Code__c).Condition_Description__r.Name;
                    } if(icdField == 4 && icdCodeDetails.containsKey(updatePD.SD4_ICD_Code__c)) {
                        updatePD.SD4_Condition_Description__c = icdCodeDetails.get(updatePD.SD4_ICD_Code__c).Condition_Description__r.Name;
                    } if(icdField == 5 && icdCodeDetails.containsKey(updatePD.ICD_10_Code__c)) {
                        updatePD.Diagnosis__c = icdCodeDetails.get(updatePD.ICD_10_Code__c).Condition_Description__r.Name;
                    }
                }
            }
        }
    }
}