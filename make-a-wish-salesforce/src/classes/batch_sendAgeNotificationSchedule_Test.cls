@istest
public class batch_sendAgeNotificationSchedule_Test{
    static testmethod void callSchedule() {
        Test.startTest();
        batch_sendAgeNotificationSchedule_AC obj = new batch_sendAgeNotificationSchedule_AC ();
        obj.execute(null);
        Test.stopTest();
    }

}