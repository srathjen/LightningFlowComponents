// Author: Jason Nguyen | Client: Make-A-Wish | Project: Wish Referral Form UI logic
// Modifications: 05/20/2019 - Samer - SIW-221
//                Modified code to accurately calculate age. Also, when calculating 6 months,
//                if the birth date is on the 31st or on Feb/29 and the 6th month goes to
//                30 days or 28 from Feb, then use the last day of the month.
//
//                05/27/2019 - Samer - SIW-245
//                Accept inquiries for children who are younger than 1 years old.
//
//                06/25/2019 - Samer - SIW-246
//                When a child age at referral is between 2.5 and younger than 3 years old,
//                the "Age at Referral" should be listed as 2.5.
//
//                02/12/2019 - Manoj - SIW-374
//                Age at referral does not update from DOB field.
//
//                02/12/2019 - Manoj - SIW-487
//                Referral: Prevent referrers submitting without consulting with their medical team
//
//                04/08/2020 - Manoj - SIW-555
//                Added custom email validation rule
//
//                04/17/2020 - Manoj - SIW-575
//                Removed Primary language validation from here as applied in VF Page itself
//
//                27/04/2020 - Manoj - SIW-556
//                Updated text even when users select No in question "HAS THE REFERRAL BEEN DISCUSSED WITH THE CHILD'S HEALTHCARE PROVIDER?"
//
//                05/26/2020 - Manoj - SIW-372
//                Made phone as required field under treating medical professional information
//
//                06/17/2020 - Manoj - SIW-532
//                removed method isTextSelected for phone number validation
//
//                06/18/2020 - Manoj - SIW-330
//                Limit Primary Diagnosis field to only accept values from drop-down
//
// format phone/date fields
// target desktop
// if (window.matchMedia("(min-width: 47.5rem)").matches) {
//$(".phonemask").mask("(999) 999-9999").attr('maxlength','15');
// }
//$(".phonemask").attr('type','tel');
$("[id$=wcdob]").removeAttr("onfocus").mask("99/99/9999", {
    placeholder: "mm/dd/yyyy",
});
$("[id$=email],[id$=pemailaddress],[id$=pemailaddress2],[id$=mpemail]").attr(
    "type",
    "email"
);
$(".main-office-contact").css("display", "none");

// unwrap/remove table from radio fields and rebuild for responsiveness
$(".r2c fieldset table tr td")
    .children()
    .unwrap()
    .unwrap()
    .unwrap()
    .unwrap()
    .unwrap();
$(".r2c input:first").clone().prependTo(".r2c label:first");
$(".r2c input:nth-child(3)").clone().prependTo(".r2c label:nth-child(4)");
$(".r2c input:nth-child(5)").clone().prependTo(".r2c label:nth-child(6)");
$(".r2c input:nth-child(7)").clone().prependTo(".r2c label:nth-child(8)");
$(".r2c input:nth-child(9)").clone().prependTo(".r2c label:nth-child(10)");
// remove original inputs
$(".r2c > input").remove();
// make labels responsive
$(".r2c label").addClass("col-xs-12 col-sm-6");
$(".r2c label input").attr("name", "r2c-radio");
$(".r2c-radio").click(function () {
    $(".familyAware").parent().parent().show();
});
// set id dynamically for MAW GA
// $('.r2c label:first').attr('id','rel-self');
// $('.r2c label:nth-child(2)').attr('id','rel-medical');
// $('.r2c label:nth-child(3)').attr('id','rel-parent');
// $('.r2c label:nth-child(4)').attr('id','rel-family');
// $('.r2c label:nth-child(5)').attr('id','rel-other');

formLogic();

// get radio selection
function getRadioVal(form, name) {
    var val;
    // get list of radio buttons with specified name
    var radios = form.elements[name];

    // loop through list of radio buttons
    for (var i = 0, len = radios.length; i < len; i++) {
        if (radios[i].checked) {
            // radio checked?
            val = radios[i].value; // if so, hold its value in val
            break; // and break out of for loop
        }
    }
    return val; // return value of checked radio or undefined if none checked
}

// default select option
$("select")
    .not(".state,.multi")
    .each(function () {
        $(this).find("option:first").remove(); // remove first
        if ($(this).attr("id") == "j_id0:frm:diagnosisYear") {
            $("#j_id0\\:frm\\:diagnosisYear").prepend(
                '<option value="">Year</option>'
            );
        } else if ($(this).attr("id") == "j_id0:frm:diagnosisMonth") {
            $("#j_id0\\:frm\\:diagnosisMonth").prepend(
                '<option value="">Month</option>'
            );
        } else {
            $(this).prepend(
                "<option selected disabled>Please select an option</option>"
            );
        }
    });
// diagnosis month change
$("[id$=diagnosisMonth]").on("change", function () {
    var diagnosisYear = $("[id$=diagnosisYear]");
    if ($(this).val() != "") {
        diagnosisYear.addClass("d-year");
        formValidationRules();
    } else {
        resetSelect(diagnosisYear);
        diagnosisYear.rules("remove");
        diagnosisYear
            .removeAttr("aria-required aria-describedby aria-invalid")
            .removeClass("d-year")
            .valid();
    }
});
// diagnosis year change
$("[id$=diagnosisYear]").on("change", function () {
    var diagnosisMonth = $("[id$=diagnosisMonth]");
    if ($(this).val() != "") {
        diagnosisMonth.addClass("d-month");
        formValidationRules();
    } else {
        diagnosisMonth.rules("remove");
        diagnosisMonth
            .removeAttr("aria-required aria-describedby aria-invalid")
            .removeClass("d-month")
            .valid();
    }
});

$(".numbers-only").keydown(function (e) {
    // Allow: backspace, delete, tab, escape and enter
    if (
        $.inArray(e.keyCode, [46, 8, 9, 27, 13, 110]) !== -1 ||
        // Allow: Ctrl+A
        (e.keyCode == 65 && e.ctrlKey === true) ||
        // Allow: Ctrl+C
        (e.keyCode == 67 && e.ctrlKey === true) ||
        // Allow: Ctrl+X
        (e.keyCode == 88 && e.ctrlKey === true) ||
        // Allow: home, end, left, right
        (e.keyCode >= 35 && e.keyCode <= 39)
    ) {
        // let it happen, don't do anything
        return;
    }
    // Ensure that it is a number and stop the keypress
    else if (
        (e.shiftKey || e.keyCode < 48 || e.keyCode > 57) &&
        (e.keyCode < 96 || e.keyCode > 105 || e.keyCode == 191)
    ) {
        e.preventDefault();
    }
});
$(".alpha-only").keydown(function (e) {
    // Allow: backspace, delete, tab, escape, enter, spacebar and .
    if (
        $.inArray(e.keyCode, [46, 8, 9, 27, 13, 110, 190, 32]) !== -1 ||
        // Allow: Ctrl+A, Command+A
        (e.keyCode === 65 && (e.ctrlKey === true || e.metaKey === true)) ||
        // Allow: Ctrl+C, Command+C
        (e.keyCode == 67 && (e.ctrlKey === true || e.metaKey === true)) ||
        // Allow: Ctrl+X, Command+X
        (e.keyCode == 88 && (e.ctrlKey === true || e.metaKey === true)) ||
        // Allow: home, end, left, right, shift
        (e.keyCode >= 35 && e.keyCode <= 39) ||
        e.shiftKey
    ) {
        // let it happen, don't do anything
        return;
    }
    // Ensure that it is a number and stop the keypress
    if (e.keyCode < 65 || e.keyCode > 90) {
        e.preventDefault();
    }
});
// auto format date
// $(".date-std").keydown(function(e){
//   if (($(this).val().length == 2) && (e.keyCode != 8)){
//     $(this).val($(this).val() + "/");
//   } else if (($(this).val().length == 5)  && (e.keyCode != 8)){
//     $(this).val($(this).val() + "/");
//   }
//   if ( (($(this).val().length == 4) || ($(this).val().length == 7) ) && (e.keyCode == 8) ){
//     // remove dash
//     $(this).val($(this).val().substring(0, $(this).val().length - 1));
//   }
// });

// auto format postal code
// $(".postalcode").keydown(function(e){
//   if (($(this).val().length == 5) && (e.keyCode != 8) && (e.keyCode != 9)){
//     // auto insert dash on 5th character keypress
//     $(this).val($(this).val() + "-");
//   }
//   if (($(this).val().length == 7) && (e.keyCode == 8)){
//     // remove dash if on 7th character backspace is used
//     $(this).val($(this).val().substring(0, $(this).val().length - 1));
//   }
// });

// check if inputted value is selected
function isTextSelected(input) {
    if (typeof input.selectionStart == "number") {
        return (
            input.selectionStart == 0 && input.selectionEnd == input.value.length
        );
    } else if (typeof document.selection != "undefined") {
        input.focus();
        return document.selection.createRange().text == input.value;
    }
}

// auto format phone
$(".phonemask").keydown(function (e) {
    if ($(this).val().length == 0 && e.keyCode != 8) {
        $(this).val($(this).val() + "(");
    } else if ($(this).val().length == 4 && e.keyCode != 8) {
        $(this).val($(this).val() + ") ");
    } else if ($(this).val().length == 9 && e.keyCode != 8) {
        $(this).val($(this).val() + "-");
    }
    // if backspace or tab is pressed on certain lengths
    if (
        (($(this).val().length == 2 || $(this).val().length == 11) &&
            e.keyCode == 8) ||
        ($(this).val().length == 2 && e.keyCode == 9)
    ) {
        // remove dash or parenthesis
        $(this).val(
            $(this)
                .val()
                .substring(0, $(this).val().length - 1)
        );
    }
    // if backspace is pressed on deletion of digit before space
    if ($(this).val().length == 7 && e.keyCode == 8) {
        // remove space and parenthesis
        $(this).val(
            $(this)
                .val()
                .substring(0, $(this).val().length - 2)
        );
    }
    //SIW-532: Phone number disappear issue
    // if full phone number isn't entered and tab is pressed
    if (e.keyCode == 9) {
        if ($(this).val().length != 10) {
            if ($(this).val().length != 14) {
                $(this).val("");
            }
        }
    }
});
$(".phonemask").attr("maxlength", "14");

// second guardian
$(".guardian-2").css("display", "block");
$(".add-guardian").parents(".connected").prop("hidden", true);
$(".add-guardian").on("click", function (e) {
    e.preventDefault();
    // reset
    $(
        "input[id$=frm\\:pfirstname2],input[id$=frm\\:plastname2],input[id$=pphonenumber2],input[id$=pemailaddress2],input[id$=pcity2],input[id$=ppostalcode2],select[id$=p-state2],input[id$=paddress2],select[id$=plang2],input[id$=psibfirstname2],input[id$=psiblastname2],input[id$=psibage2]"
    ).val("");
    $("[id$=p-state2]").prop("selectedIndex", 0);

    $(this).parents(".connected").prop("hidden", true);
    $(".guardian-2").css("display", "block");
    if ($("[id$=p-state2] option:nth-child(2)").text() == "Select an option") {
        // remove 'select an option' option (gets replaced with 'Please select a State')
        $("[id$=p-state2] option:nth-child(2)").remove();
    }
    $("select[id$=p-r2c-2]").prop("selectedIndex", 0);
    //$('select[id$=p-r2c-2]').addClass('r2c-select');
    formValidationRules();
});
$(".remove-block").on("click", function (e) {
    e.preventDefault();
    $(".add-guardian").parents(".connected").prop("hidden", false);
    $(".guardian-2").css("display", "none");
    // reset
    $(
        "input[id$=frm\\:pfirstname2],input[id$=frm\\:plastname2],input[id$=pphonenumber2],input[id$=pemailaddress2],input[id$=pcity2],input[id$=ppostalcode2],select[id$=p-state2],select[id$=p-r2c-2],input[id$=paddress2],select[id$=plang2],input[id$=psibfirstname2],input[id$=psiblastname2],input[id$=psibage2]"
    ).val("");
    $("[id$=p-state2]").prop("selectedIndex", 0);
});

// chosen.js - state select
function stateFunc() {
    $("select.state option:first").remove(); // remove first
    $(".state").prepend(
        '<option disabled="disabled" selected="selected">Please select a State</option>'
    );
}

stateFunc();

$("select.multi").chosen({
    disable_search: true,
    placeholder_text_multiple: "Please select all that apply",
    width: "100%",
});
$("select.multi")
    .find("option:first")
    .prop("disabled", true)
    .trigger("chosen:updated");
(function () {
    var chosen = $("select.multi").chosen().data("chosen");
    var autoClose = false;

    //...

    if (chosen && chosen.hasOwnProperty("result_select")) {
        var chosen_resultSelect_fn = chosen.result_select;
        chosen.result_select = function (evt) {
            var resultHighlight = null;

            if (autoClose == false) {
                evt["metaKey"] = true;
                evt["ctrlKey"] = true;

                resultHighlight = chosen.result_highlight;
            }

            var result = chosen_resultSelect_fn.call(chosen, evt);

            if (autoClose == false && resultHighlight != null)
                resultHighlight.addClass("result-selected");

            return result;
        };
    }
})();

// reset select element
function resetSelect() {
    var options = document.querySelectorAll("select option");
    for (var i = 0, l = options.length; i < l; i++) {
        options[i].selected = options[i].defaultSelected;
    }
}

// show/hide, field dupe, validation logic
function formLogic() {
    var link =
            '<a href="https://wish.org/local-chapters#sm.000001nnnt2f0tf0tux692bqfeli5" target="_blank">Click here for a local chapter directory</a>',
        familyAwareError =
            "Please make sure the family is aware of this referral before you proceed. If you have additional questions please reach out to your local chapter. ",
        referralDiscussedError =
            "We recommend that you discuss potential eligibility with the child's treating healthcare provider before you proceed. If you have additional questions please reach out to your local chapter. ", //SIW-487 : Added error message
        labels = [
            " Self",
            " Medical Professional",
            " Parent/Guardian",
            " Family Member/Relative",
            " Other",
        ],
        rerender = [" Self", " Parent/Guardian", " Family Member/Relative"],
        medicalProviders = [
            "Nurse Practitioner",
            "Physician Assistant",
            "Physician",
        ],
        childAgesEligible = [
            "2.5",
            "3",
            "4",
            "5",
            "6",
            "7",
            "8",
            "9",
            "10",
            "11",
            "12",
            "13",
        ],
        fieldClasses = [
            "firstname",
            "lastname",
            "phonechk",
            "email",
            "city",
            "state-chk",
            "address",
            "postalcode",
            "family-aware-chk",
            "medprovider",
            "r2c-manual-input",
            "wcgender",
            "wcage",
            "wcdob",
            "wcreceivedwish",
            "language",
            "siblings-chk",
            "icd",
            "pdiagnosis",
            "facility",
            "urgency",
            "sibage",
        ],
        eligibleMsg =
            "To be eligible, children must be older than 2½ years old and younger than 18 years old.",
        guardianPermissionMsg =
            "Please confirm that you have received your parent or guardians permission to complete this form.";
    refDisAddError =
        "If you would like to proceed, please fill out the form below."; //Added for SIW-556
    // To display error message when no is selected in is family aware input field
    $(".familyAware").on("change", function () {
        if ($(this).val() == "No") {
            var labelName = $(".radioSection input:checked").parent().text();
            var labelsAvailable = $.inArray(labelName, labels);
            $(".familyAwareError").css("display", "block");
            $(".medprovcat-other-wrap").css("display", "none");
            $(".medprovcat-other").val("");
            if (labelsAvailable > -1) {
                $(this)
                    .next(".familyAwareError")
                    .text(familyAwareError)
                    .append($(link));
                if (labelName == " Medical Professional") {
                    $(".medicalProvider").css("display", "none");
                }
                if (labelName == " Other") {
                    $(".r2c-manual-input").parent().parent().css("display", "none");
                    $(this)
                        .next(".familyAwareError")
                        .text(familyAwareError)
                        .append($(link));
                }
            } else {
                $(".familyAwareError, .medprovcat-other-wrap").css("display", "none");
                $(".medprovcat-other").val("");
            }
        } else if ($(this).val() == "Yes") {
            var labelName = $(".radioSection input:checked").parent().text();
            $(this).next("span").text("");
            if (labelName == " Medical Professional") {
                $(".medicalProvider").css("display", "block");
            }
            if (labelName == " Other") {
                $(".r2c-manual-input")
                    .parent()
                    .parent()
                    .removeClass("displayNone")
                    .css("display", "block");
            }
        } else {
            $(".familyAwareError").css("display", "none");
        }
    });

    //SIW -487 Added condition for new question
    $(".discussedProvider").on("change", function () {
        if ($(this).val() == "No") {
            var labelName = $(".radioSection input:checked").parent().text();
            var labelsAvailable = $.inArray(labelName, labels);
            $(".discussedProviderError").css("display", "block");
            $(".medprovcat-other-wrap").css("display", "none");
            $(".medprovcat-other").val("");
            if (labelsAvailable > -1) {
                //SIW-556 Start : Added if-else condition to update text
                if (labelName == " Other" || labelName == " Medical Professional") {
                    $(this)
                        .next(".discussedProviderError")
                        .text(referralDiscussedError)
                        .append($(link));
                } else {
                    $(this)
                        .next(".discussedProviderError")
                        .text(referralDiscussedError)
                        .append($(link))
                        .append(". " + refDisAddError);
                }
                //SIW-556 End
                if (labelName == " Medical Professional") {
                    $(".medicalProvider").css("display", "none");
                }
                if (labelName == " Other") {
                    $(".r2c-manual-input").parent().parent().css("display", "none");
                    $(this)
                        .next(".discussedProviderError")
                        .text(referralDiscussedError)
                        .append($(link));
                }
            } else {
                $(".discussedProviderError, .medprovcat-other-wrap").css(
                    "display",
                    "none"
                );
                $(".medprovcat-other").val("");
            }
        } else if ($(this).val() == "Yes") {
            var labelName = $(".radioSection input:checked").parent().text();
            $(this).next("span").text("");
            if (labelName == " Medical Professional") {
                $(".medicalProvider").css("display", "block");
            }
            if (labelName == " Other") {
                $(".r2c-manual-input")
                    .parent()
                    .parent()
                    .removeClass("displayNone")
                    .css("display", "block");
            }
        } else {
            $(".discussedProviderError").css("display", "none");
        }
    });

    // Self-describe textarea
    $("#j_id0\\:frm\\:wcgender").on("change", function () {
        if ($(this).val() != null) {
            if ($(this).val().indexOf("Self-describe") != -1) {
                $(".self-desc").prop("hidden", false);
                $(".self-desc-field").addClass("selfdescreq");
            } else {
                $(".self-desc").prop("hidden", true);
                $(".self-desc-field").removeClass("selfdescreq").val("");
            }
            formValidationRules();
        }
    });

    // other relationship show/hide
    $(".medprovcat-other-wrap").css("display", "none"); // onload
    $("[id$=medprov]").on("change", function () {
        if ($(this).val() != null) {
            if ($(this).val().indexOf("Other") != -1) {
                $(".medprovcat-other-wrap").css("display", "block");
            } else {
                $(".medprovcat-other-wrap").css("display", "none");
                $(".medprovcat-other").val("");
            }
        }
    });

    //show form fields to create new referral mp if checkbox is true
    $(".newRefMpChk").on("change", function () {
        checkVisible = $(".newRefMpChk input").is(":checked");
        if (checkVisible == true) {
            document.getElementById("refMpForm").style.display = 'block';
            $(".refNewAff").css("display", "none");
        } else if (checkVisible == false) {
            document.getElementById("refMpForm").style.display = 'none';
            $(".refMpForm :input").each(function () {
                $(this).val("");
            });
            $("[id$=refmpsalutation],[id$=refmpspecialty]").prop("selectedIndex", 0);
        }
    });

    //show form fields to create new treating mp if checkbox is true
    $(".newTrtMpChk").on("change", function () {
        checkVisible = $(".newTrtMpChk input").is(":checked");
        if (checkVisible == true) {
            document.getElementById("trtMpForm").style.display = 'block';
            $(".trtNewAff").css("display", "none");
        } else if (checkVisible == false) {
            document.getElementById("trtMpForm").style.display = 'none';
            $(".medToRepeat :input").each(function () {
                $(this).val("");
            });
            $("[id$=msalutation],[id$=mcategory],[id$=mspecialty]").prop("selectedIndex", 0);
        }
    });

    //show form fields to create new best contact mp if checkbox is true
    $(".newBestMpChk").on("change", function () {
        checkVisible = $(".newBestMpChk input").is(":checked");
        if (checkVisible == true) {
            document.getElementById('medToRepeatBest').style.display = 'block';
            $(".bestNewAff").css("display", "none");
        } else if (checkVisible == false) {
            document.getElementById('medToRepeatBest').style.display = 'none';
            $("#medToRepeatBest :input").each(function () {
                $(this).val("");
            });
            $("[id$=bsalutation],[id$=bcategory],[id$=bspecialty]").prop("selectedIndex", 0);
        }
    });

    //show form fields to create new referral HTF if checkbox is true
    $(".newRefHtfChk").on("change", function () {
        checkVisible = $(".newRefHtfChk input").is(":checked");
        if (checkVisible == true) {
            document.getElementById("refHtfForm").style.display = 'block';
        } else if (checkVisible == false) {
            document.getElementById("refHtfForm").style.display = 'none';
            $("#refHtfForm :input").each(function () {
                $(this).val("");
            });
            $("[id$=refhtfdept]").prop("selectedIndex", 0);
        }
    });

    //show form fields to create new referral HTF if checkbox is true
    $(".newTrtHtfChk").on("change", function () {
        checkVisible = $(".newTrtHtfChk input").is(":checked");
        if (checkVisible == true) {
            document.getElementById("trtHtfForm").style.display = 'block';
        } else if (checkVisible == false) {
            document.getElementById("trtHtfForm").style.display = 'none';
            $("#trtHtfForm :input").each(function () {
                $(this).val("");
            });
            $("[id$=trthtfdept]").prop("selectedIndex", 0);
        }
    });

    //showing the check box used to replicate the value
    $(".medProvCat").on("change", function () {
        var medValSelected = $(".medProvCat").val();
        var medVal = $.inArray(medValSelected, medicalProviders);
        if (medVal > -1) {
            $(".repeatMedProf").css("display", "block");
            $(".repeatMedProfBest").css("display", "block");
        } else {
            $(".repeatMedProf").css("display", "none");
            $(".repeatMedProfBest").css("display", "none");
        }
    });

    //Replicating referrer value to treating medical professional
    $(".repeatMedProf").on("change", function () {
        checkVisibleCopy = $(".repeatMedProf input").is(":checked");
        checkVisibleNewMp = $(".newRefMpChk input").is(":checked");
        checkVisibleNewHtf = $(".newRefHtfChk input").is(":checked");
        if (checkVisibleCopy == true) {
            if (checkVisibleNewMp == true) {
                $(".msalutation").val($(".refmpsalutation").val());
                $(".mfirstname").val($(".refmpfirstname").val());
                $(".mlastname").val($(".refmplastname").val());
                $(".mphone").val($(".refmpphone").val());
                $(".memail").val($(".refmpemail").val());
                $(".mcity").val($(".refmpcity").val());
                $(".mstate").val($(".refmpstate").val());
                $(".mcategory").val($(".refmpcategory").val());
                $(".mspecialty").val($(".refmpspecialty").val());
                $(".mzip").val($(".refmpzip").val());
            } else if (checkVisibleNewMp == false) {
                $(".medToRepeat :input").each(function () {
                    $(this).val("");
                });
            }
            if (checkVisibleNewHtf == true) {
                $(".trthtfname").val($(".refhtfname").val());
                $(".trthtfcity").val($(".refhtfcity").val());
                $(".trthtfstate").val($(".refhtfstate").val());
                $(".trthtfstreet").val($(".refhtfstreet").val());
                $(".trthtfzip").val($(".refhtfzip").val());
                $(".trthtfphone").val($(".refhtfphone").val());
                $(".trthtfdept").val($(".refhtfdept").val());
            } else if (checkVisibleNewHtf == false) {
                $("#trtHtfForm :input").each(function () {
                    $(this).val("");
                });
            }
            $(".trtmpaffphone").val($(".refmpaffphone").val());
            $(".trtmpaffemail").val($(".refmpaffemail").val());
            $(".trtMpInfo").css("display", "none");
            $(".repeatMedProfBest").css("display", "none");
        } else if (checkVisibleCopy == false) {
            $(".repeatMedProfBest").css("display", "block");
            $(".medToRepeat :input, #trtHtfForm :input").each(function () {
                $(this).val("");
            });
            $("[id$=msalutation],[id$=mcategory],[id$=mspecialty],[id$=trthtfdept]").prop("selectedIndex", 0);
            $("[id$=trtmpaffphone], [id$=trtmpaffemail]").val("");
            $(".trtMpInfo").css("display", "block");
        }
    });

    //Replicating referrer values to best medical contact
    $(".repeatMedProfBest").on("change", function () {
        checkVisibleCopy = $(".repeatMedProfBest input").is(":checked");
        checkVisibleNew = $(".newRefMpChk input").is(":checked");
        if (checkVisibleCopy == true) {
            if (checkVisibleNew == true) {
                $(".bsalutation").val($(".refmpsalutation").val());
                $(".mpmaincontactfirstname").val($(".refmpfirstname").val());
                $(".mpmaincontactlastname").val($(".refmplastname").val());
                $(".mpmaincontactphone").val($(".refmpphone").val());
                $(".mpmaincontactemail").val($(".refmpemail").val());
                $(".bcity").val($(".refmpcity").val());
                $(".bstate").val($(".refmpstate").val());
                $(".bcategory").val($(".refmpcategory").val());
                $(".bspecialty").val($(".refmpspecialty").val());
                $(".bzip").val($(".refmpzip").val());
            } else if (checkVisibleNew == false) {
                $("#medToRepeatBest :input").each(function () {
                    $(this).val("");
                });
            }
            $(".bestmpaffphone").val($(".refmpaffphone").val());
            $(".bestNewAffEmail").val($(".refmpaffemail").val());
            $(".bestMpInfo").css("display", "none");
            $(".repeatMedProf").css("display", "none");
        } else if (checkVisibleCopy == false) {
            $(".repeatMedProf").css("display", "block");
            $("#medToRepeatBest :input").each(function () {
                $(this).val("");
            });
            $("[id$=bsalutation],[id$=bcategory],[id$=bspecialty]").prop("selectedIndex", 0);
            $("[id$=bestmpaffphone], [id$=bestmpaffemail]").val("");
            $(".bestMpInfo").css("display", "block");
        }
    });

    //Replicating referrer value to child information
    function childClone() {
        var radioSelfSel = $(".radioSection input:checked").parent().text();
        if (radioSelfSel == " Self") {
            $(".wcfirstname").val($(".rfirstname").val());
            $(".wclastname").val($(".rlastname").val());
        }
    }

    $(".refToRepeat :input").on("keyup", childClone);

    //Replicating referrer value to parent information
    function parentClone() {
        var radioSelfSel = $(".radioSection input:checked").parent().text();
        if (radioSelfSel == " Parent/Guardian") {
            $(".pfirstname1").val($(".rfirstname").val());
            $(".plastname1").val($(".rlastname").val());
            $(".pphone1").val($(".rphone").val());
            $(".pemailaddress1").val($(".remail").val());
            $(".pcity1").val($(".rcity").val());
            $(".ppostalcode1").val($(".rpostalcode").val());
        }
    }

    // clone guardian-1 address to guardian-2
    $(".clone-guardian-1 input").click(function () {
        if ($(this).is(":checked")) {
            $("[id$=paddress2]").val($("[id$=paddress]").val());
            $("[id$=pcity2]").val($("[id$=pcity]").val());
            $("[id$=p-state2]").val($("[id$=p-state]").val());
            $("[id$=ppostalcode2]").val($("[id$=ppostalcode]").val());
        } else {
            $("[id$=paddress2], [id$=pcity2], [id$=ppostalcode2]").val("");
            $("[id$=p-state2]").prop("selectedIndex", 0);
        }
    });

    $(".refToParent :input").on("keyup", parentClone);

    //To display number of sibling field
    $("[id$=nSib],[id$=nSib2]").on("change", function () {
        var r2cRadioSelected = getRadioVal(
            document.getElementById("j_id0:frm"),
            "r2c-radio"
        );

        // fire x amount of times
        function setIntervalX(callback, delay, repetitions) {
            var x = 0;
            var intervalID = window.setInterval(function () {
                callback();
                if (++x === repetitions) {
                    window.clearInterval(intervalID);
                }
            }, delay);
        }

        if (
            $(this).val() != "" ||
            $(this).val() != "0" ||
            $(this).val() != "Unknown"
        ) {
            $(".sibInfo").css("display", "block");
            // if self or parent/guadian
            if (r2cRadioSelected == "Self" || r2cRadioSelected == "Parent/Guardian") {
                console.log("self or parent/guardian selected");
                setIntervalX(
                    function () {
                        $("[id$=psibfirstname],[id$=psibfirstname2]").addClass("firstname");
                        $("[id$=psiblastname],[id$=psiblastname2]").addClass("lastname");
                        $("[id$=psibage],[id$=psibage2]").addClass("sibage");
                        formValidationRules();
                    },
                    100,
                    3
                );
            }
        } else {
            $(".sibInfo").css("display", "none");
            setIntervalX(
                function () {
                    $("[id$=psibfirstname],[id$=psibfirstname2]").removeClass("firstname");
                    $("[id$=psiblastname],[id$=psiblastname]").removeClass("lastname");
                    $("[id$=psibage],[id$=psibage]").removeClass("sibage");
                    // remove validation
                    $(
                        "input[id$=psibfirstname],input[id$=psibfirstname2],input[id$=psiblastname],input[id$=psiblastname2],input[id$=psibage],input[id$=psibage2]"
                    ).each(function () {
                        $(this).rules("remove");
                    });
                },
                100,
                3
            );
        }
    });

    //Common deleting other than self or parent/ gaurdian
    function clearFuncSelf() {
        $(".wcfirstname").val($(".rfirstname").val());
        $(".wclastname").val($(".rlastname").val());
        if ($(".wcfirstname").val() == $(".rfirstname").val()) {
            $(".wcfirstname").val("");
        }
        if ($(".wclastname").val() == $(".rlastname").val()) {
            $(".wclastname").val("");
        }
    }

    function clearFuncParent() {
        $(".pfirstname").val($(".rfirstname").val());
        $(".plastname").val($(".rlastname").val());
        $(".pphone").val($(".rphone").val());
        $(".pemailaddress").val($(".remail").val());
        $(".pcity").val($(".rcity").val());
        $(".ppostalcode").val($(".rpostalcode").val());

        if ($(".pfirstname").val() == $(".rfirstname").val()) {
            $(".pfirstname").val("");
        }
        if ($(".plastname").val() == $(".rlastname").val()) {
            $(".plastname").val("");
        }
        if ($(".pphone").val() == $(".rphone").val()) {
            $(".pphone").val("");
        }
        if ($(".pemailaddress").val() == $(".remail").val()) {
            $(".pemailaddress").val("");
        }
        if ($(".pcity").val() == $(".rcity").val()) {
            $(".pcity").val("");
        }
        if ($(".ppostalcode").val() == $(".rpostalcode").val()) {
            $(".ppostalcode").val("");
        }
    }

    // reset aware-of-referral and field validation
    function resetCommonFields() {
        var validationSelectId = [
            "[id$=aware-of-referral],[id$=wcage],[id$=wcreceivedwish],[id$=plang],[id$=plang2],[id$=nSib],[id$=nSib2],[id$=urgency],[id$=p-r2c-1],[id$=p-r2c-2],[id$=p-state],[id$=p-state2],[id$=diagnosisMonth],[id$=diagnosisYear]",
        ];

        // reset form validation
        $("form[id$=frm]").validate().resetForm();

        // reset form validation classes/rules
        function resetFormValidationClasses() {
            $("input,select")
                .removeClass(
                    "r2c-select firstname lastname phonechk email city state-chk address postalcode family-aware-chk medprovider r2c-manual-input wcgender wcage wcdob wcreceivedwish language siblings-chk icd pdiagnosis facility urgency sibage required d-month d-year"
                )
                .removeAttr("aria-required aria-describedby");

            // remove form validation rules
            $(
                "select[id$=aware-of-referral],select[id$=medprov],select[id$=p-r2c-2],input[id$=rfirstname],input[id$=frm\\:pfirstname],input[id$=frm\\:pfirstname2],input[id$=wcfirstname]input,[id$=mpfirstname],input[id$=rlastname],input[id$=frm\\:plastname],input[id$=frm\\:plastname2],input[id$=wclastname],input[id$=mplastname],input[id$=rphone],input[id$=pphonenumber],input[id$=pphonenumber2],input[id$=mpphone],input[id$=remail],input[id$=pemailaddress],input[id$=pemailaddress2],input[id$=pcity],input[id$=pcity2],input[id$=ppostalcode],input[id$=ppostalcode2],select[id$=p-state],select[id$=p-state2],input[id$=wcdob],select[id$=wcreceivedwish],select[id$=wcgender],input[id$=paddress],input[id$=paddress2],select[id$=plang],select[id$=plang2],input[id$=searchDiagnosisId],input[id$=mphospitalname],input[id$=psibfirstname],input[id$=psibfirstname2],input[id$=psiblastname],input[id$=psiblastname2],input[id$=psibage],input[id$=psibage2],select[id$=frm\\:diagnosisMonth],select[id$=frm\\:diagnosisYear],select[id$=urgency]"
            ).each(function () {
                $(this).rules("remove");
            });
        }

        resetFormValidationClasses();

        resetSelect(validationSelectId);
        $(".sibInfo").css("display", "none");

        //reset aware-of-referral field upon selection
        $("[id$=aware-of-referral]").parent().parent().css("display", "block");
        $("[id$=aware-of-referral]").prop("selectedIndex", 0);

        //reset state error
        const stateParents = $("[id$=p-state],[id$=p-state2]").parents().parents();
        $(stateParents)
            .removeClass("has-error")
            .children(".col-md-3")
            .children("label")
            .css("color", "");
        $(stateParents)
            .children(".col-md-6")
            .children(".chosen-container-single")
            .children(".chosen-single")
            .css("border", "");
        $(stateParents)
            .children(".col-md-6")
            .children(".single")
            .children(".chosen-single")
            .css("border", "");
        $(stateParents)
            .children(".col-md-6")
            .children(".chosen-container-multi")
            .children(".chosen-multi")
            .css("border", "");
        $(stateParents).children(".col-md-6").children(".help-block").remove();

        //reset diagnosis month and year
        const monthYearParents = $("[id$=diagnosisMonth],[id$=diagnosisYear]")
            .parents()
            .parents();
        $(monthYearParents)
            .removeClass("has-error")
            .children(".col-md-3")
            .children("label")
            .css("color", "");
        $(monthYearParents).children(".col-sm-3").css("border", "");
        $(monthYearParents).children(".col-sm-3").children(".help-block").remove();
    }

    //To show corresponding sections and to perform some dependent actions
    $(".radioClickable input").click(function () {
        var labelNameRadio = $(".radioSection input:checked").parent().text();
        var labelsAvailable = $.inArray(labelNameRadio, rerender);

        resetCommonFields();
        if ($(".guardian-2").css("display") == "block") {
        }
        // hidden but still validates based off birthdate selection
        $("[id$=wcage]").parents(".form-group").addClass("sr-only");
        $(".familyAwareError").css("display", "none");
        dateLogic();
        $(
            ".medprovcat-other-wrap, .other, .main-office-contact, .medical-additional-info"
        ).css("display", "none");

        if (labelNameRadio != "") {
            $(".Relchild").val(labelNameRadio);
        }
        if (labelsAvailable > -1) {
            $(".referrerInfo").css("display", "block");
            $(".medicalProvider,.other").css("display", "none");
            if (labelsAvailable == -1 || labelsAvailable == 2) {
                clearFuncSelf();
                clearFuncParent();
            }
        }

        // re-add standard validation
        $(
            "[id$=rphone],[id$=pphonenumber],[id$=pphonenumber2],[id$=mpphone]"
        ).addClass("phonechk-std");
        $(
            "[id$=remail],[id$=mpemail],[id$=pemailaddress],[id$=pemailaddress2]"
        ).addClass("email-std");

        // add validation based on radio selection
        if (labelNameRadio == " Medical Professional") {
            $(".medProvCat").val("");
            $(".medProvCat").find("option:first").remove(); // remove first
            $(".medProvCat").prepend(
                '<option disabled="disabled" selected="selected">Please select an option</option>'
            );

            $(".referrerInfo, .medicalProvider, .main-office-contact").css(
                "display",
                "block"
            );
            $(".other, #medToRepeatBest").css("display", "none");
            $("[id$=aware-of-referral]").addClass("family-aware-chk");
            $("[id$=medprov]").addClass("medprovider");
            $(".medical-additional-info").show();
            $(
                "[id$=rfirstname],[id$=frm\\:pfirstname],[id$=frm\\:pfirstname2],[id$=wcfirstname],[id$=mpfirstname],[id$=mpmaincontactfirstname],[id$=refmpfirstname]"
            ).addClass("firstname");
            $(
                "[id$=rlastname],[id$=frm\\:plastname],[id$=frm\\:plastname2],[id$=wclastname],[id$=mplastname],[id$=mpmaincontactlastname],[id$=refmplastname]"
            ).addClass("lastname");
            if (
                $(
                    "[id$=rphone],[id$=pphonenumber],[id$=pphonenumber2],[id$=mpphone]"
                ).hasClass("phonechk-std")
            ) {
                $(
                    "[id$=rphone],[id$=pphonenumber],[id$=pphonenumber2],[id$=mpphone]"
                ).removeClass("phonechk-std");
                $("[id$=rphone],[id$=pphonenumber],[id$=mpphone]").addClass("phonechk");
            }
            if ($("[id$=remail]").hasClass("email-std")) {
                $("[id$=remail]").removeClass("email-std");
                $("[id$=remail]").addClass("email");
            }
            $("[id$=pcity],[id$=bcity],[id$=trtcity],[id$=refhtfcity],[id$=trthtfcity]").addClass("city");
            $("[id$=ppostalcode]").addClass("postalcode");
            $("[id$=p-state],[id$=refmpstate],[id$=bstate],[id$=mstate],[id$=refhtfstate],[id$=trthtfstate]").addClass("state-chk");
            $("[id$=wcdob]").addClass("wcdob");
            $("[id$=wcgender]").addClass("wcgender");
            $("[id$=wcreceivedwish]").addClass("wcreceivedwish"),
                $("[id$=paddress]").addClass("address");
            $("[id$=plang],[id$=plang2]").addClass("language");
            $("[id$=searchDiagnosisId]").addClass("pdiagnosis");
            $("[id$=urgency]").addClass("urgency");
            $("[id$=mphospitalname]").addClass("facility");
            document.getElementById("refMpForm").style.display = 'none';
            document.getElementById("refHtfForm").style.display = 'none';
            document.getElementById("trtHtfForm").style.display = 'none';
            $(".repeatMedProfBest").css("display", "none");
            $(".mpSearchCreate").css("display", "block");
            $(".refNewAff").css("display", "none");
            $(".treatingHtf").css("display", "block");
            $(".trtNewAff").css("display", "none");
            $(".bestNewAff").css("display", "none");
            $("[id$=refmpcategory],[id$=mcategory],[id$=bcategory]").addClass("medcategory");
            $("[id$=refmpphone], [id$=refmpemail]").addClass("phoneoremailref");
            $("[id$=mphone], [id$=memail]").addClass("phoneoremailtrt");
            $("[id$=mpmaincontactphone], [id$=mpmaincontactemail]").addClass("phoneoremailbest");
            $("[id$=trthtfname], [id$=refhtfname]").addClass("acctname");


            formValidationRules();
            clearFuncSelf();
            clearFuncParent();
        } else if (labelNameRadio == " Other") {
            $(".other input").val("");
            $(".referrerInfo,.other").css("display", "block");
            $(".medicalProvider").css("display", "none");
            // add classes for validation
            $("[id$=aware-of-referral]").addClass("family-aware-chk");
            $("[id$=r2cManualInput]").addClass("r2c-manual-input");
            $(
                "[id$=rfirstname],[id$=wcfirstname],[id$=frm\\:pfirstname],[id$=frm\\:pfirstname2]"
            ).addClass("firstname");
            $(
                "[id$=rlastname],[id$=frm\\:plastname],[id$=frm\\:plastname2],[id$=wclastname]"
            ).addClass("lastname");
            if ($("[id$=rphone]").hasClass("phonechk-std")) {
                $("[id$=rphone]").removeClass("phonechk-std");
                $("[id$=rphone]").addClass("phonechk");
            }
            if ($("[id$=remail]").hasClass("email-std")) {
                $("[id$=remail]").removeClass("email-std");
                $("[id$=remail]").addClass("email");
            }
            $("[id$=rcity]").addClass("city");
            $("[id$=rpostalcode]").addClass("postalcode");
            $("[id$=urgency]").addClass("urgency");
            $("[id$=wcreceivedwish]").addClass("wcreceivedwish"),
                formValidationRules();

            $("[id$=searchDiagnosisId]").addClass("pdiagnosis"); // not for validation
            $("[id$=wcage]").parents(".form-group").removeClass("sr-only");
            $(".repeatMedProf").css("display", "none");
            document.getElementById("refMpForm").style.display = 'none';
            document.getElementById("refHtfForm").style.display = 'none';
            $(".mpSearchCreate").css("display", "none");
            $(".trtNewAff").css("display", "none");
            $(".treatingHtf").css("display", "none");
            $('[id$=createNewRefMPchk],[id$=createNewTrtMPchk],[id$=createNewBestMPchk],[id$=newRefHtfChk],[id$=newTrtHtfChk]').prop('checked', false);

            clearFuncSelf();
            clearFuncParent();
        }
        // add validation for non-medical
        else if (
            labelNameRadio == " Self" ||
            labelNameRadio == " Parent/Guardian" ||
            labelNameRadio == " Family Member/Relative"
        ) {
            $(
                "[id$=rfirstname],[id$=frm\\:pfirstname],[id$=frm\\:pfirstname2],[id$=wcfirstname]"
            ).addClass("firstname");
            $(
                "[id$=rlastname],[id$=frm\\:plastname],[id$=frm\\:plastname2],[id$=wclastname],[id$=mplastname]"
            ).addClass("lastname");
            if (
                $("[id$=rphone],[id$=pphonenumber],[id$=pphonenumber2]").hasClass(
                    "phonechk-std"
                )
            ) {
                $("[id$=rphone],[id$=pphonenumber],[id$=pphonenumber2]").removeClass(
                    "phonechk-std"
                );
                $("[id$=rphone],[id$=pphonenumber]").addClass("phonechk");
            }
            //SIW-372: Made phone as required field under treating medical professional information
            if ($("[id$=mpphone]").hasClass("phonechk-std")) {
                $("[id$=mpphone]").removeClass("phonechk-std");
                $("[id$=mpphone]").addClass("phonechk");
            }
            if ($("[id$=remail]").hasClass("email-std")) {
                $("[id$=remail]").removeClass("email-std");
                $("[id$=remail]").addClass("email");
            }
            $("[id$=pcity]").addClass("city");
            $("[id$=ppostalcode]").addClass("postalcode");
            $("[id$=p-state]").addClass("state-chk");
            $(
                "[id$=nSib],[id$=nSib2],[id$=psibfirstname],[id$=psibfirstname2],[id$=psiblastname],[id$=psiblastname2],[id$=psibage],[id$=psibage2]"
            ).addClass("sibling-chk");
            $("[id$=wcdob]").addClass("wcdob");
            $("[id$=wcgender]").addClass("wcgender");
            $("[id$=wcreceivedwish]").addClass("wcreceivedwish"),
                $("[id$=paddress]").addClass("address");
            $("[id$=plang],[id$=plang2]").addClass("language");
            $("[id$=searchDiagnosisId]").addClass("pdiagnosis");
            $("[id$=mphospitalname]").addClass("facility");
            $("[id$=urgency]").addClass("urgency");
            $(".repeatMedProf").css("display", "none");
            document.getElementById("refMpForm").style.display = 'none';
            document.getElementById("refHtfForm").style.display = 'none';
            $(".mpSearchCreate").css("display", "none");
            $(".trtNewAff").css("display", "none");
            $(".treatingHtf").css("display", "none");
            $('[id$=createNewRefMPchk],[id$=createNewTrtMPchk],[id$=createNewBestMPchk],[id$=newRefHtfChk],[id$=newTrtHtfChk]').prop('checked', false);

            if (
                labelNameRadio == " Self" ||
                labelNameRadio == " Family Member/Relative"
            ) {
                $("[id$=aware-of-referral]").addClass("family-aware-chk");
            }
            if (labelNameRadio == " Self") {
                childClone();
                ageCheck();
                clearFuncParent();
            }
            if (labelNameRadio == " Family Member/Relative") {
                $("[id$=r2cManualInput]").addClass("r2c-manual-input").val("");
                $(".other").css("display", "block");
            }
            if (labelNameRadio == " Parent/Guardian") {
                $(".shownOnYes").removeClass("fam-aware-overlay");
                $("[id$=aware-of-referral]").removeClass("family-aware-chk");
                $("[id$=aware-of-referral]").parent().parent().css("display", "none");
                $('[id$=aware-of-referral] option[value="Yes"]').prop("selected", true);
            }
            formValidationRules();
            parentClone();
            clearFuncSelf();
        }
    });

    function ageCheck() {
        var childAge = $(".childAge").val();
        var selectedRel = $(".radioSection input:checked").parent().text();
        var selectedAge = $.inArray(childAge, childAgesEligible);
        if (selectedAge > "-1" && selectedRel == " Self") {
            $(".alertMsg").text(guardianPermissionMsg);
            $("#age13under-modal").modal("show");
        }
    }

    $(".childAge").on("change", function () {
        var ageVal = $("age-text").text();
        if ($(this).val() == "Under 2.5" || $(this).val() == "18 & Above") {
            $(".alertMsg").text(eligibleMsg);
            $("#warningModal").modal("show");
        }
        if ($("select.childAge").val() != ageVal) {
            $("[id$=wcdob]").val("");
            $(".age-text").fadeOut(300, function () {
                $(this).remove();
            });
            $("[id$=wcdob]").unmask();
            $("[id$=wcdob]").mask("99/99/9999", {
                placeholder: "mm/dd/yyyy",
            });
        }
        ageCheck();
    });

    // date of birth logic for wish child age input
    function dateLogic() {
        $("[id$=wcdob]").on("keyup", function () {
            var wcAge = $("[id$=wcage]"),
                wcDob = $("[id$=wcdob]"),
                // vars required for years calculation
                wcDobInput = $("[id$=wcdob]").val(),
                ageGroup = 0,
                wcDobVal = $(this).val(),
                count = 0,
                letters = ["m", "d", "y"],
                letterFormat =
                    wcDobVal.indexOf("m") &&
                    wcDobVal.indexOf("d") &&
                    wcDobVal.indexOf("y"),
                delay = (function () {
                    var timer = 0;
                    return function (callback, ms) {
                        clearTimeout(timer);
                        timer = setTimeout(callback, ms);
                    };
                })();

            // new calculate age - SIW-221
            function getAge(dateString) {
                var daysInDOBMonth, DOB, todayDate, ageYears, ageMonths, ageDays;
                todayDate = new Date();

                //validate dateString
                var dateArray = dateString.split("/");
                var mm = dateArray[0],
                    dd = dateArray[1],
                    yyyy = dateArray[2];

                if (mm < 1 || mm > 12 || dd < 1 || dd > 31) {
                    ageGroup = 0;
                    return NaN;
                }

                // check if dd greater than days in month
                var daysInMonth = new Date(yyyy, mm, 0).getDate();
                if (dd > daysInMonth) {
                    ageGroup = 0;
                    return NaN;
                }

                // check if DOB greater than today
                DOB = new Date(dateString);
                if (DOB.getTime() > todayDate.getTime()) {
                    ageGroup = 0;
                    return NaN;
                }

                ageYears = todayDate.getFullYear() - DOB.getFullYear();
                ageMonths = todayDate.getMonth() - DOB.getMonth();

                if (ageMonths < 0) {
                    ageYears = ageYears - 1;
                    ageMonths = ageMonths + 12;
                }

                ageDays = todayDate.getDate() - DOB.getDate();
                if (ageDays < 0) {
                    ageMonths = ageMonths - 1;
                    if (ageMonths < 0) {
                        ageYears = ageYears - 1;
                        ageMonths = ageMonths + 12;
                    }
                    daysInDOBMonth = new Date(
                        DOB.getFullYear(),
                        DOB.getMonth() + 1,
                        0
                    ).getDate();
                }

                if (ageYears >= 18) {
                    ageGroup = 5;
                } else if (ageYears >= 13 && ageYears < 18) {
                    ageGroup = 4;
                } else if (ageYears >= 2 && ageYears < 13) {
                    if (ageYears >= 3) {
                        ageGroup = 3;
                    } else if (ageMonths >= 6) {
                        ageGroup = 2; // SIW-246
                    } else {
                        ageGroup = 1;
                    }
                } else if (ageYears == 0 || ageYears == 1) {
                    ageGroup = 1;
                    ageYears = 1;
                }

                return ageYears;
            }

            function ageValidate() {
                var r2cRadioSelected = getRadioVal(
                    document.getElementById("j_id0:frm"),
                    "r2c-radio"
                );

                function ageAlert() {
                    $(".alertMsg").text(eligibleMsg);
                    $("#warningModal").modal("show");
                }

                // remove prev age
                $(".age-text").remove();

                getAge(wcDobInput);

                if (ageGroup == 1) {
                    $(wcAge).prop("selectedIndex", 1);
                    $(
                        '<span class="text-muted age-text">Under 2 1/2 years old</span>'
                    ).insertAfter(wcDob);
                    ageAlert();
                } else if (ageGroup == 2) {
                    $(wcAge).prop("selectedIndex", 2);
                    $(
                        '<span class="text-muted age-text">2 1/2 years old</span>'
                    ).insertAfter(wcDob);
                    if (r2cRadioSelected == "Self") {
                        console.log("between 2.5 - 13 years");
                        console.log("Self is selected");
                        $("#age13under-modal").modal("show");
                        $(".alertMsg").text(guardianPermissionMsg);
                    }
                } else if (ageGroup == 5) {
                    $(wcAge).prop("selectedIndex", 19); //SIW:374 - Modified this index to 19 for selecting option '18 & above' in case age is greater than 18 or equal to 18
                    $('<span class="text-muted age-text">Over 18 years old</span>').insertAfter(wcDob);
                    ageAlert();
                    // between ages 2.5 and 18 years
                } else if (ageGroup == 3 || ageGroup == 4) {
                    $(wcAge).prop("selectedIndex", 0);
                    $(wcAge).append(
                        '<option value="' +
                        getAge(wcDobInput) +
                        '" selected="selected">' +
                        getAge(wcDobInput) +
                        "</option>"
                    ); //add
                    $(
                        '<span class="text-muted age-text">' +
                        getAge(wcDobInput) +
                        " years old</span>"
                    ).insertAfter(wcDob);
                    if (r2cRadioSelected == "Self" && ageGroup == 3) {
                        console.log("Self is selected");
                        console.log("between 2.5 - 13 years");
                        $(".alertMsg").text(guardianPermissionMsg);
                        $("#age13under-modal").modal("show");
                    }
                }
                if (getAge(wcDobInput) < 0 || !getAge(wcDobInput)) {
                    $(".age-text").remove();
                    $(
                        '<span class="text-muted age-text" style="color:red">Oops! Invalid Birthdate</span>'
                    ).insertAfter(wcDob);
                    delay(function () {
                        $("[id$=wcdob]").val("");
                        $(".age-text").fadeOut(300, function () {
                            $(this).remove();
                        });
                        $("[id$=wcdob]").unmask();
                        $("[id$=wcdob]").mask("99/99/9999", {
                            placeholder: "mm/dd/yyyy",
                        });
                        $(wcAge).prop("selectedIndex", 0);
                    }, 1000);
                }
            }

            // filter m/d/y before calculating and printing age
            while (letterFormat !== -1) {
                count++;
                letterFormat = wcDobVal.indexOf(letters, letterFormat + 1);
            }
            // Only run when mm/dd/yyyy format is cleared from input
            if (count === 0) {
                ageValidate();
            }
        }); //dateLogic on keyup end
    }
}

formLogic();

// ICD Code and Diagnosis Functionality
function PrimaryDiagnosis() {
    var PLACEHOLDER;
    var eventObjects;
    var queryTerm;
    var pdi = $("[id$=searchDiagnosisId]"); // primary diagnosis
    var icd = $("[id$=diagnosisTextId]"); // icd code

    icd
        .autocomplete({
            minLength: 2,
            source: function (request, response) {
                queryTerm = request.term;
                WishReferralForm_AC.searchDiagnosis(request.term, function (
                    result,
                    event
                ) {
                    if (event.type == "exception") {
                        alert(event.message);
                    } else {
                        eventObjects = result;
                        response(eventObjects);
                    }
                });
            },
            response: function (event, ui) {
                ui.content.push({
                    label: "Please select a ICD code below",
                    value: "",
                });
            },
            select: function (event, ui) {
                var descName = ui.item.Condition_Description__c;
                pdi.val("");
                pdi.prop("disabled", true);
                icd.addClass("value-selected");
                pdi.addClass("value-selected");
                icd.val(ui.item.Name);
                $("[id$=shortTextId]")
                    .html("Description: " + ui.item.Short_Description__c)
                    .text();
                $(".primary-diagnosis-other").prop("hidden", true);
                $(".primary-diagnosis-other").find("textarea").val("");
                // remove validation error styling and classes
                pdiRemoveValidation();

                if (typeof descName != "undefined") {
                    pdi.val(ui.item.Condition_Description__r.Name);
                    var ss = $(".searchDiagnosisId")
                        .html(ui.item.Condition_Description__r.Name)
                        .text();
                    pdi.val(ss);
                    pdi.prop("disabled", true);
                    pdiRemoveValidation();
                }
                return false;
            },
        })
        .data("ui-autocomplete")._renderItem = function (ul, item) {
        var entry = "<a>" + item.Name;
        entry = entry + "</a>";
        entry = entry.replace(queryTerm, "<b>" + queryTerm + "</b>");
        if (item.value == "") {
            return $(
                '<li class="ui-state-disabled option-disabled">' + item.label + "</li>"
            ).prependTo(ul);
        } else {
            return $("<li></li>")
                .data("ui-autocomplete-item", item)
                .append(entry)
                .appendTo(ul);
        }
    };

    function pdiRemoveValidation() {
        pdi.css("border", "").removeAttr("aria-required aria-describedby");
        pdi.parents().removeClass("has-error");
        pdi
            .parents(".primaryDiagnosis")
            .children(".col-sm-3")
            .children("label")
            .css("color", "");
        pdi.next(".error").remove();
    }

    icd.keydown(function (e) {
        // has class 'value-selected' and if key is not tab.  (Allow tab only) result: reset pdi.
        if (
            ($(this).hasClass("value-selected") || !pdi.hasClass("value-selected")) &&
            e.keyCode != 9
        ) {
            $(this).removeClass("value-selected");
            pdi.removeClass("value-selected");
            pdi.val("");
            pdi.prop("disabled", false);
            $("[id$=shortTextId]").text("");
        }
        if (
            (e.keyCode == 9 && $(this).hasClass("value-selected")) ||
            $(this).val() == ""
        ) {
            // allow all tab
            return true;
        } else if (e.keyCode == 9) {
            // prevent tab
            e.preventDefault();
        }
    });

    pdi.keydown(function (e) {
        // has class 'value-selected' and if key is not tab
        if (
            ($(this).hasClass("value-selected") && e.keyCode != 9) ||
            $(this).val() == ""
        ) {
            $(this).removeClass("value-selected");
            icd.removeClass("value-selected");
            if (icd.hasClass("value-selected") == false) {
                icd.val("");
                icd.prop("disabled", false);
                $("[id$=shortTextId]").text("");
            }
        }
        if (
            (e.keyCode == 9 && $(this).hasClass("value-selected")) ||
            $(this).val() == ""
        ) {
            // allow all keystrokes
            return true;
        } else if (e.keyCode == 9) {
            // prevent tab
            e.preventDefault();
        }
    });

    $("body").change("click", function (event) {
        if (!icd.hasClass("value-selected")) {
            if (event.srcElement && event.srcElement.tagName) {
                if (
                    event.srcElement.tagName != "INPUT" ||
                    event.srcElement.tagName != "SELECT"
                ) {
                    icd.val("");
                    icd.prop("disabled", false);
                }
            }
        } else if (
            !icd.hasClass("value-selected") &&
            pdi.hasClass("value-selected")
        ) {
            return;
        }
    });

    pdi.autocomplete({
            minLength: 2,
            source: function (request, response) {
                queryTerm = request.term;
                WishReferralForm_AC.searchCondition(request.term, function (
                    result,
                    event
                ) {
                    if (event.type == "exception") {
                        alert(event.message);
                    } else {
                        eventObjects = result;
                        response(eventObjects);
                    }
                });
            },
            response: function (event, ui) {
                ui.content.push({
                    label: "Please select a diagnosis below",
                    value: "",
                });
            },
            select: function (event, ui) {
                var descName = ui.item.Code_To_Use__c;
                var otherDiagnosis = /^(Other )(.*)$/i.test(ui.item.Name);
                var notlistedDiagnosis = /^(Not Listed)$/i.test(ui.item.Name);
                var ss1 = $(".searchDiagnosisId").html(ui.item.Name).text();
                icd.val("");
                icd.prop("disabled", false);
                $(icd).focus();
                $(pdi).addClass("value-selected");
                pdi.val(ui.item.Name);
                pdi.val(ss1);
                if (typeof descName != "undefined") {
                    icd.val(ui.item.Code_To_Use__c);
                    icd.prop("disabled", true);
                }
                if (otherDiagnosis || notlistedDiagnosis) {
                    $(".primary-diagnosis-other").prop("hidden", false);
                } else {
                    $(".primary-diagnosis-other").prop("hidden", true);
                    $(".primary-diagnosis-other").find("textarea").val("");
                }
                return false;
            },
            //SIW-330: Limit Primary Diagnosis field to only accept values from drop-down
            change: function (event, ui) {
                if (ui.item == undefined) {
                    $(this).val("");
                }
            },
        })
        .data("ui-autocomplete")._renderItem = function (ul, item) {
        var entry = "<a>" + item.Name;

        entry = entry + "</a>";
        entry = entry.replace(queryTerm, "<b>" + queryTerm + "</b>");
        if (item.value == "") {
            return $(
                '<li class="ui-state-disabled option-disabled">' + item.label + "</li>"
            ).prependTo(ul);
        } else {
            return $("<li></li>")
                .data("ui-autocomplete-item", item)
                .append(entry)
                .appendTo(ul);
        }
    };
}

PrimaryDiagnosis();

$(".submitBtn").click(function () {
    $(".searchDiagnosisId").val($(".pdiagnosis").val());
    $(".diagnosisFilter").val($(".diagnosisText").val());
});

// hide form security from bots (suck it bots)
$(".fs").hide();

// rewrite default messages
jQuery.extend(jQuery.validator.messages, {
    required: "Oops! This field is required",
    email: "Oops! Please enter a valid email address",
    url: "Oops! Please enter a valid URL",
    date: "Oops! Please enter a valid date",
    number: "Oops! Please enter a valid number",
    digits: "Please enter only digits",
});
// custom zip-code validation rule
$.validator.addMethod(
    "zipcode",
    function (value, element) {
        return this.optional(element) || /^\d{5}(?:-\d{4})?$/.test(value);
    },
    "Oops! Please enter a valid US postal code"
);
//SIW : 555 - Added custom email validation rule
$.validator.addMethod(
    "laxEmail",
    function (value, element) {
        return (
            this.optional(element) ||
            /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/.test(
                value
            )
        );
    },
    "Oops! You've entered an invalid email address"
);
// custom not-equalto validation rule
$.validator.addMethod(
    "notEqual",
    function (value, element) {
        return this.optional(element) || $(".memail").val() != $(".bemail").val();
    },
    "Oops! Please enter an email address different from the Treating Medical Professional's email address"
);

// validation rules and methods
$("form[id$=frm]").validate({
    ignore: ":hidden",
    errorElement: "em",
    errorPlacement: function (error, element) {
        // Add the `help-block` class to the error element
        error.addClass("help-block");
        // Add `has-feedback` class to the parent div.form-group in order to add icons to inputs
        element.parents(".col-sm-6,.col-sm-3").addClass("has-feedback");

        if (element.prop("type") === "radio") {
            error.insertBefore(element.parents(".r2c"));
        }
        // uncomment if any selects have chosen enabled
        else if (element.hasClass("c-select") && element.hasClass("multi")) {
            var selectParent = $(element).parents(".col-sm-6").children(".multi");
            error.insertAfter(selectParent);
        } else {
            error.insertAfter(element);
        }
    },
    highlight: function (element, errorClass, validClass) {
        var elementParents = $(element).parents(
            ".col-sm-3, .col-sm-6, .col-xs-8.col-sm-4, .r2c, td, .dateInput"
        );
        // non-div-wrapped label
        $(elementParents)
            .removeClass("has-success")
            .addClass("has-error")
            .prev("label")
            .css("color", "red");
        // table parent label (sibling information label)
        $(elementParents)
            .removeClass("has-success")
            .addClass("has-error")
            .parents(".sibInfo")
            .children("span")
            .children("span")
            .children("label")
            .css("color", "red");
        // div wrapped label
        $(elementParents)
            .removeClass("has-success")
            .addClass("has-error")
            .prev("div")
            .children("label")
            .css("color", "red");
        // diagnosisYear label
        $(elementParents)
            .removeClass("has-success")
            .addClass("has-error")
            .prev("div")
            .prev("label")
            .css("color", "red");

        $(elementParents)
            .children(".chosen-container-single")
            .children(".chosen-single")
            .css("border", "1px solid red");
        $(elementParents).children("select.single").css("border", "1px solid red");
        $(elementParents)
            .children(".chosen-container-multi")
            .children(".chosen-multiple")
            .css("border", "1px solid red");
        $(elementParents)
            .children("input, select, textarea")
            .css("border", "1px solid red");
        $(elementParents).children("label").css("border", "1px solid red");
    },
    unhighlight: function (element, errorClass, validClass) {
        var elementParents = $(element).parents(
            ".col-sm-3, .col-sm-6, .col-xs-8.col-sm-4, .col-sm-1, .r2c, td, .dateInput"
        );
        // non-div-wrapped label
        $(elementParents).removeClass("has-error").prev("label").css("color", "");
        // table parent label (siblining information label)
        $(elementParents)
            .removeClass("has-error")
            .parents(".sibInfo")
            .children("span")
            .children("span")
            .children("label")
            .css("color", "");
        // div wrapped label
        $(elementParents)
            .removeClass("has-error")
            .prev("div")
            .children("label")
            .css("color", "");
        // diagnosisYear label
        $(elementParents)
            .removeClass("has-success")
            .addClass("has-error")
            .prev("div")
            .prev("label")
            .css("color", "");

        $(elementParents)
            .children(".chosen-container-single")
            .children(".chosen-single")
            .css("border", "");
        $(elementParents).children("select.single").css("border", "");
        $(elementParents)
            .children(".chosen-container-multiple")
            .children(".chosen-multiple")
            .css("border", "");
        $(elementParents).children("input, select, textarea").css("border", "");
        $(elementParents).children(".help-block").remove();
    },
    submitHandler: function () {
        // honeypot check
        if (
            $("#b98084695645e0e89ec5a2f3c41f0a2d").is(":checked") == true ||
            $("#2-b98084695645e0e89ec5a2f3c41f0a2d").val() !== "udh&6**33#"
        ) {
            onsubmit: false;
        } else {
            if ($("form[id$=frm]").valid()) {
                $(".submitBtn")
                    .css({
                        cursor: "not-allowed",
                        opacity: ".5",
                    })
                    .addClass("disabled")
                    .prop("disabled", true);
                form.submit();
                return; // prevent normal form posting
            }
        }
    },
});

function formValidationRules() {
    // add validation rules for common fields
    $("select.r2c-select").each(function () {
        $(this).rules("add", {
            required: true,
            messages: {
                required: "Oops! Please select the relationship to the child",
            },
        });
    });
    $("input.firstname").each(function () {
        $(this).rules("add", {
            required: true,
            minlength: 2,
            maxlength: 40,
            messages: {
                required: "Oops! Please enter a first name",
                minlength: "Oops! Your first name must have more than 2 letters",
                maxlength: "We're sorry, you've reached the maximum allowed characters",
            },
        });
    });
    $("input.lastname").each(function () {
        $(this).rules("add", {
            required: true,
            minlength: 2,
            maxlength: 40,
            messages: {
                required: "Oops! Please enter a last name",
                minlength: "Oops! Your first name must have more than 2 letters",
                maxlength: "We're sorry, you've reached the maximum allowed characters",
            },
        });
    });
    $("input.phonechk-std").each(function () {
        $(this).rules("add", {
            required: false,
            //phoneUS: true,
            minlength: 10,
            maxlength: 14,
            messages: {
                //phoneUS: "Oops! Must be a valid US number",
                number: "Only numbers are accepted",
                minlength: "Oops! Please enter at least 10 digits",
                maxlength: "We're sorry, you've reached the maximum allowed characters",
            },
        });
    });
    $("input.phonechk").each(function () {
        $(this).rules("add", {
            required: true,
            //phoneUS: true,
            minlength: 10,
            maxlength: 14,
            messages: {
                required: "Oops! Please enter a phone number",
                //phoneUS: "Oops! Must be a valid US number",
                number: "Only numbers are accepted",
                minlength: "Oops! Please enter at least 10 digits",
                maxlength: "We're sorry, you've reached the maximum allowed characters",
            },
        });
    });
    $("input.email-std").each(function () {
        $(this).rules("add", {
            required: false,
            email: true,
            laxEmail: true,
            messages: {
                email: "Oops! You've entered an invalid email address",
            },
        });
    });
    $("input.email").each(function () {
        $(this).rules("add", {
            required: true,
            email: true,
            laxEmail: true,
            messages: {
                required: "Oops! Please enter a valid email address",
                email: "Oops! You've entered an invalid email address",
            },
        });
    });
    $("input.address").each(function () {
        $(this).rules("add", {
            required: true,
            minlength: 5,
            maxlength: 40,
            messages: {
                required: "Oops! Please enter an address",
                minlength: "Oops! Please enter a minimum of 5 characters",
                maxlength: "We're sorry, you've reached the maximum allowed characters",
            },
        });
    });
    $("select.state-chk").each(function () {
        $(this).rules("add", {
            required: true,
            messages: {
                required: "Oops! Please select a state",
            },
        });
    });
    $("input.city").each(function () {
        $(this).rules("add", {
            required: true,
            minlength: 3,
            maxlength: 22,
            messages: {
                required: "Oops! Please enter a US city",
                minlength: "Oops! Please enter at least 3 characters",
                maxlength: "We're sorry, you've reached the maximum allowed characters",
            },
        });
    });
    $("input.postalcode-std").each(function () {
        $(this).rules("add", {
            required: false,
            digits: true,
            minlength: 5,
            maxlength: 9,
            messages: {
                required: "Oops! Please enter a valid US postal code",
                digits: "Oops! Please only enter digits",
                minlength: "Oops! Please enter a minimum of 5 digits",
                maxlength: "We're sorry, you've reached the maximum allowed characters",
            },
        });
    });
    $("input.postalcode").each(function () {
        $(this).rules("add", {
            required: true,
            //digits: true,
            zipcode: true,
            minlength: 5,
            maxlength: 10,
            messages: {
                required: "Oops! Please enter a valid US postal code",
                //digits: "Oops! Please only enter digits",
                minlength: "Oops! Please enter a minimum of 5 digits",
                maxlength: "We're sorry, you've reached the maximum allowed characters",
            },
        });
    });
    $("input.sibage").each(function () {
        $(this).rules("add", {
            required: true,
            digits: true,
            minlength: 1,
            maxlength: 2,
            messages: {
                required: "Oops! Please enter this sibling's age",
                digits: "Oops! Please only enter digits",
                minlength: "Oops! Please enter a minimum of 2 digits",
                maxlength: "We're sorry, you've reached the maximum allowed characters",
            },
        });
    });

    // add rules for all other fields
    $("input.r2c-radio").rules("add", {
        required: true,
        messages: {
            required: "Oops! Please select an option",
        },
    });
    $("select.family-aware-chk").rules("add", {
        required: true,
        messages: {
            required: "Oops! Please select an option",
        },
    });
    $("select.medprovider").rules("add", {
        required: true,
        messages: {
            required: "Oops! Please select an option",
        },
    });
    $("input.medprovcat-other").rules("add", {
        required: true,
        messages: {
            required: "Oops! Please enter the other medical provider category",
        },
    });
    $("input.r2c-manual-input").rules("add", {
        required: true,
        minlength: 3,
        maxlength: 20,
        messages: {
            required: "Oops! Please enter your relationship to the Wish Child",
            minlength: "Oops! Please enter a minimum of 3 characters",
            maxlength: "We're sorry, you've reached the maximum allowed characters",
        },
    });
    $("select.wcage").rules("add", {
        required: true,
        messages: {
            required: "Oops! Please select the wish child's age",
        },
    });
    $("select.wcgender").rules("add", {
        required: true,
        messages: {
            required: "Oops! The child's gender is required",
        },
    });
    // $("input.date-std").rules("add", {
    //     required: false,
    //     date: true,
    //     messages: {
    //         date: "Oops! Please enter a valid date in the correct format"
    //     }
    // });
    $("input.wcdob").rules("add", {
        required: true,
        date: true,
        messages: {
            required: "Oops! The child's date of birth is required",
            date: "Oops! Please enter a valid date in the correct format",
        },
    });
    $("select.wcreceivedwish").rules("add", {
        required: true,
        messages: {
            required: "Oops! This question is required",
        },
    });
    $("select.siblings-chk").rules("add", {
        required: true,
        messages: {
            required: "Oops! Please select the number of siblings",
        },
    });
    $("input.icd").rules("add", {
        required: true,
        minlength: 3,
        messages: {
            required: "Oops! Please enter an ICD code",
            minlength: "Oops! Please enter a minimum of 3 characters",
        },
    });
    $("input.pdiagnosis").rules("add", {
        required: true,
        minlength: 3,
        messages: {
            required: "Oops! Please enter a primary diagnosis",
            minlength: "Oops! Please enter a minimum of 3 characters",
        },
    });
    $("input.facility").rules("add", {
        required: true,
        minlength: 3,
        messages: {
            required:
                "Oops! Please enter the name of the hospital or treatment facility",
            minlength: "Oops! Please enter a minimum of 3 characters",
        },
    });
    $("select.urgency").rules("add", {
        required: true,
        messages: {
            required: "Oops! Please select an option",
        },
    });
    $("input.notqualto").rules("add", {
        notEqual: true,
    });
    $("select.d-month").rules("add", {
        required: true,
        messages: {
            required: "Oops! Please select a month",
        },
    });
    $("select.d-year").rules("add", {
        required: true,
        messages: {
            required: "Oops! Please select a year",
        },
    });
    $("textarea.selfdescreq").rules("add", {
        required: true,
        messages: {
            required:
                "Oops! Please enter a description pertaining to 'Self-describe'",
        },
    });
    $(".primary-diagnosis-other textarea").rules("add", {
        required: function () {
            return (
                $("[id$=searchDiagnosisId]").val() == "Not Listed" ||
                $("[id$=searchDiagnosisId]").val().toLowerCase().indexOf("other") >= 0
            );
        },
        messages: {
            required: "Oops! Please enter a primary diagnosis description",
        },
    });
    $("select.medcategory").each(function () {
        $(this).rules("add", {
            required: true,
            messages: {
                required: "Oops! Please select a category",
            },
        });
    });
    $("input.phoneoremailref").rules("add", {
        require_from_group: [1, ".refContact"],
        messages: {
            require_from_group: "Oops! Please enter a phone number or email",
        },
    });
    $("input.phoneoremailtrt").rules("add", {
        require_from_group: [1, ".trtContact"],
        messages: {
            require_from_group: "Oops! Please enter a phone number or email",
        },
    });
    $("input.phoneoremailbest").rules("add", {
        require_from_group: [1, ".bestContact"],
        messages: {
            require_from_group: "Oops! Please enter a phone number or email",
        },
    });
    $("input.acctname").each(function () {
        $(this).rules("add", {
            required: true,
            minlength: 2,
            maxlength: 50,
            messages: {
                required: "Oops! Please enter a name",
                minlength: "Oops! The name must have more than 2 letters",
                maxlength: "We're sorry, you've reached the maximum allowed characters",
            },
        });
    });
}

// always require this field
$(".r2c").children("label").children("input").addClass("r2c-radio");
$("[id$=p-r2c-1]").addClass("r2c-select");
formValidationRules();