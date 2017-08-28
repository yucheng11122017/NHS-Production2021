//
//  AppConstants.m
//  NHS
//
//  Created by Mac Pro on 8/15/16.
//  Copyright © 2016 NUS. All rights reserved.
//

#import "AppConstants.h"

@implementation AppConstants


#pragma mark - UserDefaults

NSString *const kResidentAge = @"resident_age";
NSString *const kNeedSERI = @"need_seri";
NSString *const kQualifyCHAS = @"qualify_chas";
NSString *const kQualifyColonsc = @"qualify_colonsc";
NSString *const kQualifyMammo = @"qualify_mammo";
NSString *const kQualifyFIT = @"qualify_fit";
NSString *const kQualifyPapSmear = @"qualify_pap_smear";
NSString *const kQualifyFallAssess = @"qualify_fall_assess";
NSString *const kQualifyDementia = @"qualify_dementia";

NSString *const kTimestamp = @"ts";
NSString *const kLastUpdateTs = @"last_updated_ts";
NSString *const kResidentId = @"resident_id";
NSString *const kSectionName = @"section_name";
NSString *const kFieldName = @"field_name";
NSString *const kNewContent = @"new_content";
NSString *const kScreenLocation = @"screening_location";
NSString *const kResiParticulars = @"resi_particulars";




#pragma mark - Resident Particulars

NSString *const kName = @"resident_name";
NSString *const kNRIC = @"nric";
NSString *const kGender = @"gender";
NSString *const kBirthDate = @"birth_date";
NSString *const kBirthYear = @"birth_year";
NSString *const kCitizenship = @"citizenship_status";
NSString *const kReligion = @"religion";
NSString *const kReligionOthers = @"religion_others";
NSString *const kHpNumber = @"hp_number";
NSString *const kHouseNumber = @"house_number";
NSString *const kEthnicity = @"ethnicity";

NSString *const kSpokenLang = @"spoken_lang";
NSString *const kLangCanto = @"lang_canto";
NSString *const kLangEng = @"lang_english";
NSString *const kLangHindi = @"lang_hindi";
NSString *const kLangHokkien = @"lang_hokkien";
NSString *const kLangMalay = @"lang_malay";
NSString *const kLangMandarin = @"lang_mandarin";
NSString *const kLangTamil = @"lang_tamil";
NSString *const kLangTeoChew = @"lang_teochew";
NSString *const kLangOthers = @"lang_others";
NSString *const kLangOthersText  = @"lang_others_text";

NSString *const kMaritalStatus = @"marital_status";
NSString *const kHousingOwnedRented = @"housing_owned_rented";
NSString *const kHousingNumRooms = @"housing_num_rooms";
NSString *const kHighestEduLevel = @"highest_edu_level";

NSString *const kAddress = @"address";  //not for submission
NSString *const kAddressStreet = @"address_street";
NSString *const kAddressBlock = @"address_block";
NSString *const kAddressOthers = @"address_others";
NSString *const kAddressUnitNum = @"address_unit_num";
NSString *const kAddressDuration = @"address_duration";
NSString *const kAddressPostCode = @"address_postalcode";

NSString *const kIsFinal = @"is_final";

NSString *const kNeighbourhood = @"neighbourhood";
NSString *const kRemarks = @"remarks";


/* Search Bar constants
 ********************************************/
 NSString *const ViewControllerTitleKey = @"ViewControllerTitleKey";
 NSString *const SearchControllerIsActiveKey = @"SearchControllerIsActiveKey";
 NSString *const SearchBarTextKey = @"SearchBarTextKey";
 NSString *const SearchBarIsFirstResponderKey = @"SearchBarIsFirstResponderKey";


#pragma mark - Mode of Screening

NSString *const kScreenMode = @"screen_mode";
NSString *const kApptDate = @"appt_date";
NSString *const kApptTime = @"appt_time";


#pragma mark - Phlebotomy

NSString *const kWasTaken = @"was_taken";
NSString *const kFastingBloodGlucose = @"fasting_blood_glu";
NSString *const kTriglycerides = @"trigycerides";
NSString *const kLDL= @"ldl";
NSString *const kHDL= @"hdl";
NSString *const kCholesterolHdlRatio= @"cholesterol_hdl_ratio";
NSString *const kTotCholesterol= @"total_cholesterol";


#pragma mark - Profiling

NSString *const kProfilingConsent= @"consent";
NSString *const kEmployStat= @"employment_status";
NSString *const kEmployReasons= @"employment_reasons";
NSString *const kEmployOthers= @"employment_others";
NSString *const kDiscloseIncome= @"disclose_income";
NSString *const kAvgMthHouseIncome= @"avg_mth_house_income";
NSString *const kNumPplInHouse= @"num_ppl_in_house";
NSString *const kAvgIncomePerHead= @"avg_income_per_head";
NSString *const kDoesntOwnChasPioneer= @"does_not_own_chas_pioneer";
NSString *const kLowHouseIncome= @"low_house_income";
NSString *const kLowHomeValue= @"low_home_value";
NSString *const kWantChas= @"want_chas";
NSString *const kSporeanPr= @"sporean_pr";
NSString *const kAgeAbove50= @"age_above_50";
NSString *const kRelWColorectCancer= @"rel_w_colorect_cancer";
NSString *const kColonoscopy3yrs= @"colonoscopy_3_yrs";
NSString *const kWantColonoscopyRef= @"want_colonoscopy_ref";
NSString *const kFitLast12Mths= @"fit_last_2_mths";
NSString *const kColonoscopy10Yrs= @"colonoscopy_10_yrs";
NSString *const kWantFitKit= @"want_fit_kit";
NSString *const kMammo2Yrs= @"mammo_2_yrs";
NSString *const kHasChas= @"has_chas";
NSString *const kSporean= @"sporean_pr";
NSString *const kWantMammo= @"want_mammo";
NSString *const kPap3Yrs= @"pap_3_yrs";
NSString *const kEngagedSex= @"engaged_sex";
NSString *const kWantPap= @"want_pap";
NSString *const kAgeAbove65= @"aged_above_65";
NSString *const kAgeCheck = @"age_check";
NSString *const kAgeCheck2 = @"age_check2";
NSString *const kFallen12Mths= @"fallen_12_mths";
NSString *const kScaredFall= @"scared_fall";
NSString *const kFeelFall= @"feel_fall";
NSString *const kCognitiveImpair= @"cognitive_impairment";


#pragma mark - Health Assessment and Risk Stratisfaction

NSString *const kDMHasInformed= @"dm_has_informed";
NSString *const kDMCheckedBlood= @"dm_checked_blood";
NSString *const kDMSeeingDocRegularly= @"dm_seeing_doc_regularly";
NSString *const kDMCurrentlyPrescribed= @"dm_currently_prescribed";
NSString *const kDMTakingRegularly= @"dm_taking_regularly";

NSString *const kLipidHasInformed= @"lipid_has_informed";
NSString *const kLipidCheckedBlood= @"lipid_checked_blood";
NSString *const kLipidSeeingDocRegularly= @"lipid_seeing_doc_regularly";
NSString *const kLipidCurrentlyPrescribed= @"lipid_currently_prescribed";
NSString *const kLipidTakingRegularly= @"lipid_taking_regularly";

NSString *const kHTHasInformed = @"ht_has_informed";
NSString *const kHTCheckedBp = @"ht_checked_bp";
NSString *const kHTSeeingDocRegularly = @"ht_seeing_doc_regularly";
NSString *const kHTCurrentlyPrescribed = @"ht_currently_prescribed";
NSString *const kHTTakingRegularly = @"ht_taking_regularly";

NSString *const kPhqQ1 = @"phq_q1";
NSString *const kPhqQ2 = @"phq_q2";
NSString *const kPhq9Score = @"phq9_score";
NSString *const kFollowUpReq = @"follow_up_req";

NSString *const kDiabeticFriend = @"diabetic_friend";
NSString *const kDelivered4kgOrGestational = @"delivered4kg_or_gestational";
NSString *const kCardioHistory = @"cardio_history";
NSString *const kSmoke = @"smoke";


#pragma mark - Social Work

/* Current Socioeconomic Situation */
NSString *const kCopeFin = @"cope_fin";
NSString *const kWhyNotCopeFin = @"why_not_cope_fin";
NSString *const kMoreWhyNotCopeFin = @"more_why_not_cope_fin";
//NSString *const kHasChas = @"has_chas";
#warning  look into this
NSString *const kHasPgp = @"has_pgp";
NSString *const kHasMedisave = @"has_medisave";
NSString *const kHasInsure = @"has_insure";
NSString *const kHasCpfPayouts = @"has_cpf_payouts";
NSString *const kCpfAmt = @"cpf_amt";
NSString *const kChasColor= @"chas_color";
NSString *const kReceivingFinAssist = @"receiving_fin_assist";
NSString *const kFinAssistName = @"fin_assist_name";
NSString *const kFinAssistOrg = @"fin_assist_org";
NSString *const kFinAssistAmt = @"fin_assist_org";
NSString *const kFinAssistPeriod = @"fin_assist_period";
NSString *const kFinAssistEnuf = @"fin_assist_enuf";
NSString *const kFinAssistEnufWhy = @"fin_assist_enuf_why";
NSString *const kSocSvcAware = @"soc_svc_aware";

/* Current Physical Status */
NSString *const kBathe = @"bathe";
NSString *const kDress = @"dress";
NSString *const kEat = @"eat";
NSString *const kHygiene = @"hygiene";
NSString *const kToileting = @"toileting";
NSString *const kWalk = @"walk";
NSString *const kMobilityStatus = @"mobility_status";
NSString *const kMobilityEquipment = @"mobility_equipment";

/* Social Support */
NSString *const kHasCaregiver = @"has_caregiver";
NSString *const kCaregiverName = @"caregiver_name";
NSString *const kCaregiverRs = @"caregiver_rs";
NSString *const kCaregiverContactNum = @"caregiver_contact_num";
NSString *const kEContact = @"e_contact";
NSString *const kEContactName = @"e_contact_name";
NSString *const kEContactRs = @"e_contact_rs";
NSString *const kEContactNum = @"e_contact_num";
NSString *const kUCaregiver = @"u_caregiver";
NSString *const kUCareStress = @"u_care_stress";
NSString *const kCaregivingDescribe = @"caregiving_describe";
NSString *const kCaregivingAssist = @"caregiving_assist";
NSString *const kCaregivingAssistType = @"caregiving_assist_type";
NSString *const kGettingSupport = @"getting_support";
NSString *const kCareGiving = @"care_giving";
NSString *const kFood = @"food";
NSString *const kMoney = @"money";
NSString *const kOtherSupport = @"other_support";
NSString *const kOthersText = @"others_text";
NSString *const kRelativesContact = @"relatives_contact";
NSString *const kRelativesEase = @"relatives_ease";
NSString *const kRelativesClose = @"relatives_close";
NSString *const kFriendsContact = @"friends_contact";
NSString *const kFriendsEase = @"friends_ease";
NSString *const kFriendsClose = @"friends_close";
NSString *const kSocialScore = @"social_score";
NSString *const kParticipateActivities = @"participate_activities";
NSString *const kSac = @"sac";
NSString *const kFsc = @"fsc";
NSString *const kCc = @"cc";
NSString *const kRc = @"rc";
NSString *const kRo = @"ro";
NSString *const kSo = @"so";
NSString *const kOth = @"oth";
NSString *const kNa = @"na";
NSString *const kDontKnow = @"dont_know";
NSString *const kDontLike = @"dont_like";
NSString *const kMobilityIssues = @"mobility_issues";
NSString *const kWhyNotOthers = @"why_not_others";
NSString *const kWhyNoParticipate = @"why_no_participate";
NSString *const kHostOthers = @"host_others";

/* Psychological well-being*/
NSString *const kIsPsychotic = @"is_psychotic";
NSString *const kPsychoticRemarks = @"psychotic_remarks";
NSString *const kSuicideIdeas = @"suicide_ideas";
NSString *const kSuicideIdeasRemarks = @"suicide_ideas_remarks";

/* Additional Services */
NSString *const kBedbug = @"bedbug";
NSString *const kDriedScars = @"dried_scars";
NSString *const kHoardingBeh = @"hoarding_beh";
NSString *const kItchyBites = @"itchy_bites";
NSString *const kPoorHygiene = @"poor_hygiene";
NSString *const kBedbugStains = @"bedbug_stains";
NSString *const kBedbugOthers = @"bedbug_others";
NSString *const kBedbugOthersText = @"bedbug_others_text";
NSString *const kRequiresBedbug = @"requires_bedbug";
NSString *const kRequiresDecluttering = @"requires_decluttering";

/* Summary */
NSString *const kFinancial = @"financial";
NSString *const kEldercare = @"eldercare";
NSString *const kBasic = @"basic";
NSString *const kBehEmo = @"beh_emo";
NSString *const kFamMarital = @"fam_marital";
NSString *const kEmployment = @"employment";
NSString *const kLegal = @"legal";
NSString *const kOtherServices = @"other_services";
NSString *const kAccom = @"accom";
NSString *const kOtherIssues = @"other_issues";
NSString *const kProblems = @"problems";
NSString *const kCaseCat = @"case_cat";
NSString *const kSwVolName = @"sw_vol_name";
NSString *const kSwVolContactNum = @"sw_vol_contact_num";


#pragma mark - Triage

/* Clinical Results */
NSString *const kBp1Sys = @"bp1_sys";
NSString *const kBp1Dias = @"bp1_dias";
NSString *const kHeightCm = @"height_cm";
NSString *const kWeightKg = @"weight_kg";
NSString *const kBmi = @"bmi";
NSString *const kWaistCircum = @"waist_circum";
NSString *const kHipCircum = @"hip_circum";
NSString *const kWaistHipRatio = @"waist_hip_ratio";
NSString *const kCbg = @"cbg";
NSString *const kBp2Sys = @"bp2_sys";
NSString *const kBp2Dias = @"bp2_dias";
NSString *const kBp12AvgSys = @"bp12_avg_sys";
NSString *const kBp12AvgDias = @"bp12_avg_dias";
NSString *const kBp3Sys = @"bp3_sys";
NSString *const kBp3Dias = @"bp3_dias";


#pragma mark - Snellen Eye Test

NSString *const kRightEye = @"right_eye";
NSString *const kLeftEye = @"left_eye";
NSString *const kSix12 = @"six_12";
NSString *const kTunnel = @"tunnel";
NSString *const kVisitEye12Mths = @"visit_eye_12mths";


#pragma mark - Additional Services

NSString *const kAppliedChas = @"applied_chas";
NSString *const kReferColonos = @"applied_colonos";
NSString *const kReceiveFit = @"receive_fit";
NSString *const kReferMammo = @"refer_mammo";
NSString *const kReferPapSmear = @"refer_pap_smear";

#pragma mark - Doctor's consult

NSString *const kDocNotes = @"doc_notes";
NSString *const kDocName = @"doc_name";
NSString *const kDocReferred = @"doc_referred";


#pragma mark - Basic dental check-up

NSString *const kDentalUndergone = @"dental_undergone";
NSString *const kDentistReferred = @"dentist_referred";


#pragma mark - SERI Advanced Eye Screening

/* Medical History */
NSString *const kChiefComp = @"chief_comp";
NSString *const kOcuHist = @"ocu_hist";
NSString *const kHealthHist = @"health_hist";

/* Visual Acuity */
NSString *const kVaDone = @"va_done";
NSString *const kVa = @"va";
NSString *const kVaSnellenOd = @"va_snellen_od";
NSString *const kVaLogmarOd = @"va_logmar_od";
NSString *const kVaSnellenOs = @"va_snellen_os";
NSString *const kVaLogmarOs = @"va_logmar_os";
NSString *const kPinSnellenOd = @"pin_snellen_od";
NSString *const kPinLogmarOd = @"pin_logmar_od";
NSString *const kPinSnellenOs = @"pin_snellen_os";
NSString *const  kPinLogmarOs = @"pin_logmar_os";
NSString *const kNearLogmarOd = @"near_logmar_od";
NSString *const kNearNxOd = @"near_nx_od";
NSString *const kNearLogmarOs = @"near_logmar_os";
NSString *const kNearNxOs = @"near_nx_os";
NSString *const kVaComments = @"va_comments";

/* Autorefractor */
NSString *const kAutoDone = @"auto_done";
NSString *const kSpRightR1 = @"sp_right_r1";
NSString *const kSpRightR2 = @"sp_right_r2";
NSString *const kSpRightR3 = @"sp_right_r3";
NSString *const kSpRightR4 = @"sp_right_r4";
NSString *const kSpRightR5 = @"sp_right_r5";
NSString *const kCylRightR1 = @"cyl_right_r1";
NSString *const kCylRightR2 = @"cyl_right_r2";
NSString *const kCylRightR3 = @"cyl_right_r3";
NSString *const kCylRightR4 = @"cyl_right_r4";
NSString *const kCylRightR5 = @"cyl_right_r5";
NSString *const kAxisRightR1 = @"axis_right_r1";
NSString *const kAxisRightR2 = @"axis_right_r2";
NSString *const kAxisRightR3 = @"axis_right_r3";
NSString *const kAxisRightR4 = @"axis_right_r4";
NSString *const kAxisRightR5 = @"axis_right_r5";
NSString *const kKerMmRightR1 = @"ker_mm_right_r1";
NSString *const kKerMmRightR2 = @"ker_mm_right_r2";
NSString *const kKerDioRightR1 = @"ker_dio_right_r1";
NSString *const kKerDioRightR2 = @"ker_dio_right_r2";
NSString *const kKerAxRightR1 = @"ker_ax_right_r1";
NSString *const kKerAxRightR2 = @"ker_ax_right_r2";
NSString *const kSpLeftR1 = @"sp_left_r1";
NSString *const kSpLeftR2 = @"sp_left_r2";
NSString *const kSpLeftR3 = @"sp_left_r3";
NSString *const kSpLeftR4 = @"sp_left_r4";
NSString *const kSpLeftR5 = @"sp_left_r5";
NSString *const kCylLeftR1 = @"cyl_left_r1";
NSString *const kCylLeftR2 = @"cyl_left_r2";
NSString *const kCylLeftR3 = @"cyl_left_r3";
NSString *const kCylLeftR4 = @"cyl_left_r4";
NSString *const kCylLeftR5 = @"cyl_left_r5";
NSString *const kAxisLeftR1 = @"axis_left_r1";
NSString *const kAxisLeftR2 = @"axis_left_r2";
NSString *const kAxisLeftR3 = @"axis_left_r3";
NSString *const kAxisLeftR4 = @"axis_left_r4";
NSString *const kAxisLeftR5 = @"axis_left_r5";
NSString *const kKerMmLeftR1 = @"ker_mm_left_r1";
NSString *const kKerMmLeftR2 = @"ker_mm_left_r2";
NSString *const kKerDioLeftR1 = @"ker_dio_left_r1";
NSString *const kKerDioLeftR2 = @"ker_dio_left_r2";
NSString *const kKerAxLeftR1 = @"ker_ax_left_r1";
NSString *const kKerAxLeftR2 = @"ker_ax_left_r2";
NSString *const kPupilDist = @"pupil_dist";
NSString *const kAutorefractorComment = @"autorefractor_comment";

/* Intra-ocular Pressure */
NSString *const kIopDone = @"iop_done";
NSString *const kIopRight = @"iop_right";
NSString *const kIopLeft = @"iop_left";
NSString *const kIopComment = @"iop_comment";

/* Anterior Health Examination */
NSString *const kAheDone = @"ahe_done";
NSString *const kAheOd = @"ahe_od";
NSString *const kAheOdRemark = @"ahe_od_remark";
NSString *const kAheOs = @"ahe_os";
NSString *const kAheOsRemark = @"ahe_os_remark";
NSString *const kAheComment = @"ahe_comment";

/* Posterior Health Examination */
NSString *const kPheDone = @"phe_done";
NSString *const kPheFundusOd = @"phe_fundus_od";
NSString *const kPheFundusOdRemark = @"phe_fundus_od_remark";
NSString *const kPheFundusOs = @"phe_fundus_os";
NSString *const kPheFundusOsRemark = @"phe_fundus_os_remark";
NSString *const kPheComment = @"phe_comment";

/* Diagnosis and Follow-up */
NSString *const kOdNormal = @"od_normal";
NSString *const kOdRefractive = @"od_refractive";
NSString *const kOdCataract = @"od_cataract";
NSString *const kOdGlaucoma = @"od_glaucoma";
NSString *const kOdAge = @"od_age";
NSString *const kOdDiabetic = @"od_diabetic";
NSString *const kOdOthers = @"od_others";
NSString *const kDiagOdOthers = @"diag_od_others";
NSString *const kOsNormal = @"os_normal";
NSString *const kOsRefractive = @"os_refractive";
NSString *const kOsCataract = @"os_cataract";
NSString *const kOsGlaucoma = @"os_glaucoma";
NSString *const kOsAge = @"os_age";
NSString *const kOsDiabetic = @"os_diabetic";
NSString *const kOsOthers = @"os_others";
NSString *const kDiagOsOthers = @"diag_os_others";
NSString *const kFollowUp = @"follow_up";
NSString *const kEyeSpecRef = @"eye_spec_ref";
NSString *const kNonUrgentRefMths = @"non_urgent_ref_mths";
NSString *const kDiagComment = @"diag_comment";

//Just for the questions sake
NSString *const kDiagnosisOd = @"diagnosis_od";
NSString *const kDiagnosisOs = @"diagnosis_os";


#pragma mark - Fall Risk Assessment

/*
(Enable only if criteria is fulfilled in PROFILING tab)
(Fall Risk Assmt Tab does not need to be completed for final submission)"
 */

NSString *const kPsfuFRA = @"psfu";
NSString *const kBalance = @"balance";
NSString *const kGaitSpeed = @"gait_speed";
NSString *const kChairStand = @"chair_stand";
NSString *const kTotal = @"total";
NSString *const kReqFollowupFRA = @"require_followup";


#pragma mark - Geriatric Dementia Assessment

/*
(Enable only if criteria is fulfilled in PROFILING tab)
(Geriatric Dementia Tab does not need to be completed for final submission)"
 */

NSString *const kPsfuGDA = @"psfu";
NSString *const kAmtScore = @"amt_score";
NSString *const kEduStatus = @"edu_status";
NSString *const kReqFollowupGDA = @"require_followup";


#pragma mark - Health Education

/* Pre-education Knowledge Quiz */
NSString *const kEdu1 = @"edu_01";
NSString *const kEdu2 = @"edu_02";
NSString *const kEdu3 = @"edu_03";
NSString *const kEdu4 = @"edu_04";
NSString *const kEdu5 = @"edu_05";
NSString *const kEdu6 = @"edu_06";
NSString *const kEdu7 = @"edu_07";
NSString *const kEdu8 = @"edu_08";
NSString *const kEdu9 = @"edu_09";
NSString *const kEdu10 = @"edu_10";
NSString *const kEdu11 = @"edu_11";
NSString *const kEdu12 = @"edu_12";
NSString *const kEdu13 = @"edu_13";
NSString *const kEdu14 = @"edu_14";
NSString *const kEdu15 = @"edu_15";
NSString *const kEdu16 = @"edu_16";
NSString *const kEdu17 = @"edu_17";
NSString *const kEdu18 = @"edu_18";
NSString *const kEdu19 = @"edu_19";
NSString *const kEdu20 = @"edu_20";
NSString *const kEdu21 = @"edu_21";
NSString *const kEdu22 = @"edu_22";
NSString *const kEdu23 = @"edu_23";
NSString *const kEdu24 = @"edu_24";
NSString *const kEdu25 = @"edu_25";
NSString *const kPreEdScore = @"pre_ed_score";

/* Post-education Knowledge Quiz */
NSString *const kPostEdScore = @"post_ed_score";





@end
