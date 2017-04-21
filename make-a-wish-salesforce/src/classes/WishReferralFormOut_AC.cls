/**********************************************************
Created by: Vennila Paramasivam & Kesavakumar Murugesan
Author : MST Solution
Created Date : 04/08/2016
Description : It will capture the lead from Referral form.
***********************************************************/

Public Class WishReferralFormOut_AC {
    Public Lead currLead{get;set;}
    Public boolean login{get;set;}
    Public String password{get;set;}
    Public String renderpdf{get;set;}
    public Id accontId;
    public List<Lead> leaddata;
    public List<SiblingInfo> sibList {get;set;}
    
    public WishReferralFormOut_AC() {
        sibList = new List<SiblingInfo>();
        renderpdf='';
        ID leadId = ApexPages.currentPage().getParameters().get('LeadId');
        currLead = new Lead();
        leaddata=[Select Id,Name,Relationship_to_child__c,CreatedDate,Treating_Medical_Professional_Phone__c,PD_Condition_Description__c,Medical_Provider_Category__c,of_Siblings__c, Other_Medical_Provider_Category__c,Sibling_Detail__c, Any_medical_reason_for_moving_quickly__c ,What_is_the_family_s_primary_spoken_lang__c, Referrer_FirstName__c, Street, Email, Has_this_child_ever_received_prior_wish__c, Referrer_City__c, Referrer_Zip__c, Referrer_Last_Name__c,Title, Hospital_Treatment_Facility_Treating__c, Referrer_Phone__c, Referrer_Email__c,
                  FirstName, City, State, Country, Child_Middle_Initial__c, LastName, DOB__c, PostalCode, Gender__c, Parent_First_Name__c, Parent_Last_Name__c, Phone, 
                  Childs_Qualifying_Diagnosis__c, PD_ICD_Code__c, Treating_Medical_Professional_First_Name__c, Treating_Medical_Professional_Last_Name__c,
                  Medical_Professional_Phone__c, Treating_Medical_Professional_Fax__c, Treating_Medical_Professional_Email__c, ChapterName__r.Id   from Lead where Id =: leadId];
        if(leaddata[0].Any_medical_reason_for_moving_quickly__c != null) {
            leaddata[0].Any_medical_reason_for_moving_quickly__c = leaddata[0].Any_medical_reason_for_moving_quickly__c.replaceAll('<[^>]+>',' ');
        }
        if(leaddata[0].Has_this_child_ever_received_prior_wish__c != null) {
            leaddata[0].Has_this_child_ever_received_prior_wish__c = leaddata[0].Has_this_child_ever_received_prior_wish__c.replaceAll('<[^>]+>',' ');
        }
        
        
        if(leaddata[0].Sibling_Detail__c != null) {
            String replaceString = '';
            for(String sibDet : leaddata[0].Sibling_Detail__c.split('<br>')) {
                sibDet = sibDet.replace('|', ',');
                SiblingInfo newSeb = new SiblingInfo();
                newSeb.firstName = sibDet.split(',')[0];
                newSeb.lastName = sibDet.split(',')[1];
                newSeb.age = sibDet.split(',')[2];
                sibList.add(newSeb);
            }
        }
        accontId= leaddata[0].ChapterName__r.Id;                           
        currLead = leaddata[0];
        
    }
    
    //Used to validate password for the form
    public pagereference submit(){
        //Used to get chapter password for referral form
        List<Account> accdata=[Select Id,Referral_Form_Password__c from Account where Id =: accontId];
        if(password == accdata[0].Referral_Form_Password__c){
            login = true;
        } else{
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Invalid password. '));
        }
        return null;
    }
    
    //Used to export the current page as pdf
    public void exportPDF() {
        //assign render as value to the page
        renderpdf = 'pdf';
        
        //setup a default file name (Lead Name + Lead Created Date)
        string fileName = leaddata[0].Name+'_'+leaddata[0].CreatedDate+'.pdf';
        
        //We have to set the content disposition as attachment.
        Apexpages.currentPage().getHeaders().put('content-disposition', 'attachemnt; filename='+fileName);
    }
    
    // Wrapper class for sibling info
    public class SiblingInfo {
        public String firstName {get;set;}
        public String lastName{get;set;}
        public String age{get;set;}
    }
}