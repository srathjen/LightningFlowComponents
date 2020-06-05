/**
 * @description This class will be used to parse LMS user Response from the Call out
 *
 * @author MST
 */
public class LMSUserResponse {
    public Integer id;
    public String login;
    public String code;
    public String first_name;
    public String last_name;
    public String email;
    public Boolean is_active;
    public String last_login_at;

    /**
     * @description
     *
     * @param json
     *
     * @return
     */
    public static LMSUserResponse parse(String json) {
        return (LMSUserResponse) System.JSON.deserialize(json, LMSUserResponse.class);
    }

}