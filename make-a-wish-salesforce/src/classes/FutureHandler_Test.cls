//Created by: MST
//This class will create the task and gets updated
@isTest
public class FutureHandler_Test {
    public static testmethod void createTask(){
        Task newTask = new task();
        newTask.Subject = 'Test';
        newTask.Status = 'Not Started';
        newTask.Priority = 'Normal';
        test.startTest();
        
        insert newTask;
        FutureHandler.UpdateTask(newTask.id);
        test.stopTest();
    }

}