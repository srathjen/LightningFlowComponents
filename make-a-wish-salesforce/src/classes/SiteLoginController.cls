/**
 * @description An apex page controller that exposes the site login functionality.
 *
 * @author MST Solutions
 *
 * @date unknown
 */
global with sharing class SiteLoginController {
    global String username { get; set; }
    global String password { get; set; }

    /**
     * @description Login function.
     *
     * @return PageReference
     *
     * @author MST Solutions
     */
    global PageReference login() {
        String startUrl = System.currentPageReference().getParameters().get('startURL');
        return Site.login(username, password, startUrl);
    }

    global SiteLoginController() {
    }
}