@isTest
Public class CreateNewWish_ACTest {

    static testmethod void createParentWish() {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        insert chapterAccount;

        /* Constituent_Code__c consTituent = OrientationandTrainingUtil.createWishParentGuardiansContituentCode();
        Constituent_Code__c  cinstChild = OrientationandTrainingUtil.createWishChildContituentCode();*/

        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        insert wishChild;

        Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        insert chapterAmericaAccount;

        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        insert parentCase;

        Contact volunterCon = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.id);
        insert volunterCon;

        User volunterUser;
        User currUser = [SELECT Id from User Where Id = :Userinfo.getUserId() LIMIT 1];
        System.runAs(currUser) {
            volunterUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunterCon.id);
            insert volunterUser;
        }

        CaseTeamRole roleRec = [SELECT Id FROM CaseTeamRole WHERE Name = 'Wish Granter'];       
        CaseTeamMember caseTeamMeber = OrientationandTrainingUtil.createCaseTeamMember(parentCase.id,volunterUser.id,roleRec.id);
        insert caseTeamMeber;

        //CreateNewWish_AC  newWish = new CreateNewWish_AC();
        CreateNewWish_AC.CreateCase(parentCase.id);
    }
}