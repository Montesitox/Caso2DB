USE SolturaDB

CREATE TABLE [sol_featuretype] (
  [featuretypeid] INT NOT NULL,
  [name] VARCHAR(50) NOT NULL,
  [enabled] BIT NOT NULL DEFAULT 1,
  [description] VARCHAR(255) NULL,
  PRIMARY KEY ([featuretypeid])
);

CREATE TABLE [sol_log_source] (
  [log_sourceid] INT NOT NULL,
  [name] VARCHAR(100) NOT NULL,
  [system_component] VARCHAR(100) NOT NULL,
  PRIMARY KEY ([log_sourceid])
);

CREATE TABLE [sol_recurrencetypes] (
  [recurrencetypeid] INT NOT NULL,
  [name] VARCHAR(20) NOT NULL,
  PRIMARY KEY ([recurrencetypeid])
);

CREATE TABLE [sol_schedules] (
  [scheduleid] INT NOT NULL,
  [name] VARCHAR(100) NOT NULL,
  [description] TEXT NULL,
  [recurrencetypeid] INT NOT NULL,
  [active] BIT NOT NULL DEFAULT 1,
  [interval] INT NOT NULL,
  [startdate] DATETIME NOT NULL,
  [endtype] VARCHAR(20) NOT NULL CHECK (endtype IN ('DATE', 'REPETITIONS', 'NEVER')),
  [repetitions] INT NULL,
  PRIMARY KEY ([scheduleid]),
  CONSTRAINT [FK_sol_schedules.recurrencetypeid]
    FOREIGN KEY ([recurrencetypeid])
      REFERENCES [sol_recurrencetypes]([recurrencetypeid])
);

CREATE TABLE [sol_category] (
  [categoryid] INT NOT NULL,
  [name] VARCHAR(75) NOT NULL,
  PRIMARY KEY ([categoryid])
);

CREATE TABLE [sol_providers] (
  [providerid] INT NOT NULL,
  [brand_name] VARCHAR(100) NOT NULL,
  [legal_name] VARCHAR(150) NOT NULL,
  [legal_identification] VARCHAR(50) NOT NULL,
  [enabled] BIT NOT NULL DEFAULT 1,
  [categoryId] INT NOT NULL,
  PRIMARY KEY ([providerid]),
  CONSTRAINT [FK_sol_providers.categoryId]
    FOREIGN KEY ([categoryId])
      REFERENCES [sol_category]([categoryid])
);


CREATE TABLE [api_integrations] (
  [id] SMALLINT NOT NULL,
  [name] VARCHAR(80) NOT NULL,
  [public_key] VARCHAR(200) NULL,
  [private_key] VARCHAR(200) NULL,
  [url] VARCHAR(200) NOT NULL,
  [creation_date] DATETIME NOT NULL,
  [last_update] DATETIME NOT NULL,
  [enabled] BIT NOT NULL DEFAULT 1,
  [idProvider] INT NOT NULL,
  PRIMARY KEY ([id]),
  CONSTRAINT [FK_api_integrations.idProvider]
    FOREIGN KEY ([idProvider])
      REFERENCES [sol_providers]([providerid])
);

CREATE TABLE [sol_pay_methods] (
  [id] INT NOT NULL,
  [name] VARCHAR(75) NOT NULL,
  [secret_key] VARBINARY(255) NOT NULL,
  [logo_icon_url] VARCHAR(200) NULL,
  [enabled] BIT NOT NULL DEFAULT 1,
  [idApiIntegration] SMALLINT NOT NULL,
  PRIMARY KEY ([id]),
  CONSTRAINT [FK_sol_pay_methods.idApiIntegration]
    FOREIGN KEY ([idApiIntegration])
      REFERENCES [api_integrations]([id])
);

CREATE TABLE [sol_available_pay_methods] (
  [id] INT NOT NULL,
  [name] VARCHAR(50) NOT NULL,
  [token] VARCHAR(255) NOT NULL,
  [exp_token] DATE NOT NULL,
  [mask_account] VARCHAR(50) NULL,
  [idMethod] INT NOT NULL,
  PRIMARY KEY ([id]),
  CONSTRAINT [FK_sol_available_pay_methods.idMethod]
    FOREIGN KEY ([idMethod])
      REFERENCES [sol_pay_methods]([id])
);

CREATE TABLE [sol_paymentstatus] (
  [paymentstatusid] INT NOT NULL,
  [name] VARCHAR(50) NOT NULL,
  PRIMARY KEY ([paymentstatusid])
);

CREATE TABLE [sol_payments] (
  [paymentid] INT NOT NULL,
  [amount] DECIMAL(10,2) NOT NULL,
  [taxamount] DECIMAL(10,2) NOT NULL,
  [discountporcent] DECIMAL(5,2) NOT NULL,
  [realamount] DECIMAL(10,2) NOT NULL,
  [result] VARCHAR(10) NULL,
  [authcode] VARCHAR(100) NULL,
  [referencenumber] VARCHAR(100) NULL,
  [chargetoken] VARBINARY(200) NULL,
  [date] DATETIME NOT NULL,
  [checksum] VARBINARY(250) NULL,
  [statusid] INT NOT NULL,
  [paymentmethodid] INT NOT NULL,
  [availablemethodid] INT NOT NULL,
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
  [paymentscheduleid] INT NOT NULL,
  [paymentid] INT NOT NULL,
  [scheduleid] INT NOT NULL,
  [nextpayment] DATETIME NOT NULL,
  [lastpayment] DATETIME NULL,
  [remainingpayments] INT NULL,
  [active] BIT NOT NULL DEFAULT 1,
  PRIMARY KEY ([paymentscheduleid]),
  CONSTRAINT [FK_sol_paymentschedules.scheduleid]
    FOREIGN KEY ([scheduleid])
      REFERENCES [sol_schedules]([scheduleid]),
  CONSTRAINT [FK_sol_paymentschedules.paymentid]
    FOREIGN KEY ([paymentid])
      REFERENCES [sol_payments]([paymentid])
);

CREATE TABLE [sol_transactionsubtypes] (
  [transactionsubtypeid] INT NOT NULL,
  [name] VARCHAR(30) NOT NULL,
  PRIMARY KEY ([transactionsubtypeid])
);

CREATE TABLE [sol_schedulesdetails] (
  [scheduledetailid] INT NOT NULL,
  [deleted] BIT NOT NULL DEFAULT 1,
  [basedate] DATETIME NOT NULL,
  [datepart] VARCHAR(20) NOT NULL,
  [maxdelaydays] INT NOT NULL,
  [executiontime] DATETIME NULL,
  [scheduleid] INT NOT NULL,
  [timezone] VARCHAR(50) NOT NULL,
  PRIMARY KEY ([scheduledetailid]),
  CONSTRAINT [FK_sol_schedulesdetails.scheduleid]
    FOREIGN KEY ([scheduleid])
      REFERENCES [sol_schedules]([scheduleid])
);

CREATE TABLE [sol_subsmemberstypes] (
  [membertype] INT NOT NULL,
  [name] VARCHAR(50) NOT NULL,
  PRIMARY KEY ([membertype])
);

CREATE TABLE [sol_subscriptionstatus] (
  [statusid] INT NOT NULL,
  [name] VARCHAR(20) NOT NULL,
  PRIMARY KEY ([statusid])
);

CREATE TABLE [sol_countries] (
  [countryid] INT NOT NULL,
  [name] VARCHAR(60) NOT NULL,
  PRIMARY KEY ([countryid])
);

CREATE TABLE [sol_states] (
  [stateid] INT NOT NULL,
  [name] VARCHAR(60) NOT NULL,
  [countryid] INT NOT NULL,
  PRIMARY KEY ([stateid]),
  CONSTRAINT [FK_sol_states.countryid]
    FOREIGN KEY ([countryid])
      REFERENCES [sol_countries]([countryid])
);

CREATE TABLE [sol_cities] (
  [cityid] INT NOT NULL,
  [name] VARCHAR(60) NOT NULL,
  [stateid] INT NOT NULL,
  PRIMARY KEY ([cityid]),
  CONSTRAINT [FK_sol_cities.stateid]
    FOREIGN KEY ([stateid])
      REFERENCES [sol_states]([stateid])
);

CREATE TABLE [sol_address] (
  [addressid] INT NOT NULL,
  [line1] VARCHAR(200) NOT NULL,
  [line2] VARCHAR(200) NULL,
  [zipcode] VARCHAR(9) NOT NULL,
  [location] GEOGRAPHY NOT NULL,
  [cityid] INT NOT NULL,
  PRIMARY KEY ([addressid]),
  CONSTRAINT [FK_sol_address.cityid]
    FOREIGN KEY ([cityid])
      REFERENCES [sol_cities]([cityid])
);

CREATE TABLE [sol_users] (
  [userid] INT NOT NULL,
  [username] VARCHAR(100) NOT NULL,
  [firstname] VARCHAR(100) NOT NULL,
  [lastname] VARCHAR(100) NOT NULL,
  [email] VARCHAR(150) NOT NULL,
  [password] VARBINARY(250) NOT NULL,
  [isActive] TINYINT NOT NULL DEFAULT 1,
  [addressid] INT NOT NULL,
  PRIMARY KEY ([userid]),
  CONSTRAINT [FK_sol_users.addressid]
    FOREIGN KEY ([addressid])
      REFERENCES [sol_address]([addressid])
);

CREATE TABLE [sol_plans] (
  [planid] INT NOT NULL,
  [name] VARCHAR(75) NOT NULL,
  [description] TEXT NULL,
  [customizable] BIT NOT NULL DEFAULT 1,
  [limit_people] SMALLINT NOT NULL,
  [enabled] BIT NOT NULL DEFAULT 1,
  [codigoid] INT NOT NULL,
  PRIMARY KEY ([planid])
);

CREATE TABLE [sol_subscriptions] (
  [subid] INT NOT NULL,
  [startdate] DATETIME NOT NULL,
  [enddate] DATETIME NOT NULL,
  [autorenew] BIT NOT NULL DEFAULT 1,
  [statusid] INT NOT NULL,
  [scheduleid] INT NOT NULL,
  [planid] INT NOT NULL,
  [userid] INT NOT NULL,
  PRIMARY KEY ([subid]),
  CONSTRAINT [FK_sol_subscriptions.scheduleid]
    FOREIGN KEY ([scheduleid])
      REFERENCES [sol_schedules]([scheduleid]),
  CONSTRAINT [FK_sol_subscriptions.statusid]
    FOREIGN KEY ([statusid])
      REFERENCES [sol_subscriptionstatus]([statusid]),
  CONSTRAINT [FK_sol_subscriptions.userid]
    FOREIGN KEY ([userid])
      REFERENCES [sol_users]([userid]),
  CONSTRAINT [FK_sol_subscriptions.planid]
    FOREIGN KEY ([planid])
      REFERENCES [sol_plans]([planid]),
);

CREATE TABLE [sol_subscriptionmembers] (
  [submembersid] INT NOT NULL,
  [membertype] INT NOT NULL,
  [isactive] DATETIME NOT NULL,
  [usersubid] INT NOT NULL,
  PRIMARY KEY ([submembersid]),
  CONSTRAINT [FK_sol_subscriptionmembers.membertype]
    FOREIGN KEY ([membertype])
      REFERENCES [sol_subsmemberstypes]([membertype]),
  CONSTRAINT [FK_sol_subscriptionmembers.usersubid]
    FOREIGN KEY ([usersubid])
      REFERENCES [sol_subscriptions]([subid])
);

CREATE TABLE [sol_servicetype] (
  [servicetypeid] INT NOT NULL,
  [name] VARCHAR(75) NOT NULL,
  [description] VARCHAR(255) NULL,
  [enabled] BIT NOT NULL DEFAULT 1,
  PRIMARY KEY ([servicetypeid])
);

CREATE TABLE [sol_contracts] (
  [contractid] INT NOT NULL,
  [description] VARCHAR(100) NOT NULL,
  [start_date] DATE NOT NULL,
  [end_date] DATE NOT NULL,
  [enabled] BIT NOT NULL DEFAULT 1,
  [providerid] INT NOT NULL,
  PRIMARY KEY ([contractid]),
  CONSTRAINT [FK_sol_contracts.providerid]
    FOREIGN KEY ([providerid])
      REFERENCES [sol_providers]([providerid])
);

CREATE TABLE [sol_price_configurations] (
  [price_config_id] INT NOT NULL,
  [provider_price] DECIMAL(10,2) NOT NULL,
  [margin_type] VARCHAR(10) NOT NULL,
  [margin_value] DECIMAL(10,2) NOT NULL,
  [soltura_percent] DECIMAL(5,2) NOT NULL,
  [client_percent] DECIMAL(5,2) NOT NULL,
  PRIMARY KEY ([price_config_id])
);

CREATE TABLE [sol_service] (
  [serviceid] INT NOT NULL,
  [name] VARCHAR(100) NOT NULL,
  [description] VARCHAR(100) NOT NULL,
  [dataType] VARCHAR(50) NOT NULL,
  [original_amount] DECIMAL(10,2) NOT NULL,
  [sale_amount] DECIMAL(10,2) NOT NULL,
  [enabled] BIT NOT NULL DEFAULT 1,
  [contractid] INT NOT NULL,
  [currencyid] INT NOT NULL,
  [servicetypeid] INT NOT NULL,
  [price_config_id] INT NOT NULL,
  PRIMARY KEY ([serviceid]),
  CONSTRAINT [FK_sol_service.servicetypeid]
    FOREIGN KEY ([servicetypeid])
      REFERENCES [sol_servicetype]([servicetypeid]),
  CONSTRAINT [FK_sol_service.contractid]
    FOREIGN KEY ([contractid])
      REFERENCES [sol_contracts]([contractid]),
  CONSTRAINT [FK_sol_service.price_config_id]
    FOREIGN KEY ([price_config_id])
      REFERENCES [sol_price_configurations]([price_config_id])
);

CREATE TABLE [sol_conditiontypes] (
  [conditiontypeid] INT NOT NULL,
  [name] VARCHAR(75) NOT NULL,
  [datatype] VARCHAR(50) NOT NULL,
  PRIMARY KEY ([conditiontypeid])
);

CREATE TABLE [sol_conditions] (
  [conditionid] INT NOT NULL,
  [description] VARCHAR(100) NOT NULL,
  [conditiontypeid] INT NOT NULL,
  [quantity_condition] VARCHAR(100) NOT NULL,
  [discount] DECIMAL(5,2) NOT NULL,
  [amount_to_pay] DECIMAL(10,2) NOT NULL,
  [enabled] BIT NOT NULL DEFAULT 1,
  [serviceid] INT NOT NULL,
  [price_config_id] INT NOT NULL,
  PRIMARY KEY ([conditionid]),
  CONSTRAINT [FK_sol_conditions.serviceid]
    FOREIGN KEY ([serviceid])
      REFERENCES [sol_service]([serviceid]),
  CONSTRAINT [FK_sol_conditions.conditiontypeid]
    FOREIGN KEY ([conditiontypeid])
      REFERENCES [sol_conditiontypes]([conditiontypeid]),
  CONSTRAINT [FK_sol_conditions.price_config_id]
    FOREIGN KEY ([price_config_id])
      REFERENCES [sol_price_configurations]([price_config_id])
);

CREATE TABLE [sol_currencies] (
  [currencyid] INT NOT NULL,
  [name] VARCHAR(50) NOT NULL,
  [acronym] VARCHAR(15) NOT NULL,
  [country] VARCHAR(45) NOT NULL,
  [symbol] VARCHAR(5) NOT NULL,
  PRIMARY KEY ([currencyid])
);

CREATE TABLE [sol_exchangerates] (
  [exchangerateid] INT NOT NULL,
  [startdate] DATETIME NOT NULL,
  [enddate] DATETIME NULL,
  [exchangerate] DECIMAL(10,4) NOT NULL,
  [currentexchangerate] BIT NOT NULL DEFAULT 1,
  [currencyidsource FK] INT NOT NULL,
  [currencyiddestiny FK] INT NOT NULL,
  PRIMARY KEY ([exchangerateid]),
  CONSTRAINT [FK_sol_exchangerates.currencyidsource FK]
    FOREIGN KEY ([currencyidsource FK])
      REFERENCES [sol_currencies]([currencyid]),
  CONSTRAINT [FK_sol_exchangerates.currencyiddestiny FK]
    FOREIGN KEY ([currencyiddestiny FK])
      REFERENCES [sol_currencies]([currencyid])
);

CREATE TABLE [sol_transactiontypes] (
  [transactiontypeid] INT NOT NULL,
  [name] VARCHAR(30) NOT NULL,
  PRIMARY KEY ([transactiontypeid])
);

CREATE TABLE [sol_transactions] (
  [transactionid] INT NOT NULL,
  [name] VARCHAR(75) NOT NULL,
  [description] TEXT NULL,
  [amount] DECIMAL(10,4) NULL,
  [referencenumber] VARCHAR(100) NULL,
  [transactiondate] DATETIME NOT NULL,
  [officetime] DATETIME NOT NULL,
  [checksum] VARBINARY(250) NULL,
  [transactiontypeid] INT NOT NULL,
  [transactionsubtypeid] INT NOT NULL,
  [currencyid] INT NOT NULL,
  [exchangerateid] INT NOT NULL,
  [payid] INT NULL,
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
  [log_typeid] INT NOT NULL,
  [name] VARCHAR(100) NOT NULL,
  [description] TEXT NULL,
  PRIMARY KEY ([log_typeid])
);



CREATE TABLE [sol_quantitytypes] (
  [quantitytypeid] INT NOT NULL,
  [typename] VARCHAR(50) NOT NULL,
  [description] TEXT NULL,
  [iscumulative] BIT NOT NULL DEFAULT 1,
  PRIMARY KEY ([quantitytypeid])
);

CREATE TABLE [sol_planfeatures] (
  [planfeatureid] INT NOT NULL,
  [value] VARCHAR(100) NOT NULL,
  [enabled] INT NOT NULL DEFAULT 1,
  [quantitytypeid] INT NOT NULL,
  [serviceid] INT NOT NULL,
  [plantid] INT NOT NULL,
  PRIMARY KEY ([planfeatureid]),
  CONSTRAINT [FK_sol_planfeatures.serviceid]
    FOREIGN KEY ([serviceid])
      REFERENCES [sol_service]([serviceid]),
  CONSTRAINT [FK_sol_planfeatures.quantitytypeid]
    FOREIGN KEY ([quantitytypeid])
      REFERENCES [sol_quantitytypes]([quantitytypeid]),
  CONSTRAINT [FK_sol_planfeatures.plantid]
    FOREIGN KEY ([plantid])
      REFERENCES [sol_plans]([planid])
);

CREATE TABLE [sol_accesscode] (
  [codeid] INT NOT NULL,
  [type] VARCHAR(100) NOT NULL,
  [value] VARBINARY NOT NULL,
  [isactive] BIT NOT NULL DEFAULT 1,
  [expirydate] TIMESTAMP NOT NULL,
  [submembersid] INT NOT NULL,
  PRIMARY KEY ([codeid]),
  CONSTRAINT [FK_sol_accesscode.submembersid]
    FOREIGN KEY ([submembersid])
      REFERENCES [sol_subscriptionmembers]([submembersid])
);

CREATE TABLE [sol_featureusage] (
  [featureusageid] INT NOT NULL,
  [quantityused] DECIMAL NOT NULL,
  [porcentageconsumed] DECIMAL NOT NULL,
  [usagedate] TIMESTAMP NULL,
  [location] VARCHAR(255) NULL,
  [notes] TEXT NULL,
  [subid] INT NOT NULL,
  [submembersid] INT NOT NULL,
  [serviceid] INT NOT NULL,
  [codeid] INT NOT NULL,
  PRIMARY KEY ([featureusageid]),
  CONSTRAINT [FK_sol_featureusage.subid]
    FOREIGN KEY ([subid])
      REFERENCES [sol_subscriptions]([subid]),
  CONSTRAINT [FK_sol_featureusage.submembersid]
    FOREIGN KEY ([submembersid])
      REFERENCES [sol_subscriptionmembers]([submembersid]),
  CONSTRAINT [FK_sol_featureusage.serviceid]
    FOREIGN KEY ([serviceid])
      REFERENCES [sol_service]([serviceid]),
  CONSTRAINT [FK_sol_featureusage.codeid]
    FOREIGN KEY ([codeid])
      REFERENCES [sol_accesscode]([codeid])
);

CREATE TABLE [sol_user_preferences] (
  [user_preferencesid] INT NOT NULL,
  [languageid] INT NOT NULL,
  [currencyid] INT NOT NULL,
  [userid] INT NOT NULL,
  PRIMARY KEY ([user_preferencesid]),
  CONSTRAINT [FK_sol_user_preferences.currencyid]
    FOREIGN KEY ([currencyid])
      REFERENCES [sol_currencies]([currencyid])
);

CREATE TABLE [sol_log_severity] (
  [log_severityid] INT NOT NULL,
  [name] VARCHAR(50) NOT NULL,
  [severity_level] BIT NOT NULL DEFAULT 1,
  PRIMARY KEY ([log_severityid])
);

CREATE TABLE [sol_logs] (
  [logid] INT NOT NULL,
  [description] VARCHAR(200) NOT NULL,
  [posttime] DATETIME NOT NULL,
  [computer] VARCHAR(100) NOT NULL,
  [trace] TEXT NULL,
  [reference_id1] BIGINT NULL,
  [reference_id2] BIGINT NULL,
  [value1] VARCHAR(180) NULL,
  [value2] VARCHAR(180) NULL,
  [checksum] VARCHAR(45) NOT NULL,
  [log_typeid] INT NOT NULL,
  [log_sourceid] INT NOT NULL,
  [log_severityid] INT NOT NULL,
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
  [contact_typeid] INT NOT NULL,
  [name] VARCHAR(50) NOT NULL,
  [description] VARCHAR(255) NULL,
  [isActive] TINYINT NOT NULL DEFAULT 1,
  PRIMARY KEY ([contact_typeid])
);

CREATE TABLE [sol_contact_info] (
  [contact_infoid] INT NOT NULL,
  [value] VARCHAR(255) NOT NULL,
  [notes] VARCHAR(255) NULL,
  [enabled] BIT NOT NULL DEFAULT 1,
  [userid] INT NOT NULL,
  [contact_typeid] INT NOT NULL,
  PRIMARY KEY ([contact_infoid]),
  CONSTRAINT [FK_sol_contact_info.contact_typeid]
    FOREIGN KEY ([contact_typeid])
      REFERENCES [sol_contact_types]([contact_typeid]),
  CONSTRAINT [FK_sol_contact_info.userid]
    FOREIGN KEY ([userid])
      REFERENCES [sol_users]([userid])
);

CREATE TABLE [sol_languages] (
  [languageid] INT NOT NULL,
  [name] VARCHAR(50) NOT NULL,
  [iso_code] CHAR(3) NOT NULL,
  PRIMARY KEY ([languageid])
);

CREATE TABLE [sol_contact_info_providers] (
  [contactinfoproviderid] INT NOT NULL,
  [value] VARCHAR(100) NOT NULL,
  [last_update] DATETIME NOT NULL,
  [idProvider] INT NOT NULL,
  [idUser] INT NOT NULL,
  [idContactType] INT NOT NULL,
  [enabled] BIT NOT NULL DEFAULT 1,
  PRIMARY KEY ([contactinfoproviderid]),
  CONSTRAINT [FK_sol_contact_info_providers.contactinfoproviderid]
    FOREIGN KEY ([contactinfoproviderid])
      REFERENCES [sol_providers]([providerid])
);

CREATE TABLE [sol_planprices] (
  [planpricesid] INT NOT NULL,
  [amount] DECIMAL(10,2) NOT NULL,
  [postTime] DATETIME NOT NULL,
  [endDate] DATE NOT NULL,
  [current] BIT NOT NULL DEFAULT 1,
  [planid] INT NOT NULL,
  PRIMARY KEY ([planpricesid]),
  CONSTRAINT [FK_sol_planprices.planid]
    FOREIGN KEY ([planid])
      REFERENCES [sol_plans]([planid])
);

CREATE TABLE [sol_translations] (
  [translationid] INT NOT NULL,
  [key] VARCHAR(100) NOT NULL,
  [value] TEXT NOT NULL,
  [languageid] INT NOT NULL,
  PRIMARY KEY ([translationid]),
  CONSTRAINT [FK_sol_translations.languageid]
    FOREIGN KEY ([languageid])
      REFERENCES [sol_languages]([languageid])
);


