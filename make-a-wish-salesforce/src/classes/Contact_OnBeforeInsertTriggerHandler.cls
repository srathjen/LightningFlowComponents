/***************************************************************************************************
Author      : MST Solutions
Date        : 10/15/2016
Description : Contact_OnBeforeInsertTriggerHandler is used assign the values to contact record based on the record types when the
              new account record is created.
              
              Modification Log
              ------------------
              WVC-1884    KANAGARAJ  04/04/2018
              
*****************************************************************************************************/

Public class Contact_OnBeforeInsertTriggerHandler{
    
    static Constant_AC  constant = new Constant_AC();
    static Id volunteerRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.volunteerRT).getRecordTypeId();
    static Id wichChildRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.contactWishChildRT).getRecordTypeId();
    static Id familyContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.wishFamilyRT).getRecordTypeId();
   
   /*This onBeforeInsert method is used to assign the values to Relationship_Type__c field based on the record type */
    public static void onBeforeInsert(List<Contact> newContactList){
         Map<String, String> monthValMap = new Map<String, String>();
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
         
        for(Contact newContact : newContactList)
        {
            if(Bypass_Triggers__c.getValues(userInfo.getUserId()) == Null)
            {
                if(newContact.RecordTypeId == volunteerRecordTypeId){
                    //contactList.add(newContact );
                    newContact.Region_Chapter__c = newContact.AccountId;
                }
                
                if(newContact.birth_day__c != Null && newContact.birth_year__c != Null && newContact.birth_month__c != Null)
                {
                    date dtConverted = Date.valueOf(newContact.birth_year__c+'-'+monthValMap.get(newContact.birth_month__c)+'-'+newContact.birth_day__c);
                    newContact.BirthDate = dtConverted ;
                }
            }
            if(newContact.RecordTypeId == wichChildRecordTypeId){
                newContact.Relationship_Type__c = 'Wish Child';
            }
            if(newContact.RecordTypeId == familyContactRecordTypeId ){
                newContact.Relationship_Type__c = 'Parent/Legal Guardian';
            }
        }
    }
}