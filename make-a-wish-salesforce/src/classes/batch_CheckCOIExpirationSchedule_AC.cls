/**
 * @description Scheduel the batch_CheckCOIExpiration_AC class in particular time interval
 * @author MST
 * @createdDate 10/12/2017
 */
global class batch_CheckCOIExpirationSchedule_AC implements Schedulable {
	global void execute(SchedulableContext SC) {
		Database.executeBatch(new batch_CheckCOIExpiration_AC(), 200);
	}
}