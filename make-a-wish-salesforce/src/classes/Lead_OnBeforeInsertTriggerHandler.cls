/***************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kanagaraj
Date        : 26/05/2016
Description : This Lead_OnBeforeInsertTriggerHandler is invoked before the lead record is created. and this
class invoke the OnBeforeInsert methods.
*****************************************************************************************************/
Public Class Lead_OnBeforeInsertTriggerHandler{
    
/*************************************************************************************************
This method is used to assign the values for lead fields when the lead record is created based on the condition.
and also it call the populateRegionCode, UpdateChatperfields, updateHiddenchapterName methods.
****************************************************************************************************/
    Public static void OnBeforeInsert(List<Lead> newLeadListRec){
        List<Lead> newLeadList = new List<Lead>();
        List<Lead> updateChapterOnLeadList = new List<Lead>();
        Set<String> postalCodesSet = new Set<String>();
        Map<Id, Lead> leadRegionMap = new Map<Id, Lead>();
        Set<Id> leadChapterSet = new Set<Id>();
        Set<Id> leadChapterNameSet = new Set<Id>();
           for(Lead newLead : newLeadListRec)
            {    
                newLead.Override_Dupe_Check__c = false;
                newLead.Contact_Dup_Check__c = Null;
                newLead.Dup_Check__c = Null;
                If(newLead.Additional_Parent_First_Name__c == newLead.Parent_First_Name__c && newLead.Additional_Parent_Last_Name__c == newLead.Parent_Last_Name__c && newLead.Additional_Parent_Phone__c == newLead.Phone
                   && newLead.Additional_Parent_Email__c == newLead.Email && newLead.Additional_Parent_City__c == newLead.City && newLead.Additional_Parent_Postal_Code__c == newLead.PostalCode){
                       
                       newLead.Additional_Parent_First_Name__c = '';
                       newLead.Additional_Parent_Last_Name__c = '';
                       newLead.Additional_Parent_Phone__c = '';
                       newLead.Additional_Parent_Email__c = '';
                       newLead.Additional_Parent_City__c = '';
                       newLead.Additional_Parent_Postal_Code__c = '';
                       }
                If(newLead.Additional_Parent_First_Name__c == Null && newLead.Additional_Parent_Last_Name__c == Null && newLead.Additional_Parent_Phone__c == Null
                   && newLead.Additional_Parent_Email__c == Null && newLead.Additional_Parent_City__c == Null && newLead.Additional_Parent_Postal_Code__c == Null){
                       newLead.Additional_Parent_State__c = '';
                   }
                leadChapterSet.add(newLead.ChapterName__c);
                leadRegionMap.put(newLead.Id, newLead);
                newLead.Part_A_Form_Password__c= getRandom();            
                leadChapterNameSet.add(newLead.ChapterName__c);
                if(Bypass_Triggers__c.getValues(userInfo.getUserId()) == Null)
                {   
                    if(newLead.Status == 'Inquiry')
                    { 
                        boolean referred = true;
                        
                        newLead.Inquiry_Date__c = System.Today();
                        
                        if(newLead.City == Null || newLead.StateCode == Null || newLead.PostalCode == Null || newLead.Street == Null)
                            referred = false;
                        for(Schema.FieldSetMember f : getNonMedicalReqFields()){
                                if(newLead.get(f.getFieldPath()) == Null){
                                    referred = false;
                                }
                          }
                          if(referred == true){
                                newLead.Status = 'Referred';}
                    }
                    if(newLead.RFI_Form_Info_Hidden__c==Null && newLead.Override_Dupe_Check__c == false && (newLead.Status == 'Inquiry' || newLead.Status == 'Referred')){
                        newLeadList.add(newLead);
                    }
                    
                    if(newLead.Status == 'Referred'){
                        newLead.Inquiry_Date__c = Date.Today();
                        newLead.Referred_Date__c= Date.Today();
                    }
                }
                
                if(newLead.PostalCode != Null ){
                    postalCodesSet.add(newLead.PostalCode);
                    updateChapterOnLeadList.add(newLead);
                }
                else{
                    postalCodesSet.add(newLead.Referrer_Zip__c);
                    updateChapterOnLeadList.add(newLead);
                }
            }
            
            if(leadRegionMap.size() > 0 && leadChapterSet.size() > 0) {
                Lead_OnBeforeInsertTriggerHandlerHelper.populateRegionCode(leadRegionMap, leadChapterSet);
            }
            if(postalCodesSet.size() > 0){
                Lead_OnBeforeInsertTriggerHandlerHelper.UpdateChatperfields(postalCodesSet,updateChapterOnLeadList);
            }
            if(leadChapterNameSet.Size() > 0)
                Lead_OnBeforeInsertTriggerHandlerHelper.updateHiddenchapterName(leadChapterNameSet,Trigger.new);
        
    }
    
    // Medical Referral Field set contains the mandatory fields of Medical Professional.
    public static List<Schema.FieldSetMember> getNonMedicalReqFields() {
        return SObjectType.Lead.FieldSets.Non_Medical_Referral_Required_Fields.getFields();
    }
    
    /****************************************************************************
    This getRandom() this method is used to generate random number. when the lead
    status is "Reffered" and sub status is "Pending dignouses verification"
    ****************************************************************************/
    public static String getRandom()
    {
        Integer len=6;
        final String chars='0123456789';
        String randStr='';
        While(randStr.length() < len)
        {
            Integer idx=Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr;
    }
}