/***************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kanagaraj
Date        : 26/05/2016
Description :

Modification Log :
1. 26/03/18 - Vignesh SM - IME 18 - Line No 57-59
2. 27/03/18 - Yuvraj - IME-60 - Line No: 34, 134, 247-249
3. 29/03/18 - Vignesh SM - IME 58 - Line No 230-232, 260-262
4. 09/04/18 - Yuvraj - IME-77 - Line No: 63, 240-242.
5. 18/04/18 - Vignesh SM - IME 110 Line No: 189, 196
*****************************************************************************************************/
Public Class Lead_OnBeforeUpdateTriggerHandler{

    public static void onBeforeUpdate(Map<Id,Lead> newLeadMap,Map<Id,Lead> oldLeadMap){
    
        List<Lead> updatedLeadList = new List<Lead>();
        Set<Id> accountIdSet = new Set<Id>();
        List<Lead> newLeadList = new List<Lead>();
        List<Lead> newUpdateLeadList = new List<Lead>();
        List<Lead> leadList = new List<Lead>();
        List<Lead> updateLeadOwnerList = new List<Lead>();
        Set<String> postalCodesSet = new Set<String>();
        List<Lead> updateChapterOnLeadList = new List<Lead>();
        Set<String> icdCodesSet = new Set<String>();
        Set<String> conditionDescriptionsSet = new Set<String>();
        List<Lead>  leadUpdateToMedicalInfoList = new List<Lead>();
        List<Lead> findduplicateList = new List<Lead>();
        List<Lead> leadQuestionList= new List<Lead>();
        Map<Id, Lead> leadRegionCodeValidationMap = new Map<Id, Lead>();
        List<Lead> findDupConList = new List<Lead>();
        Set<Id> icdCodeInfoIdSet = new Set<Id>();
        Set<String> newChaptersSet = new Set<String>();
        Map<Id, Set<Integer>> icdInfoMap = new Map<Id, Set<Integer>>();
        List<Lead> leadRecList = new List<Lead>();
        List<Lead> leadRequiredList = new List<Lead>();//IME-60
        List<Lead> qualifiedRushLeadList = new List<Lead>(); //IME 58
        
        Boolean flag;
         
         for(Lead newLead: newLeadMap.Values()){
           if(Bypass_Triggers__c.getValues(userInfo.getUserId()) == Null &&
               (newLead.Street != oldLeadMap.get(newLead.Id).Street ||
                newLead.State != oldLeadMap.get(newLead.Id).State ||
                newLead.StateCode != oldLeadMap.get(newLead.Id).StateCode ||
                newLead.City != oldLeadMap.get(newLead.Id).City ||
                newLead.PostalCode != oldLeadMap.get(newLead.Id).PostalCode
               )
              ){
                  newLead.AddressVerified__c = false;
                  newLead.AddressVerificationAttempted__c = null;
                  newLead.County__c = null;
                  
              }
              
             /* Removing as per IME 4 
              if(newLead.status == 'Eligibility Review' && oldLeadMap.get(newLead.Id).Status != 'Eligibility Review'){
                  newLead.Sub_Status__c = 'Chapter';
              }*/
             //IME 18
             if(newLead.status == 'Eligibility Review' && oldLeadMap.get(newLead.Id).Status != 'Eligibility Review' && oldLeadMap.get(newLead.Id).Status != 'DNQ'){
                 newLead.Sub_Status__c = 'New';
                 newLead.Eligibility_Review_Date__c = Date.today();//IME-77
             }
             if(newLead.status == 'DNQ' && oldLeadMap.get(newLead.Id).Status != 'DNQ'){
                 newLead.DNQ_Date__c = Date.today();//IME-77
             }
             if(newLead.ChapterName__c!= oldLeadMap.get(newLead.id).ChapterName__c && newLead.ChapterName__c != Null)
             {
                 updatedLeadList.add(newLead);
                 accountIdSet.add(newLead.ChapterName__c);
             }
           if(newLead.SD1_ICD_Code__c != oldLeadMap.get(newLead.Id).SD1_ICD_Code__c && newLead.SD1_ICD_Code__c != null) {
                icdCodeInfoIdSet.add(newLead.SD1_ICD_Code__c);
                leadRecList.add(newLead);
                if(icdInfoMap.containsKey(newLead.Id)) {
                    icdInfoMap.get(newLead.Id).add(1);
                } else {
                    icdInfoMap.put(newLead.Id, new Set<Integer>{1});
                }
            }
            if(newLead.Hidden_DV_form_Medical_professional_Type__c == 'Treating Medical Professional' && oldLeadMap.get(newLead.Id).Hidden_DV_form_Medical_professional_Type__c != newLead.Hidden_DV_form_Medical_professional_Type__c) {
                newLead.HiddenMedicalProfessionalEmail__c = newLead.Treating_Medical_Professional_Email__c;
            }
            if(newLead.SD2_ICD_Code__c != oldLeadMap.get(newLead.Id).SD2_ICD_Code__c && newLead.SD2_ICD_Code__c != null) {
                icdCodeInfoIdSet.add(newLead.SD2_ICD_Code__c);
                leadRecList.add(newLead);
                if(icdInfoMap.containsKey(newLead.Id)) {
                    icdInfoMap.get(newLead.Id).add(2);
                } else {
                    icdInfoMap.put(newLead.Id, new Set<Integer>{2});
                }
            }
            if(newLead.SD3_ICD_Code__c != oldLeadMap.get(newLead.Id).SD3_ICD_Code__c && newLead.SD3_ICD_Code__c != null) {
                icdCodeInfoIdSet.add(newLead.SD3_ICD_Code__c);
                leadRecList.add(newLead);
                if(icdInfoMap.containsKey(newLead.Id)) {
                    icdInfoMap.get(newLead.Id).add(3);
                } else {
                    icdInfoMap.put(newLead.Id, new Set<Integer>{3});
                }
            }
            if(newLead.SD4_ICD_Code__c != oldLeadMap.get(newLead.Id).SD4_ICD_Code__c && newLead.SD4_ICD_Code__c != null) {
                icdCodeInfoIdSet.add(newLead.SD4_ICD_Code__c);
                leadRecList.add(newLead);
                if(icdInfoMap.containsKey(newLead.Id)) {
                    icdInfoMap.get(newLead.Id).add(4);
                } else {
                    icdInfoMap.put(newLead.Id, new Set<Integer>{4});
                }
            }
             
             if(newLead.ICD_Given_By_Referrer__c != oldLeadMap.get(newLead.Id).ICD_Given_By_Referrer__c && newLead.ICD_Given_By_Referrer__c != null) {
                icdCodeInfoIdSet.add(newLead.ICD_Given_By_Referrer__c);
                leadRecList.add(newLead);
                if(icdInfoMap.containsKey(newLead.Id)) {
                    icdInfoMap.get(newLead.Id).add(5);
                } else {
                    icdInfoMap.put(newLead.Id, new Set<Integer>{5});
                }
            }
             
            if(newLead.Status == 'Referred' && oldLeadMap.get(newLead.id).status == 'Inquiry'){
                
                    newLead.Referred_Date__c = Date.today();
            }
            if(newLead.ChapterName__c!= oldLeadMap.get(newLead.id).ChapterName__c){
                newChaptersSet.add(newLead.ChapterName__c);
                updateLeadOwnerList.add(newLead);
            }
            if(oldLeadMap.get(newLead.id).Of_Times_Email_Sent__c != newLead.Of_Times_Email_Sent__c){
                
                    newLead.Part_A_Sent__c = Date.today();
            }
            if((newLead.Status == 'Eligibility Review') || (newLead.Status == 'Qualified') && oldLeadMap.get(newLead.id).Status == 'Referred'){
                newLead.Part_A_Received__c = Date.today();
            }
             
             /*Added as per IME 10,63*/
             if(newLead.Status == 'Qualified'){
                 newLead.Sub_Status__c = Null;
                 newLead.Qualified_Date__c = Date.today();//Added per IME-69
                     
                 /* removed as per IME 18
                 if(oldLeadMap.get(newLead.id).Status != 'Eligibility Review' && oldLeadMap.get(newLead.id).Status != 'Qualified'){
                     newLead.Auto_Qualified__c = true;
                 }*/          
             }
             /*IME 10,63*/
             //IME-60
             if(newLead.Status == 'Qualified' && (!newLead.Is_Required_Bypass__c)){
                 leadRequiredList.add(newLead);     
             }             
             
            if(newLead.Status == 'Eligibility Review' && newLead.Sub_Status__c == 'Pending Diagnosis Verification')
                newLead.Sub_Status__c = Null;
            
            if(newLead.Treating_Medical_Professional_Email__c != oldLeadMap.get(newLead.id).Treating_Medical_Professional_Email__c && newLead.Hidden_DV_form_Medical_professional_Type__c ==  'Treating Medical Professional'){
               
                newLead.Of_Times_Email_Sent__c = 0;
                newLead.Part_A_Form_Password__c = Lead_OnBeforeUpdateTriggerHandlerHelper.getRandom();
                
            }
            if(newLead.Best_contact_for_Physician_Email__c != oldLeadMap.get(newLead.id).Best_contact_for_Physician_Email__c && newLead.Hidden_DV_form_Medical_professional_Type__c ==  'Best contact for Physician'){
               
                newLead.Of_Times_Email_Sent__c = 0;
                newLead.Part_A_Form_Password__c = Lead_OnBeforeUpdateTriggerHandlerHelper.getRandom();
                
            }
            if(newLead.Alternate1MedicalProfessionalEmail__c != oldLeadMap.get(newLead.id).Alternate1MedicalProfessionalEmail__c && newLead.Hidden_DV_form_Medical_professional_Type__c ==  'Alternate 1 Medical Professional'){
                
                newLead.Of_Times_Email_Sent__c = 0;
                newLead.Part_A_Form_Password__c = Lead_OnBeforeUpdateTriggerHandlerHelper.getRandom();
             }
            if(newLead.Alternate2MedProfessionalEmail__c != oldLeadMap.get(newLead.id).Alternate2MedProfessionalEmail__c && newLead.Hidden_DV_form_Medical_professional_Type__c ==  'Alternate 2 Medical Professional'){
               
                newLead.Of_Times_Email_Sent__c = 0;
                newLead.Part_A_Form_Password__c = Lead_OnBeforeUpdateTriggerHandlerHelper.getRandom();
                
            }
            if(newLead.Medical_Questions__c != oldLeadMap.get(newLead.id).Medical_Questions__c && newLead.Medical_Questions__c  != Null ){
                leadQuestionList.add(newLead);
            }
            
            //Modified as per IME 110
            if((newLead.Status == 'Referred')
               && (newLead.Sub_Status__c == 'Pending Diagnosis Verification' || newLead.Sub_Status__c == 'Pending Part A' || newLead.Sub_Status__c == 'Pending Paper DV')
               && newLead.Sub_Status__c != oldLeadMap.get(newLead.id).Sub_Status__c
               && newLead.Dup_Check__c != 'Block Lead Dup'){
                findduplicateList.add(newLead);
            }
            //Modified as per IME 110
            if((newLead.Status == 'Referred')
               && (newLead.Sub_Status__c == 'Pending Diagnosis Verification' || newLead.Sub_Status__c == 'Pending Part A' || newLead.Sub_Status__c == 'Pending Paper DV')
               && newLead.Sub_Status__c != oldLeadMap.get(newLead.id).Sub_Status__c
               && newLead.Dup_Check__c == 'Block Lead Dup' && newLead.Contact_Dup_Check__c != 'Block Contact Dup'){
                findDupConList.add(newLead);
            }
            
            if(newLead.LastName != oldLeadMap.get(newLead.id).LastName || newLead.DOB__c  != oldLeadMap.get(newLead.id).DOB__c 
               || newLead.Parent_First_Name__c != oldLeadMap.get(newLead.id).Parent_First_Name__c && newLead.Override_Dupe_Check__c == False){
                flag = False;
                newUpdateLeadList.add(newLead);
            }
                         
            if(newLead.PostalCode != Null && newLead.PostalCode != oldLeadMap.get(newLead.Id).postalCode && newLead.AddressVerified__c == false){
                if(newLead.PostalCode != null && String.valueOf(newLead.PostalCode).length() > 5 && String.valueOf(newLead.PostalCode).contains('-')) {
                    postalCodesSet.add(String.valueOf(newLead.PostalCode).split('-')[0]);
                } else {
                    postalCodesSet.add(newLead.PostalCode);
                }
                updateChapterOnLeadList.add(newLead);
            }
            
            if(newLead.PD_ICD_Code__c != Null && newLead.PD_ICD_Code__c != oldLeadMap.get(newLead.id).PD_ICD_Code__c){
                icdCodesSet.add(newLead.PD_ICD_Code__c);
                leadUpdateToMedicalInfoList.add(newLead);
            }
            else if(newLead.PD_ICD_Code__c == Null){
               newLead.MAW_Name__c = '';
            }
            if(newLead.PD_Condition_Description__c  != Null && newLead.PD_Condition_Description__c  != oldLeadMap.get(newLead.id).PD_Condition_Description__c ){
                conditionDescriptionsSet.add(newLead.PD_Condition_Description__c );
                leadUpdateToMedicalInfoList.add(newLead);
             }
            else if(newLead.PD_Condition_Description__c  == Null && newLead.PD_Condition_Description__c  != oldLeadMap.get(newLead.id).PD_Condition_Description__c ){
                newLead.MAW_Name__c = '';
            }
            
            if(newLead.Status == 'Eligibility Review' && oldLeadMap.get(newLead.Id).Status != 'Eligibility Review'){
                leadList.add(newLead);
            }
            if(newLead.Region_Code__c != null && newLead.Region_Code__c != oldLeadMap.get(newLead.Id).Region_Code__c) {
                leadRegionCodeValidationMap.put(newLead.Id, newLead);
            }
             //IME 58
             if(newLead.Any_medical_reason_for_moving_quickly__c != null && newLead.Status == 'Qualified' && oldLeadMap.get(newLead.Id).Status != 'Qualified' && newLead.Any_medical_reason_for_moving_quickly__c.contains('Yes')) {
                 qualifiedRushLeadList.add(newLead);
             }
             //IME-77
             if(newLead.Sub_Status__c == 'Pending Part A' || newLead.Sub_Status__c == 'Pending Paper DV' || newLead.Status == 'Pending Diagnosis Verification'){
                 newLead.Pending_Diagnosis_Date__c = Date.today();
             }
        }
            
           //Update the Intake manager email and chapter name
        If(updatedLeadList.Size() > 0){
            Lead_OnBeforeUpdateTriggerHandlerHelper.updateHiddenchapterName(accountIdSet,updatedLeadList);
         }  
       if(icdInfoMap.size() > 0){
            Lead_OnBeforeUpdateTriggerHandlerHelper.MatchConditionDescription(icdInfoMap,leadRecList,icdCodeInfoIdSet);
        }
        if(newChaptersSet.size() > 0)
            Lead_OnBeforeUpdateTriggerHandlerHelper.updateLeadOwner(updateLeadOwnerList,newChaptersSet);
        
        if(leadUpdateToMedicalInfoList.size() > 0){
            Lead_OnBeforeUpdateTriggerHandlerHelper.ToUpdateMedicalInfo(conditionDescriptionsSet,icdCodesSet,leadUpdateToMedicalInfoList);
        }
        if(leadList.size() > 0){
             Lead_OnBeforeUpdateTriggerHandlerHelper.CreateNewCase(leadList);
        }
        if(findduplicateList.size() > 0){
            Lead_OnBeforeUpdateTriggerHandlerHelper.findDuplicateRecords(findduplicateList);
        }
        if(findDupConList.size() > 0){
            Lead_OnBeforeUpdateTriggerHandlerHelper.FindDupContacts(findDupConList);
        }
        if(leadRequiredList.size() > 0){
            Lead_OnBeforeUpdateTriggerHandlerHelper.preQualifiedRequired(leadRequiredList);
        }
        //IME 58
        if(qualifiedRushLeadList.size() > 0){
            Lead_OnBeforeUpdateTriggerHandlerHelper.createRushTask(qualifiedRushLeadList);
        }
    }
}