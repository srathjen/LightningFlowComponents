/**********************************************************
Created by: Vennila Paramasivam
Author : MST Solution
Created Date : 04/08/2016
Description : It will capture the lead from Referral form.
***********************************************************/

Public Class WishReferralFormOut_AC
{
   Public Lead currLead{get;set;}
   Public boolean login{get;set;}
   Public String password{get;set;}
   Public String renderpdf{get;set;}
   public Id accontId;
   
    public WishReferralFormOut_AC()
    {
       renderpdf='';
       ID leadId = ApexPages.currentPage().getParameters().get('LeadId');
       currLead = new Lead();
       List<Lead> leaddata=[Select Id, Referrer_FirstName__c, Referrer_Last_Name__c,Title, Hospital_Treatment_Facility_Treating__c, Referrer_Phone__c, Referrer_Email__c,
                            FirstName, Child_Middle_Initial__c, LastName, DOB__c, PostalCode, Gender__c, Parent_First_Name__c, Parent_Last_Name__c, Phone, 
                            Childs_Qualifying_Diagnosis__c, PD_ICD_Code__c, Treating_Medical_Professional_First_Name__c, Treating_Medical_Professional_Last_Name__c,
                            Medical_Professional_Phone__c, Treating_Medical_Professional_Fax__c, Treating_Medical_Professional_Email__c, ChapterName__r.Id   from Lead where Id =: leadId];
       accontId= leaddata[0].ChapterName__r.Id;                           
       currLead = leaddata[0];
    }
    
     //Used to validate password and whether the document is already signed
    public pagereference submit(){
       List<Account> accdata=[Select Id,Referral_Form_Password__c from Account where Id=:accontId];
       if(password == accdata[0].Referral_Form_Password__c){
            login = true;
       }
       
       else{
           Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Invalid password. '));
       }
        return null;
    }
    
    // return 'pdf' if the parameter 'p' has been passed to the page, other null
    public String getChooserender() {
        if (ApexPages.currentPage().getParameters().get('p') != null)
        return 'pdf';
        else
        return null;
    }
    
    public pagereference exportPDF()
    {
        PageReference pdf =  Page.WishReferralFormOut_VF;
        pdf.getParameters().put('p','p');
        return pdf;
    }
}