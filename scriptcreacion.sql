USE SolturaDB;
GO

-- 1) Tablas base sin dependenciaS
CREATE TABLE dbo.sol_countries (
  countryid INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
  name VARCHAR(60)	NOT NULL,
);

CREATE TABLE dbo.sol_featuretype (
  featuretypeid INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  name          VARCHAR(50)      NOT NULL,
  enabled       BIT              NOT NULL DEFAULT 1,
  description   VARCHAR(255)     NULL
);
GO

CREATE TABLE dbo.sol_log_source (
  log_sourceid    INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  name             VARCHAR(100)   NOT NULL,
  system_component VARCHAR(100)   NOT NULL
);
GO

CREATE TABLE dbo.sol_recurrencetypes (
  recurrencetypeid INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  name             VARCHAR(20)     NOT NULL
);
GO

CREATE TABLE dbo.sol_category (
  categoryid INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  name       VARCHAR(75)       NOT NULL
);
GO

CREATE TABLE dbo.sol_subsmemberstypes (
  membertype INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  name       VARCHAR(50)        NOT NULL
);
GO

CREATE TABLE dbo.sol_subscriptionstatus (
  statusid INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  name     VARCHAR(20)      NOT NULL
);
GO

CREATE TABLE dbo.sol_currencies (
  currencyid INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  name       VARCHAR(50)      NOT NULL,
  acronym    VARCHAR(15)      NOT NULL,
  country    VARCHAR(45)      NOT NULL,
  symbol     VARCHAR(5)       NOT NULL
);
GO

CREATE TABLE dbo.sol_languages (
  languageid INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  name       VARCHAR(50)      NOT NULL,
  iso_code   CHAR(3)          NOT NULL
);
GO

CREATE TABLE dbo.sol_transactiontypes (
  transactiontypeid INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  name              VARCHAR(30)      NOT NULL
);
GO

CREATE TABLE dbo.sol_transactionsubtypes (
  transactionsubtypeid INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  name                 VARCHAR(30)      NOT NULL
);
GO

CREATE TABLE dbo.sol_conditiontypes (
  conditiontypeid INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  name            VARCHAR(75)       NOT NULL,
  datatype        VARCHAR(50)       NOT NULL
);
GO

CREATE TABLE dbo.sol_servicetype (
  servicetypeid INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  name          VARCHAR(75)       NOT NULL,
  description   VARCHAR(255)      NULL,
  enabled       BIT               NOT NULL DEFAULT 1
);
GO

CREATE TABLE dbo.sol_quantitytypes (
  quantitytypeid INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  typename       VARCHAR(50)        NOT NULL,
  description    TEXT               NULL,
  iscumulative   BIT                NOT NULL DEFAULT 1
);
GO

CREATE TABLE dbo.sol_plans (
  planid       INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  name         VARCHAR(75)       NOT NULL,
  description  TEXT              NULL,
  customizable BIT               NOT NULL DEFAULT 1,
  limit_people SMALLINT          NOT NULL,
  enabled      BIT               NOT NULL DEFAULT 1,
  codigoid     INT               NOT NULL
);
GO

-- 2) Tablas con dependencias simples
CREATE TABLE dbo.sol_states (
  stateid   INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  name      VARCHAR(60)      NOT NULL,
  countryid INT              NOT NULL,
  CONSTRAINT FK_sol_states_countryid FOREIGN KEY(countryid)
    REFERENCES dbo.sol_countries(countryid)
);
GO

CREATE TABLE dbo.sol_cities (
  cityid  INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  name    VARCHAR(60)      NOT NULL,
  stateid INT              NOT NULL,
  CONSTRAINT FK_sol_cities_stateid FOREIGN KEY(stateid)
    REFERENCES dbo.sol_states(stateid)
);
GO

CREATE TABLE dbo.sol_address (
  addressid INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  line1     VARCHAR(200)      NOT NULL,
  line2     VARCHAR(200)      NULL,
  zipcode   VARCHAR(9)        NOT NULL,
  location  GEOGRAPHY         NOT NULL,
  cityid    INT               NOT NULL,
  CONSTRAINT FK_sol_address_cityid FOREIGN KEY(cityid)
    REFERENCES dbo.sol_cities(cityid)
);
GO

CREATE TABLE dbo.sol_users (
  userid    INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  username  VARCHAR(100)      NOT NULL,
  firstname VARCHAR(100)      NOT NULL,
  lastname  VARCHAR(100)      NOT NULL,
  email     VARCHAR(150)      NOT NULL,
  password  VARBINARY(250)    NOT NULL,
  isActive  TINYINT           NOT NULL DEFAULT 1,
  addressid INT               NOT NULL,
  CONSTRAINT FK_sol_users_addressid FOREIGN KEY(addressid)
    REFERENCES dbo.sol_address(addressid)
);
GO

--CREATE TABLE dbo.sol_category(dummy INT);
-- sol_category ya creada arriba
--GO

CREATE TABLE dbo.sol_providers (
  providerid           INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  brand_name           VARCHAR(100)      NOT NULL,
  legal_name           VARCHAR(150)      NOT NULL,
  legal_identification VARCHAR(50)       NOT NULL,
  enabled              BIT               NOT NULL DEFAULT 1,
  categoryId           INT               NOT NULL,
  CONSTRAINT FK_sol_providers_categoryId FOREIGN KEY(categoryId)
    REFERENCES dbo.sol_category(categoryid)
);
GO

CREATE TABLE dbo.sol_contracts (
  contractid  INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  description VARCHAR(100)      NOT NULL,
  start_date  DATE              NOT NULL,
  end_date    DATE              NOT NULL,
  enabled     BIT               NOT NULL DEFAULT 1,
  providerid  INT               NOT NULL,
  CONSTRAINT FK_sol_contracts_providerid FOREIGN KEY(providerid)
    REFERENCES dbo.sol_providers(providerid)
);
GO

CREATE TABLE dbo.api_integrations (
  id            SMALLINT       IDENTITY(1,1) NOT NULL PRIMARY KEY,
  name          VARCHAR(80)     NOT NULL,
  public_key    VARCHAR(200)    NULL,
  private_key   VARCHAR(200)    NULL,
  url           VARCHAR(200)    NOT NULL,
  creation_date DATETIME        NOT NULL,
  last_update   DATETIME        NOT NULL,
  enabled       BIT             NOT NULL DEFAULT 1,
  idProvider    INT             NOT NULL,
  CONSTRAINT FK_api_integrations_idProvider FOREIGN KEY(idProvider)
    REFERENCES dbo.sol_providers(providerid)
);
GO

CREATE TABLE dbo.sol_pay_methods (
  id               INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  name             VARCHAR(75)      NOT NULL,
  secret_key       VARBINARY(255)   NOT NULL,
  logo_icon_url    VARCHAR(200)     NULL,
  enabled          BIT              NOT NULL DEFAULT 1,
  idApiIntegration SMALLINT         NOT NULL,
  CONSTRAINT FK_sol_pay_methods_idApiIntegration FOREIGN KEY(idApiIntegration)
    REFERENCES dbo.api_integrations(id)
);
GO

CREATE TABLE dbo.sol_available_pay_methods (
  id           INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  name         VARCHAR(50)      NOT NULL,
  token        VARCHAR(255)     NOT NULL,
  exp_token    DATE             NOT NULL,
  mask_account VARCHAR(50)      NULL,
  idMethod     INT              NOT NULL,
  CONSTRAINT FK_sol_available_pay_methods_idMethod FOREIGN KEY(idMethod)
    REFERENCES dbo.sol_pay_methods(id)
);
GO

CREATE TABLE dbo.sol_paymentstatus (
  paymentstatusid INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  name            VARCHAR(50)          NOT NULL
);
GO

CREATE TABLE dbo.sol_payments (
  paymentid         INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  amount            DECIMAL(10,2)     NOT NULL,
  taxamount         DECIMAL(10,2)     NOT NULL,
  discountporcent   DECIMAL(5,2)      NOT NULL,
  realamount        DECIMAL(10,2)     NOT NULL,
  result            VARCHAR(10)       NULL,
  authcode          VARCHAR(100)      NULL,
  referencenumber   VARCHAR(100)      NULL,
  chargetoken       VARBINARY(200)    NULL,
  date              DATETIME          NOT NULL,
  checksum          VARBINARY(250)    NULL,
  statusid          INT               NOT NULL,
  paymentmethodid   INT               NOT NULL,
  availablemethodid INT               NOT NULL,
  CONSTRAINT FK_sol_payments_availablemethodid FOREIGN KEY(availablemethodid)
    REFERENCES dbo.sol_available_pay_methods(id),
  CONSTRAINT FK_sol_payments_paymentmethodid FOREIGN KEY(paymentmethodid)
    REFERENCES dbo.sol_pay_methods(id),
  CONSTRAINT FK_sol_payments_statusid FOREIGN KEY(statusid)
    REFERENCES dbo.sol_paymentstatus(paymentstatusid)
);
GO

CREATE TABLE dbo.sol_exchangerates (
  exchangerateid      INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  startdate           DATETIME         NOT NULL,
  enddate             DATETIME         NULL,
  exchangerate        DECIMAL(10,4)    NOT NULL,
  currentexchangerate BIT              NOT NULL DEFAULT 1,
  currencyidsource    INT               NOT NULL,
  currencyiddestiny   INT               NOT NULL,
  CONSTRAINT FK_sol_exchangerates_currencyidsource FOREIGN KEY(currencyidsource)
    REFERENCES dbo.sol_currencies(currencyid),
  CONSTRAINT FK_sol_exchangerates_currencyiddestiny FOREIGN KEY(currencyiddestiny)
    REFERENCES dbo.sol_currencies(currencyid)
);
GO

CREATE TABLE dbo.sol_schedules (
  scheduleid       INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  name             VARCHAR(100)     NOT NULL,
  description      TEXT             NULL,
  recurrencetypeid INT              NOT NULL,
  active           BIT              NOT NULL DEFAULT 1,
  interval         INT              NOT NULL,
  startdate        DATETIME         NOT NULL,
  endtype          VARCHAR(20)      NOT NULL CHECK(endtype IN('DATE','REPETITIONS','NEVER')),
  repetitions      INT              NULL,
  CONSTRAINT FK_sol_schedules_recurrencetypeid FOREIGN KEY(recurrencetypeid)
    REFERENCES dbo.sol_recurrencetypes(recurrencetypeid)
);
GO

CREATE TABLE dbo.sol_schedulesdetails (
  scheduledetailid INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  deleted          BIT              NOT NULL DEFAULT 1,
  basedate         DATETIME         NOT NULL,
  datepart         VARCHAR(20)      NOT NULL,
  maxdelaydays     INT              NOT NULL,
  executiontime    DATETIME         NULL,
  scheduleid       INT              NOT NULL,
  timezone         VARCHAR(50)      NOT NULL,
  CONSTRAINT FK_sol_schedulesdetails_scheduleid FOREIGN KEY(scheduleid)
    REFERENCES dbo.sol_schedules(scheduleid)
);
GO

CREATE TABLE dbo.sol_paymentschedules (
  paymentscheduleid INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  paymentid         INT              NOT NULL,
  scheduleid        INT              NOT NULL,
  nextpayment       DATETIME         NOT NULL,
  lastpayment       DATETIME         NULL,
  remainingpayments INT              NULL,
  active            BIT              NOT NULL DEFAULT 1,
  CONSTRAINT FK_sol_paymentschedules_scheduleid FOREIGN KEY(scheduleid)
    REFERENCES dbo.sol_schedules(scheduleid),
  CONSTRAINT FK_sol_paymentschedules_paymentid FOREIGN KEY(paymentid)
    REFERENCES dbo.sol_payments(paymentid)
);
GO

CREATE TABLE dbo.sol_subscriptions (
  subid      INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  startdate  DATETIME          NOT NULL,
  enddate    DATETIME          NOT NULL,
  autorenew  BIT               NOT NULL DEFAULT 1,
  statusid   INT               NOT NULL,
  scheduleid INT               NOT NULL,
  planid     INT               NOT NULL,
  userid     INT               NOT NULL,
  CONSTRAINT FK_sol_subscriptions_statusid FOREIGN KEY(statusid)
    REFERENCES dbo.sol_subscriptionstatus(statusid),
  CONSTRAINT FK_sol_subscriptions_scheduleid FOREIGN KEY(scheduleid)
    REFERENCES dbo.sol_schedules(scheduleid),
  CONSTRAINT FK_sol_subscriptions_planid FOREIGN KEY(planid)
    REFERENCES dbo.sol_plans(planid),
  CONSTRAINT FK_sol_subscriptions_userid FOREIGN KEY(userid)
    REFERENCES dbo.sol_users(userid)
);
GO

CREATE TABLE dbo.sol_subscriptionmembers (
  submembersid INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  membertype   INT               NOT NULL,
  isactive     DATETIME          NOT NULL,
  usersubid    INT               NOT NULL,
  CONSTRAINT FK_sol_subscriptionmembers_membertype FOREIGN KEY(membertype)
    REFERENCES dbo.sol_subsmemberstypes(membertype),
  CONSTRAINT FK_sol_subscriptionmembers_usersubid FOREIGN KEY(usersubid)
    REFERENCES dbo.sol_subscriptions(subid)
);
GO

CREATE TABLE dbo.sol_accesscode (
  codeid       INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  type         VARCHAR(100)     NOT NULL,
  value        VARBINARY        NOT NULL,
  isactive     BIT              NOT NULL DEFAULT 1,
  expirydate   TIMESTAMP        NOT NULL,
  submembersid INT              NOT NULL,
  CONSTRAINT FK_sol_accesscode_submembersid FOREIGN KEY(submembersid)
    REFERENCES dbo.sol_subscriptionmembers(submembersid)
);
GO

CREATE TABLE dbo.sol_price_configurations (
  price_config_id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  provider_price  DECIMAL(10,2)      NOT NULL,
  margin_type     VARCHAR(10)        NOT NULL,
  margin_value    DECIMAL(10,2)      NOT NULL,
  soltura_percent DECIMAL(5,2)       NOT NULL,
  client_percent  DECIMAL(5,2)       NOT NULL
);
GO

CREATE TABLE dbo.sol_service (
  serviceid       INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  name            VARCHAR(100)      NOT NULL,
  description     VARCHAR(100)      NOT NULL,
  dataType        VARCHAR(50)       NOT NULL,
  original_amount DECIMAL(10,2)     NOT NULL,
  sale_amount     DECIMAL(10,2)     NOT NULL,
  enabled         BIT               NOT NULL DEFAULT 1,
  contractid      INT               NOT NULL,
  currencyid      INT               NOT NULL,
  servicetypeid   INT               NOT NULL,
  price_config_id INT               NOT NULL,
  CONSTRAINT FK_sol_service_contractid       FOREIGN KEY(contractid)      REFERENCES dbo.sol_contracts(contractid),
  CONSTRAINT FK_sol_service_currencyid       FOREIGN KEY(currencyid)      REFERENCES dbo.sol_currencies(currencyid),
  CONSTRAINT FK_sol_service_servicetypeid    FOREIGN KEY(servicetypeid)   REFERENCES dbo.sol_servicetype(servicetypeid),
  CONSTRAINT FK_sol_service_priceconfig      FOREIGN KEY(price_config_id) REFERENCES dbo.sol_price_configurations(price_config_id)
);
GO

CREATE TABLE dbo.sol_conditions (
  conditionid       INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  description       VARCHAR(100)     NOT NULL,
  conditiontypeid   INT               NOT NULL,
  quantity_condition VARCHAR(100)    NOT NULL,
  discount          DECIMAL(5,2)     NOT NULL,
  amount_to_pay     DECIMAL(10,2)    NOT NULL,
  enabled           BIT              NOT NULL DEFAULT 1,
  serviceid         INT               NOT NULL,
  price_config_id   INT               NOT NULL,
  CONSTRAINT FK_sol_conditions_conditiontypeid FOREIGN KEY(conditiontypeid)
    REFERENCES dbo.sol_conditiontypes(conditiontypeid),
  CONSTRAINT FK_sol_conditions_serviceid       FOREIGN KEY(serviceid)
    REFERENCES dbo.sol_service(serviceid),
  CONSTRAINT FK_sol_conditions_priceconfig     FOREIGN KEY(price_config_id)
    REFERENCES dbo.sol_price_configurations(price_config_id)
);
GO

CREATE TABLE dbo.sol_planprices (
  planpricesid INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  amount       DECIMAL(10,2)     NOT NULL,
  postTime     DATETIME          NOT NULL,
  endDate      DATE              NOT NULL,
  [current]    BIT               NOT NULL DEFAULT 1,
  planid       INT               NOT NULL,
  CONSTRAINT FK_sol_planprices_planid FOREIGN KEY(planid)
    REFERENCES dbo.sol_plans(planid)
);
GO

CREATE TABLE dbo.sol_planfeatures (
  planfeatureid INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  value          VARCHAR(100)      NOT NULL,
  enabled        INT               NOT NULL DEFAULT 1,
  quantitytypeid INT               NOT NULL,
  serviceid      INT               NOT NULL,
  plantid        INT               NOT NULL,
  CONSTRAINT FK_sol_planfeatures_quantitytypeid FOREIGN KEY(quantitytypeid)
    REFERENCES dbo.sol_quantitytypes(quantitytypeid),
  CONSTRAINT FK_sol_planfeatures_serviceid FOREIGN KEY(serviceid)
    REFERENCES dbo.sol_service(serviceid),
  CONSTRAINT FK_sol_planfeatures_plantid FOREIGN KEY(plantid)
    REFERENCES dbo.sol_plans(planid)
);
GO

CREATE TABLE dbo.sol_featureusage (
  featureusageid     INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  quantityused       DECIMAL          NOT NULL,
  porcentageconsumed DECIMAL          NOT NULL,
  usagedate          TIMESTAMP        NULL,
  location           VARCHAR(255)     NULL,
  notes              TEXT             NULL,
  subid              INT               NOT NULL,
  submembersid       INT               NOT NULL,
  serviceid          INT               NOT NULL,
  codeid             INT               NOT NULL,
  CONSTRAINT FK_sol_featureusage_subid       FOREIGN KEY(subid)
    REFERENCES dbo.sol_subscriptions(subid),
  CONSTRAINT FK_sol_featureusage_submembersid FOREIGN KEY(submembersid)
    REFERENCES dbo.sol_subscriptionmembers(submembersid),
  CONSTRAINT FK_sol_featureusage_serviceid    FOREIGN KEY(serviceid)
    REFERENCES dbo.sol_service(serviceid),
  CONSTRAINT FK_sol_featureusage_codeid       FOREIGN KEY(codeid)
    REFERENCES dbo.sol_accesscode(codeid)
);
GO

CREATE TABLE dbo.sol_user_preferences (
  user_preferencesid INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  languageid         INT               NOT NULL,
  currencyid         INT               NOT NULL,
  userid             INT               NOT NULL,
  CONSTRAINT FK_sol_user_preferences_currencyid FOREIGN KEY(currencyid)
    REFERENCES dbo.sol_languages(languageid),
  CONSTRAINT FK_sol_user_preferences_userid FOREIGN KEY(userid)
    REFERENCES dbo.sol_users(userid)
);
GO

CREATE TABLE dbo.sol_log_severity (
  log_severityid INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  name           VARCHAR(50)       NOT NULL,
  severity_level BIT               NOT NULL DEFAULT 1
);
GO

CREATE TABLE dbo.sol_log_type (
  log_typeid INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  name       VARCHAR(100)    NOT NULL,
  description TEXT           NULL
);
GO

CREATE TABLE dbo.sol_logs (
  logid            INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  description      VARCHAR(200)     NOT NULL,
  posttime         DATETIME         NOT NULL,
  computer         VARCHAR(100)     NOT NULL,
  trace            TEXT             NULL,
  reference_id1    BIGINT           NULL,
  reference_id2    BIGINT           NULL,
  value1           VARCHAR(180)     NULL,
  value2           VARCHAR(180)     NULL,
  checksum         VARCHAR(45)      NOT NULL,
  log_typeid       INT              NOT NULL,
  log_sourceid     INT              NOT NULL,
  log_severityid   INT              NOT NULL,
  CONSTRAINT FK_sol_logs_log_typeid FOREIGN KEY(log_typeid)
    REFERENCES dbo.sol_log_type(log_typeid),
  CONSTRAINT FK_sol_logs_log_sourceid FOREIGN KEY(log_sourceid)
    REFERENCES dbo.sol_log_source(log_sourceid),
  CONSTRAINT FK_sol_logs_log_severityid FOREIGN KEY(log_severityid)
    REFERENCES dbo.sol_log_severity(log_severityid)
);
GO

CREATE TABLE dbo.sol_contact_types (
  contact_typeid INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  name           VARCHAR(50)     NOT NULL,
  description    VARCHAR(255)    NULL,
  isActive       TINYINT         NOT NULL DEFAULT 1
);
GO

CREATE TABLE dbo.sol_contact_info (
  contact_infoid INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  value          VARCHAR(255)    NOT NULL,
  notes          VARCHAR(255)    NULL,
  enabled        BIT             NOT NULL DEFAULT 1,
  userid         INT             NOT NULL,
  contact_typeid INT             NOT NULL,
  CONSTRAINT FK_sol_contact_info_userid FOREIGN KEY(userid)
    REFERENCES dbo.sol_users(userid),
  CONSTRAINT FK_sol_contact_info_contact_typeid FOREIGN KEY(contact_typeid)
    REFERENCES dbo.sol_contact_types(contact_typeid)
);
GO

CREATE TABLE dbo.sol_contact_info_providers (
  contactinfoproviderid INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  value                 VARCHAR(100)         NOT NULL,
  last_update           DATETIME             NOT NULL,
  idProvider            INT                  NOT NULL,
  idUser                INT                  NOT NULL,
  idContactType         INT                  NOT NULL,
  enabled               BIT                  NOT NULL DEFAULT 1,
  CONSTRAINT FK_sol_contact_info_providers_providerid FOREIGN KEY(idProvider)
    REFERENCES dbo.sol_providers(providerid),
  CONSTRAINT FK_sol_contact_info_providers_userid FOREIGN KEY(idUser)
    REFERENCES dbo.sol_users(userid),
  CONSTRAINT FK_sol_contact_info_providers_contact_type FOREIGN KEY(idContactType)
    REFERENCES dbo.sol_contact_types(contact_typeid)
);
GO
