/**
  * @description Javascript controller for the DisplayMobileFieldSets lightning component
  * @author      Mason Buhler, Traction on Demand
  * @date        2019-07-25
  */
({
	/**
	 * Load data for the component
	 *
	 * @param component   			Component reference
	 * @param event	                Event reference
	 * @param helper  				Helper reference
	 */
    doInit: function(component, event, helper) {
    	helper.fetchData(component);
    },

	/**
	 * Close the quick action modal when the back button is pressed
	 *
	 * @param component   			Component reference
	 * @param event	                Event reference
	 * @param helper  				Helper reference
	 */
    handleClickBack: function(component, event, helper) {
    	$A.get("e.force:closeQuickAction").fire();
    },

});