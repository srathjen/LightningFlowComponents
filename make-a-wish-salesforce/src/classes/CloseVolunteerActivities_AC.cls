/**
 * @description     This class is used to close the task when the volunteer clicks on "Mark Task Completed" button
 *                  from the Task page layout.
 *
 * @author          MST Solutions
 * @createdDate     2017-03-20
 */
global class CloseVolunteerActivities_AC {
    /**
     * @description     Used to close the volunteer task when mark completed button clicked by volunteer users
     *                  from the Task page layout.
     *
     * @param           Id taskId
     *
     * @return          Id
     *
     * @author          MST Solutions
     * @createdDate     2017-03-20
     */
    webService static Id CloseTask(Id taskId) {
        Task aTask;

        try {
            aTask = [SELECT Id FROM Task WHERE Id = :taskId];
        } catch (System.QueryException ex) {
            return null;
        }

        aTask.Status = Constant_AC.TASK_STATUS_COMPLETED;

        update aTask;

        return null;
    }
}