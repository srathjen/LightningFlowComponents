@isTest
public class WishChildFormValUpdate_AC_Test {
    public static testMethod void createCase() {
        Case currentCase = OrientationandTrainingUtil.createParentCase();
        map<string,Case> caseDetails = new map<string,Case>();
        caseDetails.put(currentCase.id, currentCase);
        Wish_Child_Form__c newWish = new Wish_Child_Form__c();
        newWish.Case__c = currentCase.id;
        newWish.Case_Team_Member1__c = 'Member 1';
        newWish.Case_Team_Member2__c = 'Member 2';
        insert newWish;
        WishChildFormValUpdate_AC.updateWishType(caseDetails);
    }
    
    public static testMethod void callUpdateWishdetails(){
        Contact newCon = OrientationandTrainingUtil.CreateWishChild();
        Case currentCase = OrientationandTrainingUtil.createParentCase(newCon.Id);
        Case parentCase = OrientationandTrainingUtil.createParentCase();
        case wihdetermination = OrientationandTrainingUtil.createWishDeterminationCase(newCon.id, parentCase.id);
        map<Id,Case> caseDetails = new map<Id,Case>();
        caseDetails.put(currentCase.Id, currentCase);
        Wish_Child_Form__c newWish = new Wish_Child_Form__c();
        newWish.Case__c = currentCase.id;
        newWish.Case_Team_Member1__c = 'Member 1';
        newWish.Case_Team_Member2__c = 'Member 2';
        newWish.Wish_Determination_Case_Id__c = wihdetermination.id;
        insert newWish;
        WishChildFormValUpdate_AC.updateWishdetails(caseDetails);
        
    }
    public static testMethod void UpdateWishChildandWishFamily(){
        
        Contact newCon = OrientationandTrainingUtil.CreateWishChild();
        Case parentCase = OrientationandTrainingUtil.createParentCase(newCon.Id);
        Case currentCase = OrientationandTrainingUtil.createParentCase(newCon.Id);
        case wihdetermination = OrientationandTrainingUtil.createWishDeterminationCase(newCon.id, parentCase.id);
        map<Id,Case> caseDetails = new map<Id,Case>();
        caseDetails.put(currentCase.Id, currentCase);
        Wish_Child_Form__c newWish = new Wish_Child_Form__c();
        newWish.Case__c = currentCase.id;
        newWish.Wish_Family_Contact__c = 'Vennila | | Paramasivam | Spouse | 8220708920 | 8220708920 | 8220708920 | mcavennila@gmail.com | 2016-11-6';
        newWish.Driver_Details__c = 'Vennila karur | Tamil Nadu | Alabama | 2016-10-12';
        newWish.Participant_Contacts__c = 'Vennila | | karur | Child | 2016-11-01 00:00:00 | asdfasdfdsafasfdsa@12gmail.com | 12 | true | true sathis Kumar | | def | Friend | - | vi@gmail.com | | false | false';
        newWish.LastName__c = 'Test Name';
        newWish.Case_Team_Member1__c = 'Member 1';
        newWish.Case_Team_Member2__c = 'Member 2';
        newWish.Wish_Determination_Case_Id__c = wihdetermination.id;
        insert newWish;
        WishChildFormValUpdate_AC.UpdateWishChildandWishFamily(caseDetails);
        
        
    }
    
}