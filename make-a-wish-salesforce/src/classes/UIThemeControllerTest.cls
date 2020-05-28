/*
 * @date  11/23/18
 * @author  Eric Smith
 * @description Test Class for Controller to return current theme to a Lightning Component
 */
@IsTest
public class UIThemeControllerTest {

    @IsTest
    static void getCurrentTheme() {
        UIThemeController theme = new UIThemeController();
        UIThemeController.themeOverride = 'Classic';
        System.assertEquals('Salesforce Classic', UIThemeController.getUIThemeDescription());
        UIThemeController.themeOverride = 'LEX';
        System.assertEquals('Lightning Experience', UIThemeController.getUIThemeDescription());
        UIThemeController.themeOverride = 'Mobile';
        System.assertEquals('Salesforce1 Mobile', UIThemeController.getUIThemeDescription());
    }
}