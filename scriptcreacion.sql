CREATE TABLE [sol_featuretype] (
  [featuretypeid] INT,
  [name] VARCHAR(50),
  [enabled] BIT,
  [description] VARCHAR(255),
  PRIMARY KEY ([featuretypeid])
);

CREATE TABLE [sol_log_source] (
  [log_sourceid] INT,
  [name] VARCHAR(100),
  [system_component] VARCHAR(100),
  PRIMARY KEY ([log_sourceid])
);

CREATE TABLE [sol_recurrencetypes] (
  [recurrencetypeid] INT,
  [name] VARCHAR(20),
  PRIMARY KEY ([recurrencetypeid])
);

CREATE TABLE [sol_schedules] (
  [scheduleid] INT,
  [name] VARCHAR(100),
  [description] TEXT,
  [recurrencetypeid] INT,
  [active] BIT,
  [interval] INT,
  [startdate] DATETIME,
  [endtype] VARCHAR(20) NOT NULL CHECK (endtype IN ('DATE', 'REPETITIONS', 'NEVER')),
  [repetitions] INT,
  PRIMARY KEY ([scheduleid]),
  CONSTRAINT [FK_sol_schedules.recurrencetypeid]
    FOREIGN KEY ([recurrencetypeid])
      REFERENCES [sol_recurrencetypes]([recurrencetypeid])
);

CREATE TABLE [sol_category] (
  [categoryid] INT,
  [name] VARCHAR(75),
  PRIMARY KEY ([categoryid])
);

CREATE TABLE [sol_providers] (
  [providerid] INT,
  [brand_name] VARCHAR(100),
  [legal_name] VARCHAR(150),
  [legal_identification] VARCHAR(50),
  [enabled] BIT,
  [categoryId] INT,
  PRIMARY KEY ([providerid]),
  CONSTRAINT [FK_sol_providers.categoryId]
    FOREIGN KEY ([categoryId])
      REFERENCES [sol_category]([categoryid])
);

CREATE TABLE [api_integrations] (
  [id] SMALLINT,
  [name] VARCHAR(80),
  [public_key] VARCHAR(200),
  [private_key] VARCHAR(200),
  [url] VARCHAR(200),
  [creation_date] DATETIME,
  [last_update] DATETIME,
  [enabled] BIT,
  [idProvider] INT,
  PRIMARY KEY ([id]),
  CONSTRAINT [FK_api_integrations.idProvider]
    FOREIGN KEY ([idProvider])
      REFERENCES [sol_providers]([providerid])
);

CREATE TABLE [sol_pay_methods] (
  [id] INT,
  [name] VARCHAR(75),
  [secret_key] VARBINARY(255),
  [logo_icon_url] VARCHAR(200),
  [enabled] BIT,
  [idApiIntegration] SMALLINT,
  PRIMARY KEY ([id]),
  CONSTRAINT [FK_sol_pay_methods.idApiIntegration]
    FOREIGN KEY ([idApiIntegration])
      REFERENCES [api_integrations]([id])
);

CREATE TABLE [sol_available_pay_methods] (
  [id] INT,
  [name] VARCHAR(50),
  [token] VARCHAR(255),
  [exp_token] DATE,
  [mask_account] VARCHAR(50),
  [idMethod] INT,
  PRIMARY KEY ([id]),
  CONSTRAINT [FK_sol_available_pay_methods.idMethod]
    FOREIGN KEY ([idMethod])
      REFERENCES [sol_pay_methods]([id])
);

CREATE TABLE [sol_paymentstatus] (
  [paymentstatusid] INT,
  [name] VARCHAR(50),
  PRIMARY KEY ([paymentstatusid])
);

CREATE TABLE [sol_payments] (
  [paymentid] INT,
  [amount] DECIMAL(10,2),
  [taxamount] DECIMAL(10,2),
  [discountporcent] DECIMAL(5,2),
  [realamount] DECIMAL(10,2),
  [result] VARCHAR(10),
  [authcode] VARCHAR(100),
  [referencenumber] VARCHAR(100),
  [chargetoken] VARBINARY(200),
  [date] DATETIME,
  [checksum] VARBINARY(250),
  [statusid] INT,
  [paymentmethodid] INT,
  [availablemethodid] INT,
  PRIMARY KEY ([paymentid]),
  CONSTRAINT [FK_sol_payments.availablemethodid]
    FOREIGN KEY ([availablemethodid])
      REFERENCES [sol_available_pay_methods]([id]),
  CONSTRAINT [FK_sol_payments.paymentmethodid]
    FOREIGN KEY ([paymentmethodid])
      REFERENCES [sol_pay_methods]([id]),
  CONSTRAINT [FK_sol_payments.statusid]
    FOREIGN KEY ([statusid])
      REFERENCES [sol_paymentstatus]([paymentstatusid])
);

CREATE TABLE [sol_paymentschedules] (
  [paymentscheduleid] INT,
  [paymentid] INT,
  [scheduleid] INT,
  [nextpayment] DATETIME,
  [lastpayment] DATETIME,
  [remainingpayments] INT NULL,
  [active] BIT,
  PRIMARY KEY ([paymentscheduleid]),
  CONSTRAINT [FK_sol_paymentschedules.scheduleid]
    FOREIGN KEY ([scheduleid])
      REFERENCES [sol_schedules]([scheduleid]),
  CONSTRAINT [FK_sol_paymentschedules.paymentid]
    FOREIGN KEY ([paymentid])
      REFERENCES [sol_payments]([paymentid])
);

CREATE TABLE [sol_transactionsubtypes] (
  [transactionsubtypeid] INT,
  [name] VARCHAR(30),
  PRIMARY KEY ([transactionsubtypeid])
);

CREATE TABLE [sol_schedulesdetails] (
  [scheduledetailid] INT,
  [deleted] BIT,
  [basedate] DATETIME,
  [datepart] VARCHAR(20),
  [maxdelaydays] INT,
  [executiontime] DATETIME,
  [scheduleid] INT,
  [timezone] VARCHAR(50),
  PRIMARY KEY ([scheduledetailid]),
  CONSTRAINT [FK_sol_schedulesdetails.scheduleid]
    FOREIGN KEY ([scheduleid])
      REFERENCES [sol_schedules]([scheduleid])
);

CREATE TABLE [sol_subsmemberstypes] (
  [membertype] INT,
  [name] VARCHAR(50),
  PRIMARY KEY ([membertype])
);

CREATE TABLE [sol_subscriptionstatus] (
  [statusid] INT,
  [name] VARCHAR(20),
  PRIMARY KEY ([statusid])
);

CREATE TABLE [sol_countries] (
  [countryid] INT,
  [name] VARCHAR(60),
  PRIMARY KEY ([countryid])
);

CREATE TABLE [sol_states] (
  [stateid] INT,
  [name] VARCHAR(60),
  [countryid] INT,
  PRIMARY KEY ([stateid]),
  CONSTRAINT [FK_sol_states.countryid]
    FOREIGN KEY ([countryid])
      REFERENCES [sol_countries]([countryid])
);

CREATE TABLE [sol_cities] (
  [cityid] INT,
  [name] varchar(60),
  [stateid] INT,
  PRIMARY KEY ([cityid]),
  CONSTRAINT [FK_sol_cities.stateid]
    FOREIGN KEY ([stateid])
      REFERENCES [sol_states]([stateid])
);

CREATE TABLE [sol_address] (
  [addressid] INT,
  [line1] VARCHAR(200),
  [line2] VARCHAR(200),
  [zipcode] VARCHAR(9),
  [location] GEOGRAPHY,
  [cityid] INT,
  PRIMARY KEY ([addressid]),
  CONSTRAINT [FK_sol_address.cityid]
    FOREIGN KEY ([cityid])
      REFERENCES [sol_cities]([cityid])
);

CREATE TABLE [sol_users] (
  [userid] INT,
  [username] VARCHAR(100),
  [firstname] VARCHAR(100),
  [lastname] VARCHAR(100),
  [email] VARCHAR(150),
  [password] VARBINARY(250),
  [isActive] TINYINT,
  [addressid] INT,
  PRIMARY KEY ([userid]),
  CONSTRAINT [FK_sol_users.addressid]
    FOREIGN KEY ([addressid])
      REFERENCES [sol_address]([addressid])
);

CREATE TABLE [sol_subscriptions] (
  [subid] INT,
  [startdate] DATETIME,
  [enddate] DATETIME,
  [autorenew] BIT,
  [statusid] INT,
  [scheduleid] INT,
  [userid] INT,
  PRIMARY KEY ([subid]),
  CONSTRAINT [FK_sol_subscriptions.scheduleid]
    FOREIGN KEY ([scheduleid])
      REFERENCES [sol_schedules]([scheduleid]),
  CONSTRAINT [FK_sol_subscriptions.statusid]
    FOREIGN KEY ([statusid])
      REFERENCES [sol_subscriptionstatus]([statusid]),
  CONSTRAINT [FK_sol_subscriptions.userid]
    FOREIGN KEY ([userid])
      REFERENCES [sol_users]([userid])
);

CREATE TABLE [sol_subscriptionmembers] (
  [submembersid] INT,
  [membertype] INT,
  [isactive] DATETIME,
  [usersubid] INT,
  PRIMARY KEY ([submembersid]),
  CONSTRAINT [FK_sol_subscriptionmembers.membertype]
    FOREIGN KEY ([membertype])
      REFERENCES [sol_subsmemberstypes]([membertype]),
  CONSTRAINT [FK_sol_subscriptionmembers.usersubid]
    FOREIGN KEY ([usersubid])
      REFERENCES [sol_subscriptions]([subid])
);

CREATE TABLE [sol_servicetype] (
  [servicetypeid] INT,
  [name] VARCHAR(75),
  PRIMARY KEY ([servicetypeid])
);

CREATE TABLE [sol_contracts] (
  [contractid] INT,
  [description] VARCHAR(100),
  [start_date] DATE,
  [end_date] DATE,
  [enabled] BIT,
  [providerid] INT,
  PRIMARY KEY ([contractid]),
  CONSTRAINT [FK_sol_contracts.providerid]
    FOREIGN KEY ([providerid])
      REFERENCES [sol_providers]([providerid])
);

CREATE TABLE [sol_service] (
  [serviceid] INT,
  [description] VARCHAR(100),
  [original_amount] DECIMAL(10,2),
  [sale_amount] DECIMAL(10,2),
  [enabled] BIT,
  [contractid] INT,
  [currencyid] INT,
  [servicetypeid] INT,
  PRIMARY KEY ([serviceid]),
  CONSTRAINT [FK_sol_service.servicetypeid]
    FOREIGN KEY ([servicetypeid])
      REFERENCES [sol_servicetype]([servicetypeid]),
  CONSTRAINT [FK_sol_service.contractid]
    FOREIGN KEY ([contractid])
      REFERENCES [sol_contracts]([contractid])
);

CREATE TABLE [sol_conditiontypes] (
  [conditiontypeid] INT,
  [name] VARCHAR(75),
  [datatype] VARCHAR(50),
  PRIMARY KEY ([conditiontypeid])
);

CREATE TABLE [sol_conditions] (
  [conditionid] INT,
  [description] VARCHAR(100),
  [conditiontypeid] INT,
  [quantity_condition] VARCHAR(100),
  [discount] DECIMAL(5,2),
  [amount_to_pay] DECIMAL(10,2),
  [enabled] BIT,
  [serviceid] INT,
  PRIMARY KEY ([conditionid]),
  CONSTRAINT [FK_sol_conditions.serviceid]
    FOREIGN KEY ([serviceid])
      REFERENCES [sol_service]([serviceid]),
  CONSTRAINT [FK_sol_conditions.conditiontypeid]
    FOREIGN KEY ([conditiontypeid])
      REFERENCES [sol_conditiontypes]([conditiontypeid])
);

CREATE TABLE [sol_currencies] (
  [currencyid] INT,
  [name] VARCHAR(50),
  [acronym] VARCHAR(15),
  [country] VARCHAR(45),
  [symbol] VARCHAR(5),
  PRIMARY KEY ([currencyid])
);

CREATE TABLE [sol_exchangerates] (
  [exchangerateid] INT,
  [startdate] DATETIME,
  [enddate] DATETIME,
  [exchangerate] DECIMAL(10,4),
  [currentexchangerate] BIT,
  [currencyidsource FK] INT,
  [currencyiddestiny FK] INT,
  PRIMARY KEY ([exchangerateid]),
  CONSTRAINT [FK_sol_exchangerates.currencyidsource FK]
    FOREIGN KEY ([currencyidsource FK])
      REFERENCES [sol_currencies]([currencyid]),
  CONSTRAINT [FK_sol_exchangerates.currencyiddestiny FK]
    FOREIGN KEY ([currencyiddestiny FK])
      REFERENCES [sol_currencies]([currencyid])
);

CREATE TABLE [sol_transactiontypes] (
  [transactiontypeid] INT,
  [name] VARCHAR(30),
  PRIMARY KEY ([transactiontypeid])
);

CREATE TABLE [sol_transactions] (
  [transactionid] INT,
  [name] VARCHAR(75),
  [description] TEXT,
  [amount] DECIMAL(10,4),
  [referencenumber] VARCHAR(100),
  [transactiondate] DATETIME,
  [officetime] DATETIME,
  [checksum] VARBINARY(250),
  [transactiontypeid] INT,
  [transactionsubtypeid] INT,
  [currencyid] INT,
  [exchangerateid] INT,
  [payid] INT,
  PRIMARY KEY ([transactionid]),
  CONSTRAINT [FK_sol_transactions.transactionsubtypeid]
    FOREIGN KEY ([transactionsubtypeid])
      REFERENCES [sol_transactionsubtypes]([transactionsubtypeid]),
  CONSTRAINT [FK_sol_transactions.currencyid]
    FOREIGN KEY ([currencyid])
      REFERENCES [sol_currencies]([currencyid]),
  CONSTRAINT [FK_sol_transactions.exchangerateid]
    FOREIGN KEY ([exchangerateid])
      REFERENCES [sol_exchangerates]([exchangerateid]),
  CONSTRAINT [FK_sol_transactions.payid]
    FOREIGN KEY ([payid])
      REFERENCES [sol_payments]([paymentid]),
  CONSTRAINT [FK_sol_transactions.transactiontypeid]
    FOREIGN KEY ([transactiontypeid])
      REFERENCES [sol_transactiontypes]([transactiontypeid])
);

CREATE TABLE [sol_log_type] (
  [log_typeid] INT,
  [name] VARCHAR(100),
  [description] TEXT,
  PRIMARY KEY ([log_typeid])
);

CREATE TABLE [sol_plans] (
  [planid] INT,
  [name] VARCHAR(75),
  [description] TEXT,
  [customizable] BIT,
  [limit_people] SMALLINT,
  [enabled] BIT,
  [codigoid] INT,
  PRIMARY KEY ([planid])
);

CREATE TABLE [sol_features] (
  [featureid] INT,
  [name] VARCHAR(100),
  [description] VARCHAR(100),
  [dataType] VARCHAR(50),
  [enabled] BIT,
  [featuretypeid] INT,
  [serviceId] INT,
  PRIMARY KEY ([featureid]),
  CONSTRAINT [FK_sol_features.serviceId]
    FOREIGN KEY ([serviceId])
      REFERENCES [sol_service]([serviceid]),
  CONSTRAINT [FK_sol_features.featuretypeid]
    FOREIGN KEY ([featuretypeid])
      REFERENCES [sol_featuretype]([featuretypeid])
);

CREATE TABLE [sol_quantitytypes] (
  [quantitytypeid] INT,
  [typename] VARCHAR(50),
  [description] TEXT,
  [iscumulative] BIT,
  PRIMARY KEY ([quantitytypeid])
);

CREATE TABLE [sol_planfeatures] (
  [planfeatureid] INT,
  [value] VARCHAR(100),
  [enabled] INT,
  [quantitytypeid] INT,
  [featureid] INT,
  [plantid] INT,
  PRIMARY KEY ([planfeatureid]),
  CONSTRAINT [FK_sol_planfeatures.featureid]
    FOREIGN KEY ([featureid])
      REFERENCES [sol_features]([featureid]),
  CONSTRAINT [FK_sol_planfeatures.quantitytypeid]
    FOREIGN KEY ([quantitytypeid])
      REFERENCES [sol_quantitytypes]([quantitytypeid]),
  CONSTRAINT [FK_sol_planfeatures.plantid]
    FOREIGN KEY ([plantid])
      REFERENCES [sol_plans]([planid])
);

CREATE TABLE [sol_accesscode] (
  [codeid] INT,
  [type] VARCHAR(100),
  [value] VARBINARY,
  [isactive] BIT,
  [expirydate] TIMESTAMP,
  [submembersid] INT,
  PRIMARY KEY ([codeid]),
  CONSTRAINT [FK_sol_accesscode.submembersid]
    FOREIGN KEY ([submembersid])
      REFERENCES [sol_subscriptionmembers]([submembersid])
);

CREATE TABLE [sol_featureusage] (
  [featureusageid] INT,
  [quantityused] DECIMAL,
  [porcentageconsumed] DECIMAL,
  [usagedate] TIMESTAMP,
  [location] VARCHAR(255),
  [notes] TEXT,
  [subid] INT,
  [submembersid] INT,
  [featureid] INT,
  [codeid] INT,
  PRIMARY KEY ([featureusageid]),
  CONSTRAINT [FK_sol_featureusage.subid]
    FOREIGN KEY ([subid])
      REFERENCES [sol_subscriptions]([subid]),
  CONSTRAINT [FK_sol_featureusage.submembersid]
    FOREIGN KEY ([submembersid])
      REFERENCES [sol_subscriptionmembers]([submembersid]),
  CONSTRAINT [FK_sol_featureusage.featureid]
    FOREIGN KEY ([featureid])
      REFERENCES [sol_features]([featureid]),
  CONSTRAINT [FK_sol_featureusage.codeid]
    FOREIGN KEY ([codeid])
      REFERENCES [sol_accesscode]([codeid])
);

CREATE TABLE [sol_user_preferences] (
  [user_preferencesid] INT,
  [languageid] INT,
  [currencyid] INT,
  [userid] INT,
  PRIMARY KEY ([user_preferencesid]),
  CONSTRAINT [FK_sol_user_preferences.currencyid]
    FOREIGN KEY ([currencyid])
      REFERENCES [sol_currencies]([currencyid])
);

CREATE TABLE [sol_log_severity] (
  [log_severityid] INT,
  [name] VARCHAR(50),
  [severity_level] BIT,
  PRIMARY KEY ([log_severityid])
);

CREATE TABLE [sol_logs] (
  [logid] INT,
  [description] VARCHAR(200),
  [posttime] DATETIME,
  [computer] VARCHAR(100),
  [trace] TEXT,
  [reference_id1] BIGINT,
  [reference_id2] BIGINT,
  [value1] VARCHAR(180),
  [value2] VARCHAR(180),
  [checksum] VARCHAR(45),
  [log_typeid] INT,
  [log_sourceid] INT,
  [log_severityid] INT,
  PRIMARY KEY ([logid]),
  CONSTRAINT [FK_sol_logs.log_severityid]
    FOREIGN KEY ([log_severityid])
      REFERENCES [sol_log_severity]([log_severityid]),
  CONSTRAINT [FK_sol_logs.log_sourceid]
    FOREIGN KEY ([log_sourceid])
      REFERENCES [sol_log_source]([log_sourceid]),
  CONSTRAINT [FK_sol_logs.log_typeid]
    FOREIGN KEY ([log_typeid])
      REFERENCES [sol_log_type]([log_typeid])
);

CREATE TABLE [sol_contact_types] (
  [contact_typeid] INT,
  [name] VARCHAR(50),
  [description] VARCHAR(255),
  [isActive] TINYINT,
  PRIMARY KEY ([contact_typeid])
);

CREATE TABLE [sol_contact_info] (
  [contact_infoid] INT,
  [value] VARCHAR(255),
  [notes] VARCHAR(255),
  [enabled] BIT,
  [userid] INT,
  [contact_typeid] INT,
  PRIMARY KEY ([contact_infoid]),
  CONSTRAINT [FK_sol_contact_info.contact_typeid]
    FOREIGN KEY ([contact_typeid])
      REFERENCES [sol_contact_types]([contact_typeid]),
  CONSTRAINT [FK_sol_contact_info.userid]
    FOREIGN KEY ([userid])
      REFERENCES [sol_users]([userid])
);

CREATE TABLE [sol_languages] (
  [languageid] INT,
  [name] VARCHAR(50),
  [iso_code] CHAR(3),
  PRIMARY KEY ([languageid])
);

CREATE TABLE [sol_contact_info_providers] (
  [contactinfoproviderid] INT,
  [value] VARCHAR(100),
  [last_update] DATETIME,
  [idProvider] INT,
  [idUser] INT,
  [idContactType] INT,
  [enabled] BIT,
  PRIMARY KEY ([contactinfoproviderid]),
  CONSTRAINT [FK_sol_contact_info_providers.contactinfoproviderid]
    FOREIGN KEY ([contactinfoproviderid])
      REFERENCES [sol_providers]([providerid])
);

CREATE TABLE [sol_planprices] (
  [planpricesid] INT,
  [amount] DECIMAL(10,2),
  [postTime] DATETIME,
  [endDate] DATE,
  [current] BIT,
  [planid] INT,
  PRIMARY KEY ([planpricesid]),
  CONSTRAINT [FK_sol_planprices.planid]
    FOREIGN KEY ([planid])
      REFERENCES [sol_plans]([planid])
);

CREATE TABLE [sol_translations] (
  [translationid] INT,
  [key] VARCHAR(100),
  [value] TEXT,
  [languageid] INT,
  PRIMARY KEY ([translationid]),
  CONSTRAINT [FK_sol_translations.languageid]
    FOREIGN KEY ([languageid])
      REFERENCES [sol_languages]([languageid])
);

