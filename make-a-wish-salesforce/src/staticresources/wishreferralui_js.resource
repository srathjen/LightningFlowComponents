//                04/17/2020 - Manoj - SIW-575
//                Removed Primary language validation from here as applied in VF Page itself
//                27/04/2020 - Manoj - SIW-556 : Updated text even when users select No in question "HAS THE REFERRAL BEEN DISCUSSED WITH THE CHILD'S HEALTHCARE PROVIDER?"
$("[id$=wcdob]").removeAttr('onfocus').mask("99/99/9999", {
    placeholder: "mm/dd/yyyy"
});
$("[id$=email],[id$=pemailaddress],[id$=pemailaddress2],[id$=mpemail]").attr('type', 'email');
$('.main-office-contact').css('display', 'none');
$('.r2c fieldset table tr td').children().unwrap().unwrap().unwrap().unwrap().unwrap();
$('.r2c input:first').clone().prependTo('.r2c label:first');
$('.r2c input:nth-child(3)').clone().prependTo('.r2c label:nth-child(4)');
$('.r2c input:nth-child(5)').clone().prependTo('.r2c label:nth-child(6)');
$('.r2c input:nth-child(7)').clone().prependTo('.r2c label:nth-child(8)');
$('.r2c input:nth-child(9)').clone().prependTo('.r2c label:nth-child(10)');
$('.r2c > input').remove();
$('.r2c label').addClass('col-xs-12 col-sm-6');
$('.r2c label input').attr('name', 'r2c-radio');
$('.r2c-radio').click(function() {
    $('.familyAware').parent().parent().show()
});
formLogic();

function getRadioVal(form, name) {
    var val;
    var radios = form.elements[name];
    for (var i = 0, len = radios.length; i < len; i++) {
        if (radios[i].checked) {
            val = radios[i].value;
            break
        }
    }
    return val
}
$('select').not('.state,.multi').each(function() {
    $(this).find('option:first').remove();
    if ($(this).attr('id') == "j_id0:frm:diagnosisYear") {
        $('#j_id0\\:frm\\:diagnosisYear').prepend('<option value="">Year</option>')
    } else if ($(this).attr('id') == "j_id0:frm:diagnosisMonth") {
        $('#j_id0\\:frm\\:diagnosisMonth').prepend('<option value="">Month</option>')
    } else {
        $(this).prepend('<option selected disabled>Please select an option</option>')
    }
});
$('[id$=diagnosisMonth]').on('change', function() {
    var diagnosisYear = $('[id$=diagnosisYear]');
    if ($(this).val() != '') {
        diagnosisYear.addClass('d-year');
        formValidationRules()
    } else {
        resetSelect(diagnosisYear);
        diagnosisYear.rules('remove');
        diagnosisYear.removeAttr('aria-required aria-describedby aria-invalid').removeClass('d-year').valid()
    }
});
$('[id$=diagnosisYear]').on('change', function() {
    var diagnosisMonth = $('[id$=diagnosisMonth]');
    if ($(this).val() != '') {
        diagnosisMonth.addClass('d-month');
        formValidationRules()
    } else {
        diagnosisMonth.rules('remove');
        diagnosisMonth.removeAttr('aria-required aria-describedby aria-invalid').removeClass('d-month').valid()
    }
});
$(".numbers-only").keydown(function(e) {
    if ($.inArray(e.keyCode, [46, 8, 9, 27, 13, 110]) !== -1 || (e.keyCode == 65 && e.ctrlKey === !0) || (e.keyCode == 67 && e.ctrlKey === !0) || (e.keyCode == 88 && e.ctrlKey === !0) || (e.keyCode >= 35 && e.keyCode <= 39)) {
        return
    } else if ((e.shiftKey || (e.keyCode < 48 || e.keyCode > 57)) && (e.keyCode < 96 || e.keyCode > 105 || (e.keyCode == 191))) {
        e.preventDefault()
    }
});
$(".alpha-only").keydown(function(e) {
    if ($.inArray(e.keyCode, [46, 8, 9, 27, 13, 110, 190, 32]) !== -1 || (e.keyCode === 65 && (e.ctrlKey === !0 || e.metaKey === !0)) || (e.keyCode == 67 && (e.ctrlKey === !0 || e.metaKey === !0)) || (e.keyCode == 88 && (e.ctrlKey === !0 || e.metaKey === !0)) || (e.keyCode >= 35 && e.keyCode <= 39) || e.shiftKey) {
        return
    }
    if (e.keyCode < 65 || e.keyCode > 90) {
        e.preventDefault()
    }
});

function isTextSelected(input) {
    if (typeof input.selectionStart == "number") {
        return input.selectionStart == 0 && input.selectionEnd == input.value.length
    } else if (typeof document.selection != "undefined") {
        input.focus();
        return document.selection.createRange().text == input.value
    }
}
$(".phonemask").keydown(function(e) {
    if (isTextSelected(this)) {
        $(this).val('')
    }
    if (($(this).val().length == 0) && (e.keyCode != 8)) {
        $(this).val($(this).val() + "(")
    } else if (($(this).val().length == 4) && (e.keyCode != 8)) {
        $(this).val($(this).val() + ") ")
    } else if (($(this).val().length == 9) && (e.keyCode != 8)) {
        $(this).val($(this).val() + "-")
    }
    if ((($(this).val().length == 2 || $(this).val().length == 11) && e.keyCode == 8) || (($(this).val().length == 2) && e.keyCode == 9)) {
        $(this).val($(this).val().substring(0, $(this).val().length - 1))
    }
    if (($(this).val().length == 7) && (e.keyCode == 8)) {
        $(this).val($(this).val().substring(0, $(this).val().length - 2))
    }
    if (($(this).val().length) != 14 && (e.keyCode == 9)) {
        $(this).val('')
    }
});
$(".phonemask").attr('maxlength', '14');
$('.guardian-2').css('display', 'block');
$('.add-guardian').parents('.connected').prop('hidden', !0);
$('.add-guardian').on('click', function(e) {
    e.preventDefault();
    $('input[id$=frm\\:pfirstname2],input[id$=frm\\:plastname2],input[id$=pphonenumber2],input[id$=pemailaddress2],input[id$=pcity2],input[id$=ppostalcode2],select[id$=p-state2],input[id$=paddress2],select[id$=plang2],input[id$=psibfirstname2],input[id$=psiblastname2],input[id$=psibage2]').val('');
    $('[id$=p-state2]').prop('selectedIndex', 0);
    $(this).parents('.connected').prop('hidden', !0);
    $('.guardian-2').css('display', 'block');
    if ($('[id$=p-state2] option:nth-child(2)').text() == 'Select an option') {
        $('[id$=p-state2] option:nth-child(2)').remove()
    }
    $('select[id$=p-r2c-2]').prop('selectedIndex', 0);
    formValidationRules()
});
$('.remove-block').on('click', function(e) {
    e.preventDefault();
    $('.add-guardian').parents('.connected').prop('hidden', !1);
    $('.guardian-2').css('display', 'none');
    $('input[id$=frm\\:pfirstname2],input[id$=frm\\:plastname2],input[id$=pphonenumber2],input[id$=pemailaddress2],input[id$=pcity2],input[id$=ppostalcode2],select[id$=p-state2],select[id$=p-r2c-2],input[id$=paddress2],select[id$=plang2],input[id$=psibfirstname2],input[id$=psiblastname2],input[id$=psibage2]').val('');
    $('[id$=p-state2]').prop('selectedIndex', 0)
});

function stateFunc() {
    $('select.state option:first').remove();
    $('.state').prepend('<option disabled="disabled" selected="selected">Please select a State</option>')
}
stateFunc();
$('select.multi').chosen({
    disable_search: !0,
    placeholder_text_multiple: "Please select all that apply",
    width: "100%"
});
$('select.multi').find('option:first').prop('disabled', !0).trigger("chosen:updated");
(function() {
    var chosen = $("select.multi").chosen().data("chosen");
    var autoClose = !1;
    if (chosen && chosen.hasOwnProperty('result_select')) {
        var chosen_resultSelect_fn = chosen.result_select;
        chosen.result_select = function(evt) {
            var resultHighlight = null;
            if (autoClose == !1) {
                evt.metaKey = !0;
                evt.ctrlKey = !0;
                resultHighlight = chosen.result_highlight
            }
            var result = chosen_resultSelect_fn.call(chosen, evt);
            if (autoClose == !1 && resultHighlight != null)
                resultHighlight.addClass("result-selected");
            return result
        }
    }
})();

function resetSelect() {
    var options = document.querySelectorAll('select option');
    for (var i = 0, l = options.length; i < l; i++) {
        options[i].selected = options[i].defaultSelected
    }
}

function formLogic() {
    var link = '<a href="https://wish.org/local-chapters#sm.000001nnnt2f0tf0tux692bqfeli5" target="_blank">Click here for a local chapter directory</a>',
        familyAwareError = 'Please make sure the family is aware of this referral before you proceed. If you have additional questions please reach out to your local chapter. ',
        referralDiscussedError = 'We recommend that you discuss potential eligibility with the child\'s treating healthcare provider before you proceed. If you have additional questions please reach out to your local chapter. ',
        labels = [' Self', ' Medical Professional', ' Parent/Guardian', ' Family Member/Relative', ' Other'],
        rerender = [' Self', ' Parent/Guardian', ' Family Member/Relative'],
        medicalProviders = ["Nurse Practitioner", "Physician Assistant", "Physician"],
        childAgesEligible = ['2.5', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13'],
        fieldClasses = ['firstname', 'lastname', 'phonechk', 'email', 'city', 'state-chk', 'address', 'postalcode', 'family-aware-chk', 'medprovider', 'r2c-manual-input', 'wcgender', 'wcage', 'wcdob', 'wcreceivedwish', 'language', 'siblings-chk', 'icd', 'pdiagnosis', 'facility', 'urgency', 'sibage'],
        eligibleMsg = 'To be eligible, children must be older than 2Â½ years old and younger than 18 years old.',
        guardianPermissionMsg = "Please confirm that you have received your parent or guardians permission to complete this form.";
        refDisAddError = "If you would like to proceed, please fill out the form below.";//Added for SIW-556
    $('.familyAware').on('change', function() {
        if ($(this).val() == 'No') {
            var labelName = $('.radioSection input:checked').parent().text();
            var labelsAvailable = $.inArray(labelName, labels);
            $('.familyAwareError').css('display', 'block');
            $('.medprovcat-other-wrap').css('display', 'none');
            $('.medprovcat-other').val('');
            if (labelsAvailable > -1) {
                $(this).next('.familyAwareError').text(familyAwareError).append($(link));
                //$('.shownOnYes').addClass('fam-aware-overlay');
                if (labelName == " Medical Professional") {
                    $('.medicalProvider').css('display', 'none')
                }
                if (labelName == " Other") {
                    $('.r2c-manual-input').parent().parent().css('display', 'none');
                    $(this).next('.familyAwareError').text(familyAwareError).append($(link))
                }
            } else {
                $('.familyAwareError, .medprovcat-other-wrap').css('display', 'none');
                $('.medprovcat-other').val('')
            }
        } else if ($(this).val() == 'Yes') {
            var labelName = $('.radioSection input:checked').parent().text();
            $(this).next('span').text('');
            if (labelName == " Medical Professional") {
                $('.medicalProvider').css('display', 'block')
            }
            if (labelName == " Other") {
                $('.r2c-manual-input').parent().parent().removeClass('displayNone').css('display', 'block')
            }
        } else {
           // $('.shownOnYes').addClass('fam-aware-overlay');
            $('.familyAwareError').css('display', 'none')
        }
    });
    $('.discussedProvider').on('change', function() {
        if ($(this).val() == 'No') {
            var labelName = $('.radioSection input:checked').parent().text();
            var labelsAvailable = $.inArray(labelName, labels);
            $('.discussedProviderError').css('display', 'block');
            $('.medprovcat-other-wrap').css('display', 'none');
            $('.medprovcat-other').val('');
            if (labelsAvailable > -1) {
                //SIW-556 Start : Added if-else condition to update text
                if (labelName == " Other" || labelName == " Medical Professional") {
                $(this).next('.discussedProviderError').text(referralDiscussedError).append($(link));
                }
                else{
                    $(this).next('.discussedProviderError').text(referralDiscussedError).append($(link)).append('. '+refDisAddError);  
                }
                //SIW-556 End
                //$('.shownOnYes').addClass('fam-aware-overlay');
                if (labelName == " Medical Professional") {
                    $('.medicalProvider').css('display', 'none')
                }
                if (labelName == " Other") {
                    $('.r2c-manual-input').parent().parent().css('display', 'none');
                    //$(this).next('.discussedProviderError').text(referralDiscussedError).append($(link))
                }
            } else {
                $('.discussedProviderError, .medprovcat-other-wrap').css('display', 'none');
                $('.medprovcat-other').val('')
            }
        } else if ($(this).val() == 'Yes') {
            var labelName = $('.radioSection input:checked').parent().text();
            $(this).next('span').text('');
            if (labelName == " Medical Professional") {
                $('.medicalProvider').css('display', 'block')
            }
            if (labelName == " Other") {
                $('.r2c-manual-input').parent().parent().removeClass('displayNone').css('display', 'block')
            }
        } else {
            //$('.shownOnYes').addClass('fam-aware-overlay');
            $('.discussedProviderError').css('display', 'none')
        }
    });
    $('#j_id0\\:frm\\:wcgender').on('change', function() {
        if ($(this).val() != null) {
            if ($(this).val().indexOf('Self-describe') != -1) {
                $('.self-desc').prop('hidden', !1);
                $('.self-desc-field').addClass('selfdescreq')
            } else {
                $('.self-desc').prop('hidden', !0);
                $('.self-desc-field').removeClass('selfdescreq').val('')
            }
            formValidationRules()
        }
    });
    $('.medprovcat-other-wrap').css('display', 'none');
    $('[id$=medprov]').on('change', function() {
        if ($(this).val() != null) {
            if ($(this).val().indexOf('Other') != -1) {
                $('.medprovcat-other-wrap').css('display', 'block')
            } else {
                $('.medprovcat-other-wrap').css('display', 'none');
                $('.medprovcat-other').val('')
            }
        }
    });
    $('.medProvCat').on('change', function() {
        var medValSelected = $('.medProvCat').val();
        var medVal = $.inArray(medValSelected, medicalProviders);
        if (medVal > -1) {
            $('.repeatMedProf').css('display', 'block')
        } else {
            $('.repeatMedProf').css('display', 'none')
        }
    });
    $('.repeatMedProf').on('change', function() {
        checkVisible = $('.repeatMedProf input').is(':checked');
        if (checkVisible == !0) {
            $('.mfirstname').val($('.rfirstname').val());
            $('.mlastname').val($('.rlastname').val());
            $('.mphone').val($('.rphone').val());
            $('.memail').val($('.remail').val())
        } else if (checkVisible == !1) {
            $('.medToRepeat :input').each(function() {
                $(this).val('')
            })
        }
    });

    function childClone() {
        var radioSelfSel = $('.radioSection input:checked').parent().text();
        if ((radioSelfSel == " Self")) {
            $('.wcfirstname').val($('.rfirstname').val());
            $('.wclastname').val($('.rlastname').val())
        }
    }
    $('.refToRepeat :input').on('keyup', childClone);

    function parentClone() {
        var radioSelfSel = $('.radioSection input:checked').parent().text();
        if ((radioSelfSel == " Parent/Guardian")) {
            $('.pfirstname1').val($('.rfirstname').val());
            $('.plastname1').val($('.rlastname').val());
            $('.pphone1').val($('.rphone').val());
            $('.pemailaddress1').val($('.remail').val());
            $('.pcity1').val($('.rcity').val());
            $('.ppostalcode1').val($('.rpostalcode').val())
        }
    }
    $('.clone-guardian-1 input').click(function() {
        if ($(this).is(':checked')) {
            $('[id$=paddress2]').val($('[id$=paddress]').val());
            $('[id$=pcity2]').val($('[id$=pcity]').val());
            $('[id$=p-state2]').val($('[id$=p-state]').val());
            $('[id$=ppostalcode2]').val($('[id$=ppostalcode]').val())
        } else {
            $('[id$=paddress2], [id$=pcity2], [id$=ppostalcode2]').val('');
            $('[id$=p-state2]').prop('selectedIndex', 0)
        }
    });
    $('.refToParent :input').on('keyup', parentClone);
    $('[id$=nSib],[id$=nSib2]').on('change', function() {
        var r2cRadioSelected = getRadioVal(document.getElementById('j_id0:frm'), 'r2c-radio');

        function setIntervalX(callback, delay, repetitions) {
            var x = 0;
            var intervalID = window.setInterval(function() {
                callback();
                if (++x === repetitions) {
                    window.clearInterval(intervalID)
                }
            }, delay)
        }
        if ($(this).val() != "" || $(this).val() != "0" || $(this).val() != "Unknown") {
            $('.sibInfo').css('display', 'block');
            if (r2cRadioSelected == "Self" || r2cRadioSelected == "Parent/Guardian") {
                console.log('self or parent/guardian selected');
                setIntervalX(function() {
                    $('[id$=psibfirstname],[id$=psibfirstname2]').addClass('firstname');
                    $('[id$=psiblastname],[id$=psiblastname2]').addClass('lastname');
                    $('[id$=psibage],[id$=psibage2]').addClass('sibage');
                    formValidationRules()
                }, 100, 3)
            }
        } else {
            $('.sibInfo').css('display', 'none');
            setIntervalX(function() {
                $('[id$=psibfirstname],[id$=psibfirstname2]').removeClass('firstname');
                $('[id$=psiblastname],[id$=psiblastname]').removeClass('lastname');
                $('[id$=psibage],[id$=psibage]').removeClass('sibage');
                $('input[id$=psibfirstname],input[id$=psibfirstname2],input[id$=psiblastname],input[id$=psiblastname2],input[id$=psibage],input[id$=psibage2]').each(function() {
                    $(this).rules('remove')
                })
            }, 100, 3)
        }
    });

    function clearFuncSelf() {
        $('.wcfirstname').val($('.rfirstname').val());
        $('.wclastname').val($('.rlastname').val());
        if ($('.wcfirstname').val() == $('.rfirstname').val()) {
            $('.wcfirstname').val('')
        }
        if ($('.wclastname').val() == $('.rlastname').val()) {
            $('.wclastname').val('')
        }
    }

    function clearFuncParent() {
        $('.pfirstname').val($('.rfirstname').val());
        $('.plastname').val($('.rlastname').val());
        $('.pphone').val($('.rphone').val());
        $('.pemailaddress').val($('.remail').val());
        $('.pcity').val($('.rcity').val());
        $('.ppostalcode').val($('.rpostalcode').val());
        if ($('.pfirstname').val() == $('.rfirstname').val()) {
            $('.pfirstname').val('')
        }
        if ($('.plastname').val() == $('.rlastname').val()) {
            $('.plastname').val('')
        }
        if ($('.pphone').val() == $('.rphone').val()) {
            $('.pphone').val('')
        }
        if ($('.pemailaddress').val() == $('.remail').val()) {
            $('.pemailaddress').val('')
        }
        if ($('.pcity').val() == $('.rcity').val()) {
            $('.pcity').val('')
        }
        if ($('.ppostalcode').val() == $('.rpostalcode').val()) {
            $('.ppostalcode').val('')
        }
    }

    function resetCommonFields() {
        var validationSelectId = ['[id$=aware-of-referral],[id$=wcage],[id$=wcreceivedwish],[id$=plang],[id$=plang2],[id$=nSib],[id$=nSib2],[id$=urgency],[id$=p-r2c-1],[id$=p-r2c-2],[id$=p-state],[id$=p-state2],[id$=diagnosisMonth],[id$=diagnosisYear]'];
        $('form[id$=frm]').validate().resetForm();

        function resetFormValidationClasses() {
            $('input,select').removeClass('r2c-select firstname lastname phonechk email city state-chk address postalcode family-aware-chk medprovider r2c-manual-input wcgender wcage wcdob wcreceivedwish language siblings-chk icd pdiagnosis facility urgency sibage required d-month d-year').removeAttr('aria-required aria-describedby');
            $('select[id$=aware-of-referral],select[id$=medprov],select[id$=p-r2c-2],input[id$=rfirstname],input[id$=frm\\:pfirstname],input[id$=frm\\:pfirstname2],input[id$=wcfirstname]input,[id$=mpfirstname],input[id$=rlastname],input[id$=frm\\:plastname],input[id$=frm\\:plastname2],input[id$=wclastname],input[id$=mplastname],input[id$=rphone],input[id$=pphonenumber],input[id$=pphonenumber2],input[id$=mpphone],input[id$=remail],input[id$=pemailaddress],input[id$=pemailaddress2],input[id$=pcity],input[id$=pcity2],input[id$=ppostalcode],input[id$=ppostalcode2],select[id$=p-state],select[id$=p-state2],input[id$=wcdob],select[id$=wcgender],input[id$=paddress],input[id$=paddress2],select[id$=plang],select[id$=plang2],input[id$=searchDiagnosisId],input[id$=mphospitalname],input[id$=psibfirstname],input[id$=psibfirstname2],input[id$=psiblastname],input[id$=psiblastname2],input[id$=psibage],input[id$=psibage2],select[id$=frm\\:diagnosisMonth],select[id$=frm\\:diagnosisYear],select[id$=urgency]').each(function() {
                $(this).rules('remove')
            })
        }
        resetFormValidationClasses();
        resetSelect(validationSelectId);
        $('.sibInfo').css('display', 'none');
        $('[id$=aware-of-referral]').parent().parent().css('display', 'block');
        $('[id$=aware-of-referral]').prop('selectedIndex', 0);
        const stateParents = $('[id$=p-state],[id$=p-state2]').parents().parents();
        $(stateParents).removeClass("has-error").children('.col-md-3').children('label').css('color', '');
        $(stateParents).children('.col-md-6').children(".chosen-container-single").children(".chosen-single").css('border', '');
        $(stateParents).children('.col-md-6').children(".single").children(".chosen-single").css('border', '');
        $(stateParents).children('.col-md-6').children(".chosen-container-multi").children(".chosen-multi").css('border', '');
        $(stateParents).children('.col-md-6').children(".help-block").remove();
        const monthYearParents = $('[id$=diagnosisMonth],[id$=diagnosisYear]').parents().parents();
        $(monthYearParents).removeClass("has-error").children('.col-md-3').children('label').css('color', '');
        $(monthYearParents).children('.col-sm-3').css('border', '');
        $(monthYearParents).children('.col-sm-3').children(".help-block").remove()
    }
    $('.radioClickable input').click(function() {
        var labelNameRadio = $('.radioSection input:checked').parent().text();
        var labelsAvailable = $.inArray(labelNameRadio, rerender);
        resetCommonFields();
        if ($('.guardian-2').css('display') == 'block') {}
        $('[id$=wcage]').parents('.form-group').addClass('sr-only');
        //$('.shownOnYes').addClass('fam-aware-overlay');
        $('.familyAwareError').css('display', 'none');
        dateLogic();
        $('.medprovcat-other-wrap, .other, .main-office-contact, .medical-additional-info').css('display', 'none');
        if (labelNameRadio != '') {
            $('.Relchild').val(labelNameRadio)
        }
        if (labelsAvailable > -1) {
            $('.referrerInfo').css('display', 'block');
            $('.medicalProvider,.other').css('display', 'none');
            if (labelsAvailable == -1 || labelsAvailable == 2) {
                clearFuncSelf();
                clearFuncParent()
            }
        }
        $('[id$=rphone],[id$=pphonenumber],[id$=pphonenumber2],[id$=mpphone]').addClass('phonechk-std');
        $('[id$=remail],[id$=mpemail],[id$=pemailaddress],[id$=pemailaddress2]').addClass('email-std');
        if (labelNameRadio == ' Medical Professional') {
            $('.medProvCat').val('');
            $('.medProvCat').find('option:first').remove();
            $('.medProvCat').prepend('<option disabled="disabled" selected="selected">Please select an option</option>');
            $('.referrerInfo, .medicalProvider, .main-office-contact').css('display', 'block');
            $('.other').css('display', 'none');
            $('[id$=aware-of-referral]').addClass('family-aware-chk');
            $('[id$=medprov]').addClass('medprovider');
            $('.medical-additional-info').show();
            $('[id$=rfirstname],[id$=frm\\:pfirstname],[id$=frm\\:pfirstname2],[id$=wcfirstname],[id$=mplastname]').addClass('firstname');
            $('[id$=rlastname],[id$=frm\\:plastname],[id$=frm\\:plastname2],[id$=wclastname],[id$=mplastname]').addClass('lastname');
            if ($('[id$=rphone],[id$=pphonenumber],[id$=pphonenumber2],[id$=mpphone]').hasClass('phonechk-std')) {
                $('[id$=rphone],[id$=pphonenumber],[id$=pphonenumber2],[id$=mpphone]').removeClass('phonechk-std');
                $('[id$=rphone],[id$=pphonenumber],[id$=mpphone]').addClass('phonechk')
            }
            if ($('[id$=remail]').hasClass('email-std')) {
                $('[id$=remail]').removeClass('email-std');
                $('[id$=remail]').addClass('email')
            }
            $('[id$=pcity]').addClass('city');
            $('[id$=ppostalcode]').addClass('postalcode');
            $('[id$=p-state]').addClass('state-chk');
            $('[id$=wcdob]').addClass('wcdob');
            $('[id$=wcgender]').addClass('wcgender');
            $('[id$=paddress]').addClass('address');
            $('[id$=plang]').addClass('language');
            $('[id$=searchDiagnosisId]').addClass('pdiagnosis');
            $('[id$=urgency]').addClass('urgency');
            $('[id$=mphospitalname]').addClass('facility');
            formValidationRules();
            clearFuncSelf();
            clearFuncParent()
        } else if (labelNameRadio == ' Other') {
            $('.other input').val('');
            $('.referrerInfo,.other').css('display', 'block');
            $('.medicalProvider').css('display', 'none');
            $('[id$=aware-of-referral]').addClass('family-aware-chk');
            $('[id$=r2cManualInput]').addClass('r2c-manual-input');
            $('[id$=rfirstname],[id$=wcfirstname],[id$=frm\\:pfirstname],[id$=frm\\:pfirstname2]').addClass('firstname');
            $('[id$=rlastname],[id$=frm\\:plastname],[id$=frm\\:plastname2],[id$=wclastname]').addClass('lastname');
            if ($('[id$=rphone]').hasClass('phonechk-std')) {
                $('[id$=rphone]').removeClass('phonechk-std');
                $('[id$=rphone]').addClass('phonechk')
            }
            if ($('[id$=remail]').hasClass('email-std')) {
                $('[id$=remail]').removeClass('email-std');
                $('[id$=remail]').addClass('email')
            }
            $('[id$=rcity]').addClass('city');
            $('[id$=rpostalcode]').addClass('postalcode');
            $('[id$=urgency]').addClass('urgency');
            formValidationRules();
            $("[id$=searchDiagnosisId]").addClass("pdiagnosis");
            $('[id$=wcage]').parents('.form-group').removeClass('sr-only');
            $('.repeatMedProf').css('display', 'none');
            clearFuncSelf();
            clearFuncParent()
        } else if (labelNameRadio == ' Self' || labelNameRadio == ' Parent/Guardian' || labelNameRadio == ' Family Member/Relative') {
            $('[id$=rfirstname],[id$=frm\\:pfirstname],[id$=frm\\:pfirstname2],[id$=wcfirstname]').addClass('firstname');
            $('[id$=rlastname],[id$=frm\\:plastname],[id$=frm\\:plastname2],[id$=wclastname],[id$=mplastname]').addClass('lastname');
            if ($('[id$=rphone],[id$=pphonenumber],[id$=pphonenumber2]').hasClass('phonechk-std')) {
                $('[id$=rphone],[id$=pphonenumber],[id$=pphonenumber2]').removeClass('phonechk-std');
                $('[id$=rphone],[id$=pphonenumber]').addClass('phonechk')
            }
            if ($('[id$=remail]').hasClass('email-std')) {
                $('[id$=remail]').removeClass('email-std');
                $('[id$=remail]').addClass('email')
            }
            $('[id$=pcity]').addClass('city');
            $('[id$=ppostalcode]').addClass('postalcode');
            $('[id$=p-state]').addClass('state-chk');
            $('[id$=nSib],[id$=nSib2],[id$=psibfirstname],[id$=psibfirstname2],[id$=psiblastname],[id$=psiblastname2],[id$=psibage],[id$=psibage2]').addClass('sibling-chk');
            $('[id$=wcdob]').addClass('wcdob');
            $('[id$=wcgender]').addClass('wcgender');
            $('[id$=paddress]').addClass('address');
            $('[id$=plang],[id$=plang2]').addClass('language');
            $('[id$=searchDiagnosisId]').addClass('pdiagnosis');
            $('[id$=mphospitalname]').addClass('facility');
            $('[id$=urgency]').addClass('urgency');
            $('.repeatMedProf').css('display', 'none');
            if (labelNameRadio == ' Self' || labelNameRadio == ' Family Member/Relative') {
                $('[id$=aware-of-referral]').addClass('family-aware-chk')
            }
            if (labelNameRadio == ' Self') {
                childClone();
                ageCheck();
                clearFuncParent()
            }
            if (labelNameRadio == ' Family Member/Relative') {
                $('[id$=r2cManualInput]').addClass('r2c-manual-input').val('');
                $('.other').css('display', 'block')
            }
            if (labelNameRadio == ' Parent/Guardian') {
               // $('.shownOnYes').removeClass('fam-aware-overlay');
                $('[id$=aware-of-referral]').removeClass('family-aware-chk');
                $('[id$=aware-of-referral]').parent().parent().css('display', 'none');
                $('[id$=aware-of-referral] option[value="Yes"]').prop('selected', !0)
            }
            formValidationRules();
            parentClone();
            clearFuncSelf()
        }
    });

    function ageCheck() {
        var childAge = $('.childAge').val();
        var selectedRel = $('.radioSection input:checked').parent().text();
        var selectedAge = $.inArray(childAge, childAgesEligible);
        if (selectedAge > '-1' && selectedRel == ' Self') {
            $('.alertMsg').text(guardianPermissionMsg);
            $('#age13under-modal').modal('show')
        }
    }
    $('.childAge').on('change', function() {
        var ageVal = $('age-text').text();
        if ($(this).val() == 'Under 2.5' || $(this).val() == '18 & Above') {
            $('.alertMsg').text(eligibleMsg);
            $('#warningModal').modal('show')
        }
        if ($('select.childAge').val() != ageVal) {
            $("[id$=wcdob]").val('');
            $('.age-text').fadeOut(300, function() {
                $(this).remove()
            });
            $("[id$=wcdob]").unmask();
            $("[id$=wcdob]").mask("99/99/9999", {
                placeholder: "mm/dd/yyyy",
            })
        }
        ageCheck()
    });

    function dateLogic() {
        $('[id$=wcdob]').on('keyup', function() {
            var wcAge = $("[id$=wcage]"),
                wcDob = $("[id$=wcdob]"),
                wcDobInput = $("[id$=wcdob]").val(),
                today = new Date(),
                birthDate = new Date(wcDobInput),
                ageGroup = 0,
                wcDobVal = $(this).val(),
                count = 0,
                letters = ['m', 'd', 'y'],
                letterFormat = wcDobVal.indexOf('m') && wcDobVal.indexOf('d') && wcDobVal.indexOf('y'),
                delay = (function() {
                    var timer = 0;
                    return function(callback, ms) {
                        clearTimeout(timer);
                        timer = setTimeout(callback, ms)
                    }
                })();

            function getAge(dateString) {
                var daysInDOBMonth, DOB, todayDate, ageYears, ageMonths, ageDays;
                todayDate = new Date();
                var dateArray = dateString.split("/");
                var mm = dateArray[0],
                    dd = dateArray[1],
                    yyyy = dateArray[2];
                if (mm < 1 || mm > 12 || dd < 1 || dd > 31) {
                    ageGroup = 0;
                    return NaN
                }
                var daysInMonth = new Date(yyyy, mm, 0).getDate();
                if (dd > daysInMonth) {
                    ageGroup = 0;
                    return NaN
                }
                DOB = new Date(dateString);
                if (DOB.getTime() > todayDate.getTime()) {
                    ageGroup = 0;
                    return NaN
                }
                ageYears = todayDate.getFullYear() - DOB.getFullYear();
                ageMonths = todayDate.getMonth() - DOB.getMonth();
                if (ageMonths < 0) {
                    ageYears = ageYears - 1;
                    ageMonths = ageMonths + 12
                }
                ageDays = todayDate.getDate() - DOB.getDate();
                if (ageDays < 0) {
                    ageMonths = ageMonths - 1;
                    if (ageMonths < 0) {
                        ageYears = ageYears - 1;
                        ageMonths = ageMonths + 12
                    }
                    daysInDOBMonth = new Date(DOB.getFullYear(), DOB.getMonth() + 1, 0).getDate();
                    ageDays = (daysInDOBMonth - DOB.getDate()) + todayDate.getDate()
                }
                if (ageYears >= 18) {
                    ageGroup = 5
                } else if (ageYears >= 13 && ageYears < 18) {
                    ageGroup = 4
                } else if (ageYears >= 2 && ageYears < 13) {
                    if (ageYears >= 3) {
                        ageGroup = 3
                    } else if (ageMonths >= 6) {
                        ageGroup = 2
                    } else {
                        ageGroup = 1
                    }
                } else if (ageYears == 0 || ageYears == 1) {
                    ageGroup = 1;
                    ageYears = 1
                }
                return ageYears
            }

            function ageValidate() {
                var r2cRadioSelected = getRadioVal(document.getElementById('j_id0:frm'), 'r2c-radio');

                function ageAlert() {
                    $('.alertMsg').text(eligibleMsg);
                    $('#warningModal').modal('show')
                }
                $('.age-text').remove();
                getAge(wcDobInput);
                if (ageGroup == 1) {
                    $(wcAge).prop('selectedIndex', 1);
                    $('<span class="text-muted age-text">Under 2 1/2 years old</span>').insertAfter(wcDob);
                    ageAlert()
                } else if (ageGroup == 2) {
                    $(wcAge).prop('selectedIndex', 2);
                    $('<span class="text-muted age-text">2 1/2 years old</span>').insertAfter(wcDob);
                    if (r2cRadioSelected == "Self") {
                        console.log('between 2.5 - 13 years');
                        console.log('Self is selected');
                        $('#age13under-modal').modal('show')
                        $('.alertMsg').text(guardianPermissionMsg)
                    }
                } else if (ageGroup == 5) {
                    $(wcAge).prop('selectedIndex', 19);
                    $('<span class="text-muted age-text">Over 18 years old</span>').insertAfter(wcDob);
                    ageAlert()
                } else if (ageGroup == 3 || ageGroup == 4) {
                    $(wcAge).prop('selectedIndex', 0);
                    $(wcAge).append('<option value="' + getAge(wcDobInput) + '" selected="selected">' + getAge(wcDobInput) + '</option>');
                    $('<span class="text-muted age-text">' + getAge(wcDobInput) + ' years old</span>').insertAfter(wcDob);
                    if (r2cRadioSelected == "Self" && ageGroup == 3) {
                        console.log('Self is selected');
                        console.log('between 2.5 - 13 years');
                        $('.alertMsg').text(guardianPermissionMsg);
                        $('#age13under-modal').modal('show')
                    }
                }
                if (getAge(wcDobInput) < 0 || !getAge(wcDobInput)) {
                    $('.age-text').remove();
                    $('<span class="text-muted age-text" style="color:red">Oops! Invalid Birthdate</span>').insertAfter(wcDob);
                    delay(function() {
                        $("[id$=wcdob]").val('');
                        $('.age-text').fadeOut(300, function() {
                            $(this).remove()
                        });
                        $("[id$=wcdob]").unmask();
                        $("[id$=wcdob]").mask("99/99/9999", {
                            placeholder: "mm/dd/yyyy",
                        });
                        $(wcAge).prop('selectedIndex', 0)
                    }, 1000)
                }
            }
            while (letterFormat !== -1) {
                count++;
                letterFormat = wcDobVal.indexOf(letters, letterFormat + 1)
            }
            if (count === 0) {
                ageValidate()
            }
        })
    }
}
formLogic();

function PrimaryDiagnosis() {
    var PLACEHOLDER;
    var eventObjects;
    var queryTerm;
    var pdi = $('[id$=searchDiagnosisId]');
    var icd = $('[id$=diagnosisTextId]');
    icd.autocomplete({
        minLength: 2,
        source: function(request, response) {
            queryTerm = request.term;
            WishReferralForm_AC.searchDiagnosis(request.term, function(result, event) {
                if (event.type == 'exception') {
                    alert(event.message)
                } else {
                    eventObjects = result;
                    response(eventObjects)
                }
            })
        },
        response: function(event, ui) {
            ui.content.push({
                'label': 'Please select a ICD code below',
                'value': ''
            })
        },
        select: function(event, ui) {
            var descName = ui.item.Condition_Description__c;
            pdi.val('');
            pdi.prop('disabled', !0);
            icd.addClass('value-selected');
            pdi.addClass('value-selected');
            icd.val(ui.item.Name);
            $('[id$=shortTextId]').html('Description: ' + ui.item.Short_Description__c).text();
            $('.primary-diagnosis-other').prop('hidden', !0);
            $('.primary-diagnosis-other').find('textarea').val('');
            pdiRemoveValidation();
            if (typeof descName != 'undefined') {
                pdi.val(ui.item.Condition_Description__r.Name);
                var ss = $('.searchDiagnosisId').html(ui.item.Condition_Description__r.Name).text();
                pdi.val(ss);
                pdi.prop('disabled', !0);
                pdiRemoveValidation()
            }
            return !1
        },
    }).data("ui-autocomplete")._renderItem = function(ul, item) {
        var entry = "<a>" + item.Name;
        entry = entry + "</a>";
        entry = entry.replace(queryTerm, "<b>" + queryTerm + "</b>");
        if (item.value == '') {
            return $('<li class="ui-state-disabled option-disabled">' + item.label + '</li>').prependTo(ul)
        } else {
            return $("<li></li>").data("ui-autocomplete-item", item).append(entry).appendTo(ul)
        }
    };

    function pdiRemoveValidation() {
        pdi.css('border', '').removeAttr('aria-required aria-describedby');
        pdi.parents().removeClass('has-error');
        pdi.parents('.primaryDiagnosis').children('.col-sm-3').children('label').css('color', '');
        pdi.next('.error').remove()
    }
    icd.keydown(function(e) {
        if (($(this).hasClass('value-selected') || !pdi.hasClass('value-selected')) && e.keyCode != 9) {
            $(this).removeClass('value-selected');
            pdi.removeClass('value-selected');
            pdi.val('');
            pdi.prop('disabled', !1);
            $('[id$=shortTextId]').text('')
        }
        if (((e.keyCode == 9) && $(this).hasClass('value-selected')) || $(this).val() == '') {
            return !0
        } else if (e.keyCode == 9) {
            e.preventDefault()
        }
    });
    pdi.keydown(function(e) {
        if (($(this).hasClass('value-selected') && e.keyCode != 9) || $(this).val() == '') {
            $(this).removeClass('value-selected');
            icd.removeClass('value-selected');
            if (icd.hasClass('value-selected') == !1) {
                icd.val('');
                icd.prop('disabled', !1);
                $('[id$=shortTextId]').text('')
            }
        }
        if (((e.keyCode == 9) && $(this).hasClass('value-selected')) || $(this).val() == '') {
            return !0
        } else if (e.keyCode == 9) {
            e.preventDefault()
        }
    });
    $('body').change('click', function(event) {
        if (!pdi.hasClass('value-selected')) {}
        if (!icd.hasClass('value-selected')) {
            if (event.srcElement && event.srcElement.tagName) {
                if (event.srcElement.tagName != "INPUT" || event.srcElement.tagName != "SELECT") {
                    icd.val('');
                    icd.prop('disabled', !1)
                }
            }
        } else if (!icd.hasClass('value-selected') && pdi.hasClass('value-selected')) {
            return
        }
    });
    pdi.autocomplete({
        minLength: 2,
        source: function(request, response) {
            queryTerm = request.term;
            WishReferralForm_AC.searchCondition(request.term, function(result, event) {
                if (event.type == 'exception') {
                    alert(event.message)
                } else {
                    eventObjects = result;
                    response(eventObjects)
                }
            })
        },
        response: function(event, ui) {
            ui.content.push({
                'label': 'Please select a diagnosis below',
                'value': ''
            })
        },
        select: function(event, ui) {
            var descName = ui.item.Code_To_Use__c;
            var otherDiagnosis = /^(Other )(.*)$/i.test(ui.item.Name);
            var notlistedDiagnosis = /^(Not Listed)$/i.test(ui.item.Name);
            var ss1 = $('.searchDiagnosisId').html(ui.item.Name).text();
            icd.val('');
            icd.prop('disabled', !1);
            pdi.val(ui.item.Name);
            pdi.val(ss1);
            pdi.addClass('value-selected');
            icd.focus();
            if (typeof descName != 'undefined') {
                icd.val(ui.item.Code_To_Use__c);
                icd.prop('disabled', !0)
            }
            if (otherDiagnosis || notlistedDiagnosis) {
                $('.primary-diagnosis-other').prop('hidden', !1)
            } else {
                $('.primary-diagnosis-other').prop('hidden', !0);
                $('.primary-diagnosis-other').find('textarea').val('')
            }
            return !1
        },
    }).data("ui-autocomplete")._renderItem = function(ul, item) {
        var entry = "<a>" + item.Name;
        entry = entry + "</a>";
        entry = entry.replace(queryTerm, "<b>" + queryTerm + "</b>");
        if (item.value == '') {
            return $('<li class="ui-state-disabled option-disabled">' + item.label + '</li>').prependTo(ul)
        } else {
            return $("<li></li>").data("ui-autocomplete-item", item).append(entry).appendTo(ul)
        }
    }
}
PrimaryDiagnosis();
$('.submitBtn').click(function() {
    $('.searchDiagnosisId').val($('.pdiagnosis').val());
    $('.diagnosisFilter').val($('.diagnosisText').val())
});
$('.fs').hide();
jQuery.extend(jQuery.validator.messages, {
    required: "Oops! This field is required",
    email: "Oops! Please enter a valid email address",
    url: "Oops! Please enter a valid URL",
    date: "Oops! Please enter a valid date",
    number: "Oops! Please enter a valid number",
    digits: "Please enter only digits",
});
$.validator.addMethod("zipcode", function(value, element) {
    return this.optional(element) || /^\d{5}(?:-\d{4})?$/.test(value)
}, "Oops! Please enter a valid US postal code");
//SIW : 555 - Added custom email validation rule
$.validator.addMethod("laxEmail", function(value, element) {
    return this.optional(element) || /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/.test(value)
}, "Oops! You've entered an invalid email address");
$.validator.addMethod("notEqual", function(value, element) {
    return this.optional(element) || ($('.memail').val() != $('.bemail').val())
}, "Oops! Please enter an email address different from the Treating Medical Professional's email address");
$("form[id$=frm]").validate({
    ignore: ":hidden",
    errorElement: "em",
    errorPlacement: function(error, element) {
        error.addClass("help-block");
        element.parents(".col-sm-6,.col-sm-3").addClass("has-feedback");
        if (element.prop("type") === "radio") {
            error.insertBefore(element.parents('.r2c'))
        } else if (element.hasClass("c-select") && element.hasClass("multi")) {
            var selectParent = $(element).parents(".col-sm-6").children(".multi");
            error.insertAfter(selectParent)
        } else {
            error.insertAfter(element)
        }
    },
    highlight: function(element, errorClass, validClass) {        
        var elementParents = $(element).parents(".col-sm-3, .col-sm-6, .col-xs-8.col-sm-4, .r2c, td, .dateInput");
        $(elementParents).removeClass("has-success").addClass("has-error").prev('label').css('color', 'red');
        $(elementParents).removeClass("has-success").addClass("has-error").parents('.sibInfo').children('span').children('span').children('label').css('color', 'red');
        $(elementParents).removeClass("has-success").addClass("has-error").prev('div').children('label').css('color', 'red');
        $(elementParents).removeClass("has-success").addClass("has-error").prev('div').prev('label').css('color', 'red');
        $(elementParents).children(".chosen-container-single").children(".chosen-single").css('border', '1px solid red');
        $(elementParents).children("select.single").css('border', '1px solid red');
        $(elementParents).children(".chosen-container-multi").children(".chosen-multiple").css('border', '1px solid red');
        $(elementParents).children("input, select, textarea").css('border', '1px solid red');
        $(elementParents).children('label').css('border', '1px solid red')
    },
    unhighlight: function(element, errorClass, validClass) {        
        var elementParents = $(element).parents(".col-sm-3, .col-sm-6, .col-xs-8.col-sm-4, .col-sm-1, .r2c, td, .dateInput");
        $(elementParents).removeClass("has-error").prev("label").css('color', '');
        $(elementParents).removeClass("has-error").parents('.sibInfo').children('span').children('span').children('label').css('color', '');
        $(elementParents).removeClass("has-error").prev('div').children("label").css('color', '');
        $(elementParents).removeClass("has-success").addClass("has-error").prev('div').prev('label').css('color', '');
        $(elementParents).children(".chosen-container-single").children(".chosen-single").css('border', '');
        $(elementParents).children("select.single").css('border', '');
        $(elementParents).children(".chosen-container-multiple").children(".chosen-multiple").css('border', '');
        $(elementParents).children("input, select, textarea").css('border', '');
        $(elementParents).children(".help-block").remove()
    },
    submitHandler: function() {
        if ($('#b98084695645e0e89ec5a2f3c41f0a2d').is(':checked') == !0 || $('#2-b98084695645e0e89ec5a2f3c41f0a2d').val() !== 'udh&6**33#') {
            onsubmit: !1
        }
        else {
            if ($("form[id$=frm]").valid()) {
                $('.submitBtn').css({
                    'cursor': 'not-allowed',
                    'opacity': '.5'
                }).addClass('disabled').prop('disabled', !0);
                form.submit();
                return
            }
        }
    }
});

function formValidationRules() {
    $("select.r2c-select").each(function() {
        $(this).rules("add", {
            required: !0,
            messages: {
                required: "Oops! Please select the relationship to the child"
            }
        })
    });
    $("input.firstname").each(function() {
        $(this).rules("add", {
            required: !0,
            minlength: 2,
            maxlength: 40,
            messages: {
                required: "Oops! Please enter a first name",
                minlength: "Oops! Your first name must have more than 2 letters",
                maxlength: "We're sorry, you've reached the maximum allowed characters",
            }
        })
    });
    $("input.lastname").each(function() {
        $(this).rules("add", {
            required: !0,
            minlength: 2,
            maxlength: 40,
            messages: {
                required: "Oops! Please enter a last name",
                minlength: "Oops! Your first name must have more than 2 letters",
                maxlength: "We're sorry, you've reached the maximum allowed characters",
            }
        })
    });
    $("input.phonechk-std").each(function() {
        $(this).rules("add", {
            required: !1,
            minlength: 10,
            maxlength: 14,
            messages: {
                number: "Only numbers are accepted",
                minlength: "Oops! Please enter at least 10 digits",
                maxlength: "We're sorry, you've reached the maximum allowed characters"
            }
        })
    });
    $("input.phonechk").each(function() {
        $(this).rules("add", {
            required: !0,
            minlength: 10,
            maxlength: 14,
            messages: {
                required: "Oops! Please enter a phone number",
                number: "Only numbers are accepted",
                minlength: "Oops! Please enter at least 10 digits",
                maxlength: "We're sorry, you've reached the maximum allowed characters"
            }
        })
    });
    $("input.email-std").each(function() {
        $(this).rules("add", {
            required: !1,
            email: !0,
            laxEmail : true,
            messages: {
                email: "Oops! You've entered an invalid email address"
            }
        })
    });
    $("input.email").each(function() {
        $(this).rules("add", {
            required: !0,
            email: !0,
            laxEmail : true,
            messages: {
                required: "Oops! Please enter a valid email address",
                email: "Oops! You've entered an invalid email address"
            }
        })
    });
    $("input.address").each(function() {
        $(this).rules("add", {
            required: !0,
            minlength: 5,
            maxlength: 40,
            messages: {
                required: "Oops! Please enter an address",
                minlength: "Oops! Please enter a minimum of 5 characters",
                maxlength: "We're sorry, you've reached the maximum allowed characters"
            }
        })
    });
    $("select.state-chk").each(function() {
        $(this).rules("add", {
            required: !0,
            messages: {
                required: "Oops! Please select a state"
            }
        })
    });
    $("input.city").each(function() {
        $(this).rules("add", {
            required: !0,
            minlength: 3,
            maxlength: 22,
            messages: {
                required: "Oops! Please enter a US city",
                minlength: "Oops! Please enter at least 3 characters",
                maxlength: "We're sorry, you've reached the maximum allowed characters",
            }
        })
    });
    $("input.postalcode-std").each(function() {
        $(this).rules("add", {
            required: !1,
            digits: !0,
            minlength: 5,
            maxlength: 9,
            messages: {
                required: "Oops! Please enter a valid US postal code",
                digits: "Oops! Please only enter digits",
                minlength: "Oops! Please enter a minimum of 5 digits",
                maxlength: "We're sorry, you've reached the maximum allowed characters"
            }
        })
    });
    $("input.postalcode").each(function() {
        $(this).rules("add", {
            required: !0,
            zipcode: !0,
            minlength: 5,
            maxlength: 10,
            messages: {
                required: "Oops! Please enter a valid US postal code",
                minlength: "Oops! Please enter a minimum of 5 digits",
                maxlength: "We're sorry, you've reached the maximum allowed characters"
            }
        })
    });
    $("input.sibage").each(function() {
        $(this).rules("add", {
            required: !0,
            digits: !0,
            minlength: 1,
            maxlength: 2,
            messages: {
                required: "Oops! Please enter this sibling's age",
                digits: "Oops! Please only enter digits",
                minlength: "Oops! Please enter a minimum of 2 digits",
                maxlength: "We're sorry, you've reached the maximum allowed characters"
            }
        })
    });
    $("input.r2c-radio").rules("add", {
        required: !0,
        messages: {
            required: "Oops! Please select an option"
        }
    });
    $("select.family-aware-chk").rules("add", {
        required: !0,
        messages: {
            required: "Oops! Please select an option"
        }
    });
    $("select.medprovider").rules("add", {
        required: !0,
        messages: {
            required: "Oops! Please select an option"
        }
    });
    $("input.medprovcat-other").rules("add", {
        required: !0,
        messages: {
            required: "Oops! Please enter the other medical provider category"
        }
    });
    $("input.r2c-manual-input").rules("add", {
        required: !0,
        minlength: 3,
        maxlength: 20,
        messages: {
            required: "Oops! Please enter your relationship to the Wish Child",
            minlength: "Oops! Please enter a minimum of 3 characters",
            maxlength: "We're sorry, you've reached the maximum allowed characters"
        }
    });
    $("select.wcage").rules("add", {
        required: !0,
        messages: {
            required: "Oops! Please select the wish child's age"
        }
    });
    $("select.wcgender").rules("add", {
        required: !0,
        messages: {
            required: "Oops! The child's gender is required"
        }
    });
    $("input.wcdob").rules("add", {
        required: !0,
        date: !0,
        messages: {
            required: "Oops! The child's date of birth is required",
            date: "Oops! Please enter a valid date in the correct format"
        }
    });
    $("input.wcreceivedwish").rules("add", {
        required: !0,
        messages: {
            required: "Oops! This question is required"
        }
    });   
    $("select.siblings-chk").rules("add", {
        required: !0,
        messages: {
            required: "Oops! Please select the number of siblings"
        }
    });
    $("input.icd").rules("add", {
        required: !0,
        minlength: 3,
        messages: {
            required: "Oops! Please enter an ICD code",
            minlength: "Oops! Please enter a minimum of 3 characters"
        }
    });
    $("input.pdiagnosis").rules("add", {
        required: !0,
        minlength: 3,
        messages: {
            required: "Oops! Please enter a primary diagnosis",
            minlength: "Oops! Please enter a minimum of 3 characters",
        }
    });
    $("input.facility").rules("add", {
        required: !0,
        minlength: 3,
        messages: {
            required: "Oops! Please enter the name of the hospital or treatment facility",
            minlength: "Oops! Please enter a minimum of 3 characters",
        }
    });
    $("select.urgency").rules("add", {
        required: !0,
        messages: {
            required: "Oops! Please select an option",
        }
    });
    $("input.notqualto").rules("add", {
        notEqual: !0
    });
    $("select.d-month").rules("add", {
        required: !0,
        messages: {
            required: "Oops! Please select a month"
        }
    });
    $("select.d-year").rules("add", {
        required: !0,
        messages: {
            required: "Oops! Please select a year"
        }
    });
    $("textarea.selfdescreq").rules("add", {
        required: !0,
        messages: {
            required: "Oops! Please enter a description pertaining to 'Self-describe'"
        }
    });
    $(".primary-diagnosis-other textarea").rules("add", {
        required: function() {
            return ($("[id$=searchDiagnosisId]").val() == "Not Listed" || ($("[id$=searchDiagnosisId]").val().toLowerCase().indexOf("other") >= 0))
        },
        messages: {
            required: "Oops! Please enter a primary diagnosis description"
        }
    })
}
$('.r2c').children('label').children('input').addClass('r2c-radio');
$('[id$=p-r2c-1]').addClass('r2c-select');
$('[id$=plang').addClass('language');
formValidationRules()
