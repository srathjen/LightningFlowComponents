/***************************************************************************************************
Author      : MST Solutions
Date        : 10/15/2016
Description : Contact_OnBeforeDeleteTriggerHandler is used to call the Helper class when the
              contact record is deleted.
              
              Modification Log
              ------------------
              WVC-1884    KANAGARAJ  04/04/2018
              
*****************************************************************************************************/
public class Contact_OnBeforeDeleteTriggerHandler{
    //When the contact record is deleted then it will call Contact_OnBeforeDeleteTriggerHelper class method.
    public static void onBeforeDelete(List<Contact> deletedConList){
        Map<Id,Contact> conMap = new Map<Id,Contact>();
        for(Contact deletedCon : deletedConList){
             conMap.put(deletedCon.id,deletedCon );
        }
        
        if(conMap.size() > 0){
            Contact_OnBeforeDeleteTriggerHelper.UpdateAffiliationPrimaryStatus(conMap);
            Contact_OnBeforeDeleteTriggerHelper.validateContact(conMap);
        }
    }
}