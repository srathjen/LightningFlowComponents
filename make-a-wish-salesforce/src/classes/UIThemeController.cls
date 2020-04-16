/**
 * @description     Contoller to return current theme to a Lightning Component.
 *
 * @author          Eric Smith
 * @createdDate     2018-11-23
 */
public with sharing class UIThemeController {
    /**
     * @description     Return current theme to a Lightning Component.
     *
     * @return          String
     *
     * @author          Eric Smith
     * @createdDate     2018-11-23
     */
    @AuraEnabled
    public static String getUIThemeDescription() {
        String themedesc;
        String theme = UserInfo.getUiThemeDisplayed();

        if (theme == 'Theme3' || theme == 'Theme2') {
            themedesc = 'Salesforce Classic';
        } else if (theme == 'Theme4d') {
            themedesc = 'Lightning Experience';
        } else if (theme == 'Theme4t') {
            themedesc = 'Salesforce1 Mobile';
        }

        return themedesc;
    }
}