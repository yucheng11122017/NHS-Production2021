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
NSString *const kQualifySeri = @"qualify_seri";
NSString *const kQualifyCHAS = @"qualify_chas";
NSString *const kQualifyColonsc = @"qualify_colonsc";
NSString *const kQualifyMammo = @"qualify_mammo";
NSString *const kQualifyFIT = @"qualify_fit";
NSString *const kQualifyPapSmear = @"qualify_pap_smear";
NSString *const kQualifyFallAssess = @"qualify_fall_assess";
NSString *const kQualifyDementia = @"qualify_dementia";
NSString *const kQualifyPhleb = @"qualify_phleb";

NSString *const kTimestamp = @"ts";
NSString *const kLastUpdateTs = @"last_updated_ts";
NSString *const kResidentId = @"resident_id";
NSString *const kSectionName = @"section_name";
NSString *const kFieldName = @"field_name";
NSString *const kNewContent = @"new_content";
NSString *const kScreenLocation = @"screening_location";
NSString *const kResiParticulars = @"resi_particulars";
NSString *const kFileType = @"file_type";

#pragma mark - Resident Particulars

NSString *const kOldRecord = @"old_record";
NSString *const kName = @"resident_name";
NSString *const kNRIC = @"nric";
NSString *const kNRIC2 = @"reenter_nric";
NSString *const kGender = @"gender";
NSString *const kBirthDate = @"birth_date";
NSString *const kBirthYear = @"birth_year";
NSString *const kAge = @"age";

NSString *const kCitizenship = @"citizenship_status";
//NSString *const kReligion = @"religion";
NSString *const kReligionOthers = @"religion_others";
NSString *const kHpNumber = @"hp_number";
NSString *const kHouseNumber = @"house_number";
NSString *const kNokName = @"nok_name";
NSString *const kNokRelationship = @"nok_relationship";
NSString *const kNokContact = @"nok_contact";

// 1700
NSString *const kNhsSerialId = @"nhs_serial_id";

NSString *const kSpokenLang = @"spoken_language";
NSString *const kBackupSpokenLang = @"backup_spoken_language";
//NSString *const kLangCanto = @"lang_canto";
//NSString *const kLangEng = @"lang_english";
//NSString *const kLangHindi = @"lang_hindi";
//NSString *const kLangHokkien = @"lang_hokkien";
//NSString *const kLangMalay = @"lang_malay";
//NSString *const kLangMandarin = @"lang_mandarin";
//NSString *const kLangTamil = @"lang_tamil";
//NSString *const kLangTeoChew = @"lang_teochew";
//NSString *const kLangOthers = @"lang_others";
//NSString *const kLangOthersText  = @"lang_others_text";

NSString *const kEthnicity = @"ethnicity";
NSString *const kWrittenLang = @"written_lang";

NSString *const kAddress = @"address";  //not for submission
NSString *const kAddressStreet = @"address_street";
NSString *const kAddressBlock = @"address_block";
NSString *const kAddressOthersBlock = @"address_others_block";
NSString *const kAddressOthersRoadName = @"address_others_road_name";

NSString *const kAddressUnitNum = @"address_unit_num";
NSString *const kAddressPostCode = @"address_postalcode";

NSString *const kNeighbourhood = @"neighbourhood";
NSString *const kScreeningLocation = @"screening_location";
NSString *const kRemarks = @"remarks";
NSString *const kPreregCompleted = @"prereg_completed";
NSString *const kIsFinal = @"is_final";
NSString *const kConsent = @"consent";

// consent_disclosure
NSString *const kLangExplainedIn = @"lang_explained_in";
NSString *const kLangExplainedInOthers = @"lang_explained_in_others";
NSString *const kConsentTakerFullName = @"consent_taker_full_name";
NSString *const kMatriculationNumber = @"matriculation_number";
NSString *const kOrganisation = @"organisation";
NSString *const kOrganisationOthers = @"organisation_others";

// consent_research
NSString *const kConsentToResearch = @"consent_research";
NSString *const kConsentRecontact = @"consent_recontact";
NSString *const kAgree6PointsImageName = @"agree_6_points_image_name";
NSString *const kConsentTakerFullName2 = @"consent_taker_full_name_2";
NSString *const kConsentSignatureImageName = @"consent_signature_image_name";
NSString *const kTranslationDone = @"translation_done";
NSString *const kWitnessTranslatorFullName = @"witness_translator_full_name";
NSString *const kWitnessTranslatorSignatureImageName = @"witness_translator_signature_image_name";
NSString *const kNhsSerialNum = @"nhs_serial_num";


NSString *const kMammogramInterest = @"mammogram_interest";
//NSString *const kHasChas = @"has_chas";       // repeated
NSString *const kDoneBefore = @"done_before";
NSString *const kWillingPay = @"willing_pay";





/* Search Bar constants
 ********************************************/
 NSString *const ViewControllerTitleKey = @"ViewControllerTitleKey";
 NSString *const SearchControllerIsActiveKey = @"SearchControllerIsActiveKey";
 NSString *const SearchBarTextKey = @"SearchBarTextKey";
 NSString *const SearchBarIsFirstResponderKey = @"SearchBarIsFirstResponderKey";

#pragma mark - Phlebotomy Eligibility Assessment

//NSString *const kWasTaken = @"was_taken";     //no longer needed
NSString *const kAge40 = @"age_40";
NSString *const kChronicCond = @"chronic_cond";
NSString *const kRegFollowup = @"reg_followup";
NSString *const kEligibleBloodTest = @"eligible_blood_test";
NSString *const kNoBloodTest = @"no_blood_test";
NSString *const kWantFreeBt = @"want_free_bt";
NSString *const kDidPhleb = @"did_phleb";
NSString *const kIsPr = @"is_pr";


#pragma mark - Phlebotomy - Results Collection
NSString *const kPhlebDone = @"phleb_done";
NSString *const kModeOfContact = @"mode_of_contact";
NSString *const kPreferredDay = @"preferred_day";
NSString *const kPreferredTime = @"preferred_time";
NSString *const kPreferredLanguage = @"preferred_language";
NSString *const kResultsCollection = @"results_collection";
NSString *const kPhlebFollowUp = @"follow_up";


#pragma mark - Phlebotomy (not in registration fields)
NSString *const kFastingBloodGlucose = @"fasting_blood_glu";
NSString *const kTriglycerides = @"triglycerides";
NSString *const kLDL= @"ldl";
NSString *const kHDL= @"hdl";
NSString *const kCholesterolHdlRatio= @"cholesterol_hdl_ratio";
NSString *const kTotCholesterol= @"total_cholesterol";

#pragma mark - Mode of Screening
NSString *const kScreenMode = @"screen_mode";
NSString *const kCentralDate = @"central_date";
NSString *const kApptDate = @"appt_date";
//NSString *const kTicketNum = @"ticket_number";
NSString *const kApptTime = @"appt_time";
NSString *const kPhlebAppt = @"phleb_appt";
NSString *const kNotes = @"notes";

#pragma mark - Profiling

/** Eligibility Assessments */
NSString *const kProfilingComments = @"comment";
NSString *const kProfilingConsent= @"consent";

NSString *const kEmployReasons= @"employment_reasons";
NSString *const kEmployOthers= @"employment_others";


NSString *const kSporeanPr= @"sporean_pr";
NSString *const kAgeAbove50= @"age_above_50";
NSString *const kRelWColorectCancer= @"rel_w_colorect_cancer";
NSString *const kColonoscopy3yrs= @"colonoscopy_3_yrs";
NSString *const kWantColonoscopyRef= @"want_colonoscopy_ref";
NSString *const kFitLast12Mths= @"fit_last_12_mths";
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
NSString *const kAgeAbove60 = @"aged_above_60";
NSString *const kAgeCheck = @"age_check";
NSString *const kAgeCheck2 = @"age_check2";
NSString *const kFallen12Mths= @"fallen_12_mths";
NSString *const kScaredFall= @"scared_fall";
NSString *const kFeelFall= @"feel_fall";
NSString *const kCognitiveImpair= @"cognitive_impairment";

/** Medical History */
//Generic variables
NSString *const kHasInformed= @"has_informed";
NSString *const kCheckedBlood= @"checked_blood";
NSString *const kCheckedBp= @"checked_bp";
NSString *const kSeeingDocRegularly= @"seeing_doc_regularly";
NSString *const kCurrentlyPrescribed= @"currently_prescribed";
NSString *const kTakingRegularly= @"taking_regularly";

/** Diabetes Mellitus */
NSString *const kDMHasInformed = @"dm_has_informed";
NSString *const kDMCheckedBlood= @"dm_checked_blood";
NSString *const kDMSeeingDocRegularly= @"dm_seeing_doc_regularly";
NSString *const kDMCurrentlyPrescribed= @"dm_currently_prescribed";
NSString *const kDMTakingRegularly= @"dm_taking_regularly";

/** Hyperlipidemia */
NSString *const kLipidHasInformed= @"lipid_has_informed";
NSString *const kLipidCheckedBlood= @"lipid_checked_blood";
NSString *const kLipidSeeingDocRegularly= @"lipid_seeing_doc_regularly";
NSString *const kLipidCurrentlyPrescribed= @"lipid_currently_prescribed";
NSString *const kLipidTakingRegularly= @"lipid_taking_regularly";

/** Stroke */
NSString *const kStrokeHasInformed= @"stroke_has_informed";
NSString *const kStrokeSeeingDocRegularly= @"stroke_seeing_doc_regularly";
NSString *const kStrokeCurrentlyPrescribed= @"stroke_currently_prescribed";

/** Hypertension */
NSString *const kHTHasInformed = @"ht_has_informed";
NSString *const kHTCheckedBp = @"ht_checked_bp";
NSString *const kHTSeeingDocRegularly = @"ht_seeing_doc_regularly";
NSString *const kHTCurrentlyPrescribed = @"ht_currently_prescribed";
NSString *const kHTTakingRegularly = @"ht_taking_regularly";

/** Other Med History */
NSString *const kTakingMeds = @"taking_meds";
NSString *const kMedConds = @"med_conds";

/** Surgery */
NSString *const kHadSurgery = @"had_surgery";

/** Healthcare Barriers */
NSString *const kGpFamDoc = @"gp_fam_doc";
NSString *const kFamMed = @"fam_med";
NSString *const kPolyclinic = @"polyclinic";
NSString *const kSocHospital = @"soc_hospital";
NSString *const kHCBRemarks = @"remarks";
NSString *const kNotSeeNeed = @"not_see_need";
NSString *const kCantMakeTime = @"cant_make_time";
NSString *const kHCBMobility = @"mobility";
NSString *const kFinancial = @"financial";
NSString *const kScaredOfDoc = @"scared_of_doc";
NSString *const kPreferTraditional = @"prefer_traditional";
NSString *const kHCBOthers = @"others";
NSString *const kAeFreq = @"ae_freq";
NSString *const kHospitalizedFreq = @"hospitalized_freq";
//NSString *const kWhyNotFollowUp = @"why_not_follow_up";
NSString *const kOtherBarrier = @"other_barrier";

/** Family History */
NSString *const kFamHighBp = @"fam_high_bp";
NSString *const kFamHighCholes = @"fam_high_choles";
NSString *const kFamChd = @"fam_chd";
NSString *const kFamStroke = @"fam_stroke";
NSString *const kFamNone = @"fam_none";

/** Risk Stratification */
NSString *const kDiabeticFriend = @"diabetic_friend";
NSString *const kDelivered4kgOrGestational = @"delivered4kg_or_gestational";
NSString *const kHeartAttack = @"heart_attack";
NSString *const kStroke = @"stroke";
NSString *const kAneurysm = @"aneurysm";
NSString *const kKidneyDisease = @"kidney_disease";
NSString *const kSmoke = @"smoke";
NSString *const kSmokeYes = @"smoke_yes";
NSString *const kSmokeNo = @"smoke_no";

/** Diet History */
NSString *const kAlcohol = @"alcohol";
NSString *const kEatHealthy = @"eat_healthy";
NSString *const kVege = @"vege";
NSString *const kFruits = @"fruits";
NSString *const kGrainsCereals = @"grains_cereals";
NSString *const kHighFats = @"high_fats";
NSString *const kProcessedFoods = @"processed_foods";

/** Exercise History */
NSString *const kDoesEngagePhysical = @"does_engage_physical";
NSString *const kEngagePhysical = @"engage_physical";
NSString *const kNoTime = @"no_time";
NSString *const kTooTired = @"too_tired";
NSString *const kTooLazy = @"too_lazy";
NSString *const kNoInterest = @"no_interest";

/** Functional Self Rated Quality of Health (EQ5D) */
NSString *const kWalking = @"walking";
NSString *const kTakingCare = @"taking_care";
NSString *const kUsualActivities = @"usual_activities";
NSString *const kPainDiscomfort = @"pain_discomfort";

/** Fall Risk Eligible */
NSString *const kUndergoneAssmt = @"undergone_assmt";
NSString *const kMobility = @"mobility";
NSString *const kNumFalls = @"num_falls";
NSString *const kAssistLevel = @"assist_level";
NSString *const kSteadiness = @"steadiness";
NSString *const kFallRiskScore = @"fall_risk_score";
NSString *const kFallRiskStatus = @"fall_risk_status";

/** Finance History */
NSString *const kEmployStat= @"employment_status";
NSString *const kOccupation = @"occupation";
NSString *const kDiscloseIncome = @"disclose_income";
NSString *const kAvgMthHouseIncome = @"avg_mth_house_income";
NSString *const kNumPplInHouse = @"num_ppl_in_house";
NSString *const kAvgIncomePerHead = @"avg_income_per_head";

/** Financial Assessment (Basic) */
NSString *const kCopeFin = @"cope_fin";
NSString *const kReceiveFinAssist = @"receive_fin_assist";
NSString *const kSeekFinAssist = @"seek_fin_assist";

/** CHAS Preliminary Eligibility Assessment */
NSString *const kBlueChas = @"blue_chas";
NSString *const kOrangeChas = @"orange_chas";
NSString *const kPgCard = @"pg_card";
NSString *const kPaCard = @"pa_card";
NSString *const kOwnsNoCard = @"owns_no_card";

NSString *const kDoesOwnChas = @"does_own_chas";
NSString *const kDoesNotOwnChasPioneer = @"does_not_own_chas_pioneer";
NSString *const kChasExpiringSoon = @"chas_expiring_soon";
NSString *const kLowHouseIncome= @"low_house_income";
NSString *const kLowHomeValue= @"low_home_value";
NSString *const kWantChas= @"want_chas";

/** Social History */
NSString *const kMaritalStatus = @"marital_status";
NSString *const kNumChildren = @"num_children";
NSString *const kReligion= @"religion";
NSString *const kHousingType = @"housing_type";
NSString *const kHousingNumRooms= @"housing_num_rooms";
NSString *const kHighestEduLevel = @"highest_edu_level";
NSString *const kAddressDuration = @"address_duration";
NSString *const kLivingArrangement = @"living_arrangement";
NSString *const kCaregiverName = @"caregiver_name";

/** Social Assessment (basic) */
NSString *const kUnderstands = @"understands";
NSString *const kCloseCare = @"close_care";
NSString *const kOpinionConfidence = @"opinion_confidence";
NSString *const kTrust = @"trust";
NSString *const kSpiritsUp = @"spirits_up";
NSString *const kFeelGood = @"feel_good";
NSString *const kConfide = @"confide";
NSString *const kDownDiscouraged = @"down_discouraged";
NSString *const kSocialAssmtScore = @"social_assmt_score";

/** Loneliness */
NSString *const kLackCompanionship = @"lack_companionship";
NSString *const kLeftOut = @"left_out";
NSString *const kIsolated = @"isolated";

/** Depression Assessment (Basic) */
NSString *const kPhqQ1 = @"phq_q1";
NSString *const kPhqQ2 = @"phq_q2";
NSString *const kPhqQ2Score = @"phq2_score";

/** Suicide Risk Assessment (Basic) */
NSString *const kProblemApproach = @"problem_approach";
NSString *const kLivingLife = @"living_life";
NSString *const kPossibleSuicide = @"possible_suicide";

#pragma mark - Geriatric Depression Assessment

//NSString *const kDidDepressAssess = @"did_depress_assess";
NSString *const kPhqQ3 = @"phq_q3";
NSString *const kPhqQ4 = @"phq_q4";
NSString *const kPhqQ5 = @"phq_q5";
NSString *const kPhqQ6 = @"phq_q6";
NSString *const kPhqQ7 = @"phq_q7";
NSString *const kPhqQ8 = @"phq_q8";
NSString *const kPhqQ9 = @"phq_q9";
NSString *const kPhq9Score = @"phq9_score";
NSString *const kDepressionSeverity = @"depression_severity";
NSString *const kQ10Response = @"q10_response";

#pragma mark - Social Work
/** Social Work (Advanced) Assessment */
NSString *const kUnderwentFin = @"underwent_fin";
NSString *const kUnderwentSoc = @"underwent_soc";
NSString *const kUnderwentPsyc = @"underwent_psyc";

/** Social Work Referrals */
NSString *const kReferredSsoNil = @"referred_sso_nil";
NSString *const kReferredSsoFinAssist = @"referred_sso_fin_assist";

NSString *const kReferredCoNil = @"referred_co_nil";
NSString *const kReferredCoDep = @"referred_co_dep";
NSString *const kReferredCoBefriend = @"referred_co_befriend";
NSString *const kReferredCoAdls = @"referred_co_adls";

NSString *const kReferredFscNil = @"referred_fsc_nil";
NSString *const kReferredFscDep =  @"referred_fsc_dep";
NSString *const kReferredFscRef = @"referred_fsc_ref";
NSString *const kReferredFscCase = @"referred_fsc_case";

/** Demographics */
NSString *const kFilename = @"file_name";

/** Current Socioeconomic Situation */

NSString *const kDescribeWork = @"describe_work";

NSString *const kWhyNotCopeFin = @"why_not_cope_fin";   //not submitted
NSString *const kMediExp = @"medi_exp";
NSString *const kHouseRent = @"house_rent";
NSString *const kDebts = @"debts";
NSString *const kDailyExpenses = @"daily_expenses";
NSString *const kOtherExpenses = @"other_expenses";

NSString *const kMoreWhyNotCopeFin = @"more_why_not_cope_fin";
NSString *const kHasPgp = @"has_pgp";
NSString *const kHasMedisave = @"has_medisave";
NSString *const kHasInsure = @"has_insure";
NSString *const kHasCpfPayouts = @"has_cpf_payouts";
NSString *const kNoneOfTheAbove = @"have_none";

NSString *const kCpfAmt = @"cpf_amt";
NSString *const kChasColor= @"chas_color";

NSString *const kFinAssistName = @"fin_assist_name";
NSString *const kFinAssistOrg = @"fin_assist_org";
NSString *const kFinAssistAmt = @"fin_assist_org";
NSString *const kFinAssistPeriod = @"fin_assist_period";
NSString *const kFinAssistEnuf = @"fin_assist_enuf";
NSString *const kFinAssistEnufWhy = @"fin_assist_enuf_why";
NSString *const kSocSvcAware = @"soc_svc_aware";

/** Current Physical Status */
NSString *const kBathe = @"bathe";
NSString *const kDress = @"dress";
NSString *const kEat = @"eat";
NSString *const kHygiene = @"hygiene";
NSString *const kToileting = @"toileting";
NSString *const kWalk = @"walk";
NSString *const kMobilityStatus = @"mobility_status";
NSString *const kMobilityEquipment = @"mobility_equipment";
NSString *const kMobilityEquipmentText = @"mobility_equipment_text";

/** Social Support */
NSString *const kHasCaregiver = @"has_caregiver";
//NSString *const kCaregiverName = @"caregiver_name";
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
NSString *const kSocialNetwork = @"social_network";
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

/** Psychological well-being*/
NSString *const kIsPsychotic = @"is_psychotic";
NSString *const kPsychoticRemarks = @"psychotic_remarks";
NSString *const kSuicideIdeas = @"suicide_ideas";
NSString *const kSuicideIdeasRemarks = @"suicide_ideas_remarks";

/** Additional Services */
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

/** Summary */
NSString *const kHCBFinancial = @"financial";
NSString *const kEldercare = @"eldercare";
NSString *const kBasic = @"basic";
NSString *const kBehEmo = @"beh_emo";
NSString *const kFamMarital = @"fam_marital";
NSString *const kEmployment = @"employment";
NSString *const kLegal = @"legal";
NSString *const kOtherServices = @"other_services";
NSString *const kAccom = @"accom";
NSString *const kOtherIssues = @"other_issues";
NSString *const kOptionNil = @"option_nil";
NSString *const kProblems = @"problems";
NSString *const kInterventions = @"interventions";
NSString *const kCommReview = @"comm_review";
NSString *const kCaseCat = @"case_cat";
NSString *const kSwVolName = @"sw_vol_name";
NSString *const kSwVolContactNum = @"sw_vol_contact_num";


#pragma mark - Triage

/** Clinical Results */
NSString *const kBp1Sys = @"bp1_sys";
NSString *const kBp1Dias = @"bp1_dias";
NSString *const kHeightCm = @"height_cm";
NSString *const kWeightKg = @"weight_kg";
NSString *const kBmi = @"bmi";
NSString *const kWaistCircum = @"waist_circum";
NSString *const kHipCircum = @"hip_circum";
NSString *const kWaistHipRatio = @"waist_hip_ratio";
NSString *const kIsDiabetic = @"is_diabetic";
NSString *const kCbg = @"cbg";
NSString *const kBp2Sys = @"bp2_sys";
NSString *const kBp2Dias = @"bp2_dias";
//NSString *const kBp12AvgSys = @"bp12_avg_sys";    //removed since build 2021
//NSString *const kBp12AvgDias = @"bp12_avg_dias";
NSString *const kBp3Sys = @"bp3_sys";
NSString *const kBp3Dias = @"bp3_dias";


#pragma mark - 4. Basic Vision
NSString *const kSpecs = @"specs";
NSString *const kRightEye = @"right_eye";
NSString *const kRightEyePlus = @"right_eye_plus";
NSString *const kLeftEye = @"left_eye";
NSString *const kLeftEyePlus = @"left_eye_plus";
NSString *const kSix12 = @"six_12";
NSString *const kTunnel = @"tunnel";
NSString *const kVisitEye12Mths = @"visit_eye_12mths";


#pragma mark - 5. Advanced Geriatrics
NSString *const kGivenReferral = @"given_referral";
NSString *const kUndergoneDementia = @"undergone_dementia";
NSString *const kAmtScore = @"amt_score";
NSString *const kEduStatus = @"edu_status";
NSString *const kDementiaStatus = @"dementia_status";
NSString *const kReqFollowupAdvGer = @"req_followup";

#pragma mark - 6. Fall Risk Assessment
NSString *const kSitStand = @"sit_stand";
NSString *const kBalance = @"balance";
NSString *const kGaitSpeed = @"gait_speed";
NSString *const kSpbbScore = @"sppb_score";
NSString *const kTimeUpGo = @"time_up_go";
NSString *const kFallRisk = @"fall_risk";
NSString *const kPhysioNotes = @"physio_notes";
NSString *const kKeyResults = @"key_results";
NSString *const kExternalRisks = @"external_risks";
NSString *const kOtherFactors = @"other_factors";
NSString *const kRecommendations = @"recommendations";

#pragma mark - Emergency Services
NSString *const kUndergoneEmerSvcs = @"undergone_emergency_services";
NSString *const kDocNotes = @"doc_notes";
NSString *const kDocName = @"doc_name";
NSString *const kDocReferred = @"doc_referred";

#pragma mark - Additional Services

NSString *const kAppliedChas = @"applied_chas";
NSString *const kReferColonos = @"refer_colonos";
NSString *const kReceiveFit = @"receive_fit";
NSString *const kReferMammo = @"refer_mammo";
NSString *const kReferPapSmear = @"refer_pap_smear";

#pragma mark - Basic dental check-up

NSString *const kDentalUndergone = @"undergone_dental";
NSString *const kUsesDentures = @"uses_dentures";
NSString *const kOralHealth = @"oral_health";
NSString *const kDentistReferred = @"dentist_referred";

#pragma mark - Hearing

NSString *const kUsesAidRight = @"uses_aid_right";
NSString *const kUsesAidLeft = @"uses_aid_left";
NSString *const kAttendedHhie =@"attended_hhie";
NSString *const kHhieResult = @"hhie_result";
NSString *const kAttendedTinnitus = @"attended_tinnitus";
NSString *const kTinnitusResult = @"tinnitus_result";
NSString *const kOtoscopyLeft = @"otoscopy_left";
NSString *const kOtoscopyRight = @"otoscopy_right";
NSString *const kAttendedAudioscope = @"attended_audioscope";
NSString *const kPractice500Hz60 = @"practice_500Hz_60";
NSString *const kAudioL500Hz25 = @"audio_L_500Hz_25";
NSString *const kAudioR500Hz25 = @"audio_R_500Hz_25";
NSString *const kAudioL1000Hz25 = @"audio_L_1000Hz_25";
NSString *const kAudioR1000Hz25 = @"audio_R_1000Hz_25";
NSString *const kAudioL2000Hz25 = @"audio_L_2000Hz_25";
NSString *const kAudioR2000Hz25 = @"audio_R_2000Hz_25";
NSString *const kAudioL4000Hz25 = @"audio_L_4000Hz_25";
NSString *const kAudioR4000Hz25 = @"audio_R_4000Hz_25";
NSString *const kAudioL500Hz40 = @"audio_L_500Hz_40";
NSString *const kAudioR500Hz40 = @"audio_R_500Hz_40";
NSString *const kAudioL1000Hz40 = @"audio_L_1000Hz_40";
NSString *const kAudioR1000Hz40 = @"audio_R_1000Hz_40";
NSString *const kAudioL2000Hz40 = @"audio_L_2000Hz_40";
NSString *const kAudioR2000Hz40 = @"audio_R_2000Hz_40";
NSString *const kAudioL4000Hz40 = @"audio_L_4000Hz_40";
NSString *const kAudioR4000Hz40 = @"audio_R_4000Hz_40";
NSString *const kApptReferred = @"appt_referred";
NSString *const kReferrerName = @"referrer_name";
NSString *const kHearingReferrerSign = @"hearing_referrer_sign";
NSString *const kAbnormalHearing = @"abnormal_hearing";
NSString *const kUpcomingAppt = @"upcoming_appt";
NSString *const kApptLocation = @"appt_location";
NSString *const kHearingFollowUp = @"follow_up";

#pragma mark - SERI Advanced Eye Screening



/** Medical History */
NSString *const kUndergoneAdvSeri = @"undergone_adv_seri";
NSString *const kChiefComp = @"chief_comp";
NSString *const kOcuHist = @"ocu_hist";
NSString *const kHealthHist = @"health_hist";
NSString *const kMedHistComments = @"med_hist_comments";

/** Visual Acuity */
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

/** Autorefractor */
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
NSString *const kAutorefractorComment  = @"autorefractor_comment";

/** Intra-ocular Pressure */
NSString *const kIopDone = @"iop_done";
NSString *const kIopRight = @"iop_right";
NSString *const kIopLeft = @"iop_left";
NSString *const kIopComment = @"iop_comment";

/** Anterior Health Examination */
NSString *const kAheDone = @"ahe_done";
NSString *const kAheOd = @"ahe_od";
NSString *const kAheOdRemark = @"ahe_od_remark";
NSString *const kAheOs = @"ahe_os";
NSString *const kAheOsRemark = @"ahe_os_remark";
NSString *const kAheComment = @"ahe_comment";

/** Posterior Health Examination */
NSString *const kPheDone = @"phe_done";
NSString *const kPheFundusOd = @"phe_fundus_od";
NSString *const kPheFundusOdRemark = @"phe_fundus_od_remark";
NSString *const kPheFundusOs = @"phe_fundus_os";
NSString *const kPheFundusOsRemark = @"phe_fundus_os_remark";
NSString *const kPheComment = @"phe_comment";

/** Diagnosis and Follow-up */
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
NSString *const kGivenVoucher = @"given_voucher";
NSString *const kGivenSmf = @"given_smf";
NSString *const kDiagComment = @"diag_comment";

//Just for the questions sake
NSString *const kDiagnosisOd = @"diagnosis_od";
NSString *const kDiagnosisOs = @"diagnosis_os";


#pragma mark - Fall Risk Assessment

/*
(Enable only if criteria is fulfilled in PROFILING tab)
(Fall Risk Assmt Tab does not need to be completed for final submission)"
 */

NSString *const kDidFallRiskAssess = @"did_fall_risk_assess";
NSString *const kPsfuFRA = @"psfu";
//NSString *const kBalance = @"balance";
//NSString *const kGaitSpeed = @"gait_speed";
NSString *const kChairStand = @"chair_stand";
NSString *const kTotal = @"total";
NSString *const kReqFollowupFRA = @"req_followup";


#pragma mark - Geriatric Dementia Assessment

/*
(Enable only if criteria is fulfilled in PROFILING tab)
(Geriatric Dementia Tab does not need to be completed for final submission)"
 */

NSString *const kPsfuGDA = @"psfu";




#pragma mark - Health Education

/** General education field for submission */
NSString *const kEdu1 = @"edu_1";
NSString *const kEdu2 = @"edu_2";
NSString *const kEdu3 = @"edu_3";
NSString *const kEdu4 = @"edu_4";
NSString *const kEdu5 = @"edu_5";
NSString *const kEdu6 = @"edu_6";
NSString *const kEdu7 = @"edu_7";
NSString *const kEdu8 = @"edu_8";
NSString *const kEdu9 = @"edu_9";
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



/** Pre-education Knowledge Quiz */
NSString *const kPreEdu1 = @"pre_edu_01";
NSString *const kPreEdu2 = @"pre_edu_02";
NSString *const kPreEdu3 = @"pre_edu_03";
NSString *const kPreEdu4 = @"pre_edu_04";
NSString *const kPreEdu5 = @"pre_edu_05";
NSString *const kPreEdu6 = @"pre_edu_06";
NSString *const kPreEdu7 = @"pre_edu_07";
NSString *const kPreEdu8 = @"pre_edu_08";
NSString *const kPreEdu9 = @"pre_edu_09";
NSString *const kPreEdu10 = @"pre_edu_10";
NSString *const kPreEdu11 = @"pre_edu_11";
NSString *const kPreEdu12 = @"pre_edu_12";
NSString *const kPreEdu13 = @"pre_edu_13";
NSString *const kPreEdu14 = @"pre_edu_14";
NSString *const kPreEdu15 = @"pre_edu_15";
NSString *const kPreEdu16 = @"pre_edu_16";
NSString *const kPreEdu17 = @"pre_edu_17";
NSString *const kPreEdu18 = @"pre_edu_18";
NSString *const kPreEdu19 = @"pre_edu_19";
NSString *const kPreEdu20 = @"pre_edu_20";
NSString *const kPreEdu21 = @"pre_edu_21";
NSString *const kPreEdu22 = @"pre_edu_22";
NSString *const kPreEdu23 = @"pre_edu_23";
NSString *const kPreEdu24 = @"pre_edu_24";
NSString *const kPreEdu25 = @"pre_edu_25";

/** Post-education Knowledge Quiz */
NSString *const kPostEdu1 = @"post_edu_01";
NSString *const kPostEdu2 = @"post_edu_02";
NSString *const kPostEdu3 = @"post_edu_03";
NSString *const kPostEdu4 = @"post_edu_04";
NSString *const kPostEdu5 = @"post_edu_05";
NSString *const kPostEdu6 = @"post_edu_06";
NSString *const kPostEdu7 = @"post_edu_07";
NSString *const kPostEdu8 = @"post_edu_08";
NSString *const kPostEdu9 = @"post_edu_09";
NSString *const kPostEdu10 = @"post_edu_10";
NSString *const kPostEdu11 = @"post_edu_11";
NSString *const kPostEdu12 = @"post_edu_12";
NSString *const kPostEdu13 = @"post_edu_13";
NSString *const kPostEdu14 = @"post_edu_14";
NSString *const kPostEdu15 = @"post_edu_15";
NSString *const kPostEdu16 = @"post_edu_16";
NSString *const kPostEdu17 = @"post_edu_17";
NSString *const kPostEdu18 = @"post_edu_18";
NSString *const kPostEdu19 = @"post_edu_19";
NSString *const kPostEdu20 = @"post_edu_20";
NSString *const kPostEdu21 = @"post_edu_21";
NSString *const kPostEdu22 = @"post_edu_22";
NSString *const kPostEdu23 = @"post_edu_23";
NSString *const kPostEdu24 = @"post_edu_24";
NSString *const kPostEdu25 = @"post_edu_25";
NSString *const kPostEdScore = @"post_ed_score";
NSString *const kDateEd = @"date_ed";

/** Post-screening Knowledge Quiz */
NSString *const kPostScreenEdu1 = @"post_screen_edu_01";
NSString *const kPostScreenEdu2 = @"post_screen_edu_02";
NSString *const kPostScreenEdu3 = @"post_screen_edu_03";
NSString *const kPostScreenEdu4 = @"post_screen_edu_04";
NSString *const kPostScreenEdu5 = @"post_screen_edu_05";
NSString *const kPostScreenEdu6 = @"post_screen_edu_06";
NSString *const kPostScreenEdu7 = @"post_screen_edu_07";
NSString *const kPostScreenEdu8 = @"post_screen_edu_08";
NSString *const kPostScreenEdu9 = @"post_screen_edu_09";
NSString *const kPostScreenEdu10 = @"post_screen_edu_10";
NSString *const kPostScreenEdu11 = @"post_screen_edu_11";
NSString *const kPostScreenEdu12 = @"post_screen_edu_12";
NSString *const kPostScreenEdu13 = @"post_screen_edu_13";
NSString *const kPostScreenEdu14 = @"post_screen_edu_14";
NSString *const kPostScreenEdu15 = @"post_screen_edu_15";
NSString *const kPostScreenEdu16 = @"post_screen_edu_16";
NSString *const kPostScreenEdu17 = @"post_screen_edu_17";
NSString *const kPostScreenEdu18 = @"post_screen_edu_18";
NSString *const kPostScreenEdu19 = @"post_screen_edu_19";
NSString *const kPostScreenEdu20 = @"post_screen_edu_20";
NSString *const kPostScreenEdu21 = @"post_screen_edu_21";
NSString *const kPostScreenEdu22 = @"post_screen_edu_22";
NSString *const kPostScreenEdu23 = @"post_screen_edu_23";
NSString *const kPostScreenEdu24 = @"post_screen_edu_24";
NSString *const kPostScreenEdu25 = @"post_screen_edu_25";

NSString *const kPostScreenEdScore = @"post_screen_ed_score";

#pragma mark - PSFU Questionnaire

/** Medical Issues */
NSString *const kFaceMedProb = @"facing_med_probs";
NSString *const kWhoFaceMedProb = @"who_face_med_prob";

NSString *const kMedResident = @"med_prob_resi";
NSString *const kMedResFamily = @"med_prob_fam";
NSString *const kMedResFlatmate = @"med_prob_fm";
NSString *const kMedResNeighbour = @"med_prob_nei";

NSString *const kFamilyName = @"fam_name";
NSString *const kFamilyAdd = @"fam_addr";
NSString *const kFamilyHp = @"fam_hp";
NSString *const kFlatmateName = @"fm_name";
NSString *const kFlatmateAdd = @"fm_addr";
NSString *const kFlatmateHp = @"fm_hp";
NSString *const kNeighbourName = @"nei_name";
NSString *const kNeighbourAdd = @"nei_addr";
NSString *const kNeighbourHp = @"nei_hp";

NSString *const kHaveHighBpChosCbg = @"bad_bp_chol_cbg";
NSString *const kHaveOtherMedIssues = @"other_med_issues";
NSString *const kHistMedIssues = @"other_med_issues_hist";
NSString *const kPsfuSeeingDoct = @"seeing_doc_now";
NSString *const kNhsfuFlag = @"flag_to_nhsfu";

/** Social Issues */
NSString *const kFaceSocialProb = @"facing_soc_probs";
NSString *const kWhoFaceSocialProb = @"who_face_social_prob";

NSString *const kSocialResident = @"soc_prob_resi";
NSString *const kSocialResFamily = @"soc_prob_fam";
NSString *const kSocialResFlatmate = @"soc_prob_fm";
NSString *const kSocialResNeighbour = @"soc_prob_nei";

//Share the same from med issues

//NSString *const kSocialFamilyName = @"fam_name";
//NSString *const kSocialFamilyAdd = @"fam_addr";
//NSString *const kSocialFamilyHp = @"fam_hp";
//NSString *const kSocialFlatmateName = @"fm_name";
//NSString *const kSocialFlatmateAdd = @"fm_addr";
//NSString *const kSocialFlatmateHp = @"fm_hp";
//NSString *const kSocialNeighbourName = @"nei_name";
//NSString *const kSocialNeighbourAdd = @"nei_addr";
//NSString *const kSocialNeighbourHp = @"nei_hp";

NSString *const kNotConnectSocWkAgency = @"not_conn";  // Q3
NSString *const kUnwillingSeekAgency = @"unwilling_to_seek_help";        // Q4
NSString *const kNhsswFlag = @"flag_to_nhssw";     //auto-check if ans 3 & 4 is yes
NSString *const kSpectrumConcerns = @"concerns";
NSString *const kNatureOfIssue = @"nature_of_issue";
NSString *const kSocIssueCaregiving = @"issue_caregiving";
NSString *const kSocIssueFinancial = @"issue_fin";
NSString *const kSocIssueOthers = @"issue_others";
NSString *const kSocIssueOthersText = @"specify_issue";

#pragma mark - Check Variables
/**     1. Triage       */
NSString *const kCheckClinicalResults = @"check_clinical_results";

/**     2. Phlebotomy       */
NSString *const kCheckPhlebResults = @"check_phlebotomy_results";
NSString *const kCheckPhleb = @"check_phlebotomy";

NSString *const kCheckScreenMode = @"check_screen_mode";
NSString *const kCheckProfiling = @"check_profiling";

/**     3a. Medical History (group)       */
NSString *const kCheckDiabetes = @"check_diabetes";
NSString *const kCheckHyperlipidemia = @"check_hyperlipidemia";
NSString *const kCheckHypertension = @"check_hypertension";
NSString *const kCheckStroke = @"check_stroke";
NSString *const kCheckMedicalHistory = @"check_medical_history";
NSString *const kCheckSurgery = @"check_surgery";
NSString *const kCheckHealthcareBarriers = @"check_healthcare_barriers";
NSString *const kCheckFamHist = @"check_fam_hist";
NSString *const kCheckRiskStratification = @"check_risk_stratification";

/**     3b. Diet & Exercise History (group)       */
NSString *const kCheckDiet = @"check_diet";
NSString *const kCheckExercise = @"check_exercise";

/**     3c. Cancer Screening Eligibility Assessment (group)       */
NSString *const kCheckFitEligible = @"check_fit_eligible";
NSString *const kCheckMammogramEligible = @"check_mammogram_eligible";
NSString *const kCheckPapSmearEligible = @"check_pap_smear_eligible";

/**     3d. Basic Geriatric (group)       */
NSString *const kCheckEq5d = @"check_eq5d";
NSString *const kCheckFallRiskEligible = @"check_fall_risk_eligible";
NSString *const kCheckGeriatricDementiaEligible = @"check_geriatric_dementia_eligible";

/**     3e. Financial History & Assessment (group)       */

NSString *const kCheckProfilingSocioecon = @"check_profiling_socioecon";
NSString *const kCheckFinAssmt = @"check_fin_assmt";
NSString *const kCheckChasPrelim = @"check_chas_prelim";

/**     3f. Social History & Assessment (group)       */
NSString *const kCheckSocialHistory = @"check_social_history";
NSString *const kCheckSocialAssmt = @"check_social_assmt";

/**     3g. Psychology History & Assessment (group)       */
NSString *const kCheckLoneliness = @"check_loneliness";
NSString *const kCheckDepression = @"check_depression";
NSString *const kCheckSuicideRisk = @"check_suicide_risk";

/**     4. Basic Vision     */
NSString *const kCheckSnellenTest = @"check_snellen_test";

/**     5. Advanced Geriatric    */
NSString *const kCheckGeriatricDementiaAssmt = @"check_geriatric_dementia_assmt";
NSString *const kCheckReferrals = @"check_referrals";

/**     6. Fall Risk Assessment    */
NSString *const kCheckPhysiotherapy = @"check_physiotherapy";

/**     7. Dental     */
NSString *const kCheckBasicDental = @"check_basic_dental";

/**     8. Hearing     */
NSString *const kCheckHearing = @"check_hearing";
NSString *const kCheckFollowUp = @"check_follow_up";

/**     9. Advanced Vision (group)     */
NSString *const kCheckSeriMedHist = @"check_seri_med_hist";
NSString *const kCheckSeriVa = @"check_seri_va";
NSString *const kCheckSeriAutorefractor = @"check_seri_autorefractor";
NSString *const kCheckSeriIop = @"check_seri_iop";
NSString *const kCheckSeriAhe = @"check_seri_ahe";
NSString *const kCheckSeriPhe = @"check_seri_phe";
NSString *const kCheckSeriDiag = @"check_seri_diag";

/**     10. Emergency Services     */
NSString *const kCheckEmergencyServices = @"check_emergency_services";

/**     11. Additional Services     */
NSString *const kCheckAddServices = @"check_add_services";

/**     12. Social Work (group)     */
NSString *const kCheckSwDepression = @"check_sw_depression";
NSString *const kCheckSwAdvAssmt = @"check_sw_adv_assmt";
NSString *const kCheckSwReferrals = @"check_sw_referrals";

/**     13. Summary & Health Education     */
    //don't need any checks for this!




/**     UNUSED!!     */
NSString *const kCheckCurrentPhyStatus = @"check_current_phy_status";
NSString *const kCheckSocialSupport = @"check_social_support";
NSString *const kCheckPsychWellbeing = @"check_psych_well_being";
NSString *const kCheckSocWorkSummary = @"check_soc_work_summary";
NSString *const kCheckAdd = @"check_add";
NSString *const kCheckFall = @"check_fall";
NSString *const kCheckDementia = @"check_dementia";
NSString *const kCheckEd = @"check_ed";
NSString *const kCheckEdPostScreen = @"check_ed_post_screen";
NSString *const kCheckHhie = @"check_hhie";
NSString *const kCheckFuncHearing = @"check_func_hearing";
NSString *const kCheckPSFUMedIssues = @"check_psfu_med";
NSString *const kCheckPSFUSocialIssues = @"check_psfu_social";
NSString *const kCheckGeno = @"check_geno";

//removed in 2019
NSString *const kCheckAdvFallRiskAssmt = @"check_adv_fall_risk_assmt";
NSString *const kCheckDocConsult = @"check_doc_consult";


@end
