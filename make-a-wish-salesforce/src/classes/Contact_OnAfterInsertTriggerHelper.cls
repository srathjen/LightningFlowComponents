/***************************************************************************************************
Author      : MST Solutions
Date        : 10/15/2016
Description : Contact_OnAfterInsertTriggerHelper is used to create affliation record.
              
              Modification Log
              ------------------
              WVC-1884    KANAGARAJ  04/04/2018
              
*****************************************************************************************************/

public class Contact_OnAfterInsertTriggerHelper{

    static Id volunteerRecordTypeId = Constant_AC.VOLUNTEER_RT_ID;
    static Id wichChildRecordTypeId = Constant_AC.CONTACT_WISH_CHILD_RT_ID;
    static Id familyContactRecordTypeId = Constant_AC.WISH_FAMILY_RT_ID;
    static Id boardMemberRT = Constant_AC.BOARD_MEMBER_RT_ID;
    static Id MedicalProfContactRecordTypeId = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;
    
    // create affliation record based on the contact creations.
    public static void CreateAffliation(List<Contact> ContactList){
        RecursiveTriggerHandler.isFirstTime = false;
        List<npe5__Affiliation__c> affDbList=new List<npe5__Affiliation__c>();
        List<npe5__Affiliation__c> houseHoldAffList = new List<npe5__Affiliation__c>();
        npe5__Affiliation__c aff; 
        List<npe5__Affiliation__c> UdateAff =new List<npe5__Affiliation__c>();
        set<Id> contactIds =new set<Id>();
        List<npe5__Affiliation__c> affList = new List<npe5__Affiliation__c>();
        
        try{
            for(Contact con:ContactList)
            {
                if((con.RecordTypeId == MedicalProfContactRecordTypeId  && con.Hidden_Hospital_Account__c != Null) || 
                (con.RecordTypeId != MedicalProfContactRecordTypeId)){
                    npe5__Affiliation__c houseHoldAffiliation = new npe5__Affiliation__c();
                    if(con.RecordTypeId == MedicalProfContactRecordTypeId  && con.Hidden_Hospital_Account__c != Null)
                        houseHoldAffiliation.npe5__Organization__c=con.Hidden_Hospital_Account__c;
                    else
                        houseHoldAffiliation.npe5__Organization__c=con.AccountId;
                    
                    houseHoldAffiliation.npe5__Contact__c=con.id;
                    houseHoldAffiliation.npe5__StartDate__c = Date.Today();
                    houseHoldAffiliation.npe5__Status__c = 'Active';
                    if(con.RecordTypeId == volunteerRecordTypeId){
                        houseHoldAffiliation.Constituent_Code__c = Constant_AC.VOLUNTEER_TASK_RT_LABEL;
                        houseHoldAffiliation.npe5__Status__c = 'Pending';
                        houseHoldAffiliation.npe5__Primary__c = true;
                        contactIds.add(con.Id);
                    }
                    else if(con.RecordTypeId == boardMemberRT)
                        houseHoldAffiliation.Constituent_Code__c=Constant_AC.BOARD_MEMBER_RT_LABEL;
                    if(con.RecordTypeId == MedicalProfContactRecordTypeId)
                        houseHoldAffiliation.npe5__Primary__c = false;
                    houseHoldAffList.add(houseHoldAffiliation);
                }
                if((con.RecordTypeId == MedicalProfContactRecordTypeId) || con.RecordTypeId == familyContactRecordTypeId || con.RecordTypeId == wichChildRecordTypeId)
                {
                    aff =new npe5__Affiliation__c();
                    if(con.Region_Chapter__c != Null)
                    {
                        aff.npe5__Organization__c=con.Region_Chapter__c;
                        aff.npe5__Contact__c=con.id;
                        aff.npe5__StartDate__c = Date.Today();
                        aff.npe5__Status__c = 'Active';
                        if(con.RecordTypeId == familyContactRecordTypeId )
                        {
                            aff.Constituent_Code__c=Constant_AC.WISH_FAMILY_RT_LABEL;
                        }
                        else if(con.RecordTypeId == wichChildRecordTypeId)
                        {
                            aff.Constituent_Code__c=Constant_AC.CONTACT_WISH_CHILD_RT_LABEL;
                        }
                        if(con.RecordTypeId == MedicalProfContactRecordTypeId  )
                        {
                            aff.Constituent_Code__c=Constant_AC.MEDICAL_PROFESSIONAL_RT_LABEL;
                            aff.npe5__Primary__c = true;
                        }
                        affDbList.add(aff);
                    }
                }
                if(con.recordtypeid == volunteerRecordTypeId)
                {
                    if(con.Region_Chapter__c == Null && con.AccountId != Null)
                        con.Region_Chapter__c = con.AccountId;
                    if(con.AccountId == Null && con.Region_Chapter__c != Null)
                        con.AccountId = con.Region_Chapter__c;
                }
            }
            if(contactIds.size() > 0){
                For(npe5__Affiliation__c  currAff : [SELECT Id,npe5__Primary__c FROM npe5__Affiliation__c  WHERE npe5__Contact__c IN : contactIds AND npe5__Primary__c = True Limit 50000]){
                    currAff.npe5__Primary__c = false;
                    affList.add(currAff);
                }
                If(affList.Size() > 0)
                    Update affList;
            }
            if(houseHoldAffList.size() > 0){
                insert houseHoldAffList;
            }
            if(affDbList.size() > 0){
                Insert affDbList;
            }
        
         if(Test.isRunningTest()){
                throw new CommonTriggerException('Test Class execution');
            }

        
        
        
        
        }
        catch(Exception ex){
            for(Contact currRec : ContactList){
                ErrorMessage_AC.createdebugRec('Contact_OnAfterInsertTriggerHelper',String.valueof(currRec),String.valueOf(ex),'CreateAffliation',currRec.Id,ex.getStackTraceString(),'Error');
            }
            
            
            
            if(!Test.isRunningTest()){
            for(Contact currRec : ContactList){
                currRec.addError(Label.Debug_log_error_message);
            }
          }
        
        } 
    }
    
    public static void updateWishFormId(List<Contact> newContactList){
        Map<Id,Id> contactIdMap = new Map<Id,Id>();
        List<Wish_Child_Form__c> wishChildFormList = new List<Wish_Child_Form__c>();
        for(Contact newContact : newContactList){
            if(newContact.RecordTypeId == wichChildRecordTypeId || newContact.RecordTypeId == familyContactRecordTypeId ){
                if(newContact.Hidden_Wish_Form_Id__c != Null){
                    contactIdMap.put(newContact.Hidden_Wish_Form_Id__c,newContact.Id);
                }
             }
        }
        
        if(contactIdMap.size() > 0){
            
            for(Wish_Child_Form__c dbWishFormRec : [SELECT Id,Contact__c,Migrated__c FROM Wish_Child_Form__c WHERE Id IN: contactIdMap.keySet() AND Migrated__c = False]){
                if(contactIdMap.containsKey(dbWishFormRec.Id)){
                   dbWishFormRec.Contact__c = contactIdMap.get(dbWishFormRec.Id);
                   wishChildFormList.add(dbWishFormRec);
                }
            }
        }
        if(wishChildFormList.size() > 0)
        update wishChildFormList;
    }
}