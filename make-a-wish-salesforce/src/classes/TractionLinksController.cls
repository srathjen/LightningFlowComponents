/**
 * @description Traction Links Controller, exposes methods for the front end components.
 * @author Mitali Nahar, Traction on Demand
 * @date 10/2/2019
 */
public with sharing class TractionLinksController {

	/**
     * @description Finds URL links
     * @return List of Links
     */
    @AuraEnabled
    public static List<URL_Links__c> getLinks() {
        List<URL_Links__c> links = [
                SELECT Name, Link__c
                FROM URL_Links__c
                ORDER BY CreatedDate ASC
        ];
        for (URL_Links__c url : links) {
            if (!url.Link__c.startsWith('https://')) {
                url.Link__c = 'https://' + url.Link__c;
            }
        }
        return links;
    }
}