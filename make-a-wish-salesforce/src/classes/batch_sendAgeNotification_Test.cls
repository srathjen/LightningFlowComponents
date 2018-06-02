@isTest
/*******************************************************************************************
Author : MST Solutions
Created Date:3/15/2018 
Description: This class is used to increase the code coverage for batch_sendAgeNotificationToCaseOwner_AC. 

**********************************************************************************************/
public class batch_sendAgeNotification_Test{
    //Set the wish Child age is 18.
    @isTest static void  wishChildAge18Birthday(){
         Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
         Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
         Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
         Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
         wishChild.Birthdate = Date.parse(String.valueOf(System.today().month())+'/'+String.valueOf(System.today().day())+'/'+String.valueOf(System.today().year()-18));
         Update wishChild;
         Contact childFamily = OrientationandTrainingUtil.CreateWishFamily();
         childFamily.Birthdate = Date.parse(String.valueOf(System.today().month())+'/'+String.valueOf(System.today().day())+'/'+String.valueOf(System.today().year()-18));
         Update childFamily;
         npe4__Relationship__c  npcr = OrientationandTrainingUtil.CreateRelationshipRec(wishChild.Id,childFamily.Id);
         Database.executeBatch(new batch_sendAgeNotificationToCaseOwner_AC());
     }
    //Set the wish Child age is 17 years and 11 month.
    @isTest static void  wishChildAge18beforeoneMonthBirthday(){
         Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
         Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
         Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
         Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
         If(System.today().month()+1 == 2 || System.today().month()+1 == 4 || System.today().month()+1 == 6 || System.today().month()+1 == 8 || System.today().month()+1 == 9 || System.today().month()+1 == 11 )
             wishChild.Birthdate = Date.parse(String.valueOf(System.today().month()+1)+'/'+String.valueOf(System.today().day()-1)+'/'+String.valueOf(System.today().year()-18));
         else 
             wishChild.Birthdate = Date.parse(String.valueOf(System.today().month()+1)+'/'+String.valueOf(System.today().day())+'/'+String.valueOf(System.today().year()-18));
         Update wishChild;
         Contact childFamily = OrientationandTrainingUtil.CreateWishFamily();
          If(System.today().month()+1 == 2 || System.today().month()+1 == 4 || System.today().month()+1 == 6 || System.today().month()+1 == 8 || System.today().month()+1 == 9 || System.today().month()+1 == 11 )
              childFamily.Birthdate = Date.parse(String.valueOf(System.today().month()+1)+'/'+String.valueOf(System.today().day()-1)+'/'+String.valueOf(System.today().year()-18));
         else
             childFamily.Birthdate = Date.parse(String.valueOf(System.today().month()+1)+'/'+String.valueOf(System.today().day())+'/'+String.valueOf(System.today().year()-18));
         Update childFamily;
         npe4__Relationship__c  npcr = OrientationandTrainingUtil.CreateRelationshipRec(wishChild.Id,childFamily.Id);
         Database.executeBatch(new batch_sendAgeNotificationToCaseOwner_AC());
     }
     //Set the wish Participant age is 18.
   /* @isTest static void  wishParticipantAge18Birthday(){
         Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
         Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
         Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
         Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
         wishChild.Birthdate = Date.parse(String.valueOf(System.today().month())+'/'+String.valueOf(System.today().day())+'/'+String.valueOf(System.today().year()-18));
         Update wishChild;
         Database.executeBatch(new batch_sendAgeNotificationToCaseOwner_AC());
     }*/
}