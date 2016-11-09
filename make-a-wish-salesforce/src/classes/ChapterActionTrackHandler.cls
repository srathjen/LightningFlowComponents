/*****************************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kesavakumar Murugesan
Date        : 6/1/2016
Description : This handler holds the Validation for Required fields and its preventing duplicates. It filter the duplicate
records based on the Wish Type, Case Type Stage and Chapter Name.
*******************************************************************************************************************/

public class ChapterActionTrackHandler {
    
    //Contains validations for records
    public static void validations(List<Chapter_Action_Track__c> newActionLists) {
        
        Map<String,Integer> checkDuplicateSortOrdersMap = new Map<String,Integer>();
        Map<String, Set<Integer>> sorOrdersSet = new Map<String, Set<Integer>>();
        Set<String> wishChapterNamesSet = new Set<String>();
        Set<String> wishTypesSet = new Set<String>();
        Set<String> wishStagesSet = new Set<String>();
        
        for(Chapter_Action_Track__c chapterAction : newActionLists) {
            if(chapterAction.Recurring__c == true && chapterAction.Recurring_Frequency__c == null) {
                chapterAction.Recurring_Frequency__c.addError('Recurring Frequency cannot be blank for Recurring Task');
            }else if(chapterAction.Sort_Order__c == null) {
                chapterAction.Sort_Order__c.addError('Please Enter Sort Order');
            }else if(chapterAction.Case_Type_Stage__c == null) {
                chapterAction.Case_Type_Stage__c.addError('Please Choose Wish Stage');
            }else if(chapterAction.Assigned_To__c == null) {
                chapterAction.Assigned_To__c.addError('Please Choose Role');
            }else if(chapterAction.Sort_Order__c <= 0) {
                chapterAction.Sort_Order__c.addError('Please Enter Sort Order greater than 0');
            } else {
                if(checkDuplicateSortOrdersMap.containsKey(chapterAction.Chapter_Name__c+'-'+chapterAction.Wish_type__c+'-'+chapterAction.Case_Type_Stage__c)) {
                    if(checkDuplicateSortOrdersMap.get(chapterAction.Chapter_Name__c+'-'+chapterAction.Wish_type__c+'-'+chapterAction.Case_Type_Stage__c) == chapterAction.Sort_Order__c) {
                        chapterAction.addError('Same Sort Order Exists');
                    }
                } else {
                    checkDuplicateSortOrdersMap.put(chapterAction.Chapter_Name__c+'-'+chapterAction.Wish_type__c+'-'+chapterAction.Case_Type_Stage__c, Integer.valueOf(chapterAction.Sort_Order__c));
                    wishChapterNamesSet.add(chapterAction.Chapter_Name__c);
                    wishTypesSet.add(chapterAction.Wish_type__c);
                    wishStagesSet.add(chapterAction.Case_Type_Stage__c);
                }
            }
        }
       for(Chapter_Action_Track__c chapterActionTraks : [SELECT Id,Sort_Order__c,Chapter_Name__c,Wish_type__c,Case_Type_Stage__c FROM Chapter_Action_Track__c WHERE Wish_type__c IN : wishTypesSet AND Case_Type_Stage__c IN : wishStagesSet AND Chapter_Name__c IN : wishChapterNamesSet]) {
            if(sorOrdersSet.containsKey(chapterActionTraks.Chapter_Name__c+'-'+chapterActionTraks.Wish_type__c+'-'+chapterActionTraks.Case_Type_Stage__c)) {
                sorOrdersSet.get(chapterActionTraks.Chapter_Name__c+'-'+chapterActionTraks.Wish_type__c+'-'+chapterActionTraks.Case_Type_Stage__c).add(Integer.valueOf(chapterActionTraks.Sort_Order__c));
            } else {
                sorOrdersSet.put(chapterActionTraks.Chapter_Name__c+'-'+chapterActionTraks.Wish_type__c+'-'+chapterActionTraks.Case_Type_Stage__c, new Set<Integer>{Integer.valueOf(chapterActionTraks.Sort_Order__c)});
            }
        }
        
       for(Chapter_Action_Track__c actions : newActionLists) {
            if(sorOrdersSet.containsKey(actions.Chapter_Name__c+'-'+actions.Wish_type__c+'-'+actions.Case_Type_Stage__c)) {
                if(sorOrdersSet.get(actions.Chapter_Name__c+'-'+actions.Wish_type__c+'-'+actions.Case_Type_Stage__c).contains(Integer.ValueOf(actions.Sort_Order__c))) {
                    actions.addError('Duplicate Exists');
                }
            }
        }
    }
}