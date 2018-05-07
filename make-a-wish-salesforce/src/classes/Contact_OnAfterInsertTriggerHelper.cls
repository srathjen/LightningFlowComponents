/***************************************************************************************************
Author      : MST Solutions
Date        : 10/15/2016
Description : Contact_OnAfterInsertTriggerHelper is used to create affliation record.
              
              Modification Log
              ------------------
              WVC-1884    KANAGARAJ  04/04/2018
              
*****************************************************************************************************/

Public class Contact_OnAfterInsertTriggerHelper{
    
    static Constant_AC  constant = new Constant_AC();
    static Id volunteerRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.volunteerRT).getRecordTypeId();
    static Id wichChildRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.contactWishChildRT).getRecordTypeId();
    static Id familyContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.wishFamilyRT).getRecordTypeId();
    static Id boardMemberRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.boardMemberRT).getRecordTypeId();
    static Id MedicalProfContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.MedicalProfessionalRT).getRecordTypeId();
    
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
                if((con.RecordTypeId == MedicalProfContactRecordTypeId  && con.Hidden_Hospital_Account__c != Null) || (con.RecordTypeId != MedicalProfContactRecordTypeId)){
                    npe5__Affiliation__c houseHoldAffiliation = new npe5__Affiliation__c();
                    if(con.RecordTypeId == MedicalProfContactRecordTypeId  && con.Hidden_Hospital_Account__c != Null)
                        houseHoldAffiliation.npe5__Organization__c=con.Hidden_Hospital_Account__c;
                    else
                        houseHoldAffiliation.npe5__Organization__c=con.AccountId;
                    
                    houseHoldAffiliation.npe5__Contact__c=con.id;
                    houseHoldAffiliation.npe5__StartDate__c = Date.Today();
                    houseHoldAffiliation.npe5__Status__c = 'Active';
                    if(con.RecordTypeId == volunteerRecordTypeId){
                        houseHoldAffiliation.Constituent_Code__c='Volunteer';
                        houseHoldAffiliation.npe5__Primary__c = true;
                        contactIds.add(con.Id);
                    }
                    else if(con.RecordTypeId == boardMemberRT)
                        houseHoldAffiliation.Constituent_Code__c='Board Member';
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
                            aff.Constituent_Code__c='Wish Family';
                        }
                        else if(con.RecordTypeId == wichChildRecordTypeId)
                        {
                            aff.Constituent_Code__c='Wish Child';
                        }
                        if(con.RecordTypeId == MedicalProfContactRecordTypeId  )
                        {
                            aff.Constituent_Code__c='Medical Professional';
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
        }
        catch(Exception ex){
            for(Contact currRec : ContactList){
                ErrorMessage_AC.createdebugRec('Contact_OnAfterInsertTriggerHelper',String.valueof(currRec),String.valueOf(ex.getCause()),'CreateAffliation',currRec.Id,ex.getStackTraceString(),'Error');
            }
            for(Contact currRec : ContactList){
                currRec.addError(Label.Debug_log_error_message);
            }
        } 
    }
}