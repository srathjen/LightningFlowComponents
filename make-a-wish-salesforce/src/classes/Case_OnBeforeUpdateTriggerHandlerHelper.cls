/*****************************************************************************************************************
Author      : MST Solutions
Date        : 5/26/2016
Description : When a new case record updated then it will update the values to corresponding fields and also
it update the field values to related objects like Account, contact, VolunteerOpportunity.
*******************************************************************************************************************/

Public class Case_OnBeforeUpdateTriggerHandlerHelper{
    Static  Constant_AC  constant = new Constant_Ac();   
    Static String wishDeterminationRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishDeterminationRT).getRecordTypeId();
    Static String parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
    Static String chapterecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(constant.chapterRT).getRecordTypeId();
    Static String diagnosisVerificationRT = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.diagnosisRT).getRecordTypeId();
    Static String wishPlanningRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishPlanningAnticipationRT).getRecordTypeId();
    Static String wishAssistRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishAssistRT).getRecordTypeId();
    Static String wishGrantRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishGrantRT).getRecordTypeId();
    Static String wichChildRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.contactWishChildRT).getRecordTypeId();
    
    /*********************************************************************************************************************
This method is used to display the error message when the region code is entered incorrectly.
*******************************************************************************************************************/
    public static void wishChildRegionValidation(Map<Id, Case> parentCaseMap, Set<Id> contactSet) {
        Constant_AC  constant = new Constant_AC();
        Map<Id,Contact> wishChildMap = new Map<Id,Contact>();
        if(contactSet.size() > 0) {
            //try{
                for(Contact wishChild : [SELECT Id, Region_Code__c, County__c FROM Contact WHERE RecordTypeId =: wichChildRecordTypeId AND Id IN : contactSet LIMIT 50000]) {
                    if(wishChild.Region_Code__c == null || wishChild.County__c == null) {
                        wishChildMap.put(wishChild.Id,wishChild);
                    }
                }
                if(wishChildMap.size() > 0) {
                    for(Case parentCase : parentCaseMap.values()) {
                        if(wishChildMap.containsKey(parentCase.ContactId)) {
                            if(wishChildMap.get(parentCase.ContactId).Region_Code__c == null && wishChildMap.get(parentCase.ContactId).county__c == null && Bypass_Triggers__c.getValues(userInfo.getUserId()) == Null)
                                parentCase.addError('Please add region and county on the wish child\'s contact record.');
                            else if(wishChildMap.get(parentCase.ContactId).Region_Code__c == null && Bypass_Triggers__c.getValues(userInfo.getUserId()) == Null)
                                parentCase.addError('Please add region on the wish child\'s contact record.');
                            else if(wishChildMap.get(parentCase.ContactId).county__c == null && Bypass_Triggers__c.getValues(userInfo.getUserId()) == Null)
                                parentCase.addError('Please add county on the wish child\'s contact record.');
                            
                        }
                    }
                }
           /* }
            catch(Exception e){
                for(case newCase : parentCaseMap.values()){
                    system.debug('@@ Exception @@'+e);
                    newCase.addError(e.getMessage());
                }
            }*/
        }
    }
    
    /*********************************************************************************************************************
This method will fire when the parent case status is updated as completed and if budget values is null then it will
display error message.
*******************************************************************************************************************/
    public static void CheckBudgetActuals(List<Case> budgetCaseList) {
        Set<Id> ActualsMatch = new Set<Id>();
        Set<Id> budgetIds=new Set<Id>();
        String message = '';
        Map<Id,List<String>> pandaCase =new Map<Id, List<String>>();
        Map<Id, List<Wish_Expense__c>> wishExpenseListbyId= new Map<Id, List<Wish_Expense__c>>();
        //try{
            for(Case caseTemp : budgetCaseList){
                budgetIds.add(caseTemp.Id);
            }
            
            List<Wish_Expense__c> wishExpenseList = [SELECT Id, Budget_Cash__c, Budget_In_Kind__c, Projected_Cash__c, Projected_In_Kind__c, Actual_Cash__c,Actual_In_Kind__c,FE_Posted_Cash__c, FE_Posted_In_Kind__c, Case__c FROM Wish_Expense__c WHERE Case__c In: budgetIds LIMIT 50000];
            system.debug('budget Info 2: ' + wishExpenseList );
            for(Id caseId : budgetIds){
                for(Wish_Expense__c wishExpense : wishExpenseList ){
                    if( caseId == wishExpense.Case__c){
                        if(!wishExpenseListbyId.containsKey(caseId)){
                            wishExpenseListbyId.put(caseId, new List<Wish_Expense__c>{wishExpense });    
                        }else{
                            wishExpenseListbyId.get(caseId).add(wishExpense ); 
                        } 
                    }
                } 
            }
            decimal totalBudCash=0;
            decimal totalBudInKind=0;
            decimal totalProjCash=0;
            decimal totalProjInKind=0;
            decimal totalActCash=0;
            decimal totalActInKind=0;
            decimal totalFECash=0;
            decimal totalFEInkind=0;
            system.debug('budget Info 3: ' + wishExpenseListbyId);
            for(Id IdStatus : wishExpenseListbyId.keySet()){
                for(Wish_Expense__c expenseSatus : wishExpenseListbyId.get(IdStatus)){
                    if(expenseSatus.Budget_Cash__c!= null){
                        totalBudCash= totalBudCash+ expenseSatus.Budget_Cash__c;
                    }
                    if(expenseSatus.Budget_In_Kind__c!= null){
                        totalBudInKind= totalBudInKind+ expenseSatus.Budget_In_Kind__c;
                    }
                    if(expenseSatus.Projected_Cash__c!= null){
                        totalProjCash= totalProjCash+ expenseSatus.Projected_Cash__c;
                    }
                    if(expenseSatus.Projected_In_Kind__c!= null){
                        totalProjInKind= totalProjInKind+ expenseSatus.Projected_In_Kind__c;
                    }
                    if(expenseSatus.Actual_Cash__c != null){
                        totalActCash = totalActCash + expenseSatus.Actual_Cash__c;
                    }
                    if(expenseSatus.Actual_In_Kind__c!= null){
                        totalActInKind = totalActInKind + expenseSatus.Actual_In_Kind__c;
                    }
                    if(expenseSatus.FE_Posted_Cash__c!= null){
                        totalFECash = totalFECash  + expenseSatus.FE_Posted_Cash__c;
                    }
                    if(expenseSatus.FE_Posted_In_Kind__c!= null){
                        totalFEInkind = totalFEInkind + expenseSatus.FE_Posted_In_Kind__c;
                    }
                }
                if(totalBudCash + totalBudInKind > 0 || totalBudInKind + totalProjInKind >0){
                    if( (totalActCash + totalActInKind  == 0 || totalFECash + totalFEInkind ==0) || (totalActCash != totalFECash || totalActInKind !=totalFEInkind )){
                        ActualsMatch.add(IdStatus);
                    }
                }
                else if(totalBudCash + totalBudInKind == 0 && totalBudInKind + totalProjInKind == 0){
                    if (totalActCash != totalFECash || totalActInKind !=totalFEInkind ){
                        ActualsMatch.add(IdStatus);
                    }
                }
                
                totalBudCash =0;
                totalBudInKind =0;
                totalProjCash = 0;
                totalProjInKind = 0;
                totalActCash =0;
                totalActInKind =0;
                totalFECash =0;
                totalFEInkind =0;
            }
            
            for(Case caseTemp : budgetCaseList){
                if(ActualsMatch.contains(caseTemp.Id) && Bypass_Triggers__c.getValues(userInfo.getUserId()) == Null){
                    caseTemp.addError('The Wish Budget Actual and FE Posted total values should match.');
                    System.debug('caseerrormsg!!!'+caseTemp);
                }
                for(Id pandaItem : pandaCase.keySet()){
                    if(caseTemp.Id == pandaItem && Bypass_Triggers__c.getValues(userInfo.getUserId()) == Null){
                        for(string str : pandaCase.get(pandaItem)){ 
                            System.debug('stringmsg!!!'+caseTemp);
                            caseTemp.addError(str);
                        }
                    }
                }
            } 
        /*} 
        catch(Exception e){
            for(case newCase : budgetCaseList){
                system.debug('@@ Exception @@'+e);
                newCase.addError(e.getMessage());
            }
        } */      
    }
    
    /*********************************************************************************************************************
This method will fire when the parent case status is updated as completed or colsed or DNQ then it will check if any date
fields in planing case is null or not. If it is null then it will display error message.
*******************************************************************************************************************/
    
    public static void checkreceivedDates(List<Case> receiveDateCaseList){
        String message = '';
        Set<Id> budgetIds=new Set<Id>();
        Constant_AC  constant = new Constant_Ac();
        //try{
            for(Case caseTemp : receiveDateCaseList){
                budgetIds.add(caseTemp.Id);
                
            }
            List<case> PandACaseList= [SELECT Id,ParentId, Absent_Parent_Form__c,Child_s_Medical_Summary_Form__c,Communication_Profile__c,Date_Liability_Release_Authorization__c,
                                       Date_Received_for_Absent_Parent_Form__c,Date_Received_for_Child_s_Medical_Summar__c,Date_Received_for_Communication_Profile__c,
                                       Date_Received_for_Entertainment_Sports__c,Date_Received_for_Guardianship_Document__c,Date_Received_for_Passports__c,
                                       Date_Received_for_Single_Parent_Form__c,Date_Received_for_Visas__c,Date_Received_for_Wish_Safety_Authorizat__c,Date_Wish_Child_Form__c,
                                       Date_Wish_Family_Form__c,Date_Wish_Information_Form__c,Entertainment_Sports_Wish_LOU__c,Guardianship_Document__c,
                                       Liability_Release_and_Authorization__c,Passports__c,Single_Parent_Form__c,Visas__c,Wish_Child_Form__c,Wish_Family_Form__c,
                                       Wish_Information_Form__c,Wish_Safety_Authorization_Part_B_Form__c 
                                       FROM Case WHERE ParentId IN : budgetIds and RecordTypeId =: wishPlanningRecordTypeId LIMIT 50000];
            
            for(Case panda : PandACaseList){
                if(panda.Wish_Child_Form__c == true && panda.Date_Wish_Child_Form__c == null){ 
                    if(message == '' || message == Null)
                        message = 'Wish Child Form';
                } 
                if(panda.Wish_Family_Form__c == true && panda.Date_Wish_Family_Form__c == null){
                    if(message == '' || message == Null)
                        message = 'Wish Family Form';
                    else
                        message = message+','+'Wish Family Form';
                }
                if(panda.Wish_Information_Form__c == true && panda.Date_Wish_Information_Form__c == null){
                    if(message == '' || message == Null)
                        message = 'Wish Information Form';
                    else
                        message= message+','+'Wish Information Form';
                }
                if(panda.Liability_Release_and_Authorization__c == true && panda.Date_Liability_Release_Authorization__c == null){
                    if(message == '' || message == Null)
                        message = 'Liability Release And Authorization';
                    else
                        message= message+','+'Liability Release And Authorization'; 
                }
                if(panda.Communication_Profile__c == true && panda.Date_Received_for_Communication_Profile__c == null){
                    if(message == '' || message == Null)
                        message = 'Communication Profile';
                    else
                        message= message+','+'Communication Profile'; 
                }
                if(panda.Guardianship_Document__c == true && panda.Date_Received_for_Guardianship_Document__c == null){
                    if(message == '' || message == Null)
                        message = 'Guardianship Document';
                    else
                        message= message+','+'Guardianship Document';
                }
                if(panda.Absent_Parent_Form__c == true && panda.Date_Received_for_Absent_Parent_Form__c == null){
                    if(message == '' || message == Null)
                        message = 'Absent Parent Form';
                    else
                        message= message+','+'Absent Parent Form';
                }
                if(panda.Single_Parent_Form__c == true && panda.Date_Received_for_Single_Parent_Form__c == null){
                    if(message == '' || message == Null)
                        message = 'Single Parent Form';
                    else
                        message= message+','+'Single Parent Form';
                }
                if(panda.Wish_Safety_Authorization_Part_B_Form__c == true && panda.Date_Received_for_Wish_Safety_Authorizat__c == null){
                    if(message == '' || message == Null)
                        message = 'Wish Clearance Form';
                    else
                        message= message+','+'Wish Clearance Form';
                }
                if(panda.Child_s_Medical_Summary_Form__c == true && panda.Date_Received_for_Child_s_Medical_Summar__c == null){
                    if(message == '' || message == Null)
                        message = 'Child’s Medical Summary Form';
                    else
                        message= message+','+'Child’s Medical Summary Form';
                }
                if(panda.Passports__c== true && panda.Date_Received_for_Passports__c == null){
                    if(message == '' || message == Null)
                        message = 'Passports';
                    else
                        message= message+','+'Passports';
                }
                if(panda.Visas__c == true && panda.Date_Received_for_Visas__c == null){
                    if(message == '' || message == Null)
                        message = 'Visas';
                    else
                        message= message+','+'Visas';
                }
                if(panda.Entertainment_Sports_Wish_LOU__c == true && panda.Date_Received_for_Entertainment_Sports__c == null){
                    if(message == '' || message == Null)
                        message = 'Entertainment & Sports Wish LOU';
                    else
                        message= message+','+'Entertainment & Sports Wish LOU';               
                }
            }
            if(!String.isBlank(message)){
                for(Case caseTemp : receiveDateCaseList){
                    if(budgetIds.contains(caseTemp.Id) && Bypass_Triggers__c.getValues(userInfo.getUserId()) == Null){
                        caseTemp.addError('Please enter the received date for the following forms -'+message);
                    }  
                }
            }
        /*}
        catch(Exception e){
            for(case newCase : receiveDateCaseList){
                system.debug('@@ Exception @@'+e);
                newCase.addError(e.getMessage());
            }
        }*/   
    }
    /************************************************************************************
     *This method is used to update the Wish Clearance Needed field when the National Type is changed.
     * ***********************************************************************************/
    public static void updateWishClearanceNeeded(Map<Id,Case> changedNationaltypeCaseMap){
        Map<String,String> wishclearanceMap = new Map<string,String>();
        //Query the meta data type for all national type and wish crearance needed.
        for(Wish_Clearance_Needed_and_National_type__mdt nationaltype : [SELECT MasterLabel,Wish_Clearance_Needed__c FROM Wish_Clearance_Needed_and_National_type__mdt Limit 50000]){
            wishclearanceMap.put(nationaltype.MasterLabel,nationaltype.Wish_Clearance_Needed__c);
        }
        for(Case currCase : changedNationaltypeCaseMap.values()){
            If(wishclearanceMap.containsKey(currCase.wish_type__C)){
                currCase.Wish_Clearance_Needed__c = wishclearanceMap.get(currCase.wish_type__C);
            }
        }
    }
}