/****************************************************************************************************************************************************************
Created by: MST Solutions
Author : MST Solutions
CreateDate : 09/19/2017
Description : This LiabilityForms_AC is used to display the list of liability forms 1.Publicity OK 2.Prefer no publicity 3.Publicity not selected .
***************************************************************************************************************************************************************/
Public Class LiabilityForms_AC{
public String liabilityFrom{get;set;}
Public String liability{get;set;}
Public String publicity{get;set;}
public Id caseId;
public LiabilityForms_AC(ApexPages.StandardController controller) {
  String options = 'One';
  String optionstwo = 'Two';
  String blank = 'Three';
  caseId = Apexpages.currentPage().getParameters().get('Id');
  LiabilityFrom = '/apex/WishLiabilityForm_VF?id='+caseId+'&'+'option='+Options;
  Liability = '/apex/WishLiabilityForm_VF?id='+caseId+'&'+'option='+Optionstwo;
  publicity = '/apex/WishLiabilityForm_VF?id='+caseId+'&'+'option='+blank;
}
}