/**
 * @description Contoller to return current theme to a Lightning Component.
 * @author Eric Smith
 * @date 2018-11-23
 */
public with sharing class UIThemeController {

    @TestVisible private static String themeOverride;

    /**
     * @description Return current theme to a Lightning Component.
     * @return String
     * @author Eric Smith
     * @date 2018-11-23
     */
    @AuraEnabled
    public static String getUIThemeDescription() {
        String themedesc;
        String theme = UserInfo.getUiThemeDisplayed();

        if (((theme == 'Theme3' || theme == 'Theme2') && !Test.isRunningTest())
                || themeOverride == 'Classic') {
            themedesc = 'Salesforce Classic';
        } else if ((theme == 'Theme4d' && !Test.isRunningTest())
                || themeOverride == 'LEX') {
            themedesc = 'Lightning Experience';
        } else if ((theme == 'Theme4t' && !Test.isRunningTest())
                || themeOverride == 'Mobile') {
            themedesc = 'Salesforce1 Mobile';
        }
        return themedesc;
    }
}