/************************************************************************************
Author : Mst Solutions
Description : This class is used to increase the code coverage for Create Subcases
*************************************************************************************/
@isTest
public class CreateSubCases_AC_Test {
    
    //Used to create sub cases
    static testmethod void createSubCase() {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        CreateSubCases_AC.createChildCases(parentCase.Id);
    }
    
}