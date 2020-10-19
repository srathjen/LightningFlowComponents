/**********************************************************
Created by: Manoj Tammineny
Created Date : 04/05/2020
Description : Static Resource for Spanish version of WishReferral form 
***********************************************************/
function getRadioVal(e, a) {
    for (var i, s = e.elements[a], r = 0, t = s.length; r < t; r++)
        if (s[r].checked) {
            i = s[r].value;
            break
        } return i
}

function isTextSelected(e) {
    return "number" == typeof e.selectionStart ? 0 == e.selectionStart && e.selectionEnd == e.value.length : void 0 !== document.selection ? (e.focus(), document.selection.createRange().text == e.value) : void 0
}

function stateFunc() {
    $("select.state option:first").remove(), $(".state").prepend('<option disabled="disabled" selected="selected">Por favor seleccione un estado</option>')
}

function resetSelect() {
    for (var e = document.querySelectorAll("select option"), a = 0, i = e.length; a < i; a++) e[a].selected = e[a].defaultSelected
}

function formLogic() {
    var e = '<a href="https://wish.org/local-chapters#sm.000001nnnt2f0tf0tux692bqfeli5" target="_blank">Haga clic aquí para un directorio de las oficinas de Make-A-Wish.</a>',
        a = "Por favor asegúrese de que la familia sepa que está siendo referida a nuestra organización antes de proceder. Si tiene usted preguntas adicionales, por favor comuníquese con la oficina de Make-A-Wish de su localidad. ",
        i = "We recommend that you discuss potential eligibility with the child's treating healthcare provider before you proceed. If you have additional questions please reach out to your local chapter. ",
        s = [" Self", " Medical Professional", " Parent/Guardian", " Family Member/Relative", " Other"],
        r = [" Self", " Parent/Guardian", " Family Member/Relative"],
        t = ["Nurse Practitioner", "Physician Assistant", "Physician"],
        n = ["2.5", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13"],
        d = "Para ser elegibles, los niños/as deben ser mayores de 2½ años de edad y menores de 18 años de edad.";

    function l() {
        $(".wcfirstname").val($(".rfirstname").val()), $(".wclastname").val($(".rlastname").val()), $(".wcfirstname").val() == $(".rfirstname").val() && $(".wcfirstname").val(""), $(".wclastname").val() == $(".rlastname").val() && $(".wclastname").val("")
    }

    function o() {
        $(".pfirstname").val($(".rfirstname").val()), $(".plastname").val($(".rlastname").val()), $(".pphone").val($(".rphone").val()), $(".pemailaddress").val($(".remail").val()), $(".pcity").val($(".rcity").val()), $(".ppostalcode").val($(".rpostalcode").val()), $(".pfirstname").val() == $(".rfirstname").val() && $(".pfirstname").val(""), $(".plastname").val() == $(".rlastname").val() && $(".plastname").val(""), $(".pphone").val() == $(".rphone").val() && $(".pphone").val(""), $(".pemailaddress").val() == $(".remail").val() && $(".pemailaddress").val(""), $(".pcity").val() == $(".rcity").val() && $(".pcity").val(""), $(".ppostalcode").val() == $(".rpostalcode").val() && $(".ppostalcode").val("")
    }
    $(".familyAware").on("change", function() {
        if ("No" == $(this).val()) {
            var i = " Other",
                r = $.inArray(i, s);
            $(".familyAwareError").css("display", "block"), $(".medprovcat-other-wrap").css("display", "none"), $(".medprovcat-other").val(""), $(this).next(".familyAwareError").text(a).append($(e)), r > -1 ? ($(this).next(".familyAwareError").text(a).append($(e)), $(".shownOnYes").addClass("fam-aware-overlay"), " Medical Professional" == i && $(".medicalProvider").css("display", "none"), " Other" == i && ($(".r2c-manual-input").parent().parent().css("display", "none"), $(this).next(".familyAwareError").text(a).append($(e)))) : ($(".familyAwareError, .medprovcat-other-wrap").css("display", "none"), $(".medprovcat-other").val(""))
        } else "Yes" == $(this).val() ? (i = " Other", $(this).next("span").text(""), $(".r2c-manual-input").parent().parent().removeClass("displayNone").css("display", "block"), " Medical Professional" == i && $(".medicalProvider").css("display", "block"), " Other" == i && $(".r2c-manual-input").parent().parent().removeClass("displayNone").css("display", "block")) : ($(".shownOnYes").addClass("fam-aware-overlay"), $(".familyAwareError").css("display", "none"))
    }), $(".discussedProvider").on("change", function() {
        if ("No" == $(this).val()) {
            var a = " Other",
                r = $.inArray(a, s);
            $(".discussedProviderError").css("display", "block"), $(".medprovcat-other-wrap").css("display", "none"), $(".medprovcat-other").val(""), r > -1 ? ($(this).next(".discussedProviderError").text(i).append($(e)), $(".shownOnYes").addClass("fam-aware-overlay"), " Medical Professional" == a && $(".medicalProvider").css("display", "none"), " Other" == a && ($(".r2c-manual-input").parent().parent().css("display", "none"), $(this).next(".discussedProviderError").text(i).append($(e)))) : ($(".discussedProviderError, .medprovcat-other-wrap").css("display", "none"), $(".medprovcat-other").val(""))
        } else "Yes" == $(this).val() ? (a = " Other", $(this).next("span").text(""), " Medical Professional" == a && $(".medicalProvider").css("display", "block"), " Other" == a && $(".r2c-manual-input").parent().parent().removeClass("displayNone").css("display", "block")) : ($(".shownOnYes").addClass("fam-aware-overlay"), $(".discussedProviderError").css("display", "none"))
    }), $("#j_id0\\:frm\\:wcgender").on("change", function() {
        null != $(this).val() && (-1 != $(this).val().indexOf("Self-describe") ? ($(".self-desc").prop("hidden", !1), $(".self-desc-field").addClass("selfdescreq")) : ($(".self-desc").prop("hidden", !0), $(".self-desc-field").removeClass("selfdescreq").val("")), formValidationRules())
    }), $(".medprovcat-other-wrap").css("display", "none"), $("[id$=medprov]").on("change", function() {
        null != $(this).val() && (-1 != $(this).val().indexOf(" Other") ? $(".medprovcat-other-wrap").css("display", "block") : ($(".medprovcat-other-wrap").css("display", "none"), $(".medprovcat-other").val("")))
    }), $(".medProvCat").on("change", function() {
        var e = $(".medProvCat").val();
        $.inArray(e, t) > -1 ? $(".repeatMedProf").css("display", "block") : $(".repeatMedProf").css("display", "none")
    }), $(".repeatMedProf").on("change", function() {
        checkVisible = $(".repeatMedProf input").is(":checked"), 1 == checkVisible ? ($(".mfirstname").val($(".rfirstname").val()), $(".mlastname").val($(".rlastname").val()), $(".mphone").val($(".rphone").val()), $(".memail").val($(".remail").val())) : 0 == checkVisible && $(".medToRepeat :input").each(function() {
            $(this).val("")
        })
    }), $(".refToRepeat :input").on("keyup", function() {}), $(".clone-guardian-1 input").click(function() {
        $(this).is(":checked") ? ($("[id$=paddress2]").val($("[id$=paddress]").val()), $("[id$=pcity2]").val($("[id$=pcity]").val()), $("[id$=p-state2]").val($("[id$=p-state]").val()), $("[id$=ppostalcode2]").val($("[id$=ppostalcode]").val())) : ($("[id$=paddress2], [id$=pcity2], [id$=ppostalcode2]").val(""), $("[id$=p-state2]").prop("selectedIndex", 0))
    }), $(".refToParent :input").on("keyup", function() {}), $("[id$=nSib],[id$=nSib2]").on("change", function() {
        "" != $(this).val() || "0" != $(this).val() || "Desconocido" != $(this).val() ? $(".sibInfo").css("display", "block") : ($(".sibInfo").css("display", "none"), function(e, a, i) {
            var s = 0,
                r = window.setInterval(function() {
                    e(), ++s === i && window.clearInterval(r)
                }, a)
        }(function() {
            $("[id$=psibfirstname],[id$=psibfirstname2]").removeClass("firstname"), $("[id$=psiblastname],[id$=psiblastname]").removeClass("lastname"), $("[id$=psibage],[id$=psibage]").removeClass("sibage"), $("input[id$=psibfirstname],input[id$=psibfirstname2],input[id$=psiblastname],input[id$=psiblastname2],input[id$=psibage],input[id$=psibage2]").each(function() {
                $(this).rules("remove")
            })
        }, 100, 3))
    }), $(document).ready(function() {
        var e = $.inArray(" Other", r);
        ! function() {
            $("form[id$=frm]").validate().resetForm(), $("input,select").removeClass("r2c-select firstname lastname phonechk email city state-chk address postalcode family-aware-chk medprovider r2c-manual-input wcgender wcage wcdob wcreceivedwish language siblings-chk icd pdiagnosis facility urgency sibage required d-month d-year").removeAttr("aria-required aria-describedby"), $("select[id$=aware-of-referral],select[id$=medprov],select[id$=p-r2c-2],input[id$=rfirstname],input[id$=frm\\:pfirstname],input[id$=frm\\:pfirstname2],input[id$=wcfirstname]input,[id$=mpfirstname],input[id$=rlastname],input[id$=frm\\:plastname],input[id$=frm\\:plastname2],input[id$=wclastname],input[id$=mplastname],input[id$=rphone],input[id$=pphonenumber],input[id$=pphonenumber2],input[id$=mpphone],input[id$=remail],input[id$=pemailaddress],input[id$=pemailaddress2],input[id$=pcity],input[id$=pcity2],input[id$=ppostalcode],input[id$=ppostalcode2],select[id$=p-state],select[id$=p-state2],input[id$=wcdob],select[id$=wcgender],input[id$=paddress],input[id$=paddress2],select[id$=plang],select[id$=plang2],input[id$=searchDiagnosisId],input[id$=mphospitalname],input[id$=psibfirstname],input[id$=psibfirstname2],input[id$=psiblastname],input[id$=psiblastname2],input[id$=psibage],input[id$=psibage2],select[id$=frm\\:diagnosisMonth],select[id$=frm\\:diagnosisYear],select[id$=urgency]").each(function() {
                $(this).rules("remove")
            }), resetSelect(["[id$=aware-of-referral],[id$=wcage],[id$=wcreceivedwish],[id$=plang],[id$=plang2],[id$=nSib],[id$=nSib2],[id$=urgency],[id$=p-r2c-1],[id$=p-r2c-2],[id$=p-state],[id$=p-state2],[id$=diagnosisMonth],[id$=diagnosisYear]"]), $(".sibInfo").css("display", "none"), $("[id$=aware-of-referral]").parent().parent().css("display", "block"), $("[id$=aware-of-referral]").prop("selectedIndex", 0);
            const e = $("[id$=p-state],[id$=p-state2]").parents().parents();
            $(e).removeClass("has-error").children(".col-md-3").children("label").css("color", ""), $(e).children(".col-md-6").children(".chosen-container-single").children(".chosen-single").css("border", ""), $(e).children(".col-md-6").children(".single").children(".chosen-single").css("border", ""), $(e).children(".col-md-6").children(".chosen-container-multi").children(".chosen-multi").css("border", ""), $(e).children(".col-md-6").children(".help-block").remove();
            const a = $("[id$=diagnosisMonth],[id$=diagnosisYear]").parents().parents();
            $(a).removeClass("has-error").children(".col-md-3").children("label").css("color", ""), $(a).children(".col-sm-3").css("border", ""), $(a).children(".col-sm-3").children(".help-block").remove()
        }(), $(".guardian-2").css("display"), $("[id$=wcage]").parents(".form-group").addClass("sr-only"), $(".shownOnYes").addClass("fam-aware-overlay"), $(".familyAwareError").css("display", "none"), $("[id$=wcdob]").on("keyup", function() {
            var e, a = $("[id$=wcage]"),
                i = $("[id$=wcdob]"),
                s = $("[id$=wcdob]").val(),
                r = (new Date, new Date(s), 0),
                t = $(this).val(),
                n = 0,
                l = ["m", "d", "y"],
                o = t.indexOf("m") && t.indexOf("d") && t.indexOf("y"),
                c = (e = 0, function(a, i) {
                    clearTimeout(e), e = setTimeout(a, i)
                });

            function p(e) {
                var a, i, s, t;
                i = new Date;
                var n = e.split("/"),
                    d = n[0],
                    l = n[1],
                    o = n[2];
                return d < 1 || d > 12 || l < 1 || l > 31 ? (r = 0, NaN) : l > new Date(o, d, 0).getDate() ? (r = 0, NaN) : (a = new Date(e)).getTime() > i.getTime() ? (r = 0, NaN) : (s = i.getFullYear() - a.getFullYear(), (t = i.getMonth() - a.getMonth()) < 0 && (s -= 1, t += 12), i.getDate() - a.getDate() < 0 && ((t -= 1) < 0 && (s -= 1, t += 12), new Date(a.getFullYear(), a.getMonth() + 1, 0).getDate(), a.getDate(), i.getDate()), s >= 18 ? r = 5 : s >= 13 && s < 18 ? r = 4 : s >= 2 && s < 13 ? r = s >= 3 ? 3 : t >= 6 ? 2 : 1 : 0 != s && 1 != s || (r = 1, s = 1), s)
            }
            for (; - 1 !== o;) n++, o = t.indexOf(l, o + 1);
            0 === n && function() {
                function e() {
                    $(".alertMsg").text(d), $("#warningModal").modal("show")
                }
                $(".age-text").remove(), p(s), 1 == r ? ($(a).prop("selectedIndex", 1), $('<span class="text-muted age-text">Menos de 2 1/2 años</span>').insertAfter(i), e()) : 2 == r ? ($(a).prop("selectedIndex", 2), $('<span class="text-muted age-text">2 1/2 años</span>').insertAfter(i)) : 5 == r ? ($(a).prop("selectedIndex", 18), $('<span class="text-muted age-text">Mayores de 18 años</span>').insertAfter(i), e()) : 3 != r && 4 != r || ($(a).prop("selectedIndex", 0), document.querySelectorAll('[id$="wcage"]')[0].selectedIndex = p(s), $('<span class="text-muted age-text">' + p(s) + " años</span>").insertAfter(i)), (p(s) < 0 || !p(s)) && ($(".age-text").remove(), $('<span class="text-muted age-text" style="color:red">Fecha de nacimiento no es válida</span>').insertAfter(i), c(function() {
                    $("[id$=wcdob]").val(""), $(".age-text").fadeOut(300, function() {
                        $(this).remove()
                    }), $("[id$=wcdob]").unmask(), $("[id$=wcdob]").mask("99/99/9999", {
                        placeholder: "mm/dd/yyyy"
                    }), $(a).prop("selectedIndex", 0)
                }, 1e3))
            }()
        }), $(".medprovcat-other-wrap, .other, .main-office-contact, .medical-additional-info").css("display", "none"), $(".Relchild").val(" Other"), e > -1 && ($(".referrerInfo").css("display", "block"), $(".medicalProvider,.other").css("display", "none"), -1 != e && 2 != e || (l(), o())), $("[id$=rphone],[id$=pphonenumber],[id$=pphonenumber2],[id$=mpphone]").addClass("phonechk-std"), $("[id$=remail],[id$=mpemail],[id$=pemailaddress],[id$=pemailaddress2]").addClass("email-std"), $(".other input").val(""), $(".referrerInfo,.other").css("display", "block"), $(".medicalProvider").css("display", "none"), $("[id$=aware-of-referral]").addClass("family-aware-chk"), $("[id$=r2cManualInput]").addClass("r2c-manual-input"), $("[id$=rfirstname],[id$=wcfirstname],[id$=frm\\:pfirstname],[id$=frm\\:pfirstname2]").addClass("firstname"), $("[id$=rlastname],[id$=frm\\:plastname],[id$=frm\\:plastname2],[id$=wclastname]").addClass("lastname"), $("[id$=rphone]").hasClass("phonechk-std") && ($("[id$=rphone]").removeClass("phonechk-std"), $("[id$=rphone]").addClass("phonechk")), $("[id$=remail]").hasClass("email-std") && ($("[id$=remail]").removeClass("email-std"), $("[id$=remail]").addClass("email")), $("[id$=rcity]").addClass("city"), $("[id$=rpostalcode]").addClass("postalcode"), $("[id$=urgency]").addClass("urgency"), formValidationRules(), $("[id$=searchDiagnosisId]").addClass("pdiagnosis"), $("[id$=wcage]").parents(".form-group").removeClass("sr-only"), $(".repeatMedProf").css("display", "none"), l(), o()
    }), $(".childAge").on("change", function() {
        var e = $("age-text").text();
        "Under 2.5" != $(this).val() && "18 & Above" != $(this).val() || ($(".alertMsg").text(d), $("#warningModal").modal("show")), $("select.childAge").val() != e && ($("[id$=wcdob]").val(""), $(".age-text").fadeOut(300, function() {
                $(this).remove()
            }), $("[id$=wcdob]").unmask(), $("[id$=wcdob]").mask("99/99/9999", {
                placeholder: "mm/dd/yyyy"
            })),
            function() {
                var e = $(".childAge").val();
                $.inArray(e, n)
            }()
    })
}

function PrimaryDiagnosis() {
    var e, a = $("[id$=searchDiagnosisId]"),
        i = $("[id$=diagnosisTextId]");

    function s() {
        a.css("border", "").removeAttr("aria-required aria-describedby"), a.parents().removeClass("has-error"), a.parents(".primaryDiagnosis").children(".col-sm-3").children("label").css("color", ""), a.next(".error").remove()
    }
    i.autocomplete({
        minLength: 2,
        source: function(a, i) {
            e = a.term, WishReferralForm_AC.searchDiagnosis(a.term, function(e, a) {
                "exception" == a.type ? alert(a.message) : i(e)
            })
        },
        response: function(e, a) {
            a.content.push({
                label: "Please select a ICD code below",
                value: ""
            })
        },
        select: function(e, r) {
            var t = r.item.Condition_Description__c;
            if (a.val(""), a.prop("disabled", !0), i.addClass("value-selected"), a.addClass("value-selected"), i.val(r.item.Name), $("[id$=shortTextId]").html("Description: " + r.item.Short_Description__c).text(), $(".primary-diagnosis-other").prop("hidden", !0), $(".primary-diagnosis-other").find("textarea").val(""), s(), void 0 !== t) {
                a.val(r.item.Condition_Description__r.Name);
                var n = $(".searchDiagnosisId").html(r.item.Condition_Description__r.Name).text();
                a.val(n), a.prop("disabled", !0), s()
            }
            return !1
        }
    }).data("ui-autocomplete")._renderItem = function(a, i) {
        var s = "<a>" + i.Name;
        return s = (s += "</a>").replace(e, "<b>" + e + "</b>"), "" == i.value ? $('<li class="ui-state-disabled option-disabled">' + i.label + "</li>").prependTo(a) : $("<li></li>").data("ui-autocomplete-item", i).append(s).appendTo(a)
    }, i.keydown(function(e) {
        if (!$(this).hasClass("value-selected") && a.hasClass("value-selected") || 9 == e.keyCode || ($(this).removeClass("value-selected"), a.removeClass("value-selected"), a.val(""), a.prop("disabled", !1), $("[id$=shortTextId]").text("")), 9 == e.keyCode && $(this).hasClass("value-selected") || "" == $(this).val()) return !0;
        9 == e.keyCode && e.preventDefault()
    }), a.keydown(function(e) {
        if (($(this).hasClass("value-selected") && 9 != e.keyCode || "" == $(this).val()) && ($(this).removeClass("value-selected"), i.removeClass("value-selected"), 0 == i.hasClass("value-selected") && (i.val(""), i.prop("disabled", !1), $("[id$=shortTextId]").text(""))), 9 == e.keyCode && $(this).hasClass("value-selected") || "" == $(this).val()) return !0;
        9 == e.keyCode && e.preventDefault()
    }), $("body").change("click", function(e) {
        if (a.hasClass("value-selected"), i.hasClass("value-selected")) {
            if (!i.hasClass("value-selected") && a.hasClass("value-selected")) return
        } else e.srcElement && e.srcElement.tagName && ("INPUT" == e.srcElement.tagName && "SELECT" == e.srcElement.tagName || (i.val(""), i.prop("disabled", !1)))
    }), a.autocomplete({
        minLength: 2,
        source: function(a, i) {
            e = a.term, WishReferralForm_AC.searchCondition(a.term, function(e, a) {
                "exception" == a.type ? alert(a.message) : i(e)
            })
        },
        response: function(e, a) {
            a.content.push({
                label: "Please select a diagnosis below",
                value: ""
            })
        },
        select: function(e, s) {
            var r = s.item.Code_To_Use__c,
                t = /^(Other )(.*)$/i.test(s.item.Name),
                n = /^(Not Listed)$/i.test(s.item.Name),
                d = $(".searchDiagnosisId").html(s.item.Name).text();
            return i.val(""), i.prop("disabled", !1), a.val(s.item.Name), a.val(d), a.addClass("value-selected"), i.focus(), void 0 !== r && (i.val(s.item.Code_To_Use__c), i.prop("disabled", !0)), t || n ? $(".primary-diagnosis-other").prop("hidden", !1) : ($(".primary-diagnosis-other").prop("hidden", !0), $(".primary-diagnosis-other").find("textarea").val("")), !1
        }
    }).data("ui-autocomplete")._renderItem = function(a, i) {
        var s = "<a>" + i.Name;
        return s = (s += "</a>").replace(e, "<b>" + e + "</b>"), "" == i.value ? $('<li class="ui-state-disabled option-disabled">' + i.label + "</li>").prependTo(a) : $("<li></li>").data("ui-autocomplete-item", i).append(s).appendTo(a)
    }
}

function formValidationRules() {
    $("select.r2c-select").each(function() {
        $(this).rules("add", {
            required: !0,
            messages: {
                required: "Por favor seleccione su relación con el niño"
            }
        })
    }), $("input.firstname").each(function() {
        $(this).rules("add", {
            required: !0,
            minlength: 2,
            maxlength: 40,
            messages: {
                required: "Por favor introduzca su nombre",
                minlength: "Su nombre debe tener más de 2 letras",
                maxlength: "Lo sentimos, ha alcanzado el máximo de caracteres permitidos"
            }
        })
    }), $("input.lastname").each(function() {
        $(this).rules("add", {
            required: !0,
            minlength: 2,
            maxlength: 40,
            messages: {
                required: "Por favor introduzca su apellido",
                minlength: "Su nombre debe tener más de 2 letras",
                maxlength: "Lo sentimos, ha alcanzado el máximo de caracteres permitidos"
            }
        })
    }), $("input.phonechk-std").each(function() {
        $(this).rules("add", {
            required: !1,
            minlength: 10,
            maxlength: 14,
            messages: {
                number: "Solo se aceptan números",
                minlength: "Por favor introduzca al menos 10 dígitos",
                maxlength: "Lo sentimos, ha alcanzado el máximo de caracteres permitidos",
                pattern: "Formato inválido"
            }
        })
    }), $("input.phonechk").each(function() {
        $(this).rules("add", {
            required: !0,
            minlength: 10,
            maxlength: 14,
            messages: {
                required: "Por favor, introduzca un número de teléfono",
                number: "Solo se aceptan números",
                minlength: "Por favor introduzca al menos 10 dígitos",
                maxlength: "Lo sentimos, ha alcanzado el máximo de caracteres permitidos",
                pattern: "Formato inválido"
            }
        })
    }), $("input.address").each(function() {
        $(this).rules("add", {
            required: !0,
            minlength: 5,
            maxlength: 40,
            messages: {
                required: "Por favor introduzca una direccion",
                minlength: "Por favor introduzca un mínimo de 5 caracteres",
                maxlength: "Lo sentimos, ha alcanzado el máximo de caracteres permitidos"
            }
        })
    }), $("select.state-chk").each(function() {
        $(this).rules("add", {
            required: !0,
            messages: {
                required: "Por favor seleccione un estado"
            }
        })
    }), $("input.city").each(function() {
        $(this).rules("add", {
            required: !0,
            minlength: 3,
            maxlength: 22,
            messages: {
                required: "Por favor, introduzca una ciudad de EE. UU",
                minlength: "Por Favor introduzca al menos 3 caracteres",
                maxlength: "Lo sentimos, ha alcanzado el máximo de caracteres permitidos"
            }
        })
    }), $("input.postalcode-std").each(function() {
        $(this).rules("add", {
            required: !1,
            digits: !0,
            minlength: 5,
            maxlength: 9,
            messages: {
                required: "Introduzca un código postal válido de EE. UU",
                digits: "Por favor solo introduzca dígitos",
                minlength: "Por favor introduzca un mínimo de 5 dígitos",
                maxlength: "Lo sentimos, ha alcanzado el máximo de caracteres permitidos"
            }
        })
    }), $("input.postalcode").each(function() {
        $(this).rules("add", {
            required: !0,
            zipcode: !0,
            minlength: 5,
            maxlength: 10,
            messages: {
                required: "Introduzca un código postal válido de EE. UU",
                minlength: "Por favor introduzca un mínimo de 5 dígitos",
                maxlength: "Lo sentimos, ha alcanzado el máximo de caracteres permitidos"
            }
        })
    }), $("input.sibage").each(function() {
        $(this).rules("add", {
            required: !0,
            digits: !0,
            minlength: 1,
            maxlength: 2,
            messages: {
                required: "Por favor introduzca la edad de este hermano/a",
                digits: "Por favor solo introduzca dígitos",
                minlength: "Por favor introduzca un mínimo de 2 dígitos",
                maxlength: "Lo sentimos, ha alcanzado el máximo de caracteres permitidos"
            }
        })
    }), $("input.r2c-radio").rules("add", {
        required: !0,
        messages: {
            required: "Por favor seleccione una opción"
        }
    }), $("select.family-aware-chk").rules("add", {
        required: !0,
        messages: {
            required: "Por favor seleccione una opción"
        }
    }), $("select.medprovider").rules("add", {
        required: !0,
        messages: {
            required: "Por favor seleccione una opción"
        }
    }), $("input.medprovcat-other").rules("add", {
        required: !0,
        messages: {
            required: "Introduzca la otra categoría de proveedor médico"
        }
    }), $("input.r2c-manual-input").rules("add", {
        required: !0,
        minlength: 3,
        maxlength: 20,
        messages: {
            required: "Por favor, introduzca su relación con el niño",
            minlength: "Por favor introduzca un mínimo de 3 caracteres",
            maxlength: "Lo sentimos, ha alcanzado el máximo de caracteres permitidos (20)"
        }
    }), $("select.wcage").rules("add", {
        required: !0,
        messages: {
            required: "Por favor seleccione la edad del niño"
        }
    }), $("select.wcgender").rules("add", {
        required: !0,
        messages: {
            required: "Se requiere el género del niño"
        }
    }), $("input.wcdob").rules("add", {
        required: !0,
        date: !0,
        messages: {
            required: "Se requiere la fecha de nacimiento del niño",
            date: "Ingrese una fecha válida en el formato correcto"
        }
    }), $("input.wcreceivedwish").rules("add", {
        required: !0,
        messages: {
            required: "Esta pregunta es obligatoria"
        }
    }), $("select.language").rules("add", {
        required: !0,
        messages: {
            required: "Por favor seleccione una lenguaje"
        }
    }), $("select.siblings-chk").rules("add", {
        required: !0,
        messages: {
            required: "Por favor seleccione el número de hermanos"
        }
    }), $("input.icd").rules("add", {
        required: !0,
        minlength: 3,
        messages: {
            required: "Por favor introduzca un código ICD",
            minlength: "Por favor introduzca un mínimo de 3 caracteres"
        }
    }), $("input.pdiagnosis").rules("add", {
        required: !0,
        minlength: 3,
        messages: {
            required: "Por favor introduzca el diagnóstico principal",
            minlength: "Por favor introduzca un mínimo de 3 caracteres"
        }
    }), $("input.facility").rules("add", {
        required: !0,
        minlength: 3,
        messages: {
            required: "Introduzca el nombre del hospital o centro de tratamiento.",
            minlength: "Por favor introduzca un mínimo de 3 caracteres"
        }
    }), $("select.urgency").rules("add", {
        required: !0,
        messages: {
            required: "Por favor seleccione una opción"
        }
    }), $("input.notqualto").rules("add", {
        notEqual: !0
    }), $("select.d-month").rules("add", {
        required: !0,
        messages: {
            required: "Por favor seleccione un mes"
        }
    }), $("select.d-year").rules("add", {
        required: !0,
        messages: {
            required: "Por favor seleccione un año"
        }
    }), $("textarea.selfdescreq").rules("add", {
        required: !0,
        messages: {
            required: "Introduzca una descripción relativa a 'Autodescripción'"
        }
    }), $(".primary-diagnosis-other textarea").rules("add", {
        required: !0,
        messages: {
            required: "Introduzca una descripción de diagnóstico principal"
        }
    })
}
$("[id$=wcdob]").removeAttr("onfocus").mask("99/99/9999", {
        placeholder: "mm/dd/yyyy"
    }), $("[id$=email],[id$=pemailaddress],[id$=pemailaddress2],[id$=mpemail]").attr("type", "email"), $(".main-office-contact").css("display", "none"), $(".r2c fieldset table tr td").children().unwrap().unwrap().unwrap().unwrap().unwrap(), $(".r2c input:first").clone().prependTo(".r2c label:first"), $(".r2c input:nth-child(3)").clone().prependTo(".r2c label:nth-child(4)"), $(".r2c input:nth-child(5)").clone().prependTo(".r2c label:nth-child(6)"), $(".r2c input:nth-child(7)").clone().prependTo(".r2c label:nth-child(8)"), $(".r2c input:nth-child(9)").clone().prependTo(".r2c label:nth-child(10)"), $(".r2c > input").remove(), $(".r2c label").addClass("col-xs-12 col-sm-6"), $(".r2c label input").attr("name", "r2c-radio"), $(".r2c-radio").click(function() {
        $(".familyAware").parent().parent().show()
    }), formLogic(), $("select").not(".state,.multi").each(function() {
        $(this).find("option:first").remove(), "j_id0:frm:diagnosisYear" == $(this).attr("id") ? $("#j_id0\\:frm\\:diagnosisYear").prepend('<option value="">Año</option>') : "j_id0:frm:diagnosisMonth" == $(this).attr("id") ? $("#j_id0\\:frm\\:diagnosisMonth").prepend('<option value="">Mes</option>') : $(this).prepend("<option selected disabled>Por favor seleccione una opción</option>")
    }), $("[id$=diagnosisMonth]").on("change", function() {
        var e = $("[id$=diagnosisYear]");
        "" != $(this).val() ? (e.addClass("d-year"), formValidationRules()) : (resetSelect(e), e.rules("remove"), e.removeAttr("aria-required aria-describedby aria-invalid").removeClass("d-year").valid())
    }), $("[id$=diagnosisYear]").on("change", function() {
        var e = $("[id$=diagnosisMonth]");
        "" != $(this).val() ? (e.addClass("d-month"), formValidationRules()) : (e.rules("remove"), e.removeAttr("aria-required aria-describedby aria-invalid").removeClass("d-month").valid())
    }), $(".numbers-only").keydown(function(e) {
        -1 !== $.inArray(e.keyCode, [46, 8, 9, 27, 13, 110]) || 65 == e.keyCode && !0 === e.ctrlKey || 67 == e.keyCode && !0 === e.ctrlKey || 88 == e.keyCode && !0 === e.ctrlKey || e.keyCode >= 35 && e.keyCode <= 39 || (e.shiftKey || e.keyCode < 48 || e.keyCode > 57) && (e.keyCode < 96 || e.keyCode > 105 || 191 == e.keyCode) && e.preventDefault()
    }), $(".alpha-only").keydown(function(e) {
        -1 !== $.inArray(e.keyCode, [46, 8, 9, 27, 13, 110, 190, 32]) || 65 === e.keyCode && (!0 === e.ctrlKey || !0 === e.metaKey) || 67 == e.keyCode && (!0 === e.ctrlKey || !0 === e.metaKey) || 88 == e.keyCode && (!0 === e.ctrlKey || !0 === e.metaKey) || e.keyCode >= 35 && e.keyCode <= 39 || e.shiftKey || (e.keyCode < 65 || e.keyCode > 90) && e.preventDefault()
    }), $(".phonemask").keydown(function(e) {
        isTextSelected(this) && $(this).val(""), 0 == $(this).val().length && 8 != e.keyCode ? $(this).val($(this).val() + "(") : 4 == $(this).val().length && 8 != e.keyCode ? $(this).val($(this).val() + ") ") : 9 == $(this).val().length && 8 != e.keyCode && $(this).val($(this).val() + "-"), ((2 == $(this).val().length || 11 == $(this).val().length) && 8 == e.keyCode || 2 == $(this).val().length && 9 == e.keyCode) && $(this).val($(this).val().substring(0, $(this).val().length - 1)), 7 == $(this).val().length && 8 == e.keyCode && $(this).val($(this).val().substring(0, $(this).val().length - 2)), 14 != $(this).val().length && 9 == e.keyCode && $(this).val("")
    }), $(".phonemask").attr("maxlength", "14"), $(".guardian-2").css("display", "block"), $(".add-guardian").parents(".connected").prop("hidden", !0), $(".add-guardian").on("click", function(e) {
        e.preventDefault(), $("input[id$=frm\\:pfirstname2],input[id$=frm\\:plastname2],input[id$=pphonenumber2],input[id$=pemailaddress2],input[id$=pcity2],input[id$=ppostalcode2],select[id$=p-state2],input[id$=paddress2],select[id$=plang2],input[id$=psibfirstname2],input[id$=psiblastname2],input[id$=psibage2]").val(""), $("[id$=p-state2]").prop("selectedIndex", 0), $(this).parents(".connected").prop("hidden", !0), $(".guardian-2").css("display", "block"), "Select an option" == $("[id$=p-state2] option:nth-child(2)").text() && $("[id$=p-state2] option:nth-child(2)").remove(), $("select[id$=p-r2c-2]").prop("selectedIndex", 0), formValidationRules()
    }), $(".remove-block").on("click", function(e) {
        e.preventDefault(), $(".add-guardian").parents(".connected").prop("hidden", !1), $(".guardian-2").css("display", "none"), $("input[id$=frm\\:pfirstname2],input[id$=frm\\:plastname2],input[id$=pphonenumber2],input[id$=pemailaddress2],input[id$=pcity2],input[id$=ppostalcode2],select[id$=p-state2],select[id$=p-r2c-2],input[id$=paddress2],select[id$=plang2],input[id$=psibfirstname2],input[id$=psiblastname2],input[id$=psibage2]").val(""), $("[id$=p-state2]").prop("selectedIndex", 0)
    }), stateFunc(), $("select.multi").chosen({
        disable_search: !0,
        placeholder_text_multiple: "Por favor seleccione todas las respuestas aplicables",
        width: "100%"
    }), $("select.multi").find("option:first").prop("disabled", !0).trigger("chosen:updated"),
    function() {
        var e = $("select.multi").chosen().data("chosen");
        if (e && e.hasOwnProperty("result_select")) {
            var a = e.result_select;
            e.result_select = function(i) {
                var s = null;
                i.metaKey = !0, i.ctrlKey = !0, s = e.result_highlight;
                var r = a.call(e, i);
                return null != s && s.addClass("result-selected"), r
            }
        }
    }(), formLogic(), PrimaryDiagnosis(), $(".submitBtn").click(function() {
        $(".searchDiagnosisId").val($(".pdiagnosis").val()), $(".diagnosisFilter").val($(".diagnosisText").val())
    }), $(".fs").hide(), jQuery.extend(jQuery.validator.messages, {
        required: "Esta pregunta es obligatoria ",
        email: "Por favor, introduzca una dirección de correo electrónico válida",
        url: "Please enter a valid URL",
        date: "Please enter a valid date",
        number: "Please enter a valid number",
        digits: "Please enter only digits"
    }), $.validator.addMethod("zipcode", function(e, a) {
        return this.optional(a) || /^\d{5}(?:-\d{4})?$/.test(e)
    }, "Introduzca un código postal válido de EE. UU"), $.validator.addMethod("laxEmail", function(e, a) {
        return this.optional(a) || /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/.test(e)
    }, "You've entered an invalid email address"), $.validator.addMethod("notEqual", function(e, a) {
        return this.optional(a) || $(".memail").val() != $(".bemail").val()
    }, "Please enter an email address different from the Treating Medical Professional's email address"), $("form[id$=frm]").validate({
        ignore: ":hidden",
        errorElement: "em",
        errorPlacement: function(e, a) {
            if (e.addClass("help-block"), a.parents(".col-sm-6,.col-sm-3").addClass("has-feedback"), "radio" === a.prop("type")) e.insertBefore(a.parents(".r2c"));
            else if (a.hasClass("c-select") && a.hasClass("multi")) {
                var i = $(a).parents(".col-sm-6").children(".multi");
                e.insertAfter(i)
            } else e.insertAfter(a)
        },
        highlight: function(e, a, i) {
            var s = $(e).parents(".col-sm-3, .col-sm-6, .col-xs-8.col-sm-4, .r2c, td, .dateInput");
            $(s).removeClass("has-success").addClass("has-error").prev("label").css("color", "red"), $(s).removeClass("has-success").addClass("has-error").parents(".sibInfo").children("span").children("span").children("label").css("color", "red"), $(s).removeClass("has-success").addClass("has-error").prev("div").children("label").css("color", "red"), $(s).removeClass("has-success").addClass("has-error").prev("div").prev("label").css("color", "red"), $(s).children(".chosen-container-single").children(".chosen-single").css("border", "1px solid red"), $(s).children("select.single").css("border", "1px solid red"), $(s).children(".chosen-container-multi").children(".chosen-multiple").css("border", "1px solid red"), $(s).children("input, select, textarea").css("border", "1px solid red"), $(s).children("label").css("border", "1px solid red")
        },
        unhighlight: function(e, a, i) {
            var s = $(e).parents(".col-sm-3, .col-sm-6, .col-xs-8.col-sm-4, .col-sm-1, .r2c, td, .dateInput");
            $(s).removeClass("has-error").prev("label").css("color", ""), $(s).removeClass("has-error").parents(".sibInfo").children("span").children("span").children("label").css("color", ""), $(s).removeClass("has-error").prev("div").children("label").css("color", ""), $(s).removeClass("has-success").addClass("has-error").prev("div").prev("label").css("color", ""), $(s).children(".chosen-container-single").children(".chosen-single").css("border", ""), $(s).children("select.single").css("border", ""), $(s).children(".chosen-container-multiple").children(".chosen-multiple").css("border", ""), $(s).children("input, select, textarea").css("border", ""), $(s).children(".help-block").remove()
        },
        submitHandler: function() {
            if (1 == $("#b98084695645e0e89ec5a2f3c41f0a2d").is(":checked") || "udh&6**33#" !== $("#2-b98084695645e0e89ec5a2f3c41f0a2d").val());
            else if ($("form[id$=frm]").valid()) return $(".submitBtn").css({
                cursor: "not-allowed",
                opacity: ".5"
            }).addClass("disabled").prop("disabled", !0), void form.submit()
        }
    }), $(".r2c").children("label").children("input").addClass("r2c-radio"), $("[id$=p-r2c-1]").addClass("r2c-select"), $("[id$=wcage]").addClass("r2c-select"), $("[id$=plang").addClass("language"), formValidationRules();