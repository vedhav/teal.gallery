library(teal.modules.clinical)
library(teal.modules.general)
library(scda)
library(scda.2022)
library(nestcolor)

options(shiny.useragg = FALSE)

ADSL <- synthetic_cdisc_data("latest")$adsl
ADMH <- synthetic_cdisc_data("latest")$admh
ADAE <- synthetic_cdisc_data("latest")$adae
ADCM <- synthetic_cdisc_data("latest")$adcm
ADVS <- synthetic_cdisc_data("latest")$advs
ADLB <- synthetic_cdisc_data("latest")$adlb

## Modify ADCM
ADCM$CMINDC <- paste0("Indication_", as.numeric(ADCM$CMDECOD))
ADCM$CMDOSE <- 1
ADCM$CMTRT <- ADCM$CMCAT
ADCM$CMDOSU <- "U"
ADCM$CMROUTE <- "CMROUTE"
ADCM$CMDOSFRQ <- "CMDOSFRQ"
ADCM$CMASTDTM <- ADCM$ASTDTM
ADCM$CMAENDTM <- ADCM$AENDTM

formatters::var_labels(
  ADCM[c("CMINDC", "CMTRT", "ASTDY", "AENDY")]
) <- c(
  "Indication",
  "Reported Name of Drug, Med, or Therapy",
  "Study Day of Start of Medication",
  "Study Day of End of Medication"
)

## Modify ADHM
ADMH[["MHDISTAT"]] <- "ONGOING"
formatters::var_labels(ADMH[c("MHDISTAT")]) <- c("Status of Disease")

## Define variable inputs
aeterm_input <- data_extract_spec(
  dataname = "ADAE",
  select = select_spec(
    choices = variable_choices(ADAE, "AETERM"),
    selected = c("AETERM"),
    multiple = FALSE,
    fixed = FALSE
  )
)

cmtrt_input <- data_extract_spec(
  dataname = "ADCM",
  select = select_spec(
    choices = variable_choices(ADCM, "CMTRT"),
    selected = c("CMTRT"),
    multiple = FALSE,
    fixed = FALSE
  )
)

cmindc_input <- data_extract_spec(
  dataname = "ADCM",
  select = select_spec(
    choices = variable_choices(ADCM, "CMINDC"),
    selected = c("CMINDC"),
    multiple = FALSE,
    fixed = FALSE
  )
)

atirel_input <- data_extract_spec(
  dataname = "ADCM",
  select = select_spec(
    choices = variable_choices(ADCM, "ATIREL"),
    selected = c("ATIREL"),
    multiple = FALSE,
    fixed = FALSE
  )
)

cmdecod_input <- data_extract_spec(
  dataname = "ADCM",
  select = select_spec(
    choices = variable_choices(ADCM, "CMDECOD"),
    selected = c("CMDECOD"),
    multiple = FALSE,
    fixed = FALSE
  )
)

app <- init(
  data = cdisc_data(
    cdisc_dataset("ADSL", ADSL, code = "ADSL <- synthetic_cdisc_data(\"latest\")$adsl"),
    cdisc_dataset("ADAE", ADAE, code = "ADAE <- synthetic_cdisc_data(\"latest\")$adae"),
    cdisc_dataset("ADMH", ADMH, code = "ADMH <- synthetic_cdisc_data(\"latest\")$admh
      ADMH[['MHDISTAT']] <- 'ONGOING'
      formatters::var_labels(ADMH[c('MHDISTAT')]) <- c('Status of Disease')"),
    cdisc_dataset("ADCM", ADCM, code = 'ADCM <- synthetic_cdisc_data(\"latest\")$adcm
      ADCM$CMINDC <- paste0("Indication_", as.numeric(ADCM$CMDECOD))
      ADCM$CMDOSE <- 1
      ADCM$CMTRT <- ADCM$CMCAT
      ADCM$CMDOSU <- "U"
      ADCM$CMROUTE <- "CMROUTE"
      ADCM$CMDOSFRQ <- "CMDOSFRQ"
      ADCM$CMASTDTM <- ADCM$ASTDTM
      ADCM$CMAENDTM <- ADCM$AENDTM
      formatters::var_labels(
        ADCM[c("CMINDC", "CMTRT", "ASTDY", "AENDY")]) <- c(
          "Indication",
          "Reported Name of Drug, Med, or Therapy",
          "Study Day of Start of Medication",
          "Study Day of End of Medication")'),
    cdisc_dataset("ADVS", ADVS, code = "ADVS <- synthetic_cdisc_data(\"latest\")$advs"),
    cdisc_dataset("ADLB", ADLB, code = "ADLB <- synthetic_cdisc_data(\"latest\")$adlb"),
    check = TRUE
  ),
  modules = modules(
    tm_front_page(
      label = "Study Information",
      header_text = c("Info about data source" = "Random data are used that have been created with the 'scda' R package"),
      tables = list(`NEST packages used` = data.frame(Packages = c("teal.modules.general", "teal.modules.clinical", "scda", "scda.2022")))
    ),
    tm_t_pp_basic_info(
      label = "Basic info",
      dataname = "ADSL",
      patient_col = "USUBJID",
      vars = data_extract_spec(
        dataname = "ADSL",
        select = select_spec(
          choices = variable_choices(ADSL),
          selected = c("ARM", "AGE", "SEX", "COUNTRY", "RACE", "EOSSTT"),
          multiple = TRUE,
          fixed = FALSE
        )
      )
    ),
    tm_t_pp_medical_history(
      label = "Medical history",
      parentname = "ADSL",
      patient_col = "USUBJID",
      mhterm = data_extract_spec(
        dataname = "ADMH",
        select = select_spec(
          choices = variable_choices(ADMH, c("MHTERM")),
          selected = c("MHTERM"),
          multiple = FALSE,
          fixed = FALSE
        )
      ),
      mhbodsys = data_extract_spec(
        dataname = "ADMH",
        select = select_spec(
          choices = variable_choices(ADMH, "MHBODSYS"),
          selected = c("MHBODSYS"),
          multiple = FALSE,
          fixed = FALSE
        )
      ),
      mhdistat = data_extract_spec(
        dataname = "ADMH",
        select = select_spec(
          choices = variable_choices(ADMH, "MHDISTAT"),
          selected = c("MHDISTAT"),
          multiple = FALSE,
          fixed = FALSE
        )
      )
    ),
    tm_t_pp_prior_medication(
      label = "Prior medication",
      parentname = "ADSL",
      patient_col = "USUBJID",
      atirel = atirel_input,
      cmdecod = cmdecod_input,
      cmindc = cmindc_input,
      cmstdy = data_extract_spec(
        dataname = "ADCM",
        select = select_spec(
          choices = variable_choices(ADCM, "ASTDY"),
          selected = c("ASTDY"),
          multiple = FALSE,
          fixed = FALSE
        )
      )
    ),
    tm_g_pp_vitals(
      label = "Vitals",
      parentname = "ADSL",
      patient_col = "USUBJID",
      plot_height = c(600L, 200L, 2000L),
      paramcd = data_extract_spec(
        dataname = "ADVS",
        select = select_spec(
          choices = variable_choices(ADVS, "PARAMCD"),
          selected = c("PARAMCD"),
          multiple = FALSE,
          fixed = FALSE
        )
      ),
      xaxis = data_extract_spec(
        dataname = "ADVS",
        select = select_spec(
          choices = variable_choices(ADVS, "ADY"),
          selected = c("ADY"),
          multiple = FALSE,
          fixed = FALSE
        )
      ),
      aval = data_extract_spec(
        dataname = "ADVS",
        select = select_spec(
          choices = variable_choices(ADVS, "AVAL"),
          selected = c("AVAL"),
          multiple = FALSE,
          fixed = FALSE
        )
      )
    ),
    tm_g_pp_therapy(
      label = "Therapy",
      parentname = "ADSL",
      patient_col = "USUBJID",
      plot_height = c(600L, 200L, 2000L),
      atirel = atirel_input,
      cmdecod = cmdecod_input,
      cmindc = cmindc_input,
      cmdose = data_extract_spec(
        dataname = "ADCM",
        select = select_spec(
          choices = variable_choices(ADCM, "CMDOSE"),
          selected = c("CMDOSE"),
          multiple = FALSE,
          fixed = FALSE
        )
      ),
      cmtrt = cmtrt_input,
      cmdosu = data_extract_spec(
        dataname = "ADCM",
        select = select_spec(
          choices = variable_choices(ADCM, "CMDOSU"),
          selected = c("CMDOSU"),
          multiple = FALSE,
          fixed = FALSE
        )
      ),
      cmroute = data_extract_spec(
        dataname = "ADCM",
        select = select_spec(
          choices = variable_choices(ADCM, "CMROUTE"),
          selected = c("CMROUTE"),
          multiple = FALSE,
          fixed = FALSE
        )
      ),
      cmdosfrq = data_extract_spec(
        dataname = "ADCM",
        select = select_spec(
          choices = variable_choices(ADCM, "CMDOSFRQ"),
          selected = c("CMDOSFRQ"),
          multiple = FALSE,
          fixed = FALSE
        )
      ),
      cmstdy = data_extract_spec(
        dataname = "ADCM",
        select = select_spec(
          choices = variable_choices(ADCM, "ASTDY"),
          selected = c("ASTDY"),
          multiple = FALSE,
          fixed = FALSE
        )
      ),
      cmendy = data_extract_spec(
        dataname = "ADCM",
        select = select_spec(
          choices = variable_choices(ADCM, "AENDY"),
          selected = c("AENDY"),
          multiple = FALSE,
          fixed = FALSE
        )
      )
    ),
    tm_g_pp_adverse_events(
      label = "Adverse events",
      parentname = "ADSL",
      patient_col = "USUBJID",
      plot_height = c(600L, 200L, 2000L),
      aeterm = aeterm_input,
      tox_grade = data_extract_spec(
        dataname = "ADAE",
        select = select_spec(
          choices = variable_choices(ADAE, "AETOXGR"),
          selected = c("AETOXGR"),
          multiple = FALSE,
          fixed = FALSE
        )
      ),
      causality = data_extract_spec(
        dataname = "ADAE",
        select = select_spec(
          choices = variable_choices(ADAE, "AEREL"),
          selected = c("AEREL"),
          multiple = FALSE,
          fixed = FALSE
        )
      ),
      outcome = data_extract_spec(
        dataname = "ADAE",
        select = select_spec(
          choices = variable_choices(ADAE, "AEOUT"),
          selected = c("AEOUT"),
          multiple = FALSE,
          fixed = FALSE
        )
      ),
      action = data_extract_spec(
        dataname = "ADAE",
        select = select_spec(
          choices = variable_choices(ADAE, "AEACN"),
          selected = c("AEACN"),
          multiple = FALSE,
          fixed = FALSE
        )
      ),
      time = data_extract_spec(
        dataname = "ADAE",
        select = select_spec(
          choices = variable_choices(ADAE, "ASTDY"),
          selected = c("ASTDY"),
          multiple = FALSE,
          fixed = FALSE
        )
      ),
      decod = NULL
    ),
    tm_t_pp_laboratory(
      label = "Lab values",
      parentname = "ADSL",
      patient_col = "USUBJID",
      paramcd = data_extract_spec(
        dataname = "ADLB",
        select = select_spec(
          choices = variable_choices(ADLB, "PARAMCD"),
          selected = c("PARAMCD"),
          multiple = FALSE,
          fixed = FALSE
        )
      ),
      param = data_extract_spec(
        dataname = "ADLB",
        select = select_spec(
          choices = variable_choices(ADLB, "PARAM"),
          selected = c("PARAM"),
          multiple = FALSE,
          fixed = FALSE
        )
      ),
      timepoints = data_extract_spec(
        dataname = "ADLB",
        select = select_spec(
          choices = variable_choices(ADLB, "ADY"),
          selected = c("ADY"),
          multiple = FALSE,
          fixed = FALSE
        )
      ),
      anrind = data_extract_spec(
        dataname = "ADLB",
        select = select_spec(
          choices = variable_choices(ADLB, "ANRIND"),
          selected = c("ANRIND"),
          multiple = FALSE,
          fixed = FALSE
        )
      ),
      aval = data_extract_spec(
        dataname = "ADLB",
        select = select_spec(
          choices = variable_choices(ADLB, "AVAL"),
          selected = c("AVAL"),
          multiple = FALSE,
          fixed = FALSE
        )
      ),
      avalu = data_extract_spec(
        dataname = "ADLB",
        select = select_spec(
          choices = variable_choices(ADLB, "AVALU"),
          selected = c("AVALU"),
          multiple = FALSE,
          fixed = FALSE
        )
      )
    ),
    tm_g_pp_patient_timeline(
      label = "Patient timeline",
      parentname = "ADSL",
      patient_col = "USUBJID",
      plot_height = c(600L, 200L, 2000L),
      font_size = c(15L, 8L, 25L),
      cmdecod = cmdecod_input,
      aeterm = aeterm_input,
      aetime_start = data_extract_spec(
        dataname = "ADAE",
        select = select_spec(
          choices = variable_choices(ADAE, "ASTDTM"),
          selected = c("ASTDTM"),
          multiple = FALSE,
          fixed = FALSE
        )
      ),
      aetime_end = data_extract_spec(
        dataname = "ADAE",
        select = select_spec(
          choices = variable_choices(ADAE, "AENDTM"),
          selected = c("AENDTM"),
          multiple = FALSE,
          fixed = FALSE
        )
      ),
      dstime_start = data_extract_spec(
        dataname = "ADCM",
        select = select_spec(
          choices = variable_choices(ADCM, "CMASTDTM"),
          selected = c("CMASTDTM"),
          multiple = FALSE,
          fixed = FALSE
        )
      ),
      dstime_end = data_extract_spec(
        dataname = "ADCM",
        select = select_spec(
          choices = variable_choices(ADCM, "CMAENDTM"),
          selected = c("CMAENDTM"),
          multiple = FALSE,
          fixed = FALSE
        )
      ),
      aerelday_start = data_extract_spec(
        dataname = "ADAE",
        select = select_spec(
          choices = variable_choices(ADAE, "ASTDY"),
          selected = c("ASTDY"),
          multiple = FALSE,
          fixed = FALSE
        )
      ),
      aerelday_end = data_extract_spec(
        dataname = "ADAE",
        select = select_spec(
          choices = variable_choices(ADAE, "AENDY"),
          selected = c("AENDY"),
          multiple = FALSE,
          fixed = FALSE
        )
      ),
      dsrelday_start = data_extract_spec(
        dataname = "ADCM",
        select = select_spec(
          choices = variable_choices(ADCM, "ASTDY"),
          selected = c("ASTDY"),
          multiple = FALSE,
          fixed = FALSE
        )
      ),
      dsrelday_end = data_extract_spec(
        dataname = "ADCM",
        select = select_spec(
          choices = variable_choices(ADCM, "AENDY"),
          selected = c("AENDY"),
          multiple = FALSE,
          fixed = FALSE
        )
      )
    )
  ),
  header = div(
    class = "",
    style = "margin-bottom: 2px;",
    tags$h1("Example Patient Profile App", tags$span("SPA", class = "pull-right"))
  ),
  footer = tags$p(class = "text-muted", "Source: teal.gallery package")
)

shinyApp(app$ui, app$server)
